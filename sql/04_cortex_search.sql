-- =========================================
-- Document Search Setup (Alternative Implementation)
-- =========================================

USE DATABASE customer_360_db;
USE SCHEMA public;

-- Note: This account does not support Cortex Search
-- Creating alternative text-based search functionality

SELECT 'Creating alternative document search capabilities...' AS status;

-- ===============================
-- Alternative Document Search Views
-- ===============================

-- Create a searchable view of all customer documents
CREATE OR REPLACE VIEW searchable_documents AS
SELECT 
    cd.document_id,
    cd.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.customer_tier,
    cd.document_title,
    cd.document_type,
    cd.document_category,
    cd.document_content,
    cd.created_at,
    cd.content_summary,
    -- Create searchable text by combining all text fields
    UPPER(CONCAT(
        COALESCE(cd.document_title, ''), ' ',
        COALESCE(cd.document_content, ''), ' ',
        COALESCE(cd.content_summary, ''), ' ',
        COALESCE(cd.document_category, ''), ' ',
        COALESCE(cd.document_type, '')
    )) as searchable_text
FROM customer_documents cd
JOIN customers c ON c.customer_id = cd.customer_id;

-- Create a view for customer activity search
CREATE OR REPLACE VIEW searchable_activities AS
SELECT 
    ca.activity_id,
    ca.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.customer_tier,
    ca.activity_type,
    ca.activity_title,
    ca.activity_description,
    ca.activity_timestamp,
    ca.channel,
    ca.priority,
    ca.status,
    -- Create searchable text
    UPPER(CONCAT(
        COALESCE(ca.activity_title, ''), ' ',
        COALESCE(ca.activity_description, ''), ' ',
        COALESCE(ca.activity_type, ''), ' ',
        COALESCE(ca.channel, '')
    )) as searchable_text
FROM customer_activities ca
JOIN customers c ON c.customer_id = ca.customer_id;

-- ===============================
-- Enhanced Search Functions (Fixed)
-- ===============================

-- Enhanced document search with multiple search terms
CREATE OR REPLACE FUNCTION search_documents_advanced(
    search_terms STRING,
    document_type STRING DEFAULT NULL,
    customer_tier_filter STRING DEFAULT NULL,
    days_back NUMBER DEFAULT 365
)
RETURNS TABLE(
    document_id STRING,
    customer_id STRING,
    customer_name STRING,
    customer_tier STRING,
    document_title STRING,
    document_type STRING,
    document_category STRING,
    match_snippet STRING,
    relevance_score NUMBER,
    created_at TIMESTAMP_NTZ
)
LANGUAGE SQL
AS
$$
    SELECT 
        sd.document_id,
        sd.customer_id,
        sd.customer_name,
        sd.customer_tier,
        sd.document_title,
        sd.document_type,
        sd.document_category,
        -- Extract snippet around the match
        CASE 
            WHEN POSITION(UPPER(search_terms) IN UPPER(sd.document_content)) > 0 THEN
                SUBSTRING(sd.document_content, 
                    GREATEST(1, POSITION(UPPER(search_terms) IN UPPER(sd.document_content)) - 75), 
                    300
                )
            ELSE SUBSTRING(COALESCE(sd.document_content, sd.document_title), 1, 300)
        END as match_snippet,
        -- Calculate relevance based on term matches
        (
            (CASE WHEN UPPER(sd.document_title) LIKE CONCAT('%', UPPER(search_terms), '%') THEN 10 ELSE 0 END) +
            (CASE WHEN UPPER(COALESCE(sd.content_summary, '')) LIKE CONCAT('%', UPPER(search_terms), '%') THEN 5 ELSE 0 END) +
            (CASE WHEN LENGTH(search_terms) > 0 THEN
                (LENGTH(sd.searchable_text) - LENGTH(REPLACE(sd.searchable_text, UPPER(search_terms), ''))) / LENGTH(search_terms)
             ELSE 0 END)
        ) as relevance_score,
        sd.created_at
    FROM searchable_documents sd
    WHERE sd.searchable_text LIKE CONCAT('%', UPPER(search_terms), '%')
    AND (document_type IS NULL OR sd.document_type = document_type)
    AND (customer_tier_filter IS NULL OR sd.customer_tier = customer_tier_filter)
    AND sd.created_at > DATEADD('day', -days_back, CURRENT_TIMESTAMP())
    AND (
        (CASE WHEN UPPER(sd.document_title) LIKE CONCAT('%', UPPER(search_terms), '%') THEN 10 ELSE 0 END) +
        (CASE WHEN UPPER(COALESCE(sd.content_summary, '')) LIKE CONCAT('%', UPPER(search_terms), '%') THEN 5 ELSE 0 END) +
        (CASE WHEN LENGTH(search_terms) > 0 THEN
            (LENGTH(sd.searchable_text) - LENGTH(REPLACE(sd.searchable_text, UPPER(search_terms), ''))) / LENGTH(search_terms)
         ELSE 0 END)
    ) > 0
    ORDER BY relevance_score DESC, created_at DESC
