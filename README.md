# Customer 360 & AI Assistant Demo

**A comprehensive Snowflake-native customer data platform with AI-powered insights and real-time analytics.**

> 🚀 **Compatible with all Snowflake editions** - No premium features required!

## 🎯 Overview

This demo showcases a complete Customer 360 solution built entirely on Snowflake, featuring:

- **🏪 Customer 360 Dashboard** - Comprehensive customer profiles with risk scoring
- **🤖 AI-Powered Analysis** - Intelligent customer insights and recommendations  
- **🔍 Advanced Search** - Text-based document and activity search
- **📊 Real-time Analytics** - Customer behavior and engagement metrics
- **⚠️ Risk Assessment** - Churn prediction and retention strategies
- **🎨 Beautiful UI** - Modern Streamlit interface with interactive charts

## ✨ Key Features

### 📈 Customer Analytics
- **360° Customer Profiles** with financial and behavioral metrics
- **Churn Risk Scoring** with automated recommendations
- **Customer Segmentation** by tier, value, and engagement
- **Activity Timeline** tracking all customer interactions

### 🔍 Intelligent Search
- **Document Search** across support tickets, contracts, and feedback
- **Activity Search** through customer behavior history
- **Relevance Scoring** for precise result ranking
- **Quick Filters** by customer tier, document type, and date ranges

### 🤖 AI-Powered Insights
- **Customer Analysis** with risk assessment and opportunities
- **Business Intelligence** with automated insights discovery
- **Recommendation Engine** for next-best actions
- **Performance Analytics** across customer segments

### 📊 Rich Visualizations
- **Interactive Dashboards** built with Plotly
- **Real-time Metrics** and KPI tracking
- **Customer Journey Mapping** with activity flows
- **Risk Heatmaps** and trend analysis

## 🚀 Quick Start

### Prerequisites
- Snowflake account (any edition)
- Basic SQL execution permissions
- Python 3.8+ (for Streamlit app)

### 1. Setup Database & Data

```sql
-- Run the complete setup (creates everything)
@sql/99_complete_setup.sql
```

### 2. Test Your Installation

```sql
-- Verify everything is working
@sql/07_test_services.sql
```

### 3. Try Key Features

```sql
-- Search for documents
SELECT * FROM TABLE(search_documents_simple('billing')) LIMIT 5;

-- Analyze a customer
SELECT analyze_customer_ai('CUST_001');

-- View high-risk customers
SELECT * FROM high_risk_customers;

-- Dashboard overview
SELECT * FROM customer_360_dashboard;
```

## 📁 Project Structure

```
customer-360-demo/
├── sql/                          # Database setup and functions
│   ├── 00_cleanup_demo.sql       # Reset/cleanup script
│   ├── 01_setup_database.sql     # Database and warehouse setup
│   ├── 02_create_tables.sql      # Schema creation
│   ├── 03_sample_data.sql        # Sample data loading
│   ├── 04_cortex_search.sql      # Search functions (no Cortex required)
│   ├── 06_cortex_agent.sql       # AI analysis functions
│   ├── 07_test_services.sql      # Verification and testing
│   └── 99_complete_setup.sql     # One-click full setup ⭐
├── streamlit/                    # Web application
│   ├── customer_360_app.py       # Main application
│   ├── components/               # UI components
│   └── utils/                    # Helper functions
├── scripts/                      # Automation scripts
│   ├── reset_demo.sh            # Demo reset automation
│   ├── quick_setup.py           # Interactive setup
│   └── check_demo_status.sql    # Status verification
├── docs/                        # Documentation
│   └── deployment_guide.md     # Detailed deployment guide
└── README.md                    # This file
```

## 🎮 Demo Scenarios

### Scenario 1: High-Risk Customer Analysis
```sql
-- Find customers at risk of churning
SELECT customer_name, churn_risk_score, risk_level, 
       recent_activity_count, open_tickets
FROM customer_360_dashboard 
WHERE risk_level = 'HIGH'
ORDER BY churn_risk_score DESC;

-- Get detailed analysis with recommendations
SELECT analyze_customer_ai('CUST_003');
```

### Scenario 2: Customer Support Intelligence
```sql
-- Search support conversations for billing issues
SELECT * FROM TABLE(search_documents_simple('billing problems')) LIMIT 10;

-- Find customers with recent support activity
SELECT customer_name, customer_tier, total_tickets, open_tickets
FROM customer_360_dashboard 
WHERE open_tickets > 0;
```

