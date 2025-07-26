-- =========================================
-- Customer 360 Demo - Complete Cleanup Script
-- =========================================
-- This script removes all demo objects to start fresh
-- Run this before redeploying the demo

-- Set context
USE ROLE SYSADMIN; -- Or your appropriate role
USE WAREHOUSE compute_wh; -- Or your warehouse

-- ===============================
-- 1. DROP CORTEX AGENT
-- ===============================
USE DATABASE customer_360_db;
USE SCHEMA public;

-- Drop Cortex Agent and related functions
DROP CORTEX AGENT IF EXISTS customer_360_ai_assistant;
DROP FUNCTION IF EXISTS ask_customer_360_ai(STRING);
DROP FUNCTION IF EXISTS analyze_customer(STRING, STRING);
DROP FUNCTION IF EXISTS get_customer_insights(STRING);
DROP FUNCTION IF EXISTS analyze_support_trends();
DROP FUNCTION IF EXISTS analyze_revenue_opportunities();
DROP FUNCTION IF EXISTS search_customer_context(STRING, STRING);
DROP FUNCTION IF EXISTS search_customer_documents(STRING, STRING);

-- ===============================
-- 2. DROP CORTEX SEARCH SERVICES
-- ===============================

-- Drop search services (may take a few minutes)
DROP CORTEX SEARCH SERVICE IF EXISTS customer_documents_search;
DROP CORTEX SEARCH SERVICE IF EXISTS customer_activities_search;

-- Wait for services to be fully dropped
-- You can check status with: SHOW CORTEX SEARCH SERVICES;

-- ===============================
-- 3. DROP VIEWS
-- ===============================

DROP VIEW IF EXISTS customer_360_summary;
DROP VIEW IF EXISTS recent_customer_activities;

-- ===============================
-- 4. DROP TABLES
-- ===============================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS customer_documents;
DROP TABLE IF EXISTS customer_communications;
DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS customer_activities;
DROP TABLE IF EXISTS customers;

-- ===============================
-- 5. DROP STAGES
-- ===============================

DROP STAGE IF EXISTS customer_360_stage;
DROP STAGE IF EXISTS customer_360_semantic_model_stage;

-- ===============================
-- 6. DROP WAREHOUSE (OPTIONAL)
-- ===============================

-- Uncomment the following line if you want to drop the warehouse
-- DROP WAREHOUSE IF EXISTS customer_360_wh;

-- ===============================
-- 7. DROP DATABASE (OPTIONAL)
-- ===============================

-- Uncomment the following lines if you want to completely remove the database
-- USE DATABASE snowflake; -- Switch to a different database first
-- DROP DATABASE IF EXISTS customer_360_db;

-- ===============================
-- 8. VERIFICATION
-- ===============================

-- Check remaining objects
SHOW TABLES IN DATABASE customer_360_db;
SHOW VIEWS IN DATABASE customer_360_db;
SHOW FUNCTIONS IN DATABASE customer_360_db;
SHOW CORTEX SEARCH SERVICES IN DATABASE customer_360_db;

-- Display cleanup summary
SELECT 
    'Demo cleanup completed!' AS status,
    CURRENT_TIMESTAMP() AS cleanup_time,
    'Ready for fresh deployment' AS next_step; 