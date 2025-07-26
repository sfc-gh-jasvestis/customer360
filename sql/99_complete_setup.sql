-- =========================================
-- Customer 360 Demo - Complete Setup Script
-- =========================================
-- This script sets up the entire demo from scratch
-- Compatible with all Snowflake editions - no premium features required

-- ===============================
-- PREREQUISITES CHECK
-- ===============================

-- Check if user has required permissions
SELECT 
    CURRENT_ROLE() as current_role,
    CURRENT_USER() as current_user,
    CURRENT_ACCOUNT() as account_name,
    'Starting Customer 360 Demo Setup...' as status;

-- ===============================
-- STEP 1: DATABASE SETUP
-- ===============================

SELECT '🏗️  Setting up database and warehouse...' AS step_status;

-- Create database and warehouse
CREATE DATABASE IF NOT EXISTS customer_360_db;
USE DATABASE customer_360_db;

-- Create warehouse for the demo
CREATE OR REPLACE WAREHOUSE customer_360_wh WITH
    WAREHOUSE_SIZE='SMALL'
    AUTO_SUSPEND = 300  -- 5 minutes
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Customer 360 & AI Assistant demo';

USE WAREHOUSE customer_360_wh;

-- Create schema for our demo data
CREATE SCHEMA IF NOT EXISTS public;
USE SCHEMA public;

-- Create stage for file uploads (if needed)
CREATE OR REPLACE STAGE customer_360_stage
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for Customer 360 demo files';

SELECT '✅ Database setup completed' AS step_status;

-- ===============================
-- STEP 2: CREATE TABLES
-- ===============================

SELECT '📊 Creating database tables...' AS step_status;

-- Main customer profiles table
CREATE OR REPLACE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(10),
    
    -- Address information
    street_address VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Account information
    account_status VARCHAR(20) DEFAULT 'active',
    customer_tier VARCHAR(20) DEFAULT 'bronze', -- bronze, silver, gold, platinum
    join_date DATE NOT NULL,
    last_login_date TIMESTAMP,
    
    -- Financial metrics
    total_spent DECIMAL(12,2) DEFAULT 0.00,
    lifetime_value DECIMAL(12,2) DEFAULT 0.00,
    credit_limit DECIMAL(10,2),
    
    -- Behavioral metrics
    churn_risk_score DECIMAL(3,2) DEFAULT 0.00, -- 0.00 to 1.00
    satisfaction_score DECIMAL(2,1), -- 1.0 to 5.0
    engagement_score DECIMAL(3,2) DEFAULT 0.00,
    
    -- Preferences
    preferred_communication_channel VARCHAR(20) DEFAULT 'email',
    marketing_opt_in BOOLEAN DEFAULT TRUE,
    newsletter_subscription BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    -- Tags for segmentation (JSON format)
    customer_tags VARIANT
);

