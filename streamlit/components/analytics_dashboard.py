"""
Analytics Dashboard Component for Customer 360 Demo

This component provides comprehensive analytics and visualizations including:
- Customer segmentation analysis
- Revenue analytics
- Churn prediction insights
- Support metrics
- Trend analysis
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import numpy as np

def render_analytics_dashboard():
    """Render the main analytics dashboard"""
    
    st.header("📊 Analytics Dashboard")
    st.markdown("Comprehensive insights into customer behavior, revenue trends, and business metrics.")
    
    # Get analytics data
    analytics_data = st.session_state.data_helpers.get_analytics_data()
    
    if not analytics_data:
        st.error("Unable to load analytics data.")
        return
    
    # Dashboard tabs
    tab1, tab2, tab3, tab4, tab5 = st.tabs([
        "🎯 Customer Insights", 
        "💰 Revenue Analytics", 
        "⚠️ Risk Assessment", 
        "🎫 Support Metrics", 
        "📈 Trends & Forecasting"
    ])
    
    with tab1:
        render_customer_insights(analytics_data)
    
    with tab2:
        render_revenue_analytics(analytics_data)
    
    with tab3:
        render_risk_assessment(analytics_data)
    
    with tab4:
        render_support_metrics(analytics_data)
    
    with tab5:
        render_trends_forecasting(analytics_data)

def render_customer_insights(analytics_data):
    """Render customer insights and segmentation"""
    
    st.subheader("🎯 Customer Segmentation & Insights")
    
    # Customer tier analysis
    tier_data = analytics_data.get('tier_distribution', pd.DataFrame())
    revenue_data = analytics_data.get('revenue_by_tier', pd.DataFrame())
    
    if not tier_data.empty and not revenue_data.empty:
        col1, col2 = st.columns(2)
        
        with col1:
            # Customer tier distribution
            fig_tier = px.pie(
                tier_data, 
                values='COUNT', 
                names='CUSTOMER_TIER',
                title="Customer Distribution by Tier",
                color_discrete_map={
                    'platinum': '#FFD700',
                    'gold': '#FFA500', 
                    'silver': '#C0C0C0',
                    'bronze': '#CD7F32'
                }
            )
            fig_tier.update_traces(textposition='inside', textinfo='percent+label')
            st.plotly_chart(fig_tier, use_container_width=True)
        
        with col2:
            # Revenue by tier
            fig_revenue = px.bar(
                revenue_data,
                x='CUSTOMER_TIER',
                y='TOTAL_REVENUE',
                title="Revenue by Customer Tier",
                color='CUSTOMER_TIER',
                color_discrete_map={
                    'platinum': '#FFD700',
                    'gold': '#FFA500',
                    'silver': '#C0C0C0', 
                    'bronze': '#CD7F32'
                }
            )
            fig_revenue.update_layout(
                xaxis_title="Customer Tier",
                yaxis_title="Total Revenue ($)"
            )
            st.plotly_chart(fig_revenue, use_container_width=True)
    
    # Customer value analysis
    if not revenue_data.empty:
        st.subheader("💎 Customer Value Analysis")
        
        # Calculate key metrics
        col1, col2, col3, col4 = st.columns(4)
        
        total_customers = revenue_data['CUSTOMER_COUNT'].sum()
        total_revenue = revenue_data['TOTAL_REVENUE'].sum()
        avg_customer_value = total_revenue / total_customers if total_customers > 0 else 0
        
        # Find highest value tier
        top_tier = revenue_data.loc[revenue_data['TOTAL_REVENUE'].idxmax(), 'CUSTOMER_TIER']
        
        with col1:
            st.metric("Total Customers", f"{total_customers:,}")
        
        with col2:
            st.metric("Total Revenue", f"${total_revenue:,.0f}")
        
        with col3:
            st.metric("Avg Customer Value", f"${avg_customer_value:,.0f}")
        
        with col4:
            st.metric("Top Revenue Tier", top_tier.title())
        
        # Customer value distribution
        fig_value = px.scatter(
            revenue_data,
            x='CUSTOMER_COUNT',
            y='AVG_REVENUE_PER_CUSTOMER',
            size='TOTAL_REVENUE',
            color='CUSTOMER_TIER',
            title="Customer Count vs Average Revenue per Customer",
            labels={
                'CUSTOMER_COUNT': 'Number of Customers',
                'AVG_REVENUE_PER_CUSTOMER': 'Average Revenue per Customer ($)'
            },
            color_discrete_map={
                'platinum': '#FFD700',
                'gold': '#FFA500',
                'silver': '#C0C0C0',
                'bronze': '#CD7F32'
            }
        )
        st.plotly_chart(fig_value, use_container_width=True)
    
    # Customer lifecycle analysis
    customers_df = st.session_state.data_helpers.get_customers()
    if not customers_df.empty:
        st.subheader("🔄 Customer Lifecycle Analysis")
        
        # Calculate customer tenure
        customers_df['JOIN_DATE'] = pd.to_datetime(customers_df['JOIN_DATE'])
        customers_df['TENURE_DAYS'] = (pd.Timestamp.now() - customers_df['JOIN_DATE']).dt.days
        customers_df['TENURE_CATEGORY'] = pd.cut(
            customers_df['TENURE_DAYS'],
            bins=[0, 90, 365, 730, float('inf')],
            labels=['New (0-3 months)', 'Growing (3-12 months)', 'Mature (1-2 years)', 'Veteran (2+ years)']
        )
        
        tenure_analysis = customers_df.groupby('TENURE_CATEGORY').agg({
            'CUSTOMER_ID': 'count',
            'TOTAL_SPENT': 'mean',
            'SATISFACTION_SCORE': 'mean',
            'CHURN_RISK_SCORE': 'mean'
        }).reset_index()
        tenure_analysis.columns = ['Tenure Category', 'Customer Count', 'Avg Spend', 'Avg Satisfaction', 'Avg Churn Risk']
        
        col1, col2 = st.columns(2)
        
        with col1:
            fig_tenure = px.bar(
                tenure_analysis,
                x='Tenure Category',
                y='Customer Count',
                title="Customer Distribution by Tenure"
            )
            st.plotly_chart(fig_tenure, use_container_width=True)
        
        with col2:
            fig_spend_tenure = px.bar(
                tenure_analysis,
                x='Tenure Category',
                y='Avg Spend',
                title="Average Spend by Customer Tenure"
            )
            st.plotly_chart(fig_spend_tenure, use_container_width=True)

def render_revenue_analytics(analytics_data):
    """Render revenue analytics and insights"""
    
    st.subheader("💰 Revenue Analytics")
    
    revenue_data = analytics_data.get('revenue_by_tier', pd.DataFrame())
    customers_df = st.session_state.data_helpers.get_customers()
    
    if not revenue_data.empty:
        # Revenue metrics
        col1, col2, col3, col4 = st.columns(4)
        
        total_revenue = revenue_data['TOTAL_REVENUE'].sum()
        total_customers = revenue_data['CUSTOMER_COUNT'].sum()
        arpu = total_revenue / total_customers if total_customers > 0 else 0
        
        # Calculate revenue concentration
        top_tier_revenue = revenue_data['TOTAL_REVENUE'].max()
        revenue_concentration = (top_tier_revenue / total_revenue * 100) if total_revenue > 0 else 0
        
        with col1:
            st.metric("Total Revenue", f"${total_revenue:,.0f}")
        
        with col2:
            st.metric("Total Customers", f"{total_customers:,}")
        
        with col3:
            st.metric("ARPU", f"${arpu:,.0f}")
        
        with col4:
            st.metric("Revenue Concentration", f"{revenue_concentration:.1f}%")
        
        # Revenue breakdown analysis
        col1, col2 = st.columns(2)
        
        with col1:
            # Revenue composition
            fig_composition = px.sunburst(
                revenue_data,
                path=['CUSTOMER_TIER'],
                values='TOTAL_REVENUE',
                title="Revenue Composition by Tier"
            )
            st.plotly_chart(fig_composition, use_container_width=True)
        
        with col2:
            # Revenue efficiency (Revenue per customer by tier)
            fig_efficiency = px.bar(
                revenue_data,
                x='CUSTOMER_TIER',
                y='AVG_REVENUE_PER_CUSTOMER',
                title="Revenue per Customer by Tier",
                color='CUSTOMER_TIER',
                color_discrete_map={
                    'platinum': '#FFD700',
                    'gold': '#FFA500',
                    'silver': '#C0C0C0',
                    'bronze': '#CD7F32'
                }
            )
            st.plotly_chart(fig_efficiency, use_container_width=True)
    
    # Customer value distribution
    if not customers_df.empty:
        st.subheader("📊 Customer Value Distribution")
        
        # Pareto analysis (80/20 rule)
        customers_sorted = customers_df.sort_values('TOTAL_SPENT', ascending=False).reset_index(drop=True)
        customers_sorted['CUMULATIVE_REVENUE'] = customers_sorted['TOTAL_SPENT'].cumsum()
        customers_sorted['CUMULATIVE_PERCENTAGE'] = (customers_sorted['CUMULATIVE_REVENUE'] / customers_sorted['TOTAL_SPENT'].sum()) * 100
        customers_sorted['CUSTOMER_PERCENTAGE'] = ((customers_sorted.index + 1) / len(customers_sorted)) * 100
        
        # Find where 80% of revenue comes from
        pareto_point = customers_sorted[customers_sorted['CUMULATIVE_PERCENTAGE'] >= 80].iloc[0]
        pareto_customers = pareto_point['CUSTOMER_PERCENTAGE']
        
        col1, col2 = st.columns([2, 1])
        
        with col1:
            fig_pareto = go.Figure()
            
            fig_pareto.add_trace(go.Scatter(
                x=customers_sorted['CUSTOMER_PERCENTAGE'],
                y=customers_sorted['CUMULATIVE_PERCENTAGE'],
                mode='lines',
                name='Cumulative Revenue %',
                line=dict(color='blue', width=3)
            ))
            
            # Add 80/20 reference lines
            fig_pareto.add_hline(y=80, line_dash="dash", line_color="red", 
                                annotation_text="80% Revenue")
            fig_pareto.add_vline(x=pareto_customers, line_dash="dash", line_color="red",
                                annotation_text=f"{pareto_customers:.1f}% Customers")
            
            fig_pareto.update_layout(
                title="Customer Revenue Pareto Analysis",
                xaxis_title="Percentage of Customers",
                yaxis_title="Cumulative Revenue Percentage",
                showlegend=False
            )
            
            st.plotly_chart(fig_pareto, use_container_width=True)
        
        with col2:
            st.markdown("### 📈 Pareto Insights")
            st.metric("Top Customers Drive", f"{pareto_customers:.1f}%", "of total revenue")
            st.metric("Revenue Concentration", "80%", f"from {pareto_customers:.1f}% customers")
            
            # Top customer insights
            top_5_revenue = customers_sorted.head(5)['TOTAL_SPENT'].sum()
            top_5_percentage = (top_5_revenue / customers_sorted['TOTAL_SPENT'].sum()) * 100
            
            st.metric("Top 5 Customers", f"{top_5_percentage:.1f}%", "of total revenue")
        
        # Customer value segmentation
        st.subheader("🎯 Customer Value Segmentation")
        
        # Create value segments based on spending
        spending_quartiles = customers_df['TOTAL_SPENT'].quantile([0.25, 0.5, 0.75]).values
        
        def categorize_value(spend):
            if spend >= spending_quartiles[2]:  # Top 25%
                return 'High Value'
            elif spend >= spending_quartiles[1]:  # 50-75%
                return 'Medium Value'
            elif spend >= spending_quartiles[0]:  # 25-50%
                return 'Low Value'
            else:  # Bottom 25%
                return 'Entry Level'
        
        customers_df['VALUE_SEGMENT'] = customers_df['TOTAL_SPENT'].apply(categorize_value)
        
        # Segment analysis
        segment_analysis = customers_df.groupby('VALUE_SEGMENT').agg({
            'CUSTOMER_ID': 'count',
            'TOTAL_SPENT': ['sum', 'mean'],
            'CHURN_RISK_SCORE': 'mean',
            'SATISFACTION_SCORE': 'mean'
        }).round(2)
        
        segment_analysis.columns = ['Count', 'Total Revenue', 'Avg Revenue', 'Avg Churn Risk', 'Avg Satisfaction']
        segment_analysis = segment_analysis.reset_index()
        
        st.dataframe(segment_analysis, use_container_width=True)

def render_risk_assessment(analytics_data):
    """Render churn risk assessment and analysis"""
    
    st.subheader("⚠️ Churn Risk Assessment")
    
    customers_df = st.session_state.data_helpers.get_customers()
    risk_data = analytics_data.get('risk_distribution', pd.DataFrame())
    
    if not customers_df.empty:
        # Risk overview metrics
        col1, col2, col3, col4 = st.columns(4)
        
        high_risk = len(customers_df[customers_df['CHURN_RISK_SCORE'] > 0.7])
        medium_risk = len(customers_df[(customers_df['CHURN_RISK_SCORE'] > 0.3) & (customers_df['CHURN_RISK_SCORE'] <= 0.7)])
        low_risk = len(customers_df[customers_df['CHURN_RISK_SCORE'] <= 0.3])
        avg_risk = customers_df['CHURN_RISK_SCORE'].mean()
        
        with col1:
            st.metric("High Risk", high_risk, delta="Immediate attention")
        
        with col2:
            st.metric("Medium Risk", medium_risk, delta="Monitor closely")
        
        with col3:
            st.metric("Low Risk", low_risk, delta="Stable customers")
        
        with col4:
            st.metric("Average Risk", f"{avg_risk:.2%}", delta=f"{'Above' if avg_risk > 0.5 else 'Below'} 50%")
        
        # Risk distribution visualization
        if not risk_data.empty:
            col1, col2 = st.columns(2)
            
            with col1:
                fig_risk_dist = px.pie(
                    risk_data,
                    values='COUNT',
                    names='RISK_CATEGORY',
                    title="Customer Risk Distribution",
                    color_discrete_map={
                        'Low Risk': '#00ff00',
                        'Medium Risk': '#ffff00',
                        'High Risk': '#ff0000'
                    }
                )
                st.plotly_chart(fig_risk_dist, use_container_width=True)
            
            with col2:
                # Risk vs Value analysis
                fig_risk_value = px.scatter(
                    customers_df,
                    x='TOTAL_SPENT',
                    y='CHURN_RISK_SCORE',
                    color='CUSTOMER_TIER',
                    size='LIFETIME_VALUE',
                    title="Customer Value vs Churn Risk",
                    labels={
                        'TOTAL_SPENT': 'Total Spent ($)',
                        'CHURN_RISK_SCORE': 'Churn Risk Score'
                    },
                    color_discrete_map={
                        'platinum': '#FFD700',
                        'gold': '#FFA500',
                        'silver': '#C0C0C0',
                        'bronze': '#CD7F32'
                    }
                )
                st.plotly_chart(fig_risk_value, use_container_width=True)
        
        # High-risk customer analysis
        st.subheader("🚨 High-Risk Customer Analysis")
        
        high_risk_customers = customers_df[customers_df['CHURN_RISK_SCORE'] > 0.7].copy()
        
        if not high_risk_customers.empty:
            # Calculate potential revenue at risk
            revenue_at_risk = high_risk_customers['LIFETIME_VALUE'].sum()
            high_value_at_risk = len(high_risk_customers[high_risk_customers['CUSTOMER_TIER'].isin(['gold', 'platinum'])])
            
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.metric("Customers at Risk", len(high_risk_customers))
            
            with col2:
                st.metric("Revenue at Risk", f"${revenue_at_risk:,.0f}")
            
            with col3:
                st.metric("High-Value at Risk", high_value_at_risk)
            
            # High-risk customer details
            st.markdown("#### 🔍 High-Risk Customer Details")
            risk_display = high_risk_customers[[
                'FIRST_NAME', 'LAST_NAME', 'CUSTOMER_TIER', 'TOTAL_SPENT', 
                'CHURN_RISK_SCORE', 'SATISFACTION_SCORE'
            ]].copy()
            
            risk_display['CHURN_RISK_SCORE'] = risk_display['CHURN_RISK_SCORE'].apply(lambda x: f"{x:.1%}")
            risk_display['TOTAL_SPENT'] = risk_display['TOTAL_SPENT'].apply(lambda x: f"${x:,.2f}")
            
            st.dataframe(risk_display, use_container_width=True)
            
            # Risk factors analysis
            st.markdown("#### 📊 Risk Factor Analysis")
            
            # Analyze patterns in high-risk customers
            risk_by_tier = high_risk_customers['CUSTOMER_TIER'].value_counts()
            satisfaction_avg = high_risk_customers['SATISFACTION_SCORE'].mean()
            
            col1, col2 = st.columns(2)
            
            with col1:
                if len(risk_by_tier) > 0:
                    fig_risk_tier = px.bar(
                        x=risk_by_tier.index,
                        y=risk_by_tier.values,
                        title="High-Risk Customers by Tier",
                        labels={'x': 'Customer Tier', 'y': 'Count'}
                    )
                    st.plotly_chart(fig_risk_tier, use_container_width=True)
            
            with col2:
                st.markdown("**Risk Insights:**")
                st.write(f"• Average satisfaction: {satisfaction_avg:.1f}/5.0")
                st.write(f"• Most at-risk tier: {risk_by_tier.index[0] if len(risk_by_tier) > 0 else 'N/A'}")
                st.write(f"• Potential monthly loss: ${revenue_at_risk/12:,.0f}")
        else:
            st.success("🎉 No high-risk customers identified!")
        
        # Preventive recommendations
        st.subheader("💡 Risk Mitigation Recommendations")
        
        recommendations = []
        
        if high_risk > 0:
            recommendations.append(f"🚨 **Immediate Action**: {high_risk} customers need urgent outreach")
        
        if medium_risk > 5:
            recommendations.append(f"📞 **Proactive Engagement**: Monitor {medium_risk} medium-risk customers")
        
        if avg_risk > 0.4:
            recommendations.append("📈 **Strategy Review**: Overall risk level is elevated")
        
        recommendations.extend([
            "💬 **Enhanced Support**: Improve satisfaction scores for at-risk segments",
            "🎁 **Retention Offers**: Deploy targeted retention campaigns",
            "📊 **Regular Monitoring**: Weekly risk assessment reviews"
        ])
        
        for rec in recommendations:
            st.markdown(rec)

def render_support_metrics(analytics_data):
    """Render support metrics and analysis"""
    
    st.subheader("🎫 Support Metrics & Analysis")
    
    support_data = analytics_data.get('support_metrics', pd.DataFrame())
    
    if not support_data.empty:
        # Support overview metrics
        col1, col2, col3, col4 = st.columns(4)
        
        total_tickets = support_data['TICKET_COUNT'].sum()
        avg_resolution = support_data['AVG_RESOLUTION_TIME'].mean()
        avg_satisfaction = support_data['AVG_SATISFACTION'].mean()
        top_category = support_data.loc[support_data['TICKET_COUNT'].idxmax(), 'CATEGORY']
        
        with col1:
            st.metric("Total Tickets (30d)", f"{total_tickets:,}")
        
        with col2:
            st.metric("Avg Resolution Time", f"{avg_resolution:.1f} hours")
        
        with col3:
            st.metric("Avg Satisfaction", f"{avg_satisfaction:.1f}/5.0")
        
        with col4:
            st.metric("Top Issue Category", top_category.title())
        
        # Support visualizations
        col1, col2 = st.columns(2)
        
        with col1:
            # Ticket distribution by category
            fig_tickets = px.bar(
                support_data,
                x='CATEGORY',
                y='TICKET_COUNT',
                title="Support Tickets by Category",
                color='TICKET_COUNT',
                color_continuous_scale='Blues'
            )
            fig_tickets.update_layout(
                xaxis_title="Category",
                yaxis_title="Number of Tickets"
            )
            st.plotly_chart(fig_tickets, use_container_width=True)
        
        with col2:
            # Resolution time vs satisfaction
            fig_resolution = px.scatter(
                support_data,
                x='AVG_RESOLUTION_TIME',
                y='AVG_SATISFACTION',
                size='TICKET_COUNT',
                color='CATEGORY',
                title="Resolution Time vs Customer Satisfaction",
                labels={
                    'AVG_RESOLUTION_TIME': 'Average Resolution Time (hours)',
                    'AVG_SATISFACTION': 'Average Satisfaction Score'
                }
            )
            st.plotly_chart(fig_resolution, use_container_width=True)
        
        # Support efficiency analysis
        st.subheader("📈 Support Efficiency Analysis")
        
        # Calculate efficiency metrics
        support_data['EFFICIENCY_SCORE'] = (support_data['AVG_SATISFACTION'] * 5) / (support_data['AVG_RESOLUTION_TIME'] / 24)  # Satisfaction per day
        
        col1, col2 = st.columns(2)
        
        with col1:
            # Efficiency by category
            fig_efficiency = px.bar(
                support_data,
                x='CATEGORY',
                y='EFFICIENCY_SCORE',
                title="Support Efficiency by Category",
                color='EFFICIENCY_SCORE',
                color_continuous_scale='Greens'
            )
            st.plotly_chart(fig_efficiency, use_container_width=True)
        
        with col2:
            # Support performance matrix
            st.markdown("#### 🎯 Performance Matrix")
            
            performance_data = support_data.copy()
            performance_data['PERFORMANCE'] = performance_data.apply(
                lambda row: 'Excellent' if row['AVG_SATISFACTION'] >= 4.5 and row['AVG_RESOLUTION_TIME'] <= 24
                else 'Good' if row['AVG_SATISFACTION'] >= 4.0 and row['AVG_RESOLUTION_TIME'] <= 48
                else 'Needs Improvement', axis=1
            )
            
            performance_summary = performance_data['PERFORMANCE'].value_counts()
            
            for performance, count in performance_summary.items():
                color = '🟢' if performance == 'Excellent' else '🟡' if performance == 'Good' else '🔴'
                st.write(f"{color} **{performance}**: {count} categories")
    
    else:
        st.info("No support metrics data available.")
    
    # Support recommendations
    st.subheader("💡 Support Improvement Recommendations")
    
    recommendations = [
        "📞 **Response Time**: Target <24 hour resolution for all categories",
        "🎯 **Training Focus**: Address categories with low satisfaction scores",
        "🤖 **Automation**: Implement chatbots for common issues",
        "📊 **Monitoring**: Real-time dashboards for support teams",
        "💬 **Feedback Loop**: Regular satisfaction surveys post-resolution"
    ]
    
    for rec in recommendations:
        st.markdown(rec)

def render_trends_forecasting(analytics_data):
    """Render trend analysis and forecasting"""
    
    st.subheader("📈 Trends & Forecasting")
    
    activity_data = analytics_data.get('activity_trends', pd.DataFrame())
    customers_df = st.session_state.data_helpers.get_customers()
    
    # Activity trends
    if not activity_data.empty:
        st.subheader("🔄 Activity Trends")
        
        # Daily activity summary
        daily_summary = activity_data.groupby('ACTIVITY_DATE')['ACTIVITY_COUNT'].sum().reset_index()
        daily_summary['ACTIVITY_DATE'] = pd.to_datetime(daily_summary['ACTIVITY_DATE'])
        
        col1, col2 = st.columns(2)
        
        with col1:
            # Daily activity trend
            fig_daily = px.line(
                daily_summary,
                x='ACTIVITY_DATE',
                y='ACTIVITY_COUNT',
                title="Daily Activity Trends (Last 30 Days)",
                markers=True
            )
            fig_daily.update_layout(
                xaxis_title="Date",
                yaxis_title="Total Activities"
            )
            st.plotly_chart(fig_daily, use_container_width=True)
        
        with col2:
            # Activity by type over time
            pivot_data = activity_data.pivot_table(
                index='ACTIVITY_DATE',
                columns='ACTIVITY_TYPE',
                values='ACTIVITY_COUNT',
                fill_value=0
            ).reset_index()
            
            fig_types = px.area(
                pivot_data,
                x='ACTIVITY_DATE',
                y=pivot_data.columns[1:],
                title="Activity Types Over Time"
            )
            st.plotly_chart(fig_types, use_container_width=True)
    
    # Customer growth analysis
    if not customers_df.empty:
        st.subheader("📊 Customer Growth Analysis")
        
        customers_df['JOIN_DATE'] = pd.to_datetime(customers_df['JOIN_DATE'])
        
        # Monthly customer acquisition
        monthly_acquisitions = customers_df.groupby(
            customers_df['JOIN_DATE'].dt.to_period('M')
        ).size().reset_index(name='NEW_CUSTOMERS')
        monthly_acquisitions['JOIN_DATE'] = monthly_acquisitions['JOIN_DATE'].astype(str)
        
        # Calculate growth rate
        monthly_acquisitions['GROWTH_RATE'] = monthly_acquisitions['NEW_CUSTOMERS'].pct_change() * 100
        
        col1, col2 = st.columns(2)
        
        with col1:
            # Customer acquisition trend
            fig_acquisition = px.bar(
                monthly_acquisitions,
                x='JOIN_DATE',
                y='NEW_CUSTOMERS',
                title="Monthly Customer Acquisitions"
            )
            st.plotly_chart(fig_acquisition, use_container_width=True)
        
        with col2:
            # Growth rate trend
            fig_growth = px.line(
                monthly_acquisitions,
                x='JOIN_DATE',
                y='GROWTH_RATE',
                title="Customer Acquisition Growth Rate (%)",
                markers=True
            )
            fig_growth.add_hline(y=0, line_dash="dash", line_color="red")
            st.plotly_chart(fig_growth, use_container_width=True)
    
    # Predictive insights
    st.subheader("🔮 Predictive Insights")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("#### 📈 Forecasting Insights")
        
        if not customers_df.empty:
            # Simple trend analysis
            recent_customers = len(customers_df[customers_df['JOIN_DATE'] >= pd.Timestamp.now() - pd.Timedelta(days=30)])
            churn_risk_trend = customers_df['CHURN_RISK_SCORE'].mean()
            satisfaction_trend = customers_df['SATISFACTION_SCORE'].mean()
            
            insights = [
                f"📊 **Customer Acquisition**: {recent_customers} new customers in last 30 days",
                f"⚠️ **Risk Trend**: Average churn risk at {churn_risk_trend:.1%}",
                f"😊 **Satisfaction Trend**: Average satisfaction {satisfaction_trend:.1f}/5.0",
                f"💰 **Revenue Opportunity**: Focus on {len(customers_df[customers_df['CUSTOMER_TIER'] == 'bronze'])} bronze tier customers for upgrades"
            ]
            
            for insight in insights:
                st.markdown(insight)
    
    with col2:
        st.markdown("#### 🎯 Strategic Recommendations")
        
        recommendations = [
            "📈 **Growth Strategy**: Maintain current acquisition momentum",
            "🔍 **Risk Monitoring**: Weekly churn risk assessments",
            "📞 **Customer Success**: Proactive outreach programs",
            "💎 **Tier Progression**: Targeted upgrade campaigns",
            "📊 **Data-Driven**: Expand analytics capabilities"
        ]
        
        for rec in recommendations:
            st.markdown(rec)
    
    # Key performance indicators
    st.subheader("🎯 Key Performance Indicators")
    
    if not customers_df.empty:
        col1, col2, col3, col4, col5 = st.columns(5)
        
        # Calculate KPIs
        total_customers = len(customers_df)
        active_customers = len(customers_df[customers_df['ACCOUNT_STATUS'] == 'active'])
        high_satisfaction = len(customers_df[customers_df['SATISFACTION_SCORE'] >= 4.0])
        low_churn_risk = len(customers_df[customers_df['CHURN_RISK_SCORE'] <= 0.3])
        total_revenue = customers_df['TOTAL_SPENT'].sum()
        
        with col1:
            st.metric("Total Customers", f"{total_customers:,}")
        
        with col2:
            active_rate = (active_customers / total_customers * 100) if total_customers > 0 else 0
            st.metric("Active Rate", f"{active_rate:.1f}%")
        
        with col3:
            satisfaction_rate = (high_satisfaction / total_customers * 100) if total_customers > 0 else 0
            st.metric("High Satisfaction", f"{satisfaction_rate:.1f}%")
        
        with col4:
            retention_rate = (low_churn_risk / total_customers * 100) if total_customers > 0 else 0
            st.metric("Retention Rate", f"{retention_rate:.1f}%")
        
        with col5:
            st.metric("Total Revenue", f"${total_revenue:,.0f}") 