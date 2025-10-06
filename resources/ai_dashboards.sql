/* ================================================
   Step 1: turn on Snowflake Intelligence
   ================================================ */

USE ROLE ACCOUNTADMIN;
CREATE DATABASE IF NOT EXISTS snowflake_intelligence;
GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE PUBLIC;

CREATE SCHEMA IF NOT EXISTS snowflake_intelligence.agents;
GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE PUBLIC;

GRANT CREATE AGENT ON SCHEMA snowflake_intelligence.agents TO ROLE SYSADMIN;

/* ================================================
   Step 2: Get Documentation Agent
   ================================================ */

-- 1. Go to Snowflake Marketplace, search "Documentation" and find the Snowflake Documentation listing
-- 2. Subscribe to the listing
-- 3. Go to AI & ML on the left sidebar, and click on "Agents"
-- 4. Create a new agent with the following settings:
--    - Name: SNOWFLAKE_DOCUMENTATION_AGENT
--    - Display Name: Snowflake Documentation Agent
-- 5. Edit the agent, go into Tools and add a Cortex Search Serivce from the SNOWFLAKE_DOCUMENTATION database
--    - ID: SOURCE_URL
--    - Title Column: DOCUMENT_TITLE
-- 6. Save the agent
-- 7. Go to AI & ML on the left sidebar, and click on "Snowflake Intelligence"

/* ================================================
   Step 3: Build the App
   ================================================ */

-- Ask the agent to build a streamlit app. Here's the prompt:
/* ================================================

You are an expert Streamlit in Snowflake app developer and Snowflake SQL user.

Build a visually engaging and interactive Streamlit in Snowflake app for exploring US Economic Census Timeseries data. **You must use only the data available in the view `analytics.census.colorado_census_view` for all queries and visualizations in the app.**

**Important:**  
- The data in `analytics.census.colorado_census_view` is only for the state of Colorado and only contains data at the Colorado level. All metrics, charts, and analyses should be for Colorado only.
- Do not include any state comparison or multi-state analysis, as no other states are present in the data.
- Use the function `session = get_active_session()` to obtain the current Snowflake session, and use this session for all data queries.
- Use Streamlit in Snowflake Python syntax throughout.
- **Your output should be a single, complete .py script that can be copied and pasted to run the app.**

**App requirements:**
- The app should have multiple tabs for different types of analysis, including:
    - **Overview:** A large, full-width time series or bar chart showing economic trends (e.g., total value by year for Colorado).
    - **Industry Trends:** Explore top industries (by NAICS code) within Colorado.
- On the Overview tab, display a prominent chart of economic trends (e.g., total value by year for Colorado).
- Below the main chart, show two smaller visualizations side by side:
    - One with a breakdown by industry (e.g., top NAICS codes in Colorado).
    - One comparing different metrics or industries within Colorado for a selected year or period.
- Add interactive controls (dropdowns, sliders, etc.) to let users select industry (NAICS code), year, and metric (e.g., value, unit).
- Include summary statistics and highlight interesting insights (e.g., which industry has grown the most in Colorado, which sector leads in a given year).
- Make the app visually appealing, intuitive, and easy to use.

Here is the metadata for the view:
CREATE OR REPLACE VIEW analytics.census.colorado_census_view AS
SELECT gi.GEO_NAME,
       c.DATE::DATE AS DATE,
       c.VARIABLE_NAME,
       c.VALUE,
       c.UNIT
FROM snowflake_public_data_free.public_data_free.geography_index AS gi
LEFT JOIN snowflake_public_data_free.public_data_free.us_economic_census_timeseries AS c
  ON gi.GEO_ID = c.GEO_ID
WHERE gi.GEO_NAME = 'Colorado'
ORDER BY c.VARIABLE_NAME;

   ================================================ */

/* ================================================
   Step 4: Streamlit in Snowflake
   ================================================ */

-- 1. Copy and paste the .py script into a new Streamlit in Snowflake app
-- 2. Run the app
-- 3. If the app fails to run, copy the error message and provide it to the agent. Ask the agent to help you fix the app based on the error.
