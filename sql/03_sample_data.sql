-- ============================================================================
-- Retail Watch Store - Sample Data
-- ============================================================================
-- Populates tables with realistic sample data for demo purposes

USE DATABASE retail_watch_db;
USE SCHEMA public;
USE WAREHOUSE retail_watch_wh;

SELECT '🎯 Loading sample data for Retail Watch Store...' as data_loading_step;

-- ============================================================================
-- WATCH BRANDS DATA
-- ============================================================================

INSERT INTO watch_brands (brand_id, brand_name, brand_tier, country_origin, founded_year, brand_description, brand_image_url, avg_price_range) VALUES
('ROLEX', 'Rolex', 'luxury', 'Switzerland', 1905, 'A crown for every achievement. World-renowned luxury Swiss watch manufacturer.', 'https://rolex.com/logo.png', 15000),
('OMEGA', 'Omega', 'luxury', 'Switzerland', 1848, 'Masters of precision and innovation since 1848.', 'https://omega.com/logo.png', 8000),
('TAG_HEUER', 'TAG Heuer', 'luxury', 'Switzerland', 1860, 'Swiss avant-garde since 1860. Don''t Crack Under Pressure.', 'https://tagheuer.com/logo.png', 3500),
('SEIKO', 'Seiko', 'premium', 'Japan', 1881, 'Moving ahead. Always. Japanese precision and innovation.', 'https://seiko.com/logo.png', 800),
('CITIZEN', 'Citizen', 'premium', 'Japan', 1918, 'Better Starts Now. Eco-Drive solar technology pioneer.', 'https://citizen.com/logo.png', 600),
('CASIO', 'Casio', 'mid-range', 'Japan', 1946, 'Creativity and contribution. G-Shock and digital innovation.', 'https://casio.com/logo.png', 200),
('TISSOT', 'Tissot', 'premium', 'Switzerland', 1853, 'Innovators by tradition. Swiss watchmaking excellence.', 'https://tissot.com/logo.png', 900),
('HAMILTON', 'Hamilton', 'mid-range', 'USA', 1892, 'American spirit, Swiss precision. Aviation-inspired timepieces.', 'https://hamilton.com/logo.png', 700),
('FOSSIL', 'Fossil', 'affordable', 'USA', 1984, 'Vintage re-inspired accessories and smartwatches.', 'https://fossil.com/logo.png', 300),
('APPLE', 'Apple', 'premium', 'USA', 2015, 'The most personal device we''ve ever made. Smartwatch innovation.', 'https://apple.com/logo.png', 450);

-- ============================================================================
-- WATCH CATEGORIES DATA
-- ============================================================================

INSERT INTO watch_categories (category_id, category_name, parent_category_id, category_description, display_order) VALUES
('LUXURY', 'Luxury Watches', NULL, 'High-end Swiss and premium timepieces', 1),
('SPORT', 'Sport Watches', NULL, 'Active lifestyle and athletic timepieces', 2),
('DRESS', 'Dress Watches', NULL, 'Elegant formal and business watches', 3),
('CASUAL', 'Casual Watches', NULL, 'Everyday wear timepieces', 4),
('SMARTWATCH', 'Smart Watches', NULL, 'Connected and digital timepieces', 5),
('DIVING', 'Diving Watches', 'SPORT', 'Water-resistant professional diving watches', 6),
('AVIATION', 'Aviation Watches', 'SPORT', 'Pilot and aviation-inspired timepieces', 7),
('CHRONOGRAPH', 'Chronograph Watches', NULL, 'Stopwatch and timing function watches', 8);

-- ============================================================================
-- PRODUCTS DATA
-- ============================================================================

