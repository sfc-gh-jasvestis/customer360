-- ============================================================================
-- SIMPLE DIVERSE RECOMMENDATIONS FUNCTION
-- ============================================================================

USE DATABASE retail_watch_db;
USE SCHEMA public;
USE WAREHOUSE retail_watch_wh;

-- Drop existing functions
DROP FUNCTION IF EXISTS get_personal_recommendations(STRING, STRING);
DROP FUNCTION IF EXISTS get_personal_recommendations(STRING);

-- Create simpler function with better diversity
CREATE OR REPLACE FUNCTION get_personal_recommendations(customer_id STRING, context STRING DEFAULT 'general')
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'customer_id', customer_id,
        'recommendation_context', context,
        'customer_insights', OBJECT_CONSTRUCT(
            'tier', c.customer_tier,
            'preferred_brands', c.preferred_brands,
            'style_preferences', c.style_preferences,
            'price_range', OBJECT_CONSTRUCT(
                'min', c.price_range_min,
                'max', c.price_range_max
            ),
            'total_spent', c.total_spent
        ),
        'top_recommendations', ARRAY_CONSTRUCT(
            -- Product 1: Highest rated in price range
            (SELECT OBJECT_CONSTRUCT(
                'product_id', p.product_id,
                'product_name', p.product_name,
                'brand_name', b.brand_name,
                'price', p.current_price,
                'rating', p.avg_rating,
                'review_count', p.review_count,
                'recommendation_score', 95,
                'match_reasons', ARRAY_CONSTRUCT('Top rated in your price range', 'Highly recommended'),
                'description', p.description,
                'images', p.product_images
            )
            FROM products p 
            JOIN watch_brands b ON p.brand_id = b.brand_id
            WHERE p.product_status = 'active' 
            AND p.stock_quantity > 0
            AND p.current_price BETWEEN c.price_range_min AND c.price_range_max
            ORDER BY p.avg_rating DESC, p.review_count DESC
            LIMIT 1),
            
            -- Product 2: Popular luxury watch
            (SELECT OBJECT_CONSTRUCT(
                'product_id', p.product_id,
                'product_name', p.product_name,
                'brand_name', b.brand_name,
                'price', p.current_price,
                'rating', p.avg_rating,
                'review_count', p.review_count,
                'recommendation_score', 90,
                'match_reasons', ARRAY_CONSTRUCT('Premium luxury brand', 'Excellent craftsmanship'),
                'description', p.description,
                'images', p.product_images
            )
            FROM products p 
            JOIN watch_brands b ON p.brand_id = b.brand_id
            WHERE p.product_status = 'active' 
            AND p.stock_quantity > 0
            AND b.brand_tier = 'luxury'
            AND p.product_id != COALESCE(
                (SELECT p2.product_id FROM products p2 
                 JOIN watch_brands b2 ON p2.brand_id = b2.brand_id
                 WHERE p2.product_status = 'active' AND p2.stock_quantity > 0
                 AND p2.current_price BETWEEN c.price_range_min AND c.price_range_max
                 ORDER BY p2.avg_rating DESC LIMIT 1), ''
            )
            ORDER BY p.avg_rating DESC
            LIMIT 1),
            
            -- Product 3: Best sport/casual watch
            (SELECT OBJECT_CONSTRUCT(
                'product_id', p.product_id,
                'product_name', p.product_name,
                'brand_name', b.brand_name,
                'price', p.current_price,
                'rating', p.avg_rating,
                'review_count', p.review_count,
                'recommendation_score', 85,
                'match_reasons', ARRAY_CONSTRUCT('Great for active lifestyle', 'Durable and reliable'),
                'description', p.description,
                'images', p.product_images
            )
            FROM products p 
            JOIN watch_brands b ON p.brand_id = b.brand_id
            JOIN watch_categories wc ON p.category_id = wc.category_id
            WHERE p.product_status = 'active' 
            AND p.stock_quantity > 0
            AND (wc.category_name IN ('Sport Watches', 'Casual Watches') OR b.brand_name IN ('SEIKO', 'CITIZEN', 'CASIO'))
            ORDER BY p.avg_rating DESC
            LIMIT 1),
            
            -- Product 4: Smartwatch option
            (SELECT OBJECT_CONSTRUCT(
                'product_id', p.product_id,
                'product_name', p.product_name,
                'brand_name', b.brand_name,
                'price', p.current_price,
                'rating', p.avg_rating,
                'review_count', p.review_count,
                'recommendation_score', 80,
                'match_reasons', ARRAY_CONSTRUCT('Modern smart features', 'Connected lifestyle'),
                'description', p.description,
                'images', p.product_images
            )
            FROM products p 
            JOIN watch_brands b ON p.brand_id = b.brand_id
            JOIN watch_categories wc ON p.category_id = wc.category_id
            WHERE p.product_status = 'active' 
            AND p.stock_quantity > 0
            AND (wc.category_name = 'Smart Watches' OR b.brand_name = 'APPLE')
            ORDER BY p.avg_rating DESC
            LIMIT 1),
            
            -- Product 5: Best value option
            (SELECT OBJECT_CONSTRUCT(
                'product_id', p.product_id,
                'product_name', p.product_name,
                'brand_name', b.brand_name,
                'price', p.current_price,
                'rating', p.avg_rating,
                'review_count', p.review_count,
                'recommendation_score', 75,
                'match_reasons', ARRAY_CONSTRUCT('Excellent value for money', 'Popular choice'),
                'description', p.description,
                'images', p.product_images
            )
            FROM products p 
            JOIN watch_brands b ON p.brand_id = b.brand_id
            WHERE p.product_status = 'active' 
            AND p.stock_quantity > 0
            AND p.current_price < (c.price_range_max * 0.8)  -- Under 80% of max budget
            ORDER BY (p.avg_rating * p.review_count) DESC  -- Popular and well-rated
            LIMIT 1)
        )
    ) as result
    FROM customers c
    WHERE c.customer_id = customer_id
    LIMIT 1
$$;

-- Test the function
SELECT '🎯 Testing simple diverse recommendations...' as test_status;
SELECT get_personal_recommendations('CUST_001', 'general') as test_result;

SELECT '✅ Simple recommendations function created!' as status; 