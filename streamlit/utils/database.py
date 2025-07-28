"""
Database utility functions for the Retail Watch Store Streamlit app
Compatible with Streamlit in Snowflake (SiS)
"""

import streamlit as st
import pandas as pd
import json
from typing import List, Dict, Any, Optional

class SnowflakeConnection:
    """Handles Snowflake database connections and queries for Streamlit in Snowflake"""
    
    def __init__(self):
        self.connection = None
        self._connect()
    
    def _connect(self):
        """Initialize connection to Snowflake using Streamlit native connection"""
        try:
            self.connection = st.connection("snowflake")
        except Exception as e:
            st.error(f"Failed to connect to Snowflake: {str(e)}")
            raise e
    
    def execute_query(self, query: str, params: Optional[Dict] = None) -> pd.DataFrame:
        """Execute a query and return results as DataFrame"""
        try:
            return self.connection.query(query, params=params if params else None)
        except Exception as e:
            st.error(f"Query execution failed: {str(e)}")
            return pd.DataFrame()
    
    def execute_query_df(self, query: str, params: Optional[Dict] = None) -> pd.DataFrame:
        """Execute a query and return results as DataFrame (alias for consistency)"""
        return self.execute_query(query, params)
    
    def close(self):
        """Close the connection"""
        if self.connection:
            self.connection.close()

# Cached connection instance
@st.cache_resource
def get_db_connection():
    """Get cached database connection"""
    return SnowflakeConnection()

# Customer-related queries
class CustomerQueries:
    """Customer-specific database queries"""
    
    @staticmethod
    def get_all_customers() -> pd.DataFrame:
        """Get all customers with basic info"""
        db = get_db_connection()
        query = """
        SELECT 
            customer_id,
            first_name,
            last_name,
            email,
            customer_tier,
            total_spent,
            churn_risk_score,
            satisfaction_score,
            last_purchase_date
        FROM customers 
        ORDER BY total_spent DESC
        """
        return db.execute_query_df(query)
    
    @staticmethod
    def get_customer_insights(customer_id: str) -> Dict:
        """Get customer 360 insights"""
        db = get_db_connection()
        query = f"SELECT get_customer_360_insights('{customer_id}') as insights"
        result = db.execute_query(query)
        
        if result and result[0][0]:
            return json.loads(result[0][0])
        return {}
    
    @staticmethod
    def get_customer_recommendations(customer_id: str, context: str = 'general') -> Dict:
        """Get personalized product recommendations"""
        db = get_db_connection()
        query = f"SELECT get_personal_recommendations('{customer_id}', '{context}') as recommendations"
        result = db.execute_query(query)
        
        if result and result[0][0]:
            return json.loads(result[0][0])
        return {}
    
    @staticmethod
    def predict_churn(customer_id: str) -> Dict:
        """Get churn prediction for customer"""
        db = get_db_connection()
        query = f"SELECT predict_customer_churn('{customer_id}') as churn_data"
        result = db.execute_query(query)
        
        if result and result[0][0]:
            return json.loads(result[0][0])
        return {}
    
    @staticmethod
    def get_customer_reviews(customer_id: str) -> pd.DataFrame:
        """Get customer's product reviews"""
        db = get_db_connection()
        query = f"""
        SELECT 
            pr.review_id,
            pr.rating,
            pr.review_text,
            pr.sentiment_score,
            pr.sentiment_label,
            pr.key_themes,
            pr.review_date,
            p.product_name,
            b.brand_name
        FROM product_reviews pr
        JOIN products p ON pr.product_id = p.product_id
        JOIN watch_brands b ON p.brand_id = b.brand_id
        WHERE pr.customer_id = '{customer_id}'
        ORDER BY pr.review_date DESC
        """
        return db.execute_query_df(query)
    
    @staticmethod
    def get_customer_events(customer_id: str, days: int = 30) -> pd.DataFrame:
        """Get customer behavioral events"""
        db = get_db_connection()
        query = f"""
        SELECT 
            event_type,
            event_timestamp,
            product_id,
            category,
            page_url,
            device_type
        FROM customer_events 
        WHERE customer_id = '{customer_id}'
        AND event_timestamp >= CURRENT_TIMESTAMP - INTERVAL '{days} days'
        ORDER BY event_timestamp DESC
        """
        return db.execute_query_df(query)

