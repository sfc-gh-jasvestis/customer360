-- ============================================================================
-- Retail Watch Store - AI Functions Test Script
-- ============================================================================
-- Test all AI functions to verify they return the expected data structure

USE DATABASE retail_watch_db;
USE SCHEMA public;
USE WAREHOUSE retail_watch_wh;

SELECT '🧪 Testing AI Functions Data Structure...' as test_step;

-- ============================================================================
-- Test 1: Customer 360 Insights Function
-- ============================================================================

SELECT '📊 Testing get_customer_360_insights...' as test_1;

SELECT get_customer_360_insights('CUST_001', 'general') as insights_test;

-- Show the structure keys
SELECT 
    'customer_360_insights structure:' as description,
    OBJECT_KEYS(get_customer_360_insights('CUST_001', 'general')) as top_level_keys;

-- ============================================================================
-- Test 2: Personal Recommendations Function  
-- ============================================================================

SELECT '🎯 Testing get_personal_recommendations...' as test_2;

SELECT get_personal_recommendations('CUST_001', 'general') as recommendations_test;

-- Show the structure keys
SELECT 
    'personal_recommendations structure:' as description,
    OBJECT_KEYS(get_personal_recommendations('CUST_001', 'general')) as top_level_keys;

-- ============================================================================
-- Test 3: Churn Prediction Function
-- ============================================================================

SELECT '⚠️ Testing predict_customer_churn...' as test_3;

SELECT predict_customer_churn('CUST_001') as churn_test;

-- Show the structure keys
SELECT 
    'churn_prediction structure:' as description,
    OBJECT_KEYS(predict_customer_churn('CUST_001')) as top_level_keys;

-- ============================================================================
-- Test 4: Sentiment Analysis Function
-- ============================================================================

SELECT '😊 Testing analyze_review_sentiment...' as test_4;

SELECT analyze_review_sentiment('REV_001') as sentiment_test;

-- Show the structure keys
SELECT 
    'sentiment_analysis structure:' as description,
    OBJECT_KEYS(analyze_review_sentiment('REV_001')) as top_level_keys;

-- ============================================================================
-- Test 5: Price Optimization Function
-- ============================================================================

SELECT '💰 Testing optimize_product_pricing...' as test_5;

SELECT optimize_product_pricing('ROLEX_SUB_001') as pricing_test;

-- Show the structure keys
SELECT 
    'price_optimization structure:' as description,
    OBJECT_KEYS(optimize_product_pricing('ROLEX_SUB_001')) as top_level_keys;

-- ============================================================================
-- Summary of Expected Data Structures
-- ============================================================================

SELECT '📋 Expected Data Structure Summary:' as summary;

SELECT 
    'get_customer_360_insights()' as function_name,
    'customer_id, analysis_timestamp, context, customer_overview, risk_assessment, behavioral_insights, purchase_insights, service_insights, ai_recommendations' as expected_keys
UNION ALL
SELECT 
    'get_personal_recommendations()',
    'customer_id, recommendation_context, customer_insights, top_recommendations'
UNION ALL
SELECT 
    'predict_customer_churn()',
    'customer_id, prediction_timestamp, churn_analysis'
UNION ALL
SELECT 
    'analyze_review_sentiment()',
    'review_id, analysis_timestamp, product_info, sentiment_score, sentiment_label, confidence, key_themes, actionable_insights'
UNION ALL
SELECT 
    'optimize_product_pricing()',
    'product_id, analysis_timestamp, current_price, recommended_price, confidence, price_insights, demand_indicators';

SELECT '✅ AI Functions Test Complete!' as test_status;
SELECT 'Use this to verify the data structure matches your Streamlit app expectations.' as usage_note; 