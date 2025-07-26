-- =========================================
-- Customer 360 & AI Assistant Demo Setup
-- =========================================

-- Create database and schema
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

-- Grant necessary permissions for Cortex features
-- Note: You may need to run these as ACCOUNTADMIN
-- GRANT USAGE ON DATABASE customer_360_db TO ROLE your_role;
-- GRANT USAGE ON SCHEMA customer_360_db.public TO ROLE your_role;
-- GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE your_role;

-- Create stage for file uploads (if needed)
CREATE OR REPLACE STAGE customer_360_stage
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for Customer 360 demo files';

-- Verify setup
SELECT 'Database setup completed successfully' AS status,
       CURRENT_DATABASE() AS database_name,
       CURRENT_SCHEMA() AS schema_name,
       CURRENT_WAREHOUSE() AS warehouse_name,
       CURRENT_TIMESTAMP() AS setup_time; 