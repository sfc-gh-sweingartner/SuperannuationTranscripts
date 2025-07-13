-- ============================================================================
-- Superannuation Transcripts Demo - Database Objects Creation
-- ============================================================================
-- This script creates all the required database objects for the demo
-- Run this script in your Snowflake account: demo_sweingartner
-- ============================================================================

-- Create the main database
CREATE DATABASE IF NOT EXISTS SUPERANNUATION
COMMENT = 'Database for Superannuation Fund call transcript analysis demo';

-- Use the database
USE DATABASE SUPERANNUATION;

-- Create the transcripts schema
CREATE SCHEMA IF NOT EXISTS TRANSCRIPTS
COMMENT = 'Schema containing call transcript data and AI analysis results';

-- Use the schema
USE SCHEMA TRANSCRIPTS;

-- Create the stage for data loading
CREATE STAGE IF NOT EXISTS TRANSCRIPTS
COMMENT = 'Stage for loading call transcript JSON files';

-- Use the warehouse (assuming MYWH already exists)
USE WAREHOUSE MYWH;

-- ============================================================================
-- Create Raw Data Tables
-- ============================================================================

-- Raw call transcripts table
CREATE TABLE IF NOT EXISTS RAW_CALL_TRANSCRIPTS (
    CALL_ID VARCHAR(50) PRIMARY KEY,
    CUSTOMER_ID VARCHAR(50) NOT NULL,
    AGENT_ID VARCHAR(50),
    CALL_TIMESTAMP TIMESTAMP,
    CALL_DURATION_SECONDS INTEGER,
    TRANSCRIPT_TEXT TEXT,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Raw call transcript data loaded from JSON files';

-- Customer master data table
CREATE TABLE IF NOT EXISTS CUSTOMER (
    CUSTOMER_ID VARCHAR(50) PRIMARY KEY,
    CUSTOMER_NAME VARCHAR(100),
    AGE INTEGER,
    TENURE_YEARS INTEGER,
    ACCOUNT_BALANCE DECIMAL(18,2),
    INVESTMENT_OPTION VARCHAR(50),
    RECENT_TRANSACTIONS INTEGER,
    LAST_INTERACTION_DATE DATE,
    PRODUCT_HOLDINGS VARIANT, -- JSON array of products
    CONTACT_PREFERENCE VARCHAR(20),
    CALL_FREQUENCY_LAST_MONTH INTEGER DEFAULT 0,
    AVG_SENTIMENT_LAST_3_CALLS DECIMAL(5,2) DEFAULT 0.0,
    NUM_NEGATIVE_CALLS_LAST_6_MONTHS INTEGER DEFAULT 0,
    HAS_CHURN_INTENT_LAST_MONTH BOOLEAN DEFAULT FALSE,
    CHURN_RISK_SCORE VARCHAR(10) DEFAULT 'Low',
    CHURN_PROBABILITY DECIMAL(3,2) DEFAULT 0.00,
    NEXT_BEST_ACTION TEXT,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Customer master data with AI-derived insights';

-- ============================================================================
-- Create Enriched Data Tables
-- ============================================================================

-- Enriched transcripts for all historical data
CREATE TABLE IF NOT EXISTS ENRICHED_TRANSCRIPTS_ALL (
    CALL_ID VARCHAR(50) PRIMARY KEY,
    CUSTOMER_ID VARCHAR(50) NOT NULL,
    CALL_TIMESTAMP TIMESTAMP,
    TRANSCRIPT_TEXT TEXT,
    SENTIMENT_SCORE DECIMAL(5,2),
    SENTIMENT_LABEL VARCHAR(20),
    PRIMARY_INTENT VARCHAR(100),
    CALL_SUMMARY TEXT,
    KEY_TOPICS VARIANT, -- JSON array of topics
    CONFIDENCE_SCORE DECIMAL(3,2),
    PROCESSING_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (CALL_ID) REFERENCES RAW_CALL_TRANSCRIPTS(CALL_ID)
) COMMENT = 'All call transcripts enriched with AI analysis - used for manager dashboard';

-- Enriched transcripts for real-time demo simulation
CREATE TABLE IF NOT EXISTS ENRICHED_TRANSCRIPTS_REALTIME (
    CALL_ID VARCHAR(50) PRIMARY KEY,
    CUSTOMER_ID VARCHAR(50) NOT NULL,
    CALL_TIMESTAMP TIMESTAMP,
    TRANSCRIPT_TEXT TEXT,
    SENTIMENT_SCORE DECIMAL(5,2),
    SENTIMENT_LABEL VARCHAR(20),
    PRIMARY_INTENT VARCHAR(100),
    CALL_SUMMARY TEXT,
    KEY_TOPICS VARIANT, -- JSON array of topics
    CONFIDENCE_SCORE DECIMAL(3,2),
    PROCESSING_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (CALL_ID) REFERENCES RAW_CALL_TRANSCRIPTS(CALL_ID)
) COMMENT = 'Real-time transcript processing results - cleared and populated during demo';

-- ============================================================================
-- Create Views for Common Queries
-- ============================================================================

-- View combining customer data with latest call sentiment
CREATE OR REPLACE VIEW CUSTOMER_INSIGHTS AS
SELECT 
    c.*,
    et.SENTIMENT_SCORE as LATEST_SENTIMENT_SCORE,
    et.SENTIMENT_LABEL as LATEST_SENTIMENT_LABEL,
    et.PRIMARY_INTENT as LATEST_PRIMARY_INTENT,
    et.CALL_SUMMARY as LATEST_CALL_SUMMARY,
    et.CALL_TIMESTAMP as LATEST_CALL_TIMESTAMP
FROM CUSTOMER c
LEFT JOIN (
    SELECT 
        CUSTOMER_ID,
        SENTIMENT_SCORE,
        SENTIMENT_LABEL,
        PRIMARY_INTENT,
        CALL_SUMMARY,
        CALL_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY CALL_TIMESTAMP DESC) as rn
    FROM ENRICHED_TRANSCRIPTS_ALL
) et ON c.CUSTOMER_ID = et.CUSTOMER_ID AND et.rn = 1;

-- View for manager dashboard metrics
CREATE OR REPLACE VIEW DASHBOARD_METRICS AS
SELECT 
    -- Sentiment distribution
    COUNT(*) as TOTAL_CALLS,
    AVG(SENTIMENT_SCORE) as AVG_SENTIMENT,
    COUNT(CASE WHEN SENTIMENT_LABEL = 'Positive' THEN 1 END) as POSITIVE_CALLS,
    COUNT(CASE WHEN SENTIMENT_LABEL = 'Negative' THEN 1 END) as NEGATIVE_CALLS,
    COUNT(CASE WHEN SENTIMENT_LABEL = 'Neutral' THEN 1 END) as NEUTRAL_CALLS,
    
    -- Churn risk distribution
    COUNT(CASE WHEN c.CHURN_RISK_SCORE = 'High' THEN 1 END) as HIGH_CHURN_RISK,
    COUNT(CASE WHEN c.CHURN_RISK_SCORE = 'Medium' THEN 1 END) as MEDIUM_CHURN_RISK,
    COUNT(CASE WHEN c.CHURN_RISK_SCORE = 'Low' THEN 1 END) as LOW_CHURN_RISK,
    
    -- Date range for context
    MIN(CALL_TIMESTAMP) as EARLIEST_CALL,
    MAX(CALL_TIMESTAMP) as LATEST_CALL
FROM ENRICHED_TRANSCRIPTS_ALL e
LEFT JOIN CUSTOMER c ON e.CUSTOMER_ID = c.CUSTOMER_ID;

-- ============================================================================
-- Create Indexes for Performance
-- ============================================================================

-- Note: Snowflake handles indexing automatically, but we can create clustering keys
-- for better performance on frequently queried columns

-- Cluster by customer_id for customer-specific queries
ALTER TABLE RAW_CALL_TRANSCRIPTS CLUSTER BY (CUSTOMER_ID);
ALTER TABLE ENRICHED_TRANSCRIPTS_ALL CLUSTER BY (CUSTOMER_ID);
ALTER TABLE ENRICHED_TRANSCRIPTS_REALTIME CLUSTER BY (CUSTOMER_ID);

-- ============================================================================
-- Grant Permissions (if needed)
-- ============================================================================

-- Grant usage on database and schema to current role
GRANT USAGE ON DATABASE SUPERANNUATION TO ROLE ACCOUNTADMIN;
GRANT USAGE ON SCHEMA TRANSCRIPTS TO ROLE ACCOUNTADMIN;
GRANT ALL ON ALL TABLES IN SCHEMA TRANSCRIPTS TO ROLE ACCOUNTADMIN;
GRANT ALL ON ALL VIEWS IN SCHEMA TRANSCRIPTS TO ROLE ACCOUNTADMIN;

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- Verify all objects were created successfully
SHOW TABLES;
SHOW VIEWS;
SHOW STAGES;

-- Check table structures
DESCRIBE TABLE RAW_CALL_TRANSCRIPTS;
DESCRIBE TABLE CUSTOMER;
DESCRIBE TABLE ENRICHED_TRANSCRIPTS_ALL;

SELECT 'Database objects created successfully' as STATUS; 