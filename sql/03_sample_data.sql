-- =========================================
-- Customer 360 Demo - Complete Sample Data (Fixed)
-- =========================================

USE DATABASE customer_360_db;
USE SCHEMA public;

-- ===============================
-- Sample Customer Data
-- ===============================

-- Clear any existing data
DELETE FROM customer_documents WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');
DELETE FROM customer_communications WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');
DELETE FROM purchases WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');
DELETE FROM support_tickets WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');
DELETE FROM customer_activities WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');
DELETE FROM customers WHERE customer_id IN ('CUST_001', 'CUST_002', 'CUST_003', 'CUST_004', 'CUST_005');

-- Step 1: Insert customers WITHOUT JSON data
INSERT INTO customers (
    customer_id, first_name, last_name, email, phone, date_of_birth, gender,
    street_address, city, state_province, postal_code, country,
    account_status, customer_tier, join_date, last_login_date,
    total_spent, lifetime_value, credit_limit,
    churn_risk_score, satisfaction_score, engagement_score,
    preferred_communication_channel, marketing_opt_in, newsletter_subscription
) VALUES
('CUST_001', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '+1-555-0123', '1985-03-15', 'Female',
 '123 Market St', 'San Francisco', 'CA', '94102', 'USA',
 'active', 'platinum', '2022-01-15', '2024-01-15 10:00:00',
 47580.50, 65000.00, 50000.00,
 0.15, 4.8, 0.92,
 'email', TRUE, TRUE),

('CUST_002', 'Michael', 'Chen', 'michael.chen@email.com', '+1-555-0456', '1978-07-22', 'Male',
 '456 Broadway', 'New York', 'NY', '10013', 'USA',
 'active', 'gold', '2022-08-10', '2024-01-14 15:30:00',
 23450.75, 35000.00, 25000.00,
 0.35, 4.2, 0.68,
 'sms', TRUE, FALSE),

('CUST_003', 'Emma', 'Davis', 'emma.davis@email.com', '+1-555-0789', '1990-11-08', 'Female',
 '789 Oak Ave', 'Austin', 'TX', '78701', 'USA',
 'active', 'silver', '2023-02-20', '2024-01-05 08:15:00',
 8920.25, 15000.00, 10000.00,
 0.78, 3.1, 0.42,
 'email', FALSE, FALSE),

('CUST_004', 'James', 'Wilson', 'james.wilson@email.com', '+1-555-0321', '1982-05-30', 'Male',
 '321 Pine St', 'Seattle', 'WA', '98101', 'USA',
 'active', 'bronze', '2024-01-05', '2024-01-15 09:00:00',
 1580.99, 5000.00, 5000.00,
 0.25, 4.5, 0.78,
 'phone', TRUE, TRUE),

('CUST_005', 'Lisa', 'Rodriguez', 'lisa.rodriguez@enterprise.com', '+1-555-0987', '1975-09-12', 'Female',
 '555 Enterprise Blvd', 'Los Angeles', 'CA', '90210', 'USA',
 'active', 'platinum', '2021-06-01', '2024-01-15 06:00:00',
 125000.00, 200000.00, 100000.00,
 0.08, 4.9, 0.95,
 'email', TRUE, TRUE);

-- Step 2: Update customers with JSON tags
UPDATE customers SET customer_tags = PARSE_JSON('["high-value", "tech-enthusiast", "early-adopter", "loyal-customer"]') WHERE customer_id = 'CUST_001';
UPDATE customers SET customer_tags = PARSE_JSON('["frequent-buyer", "mobile-user", "price-sensitive"]') WHERE customer_id = 'CUST_002';
UPDATE customers SET customer_tags = PARSE_JSON('["at-risk", "support-needed", "occasional-buyer"]') WHERE customer_id = 'CUST_003';
UPDATE customers SET customer_tags = PARSE_JSON('["new-customer", "onboarding", "high-potential"]') WHERE customer_id = 'CUST_004';
UPDATE customers SET customer_tags = PARSE_JSON('["enterprise", "vip", "decision-maker", "high-value"]') WHERE customer_id = 'CUST_005';

-- ===============================
-- Sample Customer Activities
-- ===============================

-- Step 1: Insert activities WITHOUT JSON data
INSERT INTO customer_activities (
    activity_id, customer_id, activity_type, activity_title, activity_description,
    activity_timestamp, channel, device_type, ip_address,
    transaction_amount, transaction_currency, product_category,
    priority, status
) VALUES
('ACT_001', 'CUST_001', 'purchase', 'Premium Software License', 'Purchased annual premium license with advanced features',
 '2024-01-15 08:00:00', 'web', 'desktop', '192.168.1.100',
 2499.99, 'USD', 'Software',
 'high', 'completed'),

