# 🚀 Customer 360 & AI Assistant - Deployment Guide

> **🏔️ Primary Deployment: Streamlit in Snowflake (SiS)**  
> This guide focuses on the **recommended** native Snowflake deployment approach.

## 📋 **Overview**

This comprehensive guide covers deploying your Customer 360 & AI Assistant to **Streamlit in Snowflake**, providing a native, scalable, and maintenance-free solution.

## 🎯 **Deployment Options**

### ✅ **Option 1: Streamlit in Snowflake (Recommended)**
- **✅ No local dependencies** - Everything runs in Snowflake
- **✅ Native data access** - Direct Snowpark integration
- **✅ Auto-scaling** - Snowflake handles infrastructure
- **✅ Enterprise security** - Built-in Snowflake security
- **✅ Easy sharing** - Native collaboration features

### ❌ **Option 2: Local Streamlit (Deprecated)**
- **❌ Complex setup** - Python environment management
- **❌ Dependency conflicts** - Package version issues
- **❌ Connection management** - Manual credential handling
- **❌ Limited scalability** - Single machine constraints

---

## 🏔️ **Primary Deployment: Streamlit in Snowflake**

### **📋 Prerequisites**

1. ✅ **Snowflake Account** (any edition)
2. ✅ **Streamlit Access** - Available in most Snowflake plans
3. ✅ **Database Setup** - Customer 360 database already created
4. ✅ **Required Permissions**:
   - `CREATE STREAMLIT` on database
   - `USAGE` on database and schema
   - `SELECT` on all tables and functions
   - `USAGE` on warehouse

### **🗄️ Step 1: Database Setup**

Run the complete database setup:

```sql
-- Execute the master setup script
@sql/99_complete_setup.sql

-- Verify installation
@sql/07_test_services.sql
```

**Expected Output:**
```
✅ Database: CUSTOMER_360_DB created
✅ Warehouse: CUSTOMER_360_WH created  
✅ Tables: 4 tables created
✅ Functions: 6+ AI functions created
✅ Sample Data: 100+ records loaded
```

### **🏔️ Step 2: Deploy to Streamlit in Snowflake**

#### **Method A: Web Interface (Easiest)**

1. **Access Streamlit**:
   - Log into Snowflake
   - Navigate: **Projects** → **Streamlit**
   - Click **"✚ Streamlit App"**

2. **Configure App**:
   ```
   App Name: Customer_360_AI_Assistant
   Database: CUSTOMER_360_DB
   Schema: PUBLIC
   Warehouse: CUSTOMER_360_WH
   ```

3. **Deploy Code**:
   - Copy entire contents of `streamlit/customer_360_sis_app.py`
   - Paste into Snowflake editor
   - Click **"Run"** to test
   - Click **"Deploy"** when ready

4. **Access Your App**:
   ```
   URL: https://[account].snowflakecomputing.com/streamlit/Customer_360_AI_Assistant
   ```

#### **Method B: SQL Commands (Advanced)**

```sql
-- Set context
USE DATABASE CUSTOMER_360_DB;
USE SCHEMA PUBLIC;

-- Upload app file to stage
PUT file://customer_360_sis_app.py @CUSTOMER_360_STAGE overwrite=true;

-- Create Streamlit app
CREATE OR REPLACE STREAMLIT customer_360_ai_assistant
ROOT_LOCATION = '@CUSTOMER_360_STAGE'
MAIN_FILE = 'customer_360_sis_app.py'
QUERY_WAREHOUSE = 'CUSTOMER_360_WH'
COMMENT = 'Customer 360 & AI Assistant - Native Snowflake Solution';

-- Grant permissions
GRANT USAGE ON STREAMLIT customer_360_ai_assistant TO ROLE [YOUR_ROLE];
```

### **🔧 Step 3: Verify Deployment**

Run the deployment verification script:

```sql
@sql/10_deploy_streamlit.sql
```

Expected checks:
- ✅ Database and tables accessible
- ✅ AI functions working
- ✅ Sample data loaded
- ✅ Warehouse active
- ✅ Streamlit app created

### **👥 Step 4: Share with Team**

```sql
-- Grant app access to team members
GRANT USAGE ON STREAMLIT customer_360_ai_assistant TO ROLE [TEAM_ROLE];

-- Share database access
GRANT USAGE ON DATABASE CUSTOMER_360_DB TO ROLE [TEAM_ROLE];
GRANT SELECT ON ALL TABLES IN SCHEMA CUSTOMER_360_DB.PUBLIC TO ROLE [TEAM_ROLE];
```

---

## 🎯 **App Features**

Your deployed Streamlit in Snowflake app includes:

### **📊 Dashboard Overview**
- Real-time customer metrics and KPIs
- Customer tier distribution with interactive charts
- Top customer rankings by value
- Revenue and engagement analytics

### **👤 Customer Profiles**
- Comprehensive individual customer views
- Activity timelines and interaction history
- Risk assessment and churn predictions
- Engagement scoring and satisfaction metrics

### **🤖 AI Assistant**
- Natural language query interface
- Customer-specific AI insights and analysis
- Automated recommendation generation
- Interactive chat with context awareness

### **📈 Analytics Dashboard**
- Revenue analysis by customer tier
- Churn risk distribution visualization
- Customer value segmentation
- Trend analysis and forecasting

