import streamlit as st

def clear_all_cache():
    """Clear all Streamlit cache to resolve SQL parameter issues"""
    try:
        st.cache_data.clear()
        st.cache_resource.clear()
        print("✅ Cache cleared successfully!")
        return True
    except Exception as e:
        print(f"❌ Error clearing cache: {e}")
        return False

if __name__ == "__main__":
    clear_all_cache() 