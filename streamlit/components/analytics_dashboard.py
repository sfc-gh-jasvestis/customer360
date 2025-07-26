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

def render_analytics_dashboard():
    """Render the main analytics dashboard"""
    
    st.header("📊 Analytics Dashboard")
    st.markdown("Comprehensive insights into customer behavior, revenue trends, and business metrics.")
    
    # Get analytics data
    try:
        analytics_data = st.session_state.data_helpers.get_analytics_data()
    except Exception as e:
        st.error(f"Error loading analytics data: {str(e)}")
        return
    
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
            try:
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
            except Exception as e:
                st.info(f"Could not display tier distribution chart: {str(e)}")
        
        with col2:
            # Revenue by tier
            try:
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
            except Exception as e:
                st.info(f"Could not display revenue chart: {str(e)}")
    
    # Customer value analysis
    if not revenue_data.empty:
        st.subheader("💎 Customer Value Analysis")
        
        # Calculate key metrics
        col1, col2, col3, col4 = st.columns(4)
        
        try:
            total_customers = revenue_data['CUSTOMER_COUNT'].sum() if 'CUSTOMER_COUNT' in revenue_data.columns else 0
            total_revenue = revenue_data['TOTAL_REVENUE'].sum() if 'TOTAL_REVENUE' in revenue_data.columns else 0
            avg_customer_value = total_revenue / total_customers if total_customers > 0 else 0
            
            # Find highest value tier
            if 'TOTAL_REVENUE' in revenue_data.columns and not revenue_data.empty:
                top_tier_idx = revenue_data['TOTAL_REVENUE'].idxmax()
                top_tier = safe_get_str(revenue_data.loc[top_tier_idx, 'CUSTOMER_TIER'], 'Unknown').title()
            else:
                top_tier = "Unknown"
            
            with col1:
                st.metric("Total Customers", safe_format_number(total_customers))
            
            with col2:
                st.metric("Total Revenue", safe_format_currency(total_revenue))
            
            with col3:
                st.metric("Avg Customer Value", safe_format_currency(avg_customer_value))
            
            with col4:
                st.metric("Top Revenue Tier", top_tier)
            
            # Customer value distribution
            required_cols = ['CUSTOMER_COUNT', 'AVG_REVENUE_PER_CUSTOMER', 'TOTAL_REVENUE', 'CUSTOMER_TIER']
            if all(col in revenue_data.columns for col in required_cols):
                try:
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
                except Exception as e:
                    st.info(f"Could not display value distribution chart: {str(e)}")
        except Exception as e:
            st.error(f"Error calculating customer metrics: {str(e)}")
    
    # Customer lifecycle analysis
    try:
        customers_df = st.session_state.data_helpers.get_customers()
        if not customers_df.empty and 'JOIN_DATE' in customers_df.columns:
            st.subheader("🔄 Customer Lifecycle Analysis")
            
            # Calculate customer tenure
            customers_df['JOIN_DATE'] = pd.to_datetime(customers_df['JOIN_DATE'], errors='coerce')
            customers_df['TENURE_DAYS'] = (pd.Timestamp.now() - customers_df['JOIN_DATE']).dt.days
            customers_df['TENURE_CATEGORY'] = pd.cut(
                customers_df['TENURE_DAYS'],
                bins=[0, 90, 365, 730, float('inf')],
                labels=['New (0-3 months)', 'Growing (3-12 months)', 'Mature (1-2 years)', 'Veteran (2+ years)']
            )
            
            # Safe aggregation with error handling
            tenure_metrics = {
                'CUSTOMER_ID': 'count',
                'TOTAL_SPENT': 'mean',
            }
            
            if 'SATISFACTION_SCORE' in customers_df.columns:
                tenure_metrics['SATISFACTION_SCORE'] = 'mean'
            if 'CHURN_RISK_SCORE' in customers_df.columns:
                tenure_metrics['CHURN_RISK_SCORE'] = 'mean'
            
            tenure_analysis = customers_df.groupby('TENURE_CATEGORY').agg(tenure_metrics).reset_index()
            tenure_analysis.columns = ['Tenure Category', 'Customer Count', 'Avg Spend'] + \
                                    (['Avg Satisfaction', 'Avg Churn Risk'] if len(tenure_analysis.columns) > 3 else [])
            
            col1, col2 = st.columns(2)
            
            with col1:
                try:
                    fig_tenure = px.bar(
                        tenure_analysis,
                        x='Tenure Category',
                        y='Customer Count',
                        title="Customer Distribution by Tenure"
                    )
                    st.plotly_chart(fig_tenure, use_container_width=True)
                except Exception as e:
                    st.info(f"Could not display tenure chart: {str(e)}")
            
            with col2:
                try:
                    fig_spend_tenure = px.bar(
                        tenure_analysis,
                        x='Tenure Category',
                        y='Avg Spend',
                        title="Average Spend by Customer Tenure"
                    )
                    st.plotly_chart(fig_spend_tenure, use_container_width=True)
                except Exception as e:
                    st.info(f"Could not display spend tenure chart: {str(e)}")
    except Exception as e:
        st.info(f"Could not perform lifecycle analysis: {str(e)}")