INSERT INTO products (product_id, brand_id, category_id, product_name, model_number, description, case_material, case_diameter, case_thickness, water_resistance, movement_type, display_type, strap_material, retail_price, current_price, cost_price, discount_percentage, stock_quantity, reorder_level, supplier_id, featured, new_arrival, bestseller, avg_rating, review_count, product_images, product_tags, seo_keywords, product_status, created_at, updated_at)
SELECT 'ROLEX_SUB_001', 'ROLEX', 'LUXURY', 'Submariner Date', '126610LV', 'The Rolex Submariner Date in Oystersteel with a green Cerachrom bezel insert and a black dial.', 'steel', 41.00, 12.50, 300, 'automatic', 'analog', 'steel', 10395.00, 10395.00, 5200.00, 0, 5, 2, 'SUP_001', TRUE, FALSE, TRUE, 4.8, 1247, PARSE_JSON('["https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1594534475808-b18fc33b045e?w=400&h=300&fit=crop"]'), PARSE_JSON('["luxury", "diving", "steel", "green"]'), PARSE_JSON('["rolex", "submariner", "diving", "luxury"]'), 'active', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'ROLEX_GMT_001', 'ROLEX', 'LUXURY', 'GMT-Master II', '126710BLRO', 'The Rolex GMT-Master II in Oystersteel with a blue and red Cerachrom bezel and Jubilee bracelet.', 'steel', 40.00, 12.00, 100, 'automatic', 'analog', 'steel', 10700.00, 10700.00, 5350.00, 0, 3, 2, 'SUP_001', TRUE, FALSE, TRUE, 4.9, 892, PARSE_JSON('["https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1509048191080-d2323c69888c?w=400&h=300&fit=crop"]'), PARSE_JSON('["luxury", "gmt", "travel", "pepsi"]'), PARSE_JSON('["rolex", "gmt", "master", "travel"]'), 'active', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'OMEGA_SPEED_001', 'OMEGA', 'LUXURY', 'Speedmaster Professional', '310.30.42.50.01.001', 'The legendary Moonwatch. First watch worn on the moon.', 'steel', 42.00, 13.00, 50, 'manual', 'analog', 'leather', 6350.00, 6350.00, 3175.00, 0, 8, 3, 'SUP_002', TRUE, TRUE, TRUE, 4.7, 1834, PARSE_JSON('["https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=400&h=300&fit=crop"]'), PARSE_JSON('["luxury", "chronograph", "moon", "racing"]'), PARSE_JSON('["omega", "speedmaster", "moon", "chronograph"]'), 'active', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'OMEGA_SEAMASTER_001', 'OMEGA', 'LUXURY', 'Seamaster Planet Ocean', '215.30.44.21.01.001', 'Professional diving watch with Co-Axial Master Chronometer movement.', 'steel', 43.50, 15.50, 600, 'automatic', 'analog', 'steel', 5400.00, 5400.00, 2700.00, 0, 12, 3, 'SUP_002', FALSE, FALSE, TRUE, 4.6, 756, PARSE_JSON('["https://images.unsplash.com/photo-1533139502658-0198f920d8e8?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&h=300&fit=crop"]'), PARSE_JSON('["luxury", "diving", "ocean", "master"]'), PARSE_JSON('["omega", "seamaster", "diving", "ocean"]'), 'active', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'TAG_CARRERA_001', 'TAG_HEUER', 'LUXURY', 'Carrera Chronograph', 'CBK2112.BA0715', 'Racing-inspired chronograph with Swiss automatic movement.', 'steel', 41.00, 14.50, 100, 'automatic', 'analog', 'steel', 2950.00, 2950.00, 1475.00, 0, 15, 5, 'SUP_003', FALSE, TRUE, FALSE, 4.4, 423, PARSE_JSON('["https://images.unsplash.com/photo-1614164185128-e4ec99c436d7?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1609587312208-cea54be969bf?w=400&h=300&fit=crop"]'), PARSE_JSON('["luxury", "chronograph", "racing", "carrera"]'), PARSE_JSON('["tag", "heuer", "carrera", "racing"]'), 'active', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'SEIKO_PROSPEX_001', 'SEIKO', 'SPORT', 'Prospex Solar Diver', 'SSC021', 'Solar-powered diving watch with 200m water resistance.', 'steel', 43.00, 12.00, 200, 'solar', 'analog', 'rubber', 180.00, 180.00, 90.00, 0, 25, 8, 'SUP_004', FALSE, FALSE, TRUE, 4.3, 1567, PARSE_JSON('["https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1611917743750-b2b991c5abc5?w=400&h=300&fit=crop"]'), PARSE_JSON('["sport", "diving", "solar", "affordable"]'), PARSE_JSON('["seiko", "prospex", "solar", "diving"]'), 'active', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'SEIKO_PRESAGE_001', 'SEIKO', 'DRESS', 'Presage Cocktail Time', 'SSA341', 'Elegant dress watch inspired by Japanese cocktail culture.', 'steel', 40.50, 11.80, 50, 'automatic', 'analog', 'leather', 220.00, 220.00, 110.00, 0, 20, 8, 'SUP_004', FALSE, TRUE, FALSE, 4.5, 892, PARSE_JSON('["https://images.unsplash.com/photo-1548171915-e79a380a2a4b?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1609587149924-48cd8b8a2b8f?w=400&h=300&fit=crop"]'), PARSE_JSON('["dress", "cocktail", "elegant", "automatic"]'), PARSE_JSON('["seiko", "presage", "cocktail", "dress"]'), 'active', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'CITIZEN_ECO_001', 'CITIZEN', 'CASUAL', 'Eco-Drive Chandler', 'BM8180-03E', 'Solar-powered field watch with canvas strap.', 'steel', 42.00, 11.00, 100, 'solar', 'analog', 'canvas', 95.00, 95.00, 47.50, 0, 35, 10, 'SUP_005', FALSE, FALSE, TRUE, 4.2, 2341, PARSE_JSON('["https://images.unsplash.com/photo-1542496658-e33a6d0d50b6?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1587836374615-c834f04c4915?w=400&h=300&fit=crop"]'), PARSE_JSON('["casual", "field", "solar", "canvas"]'), PARSE_JSON('["citizen", "eco-drive", "field", "casual"]'), 'active', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'CASIO_GSHOCK_001', 'CASIO', 'SPORT', 'G-Shock GA-2100', 'GA-2100-1A1', 'Tough, shock-resistant watch with carbon core guard structure.', 'resin', 45.40, 11.80, 200, 'quartz', 'analog-digital', 'resin', 99.00, 99.00, 49.50, 0, 50, 15, 'SUP_006', FALSE, TRUE, TRUE, 4.6, 3247, PARSE_JSON('["https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1618220179428-22790b461013?w=400&h=300&fit=crop"]'), PARSE_JSON('["sport", "tough", "shock", "digital"]'), PARSE_JSON('["casio", "g-shock", "tough", "shock"]'), 'active', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'APPLE_WATCH_001', 'APPLE', 'SMARTWATCH', 'Apple Watch Series 9', 'MR973LL/A', 'Advanced health monitoring, fitness tracking, and seamless iPhone integration.', 'aluminum', 45.00, 10.70, 50, 'digital', 'digital', 'sport', 429.00, 429.00, 214.50, 0, 30, 5, 'SUP_007', TRUE, TRUE, TRUE, 4.4, 8934, PARSE_JSON('["https://images.unsplash.com/photo-1551816230-ef5deaed4a26?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400&h=300&fit=crop"]'), PARSE_JSON('["smartwatch", "fitness", "health", "connected"]'), PARSE_JSON('["apple", "watch", "smart", "fitness"]'), 'active', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP();

