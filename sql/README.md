# 🛠️ Retail Watch Store - SQL Setup Guide

## 📋 **SIMPLIFIED SETUP PROCESS**

To reset and setup your entire demo, **you only need 2 files now**:

### 1. **Complete Reset & Setup** (⭐ PRIMARY)
```sql
00_complete_reset_and_setup.sql
```
**What it does:**
- ✅ Drops existing database completely (clean slate)
- ✅ Creates database, schema, warehouse 
- ✅ Creates all 10 tables with proper relationships
- ✅ Inserts realistic sample data based on [WatchBase.com](https://watchbase.com/) specifications
- ✅ Creates all 5 AI functions with bulletproof error handling
- ✅ Uses **working Unsplash image URLs** for all products
- ✅ Includes accurate watch specifications (Rolex Submariner 126610LN, Omega Speedmaster 310.30.42.50.01.001, etc.)

### 2. **Quick Verification** (🔍 OPTIONAL)
```sql  
01_quick_verification.sql
```
**What it does:**
- ✅ Verifies all tables have data
- ✅ Tests all 5 AI functions work correctly
- ✅ Confirms all product images are working
- ✅ Shows summary of demo readiness

## 🚀 **HOW TO USE**

### **For First-Time Setup or Complete Reset:**
1. Run `00_complete_reset_and_setup.sql` 
2. Run `01_quick_verification.sql` (optional but recommended)
3. Launch your Streamlit app!

### **Time Required:**
- **Setup**: ~2-3 minutes
- **Verification**: ~30 seconds

## 📊 **What You Get**

### **Watch Brands** (Based on WatchBase.com)
- 🇨🇭 **Rolex** - Ultra-Luxury (Submariner, GMT-Master II)
- 🇨🇭 **Omega** - Luxury (Speedmaster, Seamaster) 
- 🇨🇭 **TAG Heuer** - Luxury (Carrera Chronograph)
- 🇯🇵 **Seiko** - Mid-Range (Prospex, Presage)
- 🇯🇵 **Citizen** - Mid-Range (Eco-Drive)
- 🇯🇵 **Casio** - Entry (G-Shock GA-2100)
- 🇺🇸 **Apple** - Mid-Range (Apple Watch Series 8)

### **Customer Profiles**
- 👤 **5 realistic customers** with different tiers (Bronze to Diamond)
- 📊 **Churn risk scores** from 0.05 to 0.45
- 💰 **Spending ranges** from $1,850 to $45,200
- 🎯 **Preferences** for brands, styles, budgets

### **AI Functions**
1. **Customer 360 Insights** - Complete customer overview
2. **Personal Recommendations** - 5 diverse product suggestions  
3. **Churn Prediction** - Risk analysis with factors
4. **Price Optimization** - Market-based pricing recommendations
5. **Sentiment Analysis** - Review sentiment with themes

### **Product Images**
All products now use **working Unsplash URLs** that display correctly:
- 🖼️ **Rolex Submariner**: High-quality dive watch imagery
- 🖼️ **Omega Speedmaster**: Classic chronograph shots
- 🖼️ **Apple Watch**: Modern smartwatch photography
- 🖼️ **G-Shock**: Rugged sport watch images

## 🗂️ **Old Files (Now Deprecated)**

The following files are **no longer needed** with the new simplified approach:
- `01_setup_database.sql` → Included in complete setup
- `02_create_tables.sql` → Included in complete setup  
- `03_sample_data.sql` → Included in complete setup
- `04_ai_functions.sql` → Included in complete setup
- `05_update_ai_functions.sql` → No longer needed
- `06_fix_ai_functions.sql` → No longer needed
- `07_test_ai_functions.sql` → Replaced by verification
- `08-14_*.sql` → Various fixes now incorporated

## 💡 **Benefits of New Approach**

- ⚡ **Faster**: Single file setup vs 10+ files
- 🛡️ **Bulletproof**: All known issues pre-fixed
- 🖼️ **Images Work**: Guaranteed working URLs
- 📚 **Accurate Data**: Based on WatchBase.com specifications  
- 🧪 **Tested**: Includes verification script
- 🎯 **Simple**: Just run one file and you're done!

## 🎉 **Ready to Start?**

Run this in your Snowflake worksheet:
```sql
-- Copy and paste the entire contents of:
-- 00_complete_reset_and_setup.sql
```

Then launch your Streamlit app and enjoy your bulletproof watch store demo! ⌚✨ 