def render_revenue_analytics(analytics_data):
    """Render revenue analytics and insights"""
    
    st.subheader("💰 Revenue Analytics")
    
    revenue_data = analytics_data.get('revenue_by_tier', pd.DataFrame())
    
    try:
        customers_df = st.session_state.data_helpers.get_customers()
    except Exception as e:
        customers_df = pd.DataFrame()
        st.info(f"Could not load customer data: {str(e)}")
    
    if not revenue_data.empty:
        # Revenue metrics
        col1, col2, col3, col4 = st.columns(4)
        
        try:
            total_revenue = revenue_data['TOTAL_REVENUE'].sum() if 'TOTAL_REVENUE' in revenue_data.columns else 0
            total_customers = revenue_data['CUSTOMER_COUNT'].sum() if 'CUSTOMER_COUNT' in revenue_data.columns else 0
            arpu = total_revenue / total_customers if total_customers > 0 else 0
            
            # Calculate revenue concentration
            top_tier_revenue = revenue_data['TOTAL_REVENUE'].max() if 'TOTAL_REVENUE' in revenue_data.columns else 0
            revenue_concentration = (top_tier_revenue / total_revenue * 100) if total_revenue > 0 else 0
            
            with col1:
                st.metric("Total Revenue", safe_format_currency(total_revenue))
            
            with col2:
                st.metric("Total Customers", safe_format_number(total_customers))
            
            with col3:
                st.metric("ARPU", safe_format_currency(arpu))
            
            with col4:
                st.metric("Revenue Concentration", safe_format_decimal(revenue_concentration, 1) + "%")
            
            # Revenue breakdown analysis
            col1, col2 = st.columns(2)
            
            with col1:
                # Revenue composition
                try:
                    fig_composition = px.sunburst(
                        revenue_data,
                        path=['CUSTOMER_TIER'],
                        values='TOTAL_REVENUE',
                        title="Revenue Composition by Tier"
                    )
                    st.plotly_chart(fig_composition, use_container_width=True)
                except Exception as e:
                    st.info(f"Could not display revenue composition: {str(e)}")
            
            with col2:
                # Revenue efficiency (Revenue per customer by tier)
                if 'AVG_REVENUE_PER_CUSTOMER' in revenue_data.columns:
                    try:
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
                    except Exception as e:
                        st.info(f"Could not display efficiency chart: {str(e)}")
        except Exception as e:
            st.error(f"Error calculating revenue metrics: {str(e)}")
    
    # Customer value distribution
    if not customers_df.empty:
        st.subheader("📊 Customer Value Distribution")
        
        try:
            # Pareto analysis (80/20 rule)
            if 'TOTAL_SPENT' in customers_df.columns:
                customers_sorted = customers_df.sort_values('TOTAL_SPENT', ascending=False).reset_index(drop=True)
                customers_sorted['CUMULATIVE_REVENUE'] = customers_sorted['TOTAL_SPENT'].cumsum()
                customers_sorted['CUMULATIVE_PERCENTAGE'] = (customers_sorted['CUMULATIVE_REVENUE'] / customers_sorted['TOTAL_SPENT'].sum()) * 100
                customers_sorted['CUSTOMER_PERCENTAGE'] = ((customers_sorted.index + 1) / len(customers_sorted)) * 100
                
                # Find where 80% of revenue comes from
                pareto_point = customers_sorted[customers_sorted['CUMULATIVE_PERCENTAGE'] >= 80]
                if not pareto_point.empty:
                    pareto_customers = pareto_point.iloc[0]['CUSTOMER_PERCENTAGE']
                    
                    col1, col2 = st.columns([2, 1])
                    
                    with col1:
                        try:
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
                        except Exception as e:
                            st.info(f"Could not display Pareto chart: {str(e)}")
                    
                    with col2:
                        st.markdown("### 📈 Pareto Insights")
                        st.metric("Top Customers Drive", safe_format_decimal(pareto_customers, 1) + "%", "of total revenue")
                        st.metric("Revenue Concentration", "80%", f"from {safe_format_decimal(pareto_customers, 1)}% customers")
                        
                        # Top customer insights
                        top_5_revenue = customers_sorted.head(5)['TOTAL_SPENT'].sum()
                        top_5_percentage = (top_5_revenue / customers_sorted['TOTAL_SPENT'].sum()) * 100
                        
                        st.metric("Top 5 Customers", safe_format_decimal(top_5_percentage, 1) + "%", "of total revenue")
        except Exception as e:
            st.info(f"Could not perform Pareto analysis: {str(e)}")
        
        # Customer value segmentation
        st.subheader("🎯 Customer Value Segmentation")
        
        try:
            if 'TOTAL_SPENT' in customers_df.columns:
                # Create value segments based on spending
                spending_quartiles = customers_df['TOTAL_SPENT'].quantile([0.25, 0.5, 0.75]).values
                
                def categorize_value(spend):
                    try:
                        if pd.isna(spend):
                            return 'Entry Level'
                        elif spend >= spending_quartiles[2]:  # Top 25%
                            return 'High Value'
                        elif spend >= spending_quartiles[1]:  # 50-75%
                            return 'Medium Value'
                        elif spend >= spending_quartiles[0]:  # 25-50%
                            return 'Low Value'
                        else:  # Bottom 25%
                            return 'Entry Level'
                    except:
                        return 'Entry Level'
                
                customers_df['VALUE_SEGMENT'] = customers_df['TOTAL_SPENT'].apply(categorize_value)
                
                # Segment analysis
                segment_metrics = {
                    'CUSTOMER_ID': 'count',
                    'TOTAL_SPENT': ['sum', 'mean']
                }
                
                if 'CHURN_RISK_SCORE' in customers_df.columns:
                    segment_metrics['CHURN_RISK_SCORE'] = 'mean'
                if 'SATISFACTION_SCORE' in customers_df.columns:
                    segment_metrics['SATISFACTION_SCORE'] = 'mean'
                
                segment_analysis = customers_df.groupby('VALUE_SEGMENT').agg(segment_metrics).round(2)
                
                # Flatten column names
                segment_analysis.columns = ['Count', 'Total Revenue', 'Avg Revenue'] + \
                                         (['Avg Churn Risk', 'Avg Satisfaction'] if len(segment_analysis.columns) > 3 else [])
                segment_analysis = segment_analysis.reset_index()
                
                # Format currency columns
                if 'Total Revenue' in segment_analysis.columns:
                    segment_analysis['Total Revenue'] = segment_analysis['Total Revenue'].apply(safe_format_currency)
                if 'Avg Revenue' in segment_analysis.columns:
                    segment_analysis['Avg Revenue'] = segment_analysis['Avg Revenue'].apply(safe_format_currency)
                
                st.dataframe(segment_analysis, use_container_width=True)
        except Exception as e:
            st.info(f"Could not perform value segmentation: {str(e)}")

