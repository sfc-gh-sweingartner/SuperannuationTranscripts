### **Functional Design: Hyper-Personalized Member Engagement & Retention Demo**

**I. Demo Objective**

The primary objective of this demo is to showcase how a superannuation company can leverage its existing customer call transcriptions, combined with core member data, to proactively identify members at risk of churning and deliver highly personalized "Next Best Actions" (NBA) using Snowflake's integrated AI/ML platform. This will demonstrate a shift from reactive service to proactive engagement, ultimately improving member retention and satisfaction, and aligning with the company's strategic goals of enhancing member financial security and experience.

**II. User Personas & Needs**

The demo will cater to two key user personas:

1. **Front-Line Financial Advisors/Customer Service Agents:**  
   * **Need:** Real-time or near real-time insights into individual member sentiment, churn risk, and actionable recommendations for engagement.  
   * **View:** A dashboard for a specific member showing their call history, sentiment trends from calls, a churn prediction score with confidence levels, and a suggested "Next Best Action" (e.g., "Offer a personalized retirement planning session," "Proactively address recent complaint," "Suggest a specific investment product").  
   * **Interaction:** Ability to view details of specific call transcripts, AI-extracted insights, and ML model confidence scores.  
2. **Managers/Team Leads (e.g., Call Center Supervisors, Member Engagement Managers):**  
   * **Need:** High-level aggregated insights into customer sentiment, churn trends across segments, and overall effectiveness of NBA strategies.  
   * **View:** Dashboards displaying aggregate sentiment scores over time, top reasons for negative sentiment, churn risk distribution across member segments, ML model performance metrics, and the most effective NBAs.  
   * **Interaction:** Ability to drill down into specific segments or trends, and to ask natural language questions about the data (e.g., "Show me all members with high churn risk who called about investment fees last month").

**III. Key Features & Capabilities - Hybrid AI/ML Approach**

1. **Voice-to-Text Notes Ingestion:**  
   * This will not be demonstrated to the customer but to deliver the demo we must once off load pre-existing call transcriptions into Snowflake.   
   * Each transcription will be linked to a `CUSTOMER_ID`.  
2. **Advanced AI-Powered Transcript Analysis (Snowflake Cortex AI):**  
   * **Sentiment Analysis:** Enhanced with AI_CLASSIFY for emotional state classification (e.g., anger, disappointment, happiness, gratitude) and overall polarity (positive, negative, neutral).    
   * **Intent Detection:** Use AI_CLASSIFY to identify the underlying purpose or goal of the customer's call (e.g., "account inquiry," "complaint about fees," "investment advice request," "churn intent").    
   * **Call Summarization:** Generate concise summaries of lengthy call transcripts using AI_SUMMARIZE.    
   * **Customer Journey Analysis:** Use AI_AGG for cross-transcript customer insights and behavioral patterns.    
3. **Integrated Member Data Model:**  
   * Combine the AI-extracted insights from call transcripts with a simplified, existing member data (e.g., client demographics, account details, portfolio holdings, order history). This unified view is crucial for holistic analysis.  
4. **ML-Powered Churn Prediction:**  
   * Develop and apply a machine learning model using SNOWFLAKE.ML.CLASSIFICATION that predicts the likelihood of a member churning based on a combination of structured data (e.g., tenure, account balance, product usage) and unstructured insights from call transcripts (e.g., negative sentiment trends, specific churn-related intents, frequency of complaints).    
   * The model will output a `CHURN_PROBABILITY` (0.0-1.0) and `CHURN_RISK_SCORE` (e.g., Low, Medium, High) with confidence metrics.  
   * Automated model training with proper feature engineering and validation.
