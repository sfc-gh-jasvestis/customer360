-- ============================================================================
-- Retail Watch Store - AI Functions
-- ============================================================================
-- AI-powered functions for churn prediction, sentiment analysis, 
-- price optimization, and personal shopping recommendations

USE DATABASE retail_watch_db;
USE SCHEMA public;
USE WAREHOUSE retail_watch_wh;

SELECT '🤖 Creating AI Functions for Retail Watch Store...' as ai_setup_step;

-- ============================================================================
-- 1. CHURN PREDICTION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION predict_customer_churn(customer_id STRING)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'customer_id', customer_id,
        'prediction_timestamp', CURRENT_TIMESTAMP(),
        'churn_analysis', (
            WITH customer_metrics AS (
                SELECT 
                    c.customer_id,
                    c.churn_risk_score,
                    c.satisfaction_score,
                    c.engagement_score,
                    c.total_spent,
                    c.total_orders,
                    c.last_purchase_date,
                    c.last_login_date,
                    c.website_visits_30d,
                    c.email_opens_30d,
                    DATEDIFF('day', c.last_purchase_date, CURRENT_TIMESTAMP()) as days_since_last_purchase,
                    DATEDIFF('day', c.last_login_date, CURRENT_TIMESTAMP()) as days_since_last_login,
                    -- Count recent customer service issues
                    (SELECT COUNT(*) FROM customer_interactions 
                     WHERE customer_id = c.customer_id 
                     AND intent_classification = 'complaint' 
                     AND interaction_date >= DATEADD('day', -90, CURRENT_TIMESTAMP())) as recent_complaints,
                    -- Average sentiment from recent reviews
                    (SELECT AVG(sentiment_score) FROM product_reviews 
                     WHERE customer_id = c.customer_id 
                     AND review_date >= DATEADD('day', -180, CURRENT_TIMESTAMP())) as avg_review_sentiment
                FROM customers c
                WHERE c.customer_id = customer_id
            )
            SELECT OBJECT_CONSTRUCT(
                'risk_score', churn_risk_score,
                'risk_level', CASE 
                    WHEN churn_risk_score >= 0.7 THEN 'HIGH'
                    WHEN churn_risk_score >= 0.4 THEN 'MEDIUM'
                    WHEN churn_risk_score >= 0.2 THEN 'LOW'
                    ELSE 'VERY_LOW'
                END,
                'risk_factors', ARRAY_CONSTRUCT(
                    CASE WHEN days_since_last_purchase > 90 THEN 'No purchases in 90+ days' END,
                    CASE WHEN days_since_last_login > 30 THEN 'Inactive for 30+ days' END,
                    CASE WHEN satisfaction_score < 5.0 THEN 'Low satisfaction score' END,
                    CASE WHEN engagement_score < 0.3 THEN 'Low engagement score' END,
                    CASE WHEN recent_complaints > 0 THEN 'Recent customer service complaints' END,
                    CASE WHEN avg_review_sentiment < 0 THEN 'Negative review sentiment' END,
                    CASE WHEN email_opens_30d = 0 THEN 'Not opening marketing emails' END,
                    CASE WHEN website_visits_30d < 5 THEN 'Low website engagement' END
                ),
                'retention_recommendations', ARRAY_CONSTRUCT(
                    CASE WHEN churn_risk_score >= 0.7 THEN 'URGENT: Immediate personal outreach required' END,
                    CASE WHEN days_since_last_purchase > 60 THEN 'Send targeted product recommendations' END,
                    CASE WHEN satisfaction_score < 6.0 THEN 'Proactive customer service follow-up' END,
                    CASE WHEN total_spent > 5000 AND churn_risk_score > 0.3 THEN 'VIP retention offer' END,
                    CASE WHEN engagement_score < 0.5 THEN 'Re-engagement campaign with personalized content' END,
                    'Monitor customer behavior closely'
                ),
                'predicted_actions', OBJECT_CONSTRUCT(
                    'discount_offer', CASE WHEN churn_risk_score > 0.5 THEN TRUE ELSE FALSE END,
                    'personal_outreach', CASE WHEN churn_risk_score > 0.6 THEN TRUE ELSE FALSE END,
                    'priority_support', CASE WHEN recent_complaints > 0 OR satisfaction_score < 5.0 THEN TRUE ELSE FALSE END
                )
            )
            FROM customer_metrics
        )
    )
