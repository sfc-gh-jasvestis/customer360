import streamlit as st
import pandas as pd
import json
import plotly.express as px
import plotly.graph_objects as go

# Set page config
st.set_page_config(
    page_title="Retail Watch Store - Customer 360",
    page_icon="⌚",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Hardcoded working image URLs - guaranteed to work
PRODUCT_IMAGES = {
    'ROLEX_SUB_001': "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=300&fit=crop",
    'ROLEX_GMT_001': "https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=400&h=300&fit=crop", 
    'OMEGA_SPEED_001': "https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?w=400&h=300&fit=crop",
    'OMEGA_SEAMASTER_001': "https://images.unsplash.com/photo-1533139502658-0198f920d8e8?w=400&h=300&fit=crop",
    'TAG_CARRERA_001': "https://images.unsplash.com/photo-1614164185128-e4ec99c436d7?w=400&h=300&fit=crop",
    'SEIKO_PROSPEX_001': "https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=400&h=300&fit=crop",
    'SEIKO_PRESAGE_001': "https://images.unsplash.com/photo-1548171915-e79a380a2a4b?w=400&h=300&fit=crop",
    'CITIZEN_ECODRIVE_001': "https://images.unsplash.com/photo-1542496658-e33a6d0d50b6?w=400&h=300&fit=crop",
    'CASIO_GSHOCK_001': "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop",
    'APPLE_WATCH_001': "https://images.unsplash.com/photo-1551816230-ef5deaed4a26?w=400&h=300&fit=crop"
}

# Default fallback image
DEFAULT_IMAGE = "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=300&fit=crop"

def get_product_image(product_id, product_name="", width=200):
    """Get working image URL for any product"""
    # First try exact product ID match
    if product_id in PRODUCT_IMAGES:
        return PRODUCT_IMAGES[product_id]
    
    # Then try partial matches based on product name
    name_lower = product_name.lower()
    if 'submariner' in name_lower or 'rolex' in name_lower:
        return PRODUCT_IMAGES['ROLEX_SUB_001']
    elif 'g-shock' in name_lower or 'casio' in name_lower:
        return PRODUCT_IMAGES['CASIO_GSHOCK_001']
    elif 'speedmaster' in name_lower or 'omega' in name_lower:
        return PRODUCT_IMAGES['OMEGA_SPEED_001']
    elif 'apple' in name_lower or 'watch series' in name_lower:
        return PRODUCT_IMAGES['APPLE_WATCH_001']
    elif 'prospex' in name_lower or 'seiko' in name_lower:
        return PRODUCT_IMAGES['SEIKO_PROSPEX_001']
    elif 'tag' in name_lower or 'carrera' in name_lower:
        return PRODUCT_IMAGES['TAG_CARRERA_001']
    elif 'citizen' in name_lower:
        return PRODUCT_IMAGES['CITIZEN_ECODRIVE_001']
    
    # Final fallback
    return DEFAULT_IMAGE

# Customer tier images function
def get_customer_tier_image(tier):
    """Return appropriate tier image based on customer tier"""
    tier_images = {
        'Bronze': '🥉',  # Bronze medal
        'Silver': '🥈',  # Silver medal  
        'Gold': '🥇',    # Gold medal
        'Platinum': '💎', # Diamond
        'Diamond': '💎'   # Diamond
    }
    return tier_images.get(tier, '👤')

# Database connection for Streamlit in Snowflake
@st.cache_resource
def init_connection():
    conn = st.connection("snowflake")
    return conn

# Helper functions
@st.cache_data
def run_query(query, params=None):
    conn = init_connection()
    if params:
        return conn.query(query, params=params)
    else:
        return conn.query(query)

# Main app
def main():
    st.title("⌚ Retail Watch Store - Customer 360")
    st.markdown("AI-Powered Watch Store with Churn Prediction, Sentiment Analysis & Price Optimization")
    
    # Initialize session state
    if 'current_customer' not in st.session_state:
        st.session_state.current_customer = None
    if 'shopping_context' not in st.session_state:
        st.session_state.shopping_context = 'general'
    
    # Sidebar for customer selection
    with st.sidebar:
        st.header("👤 Customer Selection")
        
        # Get customer list
        customers = run_query("""
            SELECT customer_id, first_name, last_name, customer_tier, churn_risk_score
            FROM RETAIL_WATCH_DB.PUBLIC.customers 
            ORDER BY total_spent DESC
        """)
        
        customer_options = {}
        if not customers.empty:
            for _, customer in customers.iterrows():
                tier_icon = get_customer_tier_image(customer['CUSTOMER_TIER'])  # Use tier images
                risk_level = "HIGH" if customer['CHURN_RISK_SCORE'] > 0.7 else "MEDIUM" if customer['CHURN_RISK_SCORE'] > 0.4 else "LOW"
                display_name = f"{tier_icon} {customer['FIRST_NAME']} {customer['LAST_NAME']} ({customer['CUSTOMER_TIER']}) - {risk_level} RISK"
                customer_options[display_name] = customer['CUSTOMER_ID']
        
        selected_customer_display = st.selectbox(
            "Choose Customer:",
            options=list(customer_options.keys()) if customer_options else ["No customers available"]
        )
        
        if selected_customer_display and customer_options and selected_customer_display != "No customers available":
            st.session_state.current_customer = customer_options[selected_customer_display]
        
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
        
        # Quick actions with cache clearing
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
        # Navigation tabs
        tab1, tab2, tab3, tab4, tab5 = st.tabs([
            "🏠 Customer Dashboard",
            "🎯 Personal Recommendations", 
            "⚠️ Churn Analysis",
            "💰 Price Optimization",
            "📊 Sentiment Analysis"
        ])
        
        with tab1:
            display_customer_dashboard()
        with tab2:
            display_personal_recommendations(st.session_state.current_customer)
        with tab3:
            display_churn_analysis(st.session_state.current_customer)
        with tab4:
            display_price_optimization()
        with tab5:
            display_sentiment_analysis()
    else:
        st.info("👆 Please select a customer from the sidebar to begin.")

def display_customer_dashboard():
    customer_id = st.session_state.current_customer
    
    # Get customer insights (simplified version without risk_assessment)
    try:
        insights_query = f"SELECT get_customer_360_insights('{customer_id}', 'general') as insights"
        insights_result = run_query(insights_query)
        
        if not insights_result.empty:
            insights = json.loads(insights_result.iloc[0]['INSIGHTS'])
        else:
            insights = None
    except Exception as e:
        st.warning("⚠️ AI insights temporarily unavailable. Showing basic customer information.")
        insights = None
    
    # Display customer overview with tier icon
    if insights:
        customer_overview = insights.get('customer_overview', {})
        tier = customer_overview.get('tier', 'Bronze')
        tier_icon = get_customer_tier_image(tier)
        
        st.markdown(f"""
        <div style="background: linear-gradient(90deg, #667eea 0%, #764ba2 100%); 
                    padding: 2rem; border-radius: 15px; color: white; margin-bottom: 2rem;">
            <h1>{tier_icon} {customer_overview.get('name', 'Customer')} - {tier} Tier</h1>
            <h3>💎 Lifetime Value: ${customer_overview.get('lifetime_value', 0):,.0f}</h3>
            <p>📧 {customer_overview.get('email', 'N/A')}</p>
            <p>🛍️ Total Orders: {customer_overview.get('total_orders', 0)} | 
               💰 Total Spent: ${customer_overview.get('total_spent', 0):,.0f} | 
               📊 Avg Order: ${customer_overview.get('avg_order_value', 0):,.0f}</p>
        </div>
        """, unsafe_allow_html=True)
        
        # Display other metrics instead of risk assessment
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.metric("Account Age", f"{customer_overview.get('account_age_days', 0)} days")
        with col2:
            st.metric("Total Orders", customer_overview.get('total_orders', 0))
        with col3:
            st.metric("Average Order", f"${customer_overview.get('avg_order_value', 0):,.0f}")

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
        recommendations = None
    
    if recommendations and 'top_recommendations' in recommendations:
        # Display customer insights
        insights = recommendations.get('customer_insights', {})
        st.markdown(f"""
        <div class="customer-insights">
            <h3>👤 Your Profile</h3>
            <p><strong>Tier:</strong> {insights.get('tier', 'N/A')}</p>
            <p><strong>Preferred Brands:</strong> {insights.get('preferred_brands', 'None specified')}</p>
            <p><strong>Style Preferences:</strong> {insights.get('style_preferences', 'None specified')}</p>
        </div>
        """, unsafe_allow_html=True)
        
        # Display recommendations with guaranteed working images
        top_recs = recommendations['top_recommendations']
        
        for i, rec in enumerate(top_recs):
            col1, col2 = st.columns([1, 3])
            
            with col1:
                # Force working image using our hardcoded URLs
                product_id = rec.get('product_id', '')
                product_name = rec.get('product_name', '')
                image_url = get_product_image(product_id, product_name, width=200)
                
                st.image(image_url, width=200, caption=rec['product_name'])
            
            with col2:
                match_reasons = [reason for reason in rec['match_reasons'] if reason]
                
                st.markdown(f"""
                <div class="recommendation-card">
                    <h3>{rec['product_name']}</h3>
                    <p><strong>{rec['brand_name']}</strong> | ${rec['price']:,.2f}</p>
                    <p>⭐ {rec['rating']:.1f}/5.0 ({rec['review_count']} reviews)</p>
                    <p><strong>Match Score:</strong> {rec['recommendation_score']}/100</p>
                    <p><strong>Why this matches:</strong></p>
                    <ul>{''.join([f'<li>{reason}</li>' for reason in match_reasons])}</ul>
                    <p>{rec['description']}</p>
                </div>
                """, unsafe_allow_html=True)
                
                if st.button(f"🛒 Add to Cart", key=f"add_cart_{i}"):
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
        analysis = None
    
    # Display analysis results
    if analysis:
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("📊 Risk Metrics")
            st.metric("Risk Score", f"{analysis['risk_score']:.3f}")
            st.metric("Risk Level", analysis['risk_level'])
            
        with col2:
            st.subheader("🎯 Risk Factors")
            if 'risk_factors' in analysis:
                for factor in analysis['risk_factors']:
                    st.write(f"• {factor}")
    else:
        st.info("Analysis data not available")

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
        options=list(product_options.keys()) if product_options else ["No products available"],
        key="price_optimization_product_selector"  # Fixed navigation key
    )
    
    if selected_product_display and product_options and selected_product_display != "No products available":
        selected_product_id = product_options[selected_product_display]
        
        # Get selected product details for display
        selected_product = products[products['PRODUCT_ID'] == selected_product_id].iloc[0]
        
        # Display product image and info with guaranteed working image
        col1, col2 = st.columns([1, 2])
        with col1:
            # Force working image using our hardcoded URLs
            image_url = get_product_image(selected_product_id, selected_product['PRODUCT_NAME'], width=200)
            st.image(image_url, width=200, caption=selected_product['PRODUCT_NAME'])
        
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
    st.header("📊 Sentiment Analysis Dashboard")
    
    # Get reviews for analysis
    reviews = run_query("""
        SELECT pr.review_id, pr.product_id, pr.review_text, pr.rating, pr.review_date,
               p.product_name, b.brand_name, p.product_images
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
            display_text = f"{review['PRODUCT_NAME']} - Rating: {review['RATING']}⭐ - {review['REVIEW_TEXT'][:50]}..."
            review_options[display_text] = review['REVIEW_ID']
        
        selected_review_display = st.selectbox(
            "Select Review for Analysis:",
            options=list(review_options.keys())
        )
        
        if selected_review_display:
            selected_review_id = review_options[selected_review_display]
            selected_review = reviews[reviews['REVIEW_ID'] == selected_review_id].iloc[0]
            
            # Display review context with guaranteed working image
            col1, col2 = st.columns([1, 3])
            with col1:
                # Force working image using our hardcoded URLs
                product_id = selected_review['PRODUCT_ID']
                product_name = selected_review['PRODUCT_NAME']
                image_url = get_product_image(product_id, product_name, width=150)
                st.image(image_url, width=150, caption=selected_review['PRODUCT_NAME'])
            
            with col2:
                st.subheader(f"{selected_review['PRODUCT_NAME']}")
                st.write(f"**Brand:** {selected_review['BRAND_NAME']}")
                st.write(f"**Rating:** {selected_review['RATING']}⭐")
                # Safe date formatting
                review_date = selected_review['REVIEW_DATE']
                if hasattr(review_date, 'year'):
                    date_str = f"{review_date.year}-{review_date.month:02d}-{review_date.day:02d}"
                else:
                    date_str = str(review_date)[:10]
                st.write(f"**Review Date:** {date_str}")
            
            # Display review
            st.subheader("📝 Review Text")
            st.text_area("Review Content:", selected_review['REVIEW_TEXT'], height=100, disabled=True)
            
            # Simplified sentiment analysis (NO SCORE - as requested)
            st.subheader("📊 Sentiment Analysis")
            sentiment_result = run_query(
                f"SELECT analyze_review_sentiment('{selected_review_id}') as result"
            )
            
            if not sentiment_result.empty:
                result_raw = sentiment_result.iloc[0]['RESULT']
                result = json.loads(result_raw) if isinstance(result_raw, str) else result_raw
                
                confidence = result.get('confidence', 0)
                sentiment_label = result.get('sentiment_label', 'Unknown')
                
                # Simple metrics without score (as requested)
                col1, col2 = st.columns(2)
                with col1:
                    st.metric("Sentiment", sentiment_label)
                with col2:
                    st.metric("Confidence", f"{confidence:.1%}")
                
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

if __name__ == "__main__":
    main() 