5. **AI-Generated Next Best Action (NBA):**  
   * Based on the ML churn prediction and the specific insights from call transcripts, use AI_COMPLETE with claude-4-sonnet to generate personalized "Next Best Action" recommendations for each at-risk member.    
   * Examples:  
     * High churn risk + complaint about fees + AI analysis → "Offer a fee review session with a financial advisor focusing on value demonstration."  
     * Medium churn risk + inquiry about retirement planning + customer profile → "Proactively schedule a personalized retirement planning consultation with ESG investment options."  
     * High churn risk + general dissatisfaction + tenure analysis → "Initiate a proactive outreach call from a senior relationship manager with loyalty incentives."  
     * Low churn risk + interest in new products + AI insights → "Suggest a high-yield investment option based on their risk tolerance and goals."  
6. **Interactive Streamlit Application:**  
   * A user-friendly web application for both front-line advisors and managers, displaying the insights and recommendations in an intuitive visual format (charts, tables, individual member cards).    
   * Although we will have a lot of call transcripts preloaded into the database, the demo will act as though one call transcript has just come through right now.  So, we will immediately want to know a churn prediction, summary, nba, etc…  So, the application will be designed and build so that a demo person can push a button to select a recent call to process.  We will see things like summary, NBA, churn prediction are calculated and displayed very quickly.   That pushing of a button would simulate an automatic process that would run as voice to text data comes through  
7. **Snowflake Intelligence (Text-to-SQL):**  
   * Enable managers to ask ad-hoc questions about the aggregated data using natural language, receiving instant, accurate SQL-generated answers.  

**IV. Data Flow (High-Level) - Hybrid AI/ML Architecture**

1. **Existing Call Transcriptions** (Input)  
2. **Simplified Customer Data** (Input)  
3. **Snowflake Cortex AI** (Advanced LLM processing: AI_CLASSIFY, AI_AGG, AI_COMPLETE for sentiment, intent, summary, customer insights)  
4. **Enriched Call Data Table** (in Snowflake)  
5. **ML Feature Engineering** (Structured + AI insights feature preparation)
6. **SNOWFLAKE.ML.CLASSIFICATION** (Churn Prediction Model Training & Inference)  
7. **Unified Customer Data Table** (in Snowflake, combining structured data, ML predictions, and enriched unstructured data)  
8. **AI-Powered NBA Logic** (AI_COMPLETE for personalized recommendations)  
9. **Streamlit in Snowflake** (Front-end visualization for advisors and managers with ML insights)  
10. **Snowflake Intelligence** (Natural language querying for managers)

---

### **Technical Design: Hyper-Personalized Member Engagement & Retention Demo**

**I. Data Sources for Demo**

Gemini has generated 100 example call transcripts and these have been saved as a json file.  
It is here: /Users/sweingartner/Cursor/SuperannuationTranscripts/call_transcripts.json

We may need to modify that data to illustrate various capabilities

**II. Snowflake Data Architecture - Hybrid AI/ML Implementation**

**Object names:**

Create the following objects in Snowlake: 

Database: SUPERANNUATION

Schema: TRANSCRIPTS

Stage: TRANSCRIPTS

Warehouse: use the existing MYWH warehouse

1. **Data Ingestion:**  
   * **Call Transcripts:** Load the selected call transcript data (from the provided json file) into a raw staging table in Snowflake. This table would typically have columns like `CALL_ID`, `CUSTOMER_ID`, `CALL_TIMESTAMP`, `TRANSCRIPT_TEXT`, `AGENT_ID`.  
   * **Customer Data:** Create a simplified `CUSTOMER` table in Snowflake. This table will simulate the superannuation customer's existing structured data and include key columns from various sources (client, account, portfolio, orders).  It also has some columns added which are feature engineering from previous call transcript ai processing  
     * **`CUSTOMER` Table Schema (Example):**