$$;

-- ============================================================================
-- 2. SENTIMENT ANALYSIS FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION analyze_review_sentiment(review_text STRING)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    WITH sentiment_analysis AS (
        SELECT 
            review_text,
            -- Use Snowflake Cortex SENTIMENT function if available
            TRY_CAST(SNOWFLAKE.CORTEX.SENTIMENT(review_text) AS FLOAT) as cortex_sentiment,
            -- Fallback rule-based sentiment analysis
            CASE 
                WHEN UPPER(review_text) LIKE '%LOVE%' OR UPPER(review_text) LIKE '%EXCELLENT%' 
                     OR UPPER(review_text) LIKE '%PERFECT%' OR UPPER(review_text) LIKE '%AMAZING%'
                     OR UPPER(review_text) LIKE '%OUTSTANDING%' THEN 0.8
                WHEN UPPER(review_text) LIKE '%GOOD%' OR UPPER(review_text) LIKE '%GREAT%' 
                     OR UPPER(review_text) LIKE '%NICE%' OR UPPER(review_text) LIKE '%HAPPY%' THEN 0.6
                WHEN UPPER(review_text) LIKE '%HATE%' OR UPPER(review_text) LIKE '%TERRIBLE%' 
                     OR UPPER(review_text) LIKE '%AWFUL%' OR UPPER(review_text) LIKE '%DISAPPOINTING%'
                     OR UPPER(review_text) LIKE '%WORST%' THEN -0.7
                WHEN UPPER(review_text) LIKE '%BAD%' OR UPPER(review_text) LIKE '%POOR%' 
                     OR UPPER(review_text) LIKE '%PROBLEM%' OR UPPER(review_text) LIKE '%ISSUE%' THEN -0.4
                ELSE 0.1
            END as rule_based_sentiment
    )
    SELECT OBJECT_CONSTRUCT(
        'sentiment_score', COALESCE(cortex_sentiment, rule_based_sentiment),
        'sentiment_label', CASE 
            WHEN COALESCE(cortex_sentiment, rule_based_sentiment) > 0.3 THEN 'positive'
            WHEN COALESCE(cortex_sentiment, rule_based_sentiment) < -0.3 THEN 'negative'
            ELSE 'neutral'
        END,
        'confidence', CASE 
            WHEN cortex_sentiment IS NOT NULL THEN 0.95
            ELSE 0.75
        END,
        'key_themes', ARRAY_COMPACT(ARRAY_CONSTRUCT(
            CASE WHEN UPPER(review_text) LIKE '%QUALITY%' THEN 'quality' END,
            CASE WHEN UPPER(review_text) LIKE '%PRICE%' OR UPPER(review_text) LIKE '%COST%' THEN 'price' END,
            CASE WHEN UPPER(review_text) LIKE '%SERVICE%' OR UPPER(review_text) LIKE '%SUPPORT%' THEN 'service' END,
            CASE WHEN UPPER(review_text) LIKE '%DELIVERY%' OR UPPER(review_text) LIKE '%SHIPPING%' THEN 'delivery' END,
            CASE WHEN UPPER(review_text) LIKE '%DESIGN%' OR UPPER(review_text) LIKE '%APPEARANCE%' THEN 'design' END,
            CASE WHEN UPPER(review_text) LIKE '%BATTERY%' OR UPPER(review_text) LIKE '%CHARGING%' THEN 'battery' END,
            CASE WHEN UPPER(review_text) LIKE '%ACCURACY%' OR UPPER(review_text) LIKE '%TIME%' THEN 'accuracy' END,
            CASE WHEN UPPER(review_text) LIKE '%DURABILITY%' OR UPPER(review_text) LIKE '%DURABLE%' THEN 'durability' END
        ))
    )
    FROM sentiment_analysis
$$;

