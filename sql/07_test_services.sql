-- =========================================
-- Test Customer 360 Services and Functions
-- =========================================

USE DATABASE customer_360_db;
USE SCHEMA public;

-- ===============================
-- 1. Check Cortex Search Services Status
-- ===============================

-- List all Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA public;

-- Check if services exist (will show empty if not supported)
SELECT 'Checking Cortex Search services...' AS status;

-- Try to describe the services (comment out if they don't exist)
/*
DESCRIBE CORTEX SEARCH SERVICE customer_documents_search;
DESCRIBE CORTEX SEARCH SERVICE customer_activities_search;
*/

-- ===============================
-- 2. Check Functions Status
-- ===============================

-- List all user-defined functions
SHOW USER FUNCTIONS IN SCHEMA public;

-- ===============================
-- 3. Test Alternative Document Search (Always Works)
-- ===============================

-- Test text-based document search function
SELECT 'Testing document search function...' AS test_name;

SELECT * FROM TABLE(search_customer_documents_text('billing')) LIMIT 5;

SELECT * FROM TABLE(search_customer_documents_text('shipping')) LIMIT 5;

-- ===============================
-- 4. Test AI Analysis Functions
-- ===============================

-- Test customer analysis
SELECT 'Testing customer analysis...' AS test_name;

SELECT analyze_customer_ai('CUST_001');

-- Test insights summary
SELECT 'Testing insights summary...' AS test_name;

SELECT * FROM TABLE(get_customer_insights_summary());

-- Test customer report
SELECT 'Testing customer report...' AS test_name;

SELECT generate_customer_report('CUST_003');

-- ===============================
-- 5. Test Dashboard Views
-- ===============================

-- Test main dashboard
SELECT 'Testing dashboard views...' AS test_name;

SELECT * FROM customer_360_dashboard LIMIT 5;

-- Test high-risk customers
SELECT * FROM high_risk_customers;

-- Test customer segments
SELECT * FROM customer_value_segments;

-- ===============================
-- 6. Alternative Cortex Search Queries (if services exist)
-- ===============================

-- If Cortex Search is available, use these queries instead:
/*
-- Correct syntax for Cortex Search (if available)
SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH(
    'customer_documents_search',
    'shipping delays and delivery problems'
)) LIMIT 5;

SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH(
    'customer_documents_search', 
    'billing problems',
    OBJECT_CONSTRUCT('document_type', 'feedback')
)) LIMIT 5;
*/

-- ===============================
-- 7. Manual Document Analysis (Alternative to Cortex Search)
-- ===============================

-- Search for shipping-related documents manually
SELECT 
    cd.document_id,
    cd.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    cd.document_title,
    cd.document_type,
    cd.document_category,
    SUBSTRING(cd.document_content, 1, 200) as content_preview
FROM customer_documents cd
JOIN customers c ON c.customer_id = cd.customer_id
WHERE UPPER(cd.document_content) LIKE '%SHIPPING%' 
   OR UPPER(cd.document_content) LIKE '%DELAY%'
   OR UPPER(cd.document_content) LIKE '%DELIVER%'
ORDER BY cd.created_at DESC;

-- Search for billing-related documents
SELECT 
    cd.document_id,
    cd.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    cd.document_title,
    cd.document_type,
    cd.document_category,
    SUBSTRING(cd.document_content, 1, 200) as content_preview
FROM customer_documents cd
JOIN customers c ON c.customer_id = cd.customer_id
WHERE UPPER(cd.document_content) LIKE '%BILLING%' 
   OR UPPER(cd.document_content) LIKE '%CHARGE%'
   OR UPPER(cd.document_content) LIKE '%PAYMENT%'
ORDER BY cd.created_at DESC;

-- ===============================
-- 8. Customer 360 Demo Queries
-- ===============================

-- Show complete customer profile with related data
SELECT 
    'Customer 360 View for CUST_001' AS analysis_type,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.customer_tier,
    c.churn_risk_score,
    c.satisfaction_score,
    c.total_spent,
    c.lifetime_value,
    -- Recent activity count
    (SELECT COUNT(*) FROM customer_activities 
     WHERE customer_id = 'CUST_001' 
     AND activity_timestamp > DATEADD('day', -30, CURRENT_TIMESTAMP())) as recent_activities,
    -- Open tickets
    (SELECT COUNT(*) FROM support_tickets 
     WHERE customer_id = 'CUST_001' 
     AND status IN ('open', 'pending')) as open_tickets,
    -- Recent purchases
    (SELECT COUNT(*) FROM purchases 
     WHERE customer_id = 'CUST_001' 
     AND purchase_date > DATEADD('day', -90, CURRENT_TIMESTAMP())) as recent_purchases
FROM customers c
WHERE c.customer_id = 'CUST_001';

-- Show all high-risk customers with details
SELECT 
    'High Risk Customer Analysis' AS analysis_type,
    customer_id,
    customer_name,
    customer_tier,
    churn_risk_score,
    satisfaction_score,
    recent_activity_count,
    open_tickets,
    total_spent
FROM customer_360_dashboard 
WHERE risk_level = 'HIGH'
ORDER BY churn_risk_score DESC;

SELECT 'All tests completed! Review results above.' AS final_status; 