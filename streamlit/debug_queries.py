import streamlit as st
import pandas as pd

# Test individual queries to identify the problematic one
def test_queries():
    """Test each query individually to find the problematic one"""
    
    # Initialize connection
    try:
        conn = st.connection("snowflake")
        print("✅ Connection established")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return
    
    # Test queries one by one
    test_queries_list = [
        ("Customers query", """
            SELECT customer_id, first_name, last_name, customer_tier, churn_risk_score
            FROM RETAIL_WATCH_DB.PUBLIC.customers 
            ORDER BY total_spent DESC
            LIMIT 5
        """),
        
        ("Products query", """
            SELECT product_id, product_name, brand_name, current_price, stock_quantity, product_images
            FROM RETAIL_WATCH_DB.PUBLIC.products p
            JOIN RETAIL_WATCH_DB.PUBLIC.watch_brands b ON p.brand_id = b.brand_id
            WHERE p.product_status = 'active'
            LIMIT 5
        """),
        
        ("Reviews query", """
            SELECT pr.review_id, pr.product_id, pr.review_text, pr.rating, pr.review_date,
                   p.product_name, b.brand_name, p.product_images
            FROM RETAIL_WATCH_DB.PUBLIC.product_reviews pr
            JOIN RETAIL_WATCH_DB.PUBLIC.products p ON pr.product_id = p.product_id
            JOIN RETAIL_WATCH_DB.PUBLIC.watch_brands b ON p.brand_id = b.brand_id
            ORDER BY pr.review_date DESC
            LIMIT 5
        """),
        
        ("AI Function test", """
            SELECT get_personal_recommendations('CUST_001', 'general') as recommendations
        """)
    ]
    
    for query_name, query in test_queries_list:
        try:
            print(f"🧪 Testing {query_name}...")
            result = conn.query(query)
            print(f"✅ {query_name}: SUCCESS ({len(result)} rows)")
        except Exception as e:
            print(f"❌ {query_name}: FAILED - {str(e)}")
            
    print("\n🔍 Test complete!")

if __name__ == "__main__":
    test_queries() 