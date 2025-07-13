### **Functional Design: Hyper-Personalized Member Engagement & Retention Demo**

**I. Demo Objective**

The primary objective of this demo is to showcase how a superannuation company can leverage its existing customer call transcriptions, combined with core member data, to proactively identify members at risk of churning and deliver highly personalized "Next Best Actions" (NBA). This will demonstrate a shift from reactive service to proactive engagement, ultimately improving member retention and satisfaction, and aligning with the company’s strategic goals of enhancing member financial security and experience.

**II. User Personas & Needs**

The demo will cater to two key user personas:

1. **Front-Line Financial Advisors/Customer Service Agents:**  
   * **Need:** Real-time or near real-time insights into individual member sentiment, churn risk, and actionable recommendations for engagement.  
   * **View:** A dashboard for a specific member showing their call history, sentiment trends from calls, a churn prediction score, and a suggested "Next Best Action" (e.g., "Offer a personalized retirement planning session," "Proactively address recent complaint," "Suggest a specific investment product").  
   * **Interaction:** Ability to view details of specific call transcripts and the AI-extracted insights.  
2. **Managers/Team Leads (e.g., Call Center Supervisors, Member Engagement Managers):**  
   * **Need:** High-level aggregated insights into customer sentiment, churn trends across segments, and overall effectiveness of NBA strategies.  
   * **View:** Dashboards displaying aggregate sentiment scores over time, top reasons for negative sentiment, churn risk distribution across member segments, and the most effective NBAs.  
   * **Interaction:** Ability to drill down into specific segments or trends, and to ask natural language questions about the data (e.g., "Show me all members with high churn risk who called about investment fees last month").

**III. Key Features & Capabilities**

1. **Voice-to-Text Notes Ingestion:**  
   * This will not be demonstrated to the customer but to deliver the demo we must once off load pre-existing call transcriptions into Snowflake.   
   * Each transcription will be linked to a `CUSTOMER_ID`.  
2. **AI-Powered Transcript Interrogation (Cortex/Claude/Gemini Prompts):**  
   * **Sentiment Analysis:** Automatically detect the emotional tone (e.g., anger, disappointment, happiness, gratitude) and overall polarity (positive, negative, neutral) of each customer interaction within the transcript.    
   * **Intent Detection:** Identify the underlying purpose or goal of the customer's call (e.g., "account inquiry," "complaint about fees," "investment advice request," "churn intent").    
   * **Call Summarization:** Generate concise summaries of lengthy call transcripts, highlighting key discussion points and resolutions.    
   * **Key Topic Extraction:** Identify recurring themes or specific product/service mentions within conversations (e.g., "fees," "investment performance," "retirement planning," "digital access").    
3. **Integrated Member Data Model:**  
   * Combine the AI-extracted insights from call transcripts with a simplified, existing member data (e.g., client demographics, account details, portfolio holdings, order history). This unified view is crucial for holistic analysis.  
4. **Churn Prediction:**  
   * Develop and apply a machine learning model that predicts the likelihood of a member churning based on a combination of structured data (e.g., tenure, account balance, product usage) and unstructured insights from call transcripts (e.g., negative sentiment trends, specific churn-related intents, frequency of complaints).    
   * The model will output a `CHURN_RISK_SCORE` (e.g., Low, Medium, High).  
5. **Next Best Action (NBA) Generation:**  
   * Based on the churn prediction and the specific insights from call transcripts, the system will recommend a personalized "Next Best Action" for each at-risk member.    
   * Examples:  
     * High churn risk \+ complaint about fees \-\> "Offer a fee review session with a financial advisor."  
     * Medium churn risk \+ inquiry about retirement planning \-\> "Proactively schedule a personalized retirement planning consultation."  
     * High churn risk \+ general dissatisfaction \-\> "Initiate a proactive outreach call from a senior relationship manager."  
     * Low churn risk \+ interest in new products \-\> "Suggest a high-yield investment option."  
6. **Interactive Streamlit Application:**  
   * A user-friendly web application for both front-line advisors and managers, displaying the insights and recommendations in an intuitive visual format (charts, tables, individual member cards).    
   * Although we will have a lot of call transcripts preloaded into the database, the demo will act as though one call transcript has just come through right now.  So, we will immediately want to know a churn prediction, summary, nba, etc…  So, the application will be designed and build so that a demo person can push a button to select a recent call to process.  We will see things like summary, NBA, churn prediction are calculated and displayed very quickly.   That pushing of a button would simulate an automatic process that would run as voice to text data comes through  
7. **Snowflake Intelligence (Text-to-SQL):**  
   * Enable managers to ask ad-hoc questions about the aggregated data using natural language, receiving instant, accurate SQL-generated answers.  

