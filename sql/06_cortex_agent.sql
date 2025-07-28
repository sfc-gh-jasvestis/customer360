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

-- Function 2: Get Customer Insights Summary (Fixed to return STRING)
CREATE OR REPLACE FUNCTION get_customer_insights_summary()
RETURNS STRING
LANGUAGE SQL
AS
$$
    SELECT 
        'Customer 360 Business Insights:\n\n' ||
        
        -- High churn risk customers
        'HIGH CHURN RISK CUSTOMERS:\n' ||
        '• Count: ' || (SELECT COUNT(*) FROM customers WHERE churn_risk_score > 0.7)::STRING || '\n' ||
        '• These customers need immediate attention to prevent churn\n' ||
        CASE WHEN (SELECT COUNT(*) FROM customers WHERE churn_risk_score > 0.7) > 0 THEN
            '• Top risk customers: ' || (
                SELECT LISTAGG(CONCAT(first_name, ' ', last_name), ', ') WITHIN GROUP (ORDER BY churn_risk_score DESC)
                FROM (SELECT first_name, last_name, churn_risk_score FROM customers WHERE churn_risk_score > 0.7 LIMIT 3)
            ) || '\n'
        ELSE '• No high-risk customers found\n' END ||
        '\n' ||
        
        -- Low satisfaction customers  
        'LOW SATISFACTION CUSTOMERS:\n' ||
        '• Count: ' || (SELECT COUNT(*) FROM customers WHERE satisfaction_score < 3.5)::STRING || '\n' ||
        '• These customers may need service recovery efforts\n' ||
        CASE WHEN (SELECT COUNT(*) FROM customers WHERE satisfaction_score < 3.5) > 0 THEN
            '• Lowest satisfaction: ' || (
                SELECT LISTAGG(CONCAT(first_name, ' ', last_name, ' (', satisfaction_score::STRING, ')'), ', ') WITHIN GROUP (ORDER BY satisfaction_score ASC)
                FROM (SELECT first_name, last_name, satisfaction_score FROM customers WHERE satisfaction_score < 3.5 LIMIT 3)
            ) || '\n'
        ELSE '• All customers have good satisfaction scores\n' END ||
        '\n' ||
        
        -- High value customers
        'HIGH VALUE CUSTOMERS:\n' ||
        '• Platinum tier count: ' || (SELECT COUNT(*) FROM customers WHERE customer_tier = 'platinum')::STRING || '\n' ||
        '• Total platinum lifetime value: $' || (SELECT COALESCE(SUM(lifetime_value), 0)::STRING FROM customers WHERE customer_tier = 'platinum') || '\n' ||
        CASE WHEN (SELECT COUNT(*) FROM customers WHERE customer_tier = 'platinum') > 0 THEN
            '• Top platinum customers: ' || (
                SELECT LISTAGG(CONCAT(first_name, ' ', last_name), ', ') WITHIN GROUP (ORDER BY lifetime_value DESC)
                FROM (SELECT first_name, last_name, lifetime_value FROM customers WHERE customer_tier = 'platinum' LIMIT 3)
            ) || '\n'
        ELSE '• No platinum customers found\n' END ||
        '\n' ||
        
        -- Recent support activity
        'RECENT SUPPORT ACTIVITY:\n' ||
        '• Open tickets: ' || (SELECT COUNT(*) FROM support_tickets WHERE status IN ('open', 'pending'))::STRING || '\n' ||
        '• Tickets in last 7 days: ' || (SELECT COUNT(*) FROM support_tickets WHERE created_at > DATEADD('day', -7, CURRENT_TIMESTAMP()))::STRING || '\n' ||
        '• Customers with open tickets: ' || (SELECT COUNT(DISTINCT customer_id) FROM support_tickets WHERE status IN ('open', 'pending'))::STRING || '\n' ||
        '\n' ||
        
        -- Overall trends
        'OVERALL TRENDS:\n' ||
        '• Total customers: ' || (SELECT COUNT(*) FROM customers)::STRING || '\n' ||
        '• Average satisfaction: ' || (SELECT ROUND(AVG(satisfaction_score), 2)::STRING FROM customers) || '/5.0\n' ||
        '• Average churn risk: ' || (SELECT ROUND(AVG(churn_risk_score) * 100, 1)::STRING FROM customers) || '%\n' ||
        '• Total revenue: $' || (SELECT COALESCE(SUM(total_spent), 0)::STRING FROM customers) || '\n' ||
        '\n' ||
        
        -- Key recommendations
        'KEY RECOMMENDATIONS:\n' ||
        CASE WHEN (SELECT COUNT(*) FROM customers WHERE churn_risk_score > 0.7) > 0 THEN
            '• URGENT: Contact high-risk customers immediately\n'
        ELSE '' END ||
        CASE WHEN (SELECT COUNT(*) FROM support_tickets WHERE status = 'open') > 0 THEN
            '• Follow up on open support tickets\n'
        ELSE '' END ||
        CASE WHEN (SELECT COUNT(*) FROM customers WHERE satisfaction_score < 3.5) > 0 THEN
            '• Implement service recovery for low-satisfaction customers\n'
        ELSE '' END ||
        '• Continue monitoring customer health metrics\n' ||
        '• Focus on customer retention and satisfaction programs'
