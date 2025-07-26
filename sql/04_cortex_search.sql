-- =========================================
-- Cortex Search Service Setup
-- =========================================

USE DATABASE customer_360_db;
USE SCHEMA public;

-- Create Cortex Search service for customer documents
-- This will enable semantic search across customer support transcripts, contracts, and feedback

CREATE OR REPLACE CORTEX SEARCH SERVICE customer_documents_search
ON document_content
ATTRIBUTES document_title, document_type, document_category, customer_id, created_at
WAREHOUSE = customer_360_wh
TARGET_LAG = '5 minutes'
AS (
    SELECT 
        document_id,
        document_content,
        document_title,
        document_type,
        document_category,
        customer_id,
        created_at,
        -- Add computed attributes for better search
        CASE 
            WHEN document_type = 'transcript' THEN 'Support Conversation'
            WHEN document_type = 'contract' THEN 'Legal Agreement'
            WHEN document_type = 'feedback' THEN 'Customer Feedback'
            WHEN document_type = 'note' THEN 'Internal Note'
            ELSE 'General Document'
        END as document_type_display,
        
        -- Extract customer tier for filtering
        (SELECT customer_tier FROM customers c WHERE c.customer_id = customer_documents.customer_id) as customer_tier,
        
        -- Extract customer name for context
        (SELECT CONCAT(first_name, ' ', last_name) FROM customers c WHERE c.customer_id = customer_documents.customer_id) as customer_name
        
    FROM customer_documents
    WHERE document_content IS NOT NULL
    AND LENGTH(document_content) > 10  -- Filter out empty or too short content
);

-- Wait for service to be ready (this may take a few minutes)
-- You can check the status with:
-- DESCRIBE CORTEX SEARCH SERVICE customer_documents_search;

-- Test the search service with sample queries
-- These queries will work once the service is fully created and indexed

/*
-- Example search queries to test after service is ready:

-- Search for shipping-related issues
SELECT * FROM TABLE(
    CORTEX_SEARCH(
        'customer_documents_search',
        'shipping delays and delivery problems'
    )
) LIMIT 5;

-- Search for billing issues
SELECT * FROM TABLE(
    CORTEX_SEARCH(
        'customer_documents_search',
        'billing problems double charges',
        FILTER => {'document_type': 'feedback'}
    )
) LIMIT 5;

-- Search for enterprise customer documents
SELECT * FROM TABLE(
    CORTEX_SEARCH(
        'customer_documents_search',
        'enterprise contract services',
        FILTER => {'customer_tier': 'platinum'}
    )
) LIMIT 5;

-- Search for customer satisfaction issues
SELECT * FROM TABLE(
    CORTEX_SEARCH(
        'customer_documents_search',
        'customer dissatisfaction churn risk',
        FILTER => {'document_category': 'feedback'}
    )
) LIMIT 5;
*/

-- Create a helper function for common search operations
CREATE OR REPLACE FUNCTION search_customer_documents(query STRING, customer_tier STRING DEFAULT NULL)
RETURNS TABLE(
    document_id STRING,
    relevance_score FLOAT,
    document_title STRING,
    document_type STRING,
    customer_name STRING,
    snippet STRING
)
LANGUAGE SQL
AS
$$
    SELECT 
        document_id,
        relevance_score,
        document_title,
        document_type_display as document_type,
        customer_name,
        SUBSTRING(document_content, 1, 200) as snippet
    FROM TABLE(
        CORTEX_SEARCH(
            'customer_documents_search',
            query,
            CASE 
                WHEN customer_tier IS NOT NULL 
                THEN OBJECT_CONSTRUCT('customer_tier', customer_tier)
                ELSE NULL
            END
        )
    )
    ORDER BY relevance_score DESC
$$;

-- Create additional search service for customer activities (optional)
-- This can be used to search through activity descriptions and metadata

CREATE OR REPLACE CORTEX SEARCH SERVICE customer_activities_search
ON activity_description
ATTRIBUTES activity_type, activity_title, customer_id, activity_timestamp, priority
WAREHOUSE = customer_360_wh
TARGET_LAG = '5 minutes'
AS (
    SELECT 
        activity_id,
        activity_description,
        activity_type,
        activity_title,
        customer_id,
        activity_timestamp,
        priority,
        channel,
        -- Add customer context
        (SELECT CONCAT(first_name, ' ', last_name) FROM customers c WHERE c.customer_id = customer_activities.customer_id) as customer_name,
        (SELECT customer_tier FROM customers c WHERE c.customer_id = customer_activities.customer_id) as customer_tier
    FROM customer_activities
    WHERE activity_description IS NOT NULL
    AND LENGTH(activity_description) > 5
);

-- Grant necessary permissions for the search services
-- Note: Adjust roles as needed for your environment
-- GRANT USAGE ON CORTEX SEARCH SERVICE customer_documents_search TO ROLE your_role;
-- GRANT USAGE ON CORTEX SEARCH SERVICE customer_activities_search TO ROLE your_role;

-- Show created search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA public;

SELECT 'Cortex Search services created successfully' AS status,
       'Services may take a few minutes to be fully indexed' AS note; 