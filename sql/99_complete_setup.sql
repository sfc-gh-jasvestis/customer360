-- =========================================
-- Customer 360 Demo - Complete Setup Script
-- =========================================
-- This script sets up the entire demo from scratch
-- Run this after cleanup to deploy everything

-- ===============================
-- PREREQUISITES CHECK
-- ===============================

-- Check if user has required permissions
SELECT 
    CURRENT_ROLE() as current_role,
    CURRENT_USER() as current_user,
    CURRENT_ACCOUNT() as account_name;

-- Verify Cortex access (this should not error)
-- SELECT SNOWFLAKE.CORTEX.COMPLETE('llama2-7b-chat', 'Hello, this is a test');

-- ===============================
-- STEP 1: DATABASE SETUP
-- ===============================

PRINT '🏗️  Setting up database and warehouse...';

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

-- Create stage for semantic model file
CREATE OR REPLACE STAGE customer_360_semantic_model_stage;

PRINT '✅ Database setup completed';

-- ===============================
-- STEP 2: CREATE TABLES
-- ===============================

PRINT '📊 Creating database tables...';

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

-- Customer documents and files (for Cortex Search)
CREATE OR REPLACE TABLE customer_documents (
    document_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    
    -- Document details
    document_title VARCHAR(255) NOT NULL,
    document_type VARCHAR(100), -- contract, transcript, note, report
    document_content TEXT NOT NULL, -- This will be indexed by Cortex Search
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

PRINT '✅ Tables created successfully';

-- ===============================
-- STEP 3: CREATE INDEXES AND VIEWS
-- ===============================

PRINT '🔍 Creating indexes and views...';

-- Customer activities indexes
CREATE INDEX IF NOT EXISTS idx_activities_customer_timestamp ON customer_activities(customer_id, activity_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_activities_type ON customer_activities(activity_type);
CREATE INDEX IF NOT EXISTS idx_activities_timestamp ON customer_activities(activity_timestamp DESC);

-- Support tickets indexes
CREATE INDEX IF NOT EXISTS idx_tickets_customer ON support_tickets(customer_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_created ON support_tickets(created_at DESC);

-- Purchases indexes
CREATE INDEX IF NOT EXISTS idx_purchases_customer ON purchases(customer_id);
CREATE INDEX IF NOT EXISTS idx_purchases_date ON purchases(purchase_date DESC);
CREATE INDEX IF NOT EXISTS idx_purchases_category ON purchases(product_category);

-- Communications indexes
CREATE INDEX IF NOT EXISTS idx_communications_customer ON customer_communications(customer_id);
CREATE INDEX IF NOT EXISTS idx_communications_type ON customer_communications(communication_type);

-- Documents indexes (for Cortex Search)
CREATE INDEX IF NOT EXISTS idx_documents_customer ON customer_documents(customer_id);
CREATE INDEX IF NOT EXISTS idx_documents_type ON customer_documents(document_type);

-- Customer 360 summary view
CREATE OR REPLACE VIEW customer_360_summary AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.customer_tier,
    c.account_status,
    c.join_date,
    c.last_login_date,
    c.total_spent,
    c.lifetime_value,
    c.churn_risk_score,
    c.satisfaction_score,
    c.engagement_score,
    
    -- Activity metrics
    COUNT(DISTINCT a.activity_id) as total_activities,
    MAX(a.activity_timestamp) as last_activity_date,
    
    -- Purchase metrics
    COUNT(DISTINCT p.purchase_id) as total_purchases,
    COALESCE(SUM(p.total_amount), 0) as total_purchase_amount,
    MAX(p.purchase_date) as last_purchase_date,
    
    -- Support metrics
    COUNT(DISTINCT s.ticket_id) as total_support_tickets,
    COUNT(DISTINCT CASE WHEN s.status = 'open' THEN s.ticket_id END) as open_tickets,
    AVG(s.customer_satisfaction_rating) as avg_support_satisfaction
    
FROM customers c
LEFT JOIN customer_activities a ON c.customer_id = a.customer_id
LEFT JOIN purchases p ON c.customer_id = p.customer_id
LEFT JOIN support_tickets s ON c.customer_id = s.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email, c.customer_tier,
    c.account_status, c.join_date, c.last_login_date, c.total_spent,
    c.lifetime_value, c.churn_risk_score, c.satisfaction_score, c.engagement_score;

-- Activity summary view
CREATE OR REPLACE VIEW recent_customer_activities AS
SELECT 
    customer_id,
    activity_type,
    activity_title,
    activity_description,
    activity_timestamp,
    channel,
    priority,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY activity_timestamp DESC) as activity_rank
FROM customer_activities
WHERE activity_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP());

PRINT '✅ Indexes and views created';

-- ===============================
-- STEP 4: INSERT SAMPLE DATA
-- ===============================

PRINT '📝 Loading sample data...';

-- Insert sample customers
INSERT INTO customers (
    customer_id, first_name, last_name, email, phone, date_of_birth, gender,
    street_address, city, state_province, postal_code, country,
    account_status, customer_tier, join_date, last_login_date,
    total_spent, lifetime_value, credit_limit,
    churn_risk_score, satisfaction_score, engagement_score,
    preferred_communication_channel, marketing_opt_in, newsletter_subscription,
    customer_tags
) VALUES
('CUST_001', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '+1-555-0123', '1985-03-15', 'Female',
 '123 Market St', 'San Francisco', 'CA', '94102', 'USA',
 'active', 'platinum', '2022-01-15', CURRENT_TIMESTAMP() - INTERVAL '2 hours',
 47580.50, 65000.00, 50000.00,
 0.15, 4.8, 0.92,
 'email', TRUE, TRUE,
 '["high-value", "tech-enthusiast", "early-adopter", "loyal-customer"]'::VARIANT),

('CUST_002', 'Michael', 'Chen', 'michael.chen@email.com', '+1-555-0456', '1978-07-22', 'Male',
 '456 Broadway', 'New York', 'NY', '10013', 'USA',
 'active', 'gold', '2022-08-10', CURRENT_TIMESTAMP() - INTERVAL '1 day',
 23450.75, 35000.00, 25000.00,
 0.35, 4.2, 0.68,
 'sms', TRUE, FALSE,
 '["frequent-buyer", "mobile-user", "price-sensitive"]'::VARIANT),

('CUST_003', 'Emma', 'Davis', 'emma.davis@email.com', '+1-555-0789', '1990-11-08', 'Female',
 '789 Oak Ave', 'Austin', 'TX', '78701', 'USA',
 'active', 'silver', '2023-02-20', CURRENT_TIMESTAMP() - INTERVAL '10 days',
 8920.25, 15000.00, 10000.00,
 0.78, 3.1, 0.42,
 'email', FALSE, FALSE,
 '["at-risk", "support-needed", "occasional-buyer"]'::VARIANT),

('CUST_004', 'James', 'Wilson', 'james.wilson@email.com', '+1-555-0321', '1982-05-30', 'Male',
 '321 Pine St', 'Seattle', 'WA', '98101', 'USA',
 'active', 'bronze', '2024-01-05', CURRENT_TIMESTAMP() - INTERVAL '3 hours',
 1580.99, 5000.00, 5000.00,
 0.25, 4.5, 0.78,
 'phone', TRUE, TRUE,
 '["new-customer", "onboarding", "high-potential"]'::VARIANT),

('CUST_005', 'Lisa', 'Rodriguez', 'lisa.rodriguez@enterprise.com', '+1-555-0987', '1975-09-12', 'Female',
 '555 Enterprise Blvd', 'Los Angeles', 'CA', '90210', 'USA',
 'active', 'platinum', '2021-06-01', CURRENT_TIMESTAMP() - INTERVAL '6 hours',
 125000.00, 200000.00, 100000.00,
 0.08, 4.9, 0.95,
 'email', TRUE, TRUE,
 '["enterprise", "vip", "decision-maker", "high-value"]'::VARIANT);

-- Insert sample activities, purchases, tickets, communications, and documents
-- (Abbreviated for brevity - full data from sql/03_sample_data.sql would go here)

PRINT '✅ Sample data loaded';

-- ===============================
-- STEP 5: CREATE CORTEX SEARCH SERVICES
-- ===============================

PRINT '🔍 Creating Cortex Search services (this may take several minutes)...';

-- Create Cortex Search service for customer documents
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
        CASE 
            WHEN document_type = 'transcript' THEN 'Support Conversation'
            WHEN document_type = 'contract' THEN 'Legal Agreement'
            WHEN document_type = 'feedback' THEN 'Customer Feedback'
            WHEN document_type = 'note' THEN 'Internal Note'
            ELSE 'General Document'
        END as document_type_display,
        (SELECT customer_tier FROM customers c WHERE c.customer_id = customer_documents.customer_id) as customer_tier,
        (SELECT CONCAT(first_name, ' ', last_name) FROM customers c WHERE c.customer_id = customer_documents.customer_id) as customer_name
    FROM customer_documents
    WHERE document_content IS NOT NULL
    AND LENGTH(document_content) > 10
);

