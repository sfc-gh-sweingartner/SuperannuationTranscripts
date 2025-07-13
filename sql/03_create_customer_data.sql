-- ============================================================================
-- Superannuation Transcripts Demo - Customer Data Creation
-- ============================================================================
-- This script creates synthetic customer data that maps to the call transcripts
-- Run this after loading the call transcript data
-- ============================================================================

-- Set context
USE DATABASE SUPERANNUATION;
USE SCHEMA TRANSCRIPTS;
USE WAREHOUSE MYWH;

-- Clear any existing customer data (for fresh demo runs)
DELETE FROM CUSTOMER;

-- ============================================================================
-- Create Synthetic Customer Data
-- ============================================================================

-- Insert customer data with realistic profiles for demo scenarios
INSERT INTO CUSTOMER (
    CUSTOMER_ID,
    CUSTOMER_NAME,
    AGE,
    TENURE_YEARS,
    ACCOUNT_BALANCE,
    INVESTMENT_OPTION,
    RECENT_TRANSACTIONS,
    LAST_INTERACTION_DATE,
    PRODUCT_HOLDINGS,
    CONTACT_PREFERENCE,
    CALL_FREQUENCY_LAST_MONTH,
    AVG_SENTIMENT_LAST_3_CALLS,
    NUM_NEGATIVE_CALLS_LAST_6_MONTHS,
    HAS_CHURN_INTENT_LAST_MONTH,
    CHURN_RISK_SCORE,
    CHURN_PROBABILITY,
    NEXT_BEST_ACTION
) VALUES

-- Demo Scenario 1: High Churn Risk Customers
('CUST001', 'Sarah Chen', 34, 5, 125000.00, 'Growth Plus', 2, '2025-07-10', 
 PARSE_JSON('["SuperChoice Growth", "Insurance Plus"]'), 'Email', 3, -0.2, 1, FALSE, 'Medium', 0.25, 
 'Follow up on recent account inquiries and market concerns'),

('CUST003', 'Maria Garcia', 42, 8, 89000.00, 'Balanced Growth', 1, '2025-07-10', 
 PARSE_JSON('["Balanced Fund", "Life Insurance"]'), 'Phone', 4, -0.7, 3, TRUE, 'High', 0.75, 
 'URGENT: Schedule senior advisor call to address technical and service concerns'),

('CUST010', 'Robert Wilson', 55, 12, 245000.00, 'Conservative', 0, '2025-07-09', 
 PARSE_JSON('["Conservative Fund", "Pension Account", "Insurance Bundle"]'), 'Email', 5, -0.4, 2, TRUE, 'High', 0.60, 
 'Proactive outreach: Offer personalized account review and fee discussion'),

('CUST015', 'Jennifer Brown', 38, 6, 67000.00, 'Growth Plus', 3, '2025-07-08', 
 PARSE_JSON('["Growth Fund", "Salary Sacrifice"]'), 'SMS', 6, -0.5, 4, TRUE, 'High', 0.70, 
 'Urgent: Address fee concerns and provide detailed explanation of charges'),

('CUST020', 'Michael Davis', 29, 3, 45000.00, 'Aggressive Growth', 1, '2025-07-07', 
 PARSE_JSON('["Aggressive Growth", "Mobile Access"]'), 'Email', 2, -0.3, 1, FALSE, 'Medium', 0.40, 
 'Provide investment education and performance explanations'),

-- Demo Scenario 2: Upsell Opportunities (Happy customers)
('CUST004', 'John Smith', 45, 7, 180000.00, 'Balanced Growth', 4, '2025-07-10', 
 PARSE_JSON('["Balanced Fund", "Online Access"]'), 'Email', 2, 0.6, 0, FALSE, 'Low', 0.15, 
 'Offer personalized ESG investment portfolio consultation'),

('CUST007', 'Emma Thompson', 52, 15, 320000.00, 'Growth Plus', 2, '2025-07-09', 
 PARSE_JSON('["Growth Fund", "Pension Account", "Premium Services"]'), 'Phone', 1, 0.4, 0, FALSE, 'Low', 0.10, 
 'Introduce additional investment options and premium advisory services'),

('CUST012', 'David Liu', 41, 9, 195000.00, 'Sustainable Growth', 3, '2025-07-08', 
 PARSE_JSON('["ESG Fund", "Salary Sacrifice", "Insurance"]'), 'Email', 1, 0.5, 0, FALSE, 'Low', 0.12, 
 'Expand sustainable investment options and discuss additional ESG products'),

('CUST018', 'Lisa Martinez', 36, 11, 210000.00, 'Balanced Growth', 2, '2025-07-07', 
 PARSE_JSON('["Balanced Fund", "Insurance Plus", "Online Trading"]'), 'Email', 2, 0.3, 0, FALSE, 'Low', 0.18, 
 'Offer advanced investment tools and premium account features'),

