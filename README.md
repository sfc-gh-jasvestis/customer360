# Customer 360 & AI Assistant Demo - Powered by Snowflake

A comprehensive Customer 360 dashboard with AI assistant capabilities built on Snowflake's native AI/ML platform, featuring Cortex Agents, Cortex Search, and Cortex Analyst.

## 🏗️ Architecture Overview

This demo showcases a modern Customer 360 solution using Snowflake's integrated AI capabilities:

- **Data Platform**: Snowflake Data Cloud
- **AI Assistant**: Cortex Agents with multi-tool capabilities
- **Search**: Cortex Search for unstructured customer data
- **Analytics**: Cortex Analyst for natural language queries
- **Frontend**: Streamlit in Snowflake for interactive dashboards

## 🎯 Features

### 📊 Customer 360 Dashboard
- **Unified Customer Profiles**: Complete view of customer data, interactions, and preferences
- **Real-time Activity Feed**: Live customer interaction tracking
- **Purchase History & Analytics**: Comprehensive transaction analysis
- **Support Case Management**: Integrated support ticket system
- **Churn Risk Analysis**: AI-powered customer retention insights

### 🤖 AI Assistant (Cortex Agents)
- **Natural Language Interface**: Chat with your customer data
- **Multi-tool Integration**: 
  - `cortex_analyst_text_to_sql`: Convert natural language to SQL queries
  - `cortex_search`: Search through customer documents and transcripts
  - `sql_exec`: Execute analytical queries
  - `data_to_chart`: Generate visualizations
- **Customer-Specific Insights**: Context-aware recommendations
- **Real-time Analysis**: Instant customer profiling and risk assessment

### 🔍 Advanced Search (Cortex Search)
- **Semantic Search**: Find relevant customer information using natural language
- **Multi-source Integration**: Search across tickets, transcripts, and documents
- **Filtered Results**: Search by customer tier, region, or interaction type
- **RAG-powered Chat**: Retrieval-augmented generation for accurate responses

### 📈 Analytics (Cortex Analyst)
- **Natural Language Queries**: Ask questions about customer data in plain English
- **Automated Insights**: AI-generated customer behavior analysis
- **Visual Analytics**: Interactive charts and dashboards
- **Trend Analysis**: Historical patterns and predictive insights

## 🚀 Quick Start

### Prerequisites

- Snowflake account with CORTEX_USER database role
- Access to Snowflake Cortex features
- Streamlit in Snowflake enabled

### Step 1: Database Setup

```sql
-- Create database and warehouse
CREATE DATABASE IF NOT EXISTS customer_360_db;
CREATE OR REPLACE WAREHOUSE customer_360_wh WITH
    WAREHOUSE_SIZE='SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;

USE DATABASE customer_360_db;
USE WAREHOUSE customer_360_wh;
```

### Step 2: Load Sample Data

Run the provided SQL scripts to create customer tables and load sample data.

### Step 3: Configure Cortex Services

1. Create Cortex Search Service for customer documents
2. Set up semantic model for Cortex Analyst
3. Configure Cortex Agent with required tools

### Step 4: Deploy Streamlit App

1. Navigate to Snowsight → AI & ML → Studio
2. Create new Streamlit app
3. Copy the provided Streamlit code
4. Select the customer_360_db database

### Step 5: Start Exploring

Open the Streamlit app and begin interacting with your Customer 360 AI Assistant!

## 📁 Project Structure

