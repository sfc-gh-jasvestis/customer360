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

# Helper functions for safe formatting
def safe_format_currency(value, default="$0.00"):
    """Safely format a value as currency"""
    try:
        if value is None or pd.isna(value):
            return default
        return f"${float(value):,.2f}"
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
    try:
        days_back = time_ranges[selected_range]
        activities_df = st.session_state.data_helpers.get_recent_activities(days=int(days_back * 24) if days_back < 1 else int(days_back))
    except Exception as e:
        st.error(f"Error loading activities: {str(e)}")
        return
    
    if activities_df.empty:
        st.info("No activities found for the selected criteria.")
        return
    
    # Apply filters
    try:
        filtered_df = activities_df.copy()
        
        if search_term:
            # Safe string filtering
            title_filter = filtered_df['ACTIVITY_TITLE'].astype(str).str.contains(search_term, case=False, na=False)
            desc_filter = filtered_df['ACTIVITY_DESCRIPTION'].astype(str).str.contains(search_term, case=False, na=False)
            customer_filter = filtered_df['CUSTOMER_ID'].astype(str).str.contains(search_term, case=False, na=False)
            filtered_df = filtered_df[title_filter | desc_filter | customer_filter]
        
        if selected_type != 'All' and 'ACTIVITY_TYPE' in filtered_df.columns:
            filtered_df = filtered_df[filtered_df['ACTIVITY_TYPE'] == selected_type]
        
        if selected_priority != 'All' and 'PRIORITY' in filtered_df.columns:
            filtered_df = filtered_df[filtered_df['PRIORITY'] == selected_priority]
    except Exception as e:
        st.error(f"Error filtering activities: {str(e)}")
        return
    
    # Activity summary
    if not filtered_df.empty:
        col1, col2, col3, col4 = st.columns(4)
        
        try:
            with col1:
                st.metric("Total Activities", safe_format_number(len(filtered_df)))
            
            with col2:
                if 'PRIORITY' in filtered_df.columns:
                    high_priority = len(filtered_df[filtered_df['PRIORITY'].isin(['high', 'urgent'])])
                    st.metric("High Priority", high_priority, delta="Needs attention" if high_priority > 0 else "None")
                else:
                    st.metric("High Priority", "N/A")
            
            with col3:
                if 'CUSTOMER_ID' in filtered_df.columns:
                    unique_customers = filtered_df['CUSTOMER_ID'].nunique()
                    st.metric("Active Customers", unique_customers)
                else:
                    st.metric("Active Customers", "N/A")
            
            with col4:
                if 'ACTIVITY_TIMESTAMP' in filtered_df.columns:
                    try:
                        filtered_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(filtered_df['ACTIVITY_TIMESTAMP'], errors='coerce')
                        recent_activities = len(filtered_df[filtered_df['ACTIVITY_TIMESTAMP'] >= datetime.now() - timedelta(hours=1)])
                        st.metric("Last Hour", recent_activities)
                    except:
                        st.metric("Last Hour", "N/A")
                else:
                    st.metric("Last Hour", "N/A")
        except Exception as e:
            st.error(f"Error calculating metrics: {str(e)}")
        
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
    
    try:
        # Group activities by time periods
        if 'ACTIVITY_TIMESTAMP' in activities_df.columns:
            activities_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP'], errors='coerce')
            activities_df = activities_df.sort_values('ACTIVITY_TIMESTAMP', ascending=False)
        
        # Get customer names for display
        try:
            customers_df = st.session_state.data_helpers.get_customers()
            if not customers_df.empty and 'CUSTOMER_ID' in customers_df.columns:
                customer_names = dict(zip(
                    customers_df['CUSTOMER_ID'], 
                    customers_df.get('FIRST_NAME', '').fillna('') + ' ' + customers_df.get('LAST_NAME', '').fillna('')
                ))
            else:
                customer_names = {}
        except:
            customer_names = {}
        
        # Display activities with timeline
        current_date = None
        
        for _, activity in activities_df.head(50).iterrows():  # Limit to 50 most recent
            try:
                if 'ACTIVITY_TIMESTAMP' in activity and pd.notna(activity['ACTIVITY_TIMESTAMP']):
                    activity_date = activity['ACTIVITY_TIMESTAMP'].date()
                    activity_time = activity['ACTIVITY_TIMESTAMP'].strftime('%H:%M:%S')
                else:
                    activity_date = datetime.now().date()
                    activity_time = "Unknown"
                
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
                
                priority = safe_get_str(activity.get('PRIORITY', ''), 'medium').lower()
                priority_icon = priority_icons.get(priority, '⚪')
                
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
                
                activity_type = safe_get_str(activity.get('ACTIVITY_TYPE', ''), 'unknown')
                type_icon = type_icons.get(activity_type, '📱')
                
                # Get customer name
                customer_id = safe_get_str(activity.get('CUSTOMER_ID', ''), 'Unknown')
                customer_name = customer_names.get(customer_id, customer_id)
                
                # Activity card
                with st.container():
                    col1, col2, col3 = st.columns([0.5, 5, 1])
                    
                    with col1:
                        st.markdown(f"<div style='font-size: 24px;'>{type_icon}</div>", unsafe_allow_html=True)
                    
                    with col2:
                        title = safe_get_str(activity.get('ACTIVITY_TITLE', ''), 'Activity')
                        channel = safe_get_str(activity.get('CHANNEL', ''), 'Unknown')
                        description = safe_get_str(activity.get('ACTIVITY_DESCRIPTION', ''), 'No description')
                        
                        st.markdown(f"""
                        **{title}** {priority_icon}  
                        👤 {customer_name} • {activity_time} • {channel}  
                        {description}
                        """)
                        
                        if 'TRANSACTION_AMOUNT' in activity and pd.notna(activity['TRANSACTION_AMOUNT']):
                            amount = safe_format_currency(activity['TRANSACTION_AMOUNT'])
                            st.markdown(f"💰 **Amount:** {amount}")
                    
                    with col3:
                        activity_id = safe_get_str(activity.get('ACTIVITY_ID', ''), f"act_{hash(str(activity))}")
                        if st.button("View", key=f"view_{activity_id}", use_container_width=True):
                            show_activity_details(activity, customer_name)
                
                st.markdown("---")
            except Exception as e:
                st.error(f"Error displaying activity: {str(e)}")
                continue
                
    except Exception as e:
        st.error(f"Error rendering activity stream: {str(e)}")

