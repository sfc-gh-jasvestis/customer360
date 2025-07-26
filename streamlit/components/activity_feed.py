"""
Activity Feed Component for Customer 360 Demo

This component provides a real-time activity feed showing:
- Recent customer activities across all channels
- Activity filtering and search
- Real-time updates
- Activity insights and patterns
"""

import streamlit as st
import pandas as pd
import plotly.express as px
from datetime import datetime, timedelta

def render_activity_feed():
    """Render the real-time activity feed"""
    
    st.header("📱 Real-Time Activity Feed")
    st.markdown("Monitor customer interactions and activities as they happen.")
    
    # Activity controls
    col1, col2, col3, col4 = st.columns([2, 1, 1, 1])
    
    with col1:
        # Search activities
        search_term = st.text_input("🔍 Search activities", placeholder="Search by customer, activity type, or description...")
    
    with col2:
        # Activity type filter
        activity_types = ['All', 'purchase', 'login', 'support', 'email', 'cart_abandonment']
        selected_type = st.selectbox("Activity Type", activity_types)
    
    with col3:
        # Priority filter
        priorities = ['All', 'low', 'medium', 'high', 'urgent']
        selected_priority = st.selectbox("Priority", priorities)
    
    with col4:
        # Time range
        time_ranges = {'Last Hour': 1/24, 'Last 24 Hours': 1, 'Last Week': 7, 'Last Month': 30}
        selected_range = st.selectbox("Time Range", list(time_ranges.keys()), index=1)
    
    # Get activities data
    days_back = time_ranges[selected_range]
    activities_df = st.session_state.data_helpers.get_recent_activities(days=int(days_back * 24) if days_back < 1 else int(days_back))
    
    if activities_df.empty:
        st.info("No activities found for the selected criteria.")
        return
    
    # Apply filters
    filtered_df = activities_df.copy()
    
    if search_term:
        filtered_df = filtered_df[
            filtered_df['ACTIVITY_TITLE'].str.contains(search_term, case=False, na=False) |
            filtered_df['ACTIVITY_DESCRIPTION'].str.contains(search_term, case=False, na=False) |
            filtered_df['CUSTOMER_ID'].str.contains(search_term, case=False, na=False)
        ]
    
    if selected_type != 'All':
        filtered_df = filtered_df[filtered_df['ACTIVITY_TYPE'] == selected_type]
    
    if selected_priority != 'All':
        filtered_df = filtered_df[filtered_df['PRIORITY'] == selected_priority]
    
    # Activity summary
    if not filtered_df.empty:
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("Total Activities", f"{len(filtered_df):,}")
        
        with col2:
            high_priority = len(filtered_df[filtered_df['PRIORITY'].isin(['high', 'urgent'])])
            st.metric("High Priority", high_priority, delta="Needs attention" if high_priority > 0 else "None")
        
        with col3:
            unique_customers = filtered_df['CUSTOMER_ID'].nunique()
            st.metric("Active Customers", unique_customers)
        
        with col4:
            recent_activities = len(filtered_df[pd.to_datetime(filtered_df['ACTIVITY_TIMESTAMP']) >= datetime.now() - timedelta(hours=1)])
            st.metric("Last Hour", recent_activities)
        
        st.divider()
        
        # Activity visualizations
        tab1, tab2, tab3 = st.tabs(["📊 Activity Stream", "📈 Analytics", "🔥 Trending"])
        
        with tab1:
            render_activity_stream(filtered_df)
        
        with tab2:
            render_activity_analytics(filtered_df)
        
        with tab3:
            render_trending_activities(filtered_df)
    else:
        st.warning("No activities match your current filters.")

