"""
Customer 360 & AI Assistant Demo
Built with Snowflake Cortex and Streamlit

This application demonstrates a comprehensive Customer 360 solution with:
- Cortex Agents for AI-powered insights
- Cortex Search for document retrieval
- Cortex Analyst for natural language queries
- Real-time customer analytics and visualizations
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import json

# Import custom components
from components.customer_profile import render_customer_profile
from components.ai_assistant import render_ai_assistant
from components.analytics_dashboard import render_analytics_dashboard  
from components.activity_feed import render_activity_feed
from utils.cortex_client import CortexClient
from utils.data_helpers import DataHelpers

# Page configuration
st.set_page_config(
    page_title="Customer 360 & AI Assistant",
    page_icon="🎯",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(90deg, #6366f1 0%, #8b5cf6 100%);
        color: white;
        padding: 1rem;
        border-radius: 10px;
        margin-bottom: 2rem;
        text-align: center;
    }
    
    .metric-card {
        background: white;
        padding: 1rem;
        border-radius: 8px;
        border: 1px solid #e5e7eb;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }
    
    .customer-tier-platinum {
        background: linear-gradient(45deg, #ffd700, #ffed4e);
        color: #1f2937;
        font-weight: bold;
    }
    
    .customer-tier-gold {
        background: linear-gradient(45deg, #fbbf24, #f59e0b);
        color: white;
        font-weight: bold;
    }
    
    .customer-tier-silver {
        background: linear-gradient(45deg, #6b7280, #9ca3af);
        color: white;
        font-weight: bold;
    }
    
    .customer-tier-bronze {
        background: linear-gradient(45deg, #92400e, #b45309);
        color: white;
        font-weight: bold;
    }
    
    .risk-high {
        color: #ef4444;
        font-weight: bold;
    }
    
    .risk-medium {
        color: #f59e0b;
        font-weight: bold;
    }
    
    .risk-low {
        color: #10b981;
        font-weight: bold;
    }
    
    .stButton > button {
        width: 100%;
        border-radius: 8px;
        border: none;
        background: linear-gradient(45deg, #6366f1, #8b5cf6);
        color: white;
        font-weight: 500;
    }
</style>
""", unsafe_allow_html=True)

# Helper functions for safe formatting
def safe_format_currency(value, default="$0.00"):
    """Safely format a value as currency"""
    try:
        if value is None or pd.isna(value):
            return default
        return f"${float(value):,.2f}"
    except (ValueError, TypeError):
        return default

def safe_format_percentage(value, default="0.0%"):
    """Safely format a value as percentage"""
    try:
        if value is None or pd.isna(value):
            return default
        return f"{float(value):.1%}"
    except (ValueError, TypeError):
        return default

def safe_format_decimal(value, decimals=1, default="0.0"):
    """Safely format a decimal value"""
    try:
        if value is None or pd.isna(value):
            return default
        return f"{float(value):.{decimals}f}"
    except (ValueError, TypeError):
        return default

def safe_get_str(value, default="N/A"):
    """Safely get string value"""
    if value is None or pd.isna(value):
        return default
    return str(value)

# Initialize session state
if 'cortex_client' not in st.session_state:
    st.session_state.cortex_client = CortexClient()
    
if 'data_helpers' not in st.session_state:
    st.session_state.data_helpers = DataHelpers()
    
if 'selected_customer' not in st.session_state:
    st.session_state.selected_customer = None
    
if 'chat_history' not in st.session_state:
    st.session_state.chat_history = []