('ACT_002', 'CUST_001', 'login', 'Dashboard Access', 'User logged into customer dashboard',
 '2024-01-15 06:00:00', 'web', 'desktop', '192.168.1.100',
 NULL, 'USD', NULL,
 'low', 'completed'),

('ACT_003', 'CUST_002', 'email_open', 'Newsletter Campaign', 'Opened monthly product update newsletter',
 '2024-01-14 12:00:00', 'email', 'mobile', '10.0.0.50',
 NULL, 'USD', 'Marketing',
 'low', 'completed'),

('ACT_004', 'CUST_002', 'cart_abandonment', 'Shopping Cart Abandoned', 'Added items to cart but did not complete purchase',
 '2024-01-15 04:00:00', 'mobile', 'smartphone', '10.0.0.50',
 450.75, 'USD', 'Hardware',
 'medium', 'abandoned'),

('ACT_005', 'CUST_003', 'support_ticket', 'Billing Inquiry', 'Customer created support ticket about billing discrepancy',
 '2024-01-10 14:00:00', 'web', 'desktop', '172.16.0.25',
 NULL, 'USD', 'Support',
 'high', 'resolved'),

('ACT_006', 'CUST_003', 'login', 'Account Review', 'Customer logged in to review account status',
 '2024-01-05 16:00:00', 'web', 'desktop', '172.16.0.25',
 NULL, 'USD', NULL,
 'low', 'completed'),

('ACT_007', 'CUST_003', 'unsubscribe', 'Marketing Unsubscribe', 'Unsubscribed from promotional emails',
 '2024-01-07 11:00:00', 'email', 'mobile', '172.16.0.25',
 NULL, 'USD', 'Marketing',
 'high', 'completed'),

('ACT_008', 'CUST_004', 'signup', 'Account Creation', 'New customer account created through referral program',
 '2024-01-15 07:00:00', 'web', 'desktop', '203.0.113.10',
 NULL, 'USD', 'Onboarding',
 'medium', 'completed'),

('ACT_009', 'CUST_004', 'purchase', 'First Purchase', 'Customer made their first purchase with welcome discount',
 '2024-01-15 09:00:00', 'web', 'desktop', '203.0.113.10',
 149.99, 'USD', 'Software',
 'high', 'completed'),

('ACT_010', 'CUST_004', 'review', 'Product Review', 'Left positive review for first purchase',
 '2024-01-15 09:30:00', 'web', 'desktop', '203.0.113.10',
 NULL, 'USD', 'Feedback',
 'medium', 'completed'),

('ACT_011', 'CUST_005', 'contract_renewal', 'Enterprise Contract Renewal', 'Renewed enterprise contract for 2 more years',
 '2024-01-15 04:00:00', 'phone', NULL, NULL,
 75000.00, 'USD', 'Enterprise',
 'high', 'completed');

-- Step 2: Update activities with JSON metadata
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"order_id": "ORD_2024_001", "payment_method": "credit_card"}') WHERE activity_id = 'ACT_001';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"session_duration": 1200}') WHERE activity_id = 'ACT_002';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"campaign_id": "CAMP_2024_001", "open_time": 15}') WHERE activity_id = 'ACT_003';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"cart_value": 450.75, "items_count": 3}') WHERE activity_id = 'ACT_004';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"agent_id": "AGT_001", "resolution_time": 15}') WHERE activity_id = 'ACT_005';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"session_duration": 300}') WHERE activity_id = 'ACT_006';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"reason": "too_frequent"}') WHERE activity_id = 'ACT_007';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"referral_source": "google_ads", "signup_time": 180}') WHERE activity_id = 'ACT_008';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"order_id": "ORD_2024_002", "discount_applied": 50.00}') WHERE activity_id = 'ACT_009';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"rating": 5, "review_length": 150}') WHERE activity_id = 'ACT_010';
UPDATE customer_activities SET activity_metadata = PARSE_JSON('{"contract_id": "CONT_2024_001", "renewal_period": 24}') WHERE activity_id = 'ACT_011';

-- ===============================
-- Sample Support Tickets
-- ===============================

-- Step 1: Insert support tickets WITHOUT JSON data
INSERT INTO support_tickets (
    ticket_id, customer_id, subject, description, category, priority, status,
    assigned_agent_id, assigned_team, created_at, updated_at,
    first_response_at, resolved_at, resolution_time_hours,
    customer_satisfaction_rating
) VALUES
('TKT_001', 'CUST_002', 'Shipping Delay Inquiry', 'Customer asking about delayed shipment of hardware order', 'shipping', 'medium', 'resolved',
 'AGT_001', 'Customer Success', '2024-01-13 10:00:00', '2024-01-14 10:00:00',
 '2024-01-13 14:00:00', '2024-01-14 10:00:00', 4,
 4),

