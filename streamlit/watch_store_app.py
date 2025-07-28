import streamlit as st
import snowflake.connector
import pandas as pd
import json
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import uuid

# Set page config
st.set_page_config(
    page_title="🌟 Personal Watch Shopper - AI-Powered Watch Store",
    page_icon="⌚",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(90deg, #1e3c72 0%, #2a5298 100%);
        padding: 1rem;
        border-radius: 10px;
        color: white;
        text-align: center;
        margin-bottom: 2rem;
    }
    .customer-card {
        background: #f8f9fa;
        padding: 1rem;
        border-radius: 10px;
        border-left: 4px solid #007bff;
        margin-bottom: 1rem;
    }
    .metric-card {
        background: white;
        padding: 1rem;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        text-align: center;
    }
    .recommendation-card {
        background: white;
        border: 1px solid #ddd;
        border-radius: 10px;
        padding: 1rem;
        margin-bottom: 1rem;
        transition: transform 0.2s;
    }
    .recommendation-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
    .high-risk {
        color: #dc3545;
        font-weight: bold;
    }
    .medium-risk {
        color: #fd7e14;
        font-weight: bold;
    }
    .low-risk {
        color: #28a745;
        font-weight: bold;
    }
</style>
""", unsafe_allow_html=True)

# Database connection
@st.cache_resource
def init_connection():
    return snowflake.connector.connect(**st.secrets["snowflake"])

# Helper functions
@st.cache_data
def run_query(query, params=None):
    conn = init_connection()
    cur = conn.cursor()
    if params:
        cur.execute(query, params)
    else:
        cur.execute(query)
    return cur.fetchall()

def get_column_names(query):
    conn = init_connection()
    cur = conn.cursor()
    cur.execute(query)
    return [desc[0] for desc in cur.description]

# Initialize session state
if 'current_customer' not in st.session_state:
    st.session_state.current_customer = None
if 'shopping_context' not in st.session_state:
    st.session_state.shopping_context = 'general'

# Main app
def main():
    # Header
    st.markdown("""
    <div class="main-header">
        <h1>🌟 Personal Watch Shopper</h1>
        <p>AI-Powered Watch Store with Churn Prediction, Sentiment Analysis & Price Optimization</p>
    </div>
    """, unsafe_allow_html=True)
    
    # Sidebar for customer selection and context
    with st.sidebar:
        st.header("👤 Customer Profile")
        
        # Customer selection
        customers = run_query("""
            SELECT customer_id, first_name, last_name, email, customer_tier, churn_risk_score
            FROM customers 
            ORDER BY customer_tier DESC, total_spent DESC
        """)
        
        customer_options = {}
        for customer in customers:
            risk_level = "🔴 HIGH" if customer[5] > 0.7 else "🟡 MEDIUM" if customer[5] > 0.4 else "🟢 LOW"
            display_name = f"{customer[1]} {customer[2]} ({customer[4]}) - Risk: {risk_level}"
            customer_options[display_name] = customer[0]
        
        selected_customer_display = st.selectbox(
            "Select Customer:",
            options=list(customer_options.keys()),
            index=0
        )
        
        if selected_customer_display:
            st.session_state.current_customer = customer_options[selected_customer_display]
        
        st.markdown("---")
        
        # Shopping context
        st.header("🎯 Shopping Context")
        context_options = {
            "General Browsing": "general",
            "Luxury Shopping": "luxury", 
            "Sport & Active": "sport",
            "Gift Shopping": "gift",
            "Budget Conscious": "budget"
        }
        
        selected_context = st.selectbox(
            "Shopping Intent:",
            options=list(context_options.keys()),
            index=0
        )
        st.session_state.shopping_context = context_options[selected_context]
        
        # Quick actions
        st.markdown("---")
        st.header("⚡ Quick Actions")
        if st.button("🔄 Refresh Recommendations"):
            st.cache_data.clear()
            st.rerun()
        
        if st.button("📧 Send Retention Email"):
            st.success("Retention email sent!")
        
        if st.button("💰 Apply Discount"):
            st.success("10% discount applied!")
    
    # Main content area
    if st.session_state.current_customer:
        display_customer_dashboard()
    else:
        st.info("Please select a customer from the sidebar to begin.")

def display_customer_dashboard():
    customer_id = st.session_state.current_customer
    
    # Get customer insights
    insights_query = f"SELECT get_customer_360_insights('{customer_id}') as insights"
    insights_result = run_query(insights_query)
    
    if insights_result:
        insights = json.loads(insights_result[0][0])
        
        # Customer overview section
        st.header("👤 Customer Overview")
        
        col1, col2, col3, col4 = st.columns(4)
        
        customer_overview = insights['customer_overview']
        behavioral_insights = insights['behavioral_insights']
        purchase_insights = insights['purchase_insights']
        
        with col1:
            st.markdown(f"""
            <div class="metric-card">
                <h3>💎 {customer_overview['tier']}</h3>
                <p><strong>{customer_overview['name']}</strong></p>
                <p>{customer_overview['email']}</p>
            </div>
            """, unsafe_allow_html=True)
        
        with col2:
            churn_risk = customer_overview['churn_risk']['level']
            risk_class = f"{churn_risk.lower()}-risk"
            st.markdown(f"""
            <div class="metric-card">
                <h3 class="{risk_class}">⚠️ {churn_risk} RISK</h3>
                <p>Score: {customer_overview['churn_risk']['score']:.3f}</p>
                <p>Needs attention</p>
            </div>
            """, unsafe_allow_html=True)
        
        with col3:
            st.markdown(f"""
            <div class="metric-card">
                <h3>💰 ${customer_overview['total_spent']:,.0f}</h3>
                <p>Total Spent</p>
                <p>LTV: ${customer_overview['lifetime_value']:,.0f}</p>
            </div>
            """, unsafe_allow_html=True)
        
        with col4:
            engagement = behavioral_insights['engagement_score']
            engagement_color = "#28a745" if engagement > 0.7 else "#fd7e14" if engagement > 0.4 else "#dc3545"
            st.markdown(f"""
            <div class="metric-card">
                <h3 style="color: {engagement_color}">📊 {engagement:.1%}</h3>
                <p>Engagement Score</p>
                <p>Satisfaction: {behavioral_insights['satisfaction_score']:.1f}/10</p>
            </div>
            """, unsafe_allow_html=True)
        
        # Detailed insights tabs
        tab1, tab2, tab3, tab4, tab5 = st.tabs([
            "🛍️ Personal Recommendations", 
            "📈 Churn Analysis", 
            "💰 Price Optimization",
            "📝 Sentiment Analysis", 
            "📊 Customer Analytics"
        ])
        
        with tab1:
            display_personal_recommendations(customer_id)
        
        with tab2:
            display_churn_analysis(customer_id)
        
        with tab3:
            display_price_optimization()
        
        with tab4:
            display_sentiment_analysis(customer_id)
        
        with tab5:
            display_customer_analytics(customer_id, insights)

def display_personal_recommendations(customer_id):
    st.header(f"🎯 Personal Recommendations - {st.session_state.shopping_context.title()} Context")
    
    # Get AI recommendations
    recommendations_query = f"SELECT get_personal_recommendations('{customer_id}', '{st.session_state.shopping_context}') as recommendations"
    rec_result = run_query(recommendations_query)
    
    if rec_result:
        recommendations = json.loads(rec_result[0][0])
        
        # Customer insights summary
        insights = recommendations['customer_insights']
        st.markdown(f"""
        <div class="customer-card">
            <h4>Customer Profile Summary</h4>
            <p><strong>Tier:</strong> {insights['tier']} | 
               <strong>Price Range:</strong> ${insights['price_range']['min']:,.0f} - ${insights['price_range']['max']:,.0f}</p>
            <p><strong>Preferred Brands:</strong> {insights.get('preferred_brands', 'None specified')}</p>
            <p><strong>Style Preferences:</strong> {insights.get('style_preferences', 'None specified')}</p>
        </div>
        """, unsafe_allow_html=True)
        
        # Display recommendations
        top_recs = recommendations['top_recommendations']
        
        for i, rec in enumerate(top_recs):
            col1, col2 = st.columns([1, 3])
            
            with col1:
                st.image("https://via.placeholder.com/200x200?text=Watch", width=200)
            
            with col2:
                match_reasons = [reason for reason in rec['match_reasons'] if reason]
                
                st.markdown(f"""
                <div class="recommendation-card">
                    <h3>{rec['product_name']}</h3>
                    <p><strong>{rec['brand_name']}</strong> | ${rec['price']:,.2f}</p>
                    <p>⭐ {rec['rating']:.1f}/5.0 ({rec['review_count']} reviews)</p>
                    <p><strong>Match Score:</strong> {rec['recommendation_score']}/100</p>
                    <p><strong>Why this matches:</strong></p>
                    <ul>
                        {' '.join([f'<li>{reason}</li>' for reason in match_reasons])}
                    </ul>
                </div>
                """, unsafe_allow_html=True)
                
                if st.button(f"Add to Cart - {rec['product_name']}", key=f"cart_{i}"):
                    st.success(f"Added {rec['product_name']} to cart!")

def display_churn_analysis(customer_id):
    st.header("⚠️ Churn Risk Analysis")
    
    # Get churn prediction
    churn_query = f"SELECT predict_customer_churn('{customer_id}') as churn_data"
    churn_result = run_query(churn_query)
    
    if churn_result:
        churn_data = json.loads(churn_result[0][0])
        analysis = churn_data['churn_analysis']
        
        col1, col2 = st.columns(2)
        
        with col1:
            # Risk level gauge
            risk_score = analysis['risk_score']
            fig = go.Figure(go.Indicator(
                mode = "gauge+number+delta",
                value = risk_score,
                domain = {'x': [0, 1], 'y': [0, 1]},
                title = {'text': "Churn Risk Score"},
                delta = {'reference': 0.5},
                gauge = {
                    'axis': {'range': [None, 1]},
                    'bar': {'color': "darkblue"},
                    'steps': [
                        {'range': [0, 0.2], 'color': "lightgreen"},
                        {'range': [0.2, 0.4], 'color': "yellow"},
                        {'range': [0.4, 0.7], 'color': "orange"},
                        {'range': [0.7, 1], 'color': "red"}
                    ],
                    'threshold': {
                        'line': {'color': "red", 'width': 4},
                        'thickness': 0.75,
                        'value': 0.7
                    }
                }
            ))
            fig.update_layout(height=300)
            st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            st.markdown(f"""
            <div class="customer-card">
                <h4>Risk Assessment</h4>
                <p><strong>Risk Level:</strong> <span class="{analysis['risk_level'].lower()}-risk">{analysis['risk_level']}</span></p>
                <p><strong>Risk Score:</strong> {risk_score:.3f}</p>
                
                <h5>Risk Factors:</h5>
                <ul>
                    {' '.join([f'<li>{factor}</li>' for factor in analysis['risk_factors'] if factor])}
                </ul>
            </div>
            """, unsafe_allow_html=True)
        
        # Retention recommendations
        st.subheader("💡 Retention Recommendations")
        recommendations = analysis['retention_recommendations']
        
        for rec in recommendations:
            if rec:
                if "URGENT" in rec:
                    st.error(f"🚨 {rec}")
                elif "VIP" in rec or "discount" in rec.lower():
                    st.warning(f"⭐ {rec}")
                else:
                    st.info(f"💡 {rec}")

def display_price_optimization():
    st.header("💰 Price Optimization Dashboard")
    
    # Get product list for selection
    products = run_query("""
        SELECT product_id, product_name, brand_name, current_price, stock_quantity
        FROM products p
        JOIN watch_brands b ON p.brand_id = b.brand_id
        WHERE p.product_status = 'active'
        ORDER BY p.current_price DESC
    """)
    
    product_options = {}
    for product in products:
        display_name = f"{product[1]} ({product[2]}) - ${product[3]:,.0f}"
        product_options[display_name] = product[0]
    
    selected_product_display = st.selectbox(
        "Select Product for Price Analysis:",
        options=list(product_options.keys())
    )
    
    if selected_product_display:
        product_id = product_options[selected_product_display]
        
        # Get price optimization
        price_query = f"SELECT optimize_product_pricing('{product_id}') as price_data"
        price_result = run_query(price_query)
        
        if price_result:
            price_data = json.loads(price_result[0][0])
            
            col1, col2 = st.columns(2)
            
            with col1:
                current_analysis = price_data['current_analysis']
                st.markdown(f"""
                <div class="customer-card">
                    <h4>Current Analysis</h4>
                    <p><strong>Current Price:</strong> ${current_analysis['current_price']:,.2f}</p>
                    <p><strong>Margin:</strong> {current_analysis['margin_percent']:.1f}%</p>
                    <p><strong>vs Category Avg:</strong> {current_analysis['vs_category_avg']:+.1f}%</p>
                    <p><strong>Demand:</strong> {current_analysis['demand_score']}</p>
                </div>
                """, unsafe_allow_html=True)
            
            with col2:
                st.markdown(f"""
                <div class="customer-card">
                    <h4>Optimization Strategy</h4>
                    <p><strong>Strategy:</strong> {price_data['optimization_strategy']}</p>
                    <p><strong>Recommended Price:</strong> ${price_data['recommended_price']:,.2f}</p>
                    <p><strong>Expected Impact:</strong> {price_data['expected_impact']['revenue_change_estimate']}</p>
                </div>
                """, unsafe_allow_html=True)
            
            # Price factors
            st.subheader("🔍 Price Factors")
            factors = price_data['price_factors']
            for factor in factors:
                if factor:
                    st.write(f"• {factor}")

def display_sentiment_analysis(customer_id):
    st.header("😊 Sentiment Analysis")
    
    # Get customer reviews
    reviews_query = f"""
        SELECT pr.review_text, pr.rating, pr.sentiment_score, pr.sentiment_label,
               pr.key_themes, p.product_name, pr.review_date
        FROM product_reviews pr
        JOIN products p ON pr.product_id = p.product_id
        WHERE pr.customer_id = '{customer_id}'
        ORDER BY pr.review_date DESC
    """
    reviews = run_query(reviews_query)
    
    if reviews:
        # Overall sentiment metrics
        col1, col2, col3 = st.columns(3)
        
        avg_sentiment = sum([review[2] for review in reviews if review[2]]) / len(reviews)
        avg_rating = sum([review[1] for review in reviews]) / len(reviews)
        
        with col1:
            sentiment_color = "#28a745" if avg_sentiment > 0.3 else "#fd7e14" if avg_sentiment > -0.3 else "#dc3545"
            st.markdown(f"""
            <div class="metric-card">
                <h3 style="color: {sentiment_color}">😊 {avg_sentiment:.2f}</h3>
                <p>Average Sentiment</p>
            </div>
            """, unsafe_allow_html=True)
        
        with col2:
            st.markdown(f"""
            <div class="metric-card">
                <h3>⭐ {avg_rating:.1f}</h3>
                <p>Average Rating</p>
            </div>
            """, unsafe_allow_html=True)
        
        with col3:
            st.markdown(f"""
            <div class="metric-card">
                <h3>📝 {len(reviews)}</h3>
                <p>Total Reviews</p>
            </div>
            """, unsafe_allow_html=True)
        
        # Individual reviews
        st.subheader("Recent Reviews")
        for review in reviews[:5]:  # Show last 5 reviews
            sentiment_emoji = "😊" if review[3] == "positive" else "😐" if review[3] == "neutral" else "😞"
            
            st.markdown(f"""
            <div class="recommendation-card">
                <h5>{review[5]} {sentiment_emoji}</h5>
                <p><strong>Rating:</strong> {'⭐' * int(review[1])}</p>
                <p><strong>Review:</strong> "{review[0]}"</p>
                <p><strong>Sentiment:</strong> {review[3].title()} ({review[2]:.2f})</p>
                <p><strong>Date:</strong> {review[6]}</p>
            </div>
            """, unsafe_allow_html=True)
    else:
        st.info("No reviews found for this customer.")
    
    # Sentiment analysis tool
    st.subheader("🔍 Analyze New Review")
    new_review = st.text_area("Enter review text to analyze:")
    
    if st.button("Analyze Sentiment") and new_review:
        sentiment_query = f"SELECT analyze_review_sentiment('{new_review}') as sentiment_data"
        sentiment_result = run_query(sentiment_query)
        
        if sentiment_result:
            sentiment_data = json.loads(sentiment_result[0][0])
            
            col1, col2 = st.columns(2)
            with col1:
                st.json(sentiment_data)
            with col2:
                score = sentiment_data['sentiment_score']
                label = sentiment_data['sentiment_label']
                color = "#28a745" if label == "positive" else "#fd7e14" if label == "neutral" else "#dc3545"
                
                st.markdown(f"""
                <div style="background: {color}; color: white; padding: 1rem; border-radius: 10px; text-align: center;">
                    <h3>{label.upper()}</h3>
                    <p>Score: {score:.2f}</p>
                </div>
                """, unsafe_allow_html=True)

def display_customer_analytics(customer_id, insights):
    st.header("📊 Customer Analytics")
    
    # Create visualizations
    col1, col2 = st.columns(2)
    
    with col1:
        # Customer journey timeline
        events_query = f"""
            SELECT event_type, COUNT(*) as count
            FROM customer_events 
            WHERE customer_id = '{customer_id}'
            AND event_timestamp >= CURRENT_DATE - 30
            GROUP BY event_type
            ORDER BY count DESC
        """
        events = run_query(events_query)
        
        if events:
            df_events = pd.DataFrame(events, columns=['Event Type', 'Count'])
            fig = px.bar(df_events, x='Event Type', y='Count', 
                        title="Recent Activity (Last 30 Days)")
            st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Purchase history
        orders_query = f"""
            SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as revenue
            FROM orders 
            WHERE customer_id = '{customer_id}'
            AND order_date >= CURRENT_DATE - 365
            GROUP BY month
            ORDER BY month
        """
        orders = run_query(orders_query)
        
        if orders:
            df_orders = pd.DataFrame(orders, columns=['Month', 'Revenue'])
            fig = px.line(df_orders, x='Month', y='Revenue', 
                         title="Monthly Purchase History")
            st.plotly_chart(fig, use_container_width=True)
    
    # Detailed metrics
    behavioral = insights['behavioral_insights']
    purchase = insights['purchase_insights']
    
    st.subheader("Detailed Metrics")
    
    metrics_data = {
        'Metric': [
            'Website Visits (30d)', 'Email Opens (30d)', 'Email Clicks (30d)',
            'Total Orders', 'Average Order Value', 'Days Since Last Purchase'
        ],
        'Value': [
            behavioral['website_visits_30d'],
            behavioral['email_engagement']['opens_30d'],
            behavioral['email_engagement']['clicks_30d'],
            purchase['total_orders'],
            f"${purchase['avg_order_value']:,.2f}",
            purchase['days_since_last_purchase']
        ]
    }
    
    df_metrics = pd.DataFrame(metrics_data)
    st.dataframe(df_metrics, use_container_width=True)

if __name__ == "__main__":
    main() 