def render_risk_assessment(analytics_data):
    """Render churn risk assessment and analysis"""
    
    st.subheader("⚠️ Churn Risk Assessment")
    
    try:
        customers_df = st.session_state.data_helpers.get_customers()
    except Exception as e:
        customers_df = pd.DataFrame()
        st.error(f"Could not load customer data: {str(e)}")
        return
    
    risk_data = analytics_data.get('risk_distribution', pd.DataFrame())
    
    if not customers_df.empty and 'CHURN_RISK_SCORE' in customers_df.columns:
        # Risk overview metrics
        col1, col2, col3, col4 = st.columns(4)
        
        try:
            # Clean and handle None values
            customers_df['CHURN_RISK_SCORE'] = pd.to_numeric(customers_df['CHURN_RISK_SCORE'], errors='coerce').fillna(0)
            
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
                st.metric("Average Risk", safe_format_percentage(avg_risk), delta=f"{'Above' if avg_risk > 0.5 else 'Below'} 50%")
            
            # Risk distribution visualization
            if not risk_data.empty:
                col1, col2 = st.columns(2)
                
                with col1:
                    try:
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
                    except Exception as e:
                        st.info(f"Could not display risk distribution: {str(e)}")
                
                with col2:
                    # Risk vs Value analysis
                    required_cols = ['TOTAL_SPENT', 'CHURN_RISK_SCORE', 'CUSTOMER_TIER', 'LIFETIME_VALUE']
                    if all(col in customers_df.columns for col in required_cols):
                        try:
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
                        except Exception as e:
                            st.info(f"Could not display risk vs value chart: {str(e)}")
            
            # High-risk customer analysis
            st.subheader("🚨 High-Risk Customer Analysis")
            
            high_risk_customers = customers_df[customers_df['CHURN_RISK_SCORE'] > 0.7].copy()
            
            if not high_risk_customers.empty:
                # Calculate potential revenue at risk
                revenue_at_risk = high_risk_customers['LIFETIME_VALUE'].sum() if 'LIFETIME_VALUE' in high_risk_customers.columns else 0
                high_value_at_risk = len(high_risk_customers[high_risk_customers['CUSTOMER_TIER'].isin(['gold', 'platinum'])]) if 'CUSTOMER_TIER' in high_risk_customers.columns else 0
                
                col1, col2, col3 = st.columns(3)
                
                with col1:
                    st.metric("Customers at Risk", len(high_risk_customers))
                
                with col2:
                    st.metric("Revenue at Risk", safe_format_currency(revenue_at_risk))
                
                with col3:
                    st.metric("High-Value at Risk", high_value_at_risk)
                
                # High-risk customer details
                st.markdown("#### 🔍 High-Risk Customer Details")
                
                display_cols = ['FIRST_NAME', 'LAST_NAME', 'CUSTOMER_TIER', 'TOTAL_SPENT', 'CHURN_RISK_SCORE', 'SATISFACTION_SCORE']
                available_cols = [col for col in display_cols if col in high_risk_customers.columns]
                
                if available_cols:
                    risk_display = high_risk_customers[available_cols].copy()
                    
                    # Safe formatting
                    if 'CHURN_RISK_SCORE' in risk_display.columns:
                        risk_display['CHURN_RISK_SCORE'] = risk_display['CHURN_RISK_SCORE'].apply(
                            lambda x: safe_format_percentage(x) if pd.notna(x) else "N/A"
                        )
                    if 'TOTAL_SPENT' in risk_display.columns:
                        risk_display['TOTAL_SPENT'] = risk_display['TOTAL_SPENT'].apply(
                            lambda x: safe_format_currency(x) if pd.notna(x) else "$0.00"
                        )
                    
                    st.dataframe(risk_display, use_container_width=True)
                
                # Risk factors analysis
                st.markdown("#### 📊 Risk Factor Analysis")
                
                # Analyze patterns in high-risk customers
                if 'CUSTOMER_TIER' in high_risk_customers.columns:
                    risk_by_tier = high_risk_customers['CUSTOMER_TIER'].value_counts()
                else:
                    risk_by_tier = pd.Series(dtype=int)
                
                satisfaction_avg = high_risk_customers['SATISFACTION_SCORE'].mean() if 'SATISFACTION_SCORE' in high_risk_customers.columns else 0
                
                col1, col2 = st.columns(2)
                
                with col1:
                    if len(risk_by_tier) > 0:
                        try:
                            fig_risk_tier = px.bar(
                                x=risk_by_tier.index,
                                y=risk_by_tier.values,
                                title="High-Risk Customers by Tier",
                                labels={'x': 'Customer Tier', 'y': 'Count'}
                            )
                            st.plotly_chart(fig_risk_tier, use_container_width=True)
                        except Exception as e:
                            st.info(f"Could not display risk by tier chart: {str(e)}")
                
                with col2:
                    st.markdown("**Risk Insights:**")
                    st.write(f"• Average satisfaction: {safe_format_decimal(satisfaction_avg)}/5.0")
                    st.write(f"• Most at-risk tier: {risk_by_tier.index[0] if len(risk_by_tier) > 0 else 'N/A'}")
                    st.write(f"• Potential monthly loss: {safe_format_currency(revenue_at_risk/12)}")
            else:
                st.success("🎉 No high-risk customers identified!")
        except Exception as e:
            st.error(f"Error in risk assessment: {str(e)}")
    else:
        st.info("No churn risk data available.")
    
    # Preventive recommendations
    st.subheader("💡 Risk Mitigation Recommendations")
    
    try:
        recommendations = []
        
        if not customers_df.empty and 'CHURN_RISK_SCORE' in customers_df.columns:
            customers_df['CHURN_RISK_SCORE'] = pd.to_numeric(customers_df['CHURN_RISK_SCORE'], errors='coerce').fillna(0)
            high_risk = len(customers_df[customers_df['CHURN_RISK_SCORE'] > 0.7])
            medium_risk = len(customers_df[(customers_df['CHURN_RISK_SCORE'] > 0.3) & (customers_df['CHURN_RISK_SCORE'] <= 0.7)])
            avg_risk = customers_df['CHURN_RISK_SCORE'].mean()
            
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
    except Exception as e:
        st.info(f"Could not generate recommendations: {str(e)}")

