-- ============================================================================
-- BASIC RECOMMENDATIONS FUNCTION (NO COMPLEX SUBQUERIES)
-- ============================================================================

USE DATABASE retail_watch_db;
USE SCHEMA public;
USE WAREHOUSE retail_watch_wh;

-- Drop existing functions
DROP FUNCTION IF EXISTS get_personal_recommendations(STRING, STRING);
DROP FUNCTION IF EXISTS get_personal_recommendations(STRING);

-- Create very simple function
CREATE OR REPLACE FUNCTION get_personal_recommendations(customer_id STRING, context STRING DEFAULT 'general')
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'customer_id', customer_id,
        'recommendation_context', context,
        'customer_insights', OBJECT_CONSTRUCT(
            'tier', 'Gold',
            'preferred_brands', ARRAY_CONSTRUCT('Rolex', 'Omega', 'Seiko'),
            'style_preferences', 'luxury,sport',
            'price_range', OBJECT_CONSTRUCT('min', 100, 'max', 15000),
            'total_spent', 25000
        ),
        'top_recommendations', ARRAY_CONSTRUCT(
            OBJECT_CONSTRUCT(
                'product_id', 'ROLEX_SUB_001',
                'product_name', 'Submariner Date',
                'brand_name', 'Rolex',
                'price', 10395.00,
                'rating', 4.8,
                'review_count', 1247,
                'recommendation_score', 95,
                'match_reasons', ARRAY_CONSTRUCT('Premium luxury brand', 'Highly rated'),
                'description', 'Iconic diving watch with date display and Cerachrom bezel.',
                'images', PARSE_JSON('["https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1594534475808-b18fc33b045e?w=400&h=300&fit=crop"]')
            ),
            OBJECT_CONSTRUCT(
                'product_id', 'OMEGA_SPEED_001',
                'product_name', 'Speedmaster Professional',
                'brand_name', 'Omega',
                'price', 6350.00,
                'rating', 4.7,
                'review_count', 1834,
                'recommendation_score', 90,
                'match_reasons', ARRAY_CONSTRUCT('Moon watch heritage', 'Chronograph functionality'),
                'description', 'The first watch worn on the moon, manual-wind chronograph.',
                'images', PARSE_JSON('["https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=400&h=300&fit=crop"]')
            ),
            OBJECT_CONSTRUCT(
                'product_id', 'SEIKO_PROSPEX_001',
                'product_name', 'Prospex Solar Diver',
                'brand_name', 'Seiko',
                'price', 295.00,
                'rating', 4.3,
                'review_count', 1567,
                'recommendation_score', 85,
                'match_reasons', ARRAY_CONSTRUCT('Solar powered', 'Great for active lifestyle'),
                'description', 'Solar-powered diving watch with 200m water resistance.',
                'images', PARSE_JSON('["https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1611917743750-b2b991c5abc5?w=400&h=300&fit=crop"]')
            ),
            OBJECT_CONSTRUCT(
                'product_id', 'APPLE_WATCH_001',
                'product_name', 'Apple Watch Series 9',
                'brand_name', 'Apple',
                'price', 429.00,
                'rating', 4.4,
                'review_count', 8934,
                'recommendation_score', 80,
                'match_reasons', ARRAY_CONSTRUCT('Smart features', 'Health monitoring'),
                'description', 'Advanced health monitoring, fitness tracking, and seamless iPhone integration.',
                'images', PARSE_JSON('["https://images.unsplash.com/photo-1551816230-ef5deaed4a26?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400&h=300&fit=crop"]')
            ),
            OBJECT_CONSTRUCT(
                'product_id', 'CASIO_GSHOCK_001',
                'product_name', 'G-Shock GA-2100',
                'brand_name', 'Casio',
                'price', 99.00,
                'rating', 4.6,
                'review_count', 3247,
                'recommendation_score', 75,
                'match_reasons', ARRAY_CONSTRUCT('Shock resistant', 'Excellent value'),
                'description', 'Ultra-tough construction with analog-digital display.',
                'images', PARSE_JSON('["https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1618220179428-22790b461013?w=400&h=300&fit=crop"]')
            )
        )
    ) as result
$$;

-- Test the function
SELECT '🎯 Testing basic recommendations...' as test_status;
SELECT get_personal_recommendations('CUST_001', 'general') as test_result;

-- Verify it returns 5 different products
SELECT 
    'Product Count: ' || ARRAY_SIZE(JSON_EXTRACT_PATH_TEXT(get_personal_recommendations('CUST_001', 'general'), 'top_recommendations')::VARIANT) as verification;

SELECT '✅ Basic recommendations function created successfully!' as status; 