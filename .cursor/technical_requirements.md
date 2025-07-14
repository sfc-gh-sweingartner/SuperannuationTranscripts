# Technical Requirements for Superannuation Transcripts Demo

## Database Schema Design

### Core Tables

#### RAW_CALL_TRANSCRIPTS
```sql
CREATE TABLE RAW_CALL_TRANSCRIPTS (
    CALL_ID VARCHAR(50) PRIMARY KEY,
    CUSTOMER_ID VARCHAR(50) NOT NULL,
    AGENT_ID VARCHAR(50),
    CALL_TIMESTAMP TIMESTAMP,
    CALL_DURATION_SECONDS INTEGER,
    TRANSCRIPT_TEXT TEXT,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### CUSTOMER
```sql
CREATE TABLE CUSTOMER (
    CUSTOMER_ID VARCHAR(50) PRIMARY KEY,
    CUSTOMER_NAME VARCHAR(100),
    AGE INTEGER,
    TENURE_YEARS INTEGER,
    ACCOUNT_BALANCE DECIMAL(18,2),
    INVESTMENT_OPTION VARCHAR(50),
    RECENT_TRANSACTIONS INTEGER,
    LAST_INTERACTION_DATE DATE,
    PRODUCT_HOLDINGS ARRAY,
    CONTACT_PREFERENCE VARCHAR(20),
    CALL_FREQUENCY_LAST_MONTH INTEGER,
    AVG_SENTIMENT_LAST_3_CALLS DECIMAL(5,2),
    NUM_NEGATIVE_CALLS_LAST_6_MONTHS INTEGER,
    HAS_CHURN_INTENT_LAST_MONTH BOOLEAN,
    CHURN_RISK_SCORE VARCHAR(10),
    CHURN_PROBABILITY DECIMAL(3,2),
    NEXT_BEST_ACTION TEXT,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### ENRICHED_TRANSCRIPTS_ALL
```sql
CREATE TABLE ENRICHED_TRANSCRIPTS_ALL (
    CALL_ID VARCHAR(50) PRIMARY KEY,
    CUSTOMER_ID VARCHAR(50),
    CALL_TIMESTAMP TIMESTAMP,
    TRANSCRIPT_TEXT TEXT,
    SENTIMENT_SCORE DECIMAL(5,2),
    SENTIMENT_LABEL VARCHAR(20),
    PRIMARY_INTENT VARCHAR(100),
    CALL_SUMMARY TEXT,
    KEY_TOPICS ARRAY,
    CONFIDENCE_SCORE DECIMAL(3,2),
    PROCESSING_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CALL_ID) REFERENCES RAW_CALL_TRANSCRIPTS(CALL_ID)
);
```

#### ENRICHED_TRANSCRIPTS_REALTIME
```sql
CREATE TABLE ENRICHED_TRANSCRIPTS_REALTIME (
    CALL_ID VARCHAR(50) PRIMARY KEY,
    CUSTOMER_ID VARCHAR(50),
    CALL_TIMESTAMP TIMESTAMP,
    TRANSCRIPT_TEXT TEXT,
    SENTIMENT_SCORE DECIMAL(5,2),
    SENTIMENT_LABEL VARCHAR(20),
    PRIMARY_INTENT VARCHAR(100),
    CALL_SUMMARY TEXT,
    KEY_TOPICS ARRAY,
    CONFIDENCE_SCORE DECIMAL(3,2),
    PROCESSING_TIMESTAMP TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CALL_ID) REFERENCES RAW_CALL_TRANSCRIPTS(CALL_ID)
);
```

## AI Processing Functions

### Enhanced AISQL Functions (2024)

#### AI_CLASSIFY - Advanced Classification
```sql
-- Enhanced intent classification with AI_CLASSIFY
SELECT 
    CALL_ID,
    AI_CLASSIFY(
        TRANSCRIPT_TEXT,
        ['Complaint', 'Investment Inquiry', 'Account Query', 'Churn Risk', 
         'Fee Question', 'Technical Support', 'Consolidation Request', 'Retirement Planning']
    ) as PRIMARY_INTENT,
    AI_CLASSIFY(
        TRANSCRIPT_TEXT,
        ['High Priority', 'Medium Priority', 'Low Priority']
    ) as URGENCY_LEVEL
FROM RAW_CALL_TRANSCRIPTS;
```

#### AI_FILTER - Intelligent Filtering
```sql
-- Advanced filtering for churn signals
SELECT * FROM RAW_CALL_TRANSCRIPTS 
WHERE AI_FILTER(TRANSCRIPT_TEXT, 'customer expressed intention to leave or switch providers');

-- Filter for upsell opportunities
SELECT * FROM RAW_CALL_TRANSCRIPTS 
WHERE AI_FILTER(TRANSCRIPT_TEXT, 'customer interested in additional products or investment options');
```

#### AI_AGG - Cross-Transcript Insights
```sql
-- Aggregate insights across all customer calls
SELECT 
    CUSTOMER_ID,
    AI_AGG(TRANSCRIPT_TEXT, 'Summarize all churn signals and concerns across these calls') as CHURN_SUMMARY,
    AI_AGG(TRANSCRIPT_TEXT, 'Identify recurring themes and pain points') as PAIN_POINTS,
    AI_AGG(TRANSCRIPT_TEXT, 'Suggest next best actions based on all interactions') as RECOMMENDED_ACTIONS
FROM RAW_CALL_TRANSCRIPTS 
GROUP BY CUSTOMER_ID;
```

#### Traditional Cortex Functions (Enhanced)
```sql
-- Sentiment Analysis
SELECT 
    CALL_ID,
    SNOWFLAKE.CORTEX.SENTIMENT(TRANSCRIPT_TEXT) as SENTIMENT_SCORE,
    CASE 
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(TRANSCRIPT_TEXT) >= 0.5 THEN 'Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(TRANSCRIPT_TEXT) <= -0.5 THEN 'Negative'
        ELSE 'Neutral'
    END as SENTIMENT_LABEL
FROM RAW_CALL_TRANSCRIPTS;

-- Enhanced Summarization with AI_SUMMARIZE
SELECT 
    CALL_ID,
    AI_SUMMARIZE(TRANSCRIPT_TEXT, 'action items and follow-ups') as ACTION_SUMMARY,
    AI_SUMMARIZE(TRANSCRIPT_TEXT, 'customer concerns and requests') as CONCERN_SUMMARY
FROM RAW_CALL_TRANSCRIPTS;

-- Advanced Intent Detection with AI_COMPLETE
SELECT 
    CALL_ID,
    AI_COMPLETE(
        'claude-4-sonnet',
        'Analyze this call transcript and provide: 1) Primary intent, 2) Emotional state, 3) Churn risk (0-100), 4) Recommended next action. Format as JSON: ' || TRANSCRIPT_TEXT
    ) as DETAILED_ANALYSIS
FROM RAW_CALL_TRANSCRIPTS;
```

## Connection Pattern

### Dual Environment Support
```python
@st.cache_resource(show_spinner="Connecting to Snowflake...")
def get_snowflake_connection():
    """
    Connection handler that works in both local and Snowflake environments
    Based on Reference/nation_app.py pattern
    """
    # Try Snowflake hosted environment first
    try:
        session = get_active_session()
        if session:
            return session
    except Exception:
        pass
    
    # Fall back to local connection
    try:
        with open('/Users/sweingartner/.snowflake/config.toml', 'rb') as f:
            config = tomli.load(f)
        
        default_conn = config.get('default_connection_name')
        conn_params = config.get('connections', {}).get(default_conn)
        
        return snowflake.connector.connect(**conn_params)
    except Exception as e:
        st.error(f"Failed to connect: {str(e)}")
        return None
```

## Churn Prediction Logic

### Rule-Based Churn Scoring
```sql
-- Simple rule-based churn prediction for demo
UPDATE CUSTOMER 
SET CHURN_RISK_SCORE = CASE
    WHEN AVG_SENTIMENT_LAST_3_CALLS < -0.3 AND NUM_NEGATIVE_CALLS_LAST_6_MONTHS > 2 THEN 'High'
    WHEN AVG_SENTIMENT_LAST_3_CALLS < 0 OR NUM_NEGATIVE_CALLS_LAST_6_MONTHS > 0 THEN 'Medium'
    ELSE 'Low'
END;
```

### Next Best Action Generation
```sql
-- NBA logic based on churn risk and recent interactions
UPDATE CUSTOMER 
SET NEXT_BEST_ACTION = CASE
    WHEN CHURN_RISK_SCORE = 'High' AND HAS_CHURN_INTENT_LAST_MONTH THEN 'Urgent: Schedule senior advisor call to address concerns'
    WHEN CHURN_RISK_SCORE = 'High' THEN 'Proactive outreach: Offer personalized account review'
    WHEN CHURN_RISK_SCORE = 'Medium' AND ACCOUNT_BALANCE > 100000 THEN 'Offer premium advisory service consultation'
    WHEN CHURN_RISK_SCORE = 'Medium' THEN 'Send personalized investment performance update'
    WHEN CHURN_RISK_SCORE = 'Low' AND TENURE_YEARS > 5 THEN 'Offer loyalty program benefits'
    ELSE 'Standard quarterly check-in'
END;
```

## Performance Optimization

### Caching Strategy
- Use `@st.cache_data` for data queries with appropriate TTL
- Use `@st.cache_resource` for connection objects
- Implement session state for UI components

### Query Optimization
- Use LIMIT clauses for large result sets
- Implement pagination for transcript lists
- Use appropriate indexes on join columns

## Error Handling

### AI Service Failures
```python
def safe_ai_call(func, *args, **kwargs):
    """Wrapper for AI service calls with error handling"""
    try:
        return func(*args, **kwargs)
    except Exception as e:
        st.warning(f"AI processing temporarily unavailable: {str(e)}")
        return None
```

### Data Quality Checks
```sql
-- Validate transcript data before processing
SELECT CALL_ID, 'Missing transcript' as ERROR
FROM RAW_CALL_TRANSCRIPTS 
WHERE TRANSCRIPT_TEXT IS NULL OR LENGTH(TRANSCRIPT_TEXT) < 10;
```

## Testing Requirements

### Local Testing Checklist
- [ ] Connection to Snowflake works
- [ ] Data loading completes without errors
- [ ] AI processing functions work
- [ ] UI renders correctly
- [ ] Real-time simulation works
- [ ] Error handling triggers appropriately

### Snowflake Testing Checklist
- [ ] App deploys successfully
- [ ] All database objects accessible
- [ ] Cortex AI functions work
- [ ] Performance is acceptable
- [ ] Multi-user access works
- [ ] Security permissions correct

## Security Considerations

### Data Access
- Use principle of least privilege
- Implement proper role-based access control
- Ensure sensitive data is protected

### AI Processing
- Validate input data before AI processing
- Implement rate limiting for AI calls
- Log AI processing for audit trails 