### **📱 Activity Feed**
- Real-time customer activity monitoring
- Priority-based filtering and alerts
- Customer interaction patterns
- Support ticket and engagement tracking

---

## 🛠️ **Troubleshooting**

### **Common Issues & Solutions**

#### **🔴 "Permission Denied" Errors**
```sql
-- Verify role permissions
SHOW GRANTS TO ROLE [YOUR_ROLE];

-- Grant necessary permissions
GRANT USAGE ON DATABASE CUSTOMER_360_DB TO ROLE [YOUR_ROLE];
GRANT USAGE ON SCHEMA CUSTOMER_360_DB.PUBLIC TO ROLE [YOUR_ROLE];
GRANT SELECT ON ALL TABLES IN SCHEMA CUSTOMER_360_DB.PUBLIC TO ROLE [YOUR_ROLE];
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA CUSTOMER_360_DB.PUBLIC TO ROLE [YOUR_ROLE];
```

#### **🔴 "Function Not Found" Errors**
```sql
-- Check if AI functions exist
SHOW FUNCTIONS LIKE '%customer%' IN CUSTOMER_360_DB.PUBLIC;

-- Recreate functions if missing
@sql/06_cortex_agent.sql
```

#### **🔴 "Warehouse Suspended" Errors**
```sql
-- Check warehouse status
SHOW WAREHOUSES LIKE 'CUSTOMER_360_WH';

-- Resume warehouse
ALTER WAREHOUSE CUSTOMER_360_WH RESUME;

-- Set auto-resume
ALTER WAREHOUSE CUSTOMER_360_WH SET AUTO_RESUME = TRUE;
```

#### **🔴 "No Data Available" Issues**
```sql
-- Verify sample data
SELECT COUNT(*) as customers FROM customers;
SELECT COUNT(*) as activities FROM customer_activities;

-- Reload data if empty
@sql/03_sample_data.sql
```

#### **🔴 Streamlit App Not Loading**
1. **Check app status** in Snowflake UI → Projects → Streamlit
2. **Verify warehouse** is running and accessible
3. **Check permissions** on database and schema
4. **Review error logs** in Streamlit interface

### **🔍 Diagnostic Queries**

```sql
-- Check overall system health
SELECT 
    'Database' as component,
    COUNT(*) as status 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'PUBLIC';

-- Verify AI functions
SELECT 
    'AI Functions' as component,
    COUNT(*) as status
FROM INFORMATION_SCHEMA.FUNCTIONS 
WHERE FUNCTION_SCHEMA = 'PUBLIC' 
AND FUNCTION_NAME LIKE '%CUSTOMER%';

-- Test core functionality
SELECT analyze_customer_ai('CUST_001') as ai_test;
```

---

## 📊 **Performance & Monitoring**

### **📈 Monitor App Usage**
```sql
-- View app usage statistics
SELECT 
    DATE(START_TIME) as usage_date,
    COUNT(*) as sessions,
    COUNT(DISTINCT USER_NAME) as unique_users
FROM SNOWFLAKE.ACCOUNT_USAGE.STREAMLIT_EVENTS
WHERE STREAMLIT_NAME = 'CUSTOMER_360_AI_ASSISTANT'
GROUP BY DATE(START_TIME)
ORDER BY usage_date DESC;
```

### **⚡ Performance Optimization**
```sql
-- Optimize warehouse size based on usage
ALTER WAREHOUSE CUSTOMER_360_WH SET WAREHOUSE_SIZE = 'SMALL'; -- Adjust as needed

-- Enable result caching
ALTER WAREHOUSE CUSTOMER_360_WH SET USE_CACHED_RESULT = TRUE;
```

---

## ⚠️ **Deprecated: Local Deployment**

> **🚨 The local Streamlit deployment is DEPRECATED.**  
> **Use Streamlit in Snowflake instead for better performance and maintenance.**

If you still need local deployment for development purposes, see:
- `streamlit/DEPRECATED_LOCAL_VERSION.md`
- `streamlit/customer_360_app.py` (deprecated)

---

## 🚀 **Next Steps**

### **1. Customize Your App**
- Modify UI components in `customer_360_sis_app.py`
- Add custom metrics and visualizations
- Integrate with your existing data sources

### **2. Extend Functionality**
- Create additional AI analysis functions
- Add more dashboard views
- Implement custom search capabilities

### **3. Production Readiness**
- Set up monitoring and alerts
- Configure backup and recovery
- Implement role-based access control

### **4. Scale and Share**
- Grant access to additional team members
- Create departmental views
- Integrate with BI tools

---

## 🎉 **Success!**

Your **Customer 360 & AI Assistant** is now running natively in Snowflake with:

- ✅ **Zero maintenance** - Snowflake handles infrastructure
- ✅ **Enterprise security** - Built-in data protection
- ✅ **Auto-scaling** - Handles any workload size
- ✅ **Native integration** - Direct access to all Snowflake features
- ✅ **Team collaboration** - Easy sharing and permissions

**🔗 Access your app**: `https://[your-account].snowflakecomputing.com/streamlit/Customer_360_AI_Assistant`

**Ready to explore your customer data with AI-powered insights!** 🚀 