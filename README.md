# 🎯 Customer 360 & AI Assistant

> **🏔️ Native Snowflake Solution** - Deploy directly to **Streamlit in Snowflake** for maximum performance and ease!

A comprehensive **Customer 360** solution built entirely on the **Snowflake Data Cloud**, featuring AI-powered insights, real-time analytics, and an intuitive dashboard interface.

## ✨ **Key Features**

### 🎯 **Customer 360 View**
- **Unified Customer Profiles** - Complete customer journey visualization
- **Real-time Activity Tracking** - Live customer interactions and behaviors
- **Risk Assessment** - AI-powered churn prediction and intervention alerts
- **Customer Segmentation** - Dynamic tier-based customer grouping

### 🤖 **AI-Powered Insights**
- **Natural Language Queries** - Ask questions about your customers in plain English
- **Intelligent Recommendations** - AI-driven customer engagement suggestions
- **Advanced Search** - Text-based search across customer documents and activities
- **Automated Analysis** - Generate comprehensive customer reports instantly

### 📊 **Interactive Analytics**
- **Real-time Dashboards** - Live customer metrics and KPIs
- **Revenue Analytics** - Customer lifetime value and spending patterns
- **Engagement Metrics** - Satisfaction scores and interaction tracking
- **Trend Analysis** - Historical patterns and predictive insights

## 🏗️ **Architecture**

Built entirely on **Snowflake** for enterprise-grade performance:

```
┌─────────────────────┐    ┌──────────────────────┐    ┌─────────────────────┐
│   Streamlit in      │    │    Snowflake        │    │    AI & Search      │
│    Snowflake        │◄──►│   Data Cloud         │◄──►│    Functions        │
│  (Frontend/UI)      │    │  (Data Platform)     │    │  (Intelligence)     │
└─────────────────────┘    └──────────────────────┘    └─────────────────────┘
         │                            │                            │
         ▼                            ▼                            ▼
   Interactive                   Customer Data                AI Analysis
   Dashboards                   • customers                  • analyze_customer_ai
   • Customer 360               • customer_activities        • get_insights_summary  
   • Analytics                  • purchases                  • search_documents
   • AI Assistant               • support_tickets            • generate_reports
```

### **🔧 Technology Stack**
- **Frontend**: Streamlit in Snowflake (SiS) - No local dependencies!
- **Backend**: Snowflake Data Cloud with native SQL UDFs
- **AI Engine**: Snowflake Cortex functions with intelligent fallbacks
- **Data Storage**: Snowflake tables with optimized schemas
- **Analytics**: Native Snowflake SQL with Plotly visualizations

## 🚀 **Quick Start**

### **Step 1: Set Up Database**
```sql
-- Run the complete setup (includes all tables, functions, and sample data)
@sql/99_complete_setup.sql
```

### **Step 2: Deploy to Streamlit in Snowflake**
1. **Go to Snowflake Web UI** → **Projects** → **Streamlit**
2. **Click "✚ Streamlit App"**
3. **Configure**:
   - Name: `Customer_360_AI_Assistant`
   - Database: `CUSTOMER_360_DB`
   - Schema: `PUBLIC`
   - Warehouse: `CUSTOMER_360_WH`
4. **Copy & Paste** the contents of `streamlit/customer_360_sis_app.py`
5. **Click "Deploy"** 🚀

### **Step 3: Start Exploring!**
Your Customer 360 app will be available at:
`https://[your-account].snowflakecomputing.com/streamlit/Customer_360_AI_Assistant`

## 📁 **Project Structure**

```
customer360/
├── 📁 sql/                              # Database setup & configuration
│   ├── 01_setup_database.sql           # Database and warehouse creation
│   ├── 02_create_tables.sql            # Customer data schema
│   ├── 03_sample_data.sql              # Sample customer data
│   ├── 04_cortex_search.sql            # Search capabilities
│   ├── 06_cortex_agent.sql             # AI analysis functions
│   ├── 07_test_services.sql            # Service verification
│   ├── 10_deploy_streamlit.sql         # SiS deployment verification
│   └── 99_complete_setup.sql           # Complete automated setup
├── 📁 streamlit/                       # Streamlit in Snowflake app
│   ├── customer_360_sis_app.py         # 🏔️ Main SiS application
│   ├── DEPLOY_TO_SNOWFLAKE.md          # Deployment guide
│   ├── customer_360_app.py             # [Deprecated] Local version
│   └── 📁 components/                  # [Deprecated] Local components
├── 📁 scripts/                         # Automation & utilities
│   ├── reset_demo.sh                   # Complete reset automation
│   ├── quick_setup.py                  # Interactive Python setup
│   └── check_demo_status.sql           # Health verification
└── 📁 docs/                            # Documentation
    └── deployment_guide.md             # Detailed deployment guide
```