('TKT_002', 'CUST_003', 'Billing Question', 'Confusion about recent charges on account statement', 'billing', 'high', 'resolved',
 'AGT_002', 'Billing Support', '2024-01-10 09:00:00', '2024-01-11 09:00:00',
 '2024-01-10 11:00:00', '2024-01-11 09:00:00', 2,
 5),

('TKT_003', 'CUST_003', 'Account Credit Request', 'Requesting account credit due to service interruption', 'billing', 'high', 'closed',
 'AGT_003', 'Billing Support', '2024-01-07 14:00:00', '2024-01-08 14:00:00',
 '2024-01-07 16:00:00', '2024-01-08 14:00:00', 6,
 3);

-- Step 2: Update support tickets with JSON metadata
UPDATE support_tickets SET ticket_metadata = PARSE_JSON('{"escalated": true, "sla_breach": false}') WHERE ticket_id = 'TKT_001';
UPDATE support_tickets SET ticket_metadata = PARSE_JSON('{"solution_provided": true, "follow_up_scheduled": true}') WHERE ticket_id = 'TKT_002';
UPDATE support_tickets SET ticket_metadata = PARSE_JSON('{"refund_issued": true, "account_notes": "recurring_billing_issues"}') WHERE ticket_id = 'TKT_003';

-- ===============================
-- Sample Purchases
-- ===============================

-- Step 1: Insert purchases WITHOUT JSON data
INSERT INTO purchases (
    purchase_id, customer_id, order_id, purchase_date,
    product_id, product_name, product_category, product_subcategory,
    quantity, unit_price, total_amount, discount_amount, tax_amount, currency,
    shipping_address, shipping_method, tracking_number, delivery_date,
    order_status, payment_status, fulfillment_status
) VALUES
('PUR_001', 'CUST_005', 'ORD_2024_001', '2024-01-15 04:00:00',
 'PROD_ENT_001', 'Enterprise Software Suite', 'Software', 'Enterprise Solutions',
 1, 75000.00, 75000.00, 0.00, 6750.00, 'USD',
 '555 Enterprise Blvd, Los Angeles, CA 90210', 'Digital Delivery', 'TRACK_001', '2024-01-16',
 'completed', 'paid', 'delivered'),

('PUR_002', 'CUST_001', 'ORD_2024_002', '2024-01-15 08:00:00',
 'PROD_PREM_001', 'Premium Analytics Package', 'Software', 'Analytics',
 1, 2499.99, 2499.99, 250.00, 202.50, 'USD',
 '123 Market St, San Francisco, CA 94102', 'Express Shipping', 'TRACK_002', '2024-01-17',
 'processing', 'paid', 'pending'),

('PUR_003', 'CUST_004', 'ORD_2024_003', '2024-01-15 09:00:00',
 'PROD_START_001', 'Starter Package', 'Software', 'Basic',
 1, 149.99, 149.99, 50.00, 8.00, 'USD',
 '321 Pine St, Seattle, WA 98101', 'Standard Shipping', 'TRACK_003', '2024-01-20',
 'confirmed', 'paid', 'pending'),

('PUR_004', 'CUST_005', 'ORD_2024_004', '2023-10-15 10:00:00',
 'PROD_CONS_001', 'Consulting Services', 'Services', 'Professional Services',
 100, 500.00, 50000.00, 0.00, 4500.00, 'USD',
 '555 Enterprise Blvd, Los Angeles, CA 90210', 'N/A', 'N/A', '2023-11-15',
 'completed', 'paid', 'delivered');

-- Step 2: Update purchases with JSON metadata
UPDATE purchases SET purchase_metadata = PARSE_JSON('{"license_key": "ENT-2024-001", "auto_renewal": true}') WHERE purchase_id = 'PUR_001';
UPDATE purchases SET purchase_metadata = PARSE_JSON('{"subscription_id": "SUB_2024_002", "billing_cycle": "monthly"}') WHERE purchase_id = 'PUR_002';
UPDATE purchases SET purchase_metadata = PARSE_JSON('{"first_purchase": true, "welcome_discount": 50.00}') WHERE purchase_id = 'PUR_003';
UPDATE purchases SET purchase_metadata = PARSE_JSON('{"contract_period": 24, "service_level": "premium", "dedicated_support": true}') WHERE purchase_id = 'PUR_004';

