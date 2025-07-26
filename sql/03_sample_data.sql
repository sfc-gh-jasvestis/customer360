-- =========================================
-- Customer 360 Demo - Sample Data
-- =========================================

USE DATABASE customer_360_db;
USE SCHEMA public;

-- ===============================
-- Sample Customer Data
-- ===============================

INSERT INTO customers (
    customer_id, first_name, last_name, email, phone, date_of_birth, gender,
    street_address, city, state_province, postal_code, country,
    account_status, customer_tier, join_date, last_login_date,
    total_spent, lifetime_value, credit_limit,
    churn_risk_score, satisfaction_score, engagement_score,
    preferred_communication_channel, marketing_opt_in, newsletter_subscription,
    customer_tags
) VALUES
-- High-value platinum customer
('CUST_001', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '+1-555-0123', '1985-03-15', 'Female',
 '123 Market St', 'San Francisco', 'CA', '94102', 'USA',
 'active', 'platinum', '2022-01-15', CURRENT_TIMESTAMP() - INTERVAL '2 hours',
 47580.50, 65000.00, 50000.00,
 0.15, 4.8, 0.92,
 'email', TRUE, TRUE,
 '["high-value", "tech-enthusiast", "early-adopter", "loyal-customer"]'::VARIANT),

-- Medium-value gold customer with some risk
('CUST_002', 'Michael', 'Chen', 'michael.chen@email.com', '+1-555-0456', '1978-07-22', 'Male',
 '456 Broadway', 'New York', 'NY', '10013', 'USA',
 'active', 'gold', '2022-08-10', CURRENT_TIMESTAMP() - INTERVAL '1 day',
 23450.75, 35000.00, 25000.00,
 0.35, 4.2, 0.68,
 'sms', TRUE, FALSE,
 '["frequent-buyer", "mobile-user", "price-sensitive"]'::VARIANT),

-- At-risk customer requiring attention
('CUST_003', 'Emma', 'Davis', 'emma.davis@email.com', '+1-555-0789', '1990-11-08', 'Female',
 '789 Oak Ave', 'Austin', 'TX', '78701', 'USA',
 'active', 'silver', '2023-02-20', CURRENT_TIMESTAMP() - INTERVAL '10 days',
 8920.25, 15000.00, 10000.00,
 0.78, 3.1, 0.42,
 'email', FALSE, FALSE,
 '["at-risk", "support-needed", "occasional-buyer"]'::VARIANT),

-- New customer with high potential
('CUST_004', 'James', 'Wilson', 'james.wilson@email.com', '+1-555-0321', '1982-05-30', 'Male',
 '321 Pine St', 'Seattle', 'WA', '98101', 'USA',
 'active', 'bronze', '2024-01-05', CURRENT_TIMESTAMP() - INTERVAL '3 hours',
 1580.99, 5000.00, 5000.00,
 0.25, 4.5, 0.78,
 'phone', TRUE, TRUE,
 '["new-customer", "onboarding", "high-potential"]'::VARIANT),

-- Enterprise customer
('CUST_005', 'Lisa', 'Rodriguez', 'lisa.rodriguez@enterprise.com', '+1-555-0987', '1975-09-12', 'Female',
 '555 Enterprise Blvd', 'Los Angeles', 'CA', '90210', 'USA',
 'active', 'platinum', '2021-06-01', CURRENT_TIMESTAMP() - INTERVAL '6 hours',
 125000.00, 200000.00, 100000.00,
 0.08, 4.9, 0.95,
 'email', TRUE, TRUE,
 '["enterprise", "vip", "decision-maker", "high-value"]'::VARIANT);

-- ===============================
-- Sample Customer Activities
-- ===============================

INSERT INTO customer_activities (
    activity_id, customer_id, activity_type, activity_title, activity_description,
    activity_timestamp, channel, device_type, ip_address,
    transaction_amount, transaction_currency, product_category,
    priority, status, activity_metadata
) VALUES
-- Sarah Johnson activities (high engagement)
('ACT_001', 'CUST_001', 'purchase', 'Premium Software License', 'Purchased annual enterprise software license',
 CURRENT_TIMESTAMP() - INTERVAL '2 hours', 'web', 'desktop', '192.168.1.100',
 2999.99, 'USD', 'software',
 'high', 'completed', '{"order_id": "ORD_2024_001", "payment_method": "credit_card"}'::VARIANT),