## 🎯 **Core Capabilities**

### **👤 Customer Profiles**
```sql
-- Get complete customer view
SELECT * FROM customers WHERE customer_id = 'CUST_001';

-- Analyze customer with AI
SELECT analyze_customer_ai('CUST_001');
```

### **🔍 Intelligent Search**
```sql
-- Search customer documents
SELECT search_customer_documents_text('billing issue');

-- Search activities
SELECT * FROM searchable_activities WHERE content LIKE '%support%';
```

### **📊 Advanced Analytics**
```sql
-- Customer insights dashboard
SELECT * FROM customer_360_dashboard;

-- High-risk customers
SELECT * FROM high_risk_customers;

-- Customer value segments
SELECT * FROM customer_value_segments;
```

## 🛠 **Development Setup**

### **Prerequisites**
- ✅ **Snowflake Account** (any edition)
- ✅ **Database Admin** privileges
- ✅ **Streamlit in Snowflake** access

### **Local Development** (Optional)
If you want to modify the code locally before deploying:

```bash
# Clone repository
git clone https://github.com/sfc-gh-jasvestis/customer360.git
cd customer360

# Set up Python environment (optional)
pip install streamlit pandas plotly snowflake-snowpark-python

# Edit the SiS app file
code streamlit/customer_360_sis_app.py
```

## 🏔️ **Deployment Methods**

### **Method 1: Web Interface** (Recommended)
1. Copy `streamlit/customer_360_sis_app.py` content
2. Paste into Snowflake Streamlit editor
3. Configure app settings
4. Deploy! 

**See**: `streamlit/DEPLOY_TO_SNOWFLAKE.md` for detailed steps

### **Method 2: SQL Commands**
```sql
-- Upload file to stage
PUT file://customer_360_sis_app.py @CUSTOMER_360_STAGE;

-- Create Streamlit app
CREATE STREAMLIT customer_360_ai_assistant
ROOT_LOCATION = '@CUSTOMER_360_STAGE'
MAIN_FILE = 'customer_360_sis_app.py'
QUERY_WAREHOUSE = 'CUSTOMER_360_WH';
```

## 🎨 **Demo Scenarios**

### **Scenario 1: Customer Risk Analysis**
- View high-risk customers dashboard
- Drill down into specific customer profiles
- Use AI to analyze churn probability
- Generate retention recommendations

### **Scenario 2: Revenue Optimization**
- Analyze customer value segments
- Identify upsell opportunities
- Track customer lifetime value trends
- Generate growth strategy reports

### **Scenario 3: Customer Support**
- Search support ticket history
- Analyze customer satisfaction trends
- Identify common issues
- Generate support insights

## 🔧 **Troubleshooting**

### **Common Issues & Solutions**

#### **❌ "Function Not Found" Errors**
```sql
-- Verify functions exist
SHOW FUNCTIONS LIKE '%customer%' IN CUSTOMER_360_DB.PUBLIC;

-- Re-run setup if needed
@sql/99_complete_setup.sql
```

#### **❌ "Permission Denied" Errors**
```sql
-- Grant necessary permissions
GRANT USAGE ON DATABASE CUSTOMER_360_DB TO ROLE [YOUR_ROLE];
GRANT SELECT ON ALL TABLES IN SCHEMA CUSTOMER_360_DB.PUBLIC TO ROLE [YOUR_ROLE];
```

#### **❌ "No Data" Issues**
```sql
-- Check if sample data loaded
SELECT COUNT(*) FROM customers;

-- Reload if needed
@sql/03_sample_data.sql
```

### **Getting Help**
- 📖 **Deployment Guide**: `streamlit/DEPLOY_TO_SNOWFLAKE.md`
- 🔍 **Status Check**: Run `scripts/check_demo_status.sql`
- 🔄 **Reset Demo**: Run `scripts/reset_demo.sh`

## 🤝 **Contributing**

We welcome contributions! See `CONTRIBUTING.md` for guidelines.

### **Quick Contribution Guide**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Snowflake
5. Submit a pull request

## 📄 **License**

This project is licensed under the MIT License - see the `LICENSE` file for details.

## 🏷️ **Tags**

`snowflake` `streamlit` `customer-360` `ai-assistant` `analytics` `data-cloud` `customer-insights` `real-time` `dashboard`

---

## 🎉 **Ready to Get Started?**

1. **🏔️ Deploy to Snowflake**: Use `streamlit/customer_360_sis_app.py`
2. **📊 Explore Your Data**: Interactive dashboards and AI insights
3. **🚀 Scale with Confidence**: Enterprise-grade Snowflake infrastructure

**Your Customer 360 & AI Assistant is just one deployment away!** ✨ 