def main():
    """Main application function"""
    
    # Header
    st.markdown("""
    <div class="main-header">
        <h1>🎯 Customer 360 & AI Assistant</h1>
        <p>Powered by Snowflake Cortex | Real-time Customer Insights & AI-Driven Analytics</p>
    </div>
    """, unsafe_allow_html=True)
    
    # Sidebar
    with st.sidebar:
        st.title("🔍 Navigation")
        
        # Page selection
        page = st.selectbox(
            "Select View",
            ["Dashboard Overview", "Customer Profile", "AI Assistant", "Analytics", "Activity Feed"],
            index=0
        )
        
        st.divider()
        
        # Customer selection
        st.subheader("👤 Customer Selection")
        customers_df = st.session_state.data_helpers.get_customers()
        
        if not customers_df.empty:
            customer_options = []
            for _, row in customers_df.iterrows():
                first_name = safe_get_str(row.get('FIRST_NAME', ''), 'Unknown')
                last_name = safe_get_str(row.get('LAST_NAME', ''), 'Customer')
                tier = safe_get_str(row.get('CUSTOMER_TIER', 'bronze'), 'bronze').title()
                customer_options.append(f"{first_name} {last_name} ({tier})")
            
            selected_customer_idx = st.selectbox(
                "Choose Customer",
                range(len(customer_options)),
                format_func=lambda x: customer_options[x] if x < len(customer_options) else "",
                index=0 if st.session_state.selected_customer is None else 0
            )
            
            if selected_customer_idx is not None:
                st.session_state.selected_customer = customers_df.iloc[selected_customer_idx]
                
                # Display selected customer info
                customer = st.session_state.selected_customer
                first_name = safe_get_str(customer.get('FIRST_NAME', ''), 'Unknown')
                last_name = safe_get_str(customer.get('LAST_NAME', ''), 'Customer')
                tier = safe_get_str(customer.get('CUSTOMER_TIER', 'bronze'), 'bronze').title()
                status = safe_get_str(customer.get('ACCOUNT_STATUS', 'unknown'), 'unknown').title()
                total_spent = safe_format_currency(customer.get('TOTAL_SPENT', 0))
                
                st.markdown(f"""
                **Selected Customer:**  
                {first_name} {last_name}  
                **Tier:** {tier}  
                **Status:** {status}  
                **Total Spent:** {total_spent}
                """)
        
        st.divider()
        
        # Quick actions
        st.subheader("⚡ Quick Actions")
        if st.button("🔄 Refresh Data"):
            st.cache_data.clear()
            st.rerun()
            
        if st.button("📊 Generate Insights"):
            if st.session_state.selected_customer is not None:
                customer_id = st.session_state.selected_customer['CUSTOMER_ID']
                with st.spinner("Generating AI insights..."):
                    insights = st.session_state.cortex_client.analyze_customer(customer_id)
                    st.session_state.latest_insights = insights
                    st.success("Insights generated!")
            else:
                st.warning("Please select a customer first")
    
    # Main content area
    if page == "Dashboard Overview":
        render_dashboard_overview()
    elif page == "Customer Profile":
        render_customer_profile(st.session_state.selected_customer)
    elif page == "AI Assistant":
        render_ai_assistant()
    elif page == "Analytics":
        render_analytics_dashboard()
    elif page == "Activity Feed":
        render_activity_feed()

