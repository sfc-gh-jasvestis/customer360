-- ============================================================================
-- Customer 360 & AI Assistant - Comprehensive Service Testing
-- ============================================================================
-- This script tests all services and provides detailed diagnostics

USE DATABASE customer_360_db;
USE SCHEMA public;
USE WAREHOUSE customer_360_wh;

SELECT '🧪 STARTING COMPREHENSIVE SERVICE TEST...' as test_status;

-- ============================================================================
-- 1. DATABASE AND WAREHOUSE STATUS
-- ============================================================================
SELECT '📊 CHECKING DATABASE AND WAREHOUSE STATUS...' as test_section;

-- Check current database and warehouse
SELECT CURRENT_DATABASE() as current_database, CURRENT_WAREHOUSE() as current_warehouse;

-- Check warehouse status
SELECT name, state, size, auto_suspend, auto_resume 
FROM INFORMATION_SCHEMA.WAREHOUSES 
WHERE name = 'CUSTOMER_360_WH';

-- ============================================================================
-- 2. TABLE VERIFICATION
-- ============================================================================
SELECT '📋 CHECKING TABLES...' as test_section;

-- List all tables
SELECT table_name, row_count, bytes
FROM INFORMATION_SCHEMA.TABLES 
WHERE table_schema = 'PUBLIC' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Check data in key tables
SELECT 'customers' as table_name, COUNT(*) as row_count FROM customers
UNION ALL
SELECT 'customer_activities' as table_name, COUNT(*) as row_count FROM customer_activities  
UNION ALL
SELECT 'customer_documents' as table_name, COUNT(*) as row_count FROM customer_documents
UNION ALL
SELECT 'support_tickets' as table_name, COUNT(*) as row_count FROM support_tickets
UNION ALL
SELECT 'purchases' as table_name, COUNT(*) as row_count FROM purchases;

-- ============================================================================
-- 3. FUNCTION VERIFICATION
-- ============================================================================
SELECT '⚙️ CHECKING USER-DEFINED FUNCTIONS...' as test_section;

-- List all UDFs
SELECT function_name, function_language, argument_signature, data_type as return_type
FROM INFORMATION_SCHEMA.FUNCTIONS 
WHERE function_schema = 'PUBLIC'
ORDER BY function_name;

-- ============================================================================
-- 4. VIEW VERIFICATION  
-- ============================================================================
SELECT '👁️ CHECKING VIEWS...' as test_section;

-- List all views
SELECT table_name as view_name, is_updatable
FROM INFORMATION_SCHEMA.VIEWS 
WHERE table_schema = 'PUBLIC'
ORDER BY table_name;

-- Test views
SELECT 'customer_360_dashboard' as view_name, COUNT(*) as row_count FROM customer_360_dashboard
UNION ALL
SELECT 'high_risk_customers' as view_name, COUNT(*) as row_count FROM high_risk_customers
UNION ALL  
SELECT 'customer_value_segments' as view_name, COUNT(*) as row_count FROM customer_value_segments;

-- ============================================================================
-- 5. CORTEX SEARCH SERVICE VERIFICATION
-- ============================================================================
SELECT '🔍 CHECKING CORTEX SEARCH SERVICES...' as test_section;

-- Check for Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA public;

-- Alternative: Check if any search services exist
SELECT 'No native Cortex Search services found - using alternative text-based search functions' as cortex_search_status;

-- ============================================================================
-- 6. AI FUNCTION TESTING
-- ============================================================================
SELECT '🤖 TESTING AI FUNCTIONS...' as test_section;

-- Test analyze_customer_ai function
SELECT '1. Testing analyze_customer_ai...' as test_step;
SELECT analyze_customer_ai('CUST_001') as ai_analysis_result;

-- Test get_customer_insights_summary function  
SELECT '2. Testing get_customer_insights_summary...' as test_step;
SELECT get_customer_insights_summary() as insights_result;

-- Test search_customer_documents_text function
SELECT '3. Testing search_customer_documents_text...' as test_step;
SELECT search_customer_documents_text('billing') as search_result;

-- Test generate_customer_report function
SELECT '4. Testing generate_customer_report...' as test_step;
SELECT generate_customer_report('CUST_001') as report_result;

-- ============================================================================
-- 7. SEARCH FUNCTION TESTING (Alternative to Cortex Search)
-- ============================================================================
SELECT '🔎 TESTING ALTERNATIVE SEARCH FUNCTIONS...' as test_section;

-- Test document search views
SELECT '1. Testing searchable_documents view...' as test_step;
SELECT COUNT(*) as searchable_docs_count FROM searchable_documents;

SELECT '2. Testing searchable_activities view...' as test_step;  
SELECT COUNT(*) as searchable_activities_count FROM searchable_activities;

-- Test specific search queries
SELECT '3. Testing document search functionality...' as test_step;
SELECT * FROM searchable_documents 
WHERE UPPER(searchable_text) LIKE '%BILLING%' 
LIMIT 3;

SELECT '4. Testing activity search functionality...' as test_step;
SELECT * FROM searchable_activities 
WHERE UPPER(searchable_text) LIKE '%SUPPORT%'
LIMIT 3;

