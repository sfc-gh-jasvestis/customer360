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

def render_customer_profile(selected_customer):
    """Render detailed customer profile view"""
    
    if selected_customer is None:
        st.warning("Please select a customer from the sidebar to view their profile.")
        return
    
    customer = selected_customer
    customer_id = customer['CUSTOMER_ID']
    
    # Header with customer info
    st.header(f"👤 {customer['FIRST_NAME']} {customer['LAST_NAME']}")
    
    # Customer tier badge
    tier_colors = {
        'platinum': '#ffd700',
        'gold': '#fbbf24',
        'silver': '#9ca3af',
        'bronze': '#92400e'
    }
    
    tier_color = tier_colors.get(customer['CUSTOMER_TIER'], '#6b7280')
    
    st.markdown(f"""
    <div style="display: inline-block; background: {tier_color}; color: white; padding: 0.5rem 1rem; border-radius: 20px; font-weight: bold; margin-bottom: 1rem;">
        {customer['CUSTOMER_TIER'].upper()} CUSTOMER
    </div>
    """, unsafe_allow_html=True)
    
    # Key metrics row
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric(
            "Total Spent",
            f"${customer['TOTAL_SPENT']:,.2f}",
            delta=f"${customer['LIFETIME_VALUE'] - customer['TOTAL_SPENT']:,.2f} potential"
        )
    
    with col2:
        risk_score = customer['CHURN_RISK_SCORE']
        risk_color = "🔴" if risk_score > 0.7 else "🟡" if risk_score > 0.3 else "🟢"
        st.metric(
            "Churn Risk",
            f"{risk_color} {risk_score:.1%}",
            delta=f"{'High' if risk_score > 0.7 else 'Medium' if risk_score > 0.3 else 'Low'} risk"
        )
    
    with col3:
        satisfaction = customer.get('SATISFACTION_SCORE', 0)
        st.metric(
            "Satisfaction",
            f"{satisfaction:.1f}/5.0",
            delta=f"{'Above' if satisfaction > 4.0 else 'Below'} average"
        )
    
    with col4:
        engagement = customer.get('ENGAGEMENT_SCORE', 0)
        st.metric(
            "Engagement",
            f"{engagement:.1%}",
            delta=f"{'High' if engagement > 0.7 else 'Medium' if engagement > 0.4 else 'Low'} engagement"
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
        st.write(f"**Email:** {customer['EMAIL']}")
        st.write(f"**Phone:** {customer.get('PHONE', 'Not provided')}")
        st.write(f"**Location:** {customer.get('CITY', 'N/A')}, {customer.get('STATE_PROVINCE', 'N/A')}")
        st.write(f"**Country:** {customer.get('COUNTRY', 'N/A')}")
        
        if customer.get('PREFERRED_COMMUNICATION_CHANNEL'):
            st.write(f"**Preferred Contact:** {customer['PREFERRED_COMMUNICATION_CHANNEL'].title()}")
        
        st.subheader("📅 Account Details")
        st.write(f"**Member Since:** {customer.get('JOIN_DATE', 'N/A')}")
        st.write(f"**Account Status:** {customer['ACCOUNT_STATUS'].title()}")
        st.write(f"**Customer ID:** {customer['CUSTOMER_ID']}")
        
        if customer.get('LAST_LOGIN_DATE'):
            days_since_login = st.session_state.data_helpers.calculate_days_since(customer['LAST_LOGIN_DATE'])
            st.write(f"**Last Login:** {days_since_login} days ago")
    
    with col2:
        st.subheader("💰 Financial Summary")
        st.write(f"**Total Spent:** ${customer['TOTAL_SPENT']:,.2f}")
        st.write(f"**Lifetime Value:** ${customer['LIFETIME_VALUE']:,.2f}")
        
        if customer.get('CREDIT_LIMIT'):
            st.write(f"**Credit Limit:** ${customer['CREDIT_LIMIT']:,.2f}")
        
        st.subheader("📈 Behavioral Metrics")
        st.write(f"**Churn Risk:** {customer['CHURN_RISK_SCORE']:.1%}")
        st.write(f"**Satisfaction:** {customer.get('SATISFACTION_SCORE', 0):.1f}/5.0")
        st.write(f"**Engagement:** {customer.get('ENGAGEMENT_SCORE', 0):.1%}")
        
        # Customer tags
        if customer.get('CUSTOMER_TAGS'):
            st.subheader("🏷️ Customer Tags")
            try:
                tags = json.loads(customer['CUSTOMER_TAGS']) if isinstance(customer['CUSTOMER_TAGS'], str) else customer['CUSTOMER_TAGS']
                if isinstance(tags, list):
                    for tag in tags:
                        st.markdown(f"- `{tag}`")
            except (json.JSONDecodeError, TypeError):
                st.write("Tags not available")
    
    # Recent activity summary
    st.subheader("🔄 Recent Activity")
    activities_df = st.session_state.data_helpers.get_customer_activities(customer['CUSTOMER_ID'], limit=5)
    
    if not activities_df.empty:
        for _, activity in activities_df.iterrows():
            activity_time = pd.to_datetime(activity['ACTIVITY_TIMESTAMP']).strftime('%Y-%m-%d %H:%M')
            st.markdown(f"""
            **{activity['ACTIVITY_TITLE']}**  
            *{activity_time}* • {activity['CHANNEL']} • Priority: {activity['PRIORITY']}  
            {activity['ACTIVITY_DESCRIPTION']}
            """)
            st.markdown("---")
    else:
        st.info("No recent activities found.")

def render_purchase_history(customer_id):
    """Render customer purchase history"""
    
    st.subheader("🛒 Purchase History")
    
    purchases_df = st.session_state.data_helpers.get_customer_purchases(customer_id)
    
    if purchases_df.empty:
        st.info("No purchase history found.")
        return
    
    # Purchase summary metrics
    col1, col2, col3, col4 = st.columns(4)
    
    total_orders = len(purchases_df)
    total_amount = purchases_df['TOTAL_AMOUNT'].sum()
    avg_order_value = purchases_df['TOTAL_AMOUNT'].mean()
    last_purchase = purchases_df['PURCHASE_DATE'].max()
    
    with col1:
        st.metric("Total Orders", total_orders)
    with col2:
        st.metric("Total Spent", f"${total_amount:,.2f}")
    with col3:
        st.metric("Avg Order Value", f"${avg_order_value:,.2f}")
    with col4:
        days_since = st.session_state.data_helpers.calculate_days_since(last_purchase)
        st.metric("Last Purchase", f"{days_since} days ago")
    
    # Purchase trend chart
    if len(purchases_df) > 1:
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
    
    # Detailed purchase list
    st.subheader("📋 Purchase Details")
    
    # Format the dataframe for display
    display_df = purchases_df.copy()
    display_df['PURCHASE_DATE'] = pd.to_datetime(display_df['PURCHASE_DATE']).dt.strftime('%Y-%m-%d')
    display_df['TOTAL_AMOUNT'] = display_df['TOTAL_AMOUNT'].apply(lambda x: f"${x:.2f}")
    
    st.dataframe(
        display_df[['PURCHASE_DATE', 'PRODUCT_NAME', 'PRODUCT_CATEGORY', 'QUANTITY', 'TOTAL_AMOUNT', 'ORDER_STATUS']],
        use_container_width=True
    )

def render_support_tickets(customer_id):
    """Render customer support tickets"""
    
    st.subheader("🎫 Support Tickets")
    
    tickets_df = st.session_state.data_helpers.get_customer_support_tickets(customer_id)
    
    if tickets_df.empty:
        st.info("No support tickets found.")
        return
    
    # Support summary metrics
    col1, col2, col3, col4 = st.columns(4)
    
    total_tickets = len(tickets_df)
    open_tickets = len(tickets_df[tickets_df['STATUS'] == 'open'])
    avg_resolution = tickets_df['RESOLUTION_TIME_HOURS'].mean()
    avg_satisfaction = tickets_df['CUSTOMER_SATISFACTION_RATING'].mean()
    
    with col1:
        st.metric("Total Tickets", total_tickets)
    with col2:
        st.metric("Open Tickets", open_tickets, delta="Urgent" if open_tickets > 0 else "None")
    with col3:
        if not pd.isna(avg_resolution):
            st.metric("Avg Resolution", f"{avg_resolution:.1f} hours")
        else:
            st.metric("Avg Resolution", "N/A")
    with col4:
        if not pd.isna(avg_satisfaction):
            st.metric("Avg Satisfaction", f"{avg_satisfaction:.1f}/5")
        else:
            st.metric("Avg Satisfaction", "N/A")
    
    # Ticket category distribution
    if len(tickets_df) > 1:
        category_counts = tickets_df['CATEGORY'].value_counts()
        fig = px.pie(values=category_counts.values, names=category_counts.index,
                    title="Tickets by Category")
        st.plotly_chart(fig, use_container_width=True)
    
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
        
        status_icon = status_colors.get(ticket['STATUS'], '⚪')
        created_date = pd.to_datetime(ticket['CREATED_AT']).strftime('%Y-%m-%d %H:%M')
        
        with st.expander(f"{status_icon} {ticket['SUBJECT']} - {ticket['PRIORITY'].upper()} Priority"):
            col1, col2 = st.columns(2)
            
            with col1:
                st.write(f"**Ticket ID:** {ticket['TICKET_ID']}")
                st.write(f"**Category:** {ticket['CATEGORY']}")
                st.write(f"**Priority:** {ticket['PRIORITY']}")
                st.write(f"**Status:** {ticket['STATUS']}")
            
            with col2:
                st.write(f"**Created:** {created_date}")
                if not pd.isna(ticket['RESOLVED_AT']):
                    resolved_date = pd.to_datetime(ticket['RESOLVED_AT']).strftime('%Y-%m-%d %H:%M')
                    st.write(f"**Resolved:** {resolved_date}")
                if not pd.isna(ticket['RESOLUTION_TIME_HOURS']):
                    st.write(f"**Resolution Time:** {ticket['RESOLUTION_TIME_HOURS']} hours")
                if not pd.isna(ticket['CUSTOMER_SATISFACTION_RATING']):
                    st.write(f"**Satisfaction:** {ticket['CUSTOMER_SATISFACTION_RATING']}/5 ⭐")

def render_customer_analytics(customer_id):
    """Render customer analytics and insights"""
    
    st.subheader("📊 Customer Analytics")
    
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
        activities_df = st.session_state.data_helpers.get_customer_activities(customer_id, limit=50)
        if not activities_df.empty:
            activities_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP'])
            activities_df['Date'] = activities_df['ACTIVITY_TIMESTAMP'].dt.date
            
            daily_activities = activities_df.groupby(['Date', 'ACTIVITY_TYPE']).size().reset_index(name='Count')
            
            fig = px.bar(daily_activities, x='Date', y='Count', color='ACTIVITY_TYPE',
                        title="Daily Activity Timeline")
            fig.update_layout(xaxis_title="Date", yaxis_title="Number of Activities")
            st.plotly_chart(fig, use_container_width=True)
    
    # Purchase analysis
    if metrics.get('purchase_metrics'):
        st.subheader("💳 Purchase Analysis")
        
        purchase_metrics = metrics['purchase_metrics']
        
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Total Purchases", purchase_metrics.get('TOTAL_PURCHASES', 0))
        with col2:
            total_spent = purchase_metrics.get('TOTAL_SPENT', 0)
            st.metric("Total Spent", f"${total_spent:,.2f}")
        with col3:
            avg_order = purchase_metrics.get('AVG_ORDER_VALUE', 0)
            st.metric("Avg Order Value", f"${avg_order:,.2f}")
    
    # Engagement scoring
    st.subheader("🎯 Engagement Scoring")
    
    customer_info = metrics.get('customer_info', {})
    engagement_score = customer_info.get('ENGAGEMENT_SCORE', 0)
    satisfaction_score = customer_info.get('SATISFACTION_SCORE', 0)
    churn_risk = customer_info.get('CHURN_RISK_SCORE', 0)
    
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

def render_ai_insights(customer_id, customer):
    """Render AI-generated insights for the customer"""
    
    st.subheader("🤖 AI-Generated Insights")
    
    col1, col2 = st.columns([2, 1])
    
    with col1:
        # Generate insights button
        if st.button("🧠 Generate New Insights", use_container_width=True):
            with st.spinner("AI is analyzing customer data..."):
                insights = st.session_state.cortex_client.analyze_customer(customer_id, 'overview')
                st.session_state[f'insights_{customer_id}'] = insights
        
        # Display insights
        if f'insights_{customer_id}' in st.session_state:
            insights = st.session_state[f'insights_{customer_id}']
            
            st.markdown("### 💡 Key Insights")
            st.write(insights.get('message', 'No insights available'))
            
            if insights.get('data'):
                st.dataframe(insights['data'])
                
            if insights.get('chart'):
                st.plotly_chart(insights['chart'], use_container_width=True)
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
                    result = st.session_state.cortex_client.analyze_customer(customer_id, analysis_type)
                    st.session_state[f'insights_{customer_id}'] = result
                    st.rerun()
        
        st.markdown("### 📊 Customer Summary")
        st.markdown(f"""
        **Tier:** {customer['CUSTOMER_TIER'].title()}  
        **Risk Level:** {customer['CHURN_RISK_SCORE']:.1%}  
        **Satisfaction:** {customer.get('SATISFACTION_SCORE', 0):.1f}/5.0  
        **Total Spent:** ${customer['TOTAL_SPENT']:,.2f}  
        **Engagement:** {customer.get('ENGAGEMENT_SCORE', 0):.1%}
        """)
        
        # Risk assessment
        risk_score = customer['CHURN_RISK_SCORE']
        if risk_score > 0.7:
            st.error("🚨 **High Risk Customer**\nImmediate attention required!")
        elif risk_score > 0.3:
            st.warning("⚠️ **Medium Risk Customer**\nMonitor closely")
        else:
            st.success("✅ **Low Risk Customer**\nStable and engaged") 