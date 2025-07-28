import streamlit as st
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

# Database connection for Streamlit in Snowflake
@st.cache_resource
def init_connection():
    conn = st.connection("snowflake")
    # Note: USE statements are not supported in Streamlit's Snowflake connection
    # We'll use fully qualified table names instead (DATABASE.SCHEMA.TABLE)
    return conn

# Helper functions
@st.cache_data
def run_query(query, params=None):
    conn = init_connection()
    if params:
        return conn.query(query, params=params)
    else:
        return conn.query(query)

@st.cache_data
def run_query_df(query, params=None):
    conn = init_connection()
    if params:
        return conn.query(query, params=params)
    else:
        return conn.query(query)

# Verify database setup
@st.cache_data
def verify_database_setup():
    """Verify that all required tables exist"""
    conn = init_connection()
    # Use fully qualified table names: DATABASE.SCHEMA.TABLE
    required_tables = [
        'RETAIL_WATCH_DB.PUBLIC.CUSTOMERS', 
        'RETAIL_WATCH_DB.PUBLIC.PRODUCTS', 
        'RETAIL_WATCH_DB.PUBLIC.ORDERS', 
        'RETAIL_WATCH_DB.PUBLIC.WATCH_BRANDS', 
        'RETAIL_WATCH_DB.PUBLIC.WATCH_CATEGORIES'
    ]
    
    try:
        # Check if tables exist
        for table in required_tables:
            table_name = table.split('.')[-1]  # Get just the table name for display
            result = conn.query("SELECT COUNT(*) as count FROM {} LIMIT 1".format(table))
            if result.empty:
                return False, f"Table {table_name} exists but is empty"
        
        return True, "All tables verified successfully"
    
    except Exception as e:
        error_msg = str(e)
        if "does not exist" in error_msg or "not authorized" in error_msg:
            return False, f"Database setup incomplete. Missing tables or access. Error: {error_msg}"
        else:
            return False, f"Database connection issue: {error_msg}"

# Initialize and verify database
def check_database_status():
    """Check database status and show setup instructions if needed"""
    is_valid, message = verify_database_setup()
    
    if not is_valid:
        st.error("🚨 Database Setup Required")
        st.error(message)
        
        with st.expander("📋 Setup Instructions"):
            st.markdown("""
            **To fix this error, run these SQL scripts in Snowflake:**
            
            1. **Database Setup**: `@sql/01_setup_database.sql`
            2. **Create Tables**: `@sql/02_create_tables.sql`  
            3. **Load Sample Data**: `@sql/03_sample_data.sql`
            4. **Create AI Functions**: `@sql/04_ai_functions.sql`
            
            **Or run the complete setup:**
            ```sql
            @sql/99_deploy_complete.sql
            ```
            
            **Verify your access:**
            ```sql
            USE DATABASE RETAIL_WATCH_DB;
            USE SCHEMA PUBLIC;
            USE WAREHOUSE RETAIL_WATCH_WH;
            SHOW TABLES;
            ```
            """)
        
        st.stop()  # Stop execution until database is set up
    
    else:
        st.success("✅ Database connection verified")
        return True