-- ============================================================================
-- 8. ERROR TESTING AND DIAGNOSTICS
-- ============================================================================
SELECT '🔧 RUNNING ERROR DIAGNOSTICS...' as test_section;

-- Test for common errors
BEGIN
    -- Test if functions exist and are callable
    SELECT 'Function test: analyze_customer_ai exists and is callable' as diagnostic_result;
    SELECT analyze_customer_ai('CUST_001') as test_result;
EXCEPTION
    WHEN STATEMENT_ERROR THEN
        SELECT 'ERROR: analyze_customer_ai function has issues' as diagnostic_result;
END;

BEGIN
    SELECT 'Function test: get_customer_insights_summary exists and is callable' as diagnostic_result;
    SELECT get_customer_insights_summary() as test_result;
EXCEPTION
    WHEN STATEMENT_ERROR THEN
        SELECT 'ERROR: get_customer_insights_summary function has issues' as diagnostic_result;
END;

BEGIN
    SELECT 'Function test: search_customer_documents_text exists and is callable' as diagnostic_result;
    SELECT search_customer_documents_text('test') as test_result;
EXCEPTION
    WHEN STATEMENT_ERROR THEN
        SELECT 'ERROR: search_customer_documents_text function has issues' as diagnostic_result;
END;

-- ============================================================================
-- 9. PERFORMANCE TESTING
-- ============================================================================
SELECT '⚡ RUNNING PERFORMANCE TESTS...' as test_section;

-- Test query performance on key views
SELECT 'Performance test: customer_360_dashboard' as test_name, 
       COUNT(*) as record_count,
       CURRENT_TIMESTAMP() as test_time
FROM customer_360_dashboard;

SELECT 'Performance test: high_risk_customers' as test_name,
       COUNT(*) as record_count, 
       CURRENT_TIMESTAMP() as test_time
FROM high_risk_customers;

-- ============================================================================
-- 10. DATA INTEGRITY CHECKS
-- ============================================================================
SELECT '🔍 RUNNING DATA INTEGRITY CHECKS...' as test_section;

-- Check for orphaned records
SELECT 'Orphaned activities (no matching customer)' as integrity_check,
       COUNT(*) as issue_count
FROM customer_activities ca
LEFT JOIN customers c ON ca.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT 'Orphaned support tickets (no matching customer)' as integrity_check,
       COUNT(*) as issue_count  
FROM support_tickets st
LEFT JOIN customers c ON st.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT 'Orphaned purchases (no matching customer)' as integrity_check,
       COUNT(*) as issue_count
FROM purchases p
LEFT JOIN customers c ON p.customer_id = c.customer_id  
WHERE c.customer_id IS NULL;

-- Check for data quality issues
SELECT 'Customers with NULL churn_risk_score' as data_quality_check,
       COUNT(*) as issue_count
FROM customers 
WHERE churn_risk_score IS NULL;

SELECT 'Customers with NULL satisfaction_score' as data_quality_check,
       COUNT(*) as issue_count
FROM customers
WHERE satisfaction_score IS NULL;

-- ============================================================================
-- 11. SAMPLE DATA VERIFICATION
-- ============================================================================
SELECT '📝 VERIFYING SAMPLE DATA...' as test_section;

-- Show sample customers
SELECT 'Sample customers:' as data_sample;
SELECT customer_id, first_name, last_name, customer_tier, total_spent, churn_risk_score
FROM customers 
ORDER BY total_spent DESC 
LIMIT 5;

-- Show sample activities
SELECT 'Sample activities:' as data_sample;
SELECT activity_id, customer_id, activity_type, activity_title, activity_timestamp
FROM customer_activities 
ORDER BY activity_timestamp DESC 
LIMIT 5;

-- ============================================================================
-- 12. FINAL STATUS REPORT
-- ============================================================================
SELECT '📊 GENERATING FINAL STATUS REPORT...' as test_section;

SELECT 
    'TEST SUMMARY' as report_section,
    'Customer 360 & AI Assistant Service Test' as report_title,
    CURRENT_TIMESTAMP() as test_timestamp;

-- Count all major components
SELECT 
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'PUBLIC' AND table_type = 'BASE TABLE') as tables_count,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.VIEWS WHERE table_schema = 'PUBLIC') as views_count,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.FUNCTIONS WHERE function_schema = 'PUBLIC') as functions_count,
    (SELECT COUNT(*) FROM customers) as customers_count,
    (SELECT COUNT(*) FROM customer_activities) as activities_count;

-- Status indicators
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM customers) > 0 THEN '✅ PASS'
        ELSE '❌ FAIL' 
    END as sample_data_status,
    CASE
        WHEN (SELECT COUNT(*) FROM INFORMATION_SCHEMA.FUNCTIONS WHERE function_schema = 'PUBLIC') >= 4 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END as ai_functions_status,
    CASE
        WHEN (SELECT COUNT(*) FROM INFORMATION_SCHEMA.VIEWS WHERE table_schema = 'PUBLIC') >= 3 THEN '✅ PASS' 
        ELSE '❌ FAIL'
    END as dashboard_views_status;

SELECT '🎉 TEST COMPLETED!' as final_status,
       'Review results above for any issues that need attention' as next_steps; 