-- ============================================================================
-- PRODUCT VARIANTS DATA
-- ============================================================================

INSERT INTO product_variants (variant_id, product_id, variant_name, variant_type, variant_value, price_adjustment, stock_quantity, variant_images)
SELECT 'ROLEX_SUB_001_BLACK', 'ROLEX_SUB_001', 'Black Dial', 'dial', 'black', 0, 3, PARSE_JSON('["https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=300&h=300&fit=crop"]')
UNION ALL
SELECT 'ROLEX_SUB_001_GREEN', 'ROLEX_SUB_001', 'Green Dial', 'dial', 'green', 0, 2, PARSE_JSON('["https://images.unsplash.com/photo-1594534475808-b18fc33b045e?w=300&h=300&fit=crop"]')
UNION ALL
SELECT 'APPLE_WATCH_001_41MM', 'APPLE_WATCH_001', '41mm', 'size', '41mm', -30.00, 25, PARSE_JSON('["https://images.unsplash.com/photo-1551816230-ef5deaed4a26?w=300&h=300&fit=crop"]')
UNION ALL
SELECT 'APPLE_WATCH_001_45MM', 'APPLE_WATCH_001', '45mm', 'size', '45mm', 0, 30, PARSE_JSON('["https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=300&h=300&fit=crop"]')
UNION ALL
SELECT 'APPLE_WATCH_001_BLUE', 'APPLE_WATCH_001', 'Blue Band', 'band', 'blue', 0, 15, PARSE_JSON('["https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=300&h=300&fit=crop"]')
UNION ALL
SELECT 'APPLE_WATCH_001_RED', 'APPLE_WATCH_001', 'Red Band', 'band', 'red', 0, 12, PARSE_JSON('["https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300&h=300&fit=crop"]');

