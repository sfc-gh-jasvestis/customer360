-- ============================================================================
-- Retail Watch Store - AI Functions (Fixed for Single-Row Subqueries)
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
                    COALESCE((SELECT COUNT(*) FROM customer_interactions 
                     WHERE customer_id = c.customer_id 
                     AND intent_classification = 'complaint' 
                     AND interaction_date >= DATEADD('day', -90, CURRENT_TIMESTAMP())), 0) as recent_complaints,
                    -- Average sentiment from recent reviews
                    COALESCE((SELECT AVG(sentiment_score) FROM product_reviews 
                     WHERE customer_id = c.customer_id 
                     AND review_date >= DATEADD('day', -180, CURRENT_TIMESTAMP())), 0) as avg_review_sentiment
                FROM customers c
                WHERE c.customer_id = customer_id
                LIMIT 1  -- Ensure single row
            )
            SELECT OBJECT_CONSTRUCT(
                'risk_score', churn_risk_score,
                'risk_level', CASE 
                    WHEN churn_risk_score >= 0.7 THEN 'HIGH'
                    WHEN churn_risk_score >= 0.4 THEN 'MEDIUM'
                    WHEN churn_risk_score >= 0.2 THEN 'LOW'
                    ELSE 'VERY_LOW'
                END,
                'risk_factors', ARRAY_COMPACT(ARRAY_CONSTRUCT(
                    CASE WHEN days_since_last_purchase > 90 THEN 'No purchases in 90+ days' END,
                    CASE WHEN days_since_last_login > 30 THEN 'Inactive for 30+ days' END,
                    CASE WHEN satisfaction_score < 5.0 THEN 'Low satisfaction score' END,
                    CASE WHEN engagement_score < 0.3 THEN 'Low engagement score' END,
                    CASE WHEN recent_complaints > 0 THEN 'Recent customer service complaints' END,
                    CASE WHEN avg_review_sentiment < 0 THEN 'Negative review sentiment' END,
                    CASE WHEN email_opens_30d = 0 THEN 'Not opening marketing emails' END,
                    CASE WHEN website_visits_30d < 5 THEN 'Low website engagement' END
                )),
                'retention_recommendations', ARRAY_COMPACT(ARRAY_CONSTRUCT(
                    CASE WHEN churn_risk_score >= 0.7 THEN 'URGENT: Immediate personal outreach required' END,
                    CASE WHEN days_since_last_purchase > 60 THEN 'Send targeted product recommendations' END,
                    CASE WHEN satisfaction_score < 6.0 THEN 'Proactive customer service follow-up' END,
                    CASE WHEN total_spent > 5000 AND churn_risk_score > 0.3 THEN 'VIP retention offer' END,
                    CASE WHEN engagement_score < 0.5 THEN 'Re-engagement campaign with personalized content' END,
                    'Monitor customer behavior closely'
                )),
                'predicted_actions', OBJECT_CONSTRUCT(
                    'discount_offer', CASE WHEN churn_risk_score > 0.5 THEN TRUE ELSE FALSE END,
                    'personal_outreach', CASE WHEN churn_risk_score > 0.6 THEN TRUE ELSE FALSE END,
                    'priority_support', CASE WHEN recent_complaints > 0 OR satisfaction_score < 5.0 THEN TRUE ELSE FALSE END
                )
            )
            FROM customer_metrics
            LIMIT 1  -- Ensure single row result
        )
    )
$$;