-- Customer interactions and activities
CREATE OR REPLACE TABLE customer_activities (
    activity_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    activity_type VARCHAR(50) NOT NULL, -- purchase, login, support_ticket, email_open, etc.
    activity_title VARCHAR(255),
    activity_description TEXT,
    
    -- Activity details
    activity_timestamp TIMESTAMP NOT NULL,
    channel VARCHAR(50), -- web, mobile, phone, store, email
    device_type VARCHAR(50),
    ip_address VARCHAR(45),
    
    -- Transaction details (if applicable)
    transaction_amount DECIMAL(12,2),
    transaction_currency VARCHAR(3) DEFAULT 'USD',
    product_category VARCHAR(100),
    
    -- Priority and status
    priority VARCHAR(20) DEFAULT 'low', -- low, medium, high, urgent
    status VARCHAR(20) DEFAULT 'completed',
    
    -- Additional context (JSON format)
    activity_metadata VARIANT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Customer support tickets
CREATE OR REPLACE TABLE support_tickets (
    ticket_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    
    -- Ticket details
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100), -- billing, technical, product, shipping, etc.
    priority VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(20) DEFAULT 'open', -- open, in_progress, resolved, closed
    
    -- Assignment
    assigned_agent_id VARCHAR(50),
    assigned_team VARCHAR(100),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    first_response_at TIMESTAMP,
    resolved_at TIMESTAMP,
    closed_at TIMESTAMP,
    
    -- Metrics
    resolution_time_hours INTEGER,
    customer_satisfaction_rating INTEGER, -- 1-5
    
    -- Additional data
    ticket_metadata VARIANT,
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Customer purchases and transactions
CREATE OR REPLACE TABLE purchases (
    purchase_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50),
    
    -- Purchase details
    purchase_date TIMESTAMP NOT NULL,
    product_id VARCHAR(50),
    product_name VARCHAR(255),
    product_category VARCHAR(100),
    product_subcategory VARCHAR(100),
    
    -- Financial details
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- Fulfillment
    shipping_address TEXT,
    shipping_method VARCHAR(100),
    tracking_number VARCHAR(100),
    delivery_date DATE,
    
    -- Status
    order_status VARCHAR(50) DEFAULT 'pending',
    payment_status VARCHAR(50) DEFAULT 'pending',
    fulfillment_status VARCHAR(50) DEFAULT 'pending',
    
    -- Additional data
    purchase_metadata VARIANT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Customer communication preferences and history
CREATE OR REPLACE TABLE customer_communications (
    communication_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    
    -- Communication details
    communication_type VARCHAR(50) NOT NULL, -- email, sms, phone, push_notification
    direction VARCHAR(10) NOT NULL, -- inbound, outbound
    subject VARCHAR(255),
    message_content TEXT,
    
    -- Engagement metrics
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    opened_at TIMESTAMP,
    clicked_at TIMESTAMP,
    responded_at TIMESTAMP,
    
    -- Campaign information
    campaign_id VARCHAR(50),
    campaign_name VARCHAR(255),
    template_id VARCHAR(50),
    
    -- Status
    status VARCHAR(50) DEFAULT 'sent',
    
    -- Additional data
    communication_metadata VARIANT,
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Customer documents and files (for text search)
CREATE OR REPLACE TABLE customer_documents (
    document_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    
    -- Document details
    document_title VARCHAR(255) NOT NULL,
    document_type VARCHAR(100), -- contract, transcript, note, report
    document_content TEXT NOT NULL, -- This will be searchable via text functions
    file_path VARCHAR(500),
    file_size_bytes INTEGER,
    
    -- Classification
    document_category VARCHAR(100),
    document_tags VARIANT,
    
    -- Metadata
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    -- Search optimization
    content_summary TEXT,
    key_topics VARIANT,
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

SELECT '✅ Tables created successfully' AS step_status;

-- ===============================
-- STEP 3: INSERT SAMPLE DATA
-- ===============================

SELECT '📝 Loading sample data...' AS step_status;

-- Clear any existing data
DELETE FROM customer_documents WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');
DELETE FROM customer_communications WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');
DELETE FROM purchases WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');
DELETE FROM support_tickets WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');
DELETE FROM customer_activities WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');
DELETE FROM customers WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');

-- Step 1: Insert customers WITHOUT JSON data
INSERT INTO customers (
    customer_id, first_name, last_name, email, phone, date_of_birth, gender,
    street_address, city, state_province, postal_code, country,
    account_status, customer_tier, join_date, last_login_date,
    total_spent, lifetime_value, credit_limit,
    churn_risk_score, satisfaction_score, engagement_score,
    preferred_communication_channel, marketing_opt_in, newsletter_subscription
) VALUES
('CUST_001', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '+1-555-0123', '1985-03-15', 'Female',
 '123 Market St', 'San Francisco', 'CA', '94102', 'USA',
 'active', 'platinum', '2022-01-15', '2024-01-15 10:00:00',
 47580.50, 65000.00, 50000.00,
 0.15, 4.8, 0.92,
 'email', TRUE, TRUE),

('CUST_002', 'Michael', 'Chen', 'michael.chen@email.com', '+1-555-0456', '1978-07-22', 'Male',
 '456 Broadway', 'New York', 'NY', '10013', 'USA',
 'active', 'gold', '2022-08-10', '2024-01-14 15:30:00',
 23450.75, 35000.00, 25000.00,
 0.35, 4.2, 0.68,
 'sms', TRUE, FALSE),

('CUST_003', 'Emma', 'Davis', 'emma.davis@email.com', '+1-555-0789', '1990-11-08', 'Female',
 '789 Oak Ave', 'Austin', 'TX', '78701', 'USA',
 'active', 'silver', '2023-02-20', '2024-01-05 08:15:00',
 8920.25, 15000.00, 10000.00,
 0.78, 3.1, 0.42,
 'email', FALSE, FALSE),

('CUST_004', 'James', 'Wilson', 'james.wilson@email.com', '+1-555-0321', '1982-05-30', 'Male',
 '321 Pine St', 'Seattle', 'WA', '98101', 'USA',
 'active', 'bronze', '2024-01-05', '2024-01-15 09:00:00',
 1580.99, 5000.00, 5000.00,
 0.25, 4.5, 0.78,
 'phone', TRUE, TRUE),

('CUST_005', 'Lisa', 'Rodriguez', 'lisa.rodriguez@enterprise.com', '+1-555-0987', '1975-09-12', 'Female',
 '555 Enterprise Blvd', 'Los Angeles', 'CA', '90210', 'USA',
 'active', 'platinum', '2021-06-01', '2024-01-15 06:00:00',
 125000.00, 200000.00, 100000.00,
 0.08, 4.9, 0.95,
 'email', TRUE, TRUE);

-- Step 2: Update customers with JSON tags
UPDATE customers SET customer_tags = PARSE_JSON('["high-value", "tech-enthusiast", "early-adopter", "loyal-customer"]') WHERE customer_id = 'CUST_001';
UPDATE customers SET customer_tags = PARSE_JSON('["frequent-buyer", "mobile-user", "price-sensitive"]') WHERE customer_id = 'CUST_002';
UPDATE customers SET customer_tags = PARSE_JSON('["at-risk", "support-needed", "occasional-buyer"]') WHERE customer_id = 'CUST_003';
UPDATE customers SET customer_tags = PARSE_JSON('["new-customer", "onboarding", "high-potential"]') WHERE customer_id = 'CUST_004';
UPDATE customers SET customer_tags = PARSE_JSON('["enterprise", "vip", "decision-maker", "high-value"]') WHERE customer_id = 'CUST_005';

-- Insert sample activities (first few for brevity)
INSERT INTO customer_activities (
    activity_id, customer_id, activity_type, activity_title, activity_description,
    activity_timestamp, channel, device_type, ip_address,
    transaction_amount, transaction_currency, product_category,
    priority, status
) VALUES
('ACT_001', 'CUST_001', 'purchase', 'Premium Software License', 'Purchased annual premium license with advanced features',
 '2024-01-15 08:00:00', 'web', 'desktop', '192.168.1.100',
 2499.99, 'USD', 'Software',
 'high', 'completed'),

('ACT_002', 'CUST_001', 'login', 'Dashboard Access', 'User logged into customer dashboard',
 '2024-01-15 06:00:00', 'web', 'desktop', '192.168.1.100',
 NULL, 'USD', NULL,
 'low', 'completed'),

('ACT_003', 'CUST_002', 'email_open', 'Newsletter Campaign', 'Opened monthly product update newsletter',
 '2024-01-14 12:00:00', 'email', 'mobile', '10.0.0.50',
 NULL, 'USD', 'Marketing',
 'low', 'completed');

-- Update activities with JSON metadata
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"order_id": "ORD_2024_001", "payment_method": "credit_card"}') WHERE activity_id = 'ACT_001';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"session_duration": 1200}') WHERE activity_id = 'ACT_002';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"campaign_id": "CAMP_2024_001", "open_time": 15}') WHERE activity_id = 'ACT_003';