-- ============================================================================
-- CUSTOMERS DATA
-- ============================================================================

INSERT INTO customers (customer_id, email, first_name, last_name, phone, date_of_birth, gender, registration_date, street_address, city, state, postal_code, country, customer_tier, preferred_brands, price_range_min, price_range_max, style_preferences, total_spent, total_orders, avg_order_value, last_purchase_date, last_login_date, website_visits_30d, email_opens_30d, email_clicks_30d, churn_risk_score, satisfaction_score, engagement_score, lifetime_value, account_status, marketing_consent, created_at, updated_at)
SELECT 'CUST_001', 'john.smith@email.com', 'John', 'Smith', '555-0101', '1985-03-15', 'Male', '2022-01-15 10:30:00'::timestamp,
 '123 Main St', 'New York', 'NY', '10001', 'USA', 'Gold', PARSE_JSON('["Rolex", "Omega"]'), 5000, 15000, PARSE_JSON('["luxury", "formal"]'),
 28450.00, 8, 3556.25, '2024-01-15 14:30:00'::timestamp, '2024-01-20 09:15:00'::timestamp, 45, 12, 8,
 0.2500, 8.5, 0.8200, 45600.00, 'active', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'CUST_002', 'sarah.johnson@email.com', 'Sarah', 'Johnson', '555-0102', '1990-07-22', 'Female', '2023-03-20 14:20:00'::timestamp,
 '456 Oak Ave', 'Los Angeles', 'CA', '90210', 'USA', 'Platinum', PARSE_JSON('["TAG Heuer", "Omega", "Apple"]'), 2000, 8000, PARSE_JSON('["sport", "casual", "smart"]'),
 15680.00, 12, 1306.67, '2024-01-10 16:45:00'::timestamp, '2024-01-22 11:30:00'::timestamp, 62, 18, 14,
 0.1500, 9.2, 0.9100, 28900.00, 'active', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'CUST_003', 'mike.brown@email.com', 'Mike', 'Brown', '555-0103', '1978-11-08', 'Male', '2021-05-10 16:45:00'::timestamp,
 '789 Pine St', 'Chicago', 'IL', '60601', 'USA', 'Silver', PARSE_JSON('["Seiko", "Citizen", "Casio"]'), 100, 500, PARSE_JSON('["casual", "sport"]'),
 1245.00, 5, 249.00, '2023-12-22 13:20:00'::timestamp, '2024-01-18 08:45:00'::timestamp, 23, 8, 6,
 0.3200, 7.1, 0.6800, 2100.00, 'active', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'CUST_004', 'emily.davis@email.com', 'Emily', 'Davis', '555-0104', '1992-04-30', 'Female', '2023-08-15 09:30:00'::timestamp,
 '321 Elm St', 'Miami', 'FL', '33101', 'USA', 'Bronze', PARSE_JSON('["Apple", "Fossil"]'), 200, 800, PARSE_JSON('["smart", "casual"]'),
 690.00, 3, 230.00, '2024-01-05 12:10:00'::timestamp, '2024-01-21 15:20:00'::timestamp, 38, 15, 11,
 0.4500, 6.8, 0.7500, 1200.00, 'active', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'CUST_005', 'robert.wilson@email.com', 'Robert', 'Wilson', '555-0105', '1965-09-12', 'Male', '2020-11-30 11:15:00'::timestamp,
 '654 Maple Dr', 'Seattle', 'WA', '98101', 'USA', 'Platinum', PARSE_JSON('["Rolex", "Omega", "TAG Heuer"]'), 8000, 25000, PARSE_JSON('["luxury", "formal"]'),
 45230.00, 15, 3015.33, '2024-01-12 10:30:00'::timestamp, '2024-01-19 14:45:00'::timestamp, 28, 6, 4,
 0.1800, 9.0, 0.8800, 78500.00, 'active', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'CUST_006', 'lisa.garcia@email.com', 'Lisa', 'Garcia', '555-0106', '1988-12-03', 'Female', '2022-07-18 13:45:00'::timestamp,
 '987 Cedar Ln', 'Austin', 'TX', '73301', 'USA', 'Gold', PARSE_JSON('["Tissot", "Hamilton", "Seiko"]'), 800, 3000, PARSE_JSON('["dress", "casual"]'),
 4560.00, 7, 651.43, '2023-12-28 11:20:00'::timestamp, '2024-01-17 16:30:00'::timestamp, 41, 11, 9,
 0.2800, 8.3, 0.7800, 8900.00, 'active', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL
SELECT 'CUST_007', 'inactive.customer@email.com', 'David', 'Miller', '555-0107', '1995-06-18', 'Male', '2023-01-10 08:20:00'::timestamp,
 '147 Birch St', 'Denver', 'CO', '80201', 'USA', 'Bronze', PARSE_JSON('["Casio"]'), 50, 200, PARSE_JSON('["casual"]'),
 150.00, 1, 150.00, '2023-02-15 14:30:00'::timestamp, '2023-08-10 09:15:00'::timestamp, 2, 0, 0,
 0.8500, 4.2, 0.2100, 300.00, 'active', FALSE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP();

-- ============================================================================
-- ORDERS DATA
-- ============================================================================

INSERT INTO orders (order_id, customer_id, order_date, order_status, payment_status, shipping_method, tracking_number, subtotal, tax_amount, shipping_cost, discount_amount, total_amount, billing_address, shipping_address, order_source, sales_channel, coupon_code, estimated_delivery_date, actual_delivery_date)
SELECT 'ORDER_001', 'CUST_001', '2024-01-15 14:30:00'::timestamp, 'delivered', 'paid', 'Express', 'TRK123456789',
 10395.00, 831.60, 29.99, 0, 11256.59, 
 PARSE_JSON('{"street": "123 Main St", "city": "New York", "state": "NY", "postal_code": "10001"}'),
 PARSE_JSON('{"street": "123 Main St", "city": "New York", "state": "NY", "postal_code": "10001"}'),
 'website', 'online', NULL, '2024-01-18'::date, '2024-01-17'::date
UNION ALL
SELECT 'ORDER_002', 'CUST_002', '2024-01-10 16:45:00'::timestamp, 'delivered', 'paid', 'Standard', 'TRK987654321',
 429.00, 34.32, 9.99, 50.00, 423.31,
 PARSE_JSON('{"street": "456 Oak Ave", "city": "Los Angeles", "state": "CA", "postal_code": "90210"}'),
 PARSE_JSON('{"street": "456 Oak Ave", "city": "Los Angeles", "state": "CA", "postal_code": "90210"}'),
 'mobile_app', 'online', 'SAVE50', '2024-01-15'::date, '2024-01-13'::date
UNION ALL
SELECT 'ORDER_003', 'CUST_003', '2023-12-22 13:20:00'::timestamp, 'delivered', 'paid', 'Standard', 'TRK456789123',
 99.00, 7.92, 9.99, 0, 116.91,
 PARSE_JSON('{"street": "789 Pine St", "city": "Chicago", "state": "IL", "postal_code": "60601"}'),
 PARSE_JSON('{"street": "789 Pine St", "city": "Chicago", "state": "IL", "postal_code": "60601"}'),
 'website', 'online', NULL, '2023-12-27'::date, '2023-12-25'::date
UNION ALL
SELECT 'ORDER_004', 'CUST_005', '2024-01-12 10:30:00'::timestamp, 'shipped', 'paid', 'Express', 'TRK789123456',
 6350.00, 508.00, 29.99, 0, 6887.99,
 PARSE_JSON('{"street": "654 Maple Dr", "city": "Seattle", "state": "WA", "postal_code": "98101"}'),
 PARSE_JSON('{"street": "654 Maple Dr", "city": "Seattle", "state": "WA", "postal_code": "98101"}'),
 'website', 'online', NULL, '2024-01-25'::date, NULL;

-- ============================================================================
-- ORDER ITEMS DATA
-- ============================================================================

INSERT INTO order_items (order_item_id, order_id, product_id, variant_id, quantity, unit_price, total_price, discount_amount, product_snapshot)
SELECT 'ITEM_001', 'ORDER_001', 'ROLEX_SUB_001', 'ROLEX_SUB_001_GREEN', 1, 10395.00, 10395.00, 0,
 PARSE_JSON('{"product_name": "Submariner Date", "brand": "Rolex", "model": "126610LV", "variant": "Green Dial"}')
