"""
Customer 360 & AI Assistant - Streamlit in Snowflake
Built for Snowflake's native Streamlit environment

This application demonstrates a comprehensive Customer 360 solution with:
- AI-powered customer insights using SQL UDFs
- Advanced text-based search capabilities  
- Real-time customer analytics and visualizations
- Interactive dashboards and customer profiles
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import json
import numpy as np
from snowflake.snowpark.context import get_active_session

# Page configuration
st.set_page_config(
    page_title="Customer 360 & AI Assistant",
    page_icon="🎯",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Get Snowflake session (native SiS connection)
session = get_active_session()

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

def safe_format_number(value, default=0):
    """Safely format a number with thousands separator"""
    try:
        if value is None or pd.isna(value):
            return default
        return f"{int(value):,}"
    except (ValueError, TypeError):
        return default

def safe_get_str(value, default="N/A"):
    """Safely get string value"""
    if value is None or pd.isna(value):
        return default
    return str(value)

def safe_filter_dataframe(df, column, condition_func):
    """Safely filter dataframe with NaN handling"""
    try:
        if df.empty or column not in df.columns:
            return df.iloc[0:0]  # Return empty dataframe with same structure
        
        # Handle NaN values explicitly
        mask = df[column].notna() & condition_func(df[column])
        return df[mask]
    except Exception:
        return df.iloc[0:0]  # Return empty dataframe on error

def safe_boolean_filter(series, condition_func):
    """Safely apply boolean conditions to a Series"""
    try:
        if series.empty:
            return pd.Series([], dtype=bool)
        
        # Handle NaN values explicitly  
        valid_mask = series.notna()
        result_mask = pd.Series(False, index=series.index)
        result_mask[valid_mask] = condition_func(series[valid_mask])
        return result_mask
    except Exception:
        return pd.Series(False, index=series.index)

# Data access functions using Snowpark
@st.cache_data(ttl=300)
def get_customers():
    """Get all customers with basic information"""
    try:
        query = """
        SELECT 
            customer_id,
            first_name,
            last_name,
            email,
            customer_tier,
            account_status,
            join_date,
            total_spent,
            lifetime_value,
            churn_risk_score,
            satisfaction_score,
            engagement_score,
            preferred_communication_channel,
            city,
            state_province,
            country
        FROM customers
        ORDER BY total_spent DESC
        """
        df = session.sql(query).to_pandas()
        
        # Ensure numeric columns are properly typed
        numeric_columns = ['total_spent', 'lifetime_value', 'churn_risk_score', 
                          'satisfaction_score', 'engagement_score']
        for col in numeric_columns:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors='coerce')
                
        return df
    except Exception as e:
        st.error(f"Error fetching customers: {str(e)}")
        return pd.DataFrame()

@st.cache_data(ttl=60)
def get_recent_activities(days=30):
    """Get recent customer activities"""
    try:
        query = """
        SELECT 
            activity_id,
            customer_id,
            activity_type,
            activity_title,
            activity_description,
            activity_timestamp,
            channel,
            priority,
            transaction_amount
        FROM customer_activities
        WHERE activity_timestamp >= DATEADD('day', ?, CURRENT_TIMESTAMP())
        ORDER BY activity_timestamp DESC
        LIMIT 100
        """
        df = session.sql(query, params=[-days]).to_pandas()
        
        # Ensure numeric columns are properly typed
        if 'transaction_amount' in df.columns:
            df['transaction_amount'] = pd.to_numeric(df['transaction_amount'], errors='coerce')
            
        return df
    except Exception as e:
        st.error(f"Error fetching activities: {str(e)}")
        return pd.DataFrame()

def get_customer_activities(customer_id, limit=20):
    """Get activities for a specific customer"""
    try:
        query = """
        SELECT 
            activity_id,
            activity_type,
            activity_title,
            activity_description,
            activity_timestamp,
            channel,
            priority,
            transaction_amount,
            status
        FROM customer_activities
        WHERE customer_id = ?
        ORDER BY activity_timestamp DESC
        LIMIT ?
        """
        df = session.sql(query, params=[customer_id, limit]).to_pandas()
        
        # Ensure numeric columns are properly typed
        if 'transaction_amount' in df.columns:
            df['transaction_amount'] = pd.to_numeric(df['transaction_amount'], errors='coerce')
            
        return df
    except Exception as e:
        st.error(f"Error fetching customer activities: {str(e)}")
        return pd.DataFrame()

def analyze_customer_ai(customer_id):
    """Get AI analysis for a customer"""
    try:
        query = "SELECT analyze_customer_ai(?) as response"
        result = session.sql(query, params=[customer_id]).to_pandas()
        if not result.empty:
            return result.iloc[0]['RESPONSE']
        return "No analysis available"
    except Exception as e:
        return f"Analysis error: {str(e)}"

def get_customer_insights():
    """Get general customer insights"""
    try:
        query = "SELECT get_customer_insights_summary() as response"
        result = session.sql(query).to_pandas()
        if not result.empty:
            return result.iloc[0]['RESPONSE']
        return "No insights available"
    except Exception as e:
        return f"Insights error: {str(e)}"

def search_documents(search_term):
    """Search customer documents"""
    try:
        query = "SELECT search_customer_documents_text(?) as response"
        result = session.sql(query, params=[search_term]).to_pandas()
        if not result.empty:
            return result.iloc[0]['RESPONSE']
        return "No results found"
    except Exception as e:
        return f"Search error: {str(e)}"

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

# Initialize session state
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
        <p>Powered by Snowflake | Real-time Customer Insights & AI-Driven Analytics</p>
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
        customers_df = get_customers()
        
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
                    insights = analyze_customer_ai(customer_id)
                    st.session_state.latest_insights = insights
                    st.success("Insights generated!")
            else:
                st.warning("Please select a customer first")
    
    # Main content area
    if page == "Dashboard Overview":
        render_dashboard_overview()
    elif page == "Customer Profile":
        render_customer_profile()
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
    
    customers_df = get_customers()
    activities_df = get_recent_activities()
    
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
            # Use safe boolean filtering to avoid Series ambiguity
            high_risk_mask = safe_boolean_filter(customers_df['CHURN_RISK_SCORE'], lambda x: x > 0.5)
            high_risk_customers = high_risk_mask.sum()
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
            try:
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
            except Exception as e:
                st.error(f"Error creating tier chart: {str(e)}")
        else:
            st.info("No customer tier data available")
    
    with col2:
        # Top customers
        st.subheader("🌟 Top Customers")
        if not customers_df.empty:
            try:
                display_cols = ['FIRST_NAME', 'LAST_NAME', 'CUSTOMER_TIER', 'TOTAL_SPENT']
                available_cols = [col for col in display_cols if col in customers_df.columns]
                
                if available_cols and 'TOTAL_SPENT' in customers_df.columns:
                    # Safely get top customers
                    valid_spent_mask = customers_df['TOTAL_SPENT'].notna()
                    valid_customers = customers_df[valid_spent_mask]
                    
                    if not valid_customers.empty:
                        top_customers = valid_customers.nlargest(5, 'TOTAL_SPENT')[available_cols]
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
                        st.info("No valid customer spending data available")
                else:
                    st.info("No customer data available")
            except Exception as e:
                st.error(f"Error displaying top customers: {str(e)}")

def render_customer_profile():
    """Render customer profile view"""
    
    if st.session_state.selected_customer is None:
        st.warning("Please select a customer from the sidebar to view their profile.")
        return
    
    customer = st.session_state.selected_customer
    customer_id = customer.get('CUSTOMER_ID')
    
    # Header with customer info
    first_name = safe_get_str(customer.get('FIRST_NAME', ''), 'Unknown')
    last_name = safe_get_str(customer.get('LAST_NAME', ''), 'Customer')
    st.header(f"👤 {first_name} {last_name}")
    
    # Customer metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_spent = safe_format_currency(customer.get('TOTAL_SPENT', 0))
        st.metric("Total Spent", total_spent)
    
    with col2:
        risk_score = customer.get('CHURN_RISK_SCORE', 0) or 0
        risk_percentage = safe_format_percentage(risk_score)
        st.metric("Churn Risk", risk_percentage)
    
    with col3:
        satisfaction = customer.get('SATISFACTION_SCORE', 0) or 0
        satisfaction_str = safe_format_decimal(satisfaction, 1)
        st.metric("Satisfaction", f"{satisfaction_str}/5.0")
    
    with col4:
        engagement = customer.get('ENGAGEMENT_SCORE', 0) or 0
        engagement_str = safe_format_percentage(engagement)
        st.metric("Engagement", engagement_str)
    
    st.divider()
    
    # Customer activities
    st.subheader("🔄 Recent Activities")
    try:
        activities_df = get_customer_activities(customer_id, limit=10)
        
        if not activities_df.empty:
            for _, activity in activities_df.iterrows():
                title = safe_get_str(activity.get('ACTIVITY_TITLE', ''), 'Unknown Activity')
                timestamp = safe_get_str(activity.get('ACTIVITY_TIMESTAMP', ''), 'Unknown time')
                description = safe_get_str(activity.get('ACTIVITY_DESCRIPTION', ''), 'No description')
                
                st.markdown(f"""
                **{title}**  
                *{timestamp}*  
                {description}
                """)
                st.markdown("---")
        else:
            st.info("No recent activities found.")
    except Exception as e:
        st.error(f"Error loading customer activities: {str(e)}")

def render_ai_assistant():
    """Render AI assistant interface"""
    
    st.header("🤖 AI Assistant")
    st.markdown("Ask me anything about your customers, analytics, or business insights!")
    
    # Chat input
    user_input = st.chat_input("Ask about customers, analytics, or insights...")
    
    if user_input:
        # Add user message to history
        st.session_state.chat_history.append({
            'role': 'user',
            'content': user_input,
            'timestamp': datetime.now()
        })
        
        # Get AI response
        with st.spinner("AI is thinking..."):
            try:
                if st.session_state.selected_customer:
                    customer_id = st.session_state.selected_customer['CUSTOMER_ID']
                    response = analyze_customer_ai(customer_id)
                else:
                    response = get_customer_insights()
                
                st.session_state.chat_history.append({
                    'role': 'assistant',
                    'content': response,
                    'timestamp': datetime.now()
                })
            except Exception as e:
                st.session_state.chat_history.append({
                    'role': 'assistant',
                    'content': f"Sorry, I encountered an error: {str(e)}",
                    'timestamp': datetime.now()
                })
    
    # Display chat history
    for message in st.session_state.chat_history:
        if message['role'] == 'user':
            st.chat_message("user").write(message['content'])
        else:
            st.chat_message("assistant").write(message['content'])
    
    # Clear chat button
    if st.button("🗑️ Clear Chat History"):
        st.session_state.chat_history = []
        st.rerun()

def render_analytics_dashboard():
    """Render analytics dashboard"""
    
    st.header("📊 Analytics Dashboard")
    
    customers_df = get_customers()
    
    if not customers_df.empty:
        try:
            # Customer value analysis
            col1, col2 = st.columns(2)
            
            with col1:
                # Revenue by tier
                if 'CUSTOMER_TIER' in customers_df.columns and 'TOTAL_SPENT' in customers_df.columns:
                    try:
                        # Remove rows with NaN values for grouping
                        valid_data = customers_df.dropna(subset=['CUSTOMER_TIER', 'TOTAL_SPENT'])
                        if not valid_data.empty:
                            revenue_by_tier = valid_data.groupby('CUSTOMER_TIER')['TOTAL_SPENT'].sum().reset_index()
                            
                            fig = px.bar(
                                revenue_by_tier, 
                                x='CUSTOMER_TIER', 
                                y='TOTAL_SPENT',
                                title="Revenue by Customer Tier"
                            )
                            st.plotly_chart(fig, use_container_width=True)
                        else:
                            st.info("No valid revenue data available")
                    except Exception as e:
                        st.error(f"Error creating revenue chart: {str(e)}")
            
            with col2:
                # Risk distribution
                if 'CHURN_RISK_SCORE' in customers_df.columns:
                    try:
                        # Safely categorize risk with explicit NaN handling
                        def categorize_risk(x):
                            if pd.isna(x):
                                return 'Unknown Risk'
                            elif x > 0.7:
                                return 'High Risk'
                            elif x > 0.3:
                                return 'Medium Risk'
                            else:
                                return 'Low Risk'
                        
                        customers_df_copy = customers_df.copy()
                        customers_df_copy['risk_category'] = customers_df_copy['CHURN_RISK_SCORE'].apply(categorize_risk)
                        
                        risk_counts = customers_df_copy['risk_category'].value_counts()
                        
                        if not risk_counts.empty:
                            fig = px.pie(
                                values=risk_counts.values,
                                names=risk_counts.index,
                                title="Customer Risk Distribution"
                            )
                            st.plotly_chart(fig, use_container_width=True)
                        else:
                            st.info("No risk data available")
                    except Exception as e:
                        st.error(f"Error creating risk chart: {str(e)}")
        except Exception as e:
            st.error(f"Error in analytics dashboard: {str(e)}")
    else:
        st.info("No customer data available for analytics")

def render_activity_feed():
    """Render activity feed"""
    
    st.header("📱 Activity Feed")
    
    try:
        activities_df = get_recent_activities(days=7)
        
        if not activities_df.empty:
            # Activity metrics
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.metric("Total Activities", len(activities_df))
            
            with col2:
                if 'PRIORITY' in activities_df.columns:
                    try:
                        # Safe filtering for high priority activities
                        high_priority_mask = activities_df['PRIORITY'].isin(['high', 'urgent'])
                        high_priority = high_priority_mask.sum()
                        st.metric("High Priority", high_priority)
                    except Exception:
                        st.metric("High Priority", "N/A")
            
            with col3:
                if 'CUSTOMER_ID' in activities_df.columns:
                    try:
                        unique_customers = activities_df['CUSTOMER_ID'].nunique()
                        st.metric("Active Customers", unique_customers)
                    except Exception:
                        st.metric("Active Customers", "N/A")
            
            st.divider()
            
            # Recent activities
            st.subheader("🔄 Recent Activities")
            try:
                for _, activity in activities_df.head(20).iterrows():
                    title = safe_get_str(activity.get('ACTIVITY_TITLE', ''), 'Activity')
                    customer_id = safe_get_str(activity.get('CUSTOMER_ID', ''), 'Unknown')
                    timestamp = safe_get_str(activity.get('ACTIVITY_TIMESTAMP', ''), 'Unknown time')
                    description = safe_get_str(activity.get('ACTIVITY_DESCRIPTION', ''), 'No description')
                    
                    st.markdown(f"""
                    **{title}** - Customer: {customer_id}  
                    *{timestamp}*  
                    {description}
                    """)
                    st.markdown("---")
            except Exception as e:
                st.error(f"Error displaying activities: {str(e)}")
        else:
            st.info("No recent activities found")
    except Exception as e:
        st.error(f"Error loading activity feed: {str(e)}")

if __name__ == "__main__":
    main() 