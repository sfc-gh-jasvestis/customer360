-- =========================================
-- Customer 360 Demo - Status Check Script
-- =========================================
-- This script checks the current state of the demo deployment

USE DATABASE customer_360_db;
USE SCHEMA public;

-- ===============================
-- 1. DATABASE OBJECTS STATUS
-- ===============================

SELECT '🏗️ DATABASE OBJECTS STATUS' AS section;

-- Check tables
SELECT 
    'Tables' AS object_type,
    table_name,
    row_count,
    bytes,
    CASE 
        WHEN row_count > 0 THEN '✅ Has data'
        ELSE '⚠️  Empty'
    END AS status
FROM information_schema.tables t
JOIN information_schema.table_storage_metrics tsm ON t.table_name = tsm.table_name
WHERE t.table_schema = 'PUBLIC'
AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name;

-- Check views
SELECT 
    'Views' AS object_type,
    table_name AS view_name,
    'N/A' AS row_count,
    'N/A' AS bytes,
    '✅ Created' AS status
FROM information_schema.views
WHERE table_schema = 'PUBLIC'
ORDER BY table_name;

-- ===============================
-- 2. CORTEX SERVICES STATUS
-- ===============================

SELECT '🤖 CORTEX SERVICES STATUS' AS section;

-- Check Cortex Search Services
SELECT 
    'Search Service' AS service_type,
    service_name,
    service_schema,
    created_on,
    CASE 
        WHEN service_name IS NOT NULL THEN '✅ Active'
        ELSE '❌ Missing'
    END AS status
FROM information_schema.cortex_search_services
WHERE service_schema = 'PUBLIC';

-- Check functions (Cortex Agent related)
SELECT 
    'Function' AS object_type,
    function_name,
    argument_signature,
    'N/A' AS created_on,
    CASE 
        WHEN function_name IS NOT NULL THEN '✅ Created'
        ELSE '❌ Missing'
    END AS status
FROM information_schema.functions
WHERE function_schema = 'PUBLIC'
AND function_name LIKE '%customer%'
ORDER BY function_name;

-- ===============================
-- 3. DATA QUALITY CHECKS
-- ===============================

SELECT '📊 DATA QUALITY STATUS' AS section;

-- Customer data summary
SELECT 
    'Customers' AS data_type,
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_tier) AS tiers,
    AVG(churn_risk_score)::DECIMAL(4,3) AS avg_churn_risk,
    AVG(satisfaction_score)::DECIMAL(3,1) AS avg_satisfaction,
    CASE 
        WHEN COUNT(*) >= 5 THEN '✅ Good'
        WHEN COUNT(*) > 0 THEN '⚠️  Minimal'
        ELSE '❌ Empty'
    END AS status
FROM customers;

-- Activities summary
SELECT 
    'Activities' AS data_type,
    COUNT(*) AS total_records,
    COUNT(DISTINCT activity_type) AS activity_types,
    COUNT(DISTINCT customer_id) AS customers_with_activities,
    MIN(activity_timestamp) AS earliest_activity,
    CASE 
        WHEN COUNT(*) >= 10 THEN '✅ Good'
        WHEN COUNT(*) > 0 THEN '⚠️  Minimal'
        ELSE '❌ Empty'
    END AS status
FROM customer_activities;

-- Purchases summary
SELECT 
    'Purchases' AS data_type,
    COUNT(*) AS total_records,
    SUM(total_amount)::DECIMAL(12,2) AS total_revenue,
    AVG(total_amount)::DECIMAL(10,2) AS avg_order_value,
    COUNT(DISTINCT customer_id) AS customers_with_purchases,
    CASE 
        WHEN COUNT(*) >= 4 THEN '✅ Good'
        WHEN COUNT(*) > 0 THEN '⚠️  Minimal'
        ELSE '❌ Empty'
    END AS status
FROM purchases;

-- Support tickets summary
SELECT 
    'Support Tickets' AS data_type,
    COUNT(*) AS total_records,
    COUNT(DISTINCT category) AS categories,
    AVG(customer_satisfaction_rating)::DECIMAL(3,1) AS avg_satisfaction,
    COUNT(CASE WHEN status = 'open' THEN 1 END) AS open_tickets,
    CASE 
        WHEN COUNT(*) >= 3 THEN '✅ Good'
        WHEN COUNT(*) > 0 THEN '⚠️  Minimal'
        ELSE '❌ Empty'
    END AS status
FROM support_tickets;

-- Documents summary (for search)
SELECT 
    'Documents' AS data_type,
    COUNT(*) AS total_records,
    COUNT(DISTINCT document_type) AS document_types,
    AVG(LENGTH(document_content)) AS avg_content_length,
    COUNT(DISTINCT customer_id) AS customers_with_docs,
    CASE 
        WHEN COUNT(*) >= 4 THEN '✅ Good'
        WHEN COUNT(*) > 0 THEN '⚠️  Minimal'
        ELSE '❌ Empty'
    END AS status
FROM customer_documents;

-- ===============================
-- 4. CORTEX SEARCH TESTING
-- ===============================

SELECT '🔍 CORTEX SEARCH TESTING' AS section;

-- Test document search (if service exists)
SELECT 
    'Document Search Test' AS test_type,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.cortex_search_services WHERE service_name = 'CUSTOMER_DOCUMENTS_SEARCH') > 0 
        THEN 'Service exists - ready for testing'
        ELSE 'Service not found'
    END AS status;