-- ============================================================================
-- 3. PRICE OPTIMIZATION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION optimize_product_pricing(product_id STRING)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    WITH pricing_analysis AS (
        SELECT 
            p.product_id,
            p.product_name,
            p.current_price,
            p.retail_price,
            p.cost_price,
            p.stock_quantity,
            p.avg_rating,
            p.review_count,
            b.brand_tier,
            
            -- Sales metrics
            COALESCE(sales.total_sold, 0) as total_sold_30d,
            COALESCE(sales.revenue_30d, 0) as revenue_30d,
            
            -- Competitor analysis (simplified)
            AVG(p2.current_price) as category_avg_price,
            MIN(p2.current_price) as category_min_price,
            MAX(p2.current_price) as category_max_price,
            
            -- Demand indicators
            COALESCE(events.product_views_30d, 0) as product_views_30d,
            COALESCE(events.cart_adds_30d, 0) as cart_adds_30d,
            
            -- Review sentiment
            AVG(COALESCE(pr.sentiment_score, 0)) as avg_sentiment
            
        FROM products p
        JOIN watch_brands b ON p.brand_id = b.brand_id
        LEFT JOIN products p2 ON p2.category_id = p.category_id AND p2.product_id != p.product_id
        LEFT JOIN (
            SELECT 
                oi.product_id,
                COUNT(*) as total_sold,
                SUM(oi.total_price) as revenue_30d
            FROM order_items oi
            JOIN orders o ON oi.order_id = o.order_id
            WHERE o.order_date >= DATEADD('day', -30, CURRENT_TIMESTAMP())
            GROUP BY oi.product_id
        ) sales ON p.product_id = sales.product_id
        LEFT JOIN (
            SELECT 
                product_id,
                COUNT(CASE WHEN event_type = 'product_view' THEN 1 END) as product_views_30d,
                COUNT(CASE WHEN event_type = 'cart_add' THEN 1 END) as cart_adds_30d
            FROM customer_events 
            WHERE event_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
            GROUP BY product_id
        ) events ON p.product_id = events.product_id
        LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
        WHERE p.product_id = product_id
        GROUP BY p.product_id, p.product_name, p.current_price, p.retail_price, p.cost_price, 
                 p.stock_quantity, p.avg_rating, p.review_count, b.brand_tier, 
                 sales.total_sold, sales.revenue_30d, events.product_views_30d, events.cart_adds_30d
    )
    SELECT OBJECT_CONSTRUCT(
        'product_id', product_id,
        'current_analysis', OBJECT_CONSTRUCT(
            'current_price', current_price,
            'margin_percent', ROUND(((current_price - cost_price) / current_price) * 100, 2),
            'vs_category_avg', ROUND(((current_price - category_avg_price) / category_avg_price) * 100, 2),
            'demand_score', CASE 
                WHEN product_views_30d > 100 AND cart_adds_30d > 10 THEN 'HIGH'
                WHEN product_views_30d > 50 AND cart_adds_30d > 5 THEN 'MEDIUM'
                ELSE 'LOW'
            END
        ),
        'optimization_strategy', CASE
            -- High demand, low stock - increase price
            WHEN product_views_30d > 100 AND stock_quantity < 10 THEN 'PREMIUM_PRICING'
            -- Low demand, high stock - decrease price
            WHEN product_views_30d < 20 AND stock_quantity > 20 THEN 'CLEARANCE_PRICING'
            -- High sentiment, luxury brand - maintain premium
            WHEN avg_sentiment > 0.5 AND brand_tier = 'luxury' THEN 'PREMIUM_MAINTAIN'
            -- Average performance - competitive pricing
            ELSE 'COMPETITIVE_PRICING'
        END,
        'recommended_price', CASE
            WHEN product_views_30d > 100 AND stock_quantity < 10 THEN current_price * 1.05
            WHEN product_views_30d < 20 AND stock_quantity > 20 THEN current_price * 0.90
            WHEN avg_sentiment < 0 THEN current_price * 0.95
            ELSE current_price
        END,
        'price_factors', ARRAY_CONSTRUCT(
            CASE WHEN stock_quantity < 10 THEN 'Low inventory' END,
            CASE WHEN product_views_30d > category_avg_price THEN 'High demand' END,
            CASE WHEN avg_sentiment > 0.5 THEN 'Positive reviews' END,
            CASE WHEN brand_tier = 'luxury' THEN 'Premium brand positioning' END,
            CASE WHEN current_price > category_avg_price * 1.2 THEN 'Above market price' END,
            CASE WHEN total_sold_30d = 0 THEN 'No recent sales' END
        ),
        'expected_impact', OBJECT_CONSTRUCT(
            'revenue_change_estimate', CASE
                WHEN product_views_30d > 100 AND stock_quantity < 10 THEN '+5-15%'
                WHEN product_views_30d < 20 AND stock_quantity > 20 THEN '+10-25%'
                ELSE '0-5%'
            END,
            'margin_impact', 'Maintains healthy margins',
            'competitive_position', CASE
                WHEN current_price > category_avg_price THEN 'Premium positioned'
                WHEN current_price < category_avg_price THEN 'Value positioned'
                ELSE 'Market aligned'
            END
        )
    )
    FROM pricing_analysis
