# 🔧 Troubleshooting Guide: Streamlit in Snowflake

## Common Issues & Solutions

### ❌ **Error 1: "Object 'CUSTOMERS' does not exist or not authorized"**

**Cause:** Database/schema not set or tables missing

**Solutions:**
1. **Verify Database Setup:**
   ```sql
   -- Run verification script
   @sql/00_verify_setup.sql
   ```

2. **Create Missing Objects:**
   ```sql
   -- Complete setup
   @sql/99_deploy_complete.sql
   ```

3. **Check Access:**
   ```sql
   -- Verify you can see tables
   SHOW TABLES IN RETAIL_WATCH_DB.PUBLIC;
   ```

---

### ❌ **Error 2: "Unsupported statement type 'USE'"**

**Cause:** `USE` statements don't work in Streamlit's Snowflake connection

**Solution:** ✅ **FIXED** - App now uses fully qualified table names
- `customers` → `RETAIL_WATCH_DB.PUBLIC.customers`
- `products` → `RETAIL_WATCH_DB.PUBLIC.products`

---

### ❌ **Error 3: "TypeError: '>' not supported between instances of 'str' and 'float'"**

**Cause:** Data type mismatch in comparisons

**Solution:** ✅ **FIXED** - Added type conversion:
```python
# Before (ERROR)
risk_level = "HIGH" if customer[5] > 0.7 else "LOW"

# After (FIXED)
risk_score = float(customer[5]) if customer[5] is not None else 0.0
risk_level = "HIGH" if risk_score > 0.7 else "LOW"
```

---

### ❌ **Error 4: "StreamlitSecretNotFoundError"**

**Cause:** Looking for `secrets.toml` file

**Solution:** ✅ **FIXED** - App uses native `st.connection("snowflake")`
- No `secrets.toml` needed for Streamlit in Snowflake
- Authentication is handled automatically

---

## 🚀 **Quick Start Checklist**

### ✅ **1. Database Setup**
```sql
-- Run in Snowflake worksheet
@sql/01_setup_database.sql
@sql/02_create_tables.sql  
@sql/03_sample_data.sql
@sql/04_ai_functions.sql
```

### ✅ **2. Verify Setup**
```sql
-- Check everything is working
@sql/00_verify_setup.sql
```

Expected output should show:
- All tables: `✅ OK`
- All AI functions: `✅ EXISTS`
- Sample query: Customer counts
- AI function test: Churn prediction result

### ✅ **3. Deploy Streamlit**
```sql
-- Create Streamlit app
CREATE STREAMLIT "Personal_Watch_Shopper"
    ROOT_LOCATION = '@your_stage/streamlit'
    MAIN_FILE = 'watch_store_app.py'
    QUERY_WAREHOUSE = 'RETAIL_WATCH_WH';
```

### ✅ **4. Test Connection**
Launch the app and verify:
- ✅ Database connection verified
- Customer list loads
- AI functions work

---

## 🔍 **Debugging Steps**

### **Step 1: Check Database Access**
```sql
-- Test basic connectivity
SELECT CURRENT_USER();
SELECT CURRENT_ROLE();
SELECT CURRENT_DATABASE();
SELECT CURRENT_SCHEMA();
```

### **Step 2: Verify Tables**
```sql
-- List all tables
SHOW TABLES IN RETAIL_WATCH_DB.PUBLIC;

-- Count records in each table
SELECT COUNT(*) FROM RETAIL_WATCH_DB.PUBLIC.customers;
SELECT COUNT(*) FROM RETAIL_WATCH_DB.PUBLIC.products;
SELECT COUNT(*) FROM RETAIL_WATCH_DB.PUBLIC.orders;
```

### **Step 3: Test AI Functions**
```sql
-- Test each function
SELECT RETAIL_WATCH_DB.PUBLIC.predict_customer_churn('CUST_001');
SELECT RETAIL_WATCH_DB.PUBLIC.analyze_review_sentiment('REV_001');
SELECT RETAIL_WATCH_DB.PUBLIC.optimize_product_pricing('ROLEX_SUB_001');
```

### **Step 4: Check Streamlit Logs**
- Look for error messages in the Streamlit app interface
- Check for data type issues or SQL errors
- Verify warehouse is running

---

## 📞 **Need Help?**

If you encounter issues not covered here:

1. **Run the verification script first:**
   ```sql
   @sql/00_verify_setup.sql
   ```

2. **Check the setup scripts match your environment:**
   - Database name: `RETAIL_WATCH_DB`
   - Schema: `PUBLIC`
   - Warehouse: `RETAIL_WATCH_WH`

3. **Verify permissions:**
   - Can create/read tables
   - Can create/execute functions
   - Can use the warehouse

The app is designed to be self-diagnosing - it will show helpful error messages if setup is incomplete! 🌟 