def render_activity_analytics(activities_df):
    """Render activity analytics and insights"""
    
    st.subheader("📈 Activity Analytics")
    
    try:
        # Time-based activity analysis
        col1, col2 = st.columns(2)
        
        with col1:
            # Activity count by type
            if 'ACTIVITY_TYPE' in activities_df.columns:
                try:
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
                except Exception as e:
                    st.info(f"Could not display activity types chart: {str(e)}")
            else:
                st.info("Activity type data not available")
        
        with col2:
            # Activity priority distribution
            if 'PRIORITY' in activities_df.columns:
                try:
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
                except Exception as e:
                    st.info(f"Could not display priority chart: {str(e)}")
            else:
                st.info("Priority data not available")
        
        # Activity timeline
        if len(activities_df) > 1 and 'ACTIVITY_TIMESTAMP' in activities_df.columns:
            st.subheader("📊 Activity Timeline")
            
            try:
                activities_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP'], errors='coerce')
                activities_df['Hour'] = activities_df['ACTIVITY_TIMESTAMP'].dt.hour
                
                if 'ACTIVITY_TYPE' in activities_df.columns:
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
                else:
                    # Simple hourly activity without type breakdown
                    hourly_activity = activities_df.groupby('Hour').size().reset_index(name='Count')
                    
                    fig_timeline = px.bar(
                        hourly_activity,
                        x='Hour',
                        y='Count',
                        title="Activity Distribution by Hour",
                        labels={'Hour': 'Hour of Day', 'Count': 'Number of Activities'}
                    )
                    st.plotly_chart(fig_timeline, use_container_width=True)
            except Exception as e:
                st.info(f"Could not display timeline chart: {str(e)}")
        
        # Channel analysis
        if 'CHANNEL' in activities_df.columns:
            st.subheader("📱 Channel Analysis")
            
            try:
                if 'PRIORITY' in activities_df.columns:
                    channel_analysis = activities_df.groupby(['CHANNEL', 'PRIORITY']).size().reset_index(name='Count')
                    
                    fig_channels = px.sunburst(
                        channel_analysis,
                        path=['CHANNEL', 'PRIORITY'],
                        values='Count',
                        title="Activities by Channel and Priority"
                    )
                    st.plotly_chart(fig_channels, use_container_width=True)
                else:
                    # Simple channel breakdown
                    channel_counts = activities_df['CHANNEL'].value_counts()
                    fig_channels = px.bar(
                        x=channel_counts.index,
                        y=channel_counts.values,
                        title="Activities by Channel"
                    )
                    st.plotly_chart(fig_channels, use_container_width=True)
            except Exception as e:
                st.info(f"Could not display channel chart: {str(e)}")
                
    except Exception as e:
        st.error(f"Error in activity analytics: {str(e)}")

