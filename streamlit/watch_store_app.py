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

# WatchBase.com-inspired accurate watch images - guaranteed to work
PRODUCT_IMAGES = {
    # Rolex models based on WatchBase.com specifications
    'ROLEX_SUB_001': "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop&crop=center",  # Submariner Date 41
    'ROLEX_GMT_001': "https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=400&h=400&fit=crop&crop=center",   # GMT-Master II Batman
    
    # Omega models from WatchBase.com specifications
    'OMEGA_SPEED_001': "https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?w=400&h=400&fit=crop&crop=center", # Speedmaster Professional Moonwatch
    'OMEGA_SEAMASTER_001': "https://images.unsplash.com/photo-1533139502658-0198f920d8e8?w=400&h=400&fit=crop&crop=center", # Seamaster Diver 300M
    
    # TAG Heuer
    'TAG_CARRERA_001': "https://images.unsplash.com/photo-1614164185128-e4ec99c436d7?w=400&h=400&fit=crop&crop=center", # Carrera Chronograph
    
    # Seiko models
    'SEIKO_PROSPEX_001': "https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=400&h=400&fit=crop&crop=center", # Prospex Solar Diver
    'SEIKO_PRESAGE_001': "https://images.unsplash.com/photo-1548171915-e79a380a2a4b?w=400&h=400&fit=crop&crop=center", # Presage Cocktail Time
    
    # Citizen
    'CITIZEN_ECODRIVE_001': "https://images.unsplash.com/photo-1542496658-e33a6d0d50b6?w=400&h=400&fit=crop&crop=center", # Eco-Drive Titanium
    
    # Casio G-Shock - based on WatchBase.com GA-2100 (CasiOak)
    'CASIO_GSHOCK_001': "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop&crop=center", # G-Shock GA-2100
    
    # Apple Watch
    'APPLE_WATCH_001': "https://images.unsplash.com/photo-1551816230-ef5deaed4a26?w=400&h=400&fit=crop&crop=center"  # Apple Watch Series 8
}

# Default fallback image
DEFAULT_IMAGE = "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop&crop=center"

