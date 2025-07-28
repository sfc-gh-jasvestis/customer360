-- ============================================================================
-- Retail Watch Store - Database Setup Verification
-- ============================================================================
-- Run this script to verify your database setup is complete
-- NOTE: For Streamlit in Snowflake, USE statements are not supported
-- Use fully qualified table names instead

SELECT '🔍 Verifying Retail Watch Store Setup...' as verification_step;

-- Check if all tables exist and have data
SELECT '📊 Checking Tables...' as check_step;

SELECT 
    'watch_brands' as table_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN '✅ OK' ELSE '❌ EMPTY' END as status
FROM RETAIL_WATCH_DB.PUBLIC.watch_brands
UNION ALL
SELECT 
    'watch_categories' as table_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN '✅ OK' ELSE '❌ EMPTY' END as status
FROM RETAIL_WATCH_DB.PUBLIC.watch_categories
UNION ALL
SELECT 
    'products' as table_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN '✅ OK' ELSE '❌ EMPTY' END as status
FROM RETAIL_WATCH_DB.PUBLIC.products
UNION ALL
SELECT 
    'customers' as table_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN '✅ OK' ELSE '❌ EMPTY' END as status
FROM RETAIL_WATCH_DB.PUBLIC.customers
UNION ALL
SELECT 
    'orders' as table_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN '✅ OK' ELSE '❌ EMPTY' END as status
FROM RETAIL_WATCH_DB.PUBLIC.orders
UNION ALL
SELECT 
    'product_reviews' as table_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN '✅ OK' ELSE '❌ EMPTY' END as status
FROM RETAIL_WATCH_DB.PUBLIC.product_reviews
UNION ALL
SELECT 
    'customer_interactions' as table_name,
    COUNT(*) as record_count,
    CASE WHEN COUNT(*) > 0 THEN '✅ OK' ELSE '❌ EMPTY' END as status
FROM RETAIL_WATCH_DB.PUBLIC.customer_interactions
ORDER BY table_name;

-- Check if AI functions exist
SELECT '🤖 Checking AI Functions...' as check_step;

SELECT 
    function_name,
    'AI Function' as type,
    CASE WHEN function_name IS NOT NULL THEN '✅ EXISTS' ELSE '❌ MISSING' END as status
FROM RETAIL_WATCH_DB.information_schema.functions 
WHERE function_schema = 'PUBLIC'
AND function_name IN (
    'PREDICT_CUSTOMER_CHURN',
    'ANALYZE_REVIEW_SENTIMENT', 
    'OPTIMIZE_PRODUCT_PRICING',
    'GET_PERSONAL_RECOMMENDATIONS',
    'GET_CUSTOMER_360_INSIGHTS'
)
ORDER BY function_name;

-- Test a simple query
SELECT '🧪 Testing Sample Query...' as test_step;

SELECT 
    COUNT(*) as total_customers,
    COUNT(CASE WHEN customer_tier = 'Platinum' THEN 1 END) as platinum_customers,
    COUNT(CASE WHEN customer_tier = 'Gold' THEN 1 END) as gold_customers,
    COUNT(CASE WHEN customer_tier = 'Silver' THEN 1 END) as silver_customers,
    COUNT(CASE WHEN customer_tier = 'Bronze' THEN 1 END) as bronze_customers
FROM RETAIL_WATCH_DB.PUBLIC.customers;

-- Test AI function
SELECT '🤖 Testing AI Function...' as ai_test_step;

SELECT RETAIL_WATCH_DB.PUBLIC.predict_customer_churn('CUST_001') as churn_prediction_test;

SELECT '🎉 Setup Verification Complete!' as final_status;
SELECT 'If all checks show ✅ OK/EXISTS, your setup is ready for Streamlit!' as next_steps; 