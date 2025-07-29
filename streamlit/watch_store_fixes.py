# ============================================================================
# STREAMLIT FIXES FOR MULTIPLE ISSUES
# ============================================================================

# 1. Customer Profile Images Function
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

# 2. Circular Sentiment Score Display
def create_sentiment_circle(sentiment_score, confidence, sentiment_label):
    """Create circular sentiment display with score in the middle"""
    return f"""
    <div style="display: flex; justify-content: center; align-items: center; margin: 20px 0;">
        <div style="
            width: 150px; 
            height: 150px; 
            border-radius: 50%; 
            background: conic-gradient(#00ff88 0% {confidence*100}%, #e0e0e0 {confidence*100}% 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
        ">
            <div style="
                width: 120px; 
                height: 120px; 
                border-radius: 50%; 
                background: white;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                font-weight: bold;
            ">
                <div style="font-size: 24px; color: #333;">{sentiment_score:.2f}</div>
                <div style="font-size: 14px; color: #666;">{sentiment_label}</div>
            </div>
        </div>
    </div>
    """

# 3. Product Image URLs (to replace in database)
UPDATED_PRODUCT_IMAGES = {
    'ROLEX_SUB_001': [
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1594534475808-b18fc33b045e?w=400&h=300&fit=crop'
    ],
    'CASIO_GSHOCK_001': [
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1618220179428-22790b461013?w=400&h=300&fit=crop'
    ],
    'OMEGA_SPEED_001': [
        'https://images.unsplash.com/photo-1594534475808-b18fc33b045e?w=400&h=300&fit=crop', 
        'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?w=400&h=300&fit=crop'
    ],
    'SEIKO_PROSPEX_001': [
        'https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1611917743750-b2b991c5abc5?w=400&h=300&fit=crop'
    ]
}

# 4. Navigation Fix
# Add this key to the selectbox: key="price_optimization_product_selector"

# 5. Sections to Remove (Risk Assessment)
# Remove these lines:
# - Line 580: <h4>Risk Assessment</h4>
# - Lines 321-334: risk_assessment = insights.get('risk_assessment', {})
# - Lines 295-299: 'risk_assessment': { ... }

print("✅ All fixes documented and ready to apply!") 