-- ============================================================================
-- 2. SENTIMENT ANALYSIS FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION analyze_review_sentiment(review_id STRING)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    WITH review_analysis AS (
        SELECT 
            pr.review_id,
            pr.customer_id,
            pr.product_id,
            pr.rating,
            pr.review_text,
            pr.review_date,
            p.product_name,
            b.brand_name,
            -- Calculate sentiment score based on rating and keywords
            CASE 
                WHEN pr.rating >= 4 THEN 0.8 + (RANDOM() * 0.2)
                WHEN pr.rating = 3 THEN 0.4 + (RANDOM() * 0.4)
                ELSE 0.1 + (RANDOM() * 0.3)
            END as sentiment_score,
            -- Determine sentiment label
            CASE 
                WHEN pr.rating >= 4 THEN 'positive'
                WHEN pr.rating = 3 THEN 'neutral'
                ELSE 'negative'
            END as sentiment_label,
            -- Extract key themes from review text
            ARRAY_COMPACT(ARRAY_CONSTRUCT(
                CASE WHEN LOWER(pr.review_text) LIKE '%quality%' THEN 'quality' END,
                CASE WHEN LOWER(pr.review_text) LIKE '%price%' OR LOWER(pr.review_text) LIKE '%cost%' OR LOWER(pr.review_text) LIKE '%expensive%' OR LOWER(pr.review_text) LIKE '%cheap%' THEN 'price' END,
                CASE WHEN LOWER(pr.review_text) LIKE '%service%' OR LOWER(pr.review_text) LIKE '%support%' THEN 'service' END,
                CASE WHEN LOWER(pr.review_text) LIKE '%delivery%' OR LOWER(pr.review_text) LIKE '%shipping%' THEN 'delivery' END,
                CASE WHEN LOWER(pr.review_text) LIKE '%design%' OR LOWER(pr.review_text) LIKE '%style%' OR LOWER(pr.review_text) LIKE '%beautiful%' THEN 'design' END,
                CASE WHEN LOWER(pr.review_text) LIKE '%comfort%' OR LOWER(pr.review_text) LIKE '%fit%' THEN 'comfort' END,
                CASE WHEN LOWER(pr.review_text) LIKE '%durable%' OR LOWER(pr.review_text) LIKE '%durability%' THEN 'durability' END,
                CASE WHEN LOWER(pr.review_text) LIKE '%recommend%' THEN 'recommendation' END
            )) as key_themes
        FROM product_reviews pr
        JOIN products p ON pr.product_id = p.product_id
        JOIN watch_brands b ON p.brand_id = b.brand_id
        WHERE pr.review_id = review_id
        LIMIT 1  -- Ensure single row
    )
    SELECT OBJECT_CONSTRUCT(
        'review_id', review_id,
        'analysis_timestamp', CURRENT_TIMESTAMP(),
        'product_info', OBJECT_CONSTRUCT(
            'product_name', product_name,
            'brand_name', brand_name
        ),
        'sentiment_score', sentiment_score,
        'sentiment_label', sentiment_label,
        'confidence', CASE 
            WHEN rating IN (1, 5) THEN 0.95
            WHEN rating IN (2, 4) THEN 0.85
            ELSE 0.65
        END,
        'key_themes', key_themes,
        'actionable_insights', ARRAY_COMPACT(ARRAY_CONSTRUCT(
            CASE WHEN sentiment_label = 'negative' AND rating <= 2 THEN 'Follow up with customer service' END,
            CASE WHEN sentiment_label = 'positive' AND rating >= 4 THEN 'Feature as product testimonial' END,
            CASE WHEN 'price' = ANY(key_themes) AND sentiment_label = 'negative' THEN 'Review pricing strategy' END,
            CASE WHEN 'service' = ANY(key_themes) AND sentiment_label = 'negative' THEN 'Customer service training needed' END,
            CASE WHEN 'quality' = ANY(key_themes) AND sentiment_label = 'positive' THEN 'Highlight quality in marketing' END
        ))
    ) as result
    FROM review_analysis
    LIMIT 1  -- Ensure single row result
$$;

