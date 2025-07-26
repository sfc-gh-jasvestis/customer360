-- =========================================
-- Customer 360 AI Assistant (Alternative Implementation)
-- =========================================

USE DATABASE customer_360_db;
USE SCHEMA public;

-- Check if Cortex AI functions are available
SELECT 'Checking Snowflake Cortex availability...' AS status;

-- Note: Cortex Agents are a new feature and may not be available in all accounts
-- This implementation uses simpler SQL functions for customer analysis

-- Function 1: Customer Analysis (Simplified Version)
CREATE OR REPLACE FUNCTION analyze_customer_ai(customer_id STRING)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'customer_id', customer_id,
        'analysis_timestamp', CURRENT_TIMESTAMP(),
        'customer_profile', (
            SELECT OBJECT_CONSTRUCT(
                'id', c.customer_id,
                'name', CONCAT(c.first_name, ' ', c.last_name),
                'tier', c.customer_tier,
                'status', c.account_status,
                'total_spent', c.total_spent,
                'lifetime_value', c.lifetime_value,
                'churn_risk_score', c.churn_risk_score,
                'satisfaction_score', c.satisfaction_score,
                'engagement_score', c.engagement_score,
                'last_login', c.last_login_date
            )
            FROM customers c WHERE c.customer_id = customer_id
        ),
        'risk_assessment', OBJECT_CONSTRUCT(
            'risk_level', CASE 
                WHEN (SELECT churn_risk_score FROM customers WHERE customer_id = customer_id) > 0.7 THEN 'HIGH'
                WHEN (SELECT churn_risk_score FROM customers WHERE customer_id = customer_id) > 0.4 THEN 'MEDIUM'
                ELSE 'LOW' 
            END,
            'risk_factors', ARRAY_CONSTRUCT(
                CASE WHEN (SELECT churn_risk_score FROM customers WHERE customer_id = customer_id) > 0.7 THEN 'High churn probability' END,
                CASE WHEN (SELECT satisfaction_score FROM customers WHERE customer_id = customer_id) < 3.5 THEN 'Low satisfaction score' END,
                CASE WHEN (SELECT COUNT(*) FROM support_tickets WHERE customer_id = customer_id AND status IN ('open', 'pending')) > 0 THEN 'Open support tickets' END,
                CASE WHEN (SELECT last_login_date FROM customers WHERE customer_id = customer_id) < DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 'Inactive for 30+ days' END
            )
        ),
        'activity_summary', (
            SELECT OBJECT_CONSTRUCT(
                'total_activities', COUNT(*),
                'recent_activities', COUNT(CASE WHEN activity_timestamp > DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 1 END),
                'last_activity', MAX(activity_timestamp),
                'most_common_activity', MODE(activity_type)
            )
            FROM customer_activities WHERE customer_id = customer_id
        ),
        'support_summary', (
            SELECT OBJECT_CONSTRUCT(
                'total_tickets', COUNT(*),
                'open_tickets', COUNT(CASE WHEN status IN ('open', 'pending') THEN 1 END),
                'avg_satisfaction', AVG(customer_satisfaction_rating),
                'recent_tickets', COUNT(CASE WHEN created_at > DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 1 END)
            )
            FROM support_tickets WHERE customer_id = customer_id
        ),
        'purchase_summary', (
            SELECT OBJECT_CONSTRUCT(
                'total_purchases', COUNT(*),
                'total_revenue', SUM(total_amount),
                'last_purchase_date', MAX(purchase_date),
                'recent_purchases', COUNT(CASE WHEN purchase_date > DATEADD('day', -90, CURRENT_TIMESTAMP()) THEN 1 END)
            )
            FROM purchases WHERE customer_id = customer_id
        ),
        'recommendations', ARRAY_CONSTRUCT(
            CASE WHEN (SELECT churn_risk_score FROM customers WHERE customer_id = customer_id) > 0.6 THEN 'Immediate retention outreach recommended' END,
            CASE WHEN (SELECT COUNT(*) FROM support_tickets WHERE customer_id = customer_id AND status = 'open') > 0 THEN 'Follow up on open support tickets' END,
            CASE WHEN (SELECT customer_tier FROM customers WHERE customer_id = customer_id) = 'bronze' AND (SELECT total_spent FROM customers WHERE customer_id = customer_id) > 5000 THEN 'Consider tier upgrade offer' END,
            CASE WHEN (SELECT engagement_score FROM customers WHERE customer_id = customer_id) > 0.8 THEN 'Good candidate for upselling' END
        )
    )::VARIANT
$$;