# Check database setup before proceeding
check_database_status()

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
            FROM RETAIL_WATCH_DB.PUBLIC.customers 
            ORDER BY customer_tier DESC, total_spent DESC
        """)
        
        customer_options = {}
        if not customers.empty:
            for _, customer in customers.iterrows():
                # Convert risk score to float for comparison
                try:
                    risk_score = float(customer['CHURN_RISK_SCORE']) if customer['CHURN_RISK_SCORE'] is not None else 0.0
                    risk_level = "🔴 HIGH" if risk_score > 0.7 else "🟡 MEDIUM" if risk_score > 0.4 else "🟢 LOW"
                except (ValueError, TypeError):
                    risk_level = "🟢 LOW"  # Default if conversion fails
                display_name = f"{customer['FIRST_NAME']} {customer['LAST_NAME']} ({customer['CUSTOMER_TIER']}) - Risk: {risk_level}"
                customer_options[display_name] = customer['CUSTOMER_ID']
        
        selected_customer_display = st.selectbox(
            "Select Customer:",
            options=list(customer_options.keys()) if customer_options else ["No customers available"],
            index=0 if customer_options else 0
        )
        
        if selected_customer_display and customer_options and selected_customer_display != "No customers available":
            st.session_state.current_customer = customer_options[selected_customer_display]
        else:
            st.session_state.current_customer = None
            if not customer_options:
                st.warning("⚠️ No customers found. Please check your database setup.")
        
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
        if st.button("🗑️ Clear All Cache"):
            st.cache_data.clear()
            st.cache_resource.clear()
            st.success("Cache cleared! Please refresh the page.")
        st.markdown("---")
    
    # Main content area
    if st.session_state.current_customer:
        display_customer_dashboard()
    else:
        st.info("Please select a customer from the sidebar to begin.")

def display_customer_dashboard():
    customer_id = st.session_state.current_customer
    
    # Get customer insights with error handling
    try:
        insights_query = f"SELECT get_customer_360_insights('{customer_id}', 'general') as insights"
        insights_result = run_query(insights_query)
        
        if not insights_result.empty:
            insights = json.loads(insights_result.iloc[0]['INSIGHTS'])
        else:
            insights = None
    except Exception as e:
        st.warning("⚠️ AI insights temporarily unavailable. Showing basic customer information.")
        st.error(f"Debug: {str(e)}")  # Add debug info
        insights = None
    
    # Fallback: Get basic customer info if AI function fails
    if insights is None:
        try:
            basic_customer_query = f"""
            SELECT customer_id, first_name, last_name, email, customer_tier, 
                   total_spent, total_orders, avg_order_value, churn_risk_score,
                   satisfaction_score, engagement_score, lifetime_value
            FROM RETAIL_WATCH_DB.PUBLIC.customers 
            WHERE customer_id = '{customer_id}'
            """
            basic_result = run_query(basic_customer_query)
            if not basic_result.empty:
                customer_data = basic_result.iloc[0]
                # Create a simplified insights structure
                insights = {
                    'customer_overview': {
                        'name': f"{customer_data['FIRST_NAME']} {customer_data['LAST_NAME']}",
                        'email': customer_data['EMAIL'],
                        'tier': customer_data['CUSTOMER_TIER'],
                        'lifetime_value': customer_data['LIFETIME_VALUE'],
                        'total_spent': customer_data['TOTAL_SPENT'],
                        'total_orders': customer_data['TOTAL_ORDERS'],
                        'avg_order_value': customer_data['AVG_ORDER_VALUE']
                    },
                    'risk_assessment': {
                        'churn_risk_score': customer_data['CHURN_RISK_SCORE'],
                        'risk_level': 'HIGH' if customer_data['CHURN_RISK_SCORE'] > 0.7 else 'MEDIUM' if customer_data['CHURN_RISK_SCORE'] > 0.4 else 'LOW',
                        'satisfaction_score': customer_data['SATISFACTION_SCORE'],
                        'engagement_score': customer_data['ENGAGEMENT_SCORE']
                    },
                    'ai_recommendations': {
                        'next_best_actions': ['Contact customer service', 'Review account status'],
                        'recommended_products_context': 'general'
                    }
                }
            else:
                st.error("Customer data not found.")
                return
        except Exception as e:
            st.error(f"Unable to load customer data: {str(e)}")
            return
    
    # Display customer overview (works with both AI and fallback data)
    if insights:
        # Customer overview section
        st.header("👤 Customer Overview")
        
        col1, col2, col3, col4 = st.columns(4)
        
        customer_overview = insights.get('customer_overview', {})
        risk_assessment = insights.get('risk_assessment', {})
        
        with col1:
            st.markdown(f"""
            <div class="metric-card">
                <h3>�� {customer_overview.get('tier', 'N/A')}</h3>
                <p><strong>{customer_overview.get('name', 'N/A')}</strong></p>
                <p>{customer_overview.get('email', 'N/A')}</p>
            </div>
            """, unsafe_allow_html=True)
        
        with col2:
            churn_risk_level = risk_assessment.get('risk_level', 'UNKNOWN')
            churn_risk_score = risk_assessment.get('churn_risk_score', 0)
            risk_class = f"{churn_risk_level.lower()}-risk"
            st.markdown(f"""
            <div class="metric-card">
                <h3 class="{risk_class}">⚠️ {churn_risk_level} RISK</h3>
                <p>Score: {churn_risk_score:.3f}</p>
                <p>Needs attention</p>
            </div>
            """, unsafe_allow_html=True)
        
        with col3:
            st.markdown(f"""
            <div class="metric-card">
                <h3>💰 ${customer_overview.get('lifetime_value', 0):,.0f}</h3>
                <p>Lifetime Value</p>
                <p>{customer_overview.get('total_orders', 0)} orders</p>
            </div>
            """, unsafe_allow_html=True)
        
        with col4:
            st.markdown(f"""
            <div class="metric-card">
                <h3>🛒 ${customer_overview.get('total_spent', 0):,.0f}</h3>
                <p>Total Spent</p>
                <p>Avg: ${customer_overview.get('avg_order_value', 0):,.0f}</p>
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
            display_sentiment_analysis()
        
        with tab5:
            display_customer_analytics(customer_id, insights)

