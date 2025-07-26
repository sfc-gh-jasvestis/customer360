-- =========================================
-- Customer 360 Demo - Table Creation
-- =========================================

USE DATABASE customer_360_db;
USE SCHEMA public;

-- ===============================
-- Core Customer Tables
-- ===============================

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

-- ===============================
-- Performance Optimization Notes
-- ===============================
-- Snowflake uses automatic clustering and micro-partitions for performance
-- No explicit indexes needed - Snowflake optimizes queries automatically
-- For better performance on large datasets, consider:
-- 1. Clustering keys on frequently filtered columns
-- 2. Search optimization service for text search
-- 3. Materialized views for complex aggregations

-- Example clustering (uncomment if needed for large datasets):
-- ALTER TABLE customer_activities CLUSTER BY (customer_id, activity_timestamp);
-- ALTER TABLE support_tickets CLUSTER BY (customer_id, created_at);
-- ALTER TABLE purchases CLUSTER BY (customer_id, purchase_date);

-- ===============================
-- Views for Analytics
-- ===============================

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

SELECT 'Tables created successfully' AS status,
       COUNT(*) AS table_count
FROM information_schema.tables 
WHERE table_schema = 'PUBLIC' 
AND table_name IN ('CUSTOMERS', 'CUSTOMER_ACTIVITIES', 'SUPPORT_TICKETS', 'PURCHASES', 'CUSTOMER_COMMUNICATIONS', 'CUSTOMER_DOCUMENTS'); 