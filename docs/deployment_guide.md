# Customer 360 & AI Assistant Demo - Deployment Guide

This guide walks you through deploying the Customer 360 & AI Assistant demo built with Snowflake Cortex and Streamlit.

## 🏗️ Architecture Overview

The demo consists of:
- **Database Layer**: Snowflake tables with customer data
- **AI Layer**: Cortex Agents, Cortex Search, Cortex Analyst
- **Frontend**: Streamlit in Snowflake application
- **Real-time Features**: WebSocket-style updates and interactive dashboards

## 📋 Prerequisites

### Snowflake Requirements
- Snowflake account with **CORTEX_USER** role access
- Access to Snowflake Cortex features (Agents, Search, Analyst)
- Warehouse compute resources (SMALL or larger recommended)
- Streamlit in Snowflake enabled

### Required Privileges
```sql
-- Grant necessary roles (run as ACCOUNTADMIN)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE your_role;
GRANT USAGE ON WAREHOUSE compute_wh TO ROLE your_role;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE your_role;
```

## 🚀 Step-by-Step Deployment

### Step 1: Database Setup

1. **Connect to Snowflake** using SnowSQL, Snowsight, or your preferred client

2. **Run database setup scripts** in the following order:
   ```sql
   -- Execute each script in sequence
   @sql/01_setup_database.sql
   @sql/02_create_tables.sql  
   @sql/03_sample_data.sql
   ```

3. **Verify database setup**:
   ```sql
   USE DATABASE customer_360_db;
   USE SCHEMA public;
   
   -- Check tables were created
   SHOW TABLES;
   
   -- Verify sample data
   SELECT COUNT(*) FROM customers;
   SELECT COUNT(*) FROM customer_activities;
   ```

### Step 2: Configure Cortex Search

1. **Create search services**:
   ```sql
   @sql/04_cortex_search.sql
   ```

2. **Wait for indexing** (may take 5-10 minutes):
   ```sql
   -- Check search service status
   DESCRIBE CORTEX SEARCH SERVICE customer_documents_search;
   ```

3. **Test search functionality**:
   ```sql
   -- Test document search
   SELECT * FROM TABLE(
       CORTEX_SEARCH(
           'customer_documents_search',
           'billing issues customer complaints'
       )
   ) LIMIT 5;
   ```

### Step 3: Set Up Semantic Model

1. **Upload semantic model file**:
   - Navigate to Snowsight → Data → Databases → customer_360_db → public
   - Click on the `customer_360_semantic_model_stage`
   - Upload `sql/05_semantic_model.yaml`

2. **Alternative using SnowSQL**:
   ```bash
   snowsql -c your_connection -q "USE DATABASE customer_360_db;"
   snowsql -c your_connection -q "PUT file://sql/05_semantic_model.yaml @customer_360_semantic_model_stage;"
   ```

### Step 4: Create Cortex Agent

1. **Deploy the Cortex Agent**:
   ```sql
   @sql/06_cortex_agent.sql
   ```

2. **Test agent functionality**:
   ```sql
   -- Test basic AI queries
   SELECT ask_customer_360_ai('How many customers do we have?');
   SELECT analyze_customer('CUST_001', 'overview');
   ```

### Step 5: Deploy Streamlit Application

1. **Navigate to Streamlit in Snowflake**:
   - Go to Snowsight → AI & ML → Studio
   - Click **+ Create** → **Streamlit App**

2. **Configure the app**:
   - **App Name**: `Customer 360 AI Assistant`
   - **Warehouse**: `customer_360_wh`
   - **Database**: `customer_360_db`
   - **Schema**: `public`

3. **Upload application files**:
   - Main app: Copy content from `streamlit/customer_360_app.py`
   - Create folder structure for components and utils
   - Upload all files from the `streamlit/` directory

4. **Install dependencies** (if needed):
   ```python
   # Add to requirements.txt in Streamlit
   plotly
   pandas
   streamlit
   ```

### Step 6: Configure Connections

1. **Set up Snowflake connection** in Streamlit:
   ```python
   # This should work automatically in Streamlit in Snowflake
   conn = st.connection("snowflake")
   ```

2. **Test data connectivity**:
   - Run the Streamlit app
   - Check that customer data loads in the sidebar
   - Verify dashboard metrics display correctly

## 🔧 Configuration Options

### Environment Variables

If using external Streamlit deployment, create `.env`:
```env
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_USER=your_username  
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_ROLE=your_role
SNOWFLAKE_WAREHOUSE=customer_360_wh
SNOWFLAKE_DATABASE=customer_360_db
SNOWFLAKE_SCHEMA=public
```

### Cortex Agent Customization

Modify the agent instructions in `sql/06_cortex_agent.sql`:
```sql
CREATE OR REPLACE CORTEX AGENT customer_360_ai_assistant (
    INSTRUCTIONS = 'Your custom instructions here...'
) AS (
    -- Tool configurations
);
```

### Search Service Tuning

Adjust search parameters in `sql/04_cortex_search.sql`:
```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE customer_documents_search
ON document_content
ATTRIBUTES document_title, document_type, customer_id
WAREHOUSE = customer_360_wh
TARGET_LAG = '1 minute'  -- Adjust for faster updates
```

## 🧪 Testing the Deployment

### 1. Database Tests
```sql
-- Test data integrity
SELECT 
    COUNT(*) as customer_count,
    AVG(churn_risk_score) as avg_churn_risk,
    COUNT(DISTINCT customer_tier) as tier_count
FROM customers;

-- Test relationships
SELECT c.first_name, c.last_name, COUNT(a.activity_id) as activities
FROM customers c
LEFT JOIN customer_activities a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY activities DESC;
```