def render_activity_stream(activities_df):
    """Render the main activity stream"""
    
    st.subheader("🔄 Activity Stream")
    
    # Auto-refresh toggle
    col1, col2 = st.columns([3, 1])
    
    with col2:
        auto_refresh = st.checkbox("🔄 Auto-refresh", value=False)
        if auto_refresh:
            st.rerun()
    
    # Group activities by time periods
    activities_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP'])
    activities_df = activities_df.sort_values('ACTIVITY_TIMESTAMP', ascending=False)
    
    # Get customer names for display
    customers_df = st.session_state.data_helpers.get_customers()
    customer_names = dict(zip(customers_df['CUSTOMER_ID'], customers_df['FIRST_NAME'] + ' ' + customers_df['LAST_NAME']))
    
    # Display activities with timeline
    current_date = None
    
    for _, activity in activities_df.head(50).iterrows():  # Limit to 50 most recent
        activity_date = activity['ACTIVITY_TIMESTAMP'].date()
        activity_time = activity['ACTIVITY_TIMESTAMP'].strftime('%H:%M:%S')
        
        # Date separator
        if current_date != activity_date:
            st.markdown(f"### 📅 {activity_date.strftime('%B %d, %Y')}")
            current_date = activity_date
        
        # Activity priority icon
        priority_icons = {
            'low': '🟢',
            'medium': '🟡', 
            'high': '🟠',
            'urgent': '🔴'
        }
        
        priority_icon = priority_icons.get(activity['PRIORITY'], '⚪')
        
        # Activity type icon
        type_icons = {
            'purchase': '🛒',
            'login': '🔐',
            'support': '🎫',
            'email': '📧',
            'cart_abandonment': '🛒❌',
            'product_review': '⭐',
            'referral': '👥',
            'subscription': '📰'
        }
        
        type_icon = type_icons.get(activity['ACTIVITY_TYPE'], '📱')
        
        # Get customer name
        customer_name = customer_names.get(activity['CUSTOMER_ID'], activity['CUSTOMER_ID'])
        
        # Activity card
        with st.container():
            col1, col2, col3 = st.columns([0.5, 5, 1])
            
            with col1:
                st.markdown(f"<div style='font-size: 24px;'>{type_icon}</div>", unsafe_allow_html=True)
            
            with col2:
                st.markdown(f"""
                **{activity['ACTIVITY_TITLE']}** {priority_icon}  
                👤 {customer_name} • {activity_time} • {activity['CHANNEL']}  
                {activity['ACTIVITY_DESCRIPTION']}
                """)
                
                if activity.get('TRANSACTION_AMOUNT') and pd.notna(activity['TRANSACTION_AMOUNT']):
                    st.markdown(f"💰 **Amount:** ${activity['TRANSACTION_AMOUNT']:,.2f}")
            
            with col3:
                if st.button("View", key=f"view_{activity['ACTIVITY_ID']}", use_container_width=True):
                    show_activity_details(activity, customer_name)
        
        st.markdown("---")

