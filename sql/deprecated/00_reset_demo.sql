-- ============================================================================
-- Retail Watch Store - Demo Reset Script
-- ============================================================================
-- This script removes all demo objects to start fresh
-- Run this before deploying the demo if you need to reset everything

USE DATABASE retail_watch_db;
USE SCHEMA public;
USE WAREHOUSE retail_watch_wh;

SELECT '🧹 Starting Demo Reset for Retail Watch Store...' AS reset_status;

-- ============================================================================
-- Step 1: Drop Views (no dependencies)
-- ============================================================================

SELECT '🔍 Step 1: Dropping views...' AS step_status;

DROP VIEW IF EXISTS high_risk_customers;
DROP VIEW IF EXISTS customer_360_dashboard;

SELECT '✅ Views dropped successfully' AS step_result;

-- ============================================================================
-- Step 2: Drop Functions (no dependencies)
-- ============================================================================

SELECT '🔧 Step 2: Dropping functions...' AS step_status;

-- Drop AI functions
DROP FUNCTION IF EXISTS predict_customer_churn(STRING);
DROP FUNCTION IF EXISTS get_personal_recommendations(STRING, STRING);
DROP FUNCTION IF EXISTS get_customer_360_insights(STRING);
DROP FUNCTION IF EXISTS analyze_review_sentiment(STRING);
DROP FUNCTION IF EXISTS optimize_product_pricing(STRING);

-- Drop any additional utility functions that might exist
DROP FUNCTION IF EXISTS search_customer_documents_text(STRING);
DROP FUNCTION IF EXISTS generate_customer_report(STRING);
DROP FUNCTION IF EXISTS get_customer_insights_summary();

SELECT '✅ Functions dropped successfully' AS step_result;

-- ============================================================================
-- Step 3: Drop Tables (in dependency order - children first)
-- ============================================================================

SELECT '📊 Step 3: Dropping tables...' AS step_status;

-- Drop child tables first (those with foreign keys)
DROP TABLE IF EXISTS customer_interactions;
DROP TABLE IF EXISTS product_reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS product_variants;
DROP TABLE IF EXISTS customer_events;

-- Drop main entity tables
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- Drop reference tables last
DROP TABLE IF EXISTS watch_categories;
DROP TABLE IF EXISTS watch_brands;

SELECT '✅ Tables dropped successfully' AS step_result;

-- ============================================================================
-- Step 4: Clean up any remaining objects
-- ============================================================================

SELECT '🧼 Step 4: Cleaning up remaining objects...' AS step_status;

-- Drop any sequences that might exist
DROP SEQUENCE IF EXISTS customer_id_seq;
DROP SEQUENCE IF EXISTS product_id_seq;
DROP SEQUENCE IF EXISTS order_id_seq;

-- Drop any stages that might exist
DROP STAGE IF EXISTS watch_data_stage;
DROP STAGE IF EXISTS customer_data_stage;

-- Drop any file formats that might exist
DROP FILE FORMAT IF EXISTS csv_format;
DROP FILE FORMAT IF EXISTS json_format;

-- Drop any pipes that might exist
DROP PIPE IF EXISTS customer_data_pipe;
DROP PIPE IF EXISTS product_data_pipe;

SELECT '✅ Remaining objects cleaned up' AS step_result;

-- ============================================================================
-- Step 5: Verify Clean State
-- ============================================================================

SELECT '🔍 Step 5: Verifying clean state...' AS step_status;

-- Check remaining tables
SELECT 'Remaining Tables: ' || COUNT(*) AS verification_result 
FROM information_schema.tables 
WHERE table_schema = 'PUBLIC' 
AND table_type = 'BASE TABLE';

-- Check remaining views
SELECT 'Remaining Views: ' || COUNT(*) AS verification_result 
FROM information_schema.views 
WHERE table_schema = 'PUBLIC';

-- Check remaining functions
SELECT 'Remaining Functions: ' || COUNT(*) AS verification_result 
FROM information_schema.functions 
WHERE function_schema = 'PUBLIC'
AND function_name NOT LIKE 'SYSTEM%';

SELECT '✅ Clean state verified' AS step_result;

-- ============================================================================
-- Optional: Drop Warehouse and Database (Uncomment if needed)
-- ============================================================================

SELECT '⚠️  Optional: Database and Warehouse cleanup available...' AS optional_step;

-- WARNING: Uncomment the lines below ONLY if you want to completely remove 
-- the database and warehouse. This will delete EVERYTHING permanently!

-- USE DATABASE SNOWFLAKE;
-- DROP DATABASE IF EXISTS retail_watch_db;
-- DROP WAREHOUSE IF EXISTS retail_watch_wh;

-- SELECT '🗑️  Database and warehouse dropped permanently' AS final_cleanup;

-- ============================================================================
-- Reset Complete
-- ============================================================================

SELECT '🎯 DEMO RESET COMPLETED SUCCESSFULLY!' AS final_status;

SELECT 'Reset Summary:' AS summary_title
UNION ALL
SELECT '• All tables dropped (10 tables)' AS summary_item
UNION ALL  
SELECT '• All AI functions removed (5+ functions)' AS summary_item
UNION ALL
SELECT '• All views dropped (2 views)' AS summary_item
UNION ALL
SELECT '• All supporting objects cleaned up' AS summary_item
UNION ALL
SELECT '• Database and warehouse preserved' AS summary_item;

SELECT 'Next Steps:' AS next_steps_title
UNION ALL
SELECT '1. Run sql/99_deploy_complete.sql to redeploy' AS next_step
UNION ALL
SELECT '2. Or run individual setup scripts in order' AS next_step
UNION ALL
SELECT '3. Load full sample data with sql/03_sample_data.sql' AS next_step
UNION ALL
SELECT '4. Launch Streamlit app: streamlit run watch_store_app.py' AS next_step;

SELECT '🚀 Ready for fresh deployment!' AS ready_status; 