-- Demo Scenario 3: Retirement Planning (Neutral sentiment, planning focused)
('CUST005', 'Emily White', 64, 25, 780000.00, 'Conservative', 1, '2025-07-10', 
 PARSE_JSON('["Conservative Fund", "Pension Account", "Insurance Bundle", "Transition to Retirement"]'), 'Phone', 2, 0.4, 0, FALSE, 'Low', 0.08, 
 'Schedule complimentary retirement planning session and pension options review'),

('CUST008', 'Peter Johnson', 59, 20, 650000.00, 'Balanced Growth', 2, '2025-07-09', 
 PARSE_JSON('["Balanced Fund", "Pre-Retirement", "Insurance"]'), 'Phone', 1, 0.2, 0, FALSE, 'Low', 0.12, 
 'Provide pre-retirement planning consultation and transition strategies'),

-- Additional customers for broader demo scenarios
('CUST002', 'David Lee', 31, 4, 78000.00, 'Balanced Growth', 1, '2025-07-10', 
 PARSE_JSON('["Balanced Fund", "Consolidation"]'), 'Email', 1, 0.1, 0, FALSE, 'Low', 0.20, 
 'Assist with superannuation consolidation and provide consolidation benefits information'),

('CUST006', 'Michael Brown', 48, 13, 165000.00, 'Growth Plus', 2, '2025-07-10', 
 PARSE_JSON('["Growth Fund", "Salary Sacrifice", "Insurance"]'), 'Email', 1, 0.0, 0, FALSE, 'Low', 0.15, 
 'Review contribution methods and optimize salary sacrifice arrangements'),

('CUST009', 'Amanda Taylor', 33, 6, 92000.00, 'Sustainable Growth', 3, '2025-07-09', 
 PARSE_JSON('["ESG Fund", "Mobile Access"]'), 'SMS', 2, 0.3, 0, FALSE, 'Low', 0.10, 
 'Expand sustainable investment portfolio and discuss impact investing'),

('CUST011', 'Steven Clark', 50, 18, 425000.00, 'Balanced Growth', 1, '2025-07-08', 
 PARSE_JSON('["Balanced Fund", "Pension Account", "Premium Services", "Insurance Bundle"]'), 'Phone', 1, 0.2, 0, FALSE, 'Low', 0.08, 
 'Offer wealth management services and advanced planning strategies'),

('CUST013', 'Rachel Green', 39, 8, 145000.00, 'Growth Plus', 4, '2025-07-08', 
 PARSE_JSON('["Growth Fund", "Salary Sacrifice", "Online Access"]'), 'Email', 2, 0.1, 0, FALSE, 'Low', 0.12, 
 'Optimize contribution strategies and review investment performance'),

('CUST014', 'Kevin Moore', 44, 10, 175000.00, 'Aggressive Growth', 2, '2025-07-07', 
 PARSE_JSON('["Aggressive Growth", "Online Trading", "Insurance"]'), 'Email', 1, 0.4, 0, FALSE, 'Low', 0.09, 
 'Discuss diversification strategies and risk management options'),

('CUST016', 'Nancy Wilson', 37, 7, 118000.00, 'Balanced Growth', 3, '2025-07-07', 
 PARSE_JSON('["Balanced Fund", "Insurance Plus", "Mobile Access"]'), 'SMS', 2, 0.2, 0, FALSE, 'Low', 0.11, 
 'Review insurance coverage and discuss additional protection options'),

('CUST017', 'James Anderson', 53, 16, 380000.00, 'Conservative', 1, '2025-07-06', 
 PARSE_JSON('["Conservative Fund", "Pension Account", "Insurance Bundle"]'), 'Phone', 1, 0.3, 0, FALSE, 'Low', 0.07, 
 'Discuss pre-retirement planning and wealth preservation strategies'),

('CUST019', 'Karen White', 46, 12, 225000.00, 'Sustainable Growth', 2, '2025-07-06', 
 PARSE_JSON('["ESG Fund", "Pension Account", "Premium Services"]'), 'Email', 1, 0.4, 0, FALSE, 'Low', 0.08, 
 'Expand sustainable investment options and discuss impact measurement'),

('CUST021', 'Christopher Lee', 35, 5, 86000.00, 'Growth Plus', 3, '2025-07-05', 
 PARSE_JSON('["Growth Fund", "Salary Sacrifice"]'), 'Email', 1, 0.1, 0, FALSE, 'Low', 0.14, 
 'Optimize growth strategy and discuss long-term wealth building'),

-- Continue with remaining customers to match call transcript data
('CUST022', 'Michelle Garcia', 43, 9, 156000.00, 'Balanced Growth', 2, '2025-07-05', 
 PARSE_JSON('["Balanced Fund", "Insurance Plus"]'), 'Phone', 1, 0.0, 0, FALSE, 'Low', 0.13, 
 'Review portfolio balance and discuss risk tolerance'),

