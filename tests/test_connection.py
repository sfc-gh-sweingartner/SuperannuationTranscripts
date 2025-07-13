"""
Test Script for Superannuation Transcripts Demo - Connection and Setup
=====================================================================

This script tests the connection helper and basic database setup.
Run this after setting up the database objects to verify everything works.
"""

import sys
import os
import streamlit as st
import pandas as pd

# Add the src directory to the Python path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'src'))

# Import our connection helper
from connection_helper import (
    get_connection_helper,
    execute_query,
    execute_non_query,
    get_connection_info,
    test_connection,
    setup_demo_context,
    display_connection_status
)

def test_basic_connection():
    """Test basic connection functionality"""
    st.header("🔌 Connection Test")
    
    # Test connection
    if test_connection():
        st.success("✅ Basic connection test passed!")
    else:
        st.error("❌ Basic connection test failed!")
        return False
    
    # Display connection info
    display_connection_status()
    
    return True

def test_database_objects():
    """Test that all required database objects exist"""
    st.header("🗄️ Database Objects Test")
    
    # Set up demo context
    setup_demo_context()
    
    # Test tables exist
    tables_query = """
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'TRANSCRIPTS' 
    AND table_name IN ('RAW_CALL_TRANSCRIPTS', 'CUSTOMER', 'ENRICHED_TRANSCRIPTS_ALL', 'ENRICHED_TRANSCRIPTS_REALTIME')
    ORDER BY table_name
    """
    
    tables_df = execute_query(tables_query)
    
    expected_tables = ['CUSTOMER', 'ENRICHED_TRANSCRIPTS_ALL', 'ENRICHED_TRANSCRIPTS_REALTIME', 'RAW_CALL_TRANSCRIPTS']
    
    if len(tables_df) == len(expected_tables):
        st.success(f"✅ All {len(expected_tables)} required tables found:")
        for table in tables_df['TABLE_NAME'].values:
            st.write(f"  - {table}")
    else:
        st.error("❌ Missing tables detected!")
        st.write("Expected:", expected_tables)
        st.write("Found:", tables_df['TABLE_NAME'].tolist())
        return False
    
    # Test views exist
    views_query = """
    SELECT table_name 
    FROM information_schema.views 
    WHERE table_schema = 'TRANSCRIPTS' 
    AND table_name IN ('CUSTOMER_INSIGHTS', 'DASHBOARD_METRICS', 'DATA_QUALITY_REPORT')
    ORDER BY table_name
    """
    
    views_df = execute_query(views_query)
    
    expected_views = ['CUSTOMER_INSIGHTS', 'DASHBOARD_METRICS', 'DATA_QUALITY_REPORT']
    
    if len(views_df) == len(expected_views):
        st.success(f"✅ All {len(expected_views)} required views found:")
        for view in views_df['TABLE_NAME'].values:
            st.write(f"  - {view}")
    else:
        st.warning("⚠️ Some views may be missing")
        st.write("Expected:", expected_views)
        st.write("Found:", views_df['TABLE_NAME'].tolist())
    
    return True

def test_data_loading():
    """Test data loading status"""
    st.header("📊 Data Loading Test")
    
    # Test call transcripts data
    transcripts_query = "SELECT COUNT(*) as record_count FROM RAW_CALL_TRANSCRIPTS"
    transcripts_df = execute_query(transcripts_query)
    
    transcript_count = transcripts_df.iloc[0, 0] if len(transcripts_df) > 0 else 0
    
    if transcript_count > 0:
        st.success(f"✅ Call transcripts loaded: {transcript_count} records")
    else:
        st.warning("⚠️ No call transcript records found. Run the data loading script.")
    
    # Test customer data
    customer_query = "SELECT COUNT(*) as record_count FROM CUSTOMER"
    customer_df = execute_query(customer_query)
    
    customer_count = customer_df.iloc[0, 0] if len(customer_df) > 0 else 0
    
    if customer_count > 0:
        st.success(f"✅ Customer data loaded: {customer_count} records")
    else:
        st.warning("⚠️ No customer records found. Run the customer data creation script.")
    
    # Test data quality
    if transcript_count > 0:
        quality_query = "SELECT * FROM DATA_QUALITY_REPORT"
        quality_df = execute_query(quality_query)
        
        if len(quality_df) > 0:
            st.subheader("📈 Data Quality Report")
            st.dataframe(quality_df)
        
    return transcript_count > 0 and customer_count > 0