PRINT '✅ Cortex Search services created (indexing in progress)';

-- ===============================
-- STEP 6: CREATE CORTEX AGENT
-- ===============================

PRINT '🤖 Creating Cortex Agent and helper functions...';

-- Note: You'll need to upload the semantic model YAML file separately
-- The agent creation will reference the uploaded file

-- Create helper functions first
CREATE OR REPLACE FUNCTION ask_customer_360_ai(user_message STRING)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT 'Demo function - Cortex Agent integration pending semantic model upload' as message
$$;

CREATE OR REPLACE FUNCTION analyze_customer(customer_id STRING, analysis_type STRING DEFAULT 'overview')
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'message', 'Customer analysis for ' || customer_id || ' (' || analysis_type || ')',
        'customer_id', customer_id,
        'analysis_type', analysis_type,
        'status', 'Demo mode - full AI integration pending'
    )
$$;

PRINT '✅ Cortex Agent functions created (full AI integration requires semantic model upload)';

-- ===============================
-- STEP 7: VERIFICATION
-- ===============================

PRINT '🧪 Running verification tests...';

-- Test data integrity
SELECT 
    COUNT(*) as customer_count,
    AVG(churn_risk_score) as avg_churn_risk,
    COUNT(DISTINCT customer_tier) as tier_count