('ACT_002', 'CUST_001', 'login', 'Account Login', 'Logged into customer portal',
 CURRENT_TIMESTAMP() - INTERVAL '3 hours', 'web', 'desktop', '192.168.1.100',
 NULL, NULL, NULL,
 'low', 'completed', '{"session_duration": 1200}'::VARIANT),

('ACT_003', 'CUST_001', 'email_open', 'Newsletter Opened', 'Opened monthly product newsletter',
 CURRENT_TIMESTAMP() - INTERVAL '1 day', 'email', 'mobile', NULL,
 NULL, NULL, NULL,
 'low', 'completed', '{"campaign_id": "CAMP_2024_001", "open_time": 15}'::VARIANT),

-- Michael Chen activities (moderate engagement with recent inactivity)
('ACT_004', 'CUST_002', 'cart_abandonment', 'Cart Abandoned', 'Added items to cart but did not complete purchase',
 CURRENT_TIMESTAMP() - INTERVAL '2 days', 'mobile', 'smartphone', '10.0.1.50',
 450.75, 'USD', 'electronics',
 'medium', 'abandoned', '{"cart_value": 450.75, "items_count": 3}'::VARIANT),

('ACT_005', 'CUST_002', 'support_chat', 'Chat Support', 'Initiated chat about shipping delays',
 CURRENT_TIMESTAMP() - INTERVAL '3 days', 'web', 'desktop', '10.0.1.50',
 NULL, NULL, NULL,
 'high', 'resolved', '{"agent_id": "AGT_001", "resolution_time": 15}'::VARIANT),

-- Emma Davis activities (declining engagement - at risk)
('ACT_006', 'CUST_003', 'login', 'Account Login', 'Last login to account',
 CURRENT_TIMESTAMP() - INTERVAL '10 days', 'mobile', 'smartphone', '172.16.1.20',
 NULL, NULL, NULL,
 'low', 'completed', '{"session_duration": 300}'::VARIANT),

('ACT_007', 'CUST_003', 'email_unsubscribe', 'Email Unsubscribe', 'Unsubscribed from marketing emails',
 CURRENT_TIMESTAMP() - INTERVAL '15 days', 'email', 'desktop', NULL,
 NULL, NULL, NULL,
 'high', 'completed', '{"reason": "too_frequent"}'::VARIANT),

-- James Wilson activities (new customer, high potential)
('ACT_008', 'CUST_004', 'account_creation', 'Account Created', 'New customer account registration',
 CURRENT_TIMESTAMP() - INTERVAL '25 days', 'web', 'desktop', '203.0.113.10',
 NULL, NULL, NULL,
 'medium', 'completed', '{"referral_source": "google_ads", "signup_time": 180}'::VARIANT),

('ACT_009', 'CUST_004', 'purchase', 'First Purchase', 'Completed first purchase - starter package',
 CURRENT_TIMESTAMP() - INTERVAL '20 days', 'web', 'desktop', '203.0.113.10',
 299.99, 'USD', 'subscription',
 'high', 'completed', '{"order_id": "ORD_2024_002", "discount_applied": 50.00}'::VARIANT),

('ACT_010', 'CUST_004', 'product_review', 'Product Review', 'Left 5-star review for starter package',
 CURRENT_TIMESTAMP() - INTERVAL '18 days', 'web', 'mobile', '203.0.113.10',
 NULL, NULL, 'subscription',
 'medium', 'completed', '{"rating": 5, "review_length": 150}'::VARIANT),

-- Lisa Rodriguez activities (enterprise customer)
('ACT_011', 'CUST_005', 'contract_renewal', 'Contract Renewal', 'Renewed enterprise contract for 2 years',
 CURRENT_TIMESTAMP() - INTERVAL '1 month', 'phone', NULL, NULL,
 50000.00, 'USD', 'enterprise_services',
 'high', 'completed', '{"contract_id": "CONT_2024_001", "renewal_period": 24}'::VARIANT);

