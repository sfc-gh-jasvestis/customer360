-- ============================================================================
-- Customer 360 & AI Assistant - Complete Setup Script (Updated)
-- ============================================================================
-- This script sets up the entire Customer 360 solution from scratch
--
-- Compatible with all Snowflake editions - no premium features required
-- Uses alternative SQL UDFs instead of Cortex services for universal compatibility
-- ============================================================================

SELECT '🚀 Starting Customer 360 & AI Assistant Complete Setup...' as setup_status;

-- ============================================================================
-- Step 1: Database and Warehouse Setup
-- ============================================================================
SELECT '📁 Setting up database and warehouse...' as setup_step;

-- Create database
CREATE DATABASE IF NOT EXISTS customer_360_db;
USE DATABASE customer_360_db;

-- Create schema  
CREATE SCHEMA IF NOT EXISTS public;
USE SCHEMA public;

-- Create warehouse
CREATE WAREHOUSE IF NOT EXISTS customer_360_wh 
WITH 
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = FALSE;

USE WAREHOUSE customer_360_wh;

-- Create stage for file uploads (if needed)
CREATE STAGE IF NOT EXISTS customer_360_stage;

SELECT 'Database and warehouse setup completed' as step_status;

-- ============================================================================  
-- Step 2: Create Tables
-- ============================================================================
SELECT '📋 Creating tables...' as setup_step;

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
    customer_id STRING PRIMARY KEY,
    first_name STRING NOT NULL,
    last_name STRING NOT NULL,
    email STRING,
    phone STRING,
    date_of_birth DATE,
    customer_tier STRING DEFAULT 'bronze',
    account_status STRING DEFAULT 'active',
    join_date DATE DEFAULT CURRENT_DATE(),
    last_login_date TIMESTAMP,
    preferred_communication_channel STRING DEFAULT 'email',
    marketing_opt_in BOOLEAN DEFAULT FALSE,
    newsletter_subscription BOOLEAN DEFAULT FALSE,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state_province STRING,
    postal_code STRING,
    country STRING DEFAULT 'US',
    total_spent DECIMAL(12,2) DEFAULT 0.00,
    lifetime_value DECIMAL(12,2) DEFAULT 0.00,
    credit_limit DECIMAL(10,2) DEFAULT 1000.00,
    churn_risk_score DECIMAL(3,2) DEFAULT 0.00,
    satisfaction_score DECIMAL(2,1) DEFAULT 5.0,
    engagement_score DECIMAL(3,2) DEFAULT 0.50,
    customer_tags VARIANT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Customer Activities table
