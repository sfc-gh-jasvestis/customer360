-- ============================================================================
-- UPDATE PRODUCT IMAGES WITH WORKING URLS
-- Run this script to fix the placeholder image URLs in your database
-- ============================================================================

USE DATABASE retail_watch_db;
USE SCHEMA public;
USE WAREHOUSE retail_watch_wh;

-- Update product images with working Unsplash URLs
UPDATE products SET product_images = PARSE_JSON('["https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1594534475808-b18fc33b045e?w=400&h=300&fit=crop"]') WHERE product_id = 'ROLEX_SUB_001';
UPDATE products SET product_images = PARSE_JSON('["https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1509048191080-d2323c69888c?w=400&h=300&fit=crop"]') WHERE product_id = 'ROLEX_GMT_001';
UPDATE products SET product_images = PARSE_JSON('["https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=400&h=300&fit=crop"]') WHERE product_id = 'OMEGA_SPEED_001';
UPDATE products SET product_images = PARSE_JSON('["https://images.unsplash.com/photo-1533139502658-0198f920d8e8?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&h=300&fit=crop"]') WHERE product_id = 'OMEGA_SEAMASTER_001';
UPDATE products SET product_images = PARSE_JSON('["https://images.unsplash.com/photo-1614164185128-e4ec99c436d7?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1609587312208-cea54be969bf?w=400&h=300&fit=crop"]') WHERE product_id = 'TAG_CARRERA_001';
UPDATE products SET product_images = PARSE_JSON('["https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1611917743750-b2b991c5abc5?w=400&h=300&fit=crop"]') WHERE product_id = 'SEIKO_PROSPEX_001';
UPDATE products SET product_images = PARSE_JSON('["https://images.unsplash.com/photo-1548171915-e79a380a2a4b?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1609587149924-48cd8b8a2b8f?w=400&h=300&fit=crop"]') WHERE product_id = 'SEIKO_PRESAGE_001';
UPDATE products SET product_images = PARSE_JSON('["https://images.unsplash.com/photo-1542496658-e33a6d0d50b6?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1587836374615-c834f04c4915?w=400&h=300&fit=crop"]') WHERE product_id = 'CITIZEN_ECODRIVE_001';
UPDATE products SET product_images = PARSE_JSON('["https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1618220179428-22790b461013?w=400&h=300&fit=crop"]') WHERE product_id = 'CASIO_GSHOCK_001';
UPDATE products SET product_images = PARSE_JSON('["https://images.unsplash.com/photo-1551816230-ef5deaed4a26?w=400&h=300&fit=crop", "https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400&h=300&fit=crop"]') WHERE product_id = 'APPLE_WATCH_001';

-- Verify the updates
SELECT product_id, product_name, product_images 
FROM products 
WHERE product_id IN ('ROLEX_SUB_001', 'SEIKO_PRESAGE_001', 'APPLE_WATCH_001')
ORDER BY product_id;

SELECT '✅ Product images updated successfully!' as status; 