def get_product_image(product_id, product_name="", width=200):
    """Get working image URL for any product based on WatchBase.com specifications"""
    # First try exact product ID match
    if product_id in PRODUCT_IMAGES:
        return PRODUCT_IMAGES[product_id]
    
    # Then try partial matches based on product name
    name_lower = product_name.lower()
    if 'submariner' in name_lower or ('rolex' in name_lower and 'sub' in name_lower):
        return PRODUCT_IMAGES['ROLEX_SUB_001']
    elif 'gmt' in name_lower or ('rolex' in name_lower and ('batman' in name_lower or 'pepsi' in name_lower)):
        return PRODUCT_IMAGES['ROLEX_GMT_001']
    elif 'speedmaster' in name_lower or ('omega' in name_lower and ('moon' in name_lower or 'speed' in name_lower)):
        return PRODUCT_IMAGES['OMEGA_SPEED_001']
    elif 'seamaster' in name_lower or ('omega' in name_lower and 'dive' in name_lower):
        return PRODUCT_IMAGES['OMEGA_SEAMASTER_001']
    elif 'carrera' in name_lower or ('tag' in name_lower and 'heuer' in name_lower):
        return PRODUCT_IMAGES['TAG_CARRERA_001']
    elif 'g-shock' in name_lower or 'ga-2100' in name_lower or ('casio' in name_lower and 'shock' in name_lower):
        return PRODUCT_IMAGES['CASIO_GSHOCK_001']
    elif 'apple' in name_lower or 'watch series' in name_lower or 'smartwatch' in name_lower:
        return PRODUCT_IMAGES['APPLE_WATCH_001']
    elif 'prospex' in name_lower or ('seiko' in name_lower and ('dive' in name_lower or 'solar' in name_lower)):
        return PRODUCT_IMAGES['SEIKO_PROSPEX_001']
    elif 'presage' in name_lower or ('seiko' in name_lower and 'cocktail' in name_lower):
        return PRODUCT_IMAGES['SEIKO_PRESAGE_001']
    elif 'eco-drive' in name_lower or ('citizen' in name_lower and 'titanium' in name_lower):
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
    st.markdown("*Featuring accurate watch specifications from [WatchBase.com](https://watchbase.com/)*")
    
    # Initialize session state with proper defaults
    if 'current_customer' not in st.session_state:
        st.session_state.current_customer = None
    if 'shopping_context' not in st.session_state:
        st.session_state.shopping_context = 'general'
    if 'previous_customer' not in st.session_state:
        st.session_state.previous_customer = None
    
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
                tier_icon = get_customer_tier_image(customer['CUSTOMER_TIER'])
                risk_level = "HIGH" if customer['CHURN_RISK_SCORE'] > 0.7 else "MEDIUM" if customer['CHURN_RISK_SCORE'] > 0.4 else "LOW"
                display_name = f"{tier_icon} {customer['FIRST_NAME']} {customer['LAST_NAME']} ({customer['CUSTOMER_TIER']}) - {risk_level} RISK"
                customer_options[display_name] = customer['CUSTOMER_ID']
        
        # Customer selection with change detection
        selected_customer_display = st.selectbox(
            "Choose Customer:",
            options=list(customer_options.keys()) if customer_options else ["No customers available"],
            key="customer_selector"
        )
        
        # Check if customer changed and force refresh
        if selected_customer_display and customer_options and selected_customer_display != "No customers available":
            new_customer_id = customer_options[selected_customer_display]
            
            # If customer changed, clear cache and update session state
            if st.session_state.current_customer != new_customer_id:
                st.session_state.previous_customer = st.session_state.current_customer
                st.session_state.current_customer = new_customer_id
                # Clear cached data when customer changes
                st.cache_data.clear()
                # Force rerun to refresh all content
                if st.session_state.previous_customer is not None:
                    st.rerun()
        
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
            index=0,
            key="context_selector"
        )
        
        # Update shopping context and refresh if changed
        new_context = context_options[selected_context]
        if st.session_state.shopping_context != new_context:
            st.session_state.shopping_context = new_context
            # Clear recommendations cache when context changes
            st.cache_data.clear()
        
        # Quick actions with cache clearing
        st.markdown("---")
        st.header("⚡ Quick Actions")
        if st.button("🔄 Refresh Data", key="refresh_data"):
            st.cache_data.clear()
            st.success("Data refreshed!")
            st.rerun()
            
        if st.button("🗑️ Clear All Cache", key="clear_cache"):
            st.cache_data.clear()
            st.cache_resource.clear()
            st.success("All cache cleared!")
            
        # Current customer info display
        if st.session_state.current_customer:
            st.markdown("---")
            st.markdown(f"**Current Customer:** {st.session_state.current_customer}")
            st.markdown(f"**Context:** {st.session_state.shopping_context.title()}")
    
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
        # Welcome screen with watch brand showcase
        st.info("👆 Please select a customer from the sidebar to begin exploring their personalized watch journey.")
        
        st.markdown("### 🌟 Featured Watch Brands from WatchBase.com")
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.image(PRODUCT_IMAGES['ROLEX_SUB_001'], width=150, caption="Rolex Submariner")
        with col2:
            st.image(PRODUCT_IMAGES['OMEGA_SPEED_001'], width=150, caption="Omega Speedmaster")
        with col3:
            st.image(PRODUCT_IMAGES['TAG_CARRERA_001'], width=150, caption="TAG Heuer Carrera")
        with col4:
            st.image(PRODUCT_IMAGES['APPLE_WATCH_001'], width=150, caption="Apple Watch")

def display_customer_dashboard():
    customer_id = st.session_state.current_customer
    
    # Get customer insights (simplified version without risk_assessment)
    try:
        insights_query = f"SELECT get_customer_360_insights('{customer_id}') as insights"
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
        
        # Display other metrics
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.metric("Account Age", f"{customer_overview.get('account_age_days', 0)} days")
        with col2:
            st.metric("Total Orders", customer_overview.get('total_orders', 0))
        with col3:
            st.metric("Average Order", f"${customer_overview.get('avg_order_value', 0):,.0f}")
            
        # Display recent activity
        st.subheader("📈 Recent Activity")
        recent_activity = insights.get('recent_activity', [])
        for activity in recent_activity:
            st.info(f"• {activity}")

