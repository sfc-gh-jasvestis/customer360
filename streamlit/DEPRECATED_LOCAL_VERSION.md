# ⚠️ DEPRECATED: Local Streamlit Files

## 🏔️ **Migration Notice**

The local Streamlit files in this directory are **DEPRECATED** and are kept for reference only.

**🎯 Use This Instead:**
- **`customer_360_sis_app.py`** - The official Streamlit in Snowflake version

## 📋 **What Changed?**

### ❌ **Old Approach (Deprecated)**
- Local Python environment required
- Complex dependency management (pandas, plotly, snowflake connectors)
- Environment conflicts (numpy import issues)
- Manual connection configuration
- Local hosting required

### ✅ **New Approach (Recommended)**
- **Streamlit in Snowflake (SiS)** - No local dependencies!
- Native Snowpark integration
- Automatic scaling and security
- Direct data access
- Enterprise-ready deployment

## 🔄 **Migration Path**

If you're currently using the local files, migrate to SiS:

### **Step 1: Stop Local Development**
```bash
# No longer needed
pkill -f streamlit
```

### **Step 2: Deploy to Snowflake**
1. Copy `customer_360_sis_app.py` content
2. Go to Snowflake → Projects → Streamlit
3. Create new app with the SiS code
4. Deploy and enjoy!

### **Step 3: Clean Up Local Environment** (Optional)
```bash
# Remove local dependencies (optional)
pip uninstall streamlit pandas plotly snowflake-connector-python
```

## 📁 **Deprecated Files**

The following files are **DEPRECATED**:

- ❌ `customer_360_app.py` - Use `customer_360_sis_app.py` instead
- ❌ `components/customer_profile.py` - Integrated into SiS app
- ❌ `components/analytics_dashboard.py` - Integrated into SiS app  
- ❌ `components/activity_feed.py` - Integrated into SiS app
- ❌ `components/ai_assistant.py` - Integrated into SiS app
- ❌ `utils/cortex_client.py` - No longer needed (direct SQL calls)

## 🆘 **Need Help?**

- 📖 **Full Guide**: See `DEPLOY_TO_SNOWFLAKE.md`
- 🚀 **Quick Start**: Copy `customer_360_sis_app.py` to Snowflake
- 🔧 **Troubleshooting**: Run `sql/10_deploy_streamlit.sql`

---

**🏔️ The future is Streamlit in Snowflake - native, scalable, and hassle-free!** 