-- ===============================
-- Sample Support Tickets
-- ===============================

INSERT INTO support_tickets (
    ticket_id, customer_id, subject, description, category, priority, status,
    assigned_agent_id, assigned_team, created_at, updated_at,
    first_response_at, resolved_at, resolution_time_hours,
    customer_satisfaction_rating, ticket_metadata
) VALUES
-- Open urgent ticket for Michael Chen
('TKT_001', 'CUST_002', 'Shipping Delay for Order #12345', 
 'My order was supposed to arrive 3 days ago. I need this for an important presentation. Please provide status update.',
 'shipping', 'high', 'in_progress',
 'AGT_001', 'logistics', CURRENT_TIMESTAMP() - INTERVAL '2 days',
 CURRENT_TIMESTAMP() - INTERVAL '1 hour',
 CURRENT_TIMESTAMP() - INTERVAL '1 day 18 hours', NULL, NULL, NULL,
 '{"escalated": true, "sla_breach": false}'::VARIANT),

-- Recently resolved ticket for Sarah Johnson
('TKT_002', 'CUST_001', 'Feature Request - API Integration',
 'Would like to integrate our system with your new API. Need documentation and implementation guidance.',
 'technical', 'medium', 'resolved',
 'AGT_002', 'technical_support', CURRENT_TIMESTAMP() - INTERVAL '1 week',
 CURRENT_TIMESTAMP() - INTERVAL '2 days',
 CURRENT_TIMESTAMP() - INTERVAL '6 days', CURRENT_TIMESTAMP() - INTERVAL '2 days',
 120, 5,
 '{"solution_provided": true, "follow_up_scheduled": true}'::VARIANT),

-- Historical ticket for Emma Davis (contributing to churn risk)
('TKT_003', 'CUST_003', 'Billing Issue - Incorrect Charges',
 'I was charged twice for my subscription. This is the third time this has happened. Very frustrated.',
 'billing', 'high', 'closed',
 'AGT_003', 'billing', CURRENT_TIMESTAMP() - INTERVAL '3 weeks',
 CURRENT_TIMESTAMP() - INTERVAL '2 weeks',
 CURRENT_TIMESTAMP() - INTERVAL '2 weeks 5 days', CURRENT_TIMESTAMP() - INTERVAL '2 weeks',
 168, 2,
 '{"refund_issued": true, "account_notes": "recurring_billing_issues"}'::VARIANT);

-- ===============================
-- Sample Purchases
-- ===============================

INSERT INTO purchases (
    purchase_id, customer_id, order_id, purchase_date,
    product_id, product_name, product_category, product_subcategory,
    quantity, unit_price, total_amount, discount_amount, tax_amount,
    shipping_address, shipping_method, tracking_number,
    order_status, payment_status, fulfillment_status,
    purchase_metadata
) VALUES
-- Sarah Johnson's recent high-value purchase
('PUR_001', 'CUST_001', 'ORD_2024_001', CURRENT_TIMESTAMP() - INTERVAL '2 hours',
 'PROD_ENT_001', 'Enterprise Software License - Annual', 'software', 'enterprise_tools',
 1, 2999.99, 2999.99, 0.00, 239.99,
 '123 Market St, San Francisco, CA 94102', 'digital_delivery', NULL,
 'completed', 'paid', 'delivered',
 '{"license_key": "ENT-2024-001", "auto_renewal": true}'::VARIANT),

-- Michael Chen's purchase history
('PUR_002', 'CUST_002', 'ORD_2024_002', CURRENT_TIMESTAMP() - INTERVAL '2 months',
 'PROD_STD_001', 'Standard Package - Monthly', 'subscription', 'software_tools',
 1, 99.99, 99.99, 10.00, 7.99,
 '456 Broadway, New York, NY 10013', 'digital_delivery', NULL,
 'completed', 'paid', 'delivered',
 '{"subscription_id": "SUB_2024_002", "billing_cycle": "monthly"}'::VARIANT),

