#!/usr/bin/env python3
"""
🎯 Customer 360 & AI Assistant - Quick Setup
====================================

Interactive setup script for deploying the Customer 360 solution to Snowflake.

🏔️  PRIMARY: Streamlit in Snowflake (SiS) - Recommended approach
⚠️  DEPRECATED: Local Streamlit deployment
"""

import os
import sys
import subprocess
from pathlib import Path

def print_banner():
    """Display the setup banner"""
    banner = """
    ╔═══════════════════════════════════════════════════════════════════╗
    ║                🎯 Customer 360 & AI Assistant                    ║
    ║                     ⚡ Quick Setup Tool                          ║
    ║                                                                   ║
    ║  🏔️  Deploy to: Streamlit in Snowflake (Recommended)            ║
    ║  📊 Data Platform: Snowflake Data Cloud                          ║
    ║  🤖 AI Engine: SQL UDFs with Cortex Integration                  ║
    ╚═══════════════════════════════════════════════════════════════════╝
    """
    print(banner)

def print_step(step_num, title, description=""):
    """Print a formatted step"""
    print(f"\n🔸 Step {step_num}: {title}")
    if description:
        print(f"   {description}")

def run_sql_file(filepath, description=""):
    """Display SQL file execution instructions"""
    print(f"\n📋 {description}")
    print(f"   Execute: @{filepath}")
    print(f"   File: {Path(filepath).resolve()}")

def check_files():
    """Check if required files exist"""
    print_step(1, "Checking Required Files", "Verifying all setup files are present...")
    
    required_files = [
        "sql/99_complete_setup.sql",
        "sql/07_test_services.sql", 
        "sql/10_deploy_streamlit.sql",
        "streamlit/customer_360_sis_app.py",
        "streamlit/DEPLOY_TO_SNOWFLAKE.md"
    ]
    
    missing_files = []
    for file_path in required_files:
        if not Path(file_path).exists():
            missing_files.append(file_path)
            print(f"   ❌ Missing: {file_path}")
        else:
            print(f"   ✅ Found: {file_path}")
    
    if missing_files:
        print(f"\n⚠️  Warning: {len(missing_files)} files are missing!")
        print("   Please ensure you have the complete repository.")
        return False
    else:
        print("\n✅ All required files found!")
        return True

def setup_database():
    """Database setup instructions"""
    print_step(2, "Database Setup", "Setting up Snowflake database, tables, and functions...")
    
    print("\n🔧 Execute these SQL scripts in your Snowflake environment:")
    print("   (Use Snowsight, SnowSQL, or your preferred SQL client)")
    
    run_sql_file("sql/99_complete_setup.sql", "Complete Database Setup (All-in-one)")
    
    print("\n📝 What this script does:")
    print("   • Creates CUSTOMER_360_DB database")
    print("   • Sets up CUSTOMER_360_WH warehouse")
    print("   • Creates customer data tables")
    print("   • Loads sample data")
    print("   • Creates AI analysis functions")
    print("   • Sets up search capabilities")
    
    input("\n⏸️  Press Enter after executing the setup script...")

def verify_setup():
    """Setup verification instructions"""
    print_step(3, "Verify Installation", "Testing database setup and functions...")
    
    run_sql_file("sql/07_test_services.sql", "Verification & Testing")
    
    print("\n🔍 Expected results:")
    print("   • Customer count: 5 customers")
    print("   • Activities count: 15+ activities")
    print("   • Functions working: AI analysis, search, insights")
    print("   • Sample AI response from analyze_customer_ai()")
    
    input("\n⏸️  Press Enter after verifying the setup...")