$$;

-- Enhanced activity search function
CREATE OR REPLACE FUNCTION search_activities_advanced(
    search_terms STRING,
    activity_type_filter STRING DEFAULT NULL,
    days_back NUMBER DEFAULT 90
)
RETURNS TABLE(
    activity_id STRING,
    customer_id STRING,
    customer_name STRING,
    activity_type STRING,
    activity_title STRING,
    activity_description STRING,
    activity_timestamp TIMESTAMP_NTZ,
    channel STRING,
    priority STRING,
    relevance_score NUMBER
)
LANGUAGE SQL
AS
$$
    SELECT 
        sa.activity_id,
        sa.customer_id,
        sa.customer_name,
        sa.activity_type,
        sa.activity_title,
        sa.activity_description,
        sa.activity_timestamp,
        sa.channel,
        sa.priority,
        -- Calculate relevance based on term matches
        (
            (CASE WHEN UPPER(sa.activity_title) LIKE CONCAT('%', UPPER(search_terms), '%') THEN 10 ELSE 0 END) +
            (CASE WHEN UPPER(COALESCE(sa.activity_description, '')) LIKE CONCAT('%', UPPER(search_terms), '%') THEN 5 ELSE 0 END) +
            (CASE WHEN LENGTH(search_terms) > 0 THEN
                (LENGTH(sa.searchable_text) - LENGTH(REPLACE(sa.searchable_text, UPPER(search_terms), ''))) / LENGTH(search_terms)
             ELSE 0 END)
        ) as relevance_score
    FROM searchable_activities sa
    WHERE sa.searchable_text LIKE CONCAT('%', UPPER(search_terms), '%')
    AND (activity_type_filter IS NULL OR sa.activity_type = activity_type_filter)
    AND sa.activity_timestamp > DATEADD('day', -days_back, CURRENT_TIMESTAMP())
    AND (
        (CASE WHEN UPPER(sa.activity_title) LIKE CONCAT('%', UPPER(search_terms), '%') THEN 10 ELSE 0 END) +
        (CASE WHEN UPPER(COALESCE(sa.activity_description, '')) LIKE CONCAT('%', UPPER(search_terms), '%') THEN 5 ELSE 0 END) +
        (CASE WHEN LENGTH(search_terms) > 0 THEN
            (LENGTH(sa.searchable_text) - LENGTH(REPLACE(sa.searchable_text, UPPER(search_terms), ''))) / LENGTH(search_terms)
         ELSE 0 END)
    ) > 0
    ORDER BY relevance_score DESC, activity_timestamp DESC
$$;

-- ===============================
-- Simplified Search Functions (Alternative)
-- ===============================

-- Simple document search function (fallback)
CREATE OR REPLACE FUNCTION search_documents_simple(search_terms STRING)
RETURNS TABLE(
    document_id STRING,
    customer_id STRING,
    customer_name STRING,
    document_title STRING,
    document_type STRING,
    match_snippet STRING
)
LANGUAGE SQL
AS
$$
    SELECT 
        cd.document_id,
        cd.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        cd.document_title,
        cd.document_type,
        SUBSTRING(COALESCE(cd.document_content, cd.document_title), 1, 200) as match_snippet
    FROM customer_documents cd
    JOIN customers c ON c.customer_id = cd.customer_id
    WHERE UPPER(COALESCE(cd.document_content, '')) LIKE CONCAT('%', UPPER(search_terms), '%')
       OR UPPER(COALESCE(cd.document_title, '')) LIKE CONCAT('%', UPPER(search_terms), '%')
       OR UPPER(COALESCE(cd.content_summary, '')) LIKE CONCAT('%', UPPER(search_terms), '%')
    ORDER BY cd.created_at DESC