**IV. Data Flow (High-Level)**

1. **Existing Call Transcriptions** (Input)  
2. **Simplified Customer Data** (Input)  
3. **Snowflake Cortex AI** (LLM processing for sentiment, intent, summary, topics)  
4. **Enriched Call Data Table** (in Snowflake)  
5. **Unified Customer Data Table** (in Snowflake, combining structured and enriched unstructured data)  
6. **Snowpark ML** (Churn Prediction Model Training & Inference)  
7. **Next Best Action Logic** (in Snowflake)  
8. **Streamlit in Snowflake** (Front-end visualization for advisors and managers)  
9. **Snowflake Intelligence** (Natural language querying for managers)

---

### **Technical Design: Hyper-Personalized Member Engagement & Retention Demo**

**I. Data Sources for Demo**

Gemini has generated 100 example call transcripts and these have been saved as a json file.  
It is here: /Users/sweingartner/Cursor/SuperannuationTranscripts/call_transcripts.json

We may need to modify that data to illustrate various capabilities

**II. Snowflake Data Architecture**

**Object names:**

Create the following objects in Snowlake: 

Database: SUPERANNUATION

Schema: TRANSCRIPTS

Stage: TRANSCRIPTS

Warehouse: use the existing MYWH warehouse

1. **Data Ingestion:**  
   * **Call Transcripts:** Load the selected call transcript data (from the provided json file) into a raw staging table in Snowflake. This table would typically have columns like `CALL_ID`, `CUSTOMER_ID`, `CALL_TIMESTAMP`, `TRANSCRIPT_TEXT`, `AGENT_ID`.  
   * **Customer Data:** Create a simplified `CUSTOMER` table in Snowflake. This table will simulate the superannuation customer’s existing structured data and include key columns from various sources (client, account, portfolio, orders).  It also has some columns added which are feature engineering from previous call transcript ai processing  
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

2. **Data Processing & Enrichment (Snowflake Cortex AI):**  
   * Create a new table, `ENRICHED_TRANSCRIPTS_REALTIME`, to store the results of AI processing.  To enable demos, the demo person will have a button to clear this table out or to process any raw call record.  This is used to simulate a financial agent getting AI assistance in near real time during a call.    
   * Create a new table `ENRICHED_TRANSCRIPTS_ALL,`to store all the results of AI processing.  This enables demos to managers and text2sql where we want to analyse the enriched results of all 100 records.  This is used by managers to analyse trends, behaviours, results, etc…  
   * **SQL Functions (Snowflake Cortex AI):** Utilize built-in LLM functions directly in SQL to process the `TRANSCRIPT_TEXT` column from the raw staging table.  
     * **Sentiment Analysis:** Use `SNOWFLAKE.CORTEX.SENTIMENT(TRANSCRIPT_TEXT)` to extract sentiment scores (e.g., positive, negative, neutral).    
     * **Summarization:** Use `SNOWFLAKE.CORTEX.SUMMARIZE(TRANSCRIPT_TEXT)` to generate concise call summaries.    
     * **Intent Detection/Topic Extraction:** Use `SNOWFLAKE.CORTEX.COMPLETE(LLM_MODEL, PROMPT)`to extract specific intents or key topics. For example, \`SELECT SNOWFLAKE.CORTEX.COMPLETE('claude-4-sonnet', 'Analyze the following call transcript and identify the customer''s primary intent (e.g., complaint, inquiry, request for advice, churn risk): ' |

| TRANSCRIPT\_TEXT)`.[3, 11] * *Note:* Use claude-4-sonnet* **`ENRICHED\_CALL\_TRANSCRIPTS\` Table Schema (Example):\*\*

| Column Name | Data Type | Description |
| :---- | :---- | :---- |
| `CALL_ID` | VARCHAR | Foreign key to raw call data |
| `CUSTOMER_ID` | VARCHAR | Foreign key to CUSTOMER table |
| `CALL_TIMESTAMP` | TIMESTAMP | Timestamp of the call |
| `TRANSCRIPT_TEXT` | VARCHAR | Original transcript text |
| `SENTIMENT_SCORE` | FLOAT | Numerical sentiment score |
| `SENTIMENT_LABEL` | VARCHAR | E.g., "Positive", "Negative", "Neutral", "Angry", "Disappointed"   |
| `PRIMARY_INTENT` | VARCHAR | E.g., "Complaint", "Investment Inquiry", "Churn Risk" |
| `CALL_SUMMARY` | VARCHAR | AI-generated summary of the call |
| `KEY_TOPICS` | ARRAY | JSON array of extracted topics |

3. **Churn Prediction Model and also NBA:  (This second of the design is messy with a lot of manual edits and needs corrections)**  
   * Initially, we will not train a churn prediction model or NBA but simply simulate that this has occurred.  In the future, we can add that capability into the demo  
   * `CUSTOMER_ANALYTICS_DATA` to predict churn.  
     * Define a `CHURN_LABEL` (e.g., 1 for churned, 0 for not churned) based on historical data.  
     * Train the model within Snowflake using Snowpark Python.  
   * **Model Deployment & Inference:** Register the trained model in Snowflake Model Registry. Run daily or weekly inference on current customer data to generate    
   * `CHURN_RISK_SCORE` for each active member.  
   * Add `CHURN_RISK_SCORE` (e.g., "Low", "Medium", "High") and `CHURN_PROBABILITY` (e.g., 0.0-1.0) columns to the `CUSTOMER` table or a new `CUSTOMER_INSIGHTS` table.  
   * Implement SQL logic or a simple Snowpark Python function to generate `NEXT_BEST_ACTION` recommendations. This will be rule-based for the demo's simplicity, combining `CHURN_RISK_SCORE` with `PRIMARY_INTENT` and `KEY_TOPICS` from recent calls.  
   * We will probably need to have a table with a list of known demo examples where some customers are happy customers and will carry out one type of transaction and some customers are not happy and so are a churn risk and so the agent needs to carry out a different action.  The text of the simulated calls needs to have various examples to demonstrate.  So, for example, every time I demo “customer 10” then he is always likely to churn and we already know will happen.     
   * **Example SQL Logic:**  
     SQL

```
UPDATE CUSTOMER_INSIGHTS
SET NEXT_BEST_ACTION = CASE
    WHEN CHURN_RISK_SCORE = 'High' AND PRIMARY_INTENT = 'Complaint' THEN 'Proactive call from senior relationship manager to address complaint.'
    WHEN CHURN_RISK_SCORE = 'High' AND PRIMARY_INTENT = 'Investment Inquiry' THEN 'Offer personalized investment review session.'
    WHEN CHURN_RISK_SCORE = 'Medium' AND KEY_TOPICS LIKE '%retirement planning%' THEN 'Suggest a free retirement planning consultation.'
    WHEN CHURN_RISK_SCORE = 'Low' AND PRODUCT_HOLDINGS NOT LIKE '%Pension Account%' THEN 'Recommend exploring pension account options.'
    ELSE 'Standard personalized communication.'