$$;

-- ============================================================================
-- 4. PERSONAL SHOPPER RECOMMENDATION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION get_personal_recommendations(customer_id STRING, context STRING DEFAULT 'general')
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    WITH customer_profile AS (
        SELECT 
            c.*,
            -- Get customer's purchase history
            LISTAGG(DISTINCT b.brand_name, ', ') as purchased_brands,
            LISTAGG(DISTINCT p.case_material, ', ') as preferred_materials,
            AVG(oi.unit_price) as avg_purchase_price,
            LISTAGG(DISTINCT wc.category_name, ', ') as purchased_categories
        FROM customers c
        LEFT JOIN orders o ON c.customer_id = o.customer_id
        LEFT JOIN order_items oi ON o.order_id = oi.order_id
        LEFT JOIN products p ON oi.product_id = p.product_id
        LEFT JOIN watch_brands b ON p.brand_id = b.brand_id
        LEFT JOIN watch_categories wc ON p.category_id = wc.category_id
        WHERE c.customer_id = customer_id
        GROUP BY c.customer_id, c.email, c.first_name, c.last_name, c.phone, c.date_of_birth, 
                 c.gender, c.registration_date, c.street_address, c.city, c.state, c.postal_code, 
                 c.country, c.customer_tier, c.preferred_brands, c.price_range_min, c.price_range_max, 
                 c.style_preferences, c.total_spent, c.total_orders, c.avg_order_value, 
                 c.last_purchase_date, c.last_login_date, c.website_visits_30d, c.email_opens_30d, 
                 c.email_clicks_30d, c.churn_risk_score, c.satisfaction_score, c.engagement_score, 
                 c.lifetime_value, c.account_status, c.marketing_consent, c.created_at, c.updated_at
    ),
    recommendations AS (
        SELECT 
            p.product_id,
            p.product_name,
            p.current_price,
            p.description,
            b.brand_name,
            p.avg_rating,
            p.review_count,
            p.product_images,
            
            -- Recommendation score calculation
            (
                -- Price match score (40% weight)
                CASE 
                    WHEN p.current_price BETWEEN cp.price_range_min AND cp.price_range_max THEN 40
                    WHEN p.current_price < cp.price_range_min THEN 20
                    ELSE 10
                END +
                
                -- Brand preference score (25% weight)
                CASE 
                    WHEN cp.preferred_brands LIKE '%' || b.brand_name || '%' THEN 25
                    WHEN cp.purchased_brands LIKE '%' || b.brand_name || '%' THEN 20
                    WHEN b.brand_tier = CASE WHEN cp.customer_tier = 'Platinum' THEN 'luxury' 
                                            WHEN cp.customer_tier = 'Gold' THEN 'premium' 
                                            ELSE 'mid-range' END THEN 15
                    ELSE 5
                END +
                
                -- Style preference score (20% weight)
                CASE 
                    WHEN cp.style_preferences LIKE '%luxury%' AND wc.category_name = 'Luxury Watches' THEN 20
                    WHEN cp.style_preferences LIKE '%sport%' AND wc.category_name = 'Sport Watches' THEN 20
                    WHEN cp.style_preferences LIKE '%casual%' AND wc.category_name = 'Casual Watches' THEN 20
                    WHEN cp.style_preferences LIKE '%smart%' AND wc.category_name = 'Smart Watches' THEN 20
                    ELSE 10
                END +
                
                -- Rating and popularity score (15% weight)
                ROUND(p.avg_rating * 3, 0)
                
            ) as recommendation_score,
            
            -- Context-specific boost
            CASE 
                WHEN context = 'luxury' AND b.brand_tier = 'luxury' THEN 20
                WHEN context = 'sport' AND wc.category_name = 'Sport Watches' THEN 20
                WHEN context = 'gift' AND p.featured = TRUE THEN 15
                WHEN context = 'budget' AND p.current_price < 500 THEN 20
                ELSE 0
            END as context_boost
            
        FROM products p
        JOIN watch_brands b ON p.brand_id = b.brand_id
        JOIN watch_categories wc ON p.category_id = wc.category_id
        CROSS JOIN customer_profile cp
        WHERE p.product_status = 'active'
        AND p.stock_quantity > 0
        -- Exclude already purchased products
        AND p.product_id NOT IN (
            SELECT DISTINCT oi.product_id 
            FROM orders o 
            JOIN order_items oi ON o.order_id = oi.order_id 
            WHERE o.customer_id = customer_id
        )
    )
    SELECT OBJECT_CONSTRUCT(
        'customer_id', customer_id,
        'recommendation_context', context,
        'customer_insights', (
            SELECT OBJECT_CONSTRUCT(
                'tier', customer_tier,
                'preferred_brands', preferred_brands,
                'style_preferences', style_preferences,
                'price_range', OBJECT_CONSTRUCT(
                    'min', price_range_min,
                    'max', price_range_max
                ),
                'avg_purchase_price', avg_purchase_price,
                'total_spent', total_spent
            )
            FROM customer_profile
        ),
        'top_recommendations', (
            SELECT ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'product_id', product_id,
                    'product_name', product_name,
                    'brand_name', brand_name,
                    'price', current_price,
                    'rating', avg_rating,
                    'review_count', review_count,
                    'recommendation_score', recommendation_score + context_boost,
                    'match_reasons', ARRAY_CONSTRUCT(
                        CASE WHEN current_price BETWEEN (SELECT price_range_min FROM customer_profile) 
                                                    AND (SELECT price_range_max FROM customer_profile) 
                             THEN 'Within preferred price range' END,
                        CASE WHEN (SELECT preferred_brands FROM customer_profile) LIKE '%' || brand_name || '%' 
                             THEN 'Preferred brand' END,
                        CASE WHEN avg_rating >= 4.5 THEN 'Highly rated' END,
                        CASE WHEN context = 'luxury' AND brand_name IN ('Rolex', 'Omega') 
                             THEN 'Premium luxury brand' END
                    ),
                    'description', description,
                    'images', product_images
                )
            )
            FROM (
                SELECT * FROM recommendations 
                ORDER BY (recommendation_score + context_boost) DESC 
                LIMIT 5
            )
        )
    )