# Product-related queries
class ProductQueries:
    """Product-specific database queries"""
    
    @staticmethod
    def get_all_products() -> pd.DataFrame:
        """Get all active products"""
        db = get_db_connection()
        query = """
        SELECT 
            p.product_id,
            p.product_name,
            b.brand_name,
            p.current_price,
            p.retail_price,
            p.avg_rating,
            p.review_count,
            p.stock_quantity,
            wc.category_name
        FROM products p
        JOIN watch_brands b ON p.brand_id = b.brand_id
        JOIN watch_categories wc ON p.category_id = wc.category_id
        WHERE p.product_status = 'active'
        ORDER BY p.current_price DESC
        """
        return db.execute_query_df(query)
    
    @staticmethod
    def optimize_pricing(product_id: str) -> Dict:
        """Get price optimization recommendations"""
        db = get_db_connection()
        query = f"SELECT optimize_product_pricing('{product_id}') as price_data"
        result = db.execute_query(query)
        
        if result and result[0][0]:
            return json.loads(result[0][0])
        return {}
    
    @staticmethod
    def analyze_sentiment(review_text: str) -> Dict:
        """Analyze sentiment of review text"""
        db = get_db_connection()
        # Escape single quotes in the review text
        escaped_text = review_text.replace("'", "''")
        query = f"SELECT analyze_review_sentiment('{escaped_text}') as sentiment_data"
        result = db.execute_query(query)
        
        if result and result[0][0]:
            return json.loads(result[0][0])
        return {}

# Analytics queries
class AnalyticsQueries:
    """Analytics and reporting queries"""
    
    @staticmethod
    def get_sales_metrics(days: int = 30) -> Dict:
        """Get sales metrics for the specified period"""
        db = get_db_connection()
        query = f"""
        SELECT 
            COUNT(DISTINCT o.order_id) as total_orders,
            COUNT(DISTINCT o.customer_id) as unique_customers,
            SUM(o.total_amount) as total_revenue,
            AVG(o.total_amount) as avg_order_value,
            SUM(oi.quantity) as total_items_sold
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.order_date >= CURRENT_DATE - {days}
        """
        result = db.execute_query(query)
        
        if result:
            return {
                'total_orders': result[0][0] or 0,
                'unique_customers': result[0][1] or 0,
                'total_revenue': result[0][2] or 0,
                'avg_order_value': result[0][3] or 0,
                'total_items_sold': result[0][4] or 0
            }
        return {}
    
    @staticmethod
    def get_churn_distribution() -> pd.DataFrame:
        """Get distribution of customers by churn risk"""
        db = get_db_connection()
        query = """
        SELECT 
            CASE 
                WHEN churn_risk_score >= 0.7 THEN 'High Risk'
                WHEN churn_risk_score >= 0.4 THEN 'Medium Risk'
                WHEN churn_risk_score >= 0.2 THEN 'Low Risk'
                ELSE 'Very Low Risk'
            END as risk_category,
            COUNT(*) as customer_count,
            ROUND(AVG(total_spent), 2) as avg_spent,
            ROUND(AVG(satisfaction_score), 2) as avg_satisfaction
        FROM customers
        GROUP BY risk_category
        ORDER BY 
            CASE risk_category
                WHEN 'High Risk' THEN 1
                WHEN 'Medium Risk' THEN 2
                WHEN 'Low Risk' THEN 3
                ELSE 4
            END
        """
        return db.execute_query_df(query)
    
    @staticmethod
    def get_brand_performance() -> pd.DataFrame:
        """Get brand performance metrics"""
        db = get_db_connection()
        query = """
        SELECT 
            b.brand_name,
            b.brand_tier,
            COUNT(DISTINCT p.product_id) as product_count,
            COALESCE(SUM(sales.revenue), 0) as total_revenue,
            COALESCE(SUM(sales.quantity), 0) as units_sold,
            ROUND(AVG(p.avg_rating), 2) as avg_rating
        FROM watch_brands b
        JOIN products p ON b.brand_id = p.brand_id
        LEFT JOIN (
            SELECT 
                oi.product_id,
                SUM(oi.total_price) as revenue,
                SUM(oi.quantity) as quantity
            FROM order_items oi
            JOIN orders o ON oi.order_id = o.order_id
            WHERE o.order_date >= CURRENT_DATE - 90
            GROUP BY oi.product_id
        ) sales ON p.product_id = sales.product_id
        GROUP BY b.brand_name, b.brand_tier
        ORDER BY total_revenue DESC
        """
        return db.execute_query_df(query)

# Utility functions
def format_currency(amount: float) -> str:
    """Format currency values"""
    return f"${amount:,.2f}"

def format_percentage(value: float) -> str:
    """Format percentage values"""
    return f"{value:.1%}"

def get_risk_color(risk_score: float) -> str:
    """Get color based on risk score"""
    if risk_score >= 0.7:
        return "#dc3545"  # Red
    elif risk_score >= 0.4:
        return "#fd7e14"  # Orange
    elif risk_score >= 0.2:
        return "#28a745"  # Green
    else:
        return "#007bff"  # Blue

def get_sentiment_color(sentiment_score: float) -> str:
    """Get color based on sentiment score"""
    if sentiment_score > 0.3:
        return "#28a745"  # Green (positive)
    elif sentiment_score < -0.3:
        return "#dc3545"  # Red (negative)
    else:
        return "#fd7e14"  # Orange (neutral) 