-- ===============================
-- Sample Communications
-- ===============================

-- Step 1: Insert communications WITHOUT JSON data
INSERT INTO customer_communications (
    communication_id, customer_id, communication_type, direction, subject, message_content,
    sent_at, delivered_at, opened_at, clicked_at, responded_at,
    campaign_id, campaign_name, template_id, status
) VALUES
('COMM_001', 'CUST_001', 'email', 'outbound', 'Welcome to Premium!', 'Thank you for upgrading to our premium plan...',
 '2024-01-15 08:00:00', '2024-01-15 08:00:00',
 '2024-01-15 08:15:00', '2024-01-15 08:30:00', NULL,
 'CAMP_WELCOME_001', 'Premium Welcome Series', 'TEMP_001', 'clicked'),

('COMM_002', 'CUST_002', 'email', 'outbound', 'Your Monthly Newsletter', 'Here are this month''s product updates and tips...',
 '2024-01-14 12:00:00', '2024-01-14 12:00:00',
 '2024-01-14 13:00:00', '2024-01-14 13:30:00', NULL,
 'CAMP_NEWSLETTER_001', 'Monthly Newsletter', 'TEMP_002', 'clicked'),

('COMM_003', 'CUST_003', 'email', 'outbound', 'Support Ticket Update', 'Your support ticket TKT_001 has been resolved...',
 '2024-01-14 10:00:00', '2024-01-14 10:00:00',
 '2024-01-14 10:30:00', NULL, NULL,
 NULL, 'Support Notifications', 'TEMP_003', 'delivered');

-- Step 2: Update communications with JSON metadata
UPDATE customer_communications SET communication_metadata = PARSE_JSON('{"sequence_step": 1, "personalization": "high"}') WHERE communication_id = 'COMM_001';
UPDATE customer_communications SET communication_metadata = PARSE_JSON('{"engagement_score": 0.85, "time_reading": 180}') WHERE communication_id = 'COMM_002';
UPDATE customer_communications SET communication_metadata = PARSE_JSON('{"ticket_id": "TKT_001", "auto_generated": true}') WHERE communication_id = 'COMM_003';

-- ===============================
-- Sample Documents
-- ===============================

-- Step 1: Insert documents WITHOUT JSON data
INSERT INTO customer_documents (
    document_id, customer_id, document_title, document_type, document_content,
    document_category, created_by, created_at,
    content_summary
) VALUES
('DOC_001', 'CUST_002', 'Shipping Delay Support Conversation', 'transcript',
'Customer: Hi, I placed an order last week but haven''t received any shipping updates. Can you help?

Agent: I''d be happy to help you track your order. Let me look that up for you. Can you provide your order number?

Customer: Sure, it''s ORD_2024_002.

Agent: Thank you. I can see your order here. It looks like there was a delay at our fulfillment center due to high demand. Your order has now been processed and shipped. You should receive tracking information within the next hour.

Customer: That''s frustrating, but I appreciate the update. Will there be any compensation for the delay?

Agent: Absolutely. I''ve applied a $50 credit to your account for the inconvenience. You''ll see this reflected in your next billing cycle.

Customer: Thank you, that''s very helpful. I appreciate your assistance.

Agent: You''re welcome! Is there anything else I can help you with today?

Customer: No, that covers everything. Thanks again!',
 'support', 'support_agent_001', '2024-01-14 10:00:00',
 'Customer inquiry about shipping delay, resolved with account credit'),

('DOC_002', 'CUST_005', 'Enterprise Service Agreement', 'contract',
'ENTERPRISE SOFTWARE LICENSE AGREEMENT

This Enterprise Software License Agreement ("Agreement") is entered into between Company and Customer for the provision of enterprise software services.

TERMS AND CONDITIONS:
1. License Grant: Customer is granted a non-exclusive license to use the Software
2. Support Services: 24/7 premium support with dedicated account manager
3. Service Level Agreement: 99.9% uptime guarantee
4. Data Protection: Enterprise-grade security and compliance
5. Contract Term: 24 months with automatic renewal
6. Payment Terms: Annual payment in advance

SUPPORT PROVISIONS:
- Dedicated technical account manager
- Priority support queue
- Custom integration support
- Training and onboarding assistance
- Regular business reviews

This agreement ensures enterprise-level service and support for mission-critical operations.',
 'legal', 'legal_team', '2023-10-15 09:00:00',
 'Enterprise software license agreement with premium support provisions'),