$$;

-- ============================================================================
-- 5. CUSTOMER INSIGHTS SUMMARY FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION get_customer_360_insights(customer_id STRING)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    WITH customer_summary AS (
        SELECT 
            c.customer_id,
            c.first_name,
            c.last_name,
            c.email,
            c.customer_tier,
            c.lifetime_value,
            c.total_spent,
            c.total_orders,
            c.avg_order_value,
            c.price_range_min,
            c.price_range_max,
            c.last_purchase_date,
            c.last_login_date,
            c.churn_risk_score,
            c.engagement_score,
            c.satisfaction_score,
            c.website_visits_30d,
            c.email_opens_30d,
            c.email_clicks_30d,
            c.marketing_consent,
            c.preferred_brands,
            c.style_preferences,
            -- Recent activity
            (SELECT COUNT(*) FROM customer_events WHERE customer_id = c.customer_id 
             AND event_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())) as recent_activity_count,
            
            -- Order summary
            (SELECT COUNT(*) FROM orders WHERE customer_id = c.customer_id 
             AND order_date >= DATEADD('day', -90, CURRENT_TIMESTAMP())) as orders_90d,
            
            -- Support interactions
            (SELECT COUNT(*) FROM customer_interactions WHERE customer_id = c.customer_id 
             AND interaction_date >= DATEADD('day', -90, CURRENT_TIMESTAMP())) as support_interactions_90d,
            
            -- Average review sentiment
            (SELECT AVG(sentiment_score) FROM product_reviews WHERE customer_id = c.customer_id) as avg_review_sentiment
            
        FROM customers c
        WHERE c.customer_id = customer_id
    )
    SELECT OBJECT_CONSTRUCT(
        'customer_overview', OBJECT_CONSTRUCT(
            'customer_id', customer_id,
            'name', first_name || ' ' || last_name,
            'email', email,
            'tier', customer_tier,
            'lifetime_value', lifetime_value,
            'total_spent', total_spent,
            'churn_risk', OBJECT_CONSTRUCT(
                'score', churn_risk_score,
                'level', CASE 
                    WHEN churn_risk_score >= 0.7 THEN 'HIGH'
                    WHEN churn_risk_score >= 0.4 THEN 'MEDIUM'
                    ELSE 'LOW'
                END
            )
        ),
        
        'behavioral_insights', OBJECT_CONSTRUCT(
            'engagement_score', engagement_score,
            'satisfaction_score', satisfaction_score,
            'recent_activity_count', recent_activity_count,
            'website_visits_30d', website_visits_30d,
            'email_engagement', OBJECT_CONSTRUCT(
                'opens_30d', email_opens_30d,
                'clicks_30d', email_clicks_30d
            ),
            'last_interaction_days_ago', DATEDIFF('day', last_login_date, CURRENT_TIMESTAMP())
        ),
        
        'purchase_insights', OBJECT_CONSTRUCT(
            'total_orders', total_orders,
            'avg_order_value', avg_order_value,
            'orders_last_90d', orders_90d,
            'preferred_brands', preferred_brands,
            'style_preferences', style_preferences,
            'price_range', OBJECT_CONSTRUCT(
                'min', price_range_min,
                'max', price_range_max
            ),
            'days_since_last_purchase', DATEDIFF('day', last_purchase_date, CURRENT_TIMESTAMP())
        ),
        
        'service_insights', OBJECT_CONSTRUCT(
            'support_interactions_90d', support_interactions_90d,
            'avg_review_sentiment', COALESCE(avg_review_sentiment, 0),
            'marketing_consent', marketing_consent
        ),
        
        'ai_recommendations', OBJECT_CONSTRUCT(
            'next_best_actions', ARRAY_COMPACT(ARRAY_CONSTRUCT(
                CASE WHEN churn_risk_score > 0.6 THEN 'Priority retention outreach' END,
                CASE WHEN orders_90d = 0 AND DATEDIFF('day', last_purchase_date, CURRENT_TIMESTAMP()) > 60 
                     THEN 'Send personalized product recommendations' END,
                CASE WHEN satisfaction_score < 6.0 THEN 'Proactive customer service follow-up' END,
                CASE WHEN engagement_score > 0.8 AND lifetime_value > 5000 
                     THEN 'VIP program invitation' END,
                CASE WHEN recent_activity_count > 20 THEN 'High engagement - upsell opportunity' END
            )),
            'recommended_products_context', CASE
                WHEN preferred_brands LIKE '%Rolex%' OR preferred_brands LIKE '%Omega%' THEN 'luxury'
                WHEN style_preferences LIKE '%sport%' THEN 'sport'
                WHEN customer_tier = 'Bronze' THEN 'budget'
                ELSE 'general'
            END
        )
    )
    FROM customer_summary
$$;

SELECT '✅ AI Functions created successfully!' as ai_functions_status;

-- Test the functions with sample data
SELECT '🧪 Testing AI Functions...' as test_status;

-- Test churn prediction
SELECT '1. Testing Churn Prediction...' as test_name;
SELECT predict_customer_churn('CUST_007') as churn_prediction_high_risk;

-- Test sentiment analysis  
SELECT '2. Testing Sentiment Analysis...' as test_name;
SELECT analyze_review_sentiment('This watch is absolutely amazing! Great quality and perfect timing.') as sentiment_positive;

-- Test price optimization
SELECT '3. Testing Price Optimization...' as test_name;
SELECT optimize_product_pricing('ROLEX_SUB_001') as price_optimization;

-- Test personal recommendations
SELECT '4. Testing Personal Shopper...' as test_name;
SELECT get_personal_recommendations('CUST_001', 'luxury') as personal_recommendations;

-- Test customer insights
SELECT '5. Testing Customer 360 Insights...' as test_name;
SELECT get_customer_360_insights('CUST_001') as customer_insights;

SELECT '🎉 All AI Functions ready for the Personal Shopper experience!' as final_status; 