-- If you want to test search functionality, uncomment and run:
/*
SELECT * FROM TABLE(
    CORTEX_SEARCH(
        'customer_documents_search',
        'billing issues'
    )
) LIMIT 3;
*/

-- ===============================
-- 5. RELATIONSHIPS INTEGRITY
-- ===============================

SELECT '🔗 RELATIONSHIP INTEGRITY' AS section;

-- Check customer-activity relationships
SELECT 
    'Customer-Activities' AS relationship_type,
    COUNT(*) AS total_activities,
    COUNT(DISTINCT ca.customer_id) AS customers_with_activities,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    CASE 
        WHEN COUNT(DISTINCT ca.customer_id) = COUNT(DISTINCT c.customer_id) THEN '✅ All customers have activities'
        WHEN COUNT(DISTINCT ca.customer_id) > 0 THEN '⚠️  Some customers have activities'
        ELSE '❌ No activities linked'
    END AS status
FROM customer_activities ca
RIGHT JOIN customers c ON ca.customer_id = c.customer_id;

-- Check customer-purchase relationships
SELECT 
    'Customer-Purchases' AS relationship_type,
    COUNT(*) AS total_purchases,
    COUNT(DISTINCT p.customer_id) AS customers_with_purchases,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    CASE 
        WHEN COUNT(DISTINCT p.customer_id) > 0 THEN '✅ Some customers have purchases'
        ELSE '❌ No purchases linked'
    END AS status
FROM purchases p
RIGHT JOIN customers c ON p.customer_id = c.customer_id;

-- ===============================
-- 6. WAREHOUSE AND PERFORMANCE
-- ===============================

SELECT '⚡ WAREHOUSE STATUS' AS section;

-- Check warehouse status
SHOW WAREHOUSES LIKE 'CUSTOMER_360_WH';

-- Check recent query performance
SELECT 
    'Query Performance' AS metric_type,
    COUNT(*) AS queries_last_hour,
    AVG(execution_time) AS avg_execution_ms,
    AVG(compilation_time) AS avg_compilation_ms,
    CASE 
        WHEN AVG(execution_time) < 5000 THEN '✅ Good performance'
        WHEN AVG(execution_time) < 15000 THEN '⚠️  Moderate performance'
        ELSE '❌ Slow performance'
    END AS status
FROM table(information_schema.query_history())
WHERE start_time >= DATEADD('hour', -1, CURRENT_TIMESTAMP())
AND warehouse_name = 'CUSTOMER_360_WH';

-- ===============================
-- 7. DEMO READINESS SUMMARY
-- ===============================

SELECT '🎯 DEMO READINESS SUMMARY' AS section;

WITH demo_status AS (
    SELECT 
        (SELECT COUNT(*) FROM customers) AS customer_count,
        (SELECT COUNT(*) FROM customer_activities) AS activity_count,
        (SELECT COUNT(*) FROM purchases) AS purchase_count,
        (SELECT COUNT(*) FROM support_tickets) AS ticket_count,
        (SELECT COUNT(*) FROM customer_documents) AS document_count,
        (SELECT COUNT(*) FROM information_schema.cortex_search_services WHERE service_schema = 'PUBLIC') AS search_services,
        (SELECT COUNT(*) FROM information_schema.functions WHERE function_schema = 'PUBLIC' AND function_name LIKE '%customer%') AS functions_count
)
SELECT 
    CASE 
        WHEN customer_count >= 5 
         AND activity_count >= 10 
         AND purchase_count >= 4 
         AND ticket_count >= 3 
         AND document_count >= 4 
         AND search_services >= 1 
         THEN '🎉 DEMO READY!'
        WHEN customer_count > 0 
         AND activity_count > 0
         THEN '⚠️  PARTIALLY READY - Some components missing'
        ELSE '❌ NOT READY - Major components missing'
    END AS overall_status,
    
    customer_count || ' customers' AS customers,
    activity_count || ' activities' AS activities,
    purchase_count || ' purchases' AS purchases,
    ticket_count || ' tickets' AS tickets,
    document_count || ' documents' AS documents,
    search_services || ' search services' AS search_services,
    functions_count || ' functions' AS functions,
    
    CASE 
        WHEN customer_count >= 5 AND activity_count >= 10 AND purchase_count >= 4 
         AND ticket_count >= 3 AND document_count >= 4 AND search_services >= 1 
        THEN 'All core components ready for demo'
        ELSE 'Review missing components above and run setup scripts'
    END AS recommendation
    
FROM demo_status;

-- ===============================
-- 8. NEXT STEPS
-- ===============================

SELECT '📋 NEXT STEPS' AS section;

SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.cortex_search_services WHERE service_schema = 'PUBLIC') = 0
        THEN '1. Create Cortex Search services (sql/04_cortex_search.sql)'
        
        WHEN (SELECT COUNT(*) FROM information_schema.functions WHERE function_name = 'ASK_CUSTOMER_360_AI') = 0
        THEN '2. Upload semantic model and create Cortex Agent (sql/06_cortex_agent.sql)'
        
        WHEN (SELECT COUNT(*) FROM customers) < 5
        THEN '3. Load sample data (sql/03_sample_data.sql)'
        
        ELSE '4. Deploy Streamlit application and start demo!'
    END AS next_step,
    
    CURRENT_TIMESTAMP() AS checked_at;

-- Final summary
SELECT 
    '✨ Status check completed!' AS message,
    CURRENT_TIMESTAMP() AS timestamp; 