def display_personal_recommendations(customer_id):
    st.header(f"🎯 Personal Recommendations - {st.session_state.shopping_context.title()} Context")
    
    # Get AI recommendations with error handling
    try:
        recommendations_query = f"SELECT get_personal_recommendations('{customer_id}', '{st.session_state.shopping_context}') as recommendations"
        rec_result = run_query(recommendations_query)
        
        if not rec_result.empty:
            recommendations = json.loads(rec_result.iloc[0]['RECOMMENDATIONS'])
        else:
            recommendations = None
    except Exception as e:
        st.warning("⚠️ AI recommendations temporarily unavailable. Showing popular products.")
        st.error(f"Debug: {str(e)}")  # Add debug info
        recommendations = None
    
    # Fallback: Show popular products if AI function fails
    if recommendations is None:
        try:
            popular_products_query = """
            SELECT p.product_id, p.product_name, b.brand_name, p.current_price, 
                   p.avg_rating, p.review_count, p.description, p.product_images
            FROM RETAIL_WATCH_DB.PUBLIC.products p
            JOIN RETAIL_WATCH_DB.PUBLIC.watch_brands b ON p.brand_id = b.brand_id
            WHERE p.product_status = 'active' AND p.stock_quantity > 0
            ORDER BY p.avg_rating DESC, p.review_count DESC
            LIMIT 5
            """
            popular_result = run_query(popular_products_query) 
            
            if not popular_result.empty:
                # Create simplified recommendations structure
                top_recs = []
                for _, product in popular_result.iterrows():
                    top_recs.append({
                        'product_id': product['PRODUCT_ID'],
                        'product_name': product['PRODUCT_NAME'],
                        'brand_name': product['BRAND_NAME'],
                        'price': product['CURRENT_PRICE'],
                        'rating': product['AVG_RATING'],
                        'review_count': product['REVIEW_COUNT'],
                        'description': product['DESCRIPTION'],
                        'images': product['PRODUCT_IMAGES'],
                        'match_reasons': ['Popular choice', 'Highly rated']
                    })
                
                recommendations = {
                    'customer_insights': {
                        'tier': 'N/A',
                        'preferred_brands': 'N/A',
                        'style_preferences': 'N/A'
                    },
                    'top_recommendations': top_recs
                }
            else:
                st.error("Unable to load product recommendations.")
                return
        except Exception as e:
            st.error(f"Unable to load recommendations: {str(e)}")
            return

    if recommendations:
        # Customer insights summary
        insights = recommendations['customer_insights']
        st.markdown(f"""
        <div class="customer-card">
            <h4>Customer Profile Summary</h4>
            <p><strong>Tier:</strong> {insights.get('tier', 'N/A')}</p>
            <p><strong>Preferred Brands:</strong> {insights.get('preferred_brands', 'None specified')}</p>
            <p><strong>Style Preferences:</strong> {insights.get('style_preferences', 'None specified')}</p>
        </div>
        """, unsafe_allow_html=True)
        
        # Display recommendations
        top_recs = recommendations['top_recommendations']
        
        for i, rec in enumerate(top_recs):
            col1, col2 = st.columns([1, 3])
            
            with col1:
                # Display product image from database
                try:
                    # Check if images exist and are in the right format
                    images = rec.get('images', [])
                    if images and isinstance(images, list) and len(images) > 0:
                        # Use the first image from the product images array
                        product_image_url = images[0]
                        st.image(product_image_url, width=200, caption=rec['product_name'])
                    else:
                        # Fallback to a generic watch placeholder
                        st.image("https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200&h=200&fit=crop", 
                                width=200, caption="Product Image")
                except Exception as e:
                    # If image fails to load, show fallback
                    st.image("https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200&h=200&fit=crop", 
                            width=200, caption="Product Image")
            
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
    
    # Get churn prediction with error handling
    try:
        churn_query = f"SELECT predict_customer_churn('{customer_id}') as churn_data"
        churn_result = run_query(churn_query)
        
        if not churn_result.empty:
            churn_data = json.loads(churn_result.iloc[0]['CHURN_DATA'])
            analysis = churn_data['churn_analysis']
        else:
            analysis = None
    except Exception as e:
        st.warning("⚠️ AI churn analysis temporarily unavailable. Showing basic risk assessment.")
        st.error(f"Debug: {str(e)}")  # Add debug info
        analysis = None
    
    # Fallback: Get basic churn info if AI function fails
    if analysis is None:
        try:
            basic_churn_query = f"""
            SELECT churn_risk_score, satisfaction_score, engagement_score, 
                   total_spent, total_orders, last_purchase_date
            FROM RETAIL_WATCH_DB.PUBLIC.customers 
            WHERE customer_id = '{customer_id}'
            """
            basic_result = run_query(basic_churn_query)
            if not basic_result.empty:
                customer_data = basic_result.iloc[0]
                analysis = {
                    'risk_score': customer_data['CHURN_RISK_SCORE'],
                    'risk_level': 'HIGH' if customer_data['CHURN_RISK_SCORE'] > 0.7 else 'MEDIUM' if customer_data['CHURN_RISK_SCORE'] > 0.4 else 'LOW',
                    'risk_factors': ['Basic assessment available'],
                    'retention_recommendations': ['Contact customer service', 'Review engagement strategy']
                }
            else:
                st.error("Customer churn data not found.")
                return
        except Exception as e:
            st.error(f"Unable to load churn analysis: {str(e)}")
            return
    
    if analysis:
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
        SELECT product_id, product_name, brand_name, current_price, stock_quantity, product_images
        FROM RETAIL_WATCH_DB.PUBLIC.products p
        JOIN RETAIL_WATCH_DB.PUBLIC.watch_brands b ON p.brand_id = b.brand_id
        WHERE p.product_status = 'active'
        ORDER BY p.current_price DESC
    """)
    
    product_options = {}
    if not products.empty:
        for _, product in products.iterrows():
            display_name = f"{product['PRODUCT_NAME']} ({product['BRAND_NAME']}) - ${product['CURRENT_PRICE']:,.0f}"
            product_options[display_name] = product['PRODUCT_ID']
    
    selected_product_display = st.selectbox(
        "Select Product for Analysis:",
        options=list(product_options.keys()) if product_options else ["No products available"]
    )
    
    if selected_product_display and product_options and selected_product_display != "No products available":
        selected_product_id = product_options[selected_product_display]
        st.session_state.shopping_context = 'price_optimization'
        
        # Get selected product details for display
        selected_product = products[products['PRODUCT_ID'] == selected_product_id].iloc[0]
        
        # Display product image and info
        col1, col2 = st.columns([1, 2])
        with col1:
            try:
                if selected_product['PRODUCT_IMAGES'] and len(selected_product['PRODUCT_IMAGES']) > 0:
                    product_image_url = selected_product['PRODUCT_IMAGES'][0]
                    st.image(product_image_url, width=200, caption=selected_product['PRODUCT_NAME'])
                else:
                    st.image("https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200&h=200&fit=crop", 
                            width=200, caption="Product Image")
            except Exception:
                st.image("https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200&h=200&fit=crop", 
                        width=200, caption="Product Image")
        
        with col2:
            st.subheader(f"{selected_product['PRODUCT_NAME']}")
            st.write(f"**Brand:** {selected_product['BRAND_NAME']}")
            st.write(f"**Current Price:** ${selected_product['CURRENT_PRICE']:,.2f}")
            st.write(f"**Stock:** {selected_product['STOCK_QUANTITY']} units")
        
        # Display price optimization
        st.subheader("📊 Price Analysis")
        optimization_result = run_query(
            f"SELECT optimize_product_pricing('{selected_product_id}') as result"
        )
        
        if not optimization_result.empty:
            result_raw = optimization_result.iloc[0]['RESULT']
            result = json.loads(result_raw) if isinstance(result_raw, str) else result_raw
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.metric("Current Price", f"${result.get('current_price', 0):,.0f}")
            with col2:
                st.metric("Recommended Price", f"${result.get('recommended_price', 0):,.0f}", 
                         delta=f"${result.get('recommended_price', 0) - result.get('current_price', 0):,.0f}")
            with col3:
                st.metric("Confidence Score", f"{result.get('confidence', 0):.1%}")
            
            # Price elasticity insights
            st.subheader("🎯 Insights")
            for insight in result.get('price_insights', []):
                st.info(f"💡 {insight}")

def display_sentiment_analysis():
    st.header("😊 Sentiment Analysis Dashboard")
    
    # Get recent reviews
    reviews = run_query("""
        SELECT pr.review_id, pr.product_id, p.product_name, b.brand_name, 
               pr.rating, pr.review_text, pr.review_date, p.product_images
        FROM RETAIL_WATCH_DB.PUBLIC.product_reviews pr
        JOIN RETAIL_WATCH_DB.PUBLIC.products p ON pr.product_id = p.product_id
        JOIN RETAIL_WATCH_DB.PUBLIC.watch_brands b ON p.brand_id = b.brand_id
        ORDER BY pr.review_date DESC
        LIMIT 50
    """)
    
    if not reviews.empty:
        # Review selection
        review_options = {}
        for _, review in reviews.iterrows():
            display_text = f"{review['PRODUCT_NAME']} ({review['BRAND_NAME']}) - {review['RATING']}⭐"
            review_options[display_text] = review['REVIEW_ID']
        
        selected_review_display = st.selectbox(
            "Select Review to Analyze:",
            options=list(review_options.keys())
        )
        
        if selected_review_display:
            selected_review_id = review_options[selected_review_display]
            selected_review = reviews[reviews['REVIEW_ID'] == selected_review_id].iloc[0]
            
            # Display product image and review info
            col1, col2 = st.columns([1, 3])
            with col1:
                try:
                    if selected_review['PRODUCT_IMAGES'] and len(selected_review['PRODUCT_IMAGES']) > 0:
                        product_image_url = selected_review['PRODUCT_IMAGES'][0]
                        st.image(product_image_url, width=150, caption=selected_review['PRODUCT_NAME'])
                    else:
                        st.image("https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=150&h=150&fit=crop", 
                                width=150, caption="Product Image")
                except Exception:
                    st.image("https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=150&h=150&fit=crop", 
                            width=150, caption="Product Image")
            
            with col2:
                st.subheader(f"{selected_review['PRODUCT_NAME']}")
                st.write(f"**Brand:** {selected_review['BRAND_NAME']}")
                st.write(f"**Rating:** {selected_review['RATING']}⭐")
                st.write(f"**Review Date:** {selected_review['REVIEW_DATE'].strftime('%Y-%m-%d')}")
            
            # Display review
            st.subheader("📝 Review Text")
            st.text_area("Review Content:", selected_review['REVIEW_TEXT'], height=100, disabled=True)
            
            # Sentiment analysis
            st.subheader("📊 Sentiment Analysis")
            sentiment_result = run_query(
                f"SELECT analyze_review_sentiment('{selected_review_id}') as result"
            )
            
            if not sentiment_result.empty:
                result_raw = sentiment_result.iloc[0]['RESULT']
                result = json.loads(result_raw) if isinstance(result_raw, str) else result_raw
                
                col1, col2, col3 = st.columns(3)
                with col1:
                    st.metric("Sentiment", result.get('sentiment_label', 'Unknown'))
                with col2:
                    st.metric("Confidence", f"{result.get('confidence', 0):.1%}")
                with col3:
                    st.metric("Score", f"{result.get('sentiment_score', 0):.2f}")
                
                # Key themes
                if 'key_themes' in result and result['key_themes']:
                    st.subheader("🏷️ Key Themes")
                    themes = [theme for theme in result['key_themes'] if theme and theme.lower() != 'undefined']
                    if themes:
                        cols = st.columns(min(len(themes), 4))
                        for i, theme in enumerate(themes):
                            with cols[i % len(cols)]:
                                st.badge(theme)
    else:
        st.info("No reviews available for analysis.")

def display_customer_analytics(customer_id, insights):
    st.header("📊 Customer Analytics")
    
    # Create visualizations
    col1, col2 = st.columns(2)
    
    with col1:
        # Customer journey timeline
        events_query = f"""
            SELECT event_type, COUNT(*) as count
            FROM RETAIL_WATCH_DB.PUBLIC.customer_events 
            WHERE customer_id = '{customer_id}'
            AND event_timestamp >= CURRENT_DATE - 30
            GROUP BY event_type
            ORDER BY count DESC
        """
        events_result = run_query(events_query)
        
        if not events_result.empty:
            df_events = pd.DataFrame(events_result, columns=['Event Type', 'Count'])
            fig = px.bar(df_events, x='Event Type', y='Count', 
                        title="Recent Activity (Last 30 Days)")
            st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Purchase history
        orders_query = f"""
            SELECT DATE_TRUNC('month', order_date) as month, SUM(total_amount) as revenue
            FROM RETAIL_WATCH_DB.PUBLIC.orders 
            WHERE customer_id = '{customer_id}'
            AND order_date >= CURRENT_DATE - 365
            GROUP BY month
            ORDER BY month
        """
        orders = run_query(orders_query)
        
        if not orders.empty:
            df_orders = pd.DataFrame(orders, columns=['Month', 'Revenue'])
            fig = px.line(df_orders, x='Month', y='Revenue', 
                         title="Monthly Purchase History")
            st.plotly_chart(fig, use_container_width=True)
    
    # Detailed metrics
    behavioral = insights.get('behavioral_insights', {})
    purchase = insights.get('purchase_insights', {})
    
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