UNION ALL
SELECT 'ITEM_002', 'ORDER_002', 'APPLE_WATCH_001', 'APPLE_WATCH_001_45MM', 1, 429.00, 429.00, 50.00,
 PARSE_JSON('{"product_name": "Apple Watch Series 9", "brand": "Apple", "model": "MR973LL/A", "variant": "45mm"}')
UNION ALL
SELECT 'ITEM_003', 'ORDER_003', 'CASIO_GSHOCK_001', NULL, 1, 99.00, 99.00, 0,
 PARSE_JSON('{"product_name": "G-Shock GA-2100", "brand": "Casio", "model": "GA-2100-1A1"}')
UNION ALL
SELECT 'ITEM_004', 'ORDER_004', 'OMEGA_SPEED_001', NULL, 1, 6350.00, 6350.00, 0,
 PARSE_JSON('{"product_name": "Speedmaster Professional", "brand": "Omega", "model": "310.30.42.50.01.001"}');

-- ============================================================================
-- CUSTOMER EVENTS DATA (Behavioral Tracking)
-- ============================================================================

INSERT INTO customer_events (event_id, customer_id, event_type, event_timestamp, product_id, category, page_url, session_id, device_type, event_properties, revenue)
SELECT 'EVENT_001', 'CUST_001', 'page_view', '2024-01-22 09:15:00'::timestamp, NULL, 'luxury', '/watches/luxury', 'SESS_001', 'desktop', PARSE_JSON('{"duration_seconds": 120}'), 0
UNION ALL
SELECT 'EVENT_002', 'CUST_001', 'product_view', '2024-01-22 09:17:00'::timestamp, 'ROLEX_GMT_001', 'luxury', '/product/rolex-gmt-master-ii', 'SESS_001', 'desktop', PARSE_JSON('{"view_duration": 180, "images_viewed": 3}'), 0
UNION ALL
SELECT 'EVENT_003', 'CUST_001', 'product_view', '2024-01-22 09:22:00'::timestamp, 'OMEGA_SEAMASTER_001', 'luxury', '/product/omega-seamaster', 'SESS_001', 'desktop', PARSE_JSON('{"view_duration": 90}'), 0
UNION ALL
SELECT 'EVENT_004', 'CUST_001', 'cart_add', '2024-01-22 09:25:00'::timestamp, 'ROLEX_GMT_001', 'luxury', '/cart', 'SESS_001', 'desktop', PARSE_JSON('{"quantity": 1}'), 10700.00
UNION ALL
SELECT 'EVENT_005', 'CUST_002', 'search', '2024-01-22 11:30:00'::timestamp, NULL, NULL, '/search?q=sport+watch', 'SESS_002', 'mobile', PARSE_JSON('{"search_term": "sport watch", "results_count": 15}'), 0
UNION ALL
SELECT 'EVENT_006', 'CUST_002', 'product_view', '2024-01-22 11:32:00'::timestamp, 'TAG_CARRERA_001', 'luxury', '/product/tag-heuer-carrera', 'SESS_002', 'mobile', PARSE_JSON('{"view_duration": 60}'), 0
UNION ALL
SELECT 'EVENT_007', 'CUST_002', 'product_view', '2024-01-22 11:35:00'::timestamp, 'APPLE_WATCH_001', 'smartwatch', '/product/apple-watch-series-9', 'SESS_002', 'mobile', PARSE_JSON('{"view_duration": 45}'), 0
UNION ALL
SELECT 'EVENT_008', 'CUST_003', 'category_browse', '2024-01-18 08:45:00'::timestamp, NULL, 'casual', '/watches/casual', 'SESS_003', 'desktop', PARSE_JSON('{"products_viewed": 8}'), 0
UNION ALL
SELECT 'EVENT_009', 'CUST_003', 'product_view', '2024-01-18 08:48:00'::timestamp, 'SEIKO_PROSPEX_001', 'sport', '/product/seiko-prospex-solar', 'SESS_003', 'desktop', PARSE_JSON('{"view_duration": 120}'), 0
UNION ALL
SELECT 'EVENT_010', 'CUST_003', 'product_view', '2024-01-18 08:52:00'::timestamp, 'CITIZEN_ECO_001', 'casual', '/product/citizen-eco-drive', 'SESS_003', 'desktop', PARSE_JSON('{"view_duration": 90}'), 0
UNION ALL
SELECT 'EVENT_011', 'CUST_007', 'page_view', '2023-08-10 09:15:00'::timestamp, NULL, 'casual', '/watches', 'SESS_007', 'mobile', PARSE_JSON('{"duration_seconds": 30}'), 0
UNION ALL
SELECT 'EVENT_012', 'CUST_007', 'product_view', '2023-08-10 09:16:00'::timestamp, 'CASIO_GSHOCK_001', 'sport', '/product/casio-gshock', 'SESS_007', 'mobile', PARSE_JSON('{"view_duration": 15}'), 0;

