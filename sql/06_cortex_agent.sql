-- =========================================
-- Cortex Agent Configuration
-- =========================================

USE DATABASE customer_360_db;
USE SCHEMA public;

-- First, upload the semantic model file to a stage
-- Note: In practice, you would upload the YAML file using Snowsight or SnowSQL
-- For this demo, we'll create the stage and reference the file

-- Create stage for semantic model file
CREATE OR REPLACE STAGE customer_360_semantic_model_stage;

-- Upload semantic model (this would be done via UI or SnowSQL in practice)  
-- PUT file://sql/05_semantic_model.yaml @customer_360_semantic_model_stage;

-- Create the Cortex Agent with multiple tools
CREATE OR REPLACE CORTEX AGENT customer_360_ai_assistant (
    -- Agent configuration
    INSTRUCTIONS = 'You are a Customer 360 AI Assistant. You help analyze customer data, provide insights, and answer questions about customer behavior, churn risk, purchasing patterns, and support issues. 

Key capabilities:
- Analyze customer data using natural language queries
- Search through customer documents and transcripts
- Generate insights about customer behavior and risks
- Create visualizations of customer metrics
- Provide actionable recommendations

When responding:
- Be helpful and specific in your analysis
- Include relevant data and metrics when available
- Suggest actionable next steps when appropriate
- Reference specific customers by name when relevant
- Highlight any urgent issues or opportunities

Always maintain customer privacy and provide accurate, data-driven insights.'
) AS (
    -- Tool 1: Cortex Analyst for natural language to SQL
    'cortex_analyst_text_to_sql' (
        semantic_model_file => '@customer_360_semantic_model_stage/05_semantic_model.yaml'
    ),
    
    -- Tool 2: Cortex Search for document search
    'cortex_search' (
        service_name => 'customer_documents_search',
        max_results => 10,
        filters => {'customer_tier', 'document_type', 'document_category'}
    ),
    
    -- Tool 3: SQL execution
    'sql_exec' (),
    
    -- Tool 4: Data to chart generation
    'data_to_chart' ()
);

-- Grant usage on the agent
-- GRANT USAGE ON CORTEX AGENT customer_360_ai_assistant TO ROLE your_role;

-- Create helper function to interact with the agent
CREATE OR REPLACE FUNCTION ask_customer_360_ai(user_message STRING)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT CORTEX_AGENT_RUN('customer_360_ai_assistant', user_message)
$$;

-- Create a more specific function for customer analysis
CREATE OR REPLACE FUNCTION analyze_customer(customer_id STRING, analysis_type STRING DEFAULT 'overview')
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT CORTEX_AGENT_RUN(
        'customer_360_ai_assistant', 
        CASE 
            WHEN analysis_type = 'overview' THEN 
                CONCAT('Provide a comprehensive overview and analysis of customer ', customer_id, '. Include their profile, recent activities, purchase history, support tickets, and any risk factors or opportunities.')
            WHEN analysis_type = 'churn_risk' THEN
                CONCAT('Analyze the churn risk for customer ', customer_id, '. What factors contribute to their risk level and what actions should we take?')
            WHEN analysis_type = 'opportunities' THEN
                CONCAT('What opportunities exist with customer ', customer_id, '? Look at upselling, cross-selling, and engagement possibilities.')
            WHEN analysis_type = 'support_issues' THEN
                CONCAT('Analyze the support history for customer ', customer_id, '. Are there any patterns or recurring issues?')
            ELSE
                CONCAT('Analyze customer ', customer_id, ' from the perspective of: ', analysis_type)
        END
    )
$$;

-- Test the agent with sample queries (run after setup is complete)
/*
-- Test basic functionality
SELECT ask_customer_360_ai('How many customers do we have in total?');

-- Test customer analysis
SELECT analyze_customer('CUST_001', 'overview');

-- Test churn risk analysis
SELECT ask_customer_360_ai('Which customers are at highest risk of churning and why?');

-- Test search functionality
SELECT ask_customer_360_ai('Find any documents related to billing issues or customer complaints');

-- Test analytics
SELECT ask_customer_360_ai('Show me revenue trends by customer tier over the last 6 months');

-- Test visualization
SELECT ask_customer_360_ai('Create a chart showing customer satisfaction scores by tier');
*/

-- Create additional helper functions for common use cases

-- Function for getting customer insights
CREATE OR REPLACE FUNCTION get_customer_insights(customer_tier STRING DEFAULT NULL)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT CORTEX_AGENT_RUN(
        'customer_360_ai_assistant',
        CASE 
            WHEN customer_tier IS NOT NULL THEN
                CONCAT('Provide insights about our ', customer_tier, ' tier customers. What are their characteristics, behaviors, and how can we better serve them?')
            ELSE
                'Provide overall insights about our customer base. What patterns do you see in behavior, satisfaction, and value segments?'
        END
    )
$$;

-- Function for support analysis
CREATE OR REPLACE FUNCTION analyze_support_trends()
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT CORTEX_AGENT_RUN(
        'customer_360_ai_assistant',
        'Analyze our support ticket trends. What are the most common issues, which teams handle them best, and how can we improve resolution times and customer satisfaction?'
    )
$$;

-- Function for revenue analysis
CREATE OR REPLACE FUNCTION analyze_revenue_opportunities()
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT CORTEX_AGENT_RUN(
        'customer_360_ai_assistant',
        'Analyze revenue opportunities in our customer base. Which segments show growth potential, what upselling opportunities exist, and how can we increase customer lifetime value?'
    )
$$;

-- Function for searching customer documents
CREATE OR REPLACE FUNCTION search_customer_context(search_query STRING, customer_filter STRING DEFAULT NULL)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
    SELECT CORTEX_AGENT_RUN(
        'customer_360_ai_assistant',
        CASE 
            WHEN customer_filter IS NOT NULL THEN
                CONCAT('Search for documents related to "', search_query, '" specifically for ', customer_filter, ' tier customers. Summarize what you find.')
            ELSE
                CONCAT('Search for documents related to "', search_query, '". What patterns or insights do you see?')
        END
    )
$$;

-- Show created agent
DESCRIBE CORTEX AGENT customer_360_ai_assistant;

-- Verify setup
SELECT 'Cortex Agent created successfully' AS status,
       'Agent: customer_360_ai_assistant is ready for use' AS details,
       'Tools: cortex_analyst_text_to_sql, cortex_search, sql_exec, data_to_chart' AS tools_enabled; 