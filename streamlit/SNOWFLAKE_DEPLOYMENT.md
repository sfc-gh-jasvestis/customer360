# Streamlit in Snowflake Deployment Guide

## 🚀 Deploy Your Retail Watch Store to Streamlit in Snowflake

This app is configured to run natively in **Streamlit in Snowflake** (SiS). No external configuration or secrets.toml file is needed!

## Prerequisites

1. ✅ Snowflake account with Streamlit enabled
2. ✅ Database and AI functions deployed (run the SQL scripts first)
3. ✅ Appropriate Snowflake role with access to:
   - `RETAIL_WATCH_DB` database
   - `RETAIL_WATCH_WH` warehouse  
   - AI functions execution permissions

## Deployment Steps

### 1. Create Streamlit App in Snowflake

```sql
-- Connect to your Snowflake account and run:
USE DATABASE RETAIL_WATCH_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE RETAIL_WATCH_WH;

-- Create the Streamlit app
CREATE STREAMLIT "Personal_Watch_Shopper"
    ROOT_LOCATION = '@your_stage/streamlit'
    MAIN_FILE = 'watch_store_app.py'
    QUERY_WAREHOUSE = 'RETAIL_WATCH_WH';
```

### 2. Upload App Files

Upload these files to your Snowflake stage:
- `watch_store_app.py` (main application)
- `utils/database.py` (database utilities)

### 3. Launch the App

```sql
-- Show your Streamlit apps
SHOW STREAMLITS;

-- Get the app URL
SELECT SYSTEM$GET_STREAMLIT_APP_URL('Personal_Watch_Shopper');
```

## Key Features

✅ **No Secrets Required**: Uses `st.connection("snowflake")` for automatic authentication
✅ **Native Integration**: Direct access to your Snowflake data and AI functions  
✅ **High Performance**: Runs within Snowflake's secure environment
✅ **Auto-scaling**: Leverages Snowflake's compute resources

## Database Connection

The app uses Snowflake's native connection:

```python
# Automatically authenticated within Snowflake
conn = st.connection("snowflake")
data = conn.query("SELECT * FROM customers LIMIT 10")
```

## AI Functions Available

- `predict_customer_churn(customer_id)`
- `analyze_review_sentiment(review_text)`  
- `optimize_product_pricing(product_id)`
- `get_personal_recommendations(customer_id, context)`
- `get_customer_360_insights(customer_id)`

## Troubleshooting

**Error: "No secrets found"**
- ✅ **Solution**: This error occurs when trying to run locally. Deploy to Streamlit in Snowflake instead.

**Error: "Connection failed"**  
- ✅ Check your Snowflake role has access to the database and warehouse
- ✅ Ensure AI functions are deployed (`@sql/04_ai_functions.sql`)

**Error: "Function not found"**
- ✅ Run the complete deployment: `@sql/99_deploy_complete.sql`

## 🌟 Your Personal Watch Shopper is Ready!

Once deployed, your AI-powered retail watch store will be accessible directly within Snowflake with full native integration! ⌚🤖 