```
├── sql/
│   ├── 01_setup_database.sql      # Database and warehouse setup
│   ├── 02_create_tables.sql       # Customer data tables
│   ├── 03_sample_data.sql         # Sample customer data
│   ├── 04_cortex_search.sql       # Cortex Search service setup
│   └── 05_semantic_model.yaml     # Cortex Analyst semantic model
├── streamlit/
│   ├── customer_360_app.py        # Main Streamlit application
│   ├── components/
│   │   ├── customer_profile.py    # Customer profile components
│   │   ├── ai_assistant.py        # AI chat interface
│   │   ├── analytics_dashboard.py # Analytics and charts
│   │   └── activity_feed.py       # Real-time activity feed
│   └── utils/
│       ├── cortex_client.py       # Cortex services integration
│       └── data_helpers.py        # Data processing utilities
├── assets/
│   └── demo_screenshots/          # Demo screenshots and videos
└── docs/
    ├── setup_guide.md             # Detailed setup instructions
    ├── cortex_configuration.md    # Cortex services configuration
    └── demo_scenarios.md          # Demo use cases and scenarios
```

## 🛠️ Cortex Configuration

### Cortex Agent Setup

```json
{
    "tools": [
        {
            "tool_spec": {
                "name": "customer_analytics",
                "type": "cortex_analyst_text_to_sql"
            }
        },
        {
            "tool_spec": {
                "name": "customer_search",
                "type": "cortex_search"
            }
        },
        {
            "tool_spec": {
                "type": "sql_exec",
                "name": "sql_exec"
            }
        },
        {
            "tool_spec": {
                "type": "data_to_chart",
                "name": "data_to_chart"
            }
        }
    ],
    "tool_resources": {
        "customer_analytics": {
            "semantic_model_file": "@customer_360_db.public.customer_semantic_model.yaml"
        },
        "customer_search": {
            "name": "customer_360_db.public.customer_documents",
            "max_results": 10,
            "title_column": "DOCUMENT_TITLE",
            "id_column": "CUSTOMER_ID"
        }
    }
}
```

## 🎬 Demo Scenarios

### Scenario 1: High-Value Customer Analysis
- **Query**: "Show me insights for our platinum customers who made purchases in the last 30 days"
- **AI Response**: Cortex Analyst generates SQL, executes query, and provides visual analytics

### Scenario 2: Churn Risk Assessment
- **Query**: "Which customers are at risk of churning and what should we do?"
- **AI Response**: Combines search results with predictive analytics for actionable insights

### Scenario 3: Support Case Resolution
- **Query**: "Find similar support cases for customer complaints about shipping delays"
- **AI Response**: Cortex Search finds relevant cases and suggests resolution strategies

### Scenario 4: Customer Journey Analysis
- **Query**: "What's the typical path from first contact to purchase for enterprise customers?"
- **AI Response**: Multi-tool analysis combining SQL analytics with document search

## 🔧 Environment Variables

Create a `.env` file or set these in your Snowflake account:

```bash
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_ROLE=CORTEX_USER_ROLE
SNOWFLAKE_WAREHOUSE=CUSTOMER_360_WH
SNOWFLAKE_DATABASE=CUSTOMER_360_DB
SNOWFLAKE_SCHEMA=PUBLIC
```

## 📊 Key Metrics Tracked

- **Customer Lifetime Value (CLV)**
- **Churn Risk Scores**
- **Support Ticket Resolution Times**
- **Product Affinity Analysis**
- **Engagement Scores**
- **Revenue Attribution**

## 🎯 Business Value

This demo showcases how Snowflake's integrated AI platform can:

1. **Unify Customer Data**: Single source of truth for all customer interactions
2. **Enable Self-Service Analytics**: Business users can query data in natural language
3. **Accelerate Decision Making**: Real-time insights and recommendations
4. **Improve Customer Experience**: Proactive identification of issues and opportunities
5. **Reduce Operational Costs**: Automated analysis and intelligent routing

## 🤝 Contributing

This demo is designed to be customizable for your specific use cases:

1. Modify the semantic model to match your data schema
2. Add custom tools to the Cortex Agent configuration
3. Extend the Streamlit interface with additional visualizations
4. Integrate with your existing Snowflake data pipelines

## 📚 References

- [Snowflake Cortex Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex)
- [Cortex Agents Tutorial](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
- [Cortex Search Guide](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)
- [Streamlit in Snowflake](https://docs.snowflake.com/en/developer-guide/streamlit) 