| Column Name | Data Type | Description |
| :---- | :---- | :---- |
| `CUSTOMER_ID` | VARCHAR | Unique identifier for the customer |
| `CUSTOMER_NAME` | VARCHAR | Customer's full name |
| `AGE` | INTEGER | Customer's age |
| `TENURE_YEARS` | INTEGER | Years as a customer member |
| `ACCOUNT_BALANCE` | DECIMAL(18,2) | Current superannuation balance |
| `INVESTMENT_OPTION` | VARCHAR | E.g., "Growth," "Balanced," "Conservative" |
| `RECENT_TRANSACTIONS` | INTEGER | Number of transactions in last 30 days |
| `LAST_INTERACTION_DATE` | DATE | Date of last customer interaction |
| `PRODUCT_HOLDINGS` | ARRAY | JSON array of products held (e.g.,) |
| `CONTACT_PREFERENCE` | VARCHAR | E.g., "Email", "Phone", "SMS"    |
| `CALL_FREQUENCY_LAST_MONTH` | NUMBER | Number of calls in the last month |
| `AVG_SENTIMENT_LAST_3_CALLS` | NUMBER | Average sentiment of the last three calls |
| `NUM_NEGATIVE_CALLS_LAST_6_MONTHS` | NUMBER | Number of negative calls in the past 6 months  |
| `HAS_CHURN_INTENT_LAST_MONTH`  | VARCHAR | TRUE or FALSE (boolean based on `PRIMARY_INTENT from call transcripts`)  |
|  |  |  |

Export to Sheets

2. **Advanced Data Processing & Enrichment (Snowflake Cortex AI):**  
   * Create a new table, `ENRICHED_TRANSCRIPTS_REALTIME`, to store the results of AI processing.  To enable demos, the demo person will have a button to clear this table out or to process any raw call record.  This is used to simulate a financial agent getting AI assistance in near real time during a call.    
   * Create a new table `ENRICHED_TRANSCRIPTS_ALL,`to store all the results of AI processing.  This enables demos to managers and text2sql where we want to analyse the enriched results of all 100 records.  This is used by managers to analyse trends, behaviours, results, etc…  
   * **Enhanced SQL Functions (Snowflake Cortex AI):** Utilize advanced built-in LLM functions directly in SQL to process the `TRANSCRIPT_TEXT` column from the raw staging table.  
     * **Enhanced Sentiment Analysis:** Use AI_CLASSIFY to extract both sentiment scores and emotional states (e.g., frustrated, satisfied, angry).    
     * **Summarization:** Use AI_SUMMARIZE to generate concise call summaries.    
     * **Intent Detection/Topic Extraction:** Use AI_CLASSIFY to extract specific intents and key topics with structured JSON output.
     * **Customer Journey Analysis:** Use AI_AGG to analyze patterns across multiple transcripts for each customer.    
     * **Note:** Use claude-4-sonnet for all AI processing.
     * **`ENRICHED_CALL_TRANSCRIPTS` Table Schema (Updated):**

| Column Name | Data Type | Description |
| :---- | :---- | :---- |
| `CALL_ID` | VARCHAR | Foreign key to raw call data |
| `CUSTOMER_ID` | VARCHAR | Foreign key to CUSTOMER table |
| `CALL_TIMESTAMP` | TIMESTAMP | Timestamp of the call |
| `TRANSCRIPT_TEXT` | VARCHAR | Original transcript text |
| `SENTIMENT_SCORE` | FLOAT | Numerical sentiment score |
| `SENTIMENT_LABEL` | VARCHAR | E.g., "Positive", "Negative", "Neutral"   |
| `EMOTIONAL_STATE` | VARCHAR | E.g., "Angry", "Frustrated", "Satisfied", "Happy" |
| `PRIMARY_INTENT` | VARCHAR | E.g., "Complaint", "Investment Inquiry", "Churn Risk" |
| `CALL_SUMMARY` | VARCHAR | AI-generated summary of the call |
| `KEY_TOPICS` | ARRAY | JSON array of extracted topics |
| `CUSTOMER_INSIGHTS` | VARCHAR | AI_AGG generated cross-transcript insights |

