"""
AI Assistant Component for Customer 360 Demo

This component provides the chat interface for interacting with the Cortex Agent,
enabling natural language queries about customer data, insights, and recommendations.
"""

import streamlit as st
import json
from datetime import datetime

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
                    if message['role'] == 'user':
                        st.chat_message("user").write(message['content'])
                    else:
                        st.chat_message("assistant").write(message['content'])
                        
                        # If there's data or charts, display them
                        if 'data' in message:
                            st.dataframe(message['data'])
                        if 'chart' in message:
                            st.plotly_chart(message['chart'], use_container_width=True)
            
            # Chat input
            user_input = st.chat_input("Ask about customers, analytics, or insights...")
            
            if user_input:
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
                            'content': response.get('message', 'I apologize, but I encountered an issue processing your request.'),
                            'timestamp': datetime.now()
                        }
                        
                        # Add any additional data or charts
                        if 'data' in response:
                            ai_message['data'] = response['data']
                        if 'chart' in response:
                            ai_message['chart'] = response['chart']
                        
                        # Add to history and display
                        st.session_state.chat_history.append(ai_message)
                        st.chat_message("assistant").write(ai_message['content'])
                        
                        if 'data' in ai_message:
                            st.dataframe(ai_message['data'])
                        if 'chart' in ai_message:
                            st.plotly_chart(ai_message['chart'], use_container_width=True)
                            
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
            if st.button(query, key=f"suggested_{hash(query)}", use_container_width=True):
                # Simulate clicking the query
                st.session_state.pending_query = query
                st.rerun()
        
        # Handle pending query
        if hasattr(st.session_state, 'pending_query'):
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
                        'content': response.get('message', 'I apologize, but I encountered an issue processing your request.'),
                        'timestamp': datetime.now()
                    }
                    
                    if 'data' in response:
                        ai_message['data'] = response['data']
                    if 'chart' in response:
                        ai_message['chart'] = response['chart']
                    
                    st.session_state.chat_history.append(ai_message)
                    
                except Exception as e:
                    st.session_state.chat_history.append({
                        'role': 'assistant',
                        'content': f"I encountered an error: {str(e)}",
                        'timestamp': datetime.now()
                    })
        
        st.divider()
        
        # Customer-specific analysis
        st.subheader("👤 Customer Analysis")
        
        if st.session_state.selected_customer is not None:
            customer = st.session_state.selected_customer
            st.markdown(f"**Selected:** {customer['FIRST_NAME']} {customer['LAST_NAME']}")
            
            # Customer-specific quick actions
            customer_queries = [
                f"Analyze {customer['FIRST_NAME']} {customer['LAST_NAME']}'s profile",
                f"What's the churn risk for {customer['FIRST_NAME']}?",
                f"Show {customer['FIRST_NAME']}'s purchase history",
                f"Find support tickets for {customer['FIRST_NAME']}",
                f"What opportunities exist with {customer['FIRST_NAME']}?"
            ]
            
            for query in customer_queries:
                if st.button(query, key=f"customer_{hash(query)}", use_container_width=True):
                    st.session_state.pending_query = query
                    st.rerun()
        else:
            st.info("Select a customer from the sidebar for personalized analysis")
        
        st.divider()
        
        # Chat controls
        st.subheader("⚙️ Chat Controls")
        
        if st.button("🗑️ Clear Chat History", use_container_width=True):
            st.session_state.chat_history = []
            st.rerun()
        
        if st.button("💾 Export Chat", use_container_width=True):
            if st.session_state.chat_history:
                chat_export = json.dumps(st.session_state.chat_history, default=str, indent=2)
                st.download_button(
                    "Download Chat History",
                    chat_export,
                    file_name=f"chat_history_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json",
                    mime="application/json"
                )
            else:
                st.warning("No chat history to export")
        
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