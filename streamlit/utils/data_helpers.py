"""
Data Helper Utilities for Customer 360 Demo

This module provides helper functions for accessing and manipulating
customer data from Snowflake for the Streamlit application.
"""

import streamlit as st
import pandas as pd
from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta

class DataHelpers:
    """Helper class for common data operations"""
    
    def __init__(self):
        """Initialize with Snowflake connection"""
        self.conn = st.connection("snowflake")
    
    @st.cache_data(ttl=300)  # Cache for 5 minutes
    def get_customers(_self) -> pd.DataFrame:
        """
        Get all customers with basic information
        
        Returns:
            DataFrame with customer data
        """
        try:
            query = """
            SELECT 
                customer_id,
                first_name,
                last_name,
                email,
                customer_tier,
                account_status,
                join_date,
                total_spent,
                lifetime_value,
                churn_risk_score,
                satisfaction_score,
                engagement_score,
                preferred_communication_channel,
                city,
                state_province,
                country
            FROM customers
            ORDER BY total_spent DESC
            """
            return _self.conn.query(query)
        except Exception as e:
            st.error(f"Error fetching customers: {str(e)}")
            return pd.DataFrame()
    
    @st.cache_data(ttl=300)
    def get_customer_360_summary(_self) -> pd.DataFrame:
        """
        Get customer 360 summary view
        
        Returns:
            DataFrame with comprehensive customer metrics
        """
        try:
            query = """
            SELECT * FROM customer_360_summary
            ORDER BY total_spent DESC
            """
            return _self.conn.query(query)
        except Exception as e:
            st.error(f"Error fetching customer summary: {str(e)}")
            return pd.DataFrame()
    
    @st.cache_data(ttl=60)  # Cache for 1 minute (more frequent updates)
    def get_recent_activities(_self, days: int = 30) -> pd.DataFrame:
        """
        Get recent customer activities
        
        Args:
            days: Number of days to look back
            
        Returns:
            DataFrame with recent activities
        """
        try:
            query = """
            SELECT 
                activity_id,
                customer_id,
                activity_type,
                activity_title,
                activity_description,
                activity_timestamp,
                channel,
                priority,
                transaction_amount
            FROM customer_activities
            WHERE activity_timestamp >= DATEADD('day', ?, CURRENT_TIMESTAMP())
            ORDER BY activity_timestamp DESC
            LIMIT 100
            """
            return _self.conn.query(query, params=[-days])
        except Exception as e:
            st.error(f"Error fetching activities: {str(e)}")
            return pd.DataFrame()
    
    def get_customer_activities(self, customer_id: str, limit: int = 20) -> pd.DataFrame:
        """
        Get activities for a specific customer
        
        Args:
            customer_id: Customer identifier
            limit: Maximum number of activities to return
            
        Returns:
            DataFrame with customer activities
        """
        try:
            query = """
            SELECT 
                activity_id,
                activity_type,
                activity_title,
                activity_description,
                activity_timestamp,
                channel,
                priority,
                transaction_amount,
                status
            FROM customer_activities
            WHERE customer_id = ?
            ORDER BY activity_timestamp DESC
            LIMIT ?
            """
            return self.conn.query(query, params=[customer_id, limit])
        except Exception as e:
            st.error(f"Error fetching customer activities: {str(e)}")
            return pd.DataFrame()
    
    def get_customer_purchases(self, customer_id: str, limit: int = 10) -> pd.DataFrame:
        """
        Get purchase history for a specific customer
        
        Args:
            customer_id: Customer identifier
            limit: Maximum number of purchases to return
            
        Returns:
            DataFrame with purchase history
        """
        try:
            query = """
            SELECT 
                purchase_id,
                order_id,
                purchase_date,
                product_name,
                product_category,
                quantity,
                unit_price,
                total_amount,
                order_status,
                payment_status
            FROM purchases
            WHERE customer_id = ?
            ORDER BY purchase_date DESC
            LIMIT ?
            """
            return self.conn.query(query, params=[customer_id, limit])
        except Exception as e:
            st.error(f"Error fetching customer purchases: {str(e)}")
            return pd.DataFrame()
    
    def get_customer_support_tickets(self, customer_id: str, limit: int = 10) -> pd.DataFrame:
        """
        Get support tickets for a specific customer
        
        Args:
            customer_id: Customer identifier
            limit: Maximum number of tickets to return
            
        Returns:
            DataFrame with support tickets
        """
        try:
            query = """
            SELECT 
                ticket_id,
                subject,
                category,
                priority,
                status,
                created_at,
                resolved_at,
                resolution_time_hours,
                customer_satisfaction_rating
            FROM support_tickets
            WHERE customer_id = ?
            ORDER BY created_at DESC
            LIMIT ?
            """
            return self.conn.query(query, params=[customer_id, limit])
        except Exception as e:
            st.error(f"Error fetching support tickets: {str(e)}")
            return pd.DataFrame()
    
    @st.cache_data(ttl=300)
    def get_analytics_data(_self) -> Dict[str, Any]:
        """
        Get analytics data for dashboards
        
        Returns:
            Dictionary with various analytics metrics
        """
        try:
            # Customer tier distribution
            tier_query = """
            SELECT customer_tier, COUNT(*) as count
            FROM customers
            GROUP BY customer_tier
            ORDER BY count DESC
            """
            tier_data = _self.conn.query(tier_query)
            
            # Churn risk distribution
            risk_query = """
            SELECT 
                CASE 
                    WHEN churn_risk_score > 0.7 THEN 'High Risk'
                    WHEN churn_risk_score > 0.3 THEN 'Medium Risk'
                    ELSE 'Low Risk'
                END as risk_category,
                COUNT(*) as count
            FROM customers
            GROUP BY risk_category
            """
            risk_data = _self.conn.query(risk_query)
            
            # Revenue by tier
            revenue_query = """
            SELECT 
                customer_tier,
                SUM(total_spent) as total_revenue,
                AVG(total_spent) as avg_revenue_per_customer,
                COUNT(*) as customer_count
            FROM customers
            GROUP BY customer_tier
            ORDER BY total_revenue DESC
            """
            revenue_data = _self.conn.query(revenue_query)
            
            # Activity trends (last 30 days)
            activity_query = """
            SELECT 
                DATE(activity_timestamp) as activity_date,
                activity_type,
                COUNT(*) as activity_count
            FROM customer_activities
            WHERE activity_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
            GROUP BY DATE(activity_timestamp), activity_type
            ORDER BY activity_date DESC, activity_count DESC
            """
            activity_data = _self.conn.query(activity_query)
            
            # Support metrics
            support_query = """
            SELECT 
                category,
                COUNT(*) as ticket_count,
                AVG(resolution_time_hours) as avg_resolution_time,
                AVG(customer_satisfaction_rating) as avg_satisfaction
            FROM support_tickets
            WHERE created_at >= DATEADD('day', -30, CURRENT_TIMESTAMP())
            GROUP BY category
            ORDER BY ticket_count DESC
            """
            support_data = _self.conn.query(support_query)
            
            return {
                'tier_distribution': tier_data,
                'risk_distribution': risk_data,
                'revenue_by_tier': revenue_data,
                'activity_trends': activity_data,
                'support_metrics': support_data
            }
            
        except Exception as e:
            st.error(f"Error fetching analytics data: {str(e)}")
            return {}
    
    def get_customer_metrics(self, customer_id: str) -> Dict[str, Any]:
        """
        Get comprehensive metrics for a specific customer
        
        Args:
            customer_id: Customer identifier
            
        Returns:
            Dictionary with customer metrics
        """
        try:
            # Basic customer info
            customer_query = """
            SELECT * FROM customers WHERE customer_id = ?
            """
            customer_data = self.conn.query(customer_query, params=[customer_id])
            
            if customer_data.empty:
                return {}
            
            customer = customer_data.iloc[0]
            
            # Activity metrics
            activity_query = """
            SELECT 
                COUNT(*) as total_activities,
                COUNT(DISTINCT activity_type) as activity_types,
                MAX(activity_timestamp) as last_activity,
                SUM(CASE WHEN activity_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP()) THEN 1 ELSE 0 END) as activities_last_30_days
            FROM customer_activities
            WHERE customer_id = ?
            """
            activity_metrics = self.conn.query(activity_query, params=[customer_id])
            
            # Purchase metrics
            purchase_query = """
            SELECT 
                COUNT(*) as total_purchases,
                SUM(total_amount) as total_spent,
                AVG(total_amount) as avg_order_value,
                MAX(purchase_date) as last_purchase_date
            FROM purchases
            WHERE customer_id = ?
            """
            purchase_metrics = self.conn.query(purchase_query, params=[customer_id])
            
            # Support metrics
            support_query = """
            SELECT 
                COUNT(*) as total_tickets,
                COUNT(CASE WHEN status = 'open' THEN 1 END) as open_tickets,
                AVG(customer_satisfaction_rating) as avg_support_satisfaction,
                AVG(resolution_time_hours) as avg_resolution_time
            FROM support_tickets
            WHERE customer_id = ?
            """
            support_metrics = self.conn.query(support_query, params=[customer_id])
            
            # Combine all metrics
            metrics = {
                'customer_info': customer.to_dict(),
                'activity_metrics': activity_metrics.iloc[0].to_dict() if not activity_metrics.empty else {},
                'purchase_metrics': purchase_metrics.iloc[0].to_dict() if not purchase_metrics.empty else {},
                'support_metrics': support_metrics.iloc[0].to_dict() if not support_metrics.empty else {}
            }
            
            return metrics
            
        except Exception as e:
            st.error(f"Error fetching customer metrics: {str(e)}")
            return {}
    
    def search_customers(self, search_term: str, filters: Optional[Dict] = None) -> pd.DataFrame:
        """
        Search customers by name, email, or other criteria
        
        Args:
            search_term: Search term
            filters: Optional filters (tier, status, etc.)
            
        Returns:
            DataFrame with matching customers
        """
        try:
            base_query = """
            SELECT 
                customer_id,
                first_name,
                last_name,
                email,
                customer_tier,
                account_status,
                total_spent,
                churn_risk_score
            FROM customers
            WHERE (
                LOWER(first_name) LIKE LOWER(?) OR
                LOWER(last_name) LIKE LOWER(?) OR
                LOWER(email) LIKE LOWER(?)
            )
            """
            
            params = [f"%{search_term}%", f"%{search_term}%", f"%{search_term}%"]
            
            # Add filters if provided
            if filters:
                if 'tier' in filters:
                    base_query += " AND customer_tier = ?"
                    params.append(filters['tier'])
                if 'status' in filters:
                    base_query += " AND account_status = ?"
                    params.append(filters['status'])
            
            base_query += " ORDER BY total_spent DESC LIMIT 20"
            
            return self.conn.query(base_query, params=params)
            
        except Exception as e:
            st.error(f"Error searching customers: {str(e)}")
            return pd.DataFrame()
    
    def get_high_risk_customers(self, threshold: float = 0.5) -> pd.DataFrame:
        """
        Get customers with high churn risk
        
        Args:
            threshold: Churn risk threshold
            
        Returns:
            DataFrame with high-risk customers
        """
        try:
            query = """
            SELECT 
                customer_id,
                first_name,
                last_name,
                customer_tier,
                churn_risk_score,
                satisfaction_score,
                total_spent,
                last_login_date
            FROM customers
            WHERE churn_risk_score >= ?
            ORDER BY churn_risk_score DESC
            """
            return self.conn.query(query, params=[threshold])
        except Exception as e:
            st.error(f"Error fetching high-risk customers: {str(e)}")
            return pd.DataFrame()
    
    def get_top_customers(self, limit: int = 10, metric: str = 'total_spent') -> pd.DataFrame:
        """
        Get top customers by specified metric
        
        Args:
            limit: Number of customers to return
            metric: Metric to sort by (total_spent, lifetime_value, etc.)
            
        Returns:
            DataFrame with top customers
        """
        try:
            valid_metrics = ['total_spent', 'lifetime_value', 'satisfaction_score', 'engagement_score']
            if metric not in valid_metrics:
                metric = 'total_spent'
            
            query = f"""
            SELECT 
                customer_id,
                first_name,
                last_name,
                customer_tier,
                {metric},
                total_spent,
                lifetime_value,
                satisfaction_score
            FROM customers
            ORDER BY {metric} DESC
            LIMIT ?
            """
            return self.conn.query(query, params=[limit])
        except Exception as e:
            st.error(f"Error fetching top customers: {str(e)}")
            return pd.DataFrame()
    
    @staticmethod
    def format_currency(amount: float) -> str:
        """Format amount as currency"""
        return f"${amount:,.2f}"
    
    @staticmethod
    def format_percentage(value: float) -> str:
        """Format value as percentage"""
        return f"{value:.1%}"
    
    @staticmethod
    def get_risk_color(risk_score: float) -> str:
        """Get color for risk score"""
        if risk_score >= 0.7:
            return "red"
        elif risk_score >= 0.3:
            return "orange"
        else:
            return "green"
    
    @staticmethod
    def get_tier_color(tier: str) -> str:
        """Get color for customer tier"""
        colors = {
            'platinum': '#ffd700',
            'gold': '#fbbf24',
            'silver': '#9ca3af',
            'bronze': '#92400e'
        }
        return colors.get(tier.lower(), '#6b7280')
    
    @staticmethod
    def calculate_days_since(date_value) -> int:
        """Calculate days since a given date"""
        if pd.isna(date_value):
            return 999
        if isinstance(date_value, str):
            date_obj = pd.to_datetime(date_value)
        else:
            date_obj = date_value
        return (datetime.now() - date_obj).days 