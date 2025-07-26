"""
Cortex Client for Customer 360 Demo

This module provides a client interface for interacting with Snowflake Cortex services:
- Cortex Agents for AI assistance
- Cortex Search for document retrieval  
- Cortex Analyst for natural language queries
"""

import streamlit as st
import pandas as pd
import json
from typing import Dict, List, Optional, Any
import plotly.express as px
import plotly.graph_objects as go

class CortexClient:
    """Client for interacting with Snowflake Cortex services"""
    
    def __init__(self):
        """Initialize Cortex client with Snowflake connection"""
        self.conn = st.connection("snowflake")
        
    def ask_ai(self, question: str, customer_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Ask the Cortex Agent a question and return structured response
        
        Args:
            question: Natural language question
            customer_id: Optional customer ID for context
            
        Returns:
            Dict containing message, data, and optional chart
        """
        try:
            # Use the Cortex Agent function we created
            if customer_id:
                # For customer-specific queries, use the analyze_customer function
                result = self.conn.query(
                    "SELECT analyze_customer(?, 'overview') as response",
                    params=[customer_id]
                )
            else:
                # For general queries, use the main AI assistant
                result = self.conn.query(
                    "SELECT ask_customer_360_ai(?) as response",
                    params=[question]
                )
            
            if not result.empty:
                response_data = result.iloc[0]['RESPONSE']
                return self._parse_ai_response(response_data, question)
            else:
                return {
                    "message": "I'm sorry, I couldn't process your request at this time.",
                    "data": None,
                    "chart": None
                }
                
        except Exception as e:
            st.error(f"Error communicating with AI: {str(e)}")
            return self._get_fallback_response(question, customer_id)
    
    def search_documents(self, query: str, filters: Optional[Dict] = None) -> List[Dict]:
        """
        Search customer documents using Cortex Search
        
        Args:
            query: Search query
            filters: Optional filters (customer_tier, document_type, etc.)
            
        Returns:
            List of search results
        """
        try:
            # Build the search query
            if filters:
                filter_clause = ", ".join([f"'{k}': '{v}'" for k, v in filters.items()])
                sql = f"""
                SELECT * FROM TABLE(
                    CORTEX_SEARCH(
                        'customer_documents_search',
                        ?,
                        {{{filter_clause}}}
                    )
                ) LIMIT 10
                """
            else:
                sql = """
                SELECT * FROM TABLE(
                    CORTEX_SEARCH(
                        'customer_documents_search',
                        ?
                    )
                ) LIMIT 10
                """
            
            result = self.conn.query(sql, params=[query])
            return result.to_dict('records') if not result.empty else []
            
        except Exception as e:
            st.error(f"Error searching documents: {str(e)}")
            return []
    
    def analyze_customer(self, customer_id: str, analysis_type: str = "overview") -> Dict[str, Any]:
        """
        Get AI analysis for a specific customer
        
        Args:
            customer_id: Customer identifier
            analysis_type: Type of analysis (overview, churn_risk, opportunities, etc.)
            
        Returns:
            AI analysis response
        """
        try:
            result = self.conn.query(
                "SELECT analyze_customer(?, ?) as response",
                params=[customer_id, analysis_type]
            )
            
            if not result.empty:
                response_data = result.iloc[0]['RESPONSE']
                return self._parse_ai_response(response_data, f"Customer {customer_id} analysis")
            else:
                return {"message": f"Could not analyze customer {customer_id}"}
                
        except Exception as e:
            st.error(f"Error analyzing customer: {str(e)}")
            return {"message": f"Error analyzing customer {customer_id}: {str(e)}"}
    
    def get_customer_insights(self, customer_tier: Optional[str] = None) -> Dict[str, Any]:
        """
        Get insights about customers
        
        Args:
            customer_tier: Optional tier filter
            
        Returns:
            Customer insights
        """
        try:
            result = self.conn.query(
                "SELECT get_customer_insights(?) as response",
                params=[customer_tier]
            )
            
            if not result.empty:
                response_data = result.iloc[0]['RESPONSE']
                return self._parse_ai_response(response_data, "Customer insights")
            else:
                return {"message": "Could not generate customer insights"}
                
        except Exception as e:
            return {"message": f"Error getting insights: {str(e)}"}
    
    def analyze_support_trends(self) -> Dict[str, Any]:
        """Get support trend analysis"""
        try:
            result = self.conn.query("SELECT analyze_support_trends() as response")
            
            if not result.empty:
                response_data = result.iloc[0]['RESPONSE']
                return self._parse_ai_response(response_data, "Support trends")
            else:
                return {"message": "Could not analyze support trends"}
                
        except Exception as e:
            return {"message": f"Error analyzing support trends: {str(e)}"}
    
    def analyze_revenue_opportunities(self) -> Dict[str, Any]:
        """Get revenue opportunity analysis"""
        try:
            result = self.conn.query("SELECT analyze_revenue_opportunities() as response")
            
            if not result.empty:
                response_data = result.iloc[0]['RESPONSE']
                return self._parse_ai_response(response_data, "Revenue opportunities")
            else:
                return {"message": "Could not analyze revenue opportunities"}
                
        except Exception as e:
            return {"message": f"Error analyzing revenue opportunities: {str(e)}"}
    
    def _parse_ai_response(self, response_data: Any, context: str) -> Dict[str, Any]:
        """
        Parse AI response and extract structured data
        
        Args:
            response_data: Raw response from Cortex Agent
            context: Context of the query
            
        Returns:
            Structured response with message, data, and charts
        """
        try:
            # If response_data is a string, try to parse as JSON
            if isinstance(response_data, str):
                try:
                    parsed = json.loads(response_data)
                    return {
                        "message": parsed.get("message", response_data),
                        "data": parsed.get("data"),
                        "chart": self._create_chart_if_needed(parsed.get("data"), context)
                    }
                except json.JSONDecodeError:
                    return {
                        "message": response_data,
                        "data": None,
                        "chart": None
                    }
            
            # If it's already a dict/object
            elif hasattr(response_data, 'get'):
                return {
                    "message": response_data.get("message", str(response_data)),
                    "data": response_data.get("data"),
                    "chart": self._create_chart_if_needed(response_data.get("data"), context)
                }
            
            # Fallback
            else:
                return {
                    "message": str(response_data),
                    "data": None,
                    "chart": None
                }
                
        except Exception as e:
            return {
                "message": f"Generated response for: {context}",
                "data": None,
                "chart": None
            }
    
    def _create_chart_if_needed(self, data: Any, context: str) -> Optional[go.Figure]:
        """
        Create a chart if the data is suitable for visualization
        
        Args:
            data: Data to potentially chart
            context: Context to determine chart type
            
        Returns:
            Plotly figure or None
        """
        if not data or not isinstance(data, (list, dict)):
            return None
        
        try:
            # Convert to DataFrame if possible
            if isinstance(data, list) and len(data) > 0:
                if isinstance(data[0], dict):
                    df = pd.DataFrame(data)
                else:
                    return None
            elif isinstance(data, dict):
                df = pd.DataFrame([data])
            else:
                return None
            
            # Determine chart type based on context and data
            if "trend" in context.lower() or "time" in context.lower():
                return self._create_time_series_chart(df)
            elif "tier" in context.lower() or "category" in context.lower():
                return self._create_category_chart(df)
            elif "risk" in context.lower() or "score" in context.lower():
                return self._create_scatter_chart(df)
            else:
                return self._create_bar_chart(df)
                
        except Exception:
            return None
    
    def _create_time_series_chart(self, df: pd.DataFrame) -> go.Figure:
        """Create a time series chart"""
        date_cols = [col for col in df.columns if 'date' in col.lower() or 'time' in col.lower()]
        value_cols = [col for col in df.columns if df[col].dtype in ['int64', 'float64']]
        
        if date_cols and value_cols:
            fig = px.line(df, x=date_cols[0], y=value_cols[0], title="Trend Analysis")
            return fig
        return None
    
    def _create_category_chart(self, df: pd.DataFrame) -> go.Figure:
        """Create a category chart (pie or bar)"""
        text_cols = [col for col in df.columns if df[col].dtype == 'object']
        value_cols = [col for col in df.columns if df[col].dtype in ['int64', 'float64']]
        
        if text_cols and value_cols:
            if len(df) <= 5:  # Pie chart for small datasets
                fig = px.pie(df, names=text_cols[0], values=value_cols[0], title="Distribution")
            else:  # Bar chart for larger datasets
                fig = px.bar(df, x=text_cols[0], y=value_cols[0], title="Category Analysis")
            return fig
        return None
    
    def _create_scatter_chart(self, df: pd.DataFrame) -> go.Figure:
        """Create a scatter chart"""
        numeric_cols = [col for col in df.columns if df[col].dtype in ['int64', 'float64']]
        
        if len(numeric_cols) >= 2:
            fig = px.scatter(df, x=numeric_cols[0], y=numeric_cols[1], title="Correlation Analysis")
            return fig
        return None
    
    def _create_bar_chart(self, df: pd.DataFrame) -> go.Figure:
        """Create a simple bar chart"""
        if len(df.columns) >= 2:
            fig = px.bar(df, x=df.columns[0], y=df.columns[1], title="Data Analysis")
            return fig
        return None
    
    def _get_fallback_response(self, question: str, customer_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Provide fallback responses when Cortex services are unavailable
        
        Args:
            question: The original question
            customer_id: Optional customer ID
            
        Returns:
            Fallback response
        """
        fallback_responses = {
            "churn": {
                "message": "Based on our analysis, customers with high churn risk typically show: decreased login frequency, support ticket escalations, and low satisfaction scores. I recommend immediate outreach for customers with risk scores above 0.7.",
                "data": [
                    {"Risk Level": "High", "Count": 3, "Action": "Immediate outreach"},
                    {"Risk Level": "Medium", "Count": 8, "Action": "Proactive engagement"}, 
                    {"Risk Level": "Low", "Count": 15, "Action": "Standard nurturing"}
                ]
            },
            "revenue": {
                "message": "Revenue opportunities include: upselling premium features to gold customers, cross-selling complementary products, and expanding successful pilot programs.",
                "data": [
                    {"Opportunity": "Premium Upsell", "Potential": "$45,000", "Probability": "70%"},
                    {"Opportunity": "Cross-sell", "Potential": "$23,000", "Probability": "85%"},
                    {"Opportunity": "Expansion", "Potential": "$67,000", "Probability": "60%"}
                ]
            },
            "support": {
                "message": "Support trends show billing issues as the top category, followed by shipping delays. Average resolution time is 18 hours with 4.2/5 satisfaction.",
                "data": [
                    {"Issue Type": "Billing", "Count": 12, "Avg Resolution": "24 hours"},
                    {"Issue Type": "Shipping", "Count": 8, "Avg Resolution": "12 hours"},
                    {"Issue Type": "Technical", "Count": 5, "Avg Resolution": "36 hours"}
                ]
            }
        }
        
        # Simple keyword matching for fallback
        question_lower = question.lower()
        if any(word in question_lower for word in ["churn", "risk", "leaving"]):
            return fallback_responses["churn"]
        elif any(word in question_lower for word in ["revenue", "money", "opportunity", "upsell"]):
            return fallback_responses["revenue"]
        elif any(word in question_lower for word in ["support", "ticket", "issue", "problem"]):
            return fallback_responses["support"]
        else:
            return {
                "message": f"I understand you're asking about: {question}. While I'm currently connecting to our AI services, I can help you explore customer data through the dashboard and analytics views.",
                "data": None,
                "chart": None
            } 