-- ============================================================================
-- FIX PERSONAL RECOMMENDATIONS TO ENSURE DIVERSITY
-- ============================================================================

USE DATABASE retail_watch_db;
USE SCHEMA public;
USE WAREHOUSE retail_watch_wh;

-- Drop and recreate the function with better diversity logic
DROP FUNCTION IF EXISTS get_personal_recommendations(STRING, STRING);
DROP FUNCTION IF EXISTS get_personal_recommendations(STRING);

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
            c.total_spent
        FROM customers c
        WHERE c.customer_id = customer_id
        LIMIT 1
    ),
    diverse_products AS (
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
            -- Enhanced scoring with diversity factors
            CASE 
                WHEN p.current_price BETWEEN cp.price_range_min AND cp.price_range_max THEN p.avg_rating * 1.2
                ELSE p.avg_rating 
            END + 
            -- Add brand diversity bonus (different brands get slight bonus)
            (ROW_NUMBER() OVER (PARTITION BY b.brand_name ORDER BY p.avg_rating DESC) * -0.1) +
            -- Add category diversity bonus
            (ROW_NUMBER() OVER (PARTITION BY wc.category_name ORDER BY p.avg_rating DESC) * -0.05) +
            -- Add small random factor for variety
            (RANDOM() * 0.1) as score,
            -- Track brand and category for diversity
            b.brand_name as brand_for_diversity,
            wc.category_name as category_for_diversity
        FROM products p
        JOIN watch_brands b ON p.brand_id = b.brand_id
        JOIN watch_categories wc ON p.category_id = wc.category_id
        CROSS JOIN customer_profile cp
        WHERE p.product_status = 'active'
        AND p.stock_quantity > 0
        -- Ensure we get different products by adding distinct
        ORDER BY score DESC, p.product_id
        LIMIT 10  -- Get more options first
    ),
    top_diverse_products AS (
        SELECT DISTINCT
            product_id,
            product_name,
            description,
            current_price,
            avg_rating,
            review_count,
            product_images,
            brand_name,
            category_name,
            score
        FROM diverse_products
        ORDER BY score DESC
        LIMIT 5  -- Final selection of 5 diverse products
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
                'total_spent', total_spent
            )
            FROM customer_profile
            LIMIT 1
        ),
        'top_recommendations', (
            SELECT ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'product_id', tdp.product_id,
                    'product_name', tdp.product_name,
                    'brand_name', tdp.brand_name,
                    'price', tdp.current_price,
                    'rating', tdp.avg_rating,
                    'review_count', tdp.review_count,
                    'recommendation_score', ROUND(tdp.score * 20, 0), -- Scale to 0-100
                    'match_reasons', ARRAY_CONSTRUCT(
                        CASE WHEN tdp.current_price BETWEEN cp.price_range_min AND cp.price_range_max 
                             THEN 'Within preferred price range' ELSE 'Good value option' END,
                        CASE WHEN tdp.avg_rating >= 4.5 THEN 'Highly rated' 
                             WHEN tdp.avg_rating >= 4.0 THEN 'Well reviewed'
                             ELSE 'Popular choice' END,
                        'Curated for diversity'
                    ),
                    'description', tdp.description,
                    'images', tdp.product_images
                )
                ORDER BY tdp.score DESC
            )
            FROM top_diverse_products tdp
            CROSS JOIN customer_profile cp
        )
    ) as result
    FROM customer_profile
    LIMIT 1
$$;

-- Test the function
SELECT '🎯 Testing improved recommendations...' as test_status;
SELECT get_personal_recommendations('CUST_001', 'general') as test_result;

-- Show product names to verify diversity
SELECT 
    JSON_EXTRACT_PATH_TEXT(rec.value, 'product_name') as product_name,
    JSON_EXTRACT_PATH_TEXT(rec.value, 'brand_name') as brand_name,
    JSON_EXTRACT_PATH_TEXT(rec.value, 'recommendation_score') as score
FROM 
    (SELECT get_personal_recommendations('CUST_001', 'general') as recommendations) r,
    LATERAL FLATTEN(input => JSON_EXTRACT_PATH_TEXT(r.recommendations, 'top_recommendations'), outer => true) rec;

SELECT '✅ Recommendations function updated for diversity!' as status; 