def render_dashboard_overview():
    """Render the main dashboard overview"""
    
    st.header("📊 Dashboard Overview")
    
    # Key metrics row
    col1, col2, col3, col4 = st.columns(4)
    
    customers_df = st.session_state.data_helpers.get_customers()
    activities_df = st.session_state.data_helpers.get_recent_activities()
    
    with col1:
        total_customers = len(customers_df)
        st.metric("Total Customers", total_customers, delta="5 new this month")
    
    with col2:
        total_revenue = customers_df['TOTAL_SPENT'].sum() if not customers_df.empty else 0
        st.metric("Total Revenue", safe_format_currency(total_revenue), delta="12% vs last month")
    
    with col3:
        if not customers_df.empty and 'SATISFACTION_SCORE' in customers_df.columns:
            avg_satisfaction = customers_df['SATISFACTION_SCORE'].mean()
            st.metric("Avg Satisfaction", f"{safe_format_decimal(avg_satisfaction)}/5.0", delta="0.2 improvement")
        else:
            st.metric("Avg Satisfaction", "N/A", delta="No data")
    
    with col4:
        if not customers_df.empty and 'CHURN_RISK_SCORE' in customers_df.columns:
            high_risk_customers = len(customers_df[customers_df['CHURN_RISK_SCORE'] > 0.5])
            st.metric("High Risk Customers", high_risk_customers, delta="-2 from last month")
        else:
            st.metric("High Risk Customers", "0", delta="No data")
    
    st.divider()
    
    # Main dashboard content
    col1, col2 = st.columns([2, 1])
    
    with col1:
        # Customer distribution by tier
        st.subheader("🏆 Customer Distribution by Tier")
        if not customers_df.empty and 'CUSTOMER_TIER' in customers_df.columns:
            tier_counts = customers_df['CUSTOMER_TIER'].value_counts()
            
            fig_tier = px.pie(
                values=tier_counts.values,
                names=tier_counts.index,
                title="Customer Tiers",
                color_discrete_map={
                    'platinum': '#ffd700',
                    'gold': '#fbbf24', 
                    'silver': '#9ca3af',
                    'bronze': '#92400e'
                }
            )
            fig_tier.update_traces(textposition='inside', textinfo='percent+label')
            st.plotly_chart(fig_tier, use_container_width=True)
        else:
            st.info("No customer tier data available")
        
        # Churn risk analysis
        st.subheader("⚠️ Churn Risk Analysis")
        if not customers_df.empty and 'CHURN_RISK_SCORE' in customers_df.columns:
            customers_df['risk_category'] = customers_df['CHURN_RISK_SCORE'].apply(
                lambda x: 'High Risk' if pd.notna(x) and x > 0.5 else 'Medium Risk' if pd.notna(x) and x > 0.3 else 'Low Risk'
            )
            
            # Only create scatter plot if we have the required columns
            required_cols = ['TOTAL_SPENT', 'CHURN_RISK_SCORE', 'CUSTOMER_TIER', 'LIFETIME_VALUE', 'FIRST_NAME', 'LAST_NAME', 'SATISFACTION_SCORE']
            if all(col in customers_df.columns for col in required_cols):
                fig_risk = px.scatter(
                    customers_df,
                    x='TOTAL_SPENT',
                    y='CHURN_RISK_SCORE',
                    color='CUSTOMER_TIER',
                    size='LIFETIME_VALUE',
                    hover_data=['FIRST_NAME', 'LAST_NAME', 'SATISFACTION_SCORE'],
                    title="Customer Value vs Churn Risk",
                    labels={
                        'TOTAL_SPENT': 'Total Spent ($)',
                        'CHURN_RISK_SCORE': 'Churn Risk Score'
                    }
                )
                st.plotly_chart(fig_risk, use_container_width=True)
            else:
                st.info("Insufficient data for churn risk analysis")
        else:
            st.info("No churn risk data available")
    
    with col2:
        # Top customers
        st.subheader("🌟 Top Customers")
        if not customers_df.empty:
            display_cols = ['FIRST_NAME', 'LAST_NAME', 'CUSTOMER_TIER', 'TOTAL_SPENT']
            available_cols = [col for col in display_cols if col in customers_df.columns]
            
            if available_cols:
                top_customers = customers_df.nlargest(5, 'TOTAL_SPENT')[available_cols]
                for _, customer in top_customers.iterrows():
                    first_name = safe_get_str(customer.get('FIRST_NAME', ''), 'Unknown')
                    last_name = safe_get_str(customer.get('LAST_NAME', ''), 'Customer')
                    tier = safe_get_str(customer.get('CUSTOMER_TIER', 'bronze'), 'bronze')
                    total_spent = safe_format_currency(customer.get('TOTAL_SPENT', 0))
                    
                    tier_class = f"customer-tier-{tier}"
                    st.markdown(f"""
                    <div class="metric-card">
                        <div class="{tier_class}" style="padding: 0.5rem; border-radius: 4px; margin-bottom: 0.5rem;">
                            {first_name} {last_name}
                        </div>
                        <strong>{total_spent}</strong>
                    </div>
                    """, unsafe_allow_html=True)
                    st.markdown("<br>", unsafe_allow_html=True)
            else:
                st.info("No customer data available")
        
        # Recent activities summary
        st.subheader("📱 Recent Activities")
        if not activities_df.empty and 'ACTIVITY_TYPE' in activities_df.columns:
            activity_counts = activities_df.groupby('ACTIVITY_TYPE').size().sort_values(ascending=False)
            for activity_type, count in activity_counts.head(5).items():
                st.markdown(f"**{str(activity_type).replace('_', ' ').title()}:** {count}")
        else:
            st.info("No recent activities available")
        
        # Alert box for high-risk customers
        if not customers_df.empty and 'CHURN_RISK_SCORE' in customers_df.columns:
            high_risk_df = customers_df[customers_df['CHURN_RISK_SCORE'] > 0.5]
            if not high_risk_df.empty:
                st.error("🚨 **Attention Required**")
                st.markdown("**High-risk customers:**")
                for _, customer in high_risk_df.iterrows():
                    first_name = safe_get_str(customer.get('FIRST_NAME', ''), 'Unknown')
                    last_name = safe_get_str(customer.get('LAST_NAME', ''), 'Customer')
                    risk_score = safe_format_percentage(customer.get('CHURN_RISK_SCORE', 0))
                    st.markdown(f"• {first_name} {last_name} (Risk: {risk_score})")

if __name__ == "__main__":
    main() 