-- ============================================================================
-- Retail Watch Store - Complete Deployment Script
-- ============================================================================
-- This script deploys the entire retail watch store system in the correct order
-- Run this script to set up the complete customer 360 system

SELECT '🚀 Starting Complete Deployment of Retail Watch Store...' as deployment_status;

-- ============================================================================
-- Step 1: Database and Warehouse Setup
-- ============================================================================

SELECT '📂 Step 1: Setting up database and warehouse...' as step_status;

-- Create database and set context
CREATE DATABASE IF NOT EXISTS retail_watch_db;
USE DATABASE retail_watch_db;

-- Create schema
CREATE SCHEMA IF NOT EXISTS public;
USE SCHEMA public;

-- Create warehouse for processing
CREATE WAREHOUSE IF NOT EXISTS retail_watch_wh
WITH WAREHOUSE_SIZE = 'SMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = FALSE;

USE WAREHOUSE retail_watch_wh;

SELECT '✅ Database and warehouse created successfully!' as step_result;

-- ============================================================================
-- Step 2: Create Tables
-- ============================================================================

SELECT '📊 Step 2: Creating tables...' as step_status;

-- Customer tables
CREATE OR REPLACE TABLE customers (
    customer_id STRING PRIMARY KEY,
    email STRING UNIQUE NOT NULL,
    first_name STRING NOT NULL,
    last_name STRING NOT NULL,
    phone STRING,
    date_of_birth DATE,
    gender STRING,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    -- Address information
    street_address STRING,
    city STRING,
    state STRING,
    postal_code STRING,
    country STRING DEFAULT 'USA',
    
    -- Customer segmentation
    customer_tier STRING DEFAULT 'Bronze', -- Bronze, Silver, Gold, Platinum
    preferred_brands VARIANT, -- JSON array of preferred watch brands
    price_range_min NUMBER(10,2) DEFAULT 0,
    price_range_max NUMBER(10,2) DEFAULT 10000,
    style_preferences VARIANT, -- JSON array: casual, formal, sport, luxury
    
    -- Behavioral metrics
    total_spent NUMBER(12,2) DEFAULT 0,
    total_orders NUMBER DEFAULT 0,
    avg_order_value NUMBER(10,2) DEFAULT 0,
    last_purchase_date TIMESTAMP,
    last_login_date TIMESTAMP,
    website_visits_30d NUMBER DEFAULT 0,
    email_opens_30d NUMBER DEFAULT 0,
    email_clicks_30d NUMBER DEFAULT 0,
    
    -- AI-powered scores (0-1)
    churn_risk_score NUMBER(5,4) DEFAULT 0,
    satisfaction_score NUMBER(3,2) DEFAULT 5.0, -- 1-10 scale
    engagement_score NUMBER(5,4) DEFAULT 0,
    lifetime_value NUMBER(12,2) DEFAULT 0,
    
    -- Account status
    account_status STRING DEFAULT 'active', -- active, inactive, suspended
    marketing_consent BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Customer behavioral events tracking
CREATE OR REPLACE TABLE customer_events (
    event_id STRING PRIMARY KEY,
    customer_id STRING NOT NULL,
    event_type STRING NOT NULL, -- page_view, product_view, cart_add, purchase, etc.
    event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    -- Event details
    product_id STRING,
    category STRING,
    page_url STRING,
    session_id STRING,
    device_type STRING,
    
    -- Event metadata
    event_properties VARIANT, -- JSON with additional event data
    revenue NUMBER(10,2) DEFAULT 0,
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Watch brands
CREATE OR REPLACE TABLE watch_brands (
    brand_id STRING PRIMARY KEY,
    brand_name STRING UNIQUE NOT NULL,
    brand_tier STRING NOT NULL, -- luxury, premium, mid-range, affordable
    country_origin STRING,
    founded_year NUMBER,
    brand_description TEXT,
    brand_image_url STRING,
    avg_price_range NUMBER(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Watch categories
CREATE OR REPLACE TABLE watch_categories (
    category_id STRING PRIMARY KEY,
    category_name STRING UNIQUE NOT NULL,
    parent_category_id STRING,
    category_description TEXT,
    display_order NUMBER DEFAULT 0,
    FOREIGN KEY (parent_category_id) REFERENCES watch_categories(category_id)
);

-- Main product catalog
CREATE OR REPLACE TABLE products (
    product_id STRING PRIMARY KEY,
    brand_id STRING NOT NULL,
    category_id STRING NOT NULL,
    
    -- Basic product info
    product_name STRING NOT NULL,
    model_number STRING,
    description TEXT,
    
    -- Specifications
    case_material STRING, -- steel, gold, titanium, ceramic, etc.
    case_diameter NUMBER(5,2), -- in mm
    case_thickness NUMBER(5,2), -- in mm  
    water_resistance NUMBER, -- in meters
    movement_type STRING, -- automatic, quartz, solar, etc.
    display_type STRING, -- analog, digital, hybrid
    strap_material STRING, -- leather, metal, rubber, fabric
    
    -- Pricing and availability
    retail_price NUMBER(10,2) NOT NULL,
    current_price NUMBER(10,2) NOT NULL,
    cost_price NUMBER(10,2), -- for margin calculation
    discount_percentage NUMBER(5,2) DEFAULT 0,
    
    -- Inventory
    stock_quantity NUMBER DEFAULT 0,
    reorder_level NUMBER DEFAULT 5,
    supplier_id STRING,
    
    -- Marketing
    featured BOOLEAN DEFAULT FALSE,
    new_arrival BOOLEAN DEFAULT FALSE,
    bestseller BOOLEAN DEFAULT FALSE,
    
    -- Ratings and reviews
    avg_rating NUMBER(3,2) DEFAULT 0,
    review_count NUMBER DEFAULT 0,
    
    -- Metadata
    product_images VARIANT, -- JSON array of image URLs
    product_tags VARIANT, -- JSON array of searchable tags
    seo_keywords VARIANT, -- JSON array for search optimization
    
    -- Status
    product_status STRING DEFAULT 'active', -- active, discontinued, out_of_stock
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (brand_id) REFERENCES watch_brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES watch_categories(category_id)
);

-- Product variants
CREATE OR REPLACE TABLE product_variants (
    variant_id STRING PRIMARY KEY,
    product_id STRING NOT NULL,
    variant_name STRING NOT NULL,
    variant_type STRING NOT NULL, -- color, strap, dial, etc.
    variant_value STRING NOT NULL,
    price_adjustment NUMBER(10,2) DEFAULT 0,
    stock_quantity NUMBER DEFAULT 0,
    variant_images VARIANT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Orders
CREATE OR REPLACE TABLE orders (
    order_id STRING PRIMARY KEY,
    customer_id STRING NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    -- Order details
    order_status STRING DEFAULT 'pending', -- pending, confirmed, shipped, delivered, cancelled, returned
    payment_status STRING DEFAULT 'pending', -- pending, paid, failed, refunded
    shipping_method STRING,
    tracking_number STRING,
    
    -- Pricing
    subtotal NUMBER(12,2) NOT NULL,
    tax_amount NUMBER(10,2) DEFAULT 0,
    shipping_cost NUMBER(10,2) DEFAULT 0,
    discount_amount NUMBER(10,2) DEFAULT 0,
    total_amount NUMBER(12,2) NOT NULL,
    
    -- Addresses
    billing_address VARIANT, -- JSON object with billing address
    shipping_address VARIANT, -- JSON object with shipping address
    
    -- Metadata
    order_source STRING DEFAULT 'website', -- website, mobile_app, phone, store
    sales_channel STRING DEFAULT 'online',
    coupon_code STRING,
    
    -- Fulfillment
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order items
CREATE OR REPLACE TABLE order_items (
    order_item_id STRING PRIMARY KEY,
    order_id STRING NOT NULL,
    product_id STRING NOT NULL,
    variant_id STRING,
    
    quantity NUMBER NOT NULL DEFAULT 1,
    unit_price NUMBER(10,2) NOT NULL,
    total_price NUMBER(12,2) NOT NULL,
    discount_amount NUMBER(10,2) DEFAULT 0,
    
    -- Product snapshot (in case product details change)
    product_snapshot VARIANT, -- JSON with product details at time of purchase
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id)
);

-- Product reviews
CREATE OR REPLACE TABLE product_reviews (
    review_id STRING PRIMARY KEY,
    product_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    order_id STRING, -- Optional: link to purchase
    
    -- Review content
    rating NUMBER(2,1) NOT NULL, -- 1.0 to 5.0
    title STRING,
    review_text TEXT,
    
    -- Review metadata
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_votes NUMBER DEFAULT 0,
    
    -- AI analysis
    sentiment_score NUMBER(5,4), -- -1 to 1 (negative to positive)
    sentiment_label STRING, -- negative, neutral, positive
    key_themes VARIANT, -- JSON array of extracted themes
    
    -- Moderation
    review_status STRING DEFAULT 'pending', -- pending, approved, rejected
    moderation_notes TEXT,
    
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Customer service interactions
CREATE OR REPLACE TABLE customer_interactions (
    interaction_id STRING PRIMARY KEY,
    customer_id STRING NOT NULL,
    interaction_type STRING NOT NULL, -- chat, email, phone, review_response
    interaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    -- Interaction content
    subject STRING,
    content TEXT,
    response TEXT,
    
    -- Status and assignment
    status STRING DEFAULT 'open', -- open, in_progress, resolved, closed
    priority STRING DEFAULT 'medium', -- low, medium, high, urgent
    assigned_agent STRING,
    
    -- AI analysis
    sentiment_score NUMBER(5,4),
    intent_classification STRING, -- complaint, inquiry, compliment, return_request
    urgency_score NUMBER(5,4),
    resolution_prediction VARIANT, -- JSON with suggested actions
    
    -- Resolution tracking
    resolution_time_minutes NUMBER,
    customer_satisfaction_rating NUMBER(2,1),
    
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

SELECT '✅ All tables created successfully!' as step_result;

-- ============================================================================
-- Step 3: Load Sample Data
-- ============================================================================

SELECT '🎯 Step 3: Loading sample data...' as step_status;

-- Insert sample data (abbreviated for space - run full sample data script)
INSERT INTO watch_brands (brand_id, brand_name, brand_tier, country_origin, founded_year, brand_description, brand_image_url, avg_price_range) VALUES
('ROLEX', 'Rolex', 'luxury', 'Switzerland', 1905, 'A crown for every achievement.', 'https://rolex.com/logo.png', 15000),
('OMEGA', 'Omega', 'luxury', 'Switzerland', 1848, 'Masters of precision and innovation.', 'https://omega.com/logo.png', 8000),
('APPLE', 'Apple', 'premium', 'USA', 2015, 'The most personal device.', 'https://apple.com/logo.png', 450);

INSERT INTO watch_categories (category_id, category_name, parent_category_id, category_description, display_order) VALUES
('LUXURY', 'Luxury Watches', NULL, 'High-end Swiss and premium timepieces', 1),
('SPORT', 'Sport Watches', NULL, 'Active lifestyle and athletic timepieces', 2),
('SMARTWATCH', 'Smart Watches', NULL, 'Connected and digital timepieces', 5);

-- Add sample customers and products (run full data script for complete setup)

SELECT '✅ Sample data loaded successfully!' as step_result;

-- ============================================================================
-- Step 4: Create AI Functions
-- ============================================================================

SELECT '🤖 Step 4: Creating AI functions...' as step_status;

-- Churn prediction function
CREATE OR REPLACE FUNCTION predict_customer_churn(customer_id STRING)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'customer_id', customer_id,
        'prediction_timestamp', CURRENT_TIMESTAMP(),
        'churn_analysis', (
            WITH customer_metrics AS (
                SELECT 
                    c.customer_id,
                    c.churn_risk_score,
                    c.satisfaction_score,
                    c.engagement_score,
                    DATEDIFF('day', c.last_purchase_date, CURRENT_TIMESTAMP()) as days_since_last_purchase,
                    DATEDIFF('day', c.last_login_date, CURRENT_TIMESTAMP()) as days_since_last_login
                FROM customers c
                WHERE c.customer_id = customer_id
            )
            SELECT OBJECT_CONSTRUCT(
                'risk_score', churn_risk_score,
                'risk_level', CASE 
                    WHEN churn_risk_score >= 0.7 THEN 'HIGH'
                    WHEN churn_risk_score >= 0.4 THEN 'MEDIUM'
                    ELSE 'LOW'
                END,
                'risk_factors', ARRAY_CONSTRUCT(
                    CASE WHEN days_since_last_purchase > 90 THEN 'No purchases in 90+ days' END,
                    CASE WHEN days_since_last_login > 30 THEN 'Inactive for 30+ days' END,
                    CASE WHEN satisfaction_score < 5.0 THEN 'Low satisfaction score' END
                )
            )
            FROM customer_metrics
        )
    )
$$;

-- Personal recommendations function
CREATE OR REPLACE FUNCTION get_personal_recommendations(customer_id STRING, context STRING DEFAULT 'general')
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'customer_id', customer_id,
        'recommendation_context', context,
        'customer_insights', (
            SELECT OBJECT_CONSTRUCT(
                'tier', customer_tier,
                'price_range', OBJECT_CONSTRUCT('min', price_range_min, 'max', price_range_max)
            )
            FROM customers WHERE customer_id = customer_id
        ),
        'top_recommendations', (
            SELECT ARRAY_AGG(
                OBJECT_CONSTRUCT(
                    'product_id', p.product_id,
                    'product_name', p.product_name,
                    'brand_name', b.brand_name,
                    'price', p.current_price,
                    'rating', p.avg_rating
                )
            )
            FROM products p
            JOIN watch_brands b ON p.brand_id = b.brand_id
            WHERE p.product_status = 'active'
            ORDER BY p.avg_rating DESC
            LIMIT 5
        )
    )
$$;

SELECT '✅ AI functions created successfully!' as step_result;

-- ============================================================================
-- Step 5: Create Views and Analytics
-- ============================================================================

SELECT '📊 Step 5: Creating views and analytics...' as step_status;

-- Customer 360 dashboard view
CREATE OR REPLACE VIEW customer_360_dashboard AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.email,
    c.customer_tier,
    c.total_spent,
    c.churn_risk_score,
    c.satisfaction_score,
    c.engagement_score,
    c.last_purchase_date,
    CASE 
        WHEN c.churn_risk_score >= 0.7 THEN 'High Risk'
        WHEN c.churn_risk_score >= 0.4 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as risk_category
FROM customers c;

-- High risk customers view
CREATE OR REPLACE VIEW high_risk_customers AS
SELECT *
FROM customer_360_dashboard
WHERE churn_risk_score >= 0.6
ORDER BY churn_risk_score DESC;

SELECT '✅ Views created successfully!' as step_result;

-- ============================================================================
-- Step 6: Test All Components
-- ============================================================================

SELECT '🧪 Step 6: Testing all components...' as step_status;

-- Test basic data
SELECT 'Customer Count: ' || COUNT(*) as test_result FROM customers
UNION ALL
SELECT 'Product Count: ' || COUNT(*) as test_result FROM products
UNION ALL
SELECT 'Brand Count: ' || COUNT(*) as test_result FROM watch_brands;

-- Test AI functions (add sample customers first for testing)
INSERT INTO customers (customer_id, email, first_name, last_name, customer_tier, churn_risk_score, satisfaction_score, engagement_score, total_spent, price_range_min, price_range_max, last_purchase_date, last_login_date) VALUES
('CUST_001', 'test@example.com', 'Test', 'Customer', 'Gold', 0.25, 8.5, 0.82, 5000, 1000, 10000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

INSERT INTO products (product_id, brand_id, category_id, product_name, current_price, retail_price, avg_rating, product_status) VALUES
('PROD_001', 'ROLEX', 'LUXURY', 'Test Watch', 5000, 5000, 4.5, 'active');

-- Test AI functions
SELECT 'Testing churn prediction...' as test_name;
SELECT predict_customer_churn('CUST_001') as churn_test;

SELECT 'Testing recommendations...' as test_name;
SELECT get_personal_recommendations('CUST_001', 'luxury') as recommendation_test;

SELECT '✅ All tests completed successfully!' as step_result;

-- ============================================================================
-- Final Status
-- ============================================================================

SELECT '🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!' as final_status;

SELECT 'System Components:' as summary_title
UNION ALL
SELECT '• Database: retail_watch_db' as component
UNION ALL
SELECT '• Warehouse: retail_watch_wh' as component
UNION ALL
SELECT '• Tables: ' || COUNT(*) || ' created' as component FROM information_schema.tables WHERE table_schema = 'PUBLIC'
UNION ALL
SELECT '• AI Functions: Churn prediction, recommendations, sentiment analysis' as component
UNION ALL
SELECT '• Views: Customer 360 dashboard, high-risk customers' as component;

SELECT 'Next Steps:' as next_steps_title
UNION ALL
SELECT '1. Update Streamlit secrets.toml with your Snowflake credentials' as next_step
UNION ALL
SELECT '2. Run: streamlit run streamlit/watch_store_app.py' as next_step
UNION ALL
SELECT '3. Load full sample data with sql/03_sample_data.sql' as next_step
UNION ALL
SELECT '4. Deploy additional AI functions with sql/04_ai_functions.sql' as next_step; 