def render_support_metrics(analytics_data):
    """Render support metrics and analysis"""
    
    st.subheader("🎫 Support Metrics & Analysis")
    
    support_data = analytics_data.get('support_metrics', pd.DataFrame())
    
    if not support_data.empty:
        try:
            # Support overview metrics
            col1, col2, col3, col4 = st.columns(4)
            
            total_tickets = support_data['TICKET_COUNT'].sum() if 'TICKET_COUNT' in support_data.columns else 0
            avg_resolution = support_data['AVG_RESOLUTION_TIME'].mean() if 'AVG_RESOLUTION_TIME' in support_data.columns else 0
            avg_satisfaction = support_data['AVG_SATISFACTION'].mean() if 'AVG_SATISFACTION' in support_data.columns else 0
            
            if 'CATEGORY' in support_data.columns and not support_data.empty:
                top_category_idx = support_data['TICKET_COUNT'].idxmax() if 'TICKET_COUNT' in support_data.columns else 0
                top_category = safe_get_str(support_data.loc[top_category_idx, 'CATEGORY'], 'Unknown').title()
            else:
                top_category = "Unknown"
            
            with col1:
                st.metric("Total Tickets (30d)", safe_format_number(total_tickets))
            
            with col2:
                st.metric("Avg Resolution Time", safe_format_decimal(avg_resolution, 1) + " hours")
            
            with col3:
                st.metric("Avg Satisfaction", safe_format_decimal(avg_satisfaction, 1) + "/5.0")
            
            with col4:
                st.metric("Top Issue Category", top_category)
            
            # Support visualizations
            col1, col2 = st.columns(2)
            
            with col1:
                # Ticket distribution by category
                if 'CATEGORY' in support_data.columns and 'TICKET_COUNT' in support_data.columns:
                    try:
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
                    except Exception as e:
                        st.info(f"Could not display tickets chart: {str(e)}")
            
            with col2:
                # Resolution time vs satisfaction
                required_cols = ['AVG_RESOLUTION_TIME', 'AVG_SATISFACTION', 'TICKET_COUNT', 'CATEGORY']
                if all(col in support_data.columns for col in required_cols):
                    try:
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
                    except Exception as e:
                        st.info(f"Could not display resolution chart: {str(e)}")
            
            # Support efficiency analysis
            st.subheader("📈 Support Efficiency Analysis")
            
            # Calculate efficiency metrics
            if 'AVG_SATISFACTION' in support_data.columns and 'AVG_RESOLUTION_TIME' in support_data.columns:
                support_data['EFFICIENCY_SCORE'] = (support_data['AVG_SATISFACTION'] * 5) / (support_data['AVG_RESOLUTION_TIME'] / 24)  # Satisfaction per day
                
                col1, col2 = st.columns(2)
                
                with col1:
                    # Efficiency by category
                    try:
                        fig_efficiency = px.bar(
                            support_data,
                            x='CATEGORY',
                            y='EFFICIENCY_SCORE',
                            title="Support Efficiency by Category",
                            color='EFFICIENCY_SCORE',
                            color_continuous_scale='Greens'
                        )
                        st.plotly_chart(fig_efficiency, use_container_width=True)
                    except Exception as e:
                        st.info(f"Could not display efficiency chart: {str(e)}")
                
                with col2:
                    # Support performance matrix
                    st.markdown("#### 🎯 Performance Matrix")
                    
                    try:
                        performance_data = support_data.copy()
                        performance_data['PERFORMANCE'] = performance_data.apply(
                            lambda row: 'Excellent' if (pd.notna(row.get('AVG_SATISFACTION', 0)) and row.get('AVG_SATISFACTION', 0) >= 4.5 and 
                                                       pd.notna(row.get('AVG_RESOLUTION_TIME', 999)) and row.get('AVG_RESOLUTION_TIME', 999) <= 24)
                            else 'Good' if (pd.notna(row.get('AVG_SATISFACTION', 0)) and row.get('AVG_SATISFACTION', 0) >= 4.0 and 
                                          pd.notna(row.get('AVG_RESOLUTION_TIME', 999)) and row.get('AVG_RESOLUTION_TIME', 999) <= 48)
                            else 'Needs Improvement', axis=1
                        )
                        
                        performance_summary = performance_data['PERFORMANCE'].value_counts()
                        
                        for performance, count in performance_summary.items():
                            color = '🟢' if performance == 'Excellent' else '🟡' if performance == 'Good' else '🔴'
                            st.write(f"{color} **{performance}**: {count} categories")
                    except Exception as e:
                        st.info(f"Could not calculate performance matrix: {str(e)}")
        except Exception as e:
            st.error(f"Error in support metrics: {str(e)}")
    
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
    
    try:
        customers_df = st.session_state.data_helpers.get_customers()
    except Exception as e:
        customers_df = pd.DataFrame()
        st.info(f"Could not load customer data: {str(e)}")
    
    # Activity trends
    if not activity_data.empty:
        st.subheader("🔄 Activity Trends")
        
        try:
            # Daily activity summary
            if 'ACTIVITY_DATE' in activity_data.columns and 'ACTIVITY_COUNT' in activity_data.columns:
                daily_summary = activity_data.groupby('ACTIVITY_DATE')['ACTIVITY_COUNT'].sum().reset_index()
                daily_summary['ACTIVITY_DATE'] = pd.to_datetime(daily_summary['ACTIVITY_DATE'], errors='coerce')
                
                col1, col2 = st.columns(2)
                
                with col1:
                    # Daily activity trend
                    try:
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
                    except Exception as e:
                        st.info(f"Could not display daily trends: {str(e)}")
                
                with col2:
                    # Activity by type over time
                    try:
                        if 'ACTIVITY_TYPE' in activity_data.columns:
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
                    except Exception as e:
                        st.info(f"Could not display activity types chart: {str(e)}")
        except Exception as e:
            st.info(f"Could not analyze activity trends: {str(e)}")
    
    # Customer growth analysis
    if not customers_df.empty and 'JOIN_DATE' in customers_df.columns:
        st.subheader("📊 Customer Growth Analysis")
        
        try:
            customers_df['JOIN_DATE'] = pd.to_datetime(customers_df['JOIN_DATE'], errors='coerce')
            
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
                try:
                    fig_acquisition = px.bar(
                        monthly_acquisitions,
                        x='JOIN_DATE',
                        y='NEW_CUSTOMERS',
                        title="Monthly Customer Acquisitions"
                    )
                    st.plotly_chart(fig_acquisition, use_container_width=True)
                except Exception as e:
                    st.info(f"Could not display acquisition chart: {str(e)}")
            
            with col2:
                # Growth rate trend
                try:
                    fig_growth = px.line(
                        monthly_acquisitions,
                        x='JOIN_DATE',
                        y='GROWTH_RATE',
                        title="Customer Acquisition Growth Rate (%)",
                        markers=True
                    )
                    fig_growth.add_hline(y=0, line_dash="dash", line_color="red")
                    st.plotly_chart(fig_growth, use_container_width=True)
                except Exception as e:
                    st.info(f"Could not display growth chart: {str(e)}")
        except Exception as e:
            st.info(f"Could not analyze customer growth: {str(e)}")
    
    # Predictive insights
    st.subheader("🔮 Predictive Insights")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("#### 📈 Forecasting Insights")
        
        try:
            if not customers_df.empty:
                # Simple trend analysis
                recent_customers = 0
                churn_risk_trend = 0
                satisfaction_trend = 0
                bronze_customers = 0
                
                if 'JOIN_DATE' in customers_df.columns:
                    customers_df['JOIN_DATE'] = pd.to_datetime(customers_df['JOIN_DATE'], errors='coerce')
                    recent_customers = len(customers_df[customers_df['JOIN_DATE'] >= pd.Timestamp.now() - pd.Timedelta(days=30)])
                
                if 'CHURN_RISK_SCORE' in customers_df.columns:
                    churn_risk_trend = pd.to_numeric(customers_df['CHURN_RISK_SCORE'], errors='coerce').fillna(0).mean()
                
                if 'SATISFACTION_SCORE' in customers_df.columns:
                    satisfaction_trend = pd.to_numeric(customers_df['SATISFACTION_SCORE'], errors='coerce').fillna(0).mean()
                
                if 'CUSTOMER_TIER' in customers_df.columns:
                    bronze_customers = len(customers_df[customers_df['CUSTOMER_TIER'] == 'bronze'])
                
                insights = [
                    f"📊 **Customer Acquisition**: {recent_customers} new customers in last 30 days",
                    f"⚠️ **Risk Trend**: Average churn risk at {safe_format_percentage(churn_risk_trend)}",
                    f"😊 **Satisfaction Trend**: Average satisfaction {safe_format_decimal(satisfaction_trend)}/5.0",
                    f"💰 **Revenue Opportunity**: Focus on {bronze_customers} bronze tier customers for upgrades"
                ]
                
                for insight in insights:
                    st.markdown(insight)
        except Exception as e:
            st.info(f"Could not generate forecasting insights: {str(e)}")
    
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
        try:
            col1, col2, col3, col4, col5 = st.columns(5)
            
            # Calculate KPIs with safe defaults
            total_customers = len(customers_df)
            active_customers = len(customers_df[customers_df['ACCOUNT_STATUS'] == 'active']) if 'ACCOUNT_STATUS' in customers_df.columns else 0
            high_satisfaction = len(customers_df[pd.to_numeric(customers_df['SATISFACTION_SCORE'], errors='coerce').fillna(0) >= 4.0]) if 'SATISFACTION_SCORE' in customers_df.columns else 0
            low_churn_risk = len(customers_df[pd.to_numeric(customers_df['CHURN_RISK_SCORE'], errors='coerce').fillna(0) <= 0.3]) if 'CHURN_RISK_SCORE' in customers_df.columns else 0
            total_revenue = pd.to_numeric(customers_df['TOTAL_SPENT'], errors='coerce').fillna(0).sum() if 'TOTAL_SPENT' in customers_df.columns else 0
            
            with col1:
                st.metric("Total Customers", safe_format_number(total_customers))
            
            with col2:
                active_rate = (active_customers / total_customers * 100) if total_customers > 0 else 0
                st.metric("Active Rate", safe_format_decimal(active_rate, 1) + "%")
            
            with col3:
                satisfaction_rate = (high_satisfaction / total_customers * 100) if total_customers > 0 else 0
                st.metric("High Satisfaction", safe_format_decimal(satisfaction_rate, 1) + "%")
            
            with col4:
                retention_rate = (low_churn_risk / total_customers * 100) if total_customers > 0 else 0
                st.metric("Retention Rate", safe_format_decimal(retention_rate, 1) + "%")
            
            with col5:
                st.metric("Total Revenue", safe_format_currency(total_revenue))
        except Exception as e:
            st.error(f"Error calculating KPIs: {str(e)}") 