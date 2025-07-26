# 🏔️ Deploy Customer 360 to Streamlit in Snowflake

This guide shows you how to deploy your Customer 360 & AI Assistant app to **Streamlit in Snowflake (SiS)**.

## 📋 **Prerequisites**

1. ✅ **Snowflake Account** with Streamlit enabled
2. ✅ **Customer 360 Database** already set up (from `sql/99_complete_setup.sql`)
3. ✅ **Required Permissions**:
   - `CREATE STREAMLIT` on database
   - `USAGE` on database and schema
   - `SELECT` on all tables and functions

## 🚀 **Deployment Methods**

### **Method 1: Using Snowflake Web Interface (Recommended)**

#### **Step 1: Access Streamlit Apps**
1. Log into your Snowflake account
2. Navigate to **Projects** → **Streamlit**
3. Click **"+ Streamlit App"**

#### **Step 2: Configure App**
- **App name**: `Customer_360_AI_Assistant`
- **Warehouse**: Select your warehouse (e.g., `CUSTOMER_360_WH`)
- **App location**: 
  - Database: `CUSTOMER_360_DB`
  - Schema: `PUBLIC`

#### **Step 3: Upload App Code**
1. Copy the entire contents of `customer_360_sis_app.py`
2. Paste into the Streamlit editor
3. Click **"Run"** to test
4. Click **"Deploy"** when ready

---

### **Method 2: Using SQL Commands**

#### **Step 1: Create Streamlit App**
```sql
USE DATABASE CUSTOMER_360_DB;
USE SCHEMA PUBLIC;

CREATE OR REPLACE STREAMLIT customer_360_ai_assistant
ROOT_LOCATION = '@CUSTOMER_360_STAGE'
MAIN_FILE = 'customer_360_sis_app.py'
QUERY_WAREHOUSE = 'CUSTOMER_360_WH';
```

#### **Step 2: Upload Files to Stage**
```sql
-- First, put the file in the stage
PUT file://customer_360_sis_app.py @CUSTOMER_360_STAGE overwrite=true;

-- Verify the file was uploaded
LIST @CUSTOMER_360_STAGE;
```

#### **Step 3: Grant Permissions**
```sql
-- Grant usage on streamlit to role
GRANT USAGE ON STREAMLIT customer_360_ai_assistant TO ROLE ACCOUNTADMIN;

-- Grant permissions to other roles as needed
GRANT USAGE ON STREAMLIT customer_360_ai_assistant TO ROLE [YOUR_ROLE];
```

---

## 🔧 **Configuration Steps**

### **1. Verify Database Setup**
Make sure your database is properly set up:

```sql
-- Check if all tables exist
SHOW TABLES IN CUSTOMER_360_DB.PUBLIC;

-- Check if all functions exist
SHOW FUNCTIONS IN CUSTOMER_360_DB.PUBLIC;

-- Test a function
SELECT analyze_customer_ai('CUST_001');
```

### **2. Test Data Access**
```sql
-- Verify customer data
SELECT COUNT(*) as customer_count FROM customers;

-- Check sample data
SELECT * FROM customers LIMIT 5;

-- Verify activities
SELECT COUNT(*) as activity_count FROM customer_activities;
```

### **3. Set Proper Permissions**
```sql
-- Grant select on all tables to the app role
GRANT SELECT ON ALL TABLES IN SCHEMA CUSTOMER_360_DB.PUBLIC TO ROLE [YOUR_ROLE];

-- Grant usage on all functions
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA CUSTOMER_360_DB.PUBLIC TO ROLE [YOUR_ROLE];

-- Grant usage on warehouse
GRANT USAGE ON WAREHOUSE CUSTOMER_360_WH TO ROLE [YOUR_ROLE];
```

---

## 🎯 **App Features in SiS**

Your deployed app will include:

### **📊 Dashboard Overview**
- Real-time customer metrics
- Customer tier distribution charts
- Top customer rankings
- Revenue analytics

### **👤 Customer Profiles**  
- Individual customer details
- Activity timelines
- Risk assessments
- Engagement metrics

### **🤖 AI Assistant**
- Natural language queries
- Customer-specific insights
- AI-powered recommendations
- Interactive chat interface

### **📈 Analytics Dashboard**
- Revenue by tier analysis
- Churn risk distribution
- Customer value segments
- Trend visualizations

### **📱 Activity Feed**
- Real-time activity monitoring
- Priority filtering
- Customer activity patterns
- Alert notifications

---

## 🛠 **Troubleshooting**

### **Common Issues:**

#### **1. "Permission Denied" Errors**
```sql
-- Grant necessary permissions
GRANT USAGE ON DATABASE CUSTOMER_360_DB TO ROLE [YOUR_ROLE];
GRANT USAGE ON SCHEMA CUSTOMER_360_DB.PUBLIC TO ROLE [YOUR_ROLE];
GRANT SELECT ON ALL TABLES IN SCHEMA CUSTOMER_360_DB.PUBLIC TO ROLE [YOUR_ROLE];
```

#### **2. "Function Not Found" Errors**
```sql
-- Check if functions exist
SHOW FUNCTIONS LIKE '%customer%' IN CUSTOMER_360_DB.PUBLIC;

-- If missing, re-run the setup
@sql/99_complete_setup.sql
```

#### **3. "Warehouse Not Available" Errors**
```sql
-- Check warehouse status
SHOW WAREHOUSES LIKE 'CUSTOMER_360_WH';

-- Resume warehouse if suspended
ALTER WAREHOUSE CUSTOMER_360_WH RESUME;
```

#### **4. "No Data" Issues**
```sql
-- Check if sample data was loaded
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM customer_activities;

-- If empty, reload sample data
@sql/03_sample_data.sql
```

---

## 🔗 **Access Your App**

Once deployed, you can access your app:

1. **Snowflake Web UI**: Projects → Streamlit → `Customer_360_AI_Assistant`
2. **Direct URL**: `https://[your-account].snowflakecomputing.com/streamlit/Customer_360_AI_Assistant`
3. **Share URL**: Use Snowflake's sharing features to share with team members

---

## 📚 **Next Steps**

### **1. Customize the App**
- Modify the UI components
- Add your own branding
- Customize color schemes
- Add additional metrics

### **2. Extend Functionality**
- Add more AI functions
- Create additional dashboards
- Integrate with external APIs
- Add export capabilities

### **3. Monitor Performance**
```sql
-- Monitor app usage
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.STREAMLIT_EVENTS
WHERE STREAMLIT_NAME = 'CUSTOMER_360_AI_ASSISTANT'
ORDER BY START_TIME DESC;
```

### **4. Share with Team**
```sql
-- Grant access to team roles
GRANT USAGE ON STREAMLIT customer_360_ai_assistant TO ROLE [TEAM_ROLE];
```

---

## 🎉 **Success!**

Your Customer 360 & AI Assistant is now running natively in Snowflake with:

- ✅ **No local dependencies** - Everything runs in Snowflake
- ✅ **Direct data access** - Native Snowpark integration  
- ✅ **Automatic scaling** - Snowflake handles infrastructure
- ✅ **Secure by default** - Leverages Snowflake security
- ✅ **Easy sharing** - Built-in collaboration features

**Ready to explore your customers with AI-powered insights!** 🚀 