### Scenario 3: Customer Segmentation Analysis
```sql
-- Analyze performance by customer tier
SELECT * FROM customer_value_segments;

-- Find high-value customers for upselling
SELECT customer_name, customer_tier, total_spent, engagement_level
FROM customer_360_dashboard 
WHERE engagement_level = 'HIGH' AND customer_tier IN ('gold', 'silver');
```

## 🔧 Advanced Configuration

### Adding More Sample Data
Extend the sample dataset in `sql/03_sample_data.sql`:

```sql
-- Add more customers
INSERT INTO customers (...) VALUES (...);
UPDATE customers SET customer_tags = PARSE_JSON('[...]') WHERE customer_id = '...';
```

### Custom Search Functions
Create domain-specific search functions:

```sql
CREATE OR REPLACE FUNCTION search_by_sentiment(sentiment STRING)
RETURNS TABLE(...) AS $$
    SELECT * FROM searchable_documents 
    WHERE searchable_text LIKE CONCAT('%', UPPER(sentiment), '%')
    ORDER BY created_at DESC
$$;
```

### Enhanced Analytics
Add custom metrics and KPIs:

```sql
CREATE OR REPLACE VIEW customer_lifetime_metrics AS
SELECT 
    customer_id,
    DATEDIFF('day', join_date, CURRENT_DATE()) as days_as_customer,
    total_spent / NULLIF(DATEDIFF('day', join_date, CURRENT_DATE()), 0) as daily_value,
    -- Add more custom metrics
FROM customers;
```

## 🎨 Streamlit Application

### Setup
```bash
# Install dependencies
pip install streamlit snowflake-connector-python plotly pandas

# Run the application
streamlit run streamlit/customer_360_app.py
```

### Features
- **Interactive Dashboard** with real-time metrics
- **Customer Search** with advanced filtering
- **AI Chat Interface** for natural language queries
- **Visual Analytics** with Plotly charts
- **Export Capabilities** for reports and data

## 🔍 Available Functions & Views

### 🔧 Search Functions
- `search_documents_simple(search_terms)` - Basic document search
- `search_documents_advanced(terms, type, tier, days)` - Advanced search with filters
- `search_activities_advanced(terms, type, days)` - Activity search

### 🤖 AI Functions  
- `analyze_customer_ai(customer_id)` - Comprehensive customer analysis
- `generate_customer_report(customer_id)` - Detailed customer report
- `get_customer_insights_summary()` - Business intelligence insights

### 📊 Dashboard Views
- `customer_360_dashboard` - Main customer dashboard
- `high_risk_customers` - Customers with high churn risk
- `customer_value_segments` - Customer tier analysis
- `searchable_documents` - All documents with search metadata
- `support_related_content` - Support tickets and conversations
- `billing_related_content` - Billing-related documents and activities

## 🛠️ Troubleshooting

### Common Issues

**1. "Unknown function" errors**
```sql
-- Verify functions are created
SHOW USER FUNCTIONS;

-- Recreate if needed
@sql/06_cortex_agent.sql
```

**2. "Table not found" errors**
```sql
-- Check table creation
SHOW TABLES;

-- Recreate schema if needed
@sql/02_create_tables.sql
```

**3. Empty search results**
```sql
-- Verify sample data
SELECT COUNT(*) FROM customer_documents;

-- Reload data if needed
@sql/03_sample_data.sql
```

### Reset Demo
```sql
-- Complete reset and fresh setup
@sql/00_cleanup_demo.sql
@sql/99_complete_setup.sql
```

## 📚 Sample Data

The demo includes realistic sample data:

- **5 Customers** across different tiers (Bronze to Platinum)
- **11+ Activities** including purchases, logins, support tickets
- **4 Documents** with support conversations and contracts  
- **3 Support Tickets** with various priorities and statuses
- **Multiple Communications** with engagement tracking

### Customer Profiles
- **Sarah Johnson** (Platinum) - High-value tech enthusiast
- **Michael Chen** (Gold) - Frequent buyer with shipping issues  
- **Emma Davis** (Silver) - At-risk customer with billing problems
- **James Wilson** (Bronze) - New customer with high potential
- **Lisa Rodriguez** (Platinum) - Enterprise VIP customer

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📧 Create an issue for bug reports or feature requests
- 💬 Start a discussion for questions and ideas
- 📖 Check the [deployment guide](docs/deployment_guide.md) for detailed instructions

## 🎉 Acknowledgments

- Built for **Snowflake Data Cloud**
- UI powered by **Streamlit**
- Charts created with **Plotly**
- Compatible with **all Snowflake editions**

---

**🚀 Ready to explore your Customer 360 platform? Start with `@sql/99_complete_setup.sql`!** 