-- James Wilson's first purchase (new customer)
('PUR_003', 'CUST_004', 'ORD_2024_003', CURRENT_TIMESTAMP() - INTERVAL '20 days',
 'PROD_STR_001', 'Starter Package', 'subscription', 'basic_tools',
 1, 299.99, 299.99, 50.00, 23.99,
 '321 Pine St, Seattle, WA 98101', 'standard_shipping', 'TRK_2024_003',
 'completed', 'paid', 'delivered',
 '{"first_purchase": true, "welcome_discount": 50.00}'::VARIANT),

-- Lisa Rodriguez's enterprise contract renewal
('PUR_004', 'CUST_005', 'ORD_2024_004', CURRENT_TIMESTAMP() - INTERVAL '1 month',
 'PROD_ENT_002', 'Enterprise Services Contract - 2 Year', 'enterprise_services', 'professional_services',
 1, 50000.00, 50000.00, 5000.00, 0.00,
 '555 Enterprise Blvd, Los Angeles, CA 90210', 'contract_delivery', 'CONT_2024_001',
 'completed', 'paid', 'active',
 '{"contract_period": 24, "service_level": "premium", "dedicated_support": true}'::VARIANT);

-- ===============================
-- Sample Communications
-- ===============================

INSERT INTO customer_communications (
    communication_id, customer_id, communication_type, direction,
    subject, message_content, sent_at, delivered_at, opened_at, clicked_at,
    campaign_id, campaign_name, template_id, status, communication_metadata
) VALUES
-- Welcome email for new customer James
('COMM_001', 'CUST_004', 'email', 'outbound',
 'Welcome to Our Platform!', 'Thank you for joining us. Here are your next steps...',
 CURRENT_TIMESTAMP() - INTERVAL '25 days', CURRENT_TIMESTAMP() - INTERVAL '25 days',
 CURRENT_TIMESTAMP() - INTERVAL '24 days 20 hours', CURRENT_TIMESTAMP() - INTERVAL '24 days 18 hours',
 'CAMP_WELCOME_001', 'New Customer Welcome Series', 'TMPL_WELCOME_001',
 'clicked', '{"sequence_step": 1, "personalization": "high"}'::VARIANT),

-- Product newsletter for Sarah
('COMM_002', 'CUST_001', 'email', 'outbound',
 'Monthly Product Updates - January 2024', 'Discover new features and updates...',
 CURRENT_TIMESTAMP() - INTERVAL '1 week', CURRENT_TIMESTAMP() - INTERVAL '1 week',
 CURRENT_TIMESTAMP() - INTERVAL '6 days 18 hours', CURRENT_TIMESTAMP() - INTERVAL '6 days 16 hours',
 'CAMP_NEWSLETTER_001', 'Monthly Newsletter', 'TMPL_NEWSLETTER_001',
 'clicked', '{"engagement_score": 0.85, "time_reading": 180}'::VARIANT),

-- Support follow-up SMS for Michael
('COMM_003', 'CUST_002', 'sms', 'outbound',
 'Support Update', 'Your ticket #TKT_001 has been updated. Check your account for details.',
 CURRENT_TIMESTAMP() - INTERVAL '1 day', CURRENT_TIMESTAMP() - INTERVAL '1 day',
 NULL, NULL,
 NULL, NULL, 'TMPL_SUPPORT_SMS_001',
 'delivered', '{"ticket_id": "TKT_001", "auto_generated": true}'::VARIANT);

-- ===============================
-- Sample Customer Documents (for Cortex Search)
-- ===============================

INSERT INTO customer_documents (
    document_id, customer_id, document_title, document_type, document_content,
    document_category, document_tags, created_by, content_summary, key_topics
) VALUES
-- Support transcript for Michael Chen
('DOC_001', 'CUST_002', 'Chat Transcript - Shipping Inquiry', 'transcript',
 'Agent: Hello Michael, I see you''re asking about your order #12345. Let me check the status for you.
Customer: Yes, it was supposed to arrive 3 days ago and I have an important presentation.
Agent: I understand your concern. I see there was a delay at our shipping facility due to weather conditions. Your package is now in transit and should arrive by tomorrow morning.
Customer: This is frustrating. This has happened before with my orders.
Agent: I sincerely apologize for the inconvenience. I''ve escalated this to our logistics team to prevent future delays. I''m also adding a credit to your account for the inconvenience.
Customer: Thank you, I appreciate that. Can you confirm the delivery time?
Agent: Yes, it''s scheduled for delivery between 9 AM and 12 PM tomorrow. You''ll receive a tracking update shortly.',
 'support', '["shipping", "delay", "escalation", "credit"]'::VARIANT,
 'support_agent_001', 'Customer inquiry about delayed shipment with resolution and credit applied',
 '["shipping_delays", "customer_compensation", "service_recovery"]'::VARIANT),