def deploy_streamlit():
    """Streamlit in Snowflake deployment instructions"""
    print_step(4, "Deploy to Streamlit in Snowflake", "🏔️ Primary deployment method (Recommended)")
    
    print("\n🚀 Deployment Steps:")
    print("   1. Go to Snowflake Web UI")
    print("   2. Navigate: Projects → Streamlit")
    print("   3. Click '+ Streamlit App'")
    print("   4. Configure:")
    print("      • Name: Customer_360_AI_Assistant")
    print("      • Database: CUSTOMER_360_DB")
    print("      • Schema: PUBLIC")
    print("      • Warehouse: CUSTOMER_360_WH")
    
    print("\n📄 Copy App Code:")
    sis_app_path = Path("streamlit/customer_360_sis_app.py")
    print(f"   • File: {sis_app_path.resolve()}")
    print("   • Copy entire file contents")
    print("   • Paste into Snowflake Streamlit editor")
    print("   • Click 'Deploy'")
    
    print("\n📖 Detailed Guide:")
    print("   • See: streamlit/DEPLOY_TO_SNOWFLAKE.md")
    print("   • SQL verification: sql/10_deploy_streamlit.sql")
    
    print("\n🔗 Your app will be available at:")
    print("   https://[your-account].snowflakecomputing.com/streamlit/Customer_360_AI_Assistant")
    
    input("\n⏸️  Press Enter after deploying to Streamlit in Snowflake...")

def show_local_deprecation():
    """Show deprecation notice for local Streamlit"""
    print("\n" + "="*70)
    print("⚠️  DEPRECATED: Local Streamlit Deployment")
    print("="*70)
    print("🚨 The local Streamlit approach is DEPRECATED and not recommended.")
    print("")
    print("❌ Issues with local deployment:")
    print("   • Complex Python environment setup")
    print("   • Dependency conflicts (numpy, pandas, etc.)")
    print("   • Manual connection configuration")
    print("   • Limited scalability")
    print("   • Maintenance overhead")
    print("")
    print("✅ Use Streamlit in Snowflake instead:")
    print("   • No local dependencies")
    print("   • Native Snowpark integration")
    print("   • Auto-scaling infrastructure")
    print("   • Enterprise security")
    print("   • Easy team sharing")
    print("")
    print("📄 For reference: streamlit/DEPRECATED_LOCAL_VERSION.md")
    print("="*70)

def show_success():
    """Display success message"""
    success_msg = """
    ╔═══════════════════════════════════════════════════════════════════╗
    ║                        🎉 Setup Complete!                        ║
    ║                                                                   ║
    ║  Your Customer 360 & AI Assistant is ready!                      ║
    ║                                                                   ║
    ║  🏔️  Deployed to: Streamlit in Snowflake                        ║
    ║  🎯 Features: Customer 360, AI Assistant, Analytics              ║
    ║  📊 Data: Sample customers and activities loaded                  ║
    ║  🤖 AI: Intelligent analysis and search functions                ║
    ╚═══════════════════════════════════════════════════════════════════╝
    
    🚀 Next Steps:
    
    1. 🔗 Access your app:
       https://[your-account].snowflakecomputing.com/streamlit/Customer_360_AI_Assistant
    
    2. 🎯 Explore features:
       • Customer 360 Dashboard
       • AI-powered insights
       • Customer risk analysis
       • Interactive analytics
       • Activity monitoring
    
    3. 👥 Share with team:
       • Grant Streamlit app access to roles
       • Share database permissions
       • Collaborate on customer insights
    
    4. 🔧 Customize:
       • Modify customer_360_sis_app.py
       • Add custom AI functions
       • Create additional dashboards
    
    📚 Resources:
    • Deployment Guide: docs/deployment_guide.md
    • Streamlit Guide: streamlit/DEPLOY_TO_SNOWFLAKE.md
    • Troubleshooting: sql/10_deploy_streamlit.sql
    
    🎊 Happy Customer Analytics!
    """
    print(success_msg)

def main():
    """Main setup flow"""
    try:
        print_banner()
        
        # Check for required files
        if not check_files():
            print("\n❌ Setup cannot continue due to missing files.")
            print("   Please ensure you have the complete repository.")
            sys.exit(1)
        
        # Interactive setup flow
        setup_database()
        verify_setup()
        deploy_streamlit()
        show_local_deprecation()
        show_success()
        
        print("\n🎯 Setup completed successfully!")
        print("   Your Customer 360 & AI Assistant is ready to use!")
        
    except KeyboardInterrupt:
        print("\n\n⚠️  Setup interrupted by user.")
        print("   You can restart the setup anytime by running this script again.")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Setup failed with error: {str(e)}")
        print("   Please check the error message and try again.")
        sys.exit(1)

if __name__ == "__main__":
    main() 