"""
Connection Helper Module for Superannuation Transcripts Demo
===========================================================

This module provides a unified connection interface that works in both:
1. Local Streamlit development environment
2. Streamlit in Snowflake hosted environment

Based on the pattern from Reference/nation_app.py
"""

import streamlit as st
import pandas as pd
import snowflake.connector
import tomli
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark import Session
from typing import Union, Optional, Dict, Any
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SnowflakeConnectionHelper:
    """
    Helper class to manage Snowflake connections for dual deployment environments
    """
    
    def __init__(self):
        self.connection = None
        self.session = None
        self.connection_type = None
        
    @st.cache_resource(show_spinner="🔌 Connecting to Snowflake...")
    def get_connection(_self) -> Union[Session, snowflake.connector.SnowflakeConnection]:
        """
        Get Snowflake connection that works in both local and hosted environments
        
        Returns:
            Union[Session, SnowflakeConnection]: Connection object
        """
        if _self.connection is not None:
            return _self.connection
            
        # Method 1: Try to get active session (Streamlit in Snowflake)
        try:
            session = get_active_session()
            if session:
                _self.connection = session
                _self.connection_type = "snowpark_session"
                logger.info("✅ Connected using Snowpark session (Streamlit in Snowflake)")
                return session
        except Exception as e:
            logger.debug(f"Snowpark session not available: {e}")
            
        # Method 2: Try local connection using config file
        try:
            config_path = '/Users/sweingartner/.snowflake/config.toml'
            with open(config_path, 'rb') as f:
                config = tomli.load(f)
            
            # Get the default connection name
            default_conn = config.get('default_connection_name')
            if not default_conn:
                st.error("❌ No default connection specified in config.toml")
                return None
                
            # Get the connection configuration
            conn_params = config.get('connections', {}).get(default_conn)
            if not conn_params:
                st.error(f"❌ Connection '{default_conn}' not found in config.toml")
                return None
            
            # Create connection
            conn = snowflake.connector.connect(**conn_params)
            _self.connection = conn
            _self.connection_type = "connector"
            logger.info("✅ Connected using local connector")
            return conn
            
        except FileNotFoundError:
            st.error("❌ Snowflake config file not found. Please set up your local connection.")
            return None
        except Exception as e:
            st.error(f"❌ Failed to connect to Snowflake: {str(e)}")
            logger.error(f"Connection failed: {e}")
            return None
    
    def execute_query(self, query: str, params: Optional[Dict[str, Any]] = None) -> pd.DataFrame:
        """
        Execute a query and return results as a pandas DataFrame
        
        Args:
            query (str): SQL query to execute
            params (dict, optional): Query parameters
            
        Returns:
            pd.DataFrame: Query results
        """
        conn = self.get_connection()
        if not conn:
            return pd.DataFrame()
            
        try:
            if self.connection_type == "snowpark_session":
                # Use Snowpark session
                df = conn.sql(query).to_pandas()
            else:
                # Use regular connection
                cursor = conn.cursor()
                if params:
                    cursor.execute(query, params)
                else:
                    cursor.execute(query)
                
                # Get column names
                columns = [col[0] for col in cursor.description]
                results = cursor.fetchall()
                df = pd.DataFrame(results, columns=columns)
                cursor.close()
                
            return df
            
        except Exception as e:
            st.error(f"❌ Query execution failed: {str(e)}")
            logger.error(f"Query failed: {e}")
            return pd.DataFrame()
    
    def execute_non_query(self, query: str, params: Optional[Dict[str, Any]] = None) -> bool:
        """
        Execute a non-query SQL statement (INSERT, UPDATE, DELETE, etc.)
        
        Args:
            query (str): SQL statement to execute
            params (dict, optional): Query parameters
            
        Returns:
            bool: True if successful, False otherwise
        """
        conn = self.get_connection()
        if not conn:
            return False
            
        try:
            if self.connection_type == "snowpark_session":
                # Use Snowpark session
                conn.sql(query).collect()
            else:
                # Use regular connection
                cursor = conn.cursor()
                if params:
                    cursor.execute(query, params)
                else:
                    cursor.execute(query)
                cursor.close()
                
            return True
            
        except Exception as e:
            st.error(f"❌ Query execution failed: {str(e)}")
            logger.error(f"Non-query failed: {e}")
            return False
    
    def get_connection_info(self) -> Dict[str, str]:
        """
        Get information about the current connection
        
        Returns:
            dict: Connection information
        """
        conn = self.get_connection()
        if not conn:
            return {"status": "disconnected"}
            
        try:
            if self.connection_type == "snowpark_session":
                # Get session info
                current_db = conn.get_current_database()
                current_schema = conn.get_current_schema()
                current_warehouse = conn.get_current_warehouse()
                
                return {
                    "status": "connected",
                    "type": "Snowpark Session (Streamlit in Snowflake)",
                    "database": current_db,
                    "schema": current_schema,
                    "warehouse": current_warehouse
                }
            else:
                # Get connection info
                cursor = conn.cursor()
                cursor.execute("SELECT CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_WAREHOUSE()")
                result = cursor.fetchone()
                cursor.close()
                
                return {
                    "status": "connected",
                    "type": "Local Connection",
                    "database": result[0],
                    "schema": result[1],
                    "warehouse": result[2]
                }
                
        except Exception as e:
            logger.error(f"Failed to get connection info: {e}")
            return {"status": "error", "message": str(e)}
    
    def test_connection(self) -> bool:
        """
        Test the connection by running a simple query
        
        Returns:
            bool: True if connection is working, False otherwise
        """
        try:
            df = self.execute_query("SELECT 1 as test")
            return len(df) > 0 and df.iloc[0, 0] == 1
        except Exception as e:
            logger.error(f"Connection test failed: {e}")
            return False
    
    def close_connection(self):
        """
        Close the connection (for regular connections only)
        """
        if self.connection and self.connection_type == "connector":
            try:
                self.connection.close()
                logger.info("Connection closed")
            except Exception as e:
                logger.error(f"Failed to close connection: {e}")
        
        self.connection = None
        self.connection_type = None