-- Function 2: Get Customer Insights Summary
CREATE OR REPLACE FUNCTION get_customer_insights_summary()
RETURNS TABLE(
    insight_type STRING,
    insight_value STRING,
    customer_count NUMBER,
    details VARIANT
)
LANGUAGE SQL
AS
$$
    SELECT * FROM (
        -- High churn risk customers
        SELECT 
            'High Churn Risk' as insight_type,
            'Customers with churn risk > 0.7' as insight_value,
            COUNT(*) as customer_count,
            ARRAY_AGG(OBJECT_CONSTRUCT('customer_id', customer_id, 'name', CONCAT(first_name, ' ', last_name), 'risk_score', churn_risk_score))::VARIANT as details
        FROM customers 
        WHERE churn_risk_score > 0.7
        
        UNION ALL
        
        -- Low satisfaction customers
        SELECT 
            'Low Satisfaction' as insight_type,
            'Customers with satisfaction < 3.5' as insight_value,
            COUNT(*) as customer_count,
            ARRAY_AGG(OBJECT_CONSTRUCT('customer_id', customer_id, 'name', CONCAT(first_name, ' ', last_name), 'satisfaction', satisfaction_score))::VARIANT as details
        FROM customers 
        WHERE satisfaction_score < 3.5
        
        UNION ALL
        
        -- High value customers
        SELECT 
            'High Value' as insight_type,
            'Platinum tier customers' as insight_value,
            COUNT(*) as customer_count,
            ARRAY_AGG(OBJECT_CONSTRUCT('customer_id', customer_id, 'name', CONCAT(first_name, ' ', last_name), 'lifetime_value', lifetime_value))::VARIANT as details
        FROM customers 
        WHERE customer_tier = 'platinum'
        
        UNION ALL
        
        -- Recent support issues
        SELECT 
            'Recent Support Issues' as insight_type,
            'Open or recent tickets' as insight_value,
            COUNT(DISTINCT customer_id) as customer_count,
            ARRAY_AGG(OBJECT_CONSTRUCT('ticket_id', ticket_id, 'customer_id', customer_id, 'subject', subject, 'priority', priority))::VARIANT as details
        FROM support_tickets 
        WHERE status IN ('open', 'pending') OR created_at > DATEADD('day', -7, CURRENT_TIMESTAMP())
    )
$$;

-- Function 3: Search Customer Documents (Alternative to Cortex Search)
CREATE OR REPLACE FUNCTION search_customer_documents_text(search_term STRING)
RETURNS TABLE(
    document_id STRING,
    customer_id STRING,
    customer_name STRING,
    document_title STRING,
    document_type STRING,
    match_snippet STRING,
    relevance_score NUMBER
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
        SUBSTRING(cd.document_content, 
            GREATEST(1, POSITION(UPPER(search_term) IN UPPER(cd.document_content)) - 50), 
            200
        ) as match_snippet,
        -- Simple relevance scoring based on term frequency
        (LENGTH(cd.document_content) - LENGTH(REPLACE(UPPER(cd.document_content), UPPER(search_term), ''))) / LENGTH(search_term) as relevance_score
    FROM customer_documents cd
    JOIN customers c ON c.customer_id = cd.customer_id
    WHERE UPPER(cd.document_content) LIKE CONCAT('%', UPPER(search_term), '%')
       OR UPPER(cd.document_title) LIKE CONCAT('%', UPPER(search_term), '%')
    ORDER BY relevance_score DESC
$$;

-- Function 4: Generate Customer Summary Report (Simplified)
CREATE OR REPLACE FUNCTION generate_customer_report(customer_id STRING)
RETURNS VARIANT
LANGUAGE SQL  
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'generated_at', CURRENT_TIMESTAMP(),
        'customer', (
            SELECT OBJECT_CONSTRUCT(
                'id', c.customer_id,
                'name', CONCAT(c.first_name, ' ', c.last_name),
                'email', c.email,
                'tier', c.customer_tier,
                'status', c.account_status,
                'join_date', c.join_date,
                'last_login', c.last_login_date
            )
            FROM customers c WHERE c.customer_id = customer_id
        ),
        'metrics', (
            SELECT OBJECT_CONSTRUCT(
                'total_spent', c.total_spent,
                'lifetime_value', c.lifetime_value,
                'credit_limit', c.credit_limit,
                'churn_risk_score', c.churn_risk_score,
                'satisfaction_score', c.satisfaction_score,
                'engagement_score', c.engagement_score
            )
            FROM customers c WHERE c.customer_id = customer_id
        ),
        'activity_counts', OBJECT_CONSTRUCT(
            'recent_activities', (
                SELECT COUNT(*) 
                FROM customer_activities 
                WHERE customer_id = customer_id AND activity_timestamp > DATEADD('day', -30, CURRENT_TIMESTAMP())
            ),
            'open_tickets', (
                SELECT COUNT(*) 
                FROM support_tickets 
                WHERE customer_id = customer_id AND status IN ('open', 'pending')
            ),
            'total_purchases', (
                SELECT COUNT(*) 
                FROM purchases 
                WHERE customer_id = customer_id
            )
        ),
        'last_purchase_date', (
            SELECT MAX(purchase_date) 
            FROM purchases 
            WHERE customer_id = customer_id
        ),
        'communication_preferences', (
            SELECT OBJECT_CONSTRUCT(
                'channel', c.preferred_communication_channel,
                'marketing_opt_in', c.marketing_opt_in,
                'newsletter_subscription', c.newsletter_subscription
            )
            FROM customers c WHERE c.customer_id = customer_id
        ),
        'risk_indicators', (
            SELECT ARRAY_CONSTRUCT(
                CASE WHEN c.churn_risk_score > 0.7 THEN 'High churn risk' END,
                CASE WHEN c.satisfaction_score < 3.5 THEN 'Low satisfaction' END,
                CASE WHEN c.last_login_date < DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 'Inactive user' END,
                CASE WHEN (SELECT COUNT(*) FROM support_tickets WHERE customer_id = customer_id AND status = 'open') > 0 THEN 'Open support tickets' END
            )
            FROM customers c WHERE c.customer_id = customer_id
        )
    )::VARIANT
