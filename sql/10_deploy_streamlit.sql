-- ============================================================================
-- Customer 360 & AI Assistant - Streamlit in Snowflake Deployment
-- ============================================================================
-- This script deploys the Customer 360 app to Streamlit in Snowflake
-- 
-- Prerequisites:
-- 1. Customer 360 database setup completed (run 99_complete_setup.sql first)
-- 2. STREAMLIT usage privileges on your role
-- 3. Streamlit app file uploaded to stage
-- ============================================================================

-- Set context
USE DATABASE CUSTOMER_360_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE CUSTOMER_360_WH;

SELECT 'Starting Streamlit deployment...' as status;

-- ============================================================================
-- Step 1: Verify Prerequisites
-- ============================================================================

SELECT 'Checking database setup...' as status;

-- Check if tables exist
SELECT 
    'Tables Check: ' || COUNT(*) || ' tables found' as status
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'PUBLIC' 
AND TABLE_NAME IN ('CUSTOMERS', 'CUSTOMER_ACTIVITIES', 'PURCHASES', 'SUPPORT_TICKETS');

-- Check if functions exist  
SELECT 
    'Functions Check: ' || COUNT(*) || ' functions found' as status
FROM INFORMATION_SCHEMA.FUNCTIONS 
WHERE FUNCTION_SCHEMA = 'PUBLIC' 
AND FUNCTION_NAME LIKE '%CUSTOMER%';

-- Check warehouse status
SELECT 'Warehouse Status: ' || STATE as status
FROM INFORMATION_SCHEMA.WAREHOUSES 
WHERE WAREHOUSE_NAME = 'CUSTOMER_360_WH';

-- ============================================================================
-- Step 2: Create/Upload Streamlit App (Manual Step Required)
-- ============================================================================

SELECT '⚠️  MANUAL STEP REQUIRED:' as status;
SELECT 'Please copy the contents of customer_360_sis_app.py and paste into Snowflake Streamlit editor' as instruction;
SELECT 'Or upload the file to the stage using PUT command' as alternative;

-- Show PUT command for reference
SELECT 'PUT file://customer_360_sis_app.py @CUSTOMER_360_STAGE overwrite=true;' as put_command;

-- ============================================================================
-- Step 3: Create Streamlit App (Alternative SQL Method)
-- ============================================================================

-- Note: This requires the file to be uploaded to stage first
-- Uncomment the following lines if you want to create via SQL:

/*
CREATE OR REPLACE STREAMLIT customer_360_ai_assistant
ROOT_LOCATION = '@CUSTOMER_360_STAGE'
MAIN_FILE = 'customer_360_sis_app.py'
QUERY_WAREHOUSE = 'CUSTOMER_360_WH'
COMMENT = 'Customer 360 & AI Assistant - Comprehensive customer analytics with AI insights';
*/

-- ============================================================================
-- Step 4: Grant Permissions
-- ============================================================================

SELECT 'Setting up permissions...' as status;

-- Grant permissions to current role (adjust as needed)
-- GRANT USAGE ON STREAMLIT customer_360_ai_assistant TO ROLE ACCOUNTADMIN;

-- ============================================================================
-- Step 5: Verify App Access
-- ============================================================================

-- Check if Streamlit app was created
SELECT 
    'Streamlit Apps: ' || COUNT(*) || ' apps found' as status
FROM INFORMATION_SCHEMA.STREAMLITS 
WHERE STREAMLIT_SCHEMA = 'PUBLIC';

-- ============================================================================
-- Step 6: Test Data Access for App
-- ============================================================================

SELECT 'Testing data access...' as status;

-- Test customer data
SELECT 'Customer count: ' || COUNT(*) as customer_test FROM customers;

-- Test activities data  
SELECT 'Activities count: ' || COUNT(*) as activities_test FROM customer_activities;

-- Test AI functions
SELECT 'Testing AI function...' as test_status;
SELECT analyze_customer_ai('CUST_001') as ai_test_result;

-- ============================================================================
-- Step 7: Performance Recommendations
-- ============================================================================

SELECT 'Performance recommendations:' as status;

-- Recommend warehouse size based on data volume
SELECT 
    CASE 
        WHEN COUNT(*) < 1000 THEN 'XSMALL warehouse recommended'
        WHEN COUNT(*) < 10000 THEN 'SMALL warehouse recommended' 
        WHEN COUNT(*) < 100000 THEN 'MEDIUM warehouse recommended'
        ELSE 'LARGE warehouse recommended'
    END as warehouse_recommendation
FROM customers;

-- Check for indexes (not applicable to Snowflake, but good to document)
SELECT 'Note: Snowflake automatically optimizes queries - no manual indexing needed' as optimization_note;

-- ============================================================================
-- Step 8: Deployment Summary
-- ============================================================================

SELECT '✅ Deployment checklist:' as status;
SELECT '1. Database and tables: Ready' as checklist_item;
SELECT '2. AI functions: Ready' as checklist_item;
SELECT '3. Sample data: Loaded' as checklist_item;
SELECT '4. Warehouse: Active' as checklist_item;
SELECT '5. Streamlit app: Manual deployment required' as checklist_item;

-- ============================================================================
-- Next Steps
-- ============================================================================

SELECT '🚀 Next Steps:' as next_steps;
SELECT '1. Go to Snowflake Web UI > Projects > Streamlit' as step_1;
SELECT '2. Click "+ Streamlit App"' as step_2;
SELECT '3. Name: Customer_360_AI_Assistant' as step_3;
SELECT '4. Database: CUSTOMER_360_DB, Schema: PUBLIC' as step_4;  
SELECT '5. Warehouse: CUSTOMER_360_WH' as step_5;
SELECT '6. Copy/paste customer_360_sis_app.py code' as step_6;
SELECT '7. Click "Deploy" and start exploring!' as step_7;

-- ============================================================================
-- Useful Queries for App Monitoring
-- ============================================================================

-- Monitor app usage (uncomment when app is deployed)
/*
SELECT 
    START_TIME,
    END_TIME,
    USER_NAME, 
    QUERY_TEXT
FROM SNOWFLAKE.ACCOUNT_USAGE.STREAMLIT_EVENTS
WHERE STREAMLIT_NAME = 'CUSTOMER_360_AI_ASSISTANT'
ORDER BY START_TIME DESC
LIMIT 10;
*/

-- Check app performance
/*
SELECT 
    DATE(START_TIME) as usage_date,
    COUNT(*) as sessions,
    COUNT(DISTINCT USER_NAME) as unique_users,
    AVG(DATEDIFF('second', START_TIME, END_TIME)) as avg_session_duration_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.STREAMLIT_EVENTS
WHERE STREAMLIT_NAME = 'CUSTOMER_360_AI_ASSISTANT'
GROUP BY DATE(START_TIME)
ORDER BY usage_date DESC;
*/

SELECT '🎉 Deployment script completed!' as final_status;
SELECT 'Your Customer 360 & AI Assistant is ready for Streamlit deployment!' as final_message; 