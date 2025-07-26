"""
Customer Profile Component for Customer 360 Demo

This component displays detailed customer information including:
- Basic profile information
- Purchase history
- Support tickets
- Activity timeline
- Risk assessment and recommendations
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime
import json

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

def safe_format_decimal(value, decimals=2, default="0.0"):
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

def render_customer_profile(selected_customer):
    """Render detailed customer profile view"""
    
    if selected_customer is None:
        st.warning("Please select a customer from the sidebar to view their profile.")
        return
    
    customer = selected_customer
    customer_id = customer.get('CUSTOMER_ID')
    
    if not customer_id:
        st.error("Customer ID not found. Please select a valid customer.")
        return
    
    # Header with customer info
    first_name = safe_get_str(customer.get('FIRST_NAME', ''), 'Unknown')
    last_name = safe_get_str(customer.get('LAST_NAME', ''), 'Customer')
    st.header(f"👤 {first_name} {last_name}")
    
    # Customer tier badge
    tier_colors = {
        'platinum': '#ffd700',
        'gold': '#fbbf24',
        'silver': '#9ca3af',
        'bronze': '#92400e'
    }
    
    customer_tier = safe_get_str(customer.get('CUSTOMER_TIER', 'bronze'), 'bronze').lower()
    tier_color = tier_colors.get(customer_tier, '#6b7280')
    
    st.markdown(f"""
    <div style="display: inline-block; background: {tier_color}; color: white; padding: 0.5rem 1rem; border-radius: 20px; font-weight: bold; margin-bottom: 1rem;">
        {customer_tier.upper()} CUSTOMER
    </div>
    """, unsafe_allow_html=True)
    
    # Key metrics row
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_spent = safe_format_currency(customer.get('TOTAL_SPENT', 0))
        lifetime_value = customer.get('LIFETIME_VALUE', 0) or 0
        current_spent = customer.get('TOTAL_SPENT', 0) or 0
        potential = safe_format_currency(lifetime_value - current_spent)
        
        st.metric(
            "Total Spent",
            total_spent,
            delta=f"{potential} potential"
        )
    
    with col2:
        risk_score = customer.get('CHURN_RISK_SCORE', 0) or 0
        risk_color = "🔴" if risk_score > 0.7 else "🟡" if risk_score > 0.3 else "🟢"
        risk_percentage = safe_format_percentage(risk_score)
        risk_level = 'High' if risk_score > 0.7 else 'Medium' if risk_score > 0.3 else 'Low'
        
        st.metric(
            "Churn Risk",
            f"{risk_color} {risk_percentage}",
            delta=f"{risk_level} risk"
        )
    
    with col3:
        satisfaction = customer.get('SATISFACTION_SCORE', 0) or 0
        satisfaction_str = safe_format_decimal(satisfaction, 1)
        satisfaction_level = 'Above' if satisfaction > 4.0 else 'Below'
        
        st.metric(
            "Satisfaction",
            f"{satisfaction_str}/5.0",
            delta=f"{satisfaction_level} average"
        )
    
    with col4:
        engagement = customer.get('ENGAGEMENT_SCORE', 0) or 0
        engagement_str = safe_format_percentage(engagement)
        engagement_level = 'High' if engagement > 0.7 else 'Medium' if engagement > 0.4 else 'Low'
        
        st.metric(
            "Engagement",
            engagement_str,
            delta=f"{engagement_level} engagement"
        )
    
    st.divider()
    
    # Main content in tabs
    tab1, tab2, tab3, tab4, tab5 = st.tabs(["📋 Overview", "🛒 Purchases", "🎫 Support", "📊 Analytics", "🤖 AI Insights"])
    
    with tab1:
        render_customer_overview(customer)
    
    with tab2:
        render_purchase_history(customer_id)
    
    with tab3:
        render_support_tickets(customer_id)
    
    with tab4:
        render_customer_analytics(customer_id)
    
    with tab5:
        render_ai_insights(customer_id, customer)

def render_customer_overview(customer):
    """Render customer overview information"""
    
    col1, col2 = st.columns([1, 1])
    
    with col1:
        st.subheader("📞 Contact Information")
        email = safe_get_str(customer.get('EMAIL', ''), 'Not provided')
        phone = safe_get_str(customer.get('PHONE', ''), 'Not provided')
        city = safe_get_str(customer.get('CITY', ''), 'N/A')
        state = safe_get_str(customer.get('STATE_PROVINCE', ''), 'N/A')
        country = safe_get_str(customer.get('COUNTRY', ''), 'N/A')
        
        st.write(f"**Email:** {email}")
        st.write(f"**Phone:** {phone}")
        st.write(f"**Location:** {city}, {state}")
        st.write(f"**Country:** {country}")
        
        if customer.get('PREFERRED_COMMUNICATION_CHANNEL'):
            channel = safe_get_str(customer['PREFERRED_COMMUNICATION_CHANNEL'], '').title()
            st.write(f"**Preferred Contact:** {channel}")
        
        st.subheader("📅 Account Details")
        join_date = safe_get_str(customer.get('JOIN_DATE', ''), 'N/A')
        account_status = safe_get_str(customer.get('ACCOUNT_STATUS', ''), 'unknown').title()
        customer_id = safe_get_str(customer.get('CUSTOMER_ID', ''), 'Unknown')
        
        st.write(f"**Member Since:** {join_date}")
        st.write(f"**Account Status:** {account_status}")
        st.write(f"**Customer ID:** {customer_id}")
        
        if customer.get('LAST_LOGIN_DATE'):
            try:
                days_since_login = st.session_state.data_helpers.calculate_days_since(customer['LAST_LOGIN_DATE'])
                st.write(f"**Last Login:** {days_since_login} days ago")
            except:
                st.write(f"**Last Login:** N/A")
    
    with col2:
        st.subheader("💰 Financial Summary")
        total_spent = safe_format_currency(customer.get('TOTAL_SPENT', 0))
        lifetime_value = safe_format_currency(customer.get('LIFETIME_VALUE', 0))
        
        st.write(f"**Total Spent:** {total_spent}")
        st.write(f"**Lifetime Value:** {lifetime_value}")
        
        if customer.get('CREDIT_LIMIT'):
            credit_limit = safe_format_currency(customer['CREDIT_LIMIT'])
            st.write(f"**Credit Limit:** {credit_limit}")
        
        st.subheader("📈 Behavioral Metrics")
        churn_risk = safe_format_percentage(customer.get('CHURN_RISK_SCORE', 0))
        satisfaction = safe_format_decimal(customer.get('SATISFACTION_SCORE', 0), 1)
        engagement = safe_format_percentage(customer.get('ENGAGEMENT_SCORE', 0))
        
        st.write(f"**Churn Risk:** {churn_risk}")
        st.write(f"**Satisfaction:** {satisfaction}/5.0")
        st.write(f"**Engagement:** {engagement}")
        
        # Customer tags
        if customer.get('CUSTOMER_TAGS'):
            st.subheader("🏷️ Customer Tags")
            try:
                tags = customer['CUSTOMER_TAGS']
                if isinstance(tags, str):
                    tags = json.loads(tags)
                if isinstance(tags, list):
                    for tag in tags:
                        st.markdown(f"- `{tag}`")
                else:
                    st.write("Tags format not recognized")
            except (json.JSONDecodeError, TypeError):
                st.write("Tags not available")
    
    # Recent activity summary
    st.subheader("🔄 Recent Activity")
    try:
        activities_df = st.session_state.data_helpers.get_customer_activities(customer['CUSTOMER_ID'], limit=5)
        
        if not activities_df.empty:
            for _, activity in activities_df.iterrows():
                try:
                    activity_time = pd.to_datetime(activity['ACTIVITY_TIMESTAMP']).strftime('%Y-%m-%d %H:%M')
                except:
                    activity_time = "Unknown time"
                
                title = safe_get_str(activity.get('ACTIVITY_TITLE', ''), 'Unknown Activity')
                channel = safe_get_str(activity.get('CHANNEL', ''), 'Unknown')
                priority = safe_get_str(activity.get('PRIORITY', ''), 'Normal')
                description = safe_get_str(activity.get('ACTIVITY_DESCRIPTION', ''), 'No description')
                
                st.markdown(f"""
                **{title}**  
                *{activity_time}* • {channel} • Priority: {priority}  
                {description}
                """)
                st.markdown("---")
        else:
            st.info("No recent activities found.")
    except Exception as e:
        st.error(f"Error loading activities: {str(e)}")

def render_purchase_history(customer_id):
    """Render customer purchase history"""
    
    st.subheader("🛒 Purchase History")
    
    try:
        purchases_df = st.session_state.data_helpers.get_customer_purchases(customer_id)
        
        if purchases_df.empty:
            st.info("No purchase history found.")
            return
        
        # Purchase summary metrics
        col1, col2, col3, col4 = st.columns(4)
        
        total_orders = len(purchases_df)
        total_amount = purchases_df['TOTAL_AMOUNT'].sum() if 'TOTAL_AMOUNT' in purchases_df.columns else 0
        avg_order_value = purchases_df['TOTAL_AMOUNT'].mean() if 'TOTAL_AMOUNT' in purchases_df.columns else 0
        
        with col1:
            st.metric("Total Orders", total_orders)
        with col2:
            st.metric("Total Spent", safe_format_currency(total_amount))
        with col3:
            st.metric("Avg Order Value", safe_format_currency(avg_order_value))
        with col4:
            if 'PURCHASE_DATE' in purchases_df.columns:
                try:
                    last_purchase = purchases_df['PURCHASE_DATE'].max()
                    days_since = st.session_state.data_helpers.calculate_days_since(last_purchase)
                    st.metric("Last Purchase", f"{days_since} days ago")
                except:
                    st.metric("Last Purchase", "N/A")
            else:
                st.metric("Last Purchase", "N/A")
        
        # Purchase trend chart
        if len(purchases_df) > 1 and 'PURCHASE_DATE' in purchases_df.columns and 'TOTAL_AMOUNT' in purchases_df.columns:
            try:
                purchases_df['PURCHASE_DATE'] = pd.to_datetime(purchases_df['PURCHASE_DATE'])
                monthly_purchases = purchases_df.groupby(purchases_df['PURCHASE_DATE'].dt.to_period('M')).agg({
                    'TOTAL_AMOUNT': 'sum',
                    'PURCHASE_ID': 'count'
                }).reset_index()
                monthly_purchases['PURCHASE_DATE'] = monthly_purchases['PURCHASE_DATE'].astype(str)
                
                fig = px.line(monthly_purchases, x='PURCHASE_DATE', y='TOTAL_AMOUNT',
                             title="Monthly Purchase Trends", markers=True)
                fig.update_layout(xaxis_title="Month", yaxis_title="Amount ($)")
                st.plotly_chart(fig, use_container_width=True)
            except Exception as e:
                st.info(f"Could not generate trend chart: {str(e)}")
        
        # Detailed purchase list
        st.subheader("📋 Purchase Details")
        
        # Format the dataframe for display
        display_df = purchases_df.copy()
        
        # Safe column formatting
        if 'PURCHASE_DATE' in display_df.columns:
            try:
                display_df['PURCHASE_DATE'] = pd.to_datetime(display_df['PURCHASE_DATE']).dt.strftime('%Y-%m-%d')
            except:
                pass
        
        if 'TOTAL_AMOUNT' in display_df.columns:
            display_df['TOTAL_AMOUNT'] = display_df['TOTAL_AMOUNT'].apply(
                lambda x: safe_format_currency(x) if pd.notna(x) else "$0.00"
            )
        
        # Select available columns for display
        desired_cols = ['PURCHASE_DATE', 'PRODUCT_NAME', 'PRODUCT_CATEGORY', 'QUANTITY', 'TOTAL_AMOUNT', 'ORDER_STATUS']
        available_cols = [col for col in desired_cols if col in display_df.columns]
        
        if available_cols:
            st.dataframe(display_df[available_cols], use_container_width=True)
        else:
            st.dataframe(display_df, use_container_width=True)
            
    except Exception as e:
        st.error(f"Error loading purchase history: {str(e)}")

def render_support_tickets(customer_id):
    """Render customer support tickets"""
    
    st.subheader("🎫 Support Tickets")
    
    try:
        tickets_df = st.session_state.data_helpers.get_customer_support_tickets(customer_id)
        
        if tickets_df.empty:
            st.info("No support tickets found.")
            return
        
        # Support summary metrics
        col1, col2, col3, col4 = st.columns(4)
        
        total_tickets = len(tickets_df)
        open_tickets = len(tickets_df[tickets_df['STATUS'] == 'open']) if 'STATUS' in tickets_df.columns else 0
        
        with col1:
            st.metric("Total Tickets", total_tickets)
        with col2:
            st.metric("Open Tickets", open_tickets, delta="Urgent" if open_tickets > 0 else "None")
        with col3:
            if 'RESOLUTION_TIME_HOURS' in tickets_df.columns:
                avg_resolution = tickets_df['RESOLUTION_TIME_HOURS'].mean()
                if not pd.isna(avg_resolution):
                    st.metric("Avg Resolution", f"{safe_format_decimal(avg_resolution, 1)} hours")
                else:
                    st.metric("Avg Resolution", "N/A")
            else:
                st.metric("Avg Resolution", "N/A")
        with col4:
            if 'CUSTOMER_SATISFACTION_RATING' in tickets_df.columns:
                avg_satisfaction = tickets_df['CUSTOMER_SATISFACTION_RATING'].mean()
                if not pd.isna(avg_satisfaction):
                    st.metric("Avg Satisfaction", f"{safe_format_decimal(avg_satisfaction, 1)}/5")
                else:
                    st.metric("Avg Satisfaction", "N/A")
            else:
                st.metric("Avg Satisfaction", "N/A")
        
        # Ticket category distribution
        if len(tickets_df) > 1 and 'CATEGORY' in tickets_df.columns:
            try:
                category_counts = tickets_df['CATEGORY'].value_counts()
                fig = px.pie(values=category_counts.values, names=category_counts.index,
                            title="Tickets by Category")
                st.plotly_chart(fig, use_container_width=True)
            except Exception as e:
                st.info(f"Could not generate category chart: {str(e)}")
        
        # Detailed ticket list
        st.subheader("📋 Ticket Details")
        
        for _, ticket in tickets_df.iterrows():
            # Determine status color
            status_colors = {
                'open': '🔴',
                'in_progress': '🟡',
                'resolved': '🟢',
                'closed': '⚫'
            }
            
            status = safe_get_str(ticket.get('STATUS', ''), 'unknown').lower()
            status_icon = status_colors.get(status, '⚪')
            subject = safe_get_str(ticket.get('SUBJECT', ''), 'No Subject')
            priority = safe_get_str(ticket.get('PRIORITY', ''), 'normal').upper()
            
            try:
                created_date = pd.to_datetime(ticket['CREATED_AT']).strftime('%Y-%m-%d %H:%M') if 'CREATED_AT' in ticket and pd.notna(ticket['CREATED_AT']) else 'Unknown'
            except:
                created_date = 'Unknown'
            
            with st.expander(f"{status_icon} {subject} - {priority} Priority"):
                col1, col2 = st.columns(2)
                
                with col1:
                    ticket_id = safe_get_str(ticket.get('TICKET_ID', ''), 'Unknown')
                    category = safe_get_str(ticket.get('CATEGORY', ''), 'Unknown')
                    
                    st.write(f"**Ticket ID:** {ticket_id}")
                    st.write(f"**Category:** {category}")
                    st.write(f"**Priority:** {priority}")
                    st.write(f"**Status:** {status}")
                
                with col2:
                    st.write(f"**Created:** {created_date}")
                    
                    if 'RESOLVED_AT' in ticket and pd.notna(ticket['RESOLVED_AT']):
                        try:
                            resolved_date = pd.to_datetime(ticket['RESOLVED_AT']).strftime('%Y-%m-%d %H:%M')
                            st.write(f"**Resolved:** {resolved_date}")
                        except:
                            st.write(f"**Resolved:** Unknown")
                    
                    if 'RESOLUTION_TIME_HOURS' in ticket and pd.notna(ticket['RESOLUTION_TIME_HOURS']):
                        resolution_time = safe_format_decimal(ticket['RESOLUTION_TIME_HOURS'], 0)
                        st.write(f"**Resolution Time:** {resolution_time} hours")
                    
                    if 'CUSTOMER_SATISFACTION_RATING' in ticket and pd.notna(ticket['CUSTOMER_SATISFACTION_RATING']):
                        rating = safe_format_decimal(ticket['CUSTOMER_SATISFACTION_RATING'], 0)
                        st.write(f"**Satisfaction:** {rating}/5 ⭐")
    
    except Exception as e:
        st.error(f"Error loading support tickets: {str(e)}")

def render_customer_analytics(customer_id):
    """Render customer analytics and insights"""
    
    st.subheader("📊 Customer Analytics")
    
    try:
        # Get comprehensive customer metrics
        metrics = st.session_state.data_helpers.get_customer_metrics(customer_id)
        
        if not metrics:
            st.error("Unable to load customer analytics.")
            return
        
        # Activity analysis
        if metrics.get('activity_metrics'):
            st.subheader("📱 Activity Analysis")
            
            activity_metrics = metrics['activity_metrics']
            
            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("Total Activities", activity_metrics.get('TOTAL_ACTIVITIES', 0))
            with col2:
                st.metric("Activity Types", activity_metrics.get('ACTIVITY_TYPES', 0))
            with col3:
                st.metric("Recent Activities (30d)", activity_metrics.get('ACTIVITIES_LAST_30_DAYS', 0))
            
            # Activity timeline
            try:
                activities_df = st.session_state.data_helpers.get_customer_activities(customer_id, limit=50)
                if not activities_df.empty:
                    activities_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP'])
                    activities_df['Date'] = activities_df['ACTIVITY_TIMESTAMP'].dt.date
                    
                    daily_activities = activities_df.groupby(['Date', 'ACTIVITY_TYPE']).size().reset_index(name='Count')
                    
                    fig = px.bar(daily_activities, x='Date', y='Count', color='ACTIVITY_TYPE',
                                title="Daily Activity Timeline")
                    fig.update_layout(xaxis_title="Date", yaxis_title="Number of Activities")
                    st.plotly_chart(fig, use_container_width=True)
            except Exception as e:
                st.info(f"Could not generate activity timeline: {str(e)}")
        
        # Purchase analysis
        if metrics.get('purchase_metrics'):
            st.subheader("💳 Purchase Analysis")
            
            purchase_metrics = metrics['purchase_metrics']
            
            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("Total Purchases", purchase_metrics.get('TOTAL_PURCHASES', 0))
            with col2:
                total_spent = safe_format_currency(purchase_metrics.get('TOTAL_SPENT', 0))
                st.metric("Total Spent", total_spent)
            with col3:
                avg_order = safe_format_currency(purchase_metrics.get('AVG_ORDER_VALUE', 0))
                st.metric("Avg Order Value", avg_order)
        
        # Engagement scoring
        st.subheader("🎯 Engagement Scoring")
        
        customer_info = metrics.get('customer_info', {})
        engagement_score = customer_info.get('ENGAGEMENT_SCORE', 0) or 0
        satisfaction_score = customer_info.get('SATISFACTION_SCORE', 0) or 0
        churn_risk = customer_info.get('CHURN_RISK_SCORE', 0) or 0
        
        # Create gauge charts
        col1, col2, col3 = st.columns(3)
        
        with col1:
            fig_engagement = go.Figure(go.Indicator(
                mode = "gauge+number",
                value = engagement_score * 100,
                domain = {'x': [0, 1], 'y': [0, 1]},
                title = {'text': "Engagement Score"},
                gauge = {
                    'axis': {'range': [None, 100]},
                    'bar': {'color': "darkblue"},
                    'steps': [
                        {'range': [0, 50], 'color': "lightgray"},
                        {'range': [50, 80], 'color': "yellow"},
                        {'range': [80, 100], 'color': "green"}
                    ],
                    'threshold': {
                        'line': {'color': "red", 'width': 4},
                        'thickness': 0.75,
                        'value': 90
                    }
                }
            ))
            fig_engagement.update_layout(height=300)
            st.plotly_chart(fig_engagement, use_container_width=True)
        
        with col2:
            fig_satisfaction = go.Figure(go.Indicator(
                mode = "gauge+number",
                value = satisfaction_score * 20,  # Convert 5-point scale to 100
                domain = {'x': [0, 1], 'y': [0, 1]},
                title = {'text': "Satisfaction Score"},
                gauge = {
                    'axis': {'range': [None, 100]},
                    'bar': {'color': "darkgreen"},
                    'steps': [
                        {'range': [0, 60], 'color': "lightgray"},
                        {'range': [60, 80], 'color': "yellow"},
                        {'range': [80, 100], 'color': "green"}
                    ]
                }
            ))
            fig_satisfaction.update_layout(height=300)
            st.plotly_chart(fig_satisfaction, use_container_width=True)
        
        with col3:
            fig_risk = go.Figure(go.Indicator(
                mode = "gauge+number",
                value = churn_risk * 100,
                domain = {'x': [0, 1], 'y': [0, 1]},
                title = {'text': "Churn Risk Score"},
                gauge = {
                    'axis': {'range': [None, 100]},
                    'bar': {'color': "darkred"},
                    'steps': [
                        {'range': [0, 30], 'color': "green"},
                        {'range': [30, 70], 'color': "yellow"},
                        {'range': [70, 100], 'color': "red"}
                    ]
                }
            ))
            fig_risk.update_layout(height=300)
            st.plotly_chart(fig_risk, use_container_width=True)
    
    except Exception as e:
        st.error(f"Error loading customer analytics: {str(e)}")

def render_ai_insights(customer_id, customer):
    """Render AI-generated insights for the customer"""
    
    st.subheader("🤖 AI-Generated Insights")
    
    col1, col2 = st.columns([2, 1])
    
    with col1:
        # Generate insights button
        if st.button("🧠 Generate New Insights", use_container_width=True):
            with st.spinner("AI is analyzing customer data..."):
                try:
                    insights = st.session_state.cortex_client.analyze_customer(customer_id, 'overview')
                    st.session_state[f'insights_{customer_id}'] = insights
                except Exception as e:
                    st.error(f"Error generating insights: {str(e)}")
        
        # Display insights
        if f'insights_{customer_id}' in st.session_state:
            insights = st.session_state[f'insights_{customer_id}']
            
            st.markdown("### 💡 Key Insights")
            st.write(insights.get('message', 'No insights available'))
            
            if insights.get('data'):
                try:
                    st.dataframe(insights['data'])
                except:
                    st.write("Data available but could not display in table format")
                    
            if insights.get('chart'):
                try:
                    st.plotly_chart(insights['chart'], use_container_width=True)
                except:
                    st.info("Chart data available but could not display")
        else:
            st.info("Click 'Generate New Insights' to get AI analysis for this customer.")
    
    with col2:
        st.markdown("### 🎯 Quick Analysis")
        
        analysis_types = [
            ("🔄 Overview", "overview"),
            ("⚠️ Churn Risk", "churn_risk"), 
            ("💰 Opportunities", "opportunities"),
            ("🎫 Support Issues", "support_issues")
        ]
        
        for label, analysis_type in analysis_types:
            if st.button(label, key=f"analysis_{analysis_type}", use_container_width=True):
                with st.spinner(f"Analyzing {label.lower()}..."):
                    try:
                        result = st.session_state.cortex_client.analyze_customer(customer_id, analysis_type)
                        st.session_state[f'insights_{customer_id}'] = result
                        st.rerun()
                    except Exception as e:
                        st.error(f"Error with {label}: {str(e)}")
        
        st.markdown("### 📊 Customer Summary")
        
        # Safe formatting for customer summary
        tier = safe_get_str(customer.get('CUSTOMER_TIER', ''), 'bronze').title()
        risk_level = safe_format_percentage(customer.get('CHURN_RISK_SCORE', 0))
        satisfaction = safe_format_decimal(customer.get('SATISFACTION_SCORE', 0), 1)
        total_spent = safe_format_currency(customer.get('TOTAL_SPENT', 0))
        engagement = safe_format_percentage(customer.get('ENGAGEMENT_SCORE', 0))
        
        st.markdown(f"""
        **Tier:** {tier}  
        **Risk Level:** {risk_level}  
        **Satisfaction:** {satisfaction}/5.0  
        **Total Spent:** {total_spent}  
        **Engagement:** {engagement}
        """)
        
        # Risk assessment
        risk_score = customer.get('CHURN_RISK_SCORE', 0) or 0
        if risk_score > 0.7:
            st.error("🚨 **High Risk Customer**\nImmediate attention required!")
        elif risk_score > 0.3:
            st.warning("⚠️ **Medium Risk Customer**\nMonitor closely")
        else:
            st.success("✅ **Low Risk Customer**\nStable and engaged") 