def render_trending_activities(activities_df):
    """Render trending activities and patterns"""
    
    st.subheader("🔥 Trending Activities")
    
    try:
        # Most active customers
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("#### 🏆 Most Active Customers")
            
            if 'CUSTOMER_ID' in activities_df.columns:
                try:
                    customer_activity = activities_df['CUSTOMER_ID'].value_counts().head(10)
                    
                    # Get customer names
                    try:
                        customers_df = st.session_state.data_helpers.get_customers()
                        if not customers_df.empty and 'CUSTOMER_ID' in customers_df.columns:
                            customer_names = dict(zip(
                                customers_df['CUSTOMER_ID'], 
                                customers_df.get('FIRST_NAME', '').fillna('') + ' ' + customers_df.get('LAST_NAME', '').fillna('')
                            ))
                        else:
                            customer_names = {}
                    except:
                        customer_names = {}
                    
                    for i, (customer_id, count) in enumerate(customer_activity.items(), 1):
                        customer_name = customer_names.get(customer_id, customer_id)
                        if customer_name.strip():  # If we have a name
                            st.markdown(f"{i}. **{customer_name}** - {count} activities")
                        else:  # Fallback to customer ID
                            st.markdown(f"{i}. **Customer {customer_id}** - {count} activities")
                except Exception as e:
                    st.info(f"Could not display most active customers: {str(e)}")
            else:
                st.info("Customer data not available")
        
        with col2:
            st.markdown("#### 📊 Activity Trends")
            
            try:
                # Calculate activity trends
                now = datetime.now()
                
                if 'ACTIVITY_TIMESTAMP' in activities_df.columns:
                    activities_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP'], errors='coerce')
                    
                    last_hour = activities_df[activities_df['ACTIVITY_TIMESTAMP'] >= now - timedelta(hours=1)]
                    last_day = activities_df[activities_df['ACTIVITY_TIMESTAMP'] >= now - timedelta(days=1)]
                else:
                    last_hour = pd.DataFrame()
                    last_day = activities_df  # Assume all activities are recent if no timestamp
                
                high_priority_count = 0
                if 'PRIORITY' in activities_df.columns:
                    high_priority_count = len(activities_df[activities_df['PRIORITY'].isin(['high', 'urgent'])])
                
                support_count = 0
                if 'ACTIVITY_TYPE' in activities_df.columns:
                    support_count = len(activities_df[activities_df['ACTIVITY_TYPE'] == 'support'])
                
                trends = {
                    "Last Hour": len(last_hour),
                    "Last 24 Hours": len(last_day),
                    "High Priority": high_priority_count,
                    "Support Issues": support_count
                }
                
                for trend, count in trends.items():
                    st.metric(trend, count)
            except Exception as e:
                st.info(f"Could not calculate trends: {str(e)}")
        
        # Activity patterns
        st.subheader("🔍 Activity Patterns")
        
        try:
            patterns = []
            
            # High activity periods
            if 'ACTIVITY_TIMESTAMP' in activities_df.columns:
                try:
                    activities_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP'], errors='coerce')
                    activities_df['Hour'] = activities_df['ACTIVITY_TIMESTAMP'].dt.hour
                    hourly_counts = activities_df['Hour'].value_counts().sort_index()
                    
                    if not hourly_counts.empty:
                        peak_hour = hourly_counts.idxmax()
                        peak_count = hourly_counts.max()
                        patterns.append(f"🕒 **Peak Activity**: {peak_hour}:00 with {peak_count} activities")
                except:
                    pass
            
            # Support activity correlation
            if 'ACTIVITY_TYPE' in activities_df.columns:
                try:
                    support_activities = activities_df[activities_df['ACTIVITY_TYPE'] == 'support']
                    if not support_activities.empty:
                        support_ratio = len(support_activities) / len(activities_df) * 100
                        patterns.append(f"🎫 **Support Activity**: {safe_format_decimal(support_ratio, 1)}% of all activities")
                except:
                    pass
            
            # High-value customer activity
            try:
                customers_df = st.session_state.data_helpers.get_customers()
                if not customers_df.empty and 'CUSTOMER_TIER' in customers_df.columns and 'CUSTOMER_ID' in activities_df.columns:
                    high_value_customers = set(customers_df[customers_df['CUSTOMER_TIER'].isin(['gold', 'platinum'])]['CUSTOMER_ID'])
                    high_value_activities = activities_df[activities_df['CUSTOMER_ID'].isin(high_value_customers)]
                    
                    if not high_value_activities.empty:
                        hv_ratio = len(high_value_activities) / len(activities_df) * 100
                        patterns.append(f"💎 **High-Value Activity**: {safe_format_decimal(hv_ratio, 1)}% from premium customers")
            except:
                pass
            
            # Recent activity spike
            if 'ACTIVITY_TIMESTAMP' in activities_df.columns:
                try:
                    now = datetime.now()
                    activities_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP'], errors='coerce')
                    recent_activities = activities_df[activities_df['ACTIVITY_TIMESTAMP'] >= now - timedelta(hours=2)]
                    if len(recent_activities) > len(activities_df) * 0.3:  # If 30% of activities in last 2 hours
                        patterns.append("📈 **Activity Spike**: High activity detected in the last 2 hours")
                except:
                    pass
            
            if patterns:
                for pattern in patterns:
                    st.markdown(pattern)
            else:
                st.info("No significant patterns detected")
        except Exception as e:
            st.info(f"Could not analyze patterns: {str(e)}")
        
        # Real-time alerts
        st.subheader("🚨 Real-Time Alerts")
        
        try:
            alerts = []
            now = datetime.now()
            
            # Check for urgent activities
            if 'PRIORITY' in activities_df.columns:
                urgent_activities = activities_df[activities_df['PRIORITY'] == 'urgent']
                if not urgent_activities.empty:
                    alerts.append(f"🔴 **{len(urgent_activities)} Urgent Activities** - Immediate attention required")
            
            # Check for support escalations
            if 'ACTIVITY_TYPE' in activities_df.columns and 'ACTIVITY_TIMESTAMP' in activities_df.columns:
                try:
                    activities_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP'], errors='coerce')
                    recent_support = activities_df[
                        (activities_df['ACTIVITY_TYPE'] == 'support') & 
                        (activities_df['ACTIVITY_TIMESTAMP'] >= now - timedelta(hours=1))
                    ]
                    if len(recent_support) > 3:
                        alerts.append(f"🎫 **Support Spike** - {len(recent_support)} support activities in the last hour")
                except:
                    pass
            
            # Check for cart abandonments
            if 'ACTIVITY_TYPE' in activities_df.columns and 'ACTIVITY_TIMESTAMP' in activities_df.columns:
                try:
                    activities_df['ACTIVITY_TIMESTAMP'] = pd.to_datetime(activities_df['ACTIVITY_TIMESTAMP'], errors='coerce')
                    recent_abandons = activities_df[
                        (activities_df['ACTIVITY_TYPE'] == 'cart_abandonment') &
                        (activities_df['ACTIVITY_TIMESTAMP'] >= now - timedelta(hours=2))
                    ]
                    if len(recent_abandons) > 2:
                        alerts.append(f"🛒 **Cart Abandonment Alert** - {len(recent_abandons)} recent abandonments")
                except:
                    pass
            
            if alerts:
                for alert in alerts:
                    st.error(alert)
            else:
                st.success("✅ No critical alerts at this time")
        except Exception as e:
            st.info(f"Could not check alerts: {str(e)}")
            
    except Exception as e:
        st.error(f"Error in trending activities: {str(e)}")