def test_sample_queries():
    """Test sample queries that will be used in the demo"""
    st.header("🔍 Sample Queries Test")
    
    # Test customer insights view
    customer_insights_query = """
    SELECT 
        CUSTOMER_ID,
        CUSTOMER_NAME,
        CHURN_RISK_SCORE,
        CHURN_PROBABILITY,
        NEXT_BEST_ACTION
    FROM CUSTOMER_INSIGHTS 
    WHERE CHURN_RISK_SCORE = 'High'
    LIMIT 3
    """
    
    insights_df = execute_query(customer_insights_query)
    
    if len(insights_df) > 0:
        st.success("✅ Customer insights query working:")
        st.dataframe(insights_df)
    else:
        st.warning("⚠️ Customer insights query returned no results")
    
    # Test dashboard metrics
    dashboard_query = "SELECT * FROM DASHBOARD_METRICS"
    dashboard_df = execute_query(dashboard_query)
    
    if len(dashboard_df) > 0:
        st.success("✅ Dashboard metrics query working:")
        st.dataframe(dashboard_df)
    else:
        st.warning("⚠️ Dashboard metrics query returned no results")
    
    return len(insights_df) > 0

def test_demo_scenarios():
    """Test specific demo scenarios"""
    st.header("🎭 Demo Scenarios Test")
    
    # Test high churn risk customers
    high_churn_query = """
    SELECT 
        CUSTOMER_ID,
        CUSTOMER_NAME,
        CHURN_RISK_SCORE,
        CHURN_PROBABILITY,
        NEXT_BEST_ACTION
    FROM CUSTOMER 
    WHERE CHURN_RISK_SCORE = 'High'
    ORDER BY CHURN_PROBABILITY DESC
    """
    
    high_churn_df = execute_query(high_churn_query)
    
    if len(high_churn_df) > 0:
        st.success(f"✅ High churn risk scenarios ready: {len(high_churn_df)} customers")
        st.dataframe(high_churn_df)
    else:
        st.error("❌ No high churn risk customers found for demo!")
    
    # Test upsell opportunities
    upsell_query = """
    SELECT 
        CUSTOMER_ID,
        CUSTOMER_NAME,
        CHURN_RISK_SCORE,
        AVG_SENTIMENT_LAST_3_CALLS,
        NEXT_BEST_ACTION
    FROM CUSTOMER 
    WHERE CHURN_RISK_SCORE = 'Low' 
    AND AVG_SENTIMENT_LAST_3_CALLS > 0.3
    """
    
    upsell_df = execute_query(upsell_query)
    
    if len(upsell_df) > 0:
        st.success(f"✅ Upsell opportunity scenarios ready: {len(upsell_df)} customers")
        st.dataframe(upsell_df)
    else:
        st.warning("⚠️ No upsell opportunity customers found")
    
    # Test retirement planning customers
    retirement_query = """
    SELECT 
        CUSTOMER_ID,
        CUSTOMER_NAME,
        AGE,
        ACCOUNT_BALANCE,
        NEXT_BEST_ACTION
    FROM CUSTOMER 
    WHERE AGE >= 55
    ORDER BY AGE DESC
    """
    
    retirement_df = execute_query(retirement_query)
    
    if len(retirement_df) > 0:
        st.success(f"✅ Retirement planning scenarios ready: {len(retirement_df)} customers")
        st.dataframe(retirement_df)
    else:
        st.warning("⚠️ No retirement planning customers found")
    
    return len(high_churn_df) > 0

def run_all_tests():
    """Run all tests and provide summary"""
    st.title("🧪 Superannuation Transcripts Demo - Phase 1 Tests")
    st.markdown("This test suite validates the Phase 1 foundation setup.")
    
    test_results = []
    
    # Run all tests
    test_results.append(("Connection", test_basic_connection()))
    test_results.append(("Database Objects", test_database_objects()))
    test_results.append(("Data Loading", test_data_loading()))
    test_results.append(("Sample Queries", test_sample_queries()))
    test_results.append(("Demo Scenarios", test_demo_scenarios()))
    
    # Summary
    st.header("📋 Test Summary")
    
    passed = sum(1 for _, result in test_results if result)
    total = len(test_results)
    
    if passed == total:
        st.success(f"🎉 All {total} tests passed! Phase 1 foundation is ready.")
    else:
        st.error(f"❌ {total - passed} out of {total} tests failed. Please review the issues above.")
    
    # Display results table
    results_df = pd.DataFrame(test_results, columns=['Test', 'Result'])
    results_df['Status'] = results_df['Result'].apply(lambda x: '✅ PASS' if x else '❌ FAIL')
    
    st.dataframe(results_df[['Test', 'Status']], use_container_width=True)
    
    return passed == total

if __name__ == "__main__":
    # Run when executed directly
    run_all_tests() 