def render_activity_analytics(activities_df):
    """Render activity analytics and insights"""
    
    st.subheader("📈 Activity Analytics")
    
    # Time-based activity analysis
    col1, col2 = st.columns(2)
    
    with col1:
        # Activity count by type
        type_counts = activities_df['ACTIVITY_TYPE'].value_counts()
        
        fig_types = px.bar(
            x=type_counts.values,
            y=type_counts.index,
            orientation='h',
            title="Activities by Type",
            labels={'x': 'Count', 'y': 'Activity Type'}
        )
        fig_types.update_layout(height=400)
        st.plotly_chart(fig_types, use_container_width=True)
    
    with col2:
        # Activity priority distribution
        priority_counts = activities_df['PRIORITY'].value_counts()
        
        color_map = {
            'low': '#22c55e',
            'medium': '#eab308',
            'high': '#f97316',
            'urgent': '#ef4444'
        }
        
        colors = [color_map.get(priority, '#6b7280') for priority in priority_counts.index]
        
        fig_priority = px.pie(
            values=priority_counts.values,
            names=priority_counts.index,
            title="Activity Priority Distribution",
            color_discrete_sequence=colors
        )
        st.plotly_chart(fig_priority, use_container_width=True)
    
    # Activity timeline
    if len(activities_df) > 1:
        st.subheader("📊 Activity Timeline")
        
        activities_df['Hour'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP']).dt.hour
        hourly_activity = activities_df.groupby(['Hour', 'ACTIVITY_TYPE']).size().reset_index(name='Count')
        
        fig_timeline = px.bar(
            hourly_activity,
            x='Hour',
            y='Count',
            color='ACTIVITY_TYPE',
            title="Activity Distribution by Hour",
            labels={'Hour': 'Hour of Day', 'Count': 'Number of Activities'}
        )
        fig_timeline.update_layout(xaxis_title="Hour of Day (24H)", yaxis_title="Activity Count")
        st.plotly_chart(fig_timeline, use_container_width=True)
    
    # Channel analysis
    if 'CHANNEL' in activities_df.columns:
        st.subheader("📱 Channel Analysis")
        
        channel_analysis = activities_df.groupby(['CHANNEL', 'PRIORITY']).size().reset_index(name='Count')
        
        fig_channels = px.sunburst(
            channel_analysis,
            path=['CHANNEL', 'PRIORITY'],
            values='Count',
            title="Activities by Channel and Priority"
        )
        st.plotly_chart(fig_channels, use_container_width=True)

def render_trending_activities(activities_df):
    """Render trending activities and patterns"""
    
    st.subheader("🔥 Trending Activities")
    
    # Most active customers
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("#### 🏆 Most Active Customers")
        
        customer_activity = activities_df['CUSTOMER_ID'].value_counts().head(10)
        customers_df = st.session_state.data_helpers.get_customers()
        customer_names = dict(zip(customers_df['CUSTOMER_ID'], customers_df['FIRST_NAME'] + ' ' + customers_df['LAST_NAME']))
        
        for i, (customer_id, count) in enumerate(customer_activity.items(), 1):
            customer_name = customer_names.get(customer_id, customer_id)
            st.markdown(f"{i}. **{customer_name}** - {count} activities")
    
    with col2:
        st.markdown("#### 📊 Activity Trends")
        
        # Calculate activity trends
        now = datetime.now()
        last_hour = activities_df[pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP']) >= now - timedelta(hours=1)]
        last_day = activities_df[pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP']) >= now - timedelta(days=1)]
        
        trends = {
            "Last Hour": len(last_hour),
            "Last 24 Hours": len(last_day),
            "High Priority": len(activities_df[activities_df['PRIORITY'].isin(['high', 'urgent'])]),
            "Support Issues": len(activities_df[activities_df['ACTIVITY_TYPE'] == 'support'])
        }
        
        for trend, count in trends.items():
            st.metric(trend, count)
    
    # Activity patterns
    st.subheader("🔍 Activity Patterns")
    
    # Identify patterns
    patterns = []
    
    # High activity periods
    activities_df['Hour'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP']).dt.hour
    hourly_counts = activities_df['Hour'].value_counts().sort_index()
    peak_hour = hourly_counts.idxmax()
    peak_count = hourly_counts.max()
    
    patterns.append(f"🕒 **Peak Activity**: {peak_hour}:00 with {peak_count} activities")
    
    # Support activity correlation
    support_activities = activities_df[activities_df['ACTIVITY_TYPE'] == 'support']
    if not support_activities.empty:
        support_ratio = len(support_activities) / len(activities_df) * 100
        patterns.append(f"🎫 **Support Activity**: {support_ratio:.1f}% of all activities")
    
    # High-value customer activity
    customers_df = st.session_state.data_helpers.get_customers()
    high_value_customers = set(customers_df[customers_df['CUSTOMER_TIER'].isin(['gold', 'platinum'])]['CUSTOMER_ID'])
    high_value_activities = activities_df[activities_df['CUSTOMER_ID'].isin(high_value_customers)]
    
    if not high_value_activities.empty:
        hv_ratio = len(high_value_activities) / len(activities_df) * 100
        patterns.append(f"💎 **High-Value Activity**: {hv_ratio:.1f}% from premium customers")
    
    # Recent activity spike
    recent_activities = activities_df[pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP']) >= now - timedelta(hours=2)]
    if len(recent_activities) > len(activities_df) * 0.3:  # If 30% of activities in last 2 hours
        patterns.append("📈 **Activity Spike**: High activity detected in the last 2 hours")
    
    for pattern in patterns:
        st.markdown(pattern)
    
    # Real-time alerts
    st.subheader("🚨 Real-Time Alerts")
    
    alerts = []
    
    # Check for urgent activities
    urgent_activities = activities_df[activities_df['PRIORITY'] == 'urgent']
    if not urgent_activities.empty:
        alerts.append(f"🔴 **{len(urgent_activities)} Urgent Activities** - Immediate attention required")
    
    # Check for support escalations
    recent_support = activities_df[
        (activities_df['ACTIVITY_TYPE'] == 'support') & 
        (pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP']) >= now - timedelta(hours=1))
    ]
    if len(recent_support) > 3:
        alerts.append(f"🎫 **Support Spike** - {len(recent_support)} support activities in the last hour")
    
    # Check for cart abandonments
    recent_abandons = activities_df[
        (activities_df['ACTIVITY_TYPE'] == 'cart_abandonment') &
        (pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP']) >= now - timedelta(hours=2))
    ]
    if len(recent_abandons) > 2:
        alerts.append(f"🛒 **Cart Abandonment Alert** - {len(recent_abandons)} recent abandonments")
    
    if alerts:
        for alert in alerts:
            st.error(alert)
    else:
        st.success("✅ No critical alerts at this time")

def show_activity_details(activity, customer_name):
    """Show detailed activity information in a modal-like display"""
    
    st.markdown("---")
    st.markdown("### 🔍 Activity Details")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("**Basic Information:**")
        st.write(f"**Activity ID:** {activity['ACTIVITY_ID']}")
        st.write(f"**Customer:** {customer_name}")
        st.write(f"**Type:** {activity['ACTIVITY_TYPE']}")
        st.write(f"**Channel:** {activity['CHANNEL']}")
        st.write(f"**Priority:** {activity['PRIORITY']}")
        st.write(f"**Timestamp:** {activity['ACTIVITY_TIMESTAMP']}")
    
    with col2:
        st.markdown("**Details:**")
        st.write(f"**Title:** {activity['ACTIVITY_TITLE']}")
        st.write(f"**Description:** {activity['ACTIVITY_DESCRIPTION']}")
        
        if activity.get('TRANSACTION_AMOUNT') and pd.notna(activity['TRANSACTION_AMOUNT']):
            st.write(f"**Amount:** ${activity['TRANSACTION_AMOUNT']:,.2f}")
        
        if activity.get('STATUS'):
            st.write(f"**Status:** {activity['STATUS']}")
    
    # Action buttons
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("👤 View Customer Profile", key=f"profile_{activity['ACTIVITY_ID']}"):
            # This would navigate to customer profile
            st.info(f"Navigate to profile for {customer_name}")
    
    with col2:
        if st.button("📊 Customer Analytics", key=f"analytics_{activity['ACTIVITY_ID']}"):
            st.info(f"Show analytics for {customer_name}")
    
    with col3:
        if st.button("🤖 AI Analysis", key=f"ai_{activity['ACTIVITY_ID']}"):
            st.info(f"Generate AI insights for this activity")
    
    st.markdown("---") 