def show_activity_details(activity, customer_name):
    """Show detailed activity information in a modal-like display"""
    
    st.markdown("---")
    st.markdown("### 🔍 Activity Details")
    
    try:
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("**Basic Information:**")
            activity_id = safe_get_str(activity.get('ACTIVITY_ID', ''), 'Unknown')
            activity_type = safe_get_str(activity.get('ACTIVITY_TYPE', ''), 'Unknown')
            channel = safe_get_str(activity.get('CHANNEL', ''), 'Unknown')
            priority = safe_get_str(activity.get('PRIORITY', ''), 'Normal')
            
            st.write(f"**Activity ID:** {activity_id}")
            st.write(f"**Customer:** {customer_name}")
            st.write(f"**Type:** {activity_type}")
            st.write(f"**Channel:** {channel}")
            st.write(f"**Priority:** {priority}")
            
            # Format timestamp
            if 'ACTIVITY_TIMESTAMP' in activity and pd.notna(activity['ACTIVITY_TIMESTAMP']):
                try:
                    timestamp = pd.to_datetime(activity['ACTIVITY_TIMESTAMP']).strftime('%Y-%m-%d %H:%M:%S')
                    st.write(f"**Timestamp:** {timestamp}")
                except:
                    st.write(f"**Timestamp:** {safe_get_str(activity.get('ACTIVITY_TIMESTAMP', ''), 'Unknown')}")
            else:
                st.write(f"**Timestamp:** Unknown")
        
        with col2:
            st.markdown("**Details:**")
            title = safe_get_str(activity.get('ACTIVITY_TITLE', ''), 'No Title')
            description = safe_get_str(activity.get('ACTIVITY_DESCRIPTION', ''), 'No Description')
            
            st.write(f"**Title:** {title}")
            st.write(f"**Description:** {description}")
            
            if 'TRANSACTION_AMOUNT' in activity and pd.notna(activity['TRANSACTION_AMOUNT']):
                amount = safe_format_currency(activity['TRANSACTION_AMOUNT'])
                st.write(f"**Amount:** {amount}")
            
            if 'STATUS' in activity:
                status = safe_get_str(activity.get('STATUS', ''), 'Unknown')
                st.write(f"**Status:** {status}")
        
        # Action buttons
        col1, col2, col3 = st.columns(3)
        
        button_key_base = safe_get_str(activity.get('ACTIVITY_ID', ''), f"act_{hash(str(activity))}")
        
        with col1:
            if st.button("👤 View Customer Profile", key=f"profile_{button_key_base}"):
                # This would navigate to customer profile
                st.info(f"Navigate to profile for {customer_name}")
        
        with col2:
            if st.button("📊 Customer Analytics", key=f"analytics_{button_key_base}"):
                st.info(f"Show analytics for {customer_name}")
        
        with col3:
            if st.button("🤖 AI Analysis", key=f"ai_{button_key_base}"):
                st.info(f"Generate AI insights for this activity")
        
        st.markdown("---")
        
    except Exception as e:
        st.error(f"Error displaying activity details: {str(e)}") 