-- ============================================================================
-- PRODUCT REVIEWS DATA (with AI Sentiment Analysis)
-- ============================================================================

INSERT INTO product_reviews (review_id, product_id, customer_id, order_id, rating, title, review_text, review_date, verified_purchase, helpful_votes, sentiment_score, sentiment_label, key_themes, review_status, moderation_notes)
SELECT 'REV_001', 'ROLEX_SUB_001', 'CUST_001', 'ORDER_001', 5.0, 'Absolutely Perfect!', 
 'This is my third Rolex and the Submariner continues to exceed expectations. The build quality is exceptional, keeps perfect time, and the green bezel is stunning. Worth every penny for a luxury timepiece that will last generations.',
 '2024-01-20 15:30:00'::timestamp, TRUE, 23, 0.8500, 'positive', PARSE_JSON('["build quality", "luxury", "durability", "design"]'),
 'approved', NULL
UNION ALL
SELECT 'REV_002', 'APPLE_WATCH_001', 'CUST_002', 'ORDER_002', 4.5, 'Great Smart Features', 
 'Love the health tracking and fitness features. Battery life could be better but the integration with my iPhone is seamless. The display is bright and clear. Good value for a smartwatch.',
 '2024-01-15 12:45:00'::timestamp, TRUE, 18, 0.6200, 'positive', PARSE_JSON('["health tracking", "fitness", "integration", "display"]'),
 'approved', NULL
UNION ALL
SELECT 'REV_003', 'CASIO_GSHOCK_001', 'CUST_003', 'ORDER_003', 4.0, 'Tough and Reliable', 
 'Exactly what I expected from G-Shock. Super durable, survived several drops and water exposure. The analog-digital combo is practical. Great watch for outdoor activities and sports.',
 '2023-12-28 16:20:00'::timestamp, TRUE, 31, 0.7100, 'positive', PARSE_JSON('["durability", "outdoor", "practical", "sports"]'),
 'approved', NULL
UNION ALL
SELECT 'REV_004', 'OMEGA_SPEED_001', 'CUST_005', 'ORDER_004', 5.0, 'Moon Watch Excellence', 
 'The legendary Speedmaster lives up to its reputation. Manual winding is a joy, the chronograph is precise, and the history behind this watch makes it special. A true classic that never goes out of style.',
 '2024-01-18 10:15:00'::timestamp, TRUE, 15, 0.9200, 'positive', PARSE_JSON('["legendary", "history", "classic", "chronograph", "precision"]'),
 'approved', NULL
UNION ALL
SELECT 'REV_005', 'SEIKO_PROSPEX_001', 'CUST_003', NULL, 3.5, 'Good Value But...', 
 'The solar feature is convenient and the watch looks decent. However, the build quality feels a bit cheap for the price. The rubber strap started showing wear after just a few months. Still functional but expected more from Seiko.',
 '2024-01-10 14:30:00'::timestamp, FALSE, 8, 0.1200, 'neutral', PARSE_JSON('["value", "solar", "build quality", "durability concerns"]'),
 'approved', NULL
UNION ALL
SELECT 'REV_006', 'TAG_CARRERA_001', 'CUST_006', NULL, 2.5, 'Disappointing for the Price', 
 'For $3000, I expected much better. The watch gains about 15 seconds per day, which is unacceptable for a Swiss automatic. Customer service was unhelpful when I contacted them about the accuracy issue. Would not recommend.',
 '2024-01-05 09:45:00'::timestamp, FALSE, 4, -0.6500, 'negative', PARSE_JSON('["price", "accuracy", "customer service", "disappointing"]'),
 'approved', NULL;