FROM customers;

-- Test relationships
SELECT 
    c.first_name, 
    c.last_name, 
    COUNT(a.activity_id) as activities,
    COUNT(p.purchase_id) as purchases,
    COUNT(s.ticket_id) as tickets
FROM customers c
LEFT JOIN customer_activities a ON c.customer_id = a.customer_id
LEFT JOIN purchases p ON c.customer_id = p.customer_id
LEFT JOIN support_tickets s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY c.customer_id;

-- Test views
SELECT COUNT(*) as summary_view_count FROM customer_360_summary;

-- ===============================
-- COMPLETION SUMMARY
-- ===============================

SELECT 
    '🎉 Demo setup completed successfully!' AS status,
    'Database: customer_360_db' AS database_info,
    'Warehouse: customer_360_wh' AS warehouse_info,
    (SELECT COUNT(*) FROM customers) AS customers_loaded,
    (SELECT COUNT(*) FROM customer_activities) AS activities_loaded,
    CURRENT_TIMESTAMP() AS setup_completed_at,
    'Next: Upload semantic model and deploy Streamlit app' AS next_steps;

PRINT '🎉 Customer 360 & AI Assistant Demo setup completed!';
PRINT '📋 Next steps:';
PRINT '   1. Upload semantic model YAML file to stage';
PRINT '   2. Create full Cortex Agent (after model upload)';
PRINT '   3. Deploy Streamlit application';
PRINT '   4. Test all functionality';

-- Show final status
SHOW TABLES;
SHOW VIEWS;
SHOW CORTEX SEARCH SERVICES; 