('CUST023', 'Daniel Kim', 40, 11, 198000.00, 'Growth Plus', 1, '2025-07-04', 
 PARSE_JSON('["Growth Fund", "Pension Account", "Online Access"]'), 'Email', 1, 0.2, 0, FALSE, 'Low', 0.10, 
 'Discuss advanced investment strategies and market opportunities'),

('CUST024', 'Susan Miller', 57, 22, 520000.00, 'Conservative', 2, '2025-07-04', 
 PARSE_JSON('["Conservative Fund", "Transition to Retirement", "Insurance Bundle"]'), 'Phone', 1, 0.1, 0, FALSE, 'Low', 0.06, 
 'Provide transition to retirement planning and income stream options'),

('CUST025', 'Andrew Chen', 32, 3, 58000.00, 'Aggressive Growth', 4, '2025-07-03', 
 PARSE_JSON('["Aggressive Growth", "Mobile Access"]'), 'SMS', 2, 0.0, 0, FALSE, 'Low', 0.16, 
 'Discuss long-term growth strategies and contribution optimization');

-- ============================================================================
-- Verification and Summary
-- ============================================================================

-- Check customer data creation results
SELECT 
    COUNT(*) as TOTAL_CUSTOMERS,
    COUNT(CASE WHEN CHURN_RISK_SCORE = 'High' THEN 1 END) as HIGH_CHURN_CUSTOMERS,
    COUNT(CASE WHEN CHURN_RISK_SCORE = 'Medium' THEN 1 END) as MEDIUM_CHURN_CUSTOMERS,
    COUNT(CASE WHEN CHURN_RISK_SCORE = 'Low' THEN 1 END) as LOW_CHURN_CUSTOMERS,
    AVG(ACCOUNT_BALANCE) as AVG_ACCOUNT_BALANCE,
    AVG(TENURE_YEARS) as AVG_TENURE_YEARS,
    AVG(AGE) as AVG_AGE
FROM CUSTOMER;

-- Check investment option distribution
SELECT 
    INVESTMENT_OPTION,
    COUNT(*) as CUSTOMER_COUNT,
    AVG(ACCOUNT_BALANCE) as AVG_BALANCE
FROM CUSTOMER
GROUP BY INVESTMENT_OPTION
ORDER BY CUSTOMER_COUNT DESC;

-- Check customers with call transcript data
SELECT 
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME,
    c.CHURN_RISK_SCORE,
    c.CHURN_PROBABILITY,
    COUNT(r.CALL_ID) as CALL_COUNT
FROM CUSTOMER c
LEFT JOIN RAW_CALL_TRANSCRIPTS r ON c.CUSTOMER_ID = r.CUSTOMER_ID
GROUP BY c.CUSTOMER_ID, c.CUSTOMER_NAME, c.CHURN_RISK_SCORE, c.CHURN_PROBABILITY
ORDER BY c.CHURN_RISK_SCORE DESC, c.CHURN_PROBABILITY DESC;

-- Demo scenario summary
SELECT 
    CASE 
        WHEN CHURN_RISK_SCORE = 'High' THEN 'High Churn Risk (Demo Scenario 1)'
        WHEN CHURN_RISK_SCORE = 'Low' AND AVG_SENTIMENT_LAST_3_CALLS > 0.3 THEN 'Upsell Opportunity (Demo Scenario 2)'
        WHEN AGE >= 55 THEN 'Retirement Planning (Demo Scenario 3)'
        ELSE 'Standard Customer'
    END as DEMO_SCENARIO,
    COUNT(*) as CUSTOMER_COUNT,
    AVG(ACCOUNT_BALANCE) as AVG_BALANCE,
    AVG(CHURN_PROBABILITY) as AVG_CHURN_PROBABILITY
FROM CUSTOMER
GROUP BY 
    CASE 
        WHEN CHURN_RISK_SCORE = 'High' THEN 'High Churn Risk (Demo Scenario 1)'
        WHEN CHURN_RISK_SCORE = 'Low' AND AVG_SENTIMENT_LAST_3_CALLS > 0.3 THEN 'Upsell Opportunity (Demo Scenario 2)'
        WHEN AGE >= 55 THEN 'Retirement Planning (Demo Scenario 3)'
        ELSE 'Standard Customer'
    END
ORDER BY AVG_CHURN_PROBABILITY DESC;

-- Success message
SELECT 
    'Customer data created successfully!' as STATUS,
    COUNT(*) as TOTAL_CUSTOMERS,
    COUNT(CASE WHEN CHURN_RISK_SCORE = 'High' THEN 1 END) as HIGH_CHURN_CUSTOMERS
FROM CUSTOMER; 