-- ============================================================================
-- CUSTOMER INTERACTIONS DATA (Support/Service)
-- ============================================================================

INSERT INTO customer_interactions (interaction_id, customer_id, interaction_type, interaction_date, subject, content, response, status, priority, assigned_agent, sentiment_score, intent_classification, urgency_score, resolution_prediction, resolution_time_minutes, customer_satisfaction_rating)
SELECT 'INT_001', 'CUST_001', 'chat', '2024-01-22 10:30:00'::timestamp, 'Question about GMT function',
 'Hi, I''m interested in the Rolex GMT-Master II. Can you explain how the GMT function works and if it''s suitable for frequent international travel?',
 'The GMT function displays a second time zone using the additional hand and rotating bezel. Perfect for travelers who need to track home time while abroad. The Rolex GMT-Master II is specifically designed for pilots and frequent travelers.',
 'resolved', 'medium', 'agent_sarah', 0.2500, 'inquiry', 0.1000, 
 PARSE_JSON('{"suggested_actions": ["provide_detailed_explanation", "offer_demo"], "confidence": 0.95}'), 8, 5.0
UNION ALL
SELECT 'INT_002', 'CUST_006', 'email', '2024-01-05 14:20:00'::timestamp, 'Watch Accuracy Issue',
 'I purchased a TAG Heuer Carrera last month and it''s running fast by about 15 seconds per day. This seems excessive for a Swiss automatic watch. What can be done about this?',
 'I understand your concern about the timekeeping accuracy. Swiss automatic watches should maintain better precision. I''d like to arrange a warranty service for regulation. We can also provide a replacement if the issue persists.',
 'in_progress', 'high', 'agent_michael', -0.4500, 'complaint', 0.8500,
 PARSE_JSON('{"suggested_actions": ["warranty_service", "replacement_offer", "priority_handling"], "confidence": 0.88}'), NULL, NULL
UNION ALL
SELECT 'INT_003', 'CUST_002', 'phone', '2024-01-16 11:15:00'::timestamp, 'Apple Watch Setup Help',
 'I just received my Apple Watch and I''m having trouble pairing it with my iPhone. Can someone walk me through the setup process?',
 'I''d be happy to help with the Apple Watch setup. Let me guide you through the pairing process step by step. First, make sure both devices have sufficient battery and are close together...',
 'resolved', 'low', 'agent_jessica', 0.1000, 'inquiry', 0.2000,
 PARSE_JSON('{"suggested_actions": ["step_by_step_guide", "follow_up"], "confidence": 0.92}'), 12, 4.5
UNION ALL
SELECT 'INT_004', 'CUST_007', 'email', '2023-08-15 16:30:00'::timestamp, 'Cancellation Request',
 'I want to cancel my account and stop receiving marketing emails. I haven''t been active and don''t plan to purchase anything else.',
 'I''ve processed your request to opt out of marketing communications. Your account will remain active in case you change your mind, but you won''t receive promotional emails. Is there anything specific that led to this decision?',
 'resolved', 'medium', 'agent_david', -0.3000, 'complaint', 0.9200,
 PARSE_JSON('{"suggested_actions": ["retention_offer", "feedback_collection", "opt_out_processing"], "confidence": 0.85}'), 15, 3.0;

SELECT '✅ Sample data loaded successfully!' as data_status;
SELECT 'Brands: ' || COUNT(*) as brand_count FROM watch_brands
UNION ALL
SELECT 'Categories: ' || COUNT(*) as category_count FROM watch_categories  
UNION ALL
SELECT 'Products: ' || COUNT(*) as product_count FROM products
UNION ALL
SELECT 'Customers: ' || COUNT(*) as customer_count FROM customers
UNION ALL
SELECT 'Orders: ' || COUNT(*) as order_count FROM orders
UNION ALL
SELECT 'Customer Events: ' || COUNT(*) as event_count FROM customer_events
UNION ALL
SELECT 'Reviews: ' || COUNT(*) as review_count FROM product_reviews
UNION ALL
SELECT 'Interactions: ' || COUNT(*) as interaction_count FROM customer_interactions; 