-- ============================================================================
-- Retail Watch Store - Table Creation
-- ============================================================================
-- Creates all tables for customer 360, product catalog, and analytics

USE DATABASE retail_watch_db;
USE SCHEMA public;
USE WAREHOUSE retail_watch_wh;

SELECT '📊 Creating tables for Retail Watch Store...' as setup_step;

-- ============================================================================
-- CUSTOMER TABLES
-- ============================================================================

-- Main customer profile table
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

-- ============================================================================
-- PRODUCT CATALOG TABLES
-- ============================================================================

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

-- Product variants (different colors, straps, etc.)
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

-- ============================================================================
-- TRANSACTION TABLES
-- ============================================================================

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

-- ============================================================================
-- REVIEW AND FEEDBACK TABLES
-- ============================================================================

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

SELECT '✅ All tables created successfully!' as table_status;

-- Show table summary
SELECT 
    table_name,
    CASE table_name
        WHEN 'customers' THEN 'Core customer profiles and AI scores'
        WHEN 'customer_events' THEN 'Behavioral event tracking'
        WHEN 'watch_brands' THEN 'Watch brand catalog'
        WHEN 'watch_categories' THEN 'Product categorization'
        WHEN 'products' THEN 'Main product catalog'
        WHEN 'product_variants' THEN 'Product variations'
        WHEN 'orders' THEN 'Order transactions'
        WHEN 'order_items' THEN 'Order line items'
        WHEN 'product_reviews' THEN 'Customer reviews with AI sentiment'
        WHEN 'customer_interactions' THEN 'Customer service interactions'
        ELSE 'Other table'
    END as table_description
FROM information_schema.tables 
WHERE table_schema = 'PUBLIC' 
AND table_type = 'BASE TABLE'
ORDER BY table_name; 