### 2. Cortex Services Tests
```sql
-- Test Cortex Search
SELECT * FROM TABLE(
    CORTEX_SEARCH('customer_documents_search', 'shipping delay')
) LIMIT 3;

-- Test Cortex Agent
SELECT ask_customer_360_ai('Show me high-risk customers');

-- Test Cortex Analyst
SELECT analyze_customer('CUST_001', 'churn_risk');
```

### 3. Streamlit Application Tests

1. **Navigation Test**: Verify all tabs and pages load
2. **Data Display Test**: Check customer profiles, charts, and metrics
3. **AI Assistant Test**: Try various queries in the chat interface
4. **Real-time Features**: Verify activity feed updates
5. **Search and Filters**: Test customer search and filtering

## 🔧 Troubleshooting

### Common Issues

#### 1. Cortex Services Not Available
```sql
-- Check if Cortex is enabled
SHOW GRANTS TO ROLE your_role;

-- Enable Cortex user role
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE your_role;
```

#### 2. Search Service Not Ready
```sql
-- Check service status
DESCRIBE CORTEX SEARCH SERVICE customer_documents_search;

-- Wait for status to show 'READY'
-- May take 5-10 minutes after creation
```

#### 3. Semantic Model File Issues
```sql
-- Check if file was uploaded
LIST @customer_360_semantic_model_stage;

-- Re-upload if missing
PUT file://sql/05_semantic_model.yaml @customer_360_semantic_model_stage;
```

#### 4. Streamlit Connection Issues
- Verify warehouse is running and accessible
- Check database and schema permissions
- Ensure connection configuration is correct

### Performance Optimization

#### 1. Warehouse Sizing
```sql
-- Scale up for better performance
ALTER WAREHOUSE customer_360_wh SET WAREHOUSE_SIZE = 'MEDIUM';

-- Auto-suspend to save costs
ALTER WAREHOUSE customer_360_wh SET AUTO_SUSPEND = 300;
```

#### 2. Query Optimization
```sql
-- Add clustering keys for large tables
ALTER TABLE customer_activities CLUSTER BY (customer_id, activity_timestamp);
```

#### 3. Search Performance
```sql
-- Monitor search service performance
SELECT * FROM TABLE(INFORMATION_SCHEMA.CORTEX_SEARCH_SERVICE_USAGE_HISTORY());
```

## 🎯 Demo Scenarios

### Scenario 1: High-Value Customer Analysis
1. Navigate to Customer Profile → Select Sarah Johnson (Platinum)
2. Go to AI Insights tab → Generate insights
3. Ask AI: "What opportunities exist with this customer?"

### Scenario 2: Churn Risk Assessment  
1. Go to Analytics Dashboard → Risk Assessment tab
2. Identify high-risk customers (Emma Davis)
3. Use AI Assistant: "How can we reduce Emma's churn risk?"

### Scenario 3: Support Issue Analysis
1. Check Activity Feed for support activities
2. Use AI search: "Find customers with billing complaints"
3. Generate resolution recommendations

### Scenario 4: Revenue Optimization
1. Analytics Dashboard → Revenue Analytics
2. AI query: "Which customer segment has the highest growth potential?"
3. Explore cross-sell opportunities

## 📊 Monitoring and Maintenance

### Performance Monitoring
```sql
-- Monitor warehouse usage
SELECT * FROM TABLE(INFORMATION_SCHEMA.WAREHOUSE_METERING_HISTORY());

-- Check query performance
SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY()) 
WHERE QUERY_TEXT LIKE '%customer_360%'
ORDER BY START_TIME DESC;
```

### Data Refresh
```sql
-- Add new sample data periodically
INSERT INTO customer_activities (
    activity_id, customer_id, activity_type, activity_title, 
    activity_description, activity_timestamp, channel, priority
) VALUES (
    'ACT_' || CURRENT_TIMESTAMP()::STRING, 
    'CUST_001', 
    'login', 
    'Account Login',
    'Logged into customer portal',
    CURRENT_TIMESTAMP(),
    'web',
    'low'
);
```

### Security Best Practices
1. Use least-privilege access principles
2. Regularly rotate credentials
3. Monitor access logs
4. Enable network policies if needed

## 🎉 Success Criteria

Your deployment is successful when:

- ✅ All database tables are created and populated
- ✅ Cortex Search returns relevant results
- ✅ Cortex Agent responds to queries
- ✅ Streamlit app loads without errors
- ✅ Customer profiles display correctly
- ✅ AI Assistant provides meaningful responses
- ✅ Analytics dashboards show visualizations
- ✅ Activity feed displays real-time data

## 📞 Support

For issues and questions:
1. Check Snowflake documentation for Cortex features
2. Review Streamlit in Snowflake guides
3. Consult the troubleshooting section above
4. Contact your Snowflake account team for Cortex-specific issues

## 🔄 Updates and Extensions

### Adding New Data Sources
1. Create new tables following the existing schema patterns
2. Update the semantic model YAML file
3. Refresh the Cortex Agent configuration
4. Add new visualizations to Streamlit components

### Customizing AI Responses
1. Modify agent instructions in `sql/06_cortex_agent.sql`
2. Add new tools or update existing tool configurations
3. Create custom functions for specific business logic

### Scaling for Production
1. Implement proper data governance
2. Add user authentication and authorization
3. Set up monitoring and alerting
4. Optimize for larger data volumes
5. Implement CI/CD for updates 