END;
```

   *   
   * Add `NEXT_BEST_ACTION` column to the `CUSTOMER_INSIGHTS` table.

**III. Presentation Layer**

1. **Streamlit in Snowflake (Interactive Application):**  
   * **Deployment:** Develop and deploy the Streamlit application directly within Snowflake. This eliminates data movement and ensures security.    
   * **Front-Line Advisor View:**  
     * A search bar to look up `CUSTOMER_ID`.  
     * Displays `CUSTOMER_NAME`, `ACCOUNT_BALANCE`, `INVESTMENT_OPTION`, `CHURN_RISK_SCORE`, and `NEXT_BEST_ACTION`.  
     * A section showing recent call transcripts, their `SENTIMENT_LABEL`, `PRIMARY_INTENT`, and `CALL_SUMMARY`.  
     * Simple charts showing customer's sentiment trend over time.  
   * **Manager View:**  
     * Dashboard with aggregate metrics:  
       * Overall sentiment distribution (pie chart: positive, neutral, negative).  
       * Trend of negative sentiment calls over time (line chart).  
       * Distribution of `CHURN_RISK_SCORE` across all members (bar chart).  
       * Top 5 `PRIMARY_INTENT` categories from calls.  
       * Effectiveness of `NEXT_BEST_ACTION` (e.g., if a recommended action was taken and churn was avoided).  
     * Ability to filter by `INVESTMENT_OPTION`, `AGE` range, etc.  
2. **Snowflake Intelligence (Natural Language Querying):**  
   * This will be as separate task towards the end of the project.  Some assistance may be requested by Cursor to help complete this activity  
   * In summary, a YAML file (i.e. Snowflake Semantic Model) will be generated to enable text 2 sql queries against interesting tables.    
   * I will create an agent and enable Snowflake Intelligence to read from the yaml  
   * **Manager Interaction:** Managers can use a natural language interface to ask questions like:  
     * "Show me the average sentiment score for customers in the 'Growth' investment option."  
     * "Which customers with a 'High' churn risk score have called about 'fees' in the last month?"  
     * "What are the top 3 reasons for negative customer sentiment this quarter?"  
     * "How many customers received a 'retirement planning' NBA last week?"  
   * Snowflake Cortex AI's "Cortex Analyst" feature will convert these natural language queries into SQL, allowing managers to explore data without writing 