-- Contract document for Lisa Rodriguez  
('DOC_002', 'CUST_005', 'Enterprise Service Agreement 2024', 'contract',
 'This Enterprise Service Agreement ("Agreement") is entered into between [Company] and Rodriguez Enterprises.
SERVICES: The Company will provide enterprise-level software solutions, including:
- 24/7 premium support with dedicated account manager
- Custom integration services
- Advanced analytics and reporting
- Priority feature development
- Quarterly business reviews
TERM: This agreement is effective for 24 months from January 1, 2024
PRICING: Annual fee of $50,000 with 10% discount for 2-year commitment
SERVICE LEVELS: 99.9% uptime guarantee, 4-hour response time for critical issues
The customer has expressed satisfaction with previous services and looks forward to expanded partnership.',
 'legal', '["enterprise", "contract", "premium_support", "SLA"]'::VARIANT,
 'account_manager_002', 'Two-year enterprise service agreement with premium support and SLA guarantees',
 '["enterprise_contract", "service_levels", "premium_support", "account_management"]'::VARIANT),

-- Customer feedback for Emma Davis
('DOC_003', 'CUST_003', 'Customer Feedback Survey Response', 'feedback',
 'Overall satisfaction: 3/5
What we did well: The product features are good when they work properly
What needs improvement: Billing has been a recurring issue. I''ve been double-charged multiple times and it takes forever to resolve. Customer service seems overwhelmed.
Likelihood to recommend: 2/5 - Until the billing issues are fixed, I cannot recommend this service
Additional comments: I''ve been a customer for over a year but considering switching providers due to these ongoing issues. The product itself is fine but the support experience has been poor.
Would you like a follow-up call: Yes, but only if someone can actually fix the billing problems permanently.',
 'feedback', '["billing_issues", "churn_risk", "service_problems"]'::VARIANT,
 'survey_system', 'Customer expresses dissatisfaction with billing issues and considering switching providers',
 '["customer_satisfaction", "billing_problems", "churn_risk", "service_improvement"]'::VARIANT),

-- Onboarding notes for James Wilson
('DOC_004', 'CUST_004', 'Customer Onboarding Call Notes', 'note',
 'Onboarding call with James Wilson - January 5, 2024
Customer Background: Small business owner, tech-savvy, found us through Google Ads
Business Needs: Looking for project management solution for team of 8 people
Budget: $300-500/month range
Integration Requirements: Needs to connect with Slack and Google Workspace
Timeline: Wants to be fully operational within 2 weeks
Concerns: Previous solution was too complex, wants something user-friendly
Opportunity: Mentioned potential for expansion to 15+ users if initial rollout successful
Next Steps: Scheduled training session for next week, assigned customer success manager
Notes: Very engaged customer, asked detailed questions, seems likely to succeed and expand',
 'onboarding', '["new_customer", "high_potential", "expansion_opportunity"]'::VARIANT,
 'customer_success_001', 'Onboarding call notes for new customer with high expansion potential',
 '["customer_onboarding", "business_requirements", "expansion_potential", "customer_success"]'::VARIANT);

-- ===============================
-- Verify Data Load
-- ===============================

SELECT 'Sample data loaded successfully' AS status,
       (SELECT COUNT(*) FROM customers) AS customers_count,
       (SELECT COUNT(*) FROM customer_activities) AS activities_count,
       (SELECT COUNT(*) FROM support_tickets) AS tickets_count,
       (SELECT COUNT(*) FROM purchases) AS purchases_count,
       (SELECT COUNT(*) FROM customer_communications) AS communications_count,
       (SELECT COUNT(*) FROM customer_documents) AS documents_count; 