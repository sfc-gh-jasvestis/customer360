-- =========================================
-- Customer 360 Demo - Cleanup Script
-- =========================================
-- This script removes all demo objects to start fresh
-- Run this before deploying the demo if you need to reset

USE DATABASE customer_360_db;
USE SCHEMA public;

SELECT '🧹 Starting cleanup of Customer 360 Demo...' AS status;

-- ===============================
-- Drop Tables (in dependency order)
-- ===============================

SELECT '📊 Dropping tables...' AS step_status;

-- Drop child tables first (those with foreign keys)
DROP TABLE IF EXISTS customer_documents;
DROP TABLE IF EXISTS customer_communications;
DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS customer_activities;

-- Drop parent table last
DROP TABLE IF EXISTS customers;

SELECT '✅ Tables dropped successfully' AS step_status;

-- ===============================
-- Drop Views
-- ===============================

SELECT '🔍 Dropping views...' AS step_status;

DROP VIEW IF EXISTS high_risk_customers;
DROP VIEW IF EXISTS customer_value_segments;
DROP VIEW IF EXISTS customer_360_dashboard;
DROP VIEW IF EXISTS billing_related_content;
DROP VIEW IF EXISTS support_related_content;
DROP VIEW IF EXISTS searchable_activities;
DROP VIEW IF EXISTS searchable_documents;

SELECT '✅ Views dropped successfully' AS step_status;

-- ===============================
-- Drop Functions
-- ===============================

SELECT '🔧 Dropping functions...' AS step_status;

DROP FUNCTION IF EXISTS analyze_customer_ai(STRING);
DROP FUNCTION IF EXISTS generate_customer_report(STRING);
DROP FUNCTION IF EXISTS get_customer_insights_summary();
DROP FUNCTION IF EXISTS search_customer_documents_text(STRING);
DROP FUNCTION IF EXISTS search_documents_simple(STRING);
DROP FUNCTION IF EXISTS search_documents_advanced(STRING, STRING, STRING, NUMBER);
DROP FUNCTION IF EXISTS search_activities_advanced(STRING, STRING, NUMBER);

SELECT '✅ Functions dropped successfully' AS step_status;

-- ===============================
-- Drop Stages
-- ===============================

SELECT '📦 Dropping stages...' AS step_status;

DROP STAGE IF EXISTS customer_360_stage;

SELECT '✅ Stages dropped successfully' AS step_status;

-- ===============================
-- Optional: Drop Warehouse
-- ===============================

-- Uncomment the following lines if you want to completely remove the warehouse
-- Note: This will stop any running queries and remove compute resources

/*
SELECT '⚙️ Dropping warehouse...' AS step_status;
DROP WAREHOUSE IF EXISTS customer_360_wh;
SELECT '✅ Warehouse dropped successfully' AS step_status;
*/

-- ===============================
-- Optional: Drop Database
-- ===============================

-- Uncomment the following lines if you want to completely remove the database
-- WARNING: This will delete ALL data and objects in the database

/*
SELECT '🗄️ Dropping database...' AS step_status;
DROP DATABASE IF EXISTS customer_360_db;
SELECT '✅ Database dropped successfully' AS step_status;
*/

-- ===============================
-- Verification
-- ===============================

SELECT '🧪 Verifying cleanup...' AS step_status;

-- Show remaining objects (should be minimal)
SHOW TABLES;
SHOW VIEWS;
SHOW USER FUNCTIONS;
SHOW STAGES;

-- Final cleanup status
SELECT 
    '🎉 Cleanup completed successfully!' AS status,
    'All demo objects have been removed' AS details,
    'Ready for fresh deployment' AS next_steps,
    CURRENT_TIMESTAMP() AS cleanup_completed_at;

SELECT '📋 Cleanup Summary:' AS summary_header;
SELECT '   ✅ Tables removed' AS cleanup_1;
SELECT '   ✅ Views removed' AS cleanup_2;
SELECT '   ✅ Functions removed' AS cleanup_3;
SELECT '   ✅ Stages removed' AS cleanup_4;
SELECT '   ℹ️ Warehouse preserved (commented out)' AS cleanup_5;
SELECT '   ℹ️ Database preserved (commented out)' AS cleanup_6;
SELECT '' AS separator;
SELECT '💡 To run a fresh setup: @sql/99_complete_setup.sql' AS next_step; 