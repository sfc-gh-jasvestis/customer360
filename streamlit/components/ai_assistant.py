"""
AI Assistant Component for Customer 360 Demo

This component provides the chat interface for interacting with the Cortex Agent,
enabling natural language queries about customers, analytics, and business insights.
"""

import streamlit as st
import json
from datetime import datetime

# Helper functions for safe formatting
def safe_get_str(value, default="N/A"):
    """Safely get string value"""
    if value is None or pd.isna(value) if 'pd' in globals() else value is None:
        return default
    return str(value)

def render_ai_assistant():
    """Render the AI assistant chat interface"""
    
    st.header("🤖 AI Assistant")
    st.markdown("Ask me anything about your customers, analytics, or business insights!")
    
    # Create two columns for layout
    col1, col2 = st.columns([2, 1])
    
    with col1:
        # Chat interface
        st.subheader("💬 Chat with AI")
        
        # Chat container
        chat_container = st.container()
        
        with chat_container:
            # Display chat history
            if st.session_state.chat_history:
                for message in st.session_state.chat_history:
                    try:
                        if message.get('role') == 'user':
                            content = safe_get_str(message.get('content', ''), 'Message not available')
                            st.chat_message("user").write(content)
                        else:
                            content = safe_get_str(message.get('content', ''), 'Response not available')
                            st.chat_message("assistant").write(content)
                            
                            # If there's data or charts, display them
                            if 'data' in message and message['data'] is not None:
                                try:
                                    st.dataframe(message['data'])
                                except Exception as e:
                                    st.info(f"Could not display data: {str(e)}")
                            
                            if 'chart' in message and message['chart'] is not None:
                                try:
                                    st.plotly_chart(message['chart'], use_container_width=True)
                                except Exception as e:
                                    st.info(f"Could not display chart: {str(e)}")
                    except Exception as e:
                        st.error(f"Error displaying message: {str(e)}")
            
            # Chat input
            user_input = st.chat_input("Ask about customers, analytics, or insights...")
            
            if user_input:
                try:
                    # Add user message to history
                    st.session_state.chat_history.append({
                        'role': 'user',
                        'content': user_input,
                        'timestamp': datetime.now()
                    })
                    
                    # Display user message
                    st.chat_message("user").write(user_input)
                    
                    # Get AI response
                    with st.spinner("AI is thinking..."):
                        try:
                            response = st.session_state.cortex_client.ask_ai(user_input)
                            
                            # Parse response (assuming it returns structured data)
                            ai_message = {
                                'role': 'assistant',
                                'content': safe_get_str(response.get('message', ''), 'I apologize, but I encountered an issue processing your request.'),
                                'timestamp': datetime.now()
                            }
                            
                            # Add any additional data or charts
                            if 'data' in response and response['data'] is not None:
                                ai_message['data'] = response['data']
                            if 'chart' in response and response['chart'] is not None:
                                ai_message['chart'] = response['chart']
                            
                            # Add to history and display
                            st.session_state.chat_history.append(ai_message)
                            st.chat_message("assistant").write(ai_message['content'])
                            
                            if 'data' in ai_message:
                                try:
                                    st.dataframe(ai_message['data'])
                                except Exception as e:
                                    st.info(f"Could not display data: {str(e)}")
                            if 'chart' in ai_message:
                                try:
                                    st.plotly_chart(ai_message['chart'], use_container_width=True)
                                except Exception as e:
                                    st.info(f"Could not display chart: {str(e)}")
                                
                        except Exception as e:
                            error_message = f"I encountered an error: {str(e)}"
                            st.session_state.chat_history.append({
                                'role': 'assistant',
                                'content': error_message,
                                'timestamp': datetime.now()
                            })
                            st.chat_message("assistant").write(error_message)
                    
                    # Rerun to update the display
                    st.rerun()
                except Exception as e:
                    st.error(f"Error processing your request: {str(e)}")
    
    with col2:
        # Suggested queries and controls
        st.subheader("💡 Suggested Queries")
        
        # Quick action buttons
        suggested_queries = [
            "Show me high-value customers at risk of churning",
            "What are the most common support issues?",
            "Which customers haven't purchased in 30 days?",
            "Create a chart of revenue by customer tier",
            "Find customers with billing complaints",
            "What's our average customer satisfaction?",
            "Show purchase trends by product category",
            "Which customers are most engaged?",
            "Find opportunities for upselling",
            "What are our top customer retention risks?"
        ]
        
        for query in suggested_queries:
            try:
                query_hash = hash(query)
                if st.button(query, key=f"suggested_{query_hash}", use_container_width=True):
                    # Simulate clicking the query
                    st.session_state.pending_query = query
                    st.rerun()
            except Exception as e:
                st.error(f"Error with suggested query: {str(e)}")
        
        # Handle pending query
        if hasattr(st.session_state, 'pending_query'):
            try:
                query = st.session_state.pending_query
                delattr(st.session_state, 'pending_query')
                
                # Add to chat history and get response
                st.session_state.chat_history.append({
                    'role': 'user',
                    'content': query,
                    'timestamp': datetime.now()
                })
                
                with st.spinner("AI is thinking..."):
                    try:
                        response = st.session_state.cortex_client.ask_ai(query)
                        ai_message = {
                            'role': 'assistant',
                            'content': safe_get_str(response.get('message', ''), 'I apologize, but I encountered an issue processing your request.'),
                            'timestamp': datetime.now()
                        }
                        
                        if 'data' in response and response['data'] is not None:
                            ai_message['data'] = response['data']
                        if 'chart' in response and response['chart'] is not None:
                            ai_message['chart'] = response['chart']
                        
                        st.session_state.chat_history.append(ai_message)
                        
                    except Exception as e:
                        st.session_state.chat_history.append({
                            'role': 'assistant',
                            'content': f"I encountered an error: {str(e)}",
                            'timestamp': datetime.now()
                        })
            except Exception as e:
                st.error(f"Error handling pending query: {str(e)}")
        
        st.divider()
        
        # Customer-specific analysis
        st.subheader("👤 Customer Analysis")
        
        try:
            if st.session_state.selected_customer is not None:
                customer = st.session_state.selected_customer
                first_name = safe_get_str(customer.get('FIRST_NAME', ''), 'Unknown')
                last_name = safe_get_str(customer.get('LAST_NAME', ''), 'Customer')
                st.markdown(f"**Selected:** {first_name} {last_name}")
                
                # Customer-specific quick actions
                customer_queries = [
                    f"Analyze {first_name} {last_name}'s profile",
                    f"What's the churn risk for {first_name}?",
                    f"Show {first_name}'s purchase history",
                    f"Find support tickets for {first_name}",
                    f"What opportunities exist with {first_name}?"
                ]
                
                for query in customer_queries:
                    try:
                        query_hash = hash(query)
                        if st.button(query, key=f"customer_{query_hash}", use_container_width=True):
                            st.session_state.pending_query = query
                            st.rerun()
                    except Exception as e:
                        st.error(f"Error with customer query: {str(e)}")
            else:
                st.info("Select a customer from the sidebar for personalized analysis")
        except Exception as e:
            st.error(f"Error in customer analysis section: {str(e)}")
        
        st.divider()
        
        # Chat controls
        st.subheader("⚙️ Chat Controls")
        
        try:
            if st.button("🗑️ Clear Chat History", use_container_width=True):
                st.session_state.chat_history = []
                st.rerun()
            
            if st.button("💾 Export Chat", use_container_width=True):
                if st.session_state.chat_history:
                    try:
                        chat_export = json.dumps(st.session_state.chat_history, default=str, indent=2)
                        st.download_button(
                            "Download Chat History",
                            chat_export,
                            file_name=f"chat_history_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json",
                            mime="application/json"
                        )
                    except Exception as e:
                        st.error(f"Error exporting chat: {str(e)}")
                else:
                    st.warning("No chat history to export")
        except Exception as e:
            st.error(f"Error with chat controls: {str(e)}")
        
        # AI capabilities info
        st.subheader("🧠 AI Capabilities")
        st.markdown("""
        **What I can help with:**
        - 📊 Customer analytics & insights
        - 🔍 Search customer documents
        - 📈 Generate charts & visualizations  
        - ⚠️ Identify risks & opportunities
        - 💡 Provide recommendations
        - 📋 Answer questions about data
        
        **Powered by:**
        - Cortex Analyst (Natural Language SQL)
        - Cortex Search (Document Search)
        - Cortex Agent (Multi-tool AI)
        """)

def get_sample_responses():
    """Get sample AI responses for demonstration"""
    return {
        "high_value_customers": {
            "message": "Here are your high-value customers at risk of churning:",
            "data": {
                "Customer": ["Sarah Johnson", "Michael Chen"],
                "Tier": ["Platinum", "Gold"], 
                "Total Spent": ["$47,580", "$23,451"],
                "Churn Risk": ["15%", "35%"],
                "Recommended Action": ["VIP retention offer", "Personal outreach call"]
            }
        },
        "support_issues": {
            "message": "The most common support issues are:",
            "data": {
                "Issue Type": ["Billing", "Shipping", "Technical", "Product"],
                "Count": [12, 8, 6, 4],
                "Avg Resolution Time": ["24 hours", "12 hours", "48 hours", "18 hours"]
            }
        }
    } 