-- Insert sample documents for search
INSERT INTO customer_documents (
    document_id, customer_id, document_title, document_type, document_content,
    document_category, created_by, created_at,
    content_summary
) VALUES
('DOC_001', 'CUST_002', 'Shipping Delay Support Conversation', 'transcript',
'Customer: Hi, I placed an order last week but haven''t received any shipping updates. Can you help?

Agent: I''d be happy to help you track your order. Let me look that up for you. Can you provide your order number?

Customer: Sure, it''s ORD_2024_002.

Agent: Thank you. I can see your order here. It looks like there was a delay at our fulfillment center due to high demand. Your order has now been processed and shipped. You should receive tracking information within the next hour.

Customer: That''s frustrating, but I appreciate the update. Will there be any compensation for the delay?

Agent: Absolutely. I''ve applied a $50 credit to your account for the inconvenience. You''ll see this reflected in your next billing cycle.

Customer: Thank you, that''s very helpful. I appreciate your assistance.',
 'support', 'support_agent_001', '2024-01-14 10:00:00',
 'Customer inquiry about shipping delay, resolved with account credit');

-- Update document with JSON data
UPDATE customer_documents SET document_tags = PARSE_JSON('["shipping", "delay", "escalation", "credit"]') WHERE document_id = 'DOC_001';
UPDATE customer_documents SET key_topics = PARSE_JSON('["shipping_delays", "customer_compensation", "service_recovery"]') WHERE document_id = 'DOC_001';