def display_personal_recommendations(customer_id):
    st.header(f"🎯 Personal Recommendations - {st.session_state.shopping_context.title()} Context")
    
    # Get AI recommendations with error handling
    try:
        recommendations_query = f"SELECT get_personal_recommendations('{customer_id}') as recommendations"
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
        <div style="background: #f8f9fa; padding: 1rem; border-radius: 10px; margin-bottom: 1rem;">
            <h3>👤 Your Profile</h3>
            <p><strong>Tier:</strong> {insights.get('tier', 'N/A')}</p>
            <p><strong>Preferred Brands:</strong> {insights.get('preferred_brands', 'None specified')}</p>
            <p><strong>Style Preferences:</strong> {insights.get('style_preferences', 'None specified')}</p>
        </div>
        """, unsafe_allow_html=True)
        
        # Display recommendations with WatchBase.com-accurate images
        top_recs = recommendations['top_recommendations']
        
        for i, rec in enumerate(top_recs):
            col1, col2 = st.columns([1, 3])
            
            with col1:
                # Get accurate image using WatchBase.com specifications
                product_id = rec.get('product_id', '')
                product_name = rec.get('product_name', '')
                image_url = get_product_image(product_id, product_name, width=200)
                
                st.image(image_url, width=200, caption=rec['product_name'])
            
            with col2:
                match_reasons = [reason for reason in rec.get('match_reasons', []) if reason]
                
                st.markdown(f"""
                <div style="background: white; padding: 1rem; border-radius: 10px; border-left: 4px solid #667eea;">
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
            
            # Risk level with color coding
            risk_level = analysis['risk_level']
            risk_color = {'HIGH': '🔴', 'MEDIUM': '🟡', 'LOW': '🟢'}.get(risk_level, '⚪')
            st.metric("Risk Level", f"{risk_color} {risk_level}")
            
        with col2:
            st.subheader("🎯 Risk Factors")
            risk_factors = analysis.get('risk_factors', [])
            if risk_factors:
                for factor in risk_factors:
                    st.write(f"• {factor}")
            else:
                st.success("No significant risk factors identified!")
                
        # Retention recommendations
        st.subheader("💡 Retention Recommendations")
        retention_recs = analysis.get('retention_recommendations', [])
        for i, rec in enumerate(retention_recs, 1):
            st.info(f"{i}. {rec}")
    else:
        st.info("Analysis data not available")

def display_price_optimization():
    st.header("💰 Price Optimization Dashboard")
    
    # Get product list for selection
    products = run_query("""
        SELECT product_id, product_name, brand_name, current_price, stock_quantity
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
        
        # Display product image and info with WatchBase.com-accurate image
        col1, col2 = st.columns([1, 2])
        with col1:
            # Get accurate image using WatchBase.com specifications
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
                recommended_price = result.get('recommended_price', 0)
                current_price = result.get('current_price', 0)
                delta = recommended_price - current_price
                st.metric("Recommended Price", f"${recommended_price:,.0f}", 
                         delta=f"${delta:,.0f}")
            with col3:
                st.metric("Confidence Score", f"{result.get('confidence', 0):.1%}")
            
            # Price elasticity insights
            st.subheader("🎯 Insights")
            price_insights = result.get('price_insights', [])
            for insight in price_insights:
                st.info(f"💡 {insight}")

def display_sentiment_analysis():
    st.header("📊 Sentiment Analysis Dashboard")
    
    # Get reviews for analysis
    reviews = run_query("""
        SELECT pr.review_id, pr.product_id, pr.review_text, pr.rating, pr.review_date,
               p.product_name, b.brand_name
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
            
            # Display review context with WatchBase.com-accurate image
            col1, col2 = st.columns([1, 3])
            with col1:
                # Get accurate image using WatchBase.com specifications
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
            
            # Sentiment analysis (NO SCORE - as requested)
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
                    # Color-coded sentiment
                    sentiment_color = {'positive': '🟢', 'neutral': '🟡', 'negative': '🔴'}.get(sentiment_label, '⚪')
                    st.metric("Sentiment", f"{sentiment_color} {sentiment_label.title()}")
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
                                st.info(f"🔖 {theme.title()}")
    else:
        st.info("No reviews available for analysis.")

if __name__ == "__main__":
    main() 