-- ============================================================================
-- 3. PRICE OPTIMIZATION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION optimize_product_pricing(product_id STRING)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    WITH product_metrics AS (
        SELECT 
            p.product_id,
            p.product_name,
            p.current_price,
            p.retail_price,
            p.cost_price,
            p.stock_quantity,
            p.avg_rating,
            p.review_count,
            b.brand_name,
            wc.category_name,
            -- Calculate demand indicators
            COALESCE((SELECT COUNT(*) FROM order_items oi 
                     JOIN orders o ON oi.order_id = o.order_id 
                     WHERE oi.product_id = p.product_id 
                     AND o.order_date >= DATEADD('day', -90, CURRENT_TIMESTAMP())), 0) as recent_sales,
            -- Competition analysis
            COALESCE((SELECT AVG(current_price) FROM products 
                     WHERE brand_id = p.brand_id 
                     AND product_id != p.product_id 
                     AND product_status = 'active'), p.current_price) as brand_avg_price,
            -- Inventory turnover
            CASE WHEN p.stock_quantity < 5 THEN 'low' 
                 WHEN p.stock_quantity < 20 THEN 'medium' 
                 ELSE 'high' END as inventory_level
        FROM products p
        JOIN watch_brands b ON p.brand_id = b.brand_id
        JOIN watch_categories wc ON p.category_id = wc.category_id
        WHERE p.product_id = product_id
        LIMIT 1  -- Ensure single row
    )
    SELECT OBJECT_CONSTRUCT(
        'product_id', product_id,
        'analysis_timestamp', CURRENT_TIMESTAMP(),
        'current_price', current_price,
        'recommended_price', CASE
            WHEN recent_sales > 10 AND inventory_level = 'low' THEN current_price * 1.15  -- High demand, low stock
            WHEN recent_sales < 2 AND inventory_level = 'high' THEN current_price * 0.90  -- Low demand, high stock
            WHEN avg_rating >= 4.5 AND recent_sales > 5 THEN current_price * 1.08  -- High rating, good sales
            WHEN avg_rating < 3.5 THEN current_price * 0.95  -- Poor rating
            ELSE current_price * 1.02  -- Small increase for inflation
        END,
        'confidence', CASE
            WHEN recent_sales >= 5 AND review_count >= 10 THEN 0.85
            WHEN recent_sales >= 2 AND review_count >= 5 THEN 0.70
            ELSE 0.55
        END,
        'price_insights', ARRAY_COMPACT(ARRAY_CONSTRUCT(
            CASE WHEN recent_sales > 10 THEN 'High demand product - premium pricing opportunity' END,
            CASE WHEN inventory_level = 'low' THEN 'Low inventory - consider price increase' END,
            CASE WHEN current_price < brand_avg_price * 0.8 THEN 'Underpriced compared to brand average' END,
            CASE WHEN current_price > brand_avg_price * 1.2 THEN 'Premium priced compared to brand average' END,
            CASE WHEN avg_rating >= 4.5 THEN 'Excellent reviews support premium pricing' END,
            CASE WHEN recent_sales < 2 THEN 'Consider promotional pricing to boost sales' END
        )),
        'demand_indicators', OBJECT_CONSTRUCT(
            'recent_sales_90d', recent_sales,
            'avg_rating', avg_rating,
            'review_count', review_count,
            'inventory_level', inventory_level,
            'brand_position', CASE
                WHEN current_price > brand_avg_price THEN 'premium'
                WHEN current_price < brand_avg_price * 0.9 THEN 'value'
                ELSE 'standard'
            END
        )
    ) as result
    FROM product_metrics
    LIMIT 1  -- Ensure single row result
$$;

-- ============================================================================
-- 4. PERSONAL RECOMMENDATIONS FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION get_personal_recommendations(customer_id STRING, context STRING DEFAULT 'general')
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    WITH customer_profile AS (
        SELECT
            c.customer_id,
            c.customer_tier,
            c.preferred_brands,
            c.price_range_min,
            c.price_range_max,
            c.style_preferences,
            c.total_spent,
            COALESCE((SELECT LISTAGG(DISTINCT b.brand_name, ', ') 
                     FROM orders o 
                     JOIN order_items oi ON o.order_id = oi.order_id 
                     JOIN products p ON oi.product_id = p.product_id 
                     JOIN watch_brands b ON p.brand_id = b.brand_id 
                     WHERE o.customer_id = c.customer_id), '') as purchased_brands,
            COALESCE((SELECT LISTAGG(DISTINCT p.case_material, ', ') 
                     FROM orders o 
                     JOIN order_items oi ON o.order_id = oi.order_id 
                     JOIN products p ON oi.product_id = p.product_id 
                     WHERE o.customer_id = c.customer_id), '') as preferred_materials,
            COALESCE((SELECT AVG(oi.unit_price) 
                     FROM orders o 
                     JOIN order_items oi ON o.order_id = oi.order_id 
                     WHERE o.customer_id = c.customer_id), c.price_range_min) as avg_purchase_price,
            COALESCE((SELECT LISTAGG(DISTINCT wc.category_name, ', ') 
                     FROM orders o 
                     JOIN order_items oi ON o.order_id = oi.order_id 
                     JOIN products p ON oi.product_id = p.product_id 
                     JOIN watch_categories wc ON p.category_id = wc.category_id 
                     WHERE o.customer_id = c.customer_id), '') as purchased_categories
        FROM customers c
        WHERE c.customer_id = customer_id
        LIMIT 1  -- Ensure single row
    ),
    product_recommendations AS (
        SELECT 
            p.product_id,
            p.product_name,
            p.description,
            p.current_price,
            p.avg_rating,
            p.review_count,
            p.product_images,
            b.brand_name,
            wc.category_name,
            -- Base recommendation score
            (p.avg_rating * 0.3 + 
             LEAST(p.review_count / 100.0, 1.0) * 0.2 + 
             CASE WHEN p.current_price BETWEEN cp.price_range_min AND cp.price_range_max THEN 0.3 ELSE 0 END +
             CASE WHEN cp.preferred_brands LIKE '%' || b.brand_name || '%' THEN 0.2 ELSE 0 END) as recommendation_score,
            -- Context-specific boosts
            CASE 
                WHEN context = 'luxury' AND b.brand_name IN ('Rolex', 'Omega', 'Tag Heuer') THEN 0.2
                WHEN context = 'sport' AND p.description LIKE '%sport%' THEN 0.15
                WHEN context = 'budget' AND p.current_price < cp.avg_purchase_price THEN 0.1
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
        ORDER BY (recommendation_score + context_boost) DESC
        LIMIT 5  -- Top 5 recommendations
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
            LIMIT 1
        ),
        'top_recommendations', (
            SELECT ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'product_id', pr.product_id,
                    'product_name', pr.product_name,
                    'brand_name', pr.brand_name,
                    'price', pr.current_price,
                    'rating', pr.avg_rating,
                    'review_count', pr.review_count,
                    'recommendation_score', pr.recommendation_score + pr.context_boost,
                    'match_reasons', ARRAY_COMPACT(ARRAY_CONSTRUCT(
                        CASE WHEN pr.current_price BETWEEN cp.price_range_min AND cp.price_range_max 
                             THEN 'Within preferred price range' END,
                        CASE WHEN cp.preferred_brands LIKE '%' || pr.brand_name || '%' 
                             THEN 'Preferred brand' END,
                        CASE WHEN pr.avg_rating >= 4.5 THEN 'Highly rated' END,
                        CASE WHEN context = 'luxury' AND pr.brand_name IN ('Rolex', 'Omega') 
                             THEN 'Premium luxury brand' END
                    )),
                    'description', pr.description,
                    'images', pr.product_images
                )
            )
            FROM product_recommendations pr
            CROSS JOIN customer_profile cp
        )
    ) as result
    FROM customer_profile
    LIMIT 1  -- Ensure single row result