CREATE TABLE IF NOT EXISTS customer_activities (
    activity_id STRING PRIMARY KEY,
    customer_id STRING NOT NULL,
    activity_type STRING NOT NULL,
    activity_title STRING,
    activity_description STRING,
    activity_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    session_id STRING,
    channel STRING DEFAULT 'web',
    device_type STRING,
    ip_address STRING,
    user_agent STRING,
    page_url STRING,
    referrer_url STRING,
    transaction_amount DECIMAL(10,2),
    product_category STRING,
    campaign_source STRING,
    priority STRING DEFAULT 'medium',
    status STRING DEFAULT 'completed',
    metadata VARIANT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Customer Documents table
CREATE TABLE IF NOT EXISTS customer_documents (
    document_id STRING PRIMARY KEY,
    customer_id STRING NOT NULL,
    document_title STRING NOT NULL,
    document_type STRING NOT NULL,
    document_content STRING,
    file_path STRING,
    file_size_bytes NUMBER,
    mime_type STRING,
    upload_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    last_accessed TIMESTAMP,
    access_count NUMBER DEFAULT 0,
    is_public BOOLEAN DEFAULT FALSE,
    tags VARIANT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Support Tickets table
CREATE TABLE IF NOT EXISTS support_tickets (
    ticket_id STRING PRIMARY KEY,
    customer_id STRING NOT NULL,
    subject STRING NOT NULL,
    description STRING,
    priority STRING DEFAULT 'medium',
    status STRING DEFAULT 'open',
    category STRING,
    assigned_agent STRING,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    resolved_at TIMESTAMP,
    customer_satisfaction_rating DECIMAL(2,1),
    resolution_notes STRING,
    tags VARIANT
);

-- Purchases table
CREATE TABLE IF NOT EXISTS purchases (
    purchase_id STRING PRIMARY KEY,
    customer_id STRING NOT NULL,
    purchase_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    currency STRING DEFAULT 'USD',
    payment_method STRING,
    shipping_address STRING,
    billing_address STRING,
    order_status STRING DEFAULT 'completed',
    items VARIANT,
    discount_amount DECIMAL(8,2) DEFAULT 0.00,
    tax_amount DECIMAL(8,2) DEFAULT 0.00,
    shipping_cost DECIMAL(6,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

SELECT 'Tables created successfully' as step_status;

-- ============================================================================
-- Step 3: Insert Sample Data
-- ============================================================================  
SELECT '📝 Inserting sample data...' as setup_step;

-- Insert customers (without JSON tags first)
INSERT INTO customers (
    customer_id, first_name, last_name, email, phone, date_of_birth,
    customer_tier, account_status, join_date, last_login_date,
    preferred_communication_channel, marketing_opt_in, newsletter_subscription,
    city, state_province, country, total_spent, lifetime_value, credit_limit,
    churn_risk_score, satisfaction_score, engagement_score
) VALUES
('CUST_001', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '+1-555-0101', '1985-03-15',
 'platinum', 'active', '2020-01-15', '2024-01-20 14:30:00',
 'email', TRUE, TRUE, 'San Francisco', 'CA', 'US', 15750.00, 18500.00, 25000.00,
 0.15, 4.8, 0.92),
('CUST_002', 'Michael', 'Chen', 'michael.chen@email.com', '+1-555-0102', '1978-07-22',
 'gold', 'active', '2020-03-10', '2024-01-19 09:45:00',
 'phone', TRUE, FALSE, 'Austin', 'TX', 'US', 8920.00, 12300.00, 15000.00,
 0.45, 3.9, 0.76),
('CUST_003', 'Emma', 'Davis', 'emma.davis@email.com', '+1-555-0103', '1992-11-08',
 'silver', 'active', '2021-06-20', '2024-01-18 16:20:00',
 'email', FALSE, TRUE, 'Seattle', 'WA', 'US', 3450.00, 5200.00, 8000.00,
 0.78, 2.1, 0.34),
('CUST_004', 'James', 'Wilson', 'james.wilson@email.com', '+1-555-0104', '1988-05-03',
 'bronze', 'active', '2023-09-05', '2024-01-21 11:15:00',
 'sms', TRUE, TRUE, 'Denver', 'CO', 'US', 890.00, 1200.00, 3000.00,
 0.22, 4.5, 0.68),
('CUST_005', 'Lisa', 'Rodriguez', 'lisa.rodriguez@email.com', '+1-555-0105', '1975-12-18',
 'platinum', 'active', '2019-05-08', '2024-01-22 13:00:00',
 'email', TRUE, TRUE, 'Miami', 'FL', 'US', 22100.00, 28900.00, 50000.00,
 0.08, 4.9, 0.95);

-- Update customers with JSON tags
UPDATE customers SET customer_tags = PARSE_JSON('["high-value", "tech-enthusiast", "early-adopter", "loyal-customer"]') WHERE customer_id = 'CUST_001';
UPDATE customers SET customer_tags = PARSE_JSON('["frequent-buyer", "mobile-user", "deal-seeker"]') WHERE customer_id = 'CUST_002';
UPDATE customers SET customer_tags = PARSE_JSON('["at-risk", "support-heavy", "price-sensitive"]') WHERE customer_id = 'CUST_003';
UPDATE customers SET customer_tags = PARSE_JSON('["new-customer", "potential-growth", "social-media-active"]') WHERE customer_id = 'CUST_004';
UPDATE customers SET customer_tags = PARSE_JSON('["vip", "enterprise", "long-term", "advocate"]') WHERE customer_id = 'CUST_005';

-- Insert customer activities
INSERT INTO customer_activities (
    activity_id, customer_id, activity_type, activity_title, activity_description,
    activity_timestamp, channel, device_type, transaction_amount, priority
) VALUES
('ACT_001', 'CUST_001', 'purchase', 'Premium Software License Purchase', 'Purchased annual premium license', '2024-01-20 10:30:00', 'web', 'desktop', 599.00, 'high'),
('ACT_002', 'CUST_001', 'login', 'Account Login', 'Logged into customer portal', '2024-01-20 14:30:00', 'web', 'mobile', NULL, 'low'),
('ACT_003', 'CUST_002', 'support', 'Shipping Inquiry', 'Asked about delayed shipment status', '2024-01-19 09:45:00', 'phone', 'phone', NULL, 'medium'),
('ACT_004', 'CUST_002', 'purchase', 'Hardware Accessories', 'Bought charging cables and case', '2024-01-18 15:20:00', 'mobile', 'mobile', 89.99, 'medium'),
('ACT_005', 'CUST_003', 'support', 'Billing Dispute', 'Questioned charges on recent bill', '2024-01-18 16:20:00', 'email', 'desktop', NULL, 'high'),
('ACT_006', 'CUST_003', 'login', 'Account Access', 'Multiple failed login attempts', '2024-01-17 12:00:00', 'web', 'mobile', NULL, 'medium'),
('ACT_007', 'CUST_004', 'registration', 'Account Creation', 'New customer registration completed', '2023-09-05 14:15:00', 'web', 'desktop', NULL, 'low'),
('ACT_008', 'CUST_004', 'purchase', 'First Purchase', 'Welcome package and starter kit', '2023-09-06 10:30:00', 'web', 'desktop', 149.99, 'medium'),
('ACT_009', 'CUST_005', 'purchase', 'Enterprise Solution', 'Upgraded to enterprise tier', '2024-01-22 13:00:00', 'phone', 'phone', 2500.00, 'high'),
('ACT_010', 'CUST_005', 'support', 'Implementation Support', 'Requested technical implementation assistance', '2024-01-22 14:30:00', 'email', 'desktop', NULL, 'high'),
('ACT_011', 'CUST_001', 'engagement', 'Newsletter Interaction', 'Clicked product announcement link', '2024-01-19 08:15:00', 'email', 'mobile', NULL, 'low'),
('ACT_012', 'CUST_002', 'support', 'Feature Request', 'Requested new dashboard features', '2024-01-16 11:00:00', 'web', 'desktop', NULL, 'low'),
('ACT_013', 'CUST_003', 'cart_abandonment', 'Abandoned Shopping Cart', 'Left items in cart without purchasing', '2024-01-15 19:45:00', 'web', 'mobile', NULL, 'medium'),
('ACT_014', 'CUST_004', 'engagement', 'Social Media Interaction', 'Shared product review on social media', '2024-01-14 16:30:00', 'social', 'mobile', NULL, 'low'),
('ACT_015', 'CUST_005', 'login', 'Admin Portal Access', 'Accessed enterprise admin dashboard', '2024-01-21 09:00:00', 'web', 'desktop', NULL, 'low');

-- Insert customer documents  
INSERT INTO customer_documents (
    document_id, customer_id, document_title, document_type, document_content
) VALUES
('DOC_001', 'CUST_002', 'Shipping Delay Correspondence', 'support_email', 'Dear Michael, We apologize for the delay in your recent order shipment. Due to weather conditions, your package has been delayed by 2 business days. We have applied a shipping credit to your account and upgraded you to expedited shipping at no charge. Your tracking number is TR123456789. Thank you for your patience. Best regards, Customer Service Team'),
('DOC_002', 'CUST_003', 'Billing Dispute Case', 'support_ticket', 'Customer Emma Davis has disputed a charge of $89.99 on her account dated January 15, 2024. She claims she did not authorize this transaction. Investigation shows the charge was for premium feature activation that was clicked during her session. Customer was not aware this was a paid feature. Recommending refund and UI improvement to make paid features more obvious.'),
('DOC_003', 'CUST_005', 'Enterprise Contract Agreement', 'contract', 'Enterprise Service Agreement between Customer 360 Inc. and Lisa Rodriguez (Rodriguez Consulting LLC). This agreement covers premium support, dedicated account management, custom integrations, and priority feature development. Contract value: $25,000 annually. Effective date: January 1, 2024. Terms include 99.9% uptime SLA, 4-hour response time for critical issues, and quarterly business reviews.'),
('DOC_004', 'CUST_001', 'Product Feedback Survey', 'feedback', 'Overall rating: 5/5 stars. Sarah Johnson feedback: "Excellent product with intuitive interface. Love the new dashboard features and mobile app. The customer support team is very responsive. Would definitely recommend to other businesses. Suggestions: Add more customization options and integrate with more third-party tools. Very satisfied with the premium tier benefits."');

-- Insert support tickets
INSERT INTO support_tickets (
    ticket_id, customer_id, subject, description, priority, status, category, assigned_agent, customer_satisfaction_rating
) VALUES
('TICK_001', 'CUST_002', 'Delayed Shipment Inquiry', 'Customer asking about delayed package delivery', 'medium', 'resolved', 'shipping', 'Agent_Sarah', 4.0),
('TICK_002', 'CUST_003', 'Billing Dispute - Unauthorized charge', 'Customer disputes $89.99 charge, claims not authorized', 'high', 'open', 'billing', 'Agent_Mike', NULL),
('TICK_003', 'CUST_005', 'Enterprise Implementation Support', 'Need help with enterprise tier setup and configuration', 'high', 'in_progress', 'technical', 'Agent_Lisa', NULL);

-- Insert purchases
INSERT INTO purchases (
    purchase_id, customer_id, purchase_date, total_amount, currency, payment_method, order_status
) VALUES
('PUR_001', 'CUST_001', '2024-01-20', 599.00, 'USD', 'credit_card', 'completed'),
('PUR_002', 'CUST_002', '2024-01-18', 89.99, 'USD', 'paypal', 'completed'),
('PUR_003', 'CUST_004', '2023-09-06', 149.99, 'USD', 'credit_card', 'completed'),
('PUR_004', 'CUST_005', '2024-01-22', 2500.00, 'USD', 'bank_transfer', 'completed'),
('PUR_005', 'CUST_001', '2023-12-15', 299.00, 'USD', 'credit_card', 'completed');

-- Update purchases with JSON items
UPDATE purchases SET items = PARSE_JSON('[{"name": "Premium License", "quantity": 1, "price": 599.00}]') WHERE purchase_id = 'PUR_001';
UPDATE purchases SET items = PARSE_JSON('[{"name": "USB Cable", "quantity": 2, "price": 24.99}, {"name": "Phone Case", "quantity": 1, "price": 39.99}]') WHERE purchase_id = 'PUR_002';
UPDATE purchases SET items = PARSE_JSON('[{"name": "Starter Kit", "quantity": 1, "price": 149.99}]') WHERE purchase_id = 'PUR_003';
UPDATE purchases SET items = PARSE_JSON('[{"name": "Enterprise Upgrade", "quantity": 1, "price": 2500.00}]') WHERE purchase_id = 'PUR_004';
UPDATE purchases SET items = PARSE_JSON('[{"name": "Add-on Features", "quantity": 1, "price": 299.00}]') WHERE purchase_id = 'PUR_005';

SELECT 'Sample data inserted successfully' as step_status;

-- ============================================================================
-- Step 4: Create Search Views (Alternative to Cortex Search)
-- ============================================================================
SELECT '🔍 Creating search capabilities...' as setup_step;

-- Searchable documents view
CREATE OR REPLACE VIEW searchable_documents AS
SELECT 
    cd.document_id,
    cd.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    cd.document_title,
    cd.document_type,
    cd.document_content,
    CONCAT(
        COALESCE(cd.document_title, ''), ' ',
        COALESCE(cd.document_content, ''), ' ',
        COALESCE(c.first_name, ''), ' ',
        COALESCE(c.last_name, ''), ' ',
        COALESCE(cd.document_type, '')
    ) as searchable_text,
    cd.upload_timestamp,
    cd.created_at
FROM customer_documents cd
JOIN customers c ON c.customer_id = cd.customer_id;

-- Searchable activities view  
CREATE OR REPLACE VIEW searchable_activities AS
SELECT 
    ca.activity_id,
    ca.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    ca.activity_type,
    ca.activity_title,
    ca.activity_description,
    CONCAT(
        COALESCE(ca.activity_title, ''), ' ',
        COALESCE(ca.activity_description, ''), ' ',
        COALESCE(ca.activity_type, ''), ' ',
        COALESCE(c.first_name, ''), ' ',
        COALESCE(c.last_name, '')
    ) as searchable_text,
    ca.activity_timestamp,
    ca.created_at
FROM customer_activities ca
JOIN customers c ON c.customer_id = ca.customer_id;

-- Support related content view
CREATE OR REPLACE VIEW support_related_content AS
SELECT 
    st.ticket_id as content_id,
    st.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    'support_ticket' as content_type,
    st.subject as title,
    st.description as content,
    st.priority,
    st.status,
    st.created_at
FROM support_tickets st
JOIN customers c ON c.customer_id = st.customer_id;

-- Billing related content view
CREATE OR REPLACE VIEW billing_related_content AS
SELECT 
    p.purchase_id as content_id,
    p.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    'purchase' as content_type,
    CONCAT('Purchase - $', p.total_amount) as title,
    CONCAT('Purchase of $', p.total_amount, ' on ', p.purchase_date, ' via ', p.payment_method) as content,
    p.order_status as status,
    p.created_at
FROM purchases p
JOIN customers c ON c.customer_id = p.customer_id;

SELECT 'Search views created successfully' as step_status;

-- ============================================================================
-- Step 5: Create AI Analysis Functions (Alternative to Cortex Agents)
-- ============================================================================
SELECT '🤖 Creating AI analysis functions...' as setup_step;

-- Function 1: Customer Analysis
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

-- Function 3: Search Customer Documents (Fixed to return STRING)
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

-- Function 4: Generate Customer Report (Fixed to return STRING)
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

SELECT 'AI analysis functions created successfully' as step_status;

-- ============================================================================
-- Step 6: Create Dashboard Views
-- ============================================================================
SELECT '📊 Creating dashboard views...' as setup_step;

-- Customer 360 Dashboard View
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

-- High Risk Customers View
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

-- Customer Value Segments View
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

SELECT 'Dashboard views created successfully' as step_status;

-- ============================================================================
-- Final Status Report
-- ============================================================================
SELECT '✅ SETUP COMPLETE!' as final_status;

SELECT 
    'Customer 360 & AI Assistant Setup Summary' as summary_title,
    CURRENT_TIMESTAMP() as completion_time;

-- Count created objects
SELECT 
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'PUBLIC' AND table_type = 'BASE TABLE') as tables_created,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.VIEWS WHERE table_schema = 'PUBLIC') as views_created,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.FUNCTIONS WHERE function_schema = 'PUBLIC') as functions_created,
    (SELECT COUNT(*) FROM customers) as sample_customers,
    (SELECT COUNT(*) FROM customer_activities) as sample_activities;

SELECT '🎉 Your Customer 360 & AI Assistant is ready!' as success_message,
       'Next step: Deploy to Streamlit in Snowflake using customer_360_sis_app.py' as next_steps; 