('DOC_003', 'CUST_003', 'Customer Feedback Survey Response', 'feedback',
'CUSTOMER SATISFACTION SURVEY - RESPONSE

Customer ID: CUST_003
Survey Date: [Date]
Overall Satisfaction: 3/5

DETAILED FEEDBACK:

Product Quality: 4/5
"The software works well when it''s working, but I''ve had some billing issues that have been frustrating."

Customer Support: 4/5
"Support team is helpful and responsive, though it sometimes takes a while to get through."

Value for Money: 2/5
"I feel like I''m paying too much for what I get, especially with the billing problems I''ve had."

SPECIFIC COMMENTS:
"I''ve been a customer for about a year now, and while I like the product, the billing issues are really concerning. I''ve had incorrect charges twice now, and while support resolves them, it shouldn''t happen in the first place. I''m considering switching to a competitor if this continues."

IMPROVEMENT SUGGESTIONS:
- Fix billing system reliability
- Provide more transparent pricing
- Offer loyalty discounts for long-term customers

Likelihood to recommend: 6/10',
 'feedback', 'survey_system', '2024-01-01 12:00:00',
 'Customer feedback indicating billing issues and potential churn risk'),

('DOC_004', 'CUST_004', 'New Customer Onboarding Notes', 'note',
'NEW CUSTOMER ONBOARDING - CUST_004

Customer: James Wilson
Onboarding Date: [Date]
Account Manager: Sarah Mitchell

CUSTOMER PROFILE:
- Small business owner in Seattle
- Technology-savvy
- Price-conscious but values quality
- Referred by Google Ads campaign
- Looking for growth-oriented solutions

INITIAL CONSULTATION NOTES:
Customer expressed interest in our starter package but asked about upgrade paths. He runs a growing consulting business and anticipates needing more advanced features within 6-12 months.

KEY REQUIREMENTS:
- Cost-effective solution to start
- Easy scalability
- Integration with existing tools
- Good customer support

RECOMMENDATIONS:
- Started with Starter Package ($149.99)
- Applied new customer discount (33% off)
- Scheduled follow-up in 30 days
- Flagged for potential upsell opportunity

FOLLOW-UP ACTIONS:
- Send welcome sequence emails
- Schedule product training session
- Monitor usage patterns
- Prepare upgrade proposal for Q2

NOTES:
Customer seems very promising. High engagement during onboarding call, asked thoughtful questions about features and scalability. Good candidate for growth into premium tiers.',
 'onboarding', 'onboarding_specialist', '2024-01-15 07:00:00',
 'Onboarding notes for new customer with high growth potential');

-- Step 2: Update documents with JSON data
UPDATE customer_documents SET document_tags = PARSE_JSON('["shipping", "delay", "escalation", "credit"]') WHERE document_id = 'DOC_001';
UPDATE customer_documents SET key_topics = PARSE_JSON('["shipping_delays", "customer_compensation", "service_recovery"]') WHERE document_id = 'DOC_001';

UPDATE customer_documents SET document_tags = PARSE_JSON('["enterprise", "contract", "premium_support", "SLA"]') WHERE document_id = 'DOC_002';
UPDATE customer_documents SET key_topics = PARSE_JSON('["enterprise_contract", "service_levels", "premium_support", "account_management"]') WHERE document_id = 'DOC_002';

UPDATE customer_documents SET document_tags = PARSE_JSON('["billing_issues", "churn_risk", "service_problems"]') WHERE document_id = 'DOC_003';
UPDATE customer_documents SET key_topics = PARSE_JSON('["customer_satisfaction", "billing_problems", "churn_risk", "service_improvement"]') WHERE document_id = 'DOC_003';

UPDATE customer_documents SET document_tags = PARSE_JSON('["new_customer", "high_potential", "expansion_opportunity"]') WHERE document_id = 'DOC_004';
UPDATE customer_documents SET key_topics = PARSE_JSON('["customer_onboarding", "business_requirements", "expansion_potential", "customer_success"]') WHERE document_id = 'DOC_004';

-- ===============================
-- Final Verification
-- ===============================

SELECT 'Complete sample data loaded successfully!' AS status,
       (SELECT COUNT(*) FROM customers) AS customers,
       (SELECT COUNT(*) FROM customer_activities) AS activities,
       (SELECT COUNT(*) FROM support_tickets) AS tickets,
       (SELECT COUNT(*) FROM purchases) AS purchases,
       (SELECT COUNT(*) FROM customer_communications) AS communications,
       (SELECT COUNT(*) FROM customer_documents) AS documents,
       (SELECT COUNT(CASE WHEN customer_tags IS NOT NULL THEN 1 END) FROM customers) AS customers_with_tags; 