# Global connection helper instance
@st.cache_resource
def get_connection_helper() -> SnowflakeConnectionHelper:
    """
    Get a cached instance of the connection helper
    
    Returns:
        SnowflakeConnectionHelper: Connection helper instance
    """
    return SnowflakeConnectionHelper()


# Convenience functions for common operations
def execute_query(query: str, params: Optional[Dict[str, Any]] = None) -> pd.DataFrame:
    """
    Execute a query using the global connection helper
    
    Args:
        query (str): SQL query to execute
        params (dict, optional): Query parameters
        
    Returns:
        pd.DataFrame: Query results
    """
    helper = get_connection_helper()
    return helper.execute_query(query, params)


def execute_non_query(query: str, params: Optional[Dict[str, Any]] = None) -> bool:
    """
    Execute a non-query SQL statement using the global connection helper
    
    Args:
        query (str): SQL statement to execute
        params (dict, optional): Query parameters
        
    Returns:
        bool: True if successful, False otherwise
    """
    helper = get_connection_helper()
    return helper.execute_non_query(query, params)


def get_connection_info() -> Dict[str, str]:
    """
    Get connection information using the global connection helper
    
    Returns:
        dict: Connection information
    """
    helper = get_connection_helper()
    return helper.get_connection_info()


def test_connection() -> bool:
    """
    Test the connection using the global connection helper
    
    Returns:
        bool: True if connection is working, False otherwise
    """
    helper = get_connection_helper()
    return helper.test_connection()


def display_connection_status():
    """
    Display connection status in Streamlit UI
    """
    info = get_connection_info()
    
    if info["status"] == "connected":
        st.success(f"✅ Connected to Snowflake via {info['type']}")
        
        # Show connection details
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Database", info.get("database", "N/A"))
        with col2:
            st.metric("Schema", info.get("schema", "N/A"))
        with col3:
            st.metric("Warehouse", info.get("warehouse", "N/A"))
            
    elif info["status"] == "disconnected":
        st.error("❌ Not connected to Snowflake")
    else:
        st.error(f"❌ Connection error: {info.get('message', 'Unknown error')}")


# Demo-specific helper functions
def setup_demo_context():
    """
    Set up the demo database context
    """
    setup_queries = [
        "USE DATABASE SUPERANNUATION",
        "USE SCHEMA TRANSCRIPTS",
        "USE WAREHOUSE MYWH"
    ]
    
    for query in setup_queries:
        execute_non_query(query)


def safe_ai_call(func, *args, **kwargs):
    """
    Wrapper for AI service calls with error handling
    
    Args:
        func: Function to call
        *args: Function arguments
        **kwargs: Function keyword arguments
        
    Returns:
        Result of function call or None if error
    """
    try:
        return func(*args, **kwargs)
    except Exception as e:
        st.warning(f"⚠️ AI processing temporarily unavailable: {str(e)}")
        logger.warning(f"AI call failed: {e}")
        return None


# Cache configuration for demo optimization
@st.cache_data(ttl=300)  # Cache for 5 minutes
def cached_query(query: str, params: Optional[Dict[str, Any]] = None) -> pd.DataFrame:
    """
    Cached version of execute_query for better demo performance
    
    Args:
        query (str): SQL query to execute
        params (dict, optional): Query parameters
        
    Returns:
        pd.DataFrame: Cached query results
    """
    return execute_query(query, params) 