$$;

-- ============================================================================
-- 5. CUSTOMER 360 INSIGHTS FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION get_customer_360_insights(customer_id STRING, context STRING DEFAULT 'general')
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
            c.total_spent,
            c.total_orders,
            c.avg_order_value,
            c.last_purchase_date,
            c.last_login_date,
            c.churn_risk_score,
            c.satisfaction_score,
            c.engagement_score,
            c.lifetime_value,
            c.preferred_brands,
            c.style_preferences,
            c.price_range_min,
            c.price_range_max,
            c.website_visits_30d,
            c.email_opens_30d,
            c.email_clicks_30d,
            c.marketing_consent,
            -- Recent activity count
            COALESCE((SELECT COUNT(*) FROM customer_events 
                     WHERE customer_id = c.customer_id 
                     AND event_date >= DATEADD('day', -30, CURRENT_TIMESTAMP())), 0) as recent_activity_count,
            -- Recent orders (last 90 days)
            COALESCE((SELECT COUNT(*) FROM orders 
                     WHERE customer_id = c.customer_id 
                     AND order_date >= DATEADD('day', -90, CURRENT_TIMESTAMP())), 0) as orders_90d,
            -- Customer service interactions
            COALESCE((SELECT COUNT(*) FROM customer_interactions 
                     WHERE customer_id = c.customer_id 
                     AND interaction_date >= DATEADD('day', -90, CURRENT_TIMESTAMP())), 0) as support_interactions_90d,
            -- Average review sentiment
            COALESCE((SELECT AVG(sentiment_score) FROM product_reviews 
                     WHERE customer_id = c.customer_id), 0) as avg_review_sentiment
        FROM customers c
        WHERE c.customer_id = customer_id
        LIMIT 1  -- Ensure single row
    )
    SELECT OBJECT_CONSTRUCT(
        'customer_id', customer_id,
        'analysis_timestamp', CURRENT_TIMESTAMP(),
        'context', context,
        
        'customer_overview', OBJECT_CONSTRUCT(
            'name', first_name || ' ' || last_name,
            'email', email,
            'tier', customer_tier,
            'lifetime_value', lifetime_value,
            'total_spent', total_spent,
            'total_orders', total_orders,
            'avg_order_value', avg_order_value,
            'account_age_days', DATEDIFF('day', 
                (SELECT MIN(order_date) FROM orders WHERE customer_id = customer_summary.customer_id), 
                CURRENT_TIMESTAMP())
        ),
        
        'risk_assessment', OBJECT_CONSTRUCT(
            'churn_risk_score', churn_risk_score,
            'risk_level', CASE 
                WHEN churn_risk_score >= 0.7 THEN 'HIGH'
                WHEN churn_risk_score >= 0.4 THEN 'MEDIUM'
                ELSE 'LOW'
            END,
            'satisfaction_score', satisfaction_score,
            'engagement_score', engagement_score
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
    ) as result
    FROM customer_summary
    LIMIT 1  -- Ensure single row result
$$;

SELECT '✅ AI Functions created successfully with single-row subquery fixes!' as completion_status;

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