$$;

-- Function 3: Search Customer Documents (Alternative to Cortex Search)
CREATE OR REPLACE FUNCTION search_customer_documents_text(search_term STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
    SELECT 
        CASE 
            WHEN (SELECT COUNT(*) FROM customer_documents WHERE UPPER(document_content) LIKE CONCAT('%', UPPER(search_term), '%')) = 0 THEN
                'No documents found matching "' || search_term || '"'
            ELSE
                'Search Results for "' || search_term || '":\n\n' ||
                (
                    SELECT LISTAGG(
                        '• Document: ' || document_title || '\n' ||
                        '  Customer: ' || customer_name || '\n' ||
                        '  Type: ' || document_type || '\n' ||
                        '  Snippet: ' || SUBSTRING(match_snippet, 1, 150) || '...\n',
                        '\n'
                    ) WITHIN GROUP (ORDER BY relevance_score DESC)
                    FROM (
                        SELECT 
                            cd.document_title,
                            CONCAT(c.first_name, ' ', c.last_name) as customer_name,
                            cd.document_type,
                            SUBSTRING(cd.document_content, 
                                GREATEST(1, POSITION(UPPER(search_term) IN UPPER(cd.document_content)) - 50), 
                                200
                            ) as match_snippet,
                            (LENGTH(cd.document_content) - LENGTH(REPLACE(UPPER(cd.document_content), UPPER(search_term), ''))) / LENGTH(search_term) as relevance_score
                        FROM customer_documents cd
                        JOIN customers c ON c.customer_id = cd.customer_id
                        WHERE UPPER(cd.document_content) LIKE CONCAT('%', UPPER(search_term), '%')
                           OR UPPER(cd.document_title) LIKE CONCAT('%', UPPER(search_term), '%')
                        ORDER BY relevance_score DESC
                        LIMIT 5
                    )
                )
        END
$$;

-- Function 4: Generate Customer Summary Report (Simplified)
CREATE OR REPLACE FUNCTION generate_customer_report(customer_id STRING)
RETURNS STRING
LANGUAGE SQL  
AS
$$
    SELECT 
        CASE 
            WHEN (SELECT COUNT(*) FROM customers WHERE customer_id = customer_id) = 0 THEN
                'Customer not found: ' || customer_id
            ELSE
                'CUSTOMER REPORT\n' ||
                '================\n\n' ||
                
                -- Customer basic info
                'CUSTOMER PROFILE:\n' ||
                '• Name: ' || (SELECT CONCAT(first_name, ' ', last_name) FROM customers WHERE customer_id = customer_id) || '\n' ||
                '• ID: ' || customer_id || '\n' ||
                '• Tier: ' || (SELECT customer_tier FROM customers WHERE customer_id = customer_id) || '\n' ||
                '• Status: ' || (SELECT account_status FROM customers WHERE customer_id = customer_id) || '\n' ||
                '• Join Date: ' || (SELECT join_date FROM customers WHERE customer_id = customer_id)::STRING || '\n' ||
                '• Email: ' || (SELECT email FROM customers WHERE customer_id = customer_id) || '\n\n' ||
                
                -- Financial metrics
                'FINANCIAL METRICS:\n' ||
                '• Total Spent: $' || (SELECT COALESCE(total_spent, 0)::STRING FROM customers WHERE customer_id = customer_id) || '\n' ||
                '• Lifetime Value: $' || (SELECT COALESCE(lifetime_value, 0)::STRING FROM customers WHERE customer_id = customer_id) || '\n' ||
                '• Average Order Value: $' || (SELECT COALESCE(ROUND(total_spent / NULLIF((SELECT COUNT(*) FROM purchases WHERE customer_id = customer_id), 0), 2), 0)::STRING FROM customers WHERE customer_id = customer_id) || '\n\n' ||
                
                -- Risk and satisfaction
                'CUSTOMER HEALTH:\n' ||
                '• Churn Risk Score: ' || (SELECT COALESCE(ROUND(churn_risk_score * 100, 1), 0)::STRING FROM customers WHERE customer_id = customer_id) || '%\n' ||
                '• Satisfaction Score: ' || (SELECT COALESCE(satisfaction_score, 0)::STRING FROM customers WHERE customer_id = customer_id) || '/5.0\n' ||
                '• Engagement Score: ' || (SELECT COALESCE(ROUND(engagement_score * 100, 1), 0)::STRING FROM customers WHERE customer_id = customer_id) || '%\n\n' ||
                
                -- Activity summary
                'ACTIVITY SUMMARY:\n' ||
                '• Total Activities: ' || (SELECT COUNT(*) FROM customer_activities WHERE customer_id = customer_id)::STRING || '\n' ||
                '• Recent Activities (30 days): ' || (SELECT COUNT(*) FROM customer_activities WHERE customer_id = customer_id AND activity_timestamp > DATEADD('day', -30, CURRENT_TIMESTAMP()))::STRING || '\n' ||
                '• Last Activity: ' || COALESCE((SELECT MAX(activity_timestamp)::STRING FROM customer_activities WHERE customer_id = customer_id), 'No activities') || '\n\n' ||
                
                -- Support summary
                'SUPPORT SUMMARY:\n' ||
                '• Total Support Tickets: ' || (SELECT COUNT(*) FROM support_tickets WHERE customer_id = customer_id)::STRING || '\n' ||
                '• Open Tickets: ' || (SELECT COUNT(*) FROM support_tickets WHERE customer_id = customer_id AND status IN ('open', 'pending'))::STRING || '\n' ||
                '• Recent Tickets (30 days): ' || (SELECT COUNT(*) FROM support_tickets WHERE customer_id = customer_id AND created_at > DATEADD('day', -30, CURRENT_TIMESTAMP()))::STRING || '\n\n' ||
                
                -- Purchase summary
                'PURCHASE SUMMARY:\n' ||
                '• Total Purchases: ' || (SELECT COUNT(*) FROM purchases WHERE customer_id = customer_id)::STRING || '\n' ||
                '• Recent Purchases (90 days): ' || (SELECT COUNT(*) FROM purchases WHERE customer_id = customer_id AND purchase_date > DATEADD('day', -90, CURRENT_TIMESTAMP()))::STRING || '\n' ||
                '• Last Purchase: ' || COALESCE((SELECT MAX(purchase_date)::STRING FROM purchases WHERE customer_id = customer_id), 'No purchases') || '\n\n' ||
                
                -- Recommendations
                'RECOMMENDATIONS:\n' ||
                CASE WHEN (SELECT churn_risk_score FROM customers WHERE customer_id = customer_id) > 0.7 THEN '• HIGH PRIORITY: This customer is at high risk of churning - immediate outreach recommended\n' ELSE '' END ||
                CASE WHEN (SELECT satisfaction_score FROM customers WHERE customer_id = customer_id) < 3.5 THEN '• Customer satisfaction is low - consider service recovery actions\n' ELSE '' END ||
                CASE WHEN (SELECT COUNT(*) FROM support_tickets WHERE customer_id = customer_id AND status = 'open') > 0 THEN '• Follow up on open support tickets\n' ELSE '' END ||
                CASE WHEN (SELECT customer_tier FROM customers WHERE customer_id = customer_id) = 'bronze' AND (SELECT total_spent FROM customers WHERE customer_id = customer_id) > 5000 THEN '• Consider offering tier upgrade based on spending\n' ELSE '' END ||
                CASE WHEN (SELECT engagement_score FROM customers WHERE customer_id = customer_id) > 0.8 THEN '• High engagement - good candidate for upselling opportunities\n' ELSE '' END ||
                '• Continue monitoring customer health metrics regularly'
        END
$$;

-- Helper Views for Dashboard Access
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
    
    -- Activity metrics
    COALESCE(a.total_activities, 0) as total_activities,
    COALESCE(a.recent_activity_count, 0) as recent_activity_count,
    a.last_activity_date,
    
    -- Support metrics  
    COALESCE(s.total_tickets, 0) as total_tickets,
    COALESCE(s.open_tickets, 0) as open_tickets,
    
    -- Purchase metrics
    COALESCE(p.total_purchases, 0) as total_purchases,
    COALESCE(p.recent_purchases, 0) as recent_purchases,
    
    -- Risk categorization
    CASE 
        WHEN c.churn_risk_score > 0.7 THEN 'HIGH'
        WHEN c.churn_risk_score > 0.4 THEN 'MEDIUM' 
        ELSE 'LOW'
    END as risk_level,
    
    -- Engagement categorization
    CASE
        WHEN c.engagement_score > 0.8 THEN 'HIGH'
        WHEN c.engagement_score > 0.5 THEN 'MEDIUM'
        ELSE 'LOW' 
    END as engagement_level

FROM customers c

LEFT JOIN (
    SELECT 
        customer_id,
        COUNT(*) as total_activities,
        COUNT(CASE WHEN activity_timestamp > DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 1 END) as recent_activity_count,
        MAX(activity_timestamp) as last_activity_date
    FROM customer_activities 
    GROUP BY customer_id
) a ON c.customer_id = a.customer_id

LEFT JOIN (
    SELECT 
        customer_id,
        COUNT(*) as total_tickets,
        COUNT(CASE WHEN status IN ('open', 'pending') THEN 1 END) as open_tickets
    FROM support_tickets
    GROUP BY customer_id  
) s ON c.customer_id = s.customer_id

LEFT JOIN (
    SELECT 
        customer_id,
        COUNT(*) as total_purchases,
        COUNT(CASE WHEN purchase_date > DATEADD('day', -90, CURRENT_TIMESTAMP()) THEN 1 END) as recent_purchases
    FROM purchases
    GROUP BY customer_id
) p ON c.customer_id = p.customer_id;

-- View for High Risk Customers
CREATE OR REPLACE VIEW high_risk_customers AS
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) as customer_name,
    customer_tier,
    churn_risk_score,
    satisfaction_score,
    total_spent,
    lifetime_value,
    last_login_date,
    CASE 
        WHEN churn_risk_score > 0.8 THEN 'CRITICAL'
        WHEN churn_risk_score > 0.7 THEN 'HIGH'
        ELSE 'ELEVATED'
    END as risk_category
FROM customers 
WHERE churn_risk_score > 0.6
ORDER BY churn_risk_score DESC;

-- View for Customer Value Segments
CREATE OR REPLACE VIEW customer_value_segments AS
SELECT 
    customer_tier,
    COUNT(*) as customer_count,
    SUM(total_spent) as total_revenue,
    AVG(total_spent) as avg_spent_per_customer,
    AVG(lifetime_value) as avg_lifetime_value,
    AVG(churn_risk_score) as avg_churn_risk,
    AVG(satisfaction_score) as avg_satisfaction,
    AVG(engagement_score) as avg_engagement
FROM customers
GROUP BY customer_tier
ORDER BY 
    CASE customer_tier 
        WHEN 'platinum' THEN 1
        WHEN 'gold' THEN 2  
        WHEN 'silver' THEN 3
        WHEN 'bronze' THEN 4
        ELSE 5
    END; 