SELECT '✅ Sample data loaded successfully' AS step_status;

-- ===============================
-- STEP 4: CREATE SEARCH AND AI FUNCTIONS
-- ===============================

SELECT '🔍 Creating search and AI functions...' AS step_status;

-- Create searchable views
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

-- Simple document search function
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

-- Customer analysis function
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
                CASE WHEN (SELECT COUNT(*) FROM support_tickets WHERE customer_id = customer_id AND status IN ('open', 'pending')) > 0 THEN 'Open support tickets' END
            )
        ),
        'recommendations', ARRAY_CONSTRUCT(
            CASE WHEN (SELECT churn_risk_score FROM customers WHERE customer_id = customer_id) > 0.6 THEN 'Immediate retention outreach recommended' END,
            CASE WHEN (SELECT COUNT(*) FROM support_tickets WHERE customer_id = customer_id AND status = 'open') > 0 THEN 'Follow up on open support tickets' END,
            CASE WHEN (SELECT engagement_score FROM customers WHERE customer_id = customer_id) > 0.8 THEN 'Good candidate for upselling' END
        )
    )::VARIANT
$$;

-- Create dashboard views
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
) support_summary ON c.customer_id = support_summary.customer_id;

-- High-risk customers view
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

SELECT '✅ Search and AI functions created successfully' AS step_status;

-- ===============================
-- STEP 5: VERIFICATION
-- ===============================

SELECT '🧪 Running verification tests...' AS step_status;

-- Test data integrity
SELECT 
    'Data Integrity Check' as test_name,
    COUNT(*) as customer_count,
    ROUND(AVG(churn_risk_score), 3) as avg_churn_risk,
    COUNT(DISTINCT customer_tier) as tier_count
FROM customers;

-- Test search function
SELECT 
    'Search Function Test' as test_name,
    COUNT(*) as search_results
FROM TABLE(search_documents_simple('shipping'));

-- Test AI analysis function
SELECT 
    'AI Analysis Test' as test_name,
    'Customer analysis completed' as result
FROM (SELECT analyze_customer_ai('CUST_001')) LIMIT 1;

-- Test dashboard views
SELECT 
    'Dashboard Views Test' as test_name,
    COUNT(*) as dashboard_records
FROM customer_360_dashboard;

SELECT 
    'High Risk Customers Test' as test_name,
    COUNT(*) as high_risk_count
FROM high_risk_customers;

-- ===============================
-- COMPLETION SUMMARY
-- ===============================

SELECT 
    '🎉 Demo setup completed successfully!' AS status,
    'Database: customer_360_db' AS database_info,
    'Warehouse: customer_360_wh' AS warehouse_info,
    (SELECT COUNT(*) FROM customers) AS customers_loaded,
    (SELECT COUNT(*) FROM customer_activities) AS activities_loaded,
    (SELECT COUNT(*) FROM customer_documents) AS documents_loaded,
    CURRENT_TIMESTAMP() AS setup_completed_at,
    'Ready for demo and Streamlit deployment!' AS next_steps;

-- Final status
SELECT '🎉 Customer 360 & AI Assistant Demo setup completed!' AS final_status;
SELECT '📋 Demo Features Available:' AS features_header;
SELECT '   ✅ Customer 360 Dashboard' AS feature_1;
SELECT '   ✅ AI-Powered Customer Analysis' AS feature_2;
SELECT '   ✅ Document Search (Text-based)' AS feature_3;
SELECT '   ✅ Risk Assessment & Insights' AS feature_4;
SELECT '   ✅ High-Risk Customer Identification' AS feature_5;
SELECT '   ✅ Compatible with all Snowflake editions' AS feature_6;

-- Show created objects
SHOW TABLES;
SHOW VIEWS;
SHOW USER FUNCTIONS; 