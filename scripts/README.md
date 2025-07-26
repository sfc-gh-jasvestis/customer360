# Customer 360 Demo - Reset & Setup Scripts

This directory contains scripts to easily reset and redeploy the Customer 360 & AI Assistant demo from scratch.

## 🎯 Purpose

These scripts are designed for:
- **Demo presentations** - Start with a clean slate
- **Development cycles** - Quick reset during testing
- **Troubleshooting** - Fix issues by starting over
- **Training sessions** - Multiple clean deployments

## 📁 Files Overview

### SQL Scripts

| File | Purpose | Description |
|------|---------|-------------|
| `00_cleanup_demo.sql` | 🧹 Cleanup | Removes all demo objects completely |
| `99_complete_setup.sql` | 🏗️ Full Setup | Creates entire demo from scratch |
| `check_demo_status.sql` | 📊 Status Check | Verifies demo state and readiness |

### Automation Scripts

| File | Purpose | Description |
|------|---------|-------------|
| `reset_demo.sh` | 🔄 Bash Automation | Complete reset via bash script |
| `quick_setup.py` | 🐍 Interactive Setup | Python interactive demo manager |

---

## 🚀 Quick Start Options

### Option 1: Interactive Python Setup (Recommended)

```bash
# Run interactive setup manager
python3 scripts/quick_setup.py
```

**Features:**
- ✅ Interactive menu system
- ✅ Connection testing
- ✅ Step-by-step guidance
- ✅ Error handling and recovery
- ✅ Status checking

### Option 2: Bash Script Automation

```bash
# Make executable
chmod +x scripts/reset_demo.sh

# Run with your connection
./scripts/reset_demo.sh -c your_connection_name
```

### Option 3: Manual SQL Execution

```sql
-- 1. Clean up (optional)
@scripts/../sql/00_cleanup_demo.sql

-- 2. Complete setup
@scripts/../sql/99_complete_setup.sql

-- 3. Check status
@scripts/../sql/check_demo_status.sql
```

---

## 📋 Detailed Instructions

### Prerequisites

1. **SnowSQL CLI installed**
   ```bash
   # Install from: https://docs.snowflake.com/en/user-guide/snowsql-install-config
   snowsql --version
   ```

2. **Snowflake connection configured**
   ```bash
   # List connections
   snowsql -l
   
   # Test connection
   snowsql -c your_connection -q "SELECT CURRENT_USER();"
   ```

3. **Required Snowflake privileges**
   - `CORTEX_USER` database role
   - `CREATE DATABASE` privilege
   - Warehouse usage permissions

### Step-by-Step Process

#### 1. Cleanup Existing Demo (if needed)

**Purpose:** Remove all existing demo objects to start fresh

```sql
-- Run cleanup script
@sql/00_cleanup_demo.sql
```

**What it removes:**
- Cortex Agents and functions
- Cortex Search services
- All tables and views
- Sample data
- Stages

**⚠️ Warning:** This deletes ALL demo data!

#### 2. Complete Demo Setup

**Purpose:** Create entire demo infrastructure

```sql
-- Run complete setup
@sql/99_complete_setup.sql
```

**What it creates:**
- Database: `customer_360_db`
- Warehouse: `customer_360_wh`
- 6 core tables with sample data
- Views and indexes
- Cortex Search services
- Helper functions

#### 3. Manual Steps Required

**Upload Semantic Model:**
1. Go to Snowsight → Data → Databases → customer_360_db → public
2. Click on `customer_360_semantic_model_stage`
3. Upload `sql/05_semantic_model.yaml`

**Create Cortex Agent:**
```sql
@sql/06_cortex_agent.sql
```

#### 4. Deploy Streamlit App

1. Snowsight → AI & ML → Studio
2. Create new Streamlit app
3. Upload files from `streamlit/` directory
4. Configure database connection

#### 5. Verify Deployment

```sql
-- Check everything is working
@scripts/check_demo_status.sql
```

---

## 🛠️ Script Configuration

### Python Setup Script

**Configuration:**
```python
# In quick_setup.py, you can modify:
SNOWFLAKE_CONNECTION = "your_default_connection"
DATABASE_NAME = "customer_360_db"
WAREHOUSE_NAME = "customer_360_wh"
```

**Usage:**
```bash
# Interactive mode
python3 scripts/quick_setup.py

# Direct connection
python3 scripts/quick_setup.py --connection my_conn
```

### Bash Reset Script

**Configuration:**
```bash
# In reset_demo.sh, update:
SNOWFLAKE_CONNECTION="your_connection_name"
DATABASE_NAME="customer_360_db"
WAREHOUSE_NAME="customer_360_wh"
```

