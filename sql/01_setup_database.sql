-- ============================================================================
-- Retail Watch Store - Customer 360 Database Setup
-- ============================================================================
-- This script sets up the database, warehouse, and initial configuration
-- for a retail watch store with AI-powered customer analytics

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

SELECT '🏪 Retail Watch Store Database Created Successfully!' as setup_status;
SELECT CURRENT_DATABASE() as database_name, CURRENT_WAREHOUSE() as warehouse_name;

-- Enable Cortex functions for AI capabilities
SELECT 'Snowflake Cortex AI functions will be used for:' as ai_features;
SELECT '• Churn Prediction Analysis' as feature_1;
SELECT '• Sentiment Analysis of Reviews' as feature_2; 
SELECT '• Price Optimization Engine' as feature_3;
SELECT '• Personal Shopping Recommendations' as feature_4; 