$$;

-- Create views for easy dashboard access
CREATE OR REPLACE VIEW customer_360_dashboard AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.customer_tier,
    c.account_status,
    c.total_spent,
    c.lifetime_value,
    c.churn_risk_score,
    c.satisfaction_score,
    c.engagement_score,
    c.last_login_date,
    -- Activity summary
    COALESCE(recent_activities.activity_count, 0) as recent_activity_count,
    COALESCE(recent_activities.last_activity_date, c.join_date) as last_activity_date,
    -- Support summary  
    COALESCE(support_summary.open_tickets, 0) as open_tickets,
    COALESCE(support_summary.total_tickets, 0) as total_tickets,
    -- Purchase summary
    COALESCE(purchase_summary.recent_purchases, 0) as recent_purchases,
    COALESCE(purchase_summary.last_purchase_date, c.join_date) as last_purchase_date,
    -- Risk indicators
    CASE 
        WHEN c.churn_risk_score > 0.7 THEN 'HIGH'
        WHEN c.churn_risk_score > 0.4 THEN 'MEDIUM'
        ELSE 'LOW'
    END as risk_level,
    CASE 
        WHEN c.engagement_score > 0.8 THEN 'HIGH'
        WHEN c.engagement_score > 0.5 THEN 'MEDIUM'  
        ELSE 'LOW'
    END as engagement_level
FROM customers c
LEFT JOIN (
    SELECT 
        customer_id,
        COUNT(*) as activity_count,
        MAX(activity_timestamp) as last_activity_date
    FROM customer_activities 
    WHERE activity_timestamp > DATEADD('day', -30, CURRENT_TIMESTAMP())
    GROUP BY customer_id
) recent_activities ON c.customer_id = recent_activities.customer_id
LEFT JOIN (
    SELECT 
        customer_id,
        COUNT(CASE WHEN status IN ('open', 'pending') THEN 1 END) as open_tickets,
        COUNT(*) as total_tickets
    FROM support_tickets
    GROUP BY customer_id
) support_summary ON c.customer_id = support_summary.customer_id
LEFT JOIN (
    SELECT 
        customer_id,
        COUNT(CASE WHEN purchase_date > DATEADD('day', -90, CURRENT_TIMESTAMP()) THEN 1 END) as recent_purchases,
        MAX(purchase_date) as last_purchase_date
    FROM purchases
    GROUP BY customer_id
) purchase_summary ON c.customer_id = purchase_summary.customer_id;

-- Create additional helper views for quick insights
CREATE OR REPLACE VIEW high_risk_customers AS
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) as customer_name,
    customer_tier,
    churn_risk_score,
    satisfaction_score,
    last_login_date,
    total_spent,
    lifetime_value
FROM customers 
WHERE churn_risk_score > 0.6
ORDER BY churn_risk_score DESC;

CREATE OR REPLACE VIEW customer_value_segments AS
SELECT 
    customer_tier,
    COUNT(*) as customer_count,
    AVG(total_spent) as avg_spent,
    AVG(lifetime_value) as avg_lifetime_value,
    AVG(churn_risk_score) as avg_churn_risk,
    AVG(satisfaction_score) as avg_satisfaction,
    AVG(engagement_score) as avg_engagement
FROM customers
GROUP BY customer_tier
ORDER BY avg_lifetime_value DESC;

-- Test the alternative AI functions
SELECT 'Alternative AI Assistant functions created successfully' AS status,
       'Functions: analyze_customer_ai, get_customer_insights_summary, search_customer_documents_text, generate_customer_report' AS available_functions,
       'Views: customer_360_dashboard, high_risk_customers, customer_value_segments' AS dashboard_views;

-- Sample usage (uncomment to test):
/*
-- Test customer analysis
SELECT analyze_customer_ai('CUST_001');

-- Test insights summary
SELECT * FROM TABLE(get_customer_insights_summary());

-- Test document search
SELECT * FROM TABLE(search_customer_documents_text('billing'));

-- Test customer report
SELECT generate_customer_report('CUST_001');

-- Test dashboard views
SELECT * FROM customer_360_dashboard WHERE risk_level = 'HIGH';
SELECT * FROM high_risk_customers;
SELECT * FROM customer_value_segments;
*/ 