**Usage:**
```bash
# Default connection
./scripts/reset_demo.sh

# Specify connection
./scripts/reset_demo.sh -c my_connection

# Show help
./scripts/reset_demo.sh --help
```

---

## 🧪 Testing & Verification

### Status Check Script

The `check_demo_status.sql` script provides comprehensive verification:

```sql
@scripts/check_demo_status.sql
```

**What it checks:**
- ✅ Database objects (tables, views, functions)
- ✅ Cortex services (Search, Agent)
- ✅ Data quality and integrity
- ✅ Performance metrics
- ✅ Demo readiness status

### Expected Results

**Successful Setup:**
- 5 customers loaded
- 10+ activities
- 4+ purchases
- 3+ support tickets
- 4+ documents
- 1+ search service
- Multiple helper functions

### Demo Scenarios

Test these scenarios after setup:

1. **High-Value Customer Analysis**
   - Select Sarah Johnson (Platinum)
   - Generate AI insights
   - Review recommendations

2. **Churn Risk Assessment**
   - Identify Emma Davis (High Risk)
   - Analyze risk factors
   - Generate retention strategies

3. **Support Issue Analysis**
   - Review Michael Chen's shipping delay
   - Search for similar issues
   - Analyze resolution patterns

4. **Revenue Optimization**
   - Explore customer tiers
   - Identify upsell opportunities
   - Analyze purchase patterns

---

## 🔧 Troubleshooting

### Common Issues

**1. SnowSQL Not Found**
```bash
# Install SnowSQL
curl -O https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.2/linux_x86_64/snowsql-1.2.32-linux_x86_64.bash
bash snowsql-1.2.32-linux_x86_64.bash
```

**2. Connection Failed**
```bash
# Check connection config
cat ~/.snowsql/config

# Test connection
snowsql -c your_connection -q "SELECT 1;"
```

**3. Cortex Services Not Available**
```sql
-- Check permissions
SHOW GRANTS TO ROLE your_role;

-- Grant Cortex access
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE your_role;
```

**4. Search Services Not Ready**
```sql
-- Check status (wait 5-10 minutes)
DESCRIBE CORTEX SEARCH SERVICE customer_documents_search;
```

**5. Python Script Issues**
```bash
# Install required Python version (3.7+)
python3 --version

# Run with debugging
python3 -v scripts/quick_setup.py
```

### Performance Optimization

**Warehouse Scaling:**
```sql
-- Scale up for faster setup
ALTER WAREHOUSE customer_360_wh SET WAREHOUSE_SIZE = 'MEDIUM';

-- Scale down to save costs
ALTER WAREHOUSE customer_360_wh SET WAREHOUSE_SIZE = 'SMALL';
```

**Query Optimization:**
```sql
-- Monitor performance
SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE WAREHOUSE_NAME = 'CUSTOMER_360_WH'
ORDER BY START_TIME DESC;
```

---

## 📞 Support

### Getting Help

1. **Check Status First**
   ```sql
   @scripts/check_demo_status.sql
   ```

2. **Review Logs**
   - SnowSQL error messages
   - Python script output
   - Warehouse query history

3. **Common Solutions**
   - Wait for Cortex Search indexing (5-10 min)
   - Verify database permissions
   - Check warehouse is running
   - Ensure semantic model is uploaded

### Best Practices

1. **Before Demo**
   - Run complete reset 30 minutes before
   - Verify all components with status check
   - Test key scenarios

2. **During Development**
   - Use cleanup script between iterations
   - Check status after each major change
   - Keep backups of custom modifications

3. **For Training**
   - Prepare multiple clean environments
   - Document any customizations
   - Have rollback plan ready

---

## 🔄 Customization

### Adding Custom Data

```sql
-- Add to 03_sample_data.sql or create new script
INSERT INTO customers (customer_id, first_name, last_name, ...)
VALUES ('CUST_006', 'John', 'Doe', ...);
```

### Modifying Search Services

```sql
-- Update 04_cortex_search.sql
CREATE OR REPLACE CORTEX SEARCH SERVICE custom_search
ON document_content
ATTRIBUTES custom_field1, custom_field2
...
```

### Custom Cortex Agent

```sql
-- Modify 06_cortex_agent.sql
CREATE OR REPLACE CORTEX AGENT custom_agent (
    INSTRUCTIONS = 'Your custom instructions...'
) AS (
    -- Custom tool configurations
);
```

### Environment Variables

Create `.env` file for external deployments:
```env
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_ROLE=your_role
SNOWFLAKE_WAREHOUSE=customer_360_wh
SNOWFLAKE_DATABASE=customer_360_db
```

---

*Last updated: January 2024* 