# Superannuation Transcripts Demo

## Project Overview

This demo showcases how a superannuation fund can leverage customer call transcripts for churn prediction and personalized engagement using Snowflake's integrated AI/ML platform. The solution demonstrates a **Hybrid AI + ML approach** that combines real-time AI processing with machine learning models to transform reactive customer service into proactive, data-driven member engagement.

## 🎯 Key Features

- **AI-Powered Transcript Analysis**: Sentiment analysis, intent detection, and call summarization
- **ML-Driven Churn Prediction**: Risk scoring and confidence metrics
- **Personalized Engagement**: AI-generated Next Best Actions (NBA)
- **Real-time Processing**: Simulated live transcript analysis
- **Multi-View Dashboard**: Advisor and manager perspectives
- **Modern UI/UX**: Streamlit-based interface with rich visualizations

## 📋 Application Structure

The demo includes 7 pages:

1. **📊 Data Foundation** - Database setup and data overview
2. **🤖 AI Processing Demo** - Real-time transcript analysis simulation
3. **👨‍💼 Advisor View** - Individual customer insights and recommendations
4. **📈 Manager Dashboard** - Aggregate insights and performance metrics
5. **🔬 ML Model Performance** - Model metrics and technical details
6. **❓ Demo Guide** - Instructions for presenting the solution
7. **📋 Solution Design** - Technical architecture and implementation status

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Snowflake account with appropriate permissions
- Configuration file at `~/.snowflake/config.toml`

### Installation
```bash
pip install -r requirements.txt
```

### Running the Demo
```bash
streamlit run src/streamlit_main.py
```

## 🏗️ Technical Architecture

### Platform Stack
- **Database**: Snowflake (SUPERANNUATION.TRANSCRIPTS schema)
- **AI Engine**: Snowflake Cortex AI (claude-4-sonnet)
- **ML Framework**: SNOWFLAKE.ML.CLASSIFICATION
- **Frontend**: Streamlit (local + Snowflake hosted)
- **Connection**: snowflake.connector + tomli config

### Data Flow
1. **Ingestion**: JSON transcripts → Snowflake tables
2. **AI Processing**: Cortex AI analysis (sentiment, intent, summarization)
3. **ML Processing**: Churn prediction models
4. **Personalization**: AI-generated recommendations
5. **Visualization**: Interactive dashboards

## 📊 Implementation Status

### ✅ Fully Implemented
- Snowflake connection and database schema
- Data loading and management scripts
- Multi-page Streamlit application
- Interactive visualizations and charts
- Demo scenarios with fallback data

### ⚠️ Simulated Components
- AI functions (AI_CLASSIFY, AI_AGG, AI_COMPLETE)
- ML model training (SNOWFLAKE.ML.CLASSIFICATION)
- Churn predictions (rule-based scoring)
- NBA generation (template-based responses)

### 🔮 Future Development
- Production AI/ML integration
- Real-time streaming connections
- Enterprise CRM integration
- Advanced security and compliance

## 📁 Project Structure

```
SuperannuationTranscripts/
├── src/
│   ├── streamlit_main.py          # Main application
│   ├── connection_helper.py       # Snowflake connection utilities
│   └── pages/                     # Individual demo pages
├── scripts/                       # Data loading and setup scripts
├── sql/                          # Database setup scripts
├── TRASH/                        # Obsolete files (post-testing cleanup)
├── Reference/                    # Design documents and examples
└── requirements.txt              # Python dependencies
```

## 🎭 Demo Scenarios

### High-Risk Customer (Maria Garcia)
- 78% churn probability
- Recent negative sentiment
- NBA: Urgent senior advisor intervention

### Growth Opportunity (John Smith)
- 18% churn probability
- Interest in ESG investing
- NBA: Personalized ESG portfolio consultation

### Real-time Processing
- Button-triggered analysis
- Instant AI insights
- Live recommendation generation

## 🔧 Configuration

Create `~/.snowflake/config.toml`:
```toml
[default]
account = "your_account"
user = "your_username"
password = "your_password"
warehouse = "MYWH"
database = "SUPERANNUATION"
schema = "TRANSCRIPTS"
```

## 📈 Business Value

### Immediate Demo Value
- Proof of concept for AI/ML-driven engagement
- Professional UI for stakeholder presentations
- Integration pattern demonstration

### Production Potential
- 15-25% churn reduction through proactive intervention
- Improved member satisfaction via personalization
- Operational efficiency gains
- Revenue growth through better retention

## 🔗 Links

- **Repository**: https://github.com/sfc-gh-sweingartner/SuperannuationTranscripts
- **Snowflake Account**: demo_sweingartner
- **Demo Environment**: Local + Snowflake hosted

## 📝 Notes

This is a **demonstration solution** designed to showcase Snowflake's AI/ML capabilities in a financial services context. The implementation uses a mix of real infrastructure and simulated components to provide a compelling demo experience while maintaining realistic technical architecture.

For production deployment, additional development would be required to integrate with actual Snowflake Cortex AI and ML services, implement real-time streaming, and add enterprise-grade security and compliance features.

---

*Testing Phase Complete - Solution Ready for Demo* 