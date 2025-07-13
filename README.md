# Superannuation Transcripts Demo

A demonstration application showing how Snowflake can leverage customer call transcripts for churn prediction and personalized engagement at a Superannuation Fund.

## 🎯 Demo Overview

This demo showcases:
- **AI-powered transcript analysis** using Snowflake Cortex AI
- **Churn prediction** based on call sentiment and patterns
- **Personalized Next Best Actions** for customer engagement
- **Dual deployment** (local development + Streamlit in Snowflake)
- **Real-time processing simulation** for live demos

## 🏗️ Architecture

- **Database**: Snowflake (SUPERANNUATION.TRANSCRIPTS)
- **AI Processing**: Snowflake Cortex AI (Claude-4-Sonnet, sentiment analysis)
- **Frontend**: Streamlit (local + Snowflake hosted)
- **Connection**: Dual-environment pattern (local config + Snowpark)

## 📋 Prerequisites

### Snowflake Account
- Account: `demo_sweingartner`
- Warehouse: `MYWH` (should already exist)
- Required privileges: CREATE DATABASE, USE WAREHOUSE, CORTEX AI access

### Local Development
- Python 3.8+
- Snowflake CLI or SnowSQL
- Local Snowflake connection configured

### Python Dependencies
```bash
pip install -r requirements.txt
```

## 🚀 Phase 1 Setup (Foundation)

### Step 1: Create Database Objects
```sql
-- Run this in your Snowflake account
@sql/01_create_database_objects.sql
```

### Step 2: Load Call Transcript Data
```bash
# Upload the JSON file to Snowflake stage
snowsql -f sql/02_load_call_transcripts.sql

# Or use PUT command in SnowSQL:
PUT file:///path/to/call_transcripts.json @SUPERANNUATION.TRANSCRIPTS.TRANSCRIPTS;
```

### Step 3: Create Customer Data
```sql
-- Run this to create synthetic customer data
@sql/03_create_customer_data.sql
```

### Step 4: Test the Setup
```bash
# Run the test suite
streamlit run tests/test_connection.py
```

## 🗄️ Database Schema

### Core Tables
- **RAW_CALL_TRANSCRIPTS**: Original call transcript data
- **CUSTOMER**: Customer master data with AI-derived insights
- **ENRICHED_TRANSCRIPTS_ALL**: Historical AI-processed transcripts
- **ENRICHED_TRANSCRIPTS_REALTIME**: Real-time demo processing table

### Key Views
- **CUSTOMER_INSIGHTS**: Combined customer and latest call data
- **DASHBOARD_METRICS**: Aggregated metrics for manager dashboard
- **DATA_QUALITY_REPORT**: Data quality monitoring

## 🔧 Configuration

### Local Development
Set up your local Snowflake connection in `~/.snowflake/config.toml`:
```toml
default_connection_name = "demo_sweingartner"

[connections.demo_sweingartner]
account = "demo_sweingartner"
user = "your_username"
password = "your_password"
# or use other auth methods like SSO
```

### Streamlit in Snowflake
No additional configuration needed - uses active Snowpark session.

## 🎭 Demo Scenarios

### High Churn Risk Customers
- **CUST003**: Maria Garcia - Technical issues, frustrated
- **CUST010**: Robert Wilson - Fee concerns, considering leaving
- **CUST015**: Jennifer Brown - Multiple complaints, high call frequency

### Upsell Opportunities
- **CUST004**: John Smith - Interested in ESG investing
- **CUST007**: Emma Thompson - High-value customer, positive sentiment
- **CUST012**: David Liu - Sustainable investing focus

### Retirement Planning
- **CUST005**: Emily White - Age 64, planning retirement
- **CUST008**: Peter Johnson - Age 59, pre-retirement planning

## 📁 File Structure

```
SuperannuationTranscripts/
├── sql/                          # Database setup scripts
│   ├── 01_create_database_objects.sql
│   ├── 02_load_call_transcripts.sql
│   └── 03_create_customer_data.sql
├── src/                          # Python source code
│   └── connection_helper.py      # Dual-environment connection
├── tests/                        # Test scripts
│   └── test_connection.py        # Phase 1 validation
├── .cursor/                      # Cursor rules and documentation
├── call_transcripts.json         # Sample call transcript data
└── README.md                     # This file
```

## ✅ Phase 1 Success Criteria

- [ ] All database objects created successfully
- [ ] Call transcript data loaded (100 records)
- [ ] Customer data created (25 customers)
- [ ] Connection helper works in both environments
- [ ] Test suite passes all tests
- [ ] Demo scenarios are ready

## 🔍 Testing

Run the comprehensive test suite:
```bash
streamlit run tests/test_connection.py
```

The test suite validates:
- Snowflake connection (local + hosted)
- Database objects creation
- Data loading completeness
- Sample queries functionality
- Demo scenarios readiness

## 📊 Data Quality

The demo includes built-in data quality monitoring:
- **Record counts**: Validate data loading
- **Data completeness**: Check for missing fields
- **Relationship integrity**: Verify FK relationships
- **Demo scenarios**: Ensure predictable outcomes

## 🚧 Next Phases

- **Phase 2**: AI Processing Implementation
- **Phase 3**: Business Logic Development
- **Phase 4**: Frontend Development
- **Phase 5**: Testing and Refinement
- **Phase 6**: Final Integration

## 🆘 Troubleshooting

### Connection Issues
- Verify Snowflake credentials
- Check network connectivity
- Ensure warehouse is running
- Validate database permissions

### Data Loading Issues
- Check file format and encoding
- Verify stage permissions
- Validate JSON structure
- Check for file size limits

### Test Failures
- Review connection configuration
- Check database object permissions
- Verify data loading completed
- Validate table structures

## 📞 Support

For issues or questions:
1. Check the test suite output
2. Review the connection helper logs
3. Validate database permissions
4. Consult Snowflake documentation

## 🎯 Demo Success Tips

1. **Test thoroughly** in both environments
2. **Use preset scenarios** for reliable demos
3. **Have backup plans** for technical issues
4. **Practice timing** for each demo section
5. **Focus on business value** over technical details

---

*This is a demo application for Snowflake sales purposes. Not intended for production use.* 