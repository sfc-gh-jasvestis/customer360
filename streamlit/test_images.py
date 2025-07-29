import streamlit as st
import json

def test_images():
    """Test what images are actually being returned"""
    
    st.title("🧪 Image Testing")
    
    # Test database connection
    try:
        conn = st.connection("snowflake")
        st.success("✅ Database connected")
    except Exception as e:
        st.error(f"❌ Database connection failed: {e}")
        return
    
    # Test product images from database
    st.header("📊 Database Product Images")
    try:
        products_query = """
            SELECT product_id, product_name, product_images 
            FROM RETAIL_WATCH_DB.PUBLIC.products 
            WHERE product_id IN ('ROLEX_SUB_001', 'CASIO_GSHOCK_001', 'APPLE_WATCH_001')
            ORDER BY product_id
        """
        products = conn.query(products_query)
        
        for _, product in products.iterrows():
            st.subheader(f"{product['PRODUCT_NAME']} ({product['PRODUCT_ID']})")
            images = product['PRODUCT_IMAGES']
            st.write(f"**Images data type:** {type(images)}")
            st.write(f"**Images content:** {images}")
            
            # Try to display the images
            if images:
                try:
                    if isinstance(images, list):
                        for i, img_url in enumerate(images):
                            st.write(f"Image {i+1}: {img_url}")
                            try:
                                st.image(img_url, width=200, caption=f"Image {i+1}")
                            except Exception as e:
                                st.error(f"Failed to load image {i+1}: {e}")
                    else:
                        st.write(f"Images is not a list: {images}")
                except Exception as e:
                    st.error(f"Error processing images: {e}")
            else:
                st.warning("No images found")
            st.markdown("---")
                    
    except Exception as e:
        st.error(f"❌ Failed to fetch products: {e}")
    
    # Test recommendations function
    st.header("🎯 Recommendations Function Images")
    try:
        rec_query = "SELECT get_personal_recommendations('CUST_001', 'general') as recommendations"
        rec_result = conn.query(rec_query)
        
        if not rec_result.empty:
            recommendations = json.loads(rec_result.iloc[0]['RECOMMENDATIONS'])
            top_recs = recommendations.get('top_recommendations', [])
            
            for i, rec in enumerate(top_recs):
                st.subheader(f"{rec['product_name']} ({rec['product_id']})")
                images = rec.get('images', [])
                st.write(f"**Images data type:** {type(images)}")
                st.write(f"**Images content:** {images}")
                
                # Try to display the images
                if images and isinstance(images, list):
                    for j, img_url in enumerate(images):
                        st.write(f"Image {j+1}: {img_url}")
                        try:
                            st.image(img_url, width=200, caption=f"Rec {i+1} - Image {j+1}")
                        except Exception as e:
                            st.error(f"Failed to load image {j+1}: {e}")
                else:
                    st.warning("No valid images found")
                st.markdown("---")
        else:
            st.error("No recommendations returned")
            
    except Exception as e:
        st.error(f"❌ Failed to test recommendations: {e}")
    
    # Test individual image URLs
    st.header("🌐 Test Individual Image URLs")
    test_urls = [
        "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200&h=200&fit=crop",
        "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200&h=200&fit=crop",
        "https://images.unsplash.com/photo-1551816230-ef5deaed4a26?w=200&h=200&fit=crop",
        "https://images.unsplash.com/photo-1594534475808-b18fc33b045e?w=200&h=200&fit=crop",
        "https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=200&h=200&fit=crop"
    ]
    
    for i, url in enumerate(test_urls):
        st.write(f"**Test URL {i+1}:** {url}")
        try:
            st.image(url, width=200, caption=f"Test Image {i+1}")
            st.success(f"✅ URL {i+1} works")
        except Exception as e:
            st.error(f"❌ URL {i+1} failed: {e}")

if __name__ == "__main__":
    test_images() 