3. **ML-Powered Churn Prediction & AI-Generated NBA:**  
   * **Feature Engineering:** Combine structured customer data with AI-extracted insights (sentiment trends, intent patterns, emotional states) to create comprehensive feature sets for ML training.
   * **Model Training:** Use SNOWFLAKE.ML.CLASSIFICATION to train churn prediction models on historical customer data with proper train/test/validation splits.
   * **Model Deployment & Inference:** Register the trained model in Snowflake Model Registry. Run real-time inference on current customer data to generate `CHURN_PROBABILITY` and `CHURN_RISK_SCORE` for each active member.  
   * **ML Model Performance:** Include model evaluation metrics (accuracy, precision, recall, F1-score) for demo credibility.
   * **AI-Powered NBA Generation:** Use AI_COMPLETE with claude-4-sonnet to generate personalized `NEXT_BEST_ACTION` recommendations based on:
     * ML churn prediction scores and confidence levels
     * AI-extracted customer insights and emotional states
     * Customer profile and historical interactions
     * Business rules and available actions
   * **Demo Scenarios:** Create preset customer scenarios that demonstrate various churn risk levels and NBA types for reliable demo flow.
   * **Customer Analytics Schema:**

| Column Name | Data Type | Description |
| :---- | :---- | :---- |
| `CUSTOMER_ID` | VARCHAR | Foreign key to CUSTOMER table |
| `CHURN_PROBABILITY` | FLOAT | ML model output (0.0-1.0) |
| `CHURN_RISK_SCORE` | VARCHAR | "Low", "Medium", "High" based on probability thresholds |
| `MODEL_CONFIDENCE` | FLOAT | ML model confidence score |
| `NEXT_BEST_ACTION` | VARCHAR | AI-generated personalized recommendation |
| `NBA_REASONING` | VARCHAR | AI explanation for the recommended action |
| `LAST_UPDATED` | TIMESTAMP | When the prediction was last updated |

**III. Presentation Layer - Enhanced with ML Insights**

1. **Streamlit in Snowflake (Interactive Application):**  
   * **Deployment:** Develop and deploy the Streamlit application directly within Snowflake. This eliminates data movement and ensures security.    
   * **Front-Line Advisor View:**  
     * A search bar to look up `CUSTOMER_ID`.  
     * Displays `CUSTOMER_NAME`, `ACCOUNT_BALANCE`, `INVESTMENT_OPTION`, `CHURN_PROBABILITY`, `CHURN_RISK_SCORE`, `MODEL_CONFIDENCE`, and `NEXT_BEST_ACTION`.  
     * A section showing recent call transcripts, their `SENTIMENT_LABEL`, `EMOTIONAL_STATE`, `PRIMARY_INTENT`, and `CALL_SUMMARY`.  
     * Simple charts showing customer's sentiment trend over time and churn probability evolution.
     * AI reasoning display showing why specific NBAs were recommended.  
   * **Manager View:**  
     * Dashboard with aggregate metrics:  
       * Overall sentiment distribution (pie chart: positive, neutral, negative).  
       * Trend of negative sentiment calls over time (line chart).  
       * Distribution of `CHURN_RISK_SCORE` across all members (bar chart).  
       * ML model performance metrics dashboard.
       * Top 5 `PRIMARY_INTENT` categories from calls.  
       * Effectiveness of `NEXT_BEST_ACTION` (e.g., if a recommended action was taken and churn was avoided).  
     * Ability to filter by `INVESTMENT_OPTION`, `AGE` range, churn risk levels, etc.  
2. **Snowflake Intelligence (Natural Language Querying):**  
   * This will be as separate task towards the end of the project.  Some assistance may be requested by Cursor to help complete this activity  
   * In summary, a YAML file (i.e. Snowflake Semantic Model) will be generated to enable text 2 sql queries against interesting tables.    
   * I will create an agent and enable Snowflake Intelligence to read from the yaml  
   * **Manager Interaction:** Managers can use a natural language interface to ask questions like:  
     * "Show me the average churn probability for customers in the 'Growth' investment option."  
     * "Which customers with a 'High' churn risk score have called about 'fees' in the last month?"  
     * "What are the top 3 reasons for negative customer sentiment this quarter?"  
     * "How many customers received a 'retirement planning' NBA last week and what was the model confidence?"  
     * "Show me ML model performance metrics for the current churn prediction model."
   * Snowflake Cortex AI's "Cortex Analyst" feature will convert these natural language queries into SQL, allowing managers to explore data without writing code. 