$$;

-- ===============================
-- Quick Search Views for Common Queries
-- ===============================

-- View for finding support-related content
CREATE OR REPLACE VIEW support_related_content AS
SELECT 
    'document' as content_type,
    sd.document_id as content_id,
    sd.customer_id,
    sd.customer_name,
    sd.customer_tier,
    sd.document_title as title,
    SUBSTRING(sd.document_content, 1, 200) as content_preview,
    sd.created_at as content_date,
    'Support Document' as category
FROM searchable_documents sd
WHERE sd.searchable_text LIKE '%SUPPORT%' 
   OR sd.searchable_text LIKE '%TICKET%'
   OR sd.searchable_text LIKE '%HELP%'
   OR sd.document_type = 'transcript'

UNION ALL

SELECT 
    'activity' as content_type,
    sa.activity_id as content_id,
    sa.customer_id,
    sa.customer_name,
    sa.customer_tier,
    sa.activity_title as title,
    SUBSTRING(COALESCE(sa.activity_description, sa.activity_title), 1, 200) as content_preview,
    sa.activity_timestamp as content_date,
    'Support Activity' as category
FROM searchable_activities sa
WHERE sa.activity_type = 'support_ticket'
   OR sa.searchable_text LIKE '%SUPPORT%'
   OR sa.searchable_text LIKE '%TICKET%';

-- View for finding billing-related content
CREATE OR REPLACE VIEW billing_related_content AS
SELECT 
    'document' as content_type,
    sd.document_id as content_id,
    sd.customer_id,
    sd.customer_name,
    sd.customer_tier,
    sd.document_title as title,
    SUBSTRING(sd.document_content, 1, 200) as content_preview,
    sd.created_at as content_date,
    'Billing Document' as category
FROM searchable_documents sd
WHERE sd.searchable_text LIKE '%BILLING%' 
   OR sd.searchable_text LIKE '%PAYMENT%'
   OR sd.searchable_text LIKE '%CHARGE%'
   OR sd.searchable_text LIKE '%REFUND%'
   OR sd.searchable_text LIKE '%CREDIT%'

UNION ALL

SELECT 
    'activity' as content_type,
    sa.activity_id as content_id,
    sa.customer_id,
    sa.customer_name,
    sa.customer_tier,
    sa.activity_title as title,
    SUBSTRING(COALESCE(sa.activity_description, sa.activity_title), 1, 200) as content_preview,
    sa.activity_timestamp as content_date,
    'Billing Activity' as category
FROM searchable_activities sa
WHERE sa.searchable_text LIKE '%BILLING%'
   OR sa.searchable_text LIKE '%PAYMENT%'
   OR sa.searchable_text LIKE '%PURCHASE%';

-- ===============================
-- Test the Alternative Search
-- ===============================

SELECT 'Alternative document search system created successfully!' AS status,
       'No Cortex Search needed - using enhanced text search instead' AS note,
       'Functions: search_documents_advanced, search_activities_advanced, search_documents_simple' AS available_functions,
       'Views: support_related_content, billing_related_content' AS quick_search_views;

-- Sample searches (uncomment to test):
/*
-- Test simple document search (most reliable)
SELECT * FROM TABLE(search_documents_simple('billing')) LIMIT 5;
SELECT * FROM TABLE(search_documents_simple('shipping')) LIMIT 5;

-- Test advanced document search
SELECT * FROM TABLE(search_documents_advanced('billing')) LIMIT 5;
SELECT * FROM TABLE(search_documents_advanced('shipping delay')) LIMIT 5;

-- Test activity search
SELECT * FROM TABLE(search_activities_advanced('purchase')) LIMIT 5;

-- Test quick search views
SELECT * FROM support_related_content LIMIT 5;
SELECT * FROM billing_related_content LIMIT 5;

-- Search for specific document types
SELECT * FROM TABLE(search_documents_advanced('problem', 'feedback')) LIMIT 5;

-- Search recent activities only
SELECT * FROM TABLE(search_activities_advanced('login', NULL, 30)) LIMIT 5;
*/ 