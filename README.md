### Project Title: Data Warehousing, Analysis and Business Intelligence with SQL

#### Overview
This project involves the creation of a data warehouse using SQL to analyse water quality data. The project encompasses the full ETL (Extract, Transform, Load) process, designing a STAR schema for data organisation, and using SQL to perform data cleansing, transformation, and complex querying. Additionally, the project integrates machine learning techniques to predict future water quality trends, showcasing advanced analytical capabilities.

#### Dataset Description
The dataset used for this project is a publicly available water quality dataset provided by the environment agency, containing data from 2000 to 2016. The data includes various measurements related to water quality, such as pH levels, nitrate concentrations, and more. The dataset is initially available in multiple tables, which are consolidated into a single, comprehensive dataset for analysis.

#### Project Steps

1. **Data Extraction:**
   - The raw data, originally stored in Microsoft Access, was exported to an Oracle database using SQL.
   - Multiple tables were merged into a single dataset to facilitate further analysis.

2. **Data Transformation:**
   - **Designing the STAR Schema:** A STAR schema was designed, consisting of one fact table to store the main measurements and three dimension tables to store attributes related to samples, determinants, and time.
   - **Data Cleansing:** SQL was used to clean the data, including tasks like removing null values, standardising data formats, and splitting columns for better query performance.
   - **Data Loading:** The cleansed and transformed data was loaded into the fact and dimension tables using SQL's bulk insertion techniques.

3. **Data Verification:**
   - Verified the accuracy and integrity of the loaded data by running SQL queries to check for consistency across the fact and dimension tables.

4. **Statistical Analysis:**
   - Performed various SQL queries to generate statistical summaries, such as the number of measurements by location, average pH levels by year, and more.
   - Created complex queries to answer specific business questions related to water quality.

#### Key Features
- **ETL Process:** Demonstrates the complete ETL process using SQL, from data extraction and transformation to loading into a well-structured data warehouse.
- **STAR Schema Design:** Efficiently organises data using a STAR schema, optimising it for high-performance queries.
- **Data Cleansing:** Ensures data quality through rigorous cleansing techniques, making the dataset reliable for analysis.
- **Advanced SQL Queries:** Implements complex SQL queries for detailed data analysis and business intelligence reporting.

#### How to Use
- Download the `.sql` file and execute it in an Oracle or compatible SQL database environment.
- Review the SQL scripts for each step of the ETL process, from data extraction and transformation to loading and querying.
- Use the provided SQL queries to explore the dataset and generate insights related to water quality.

This project serves as a comprehensive guide to building and analysing a data warehouse using SQL, showcasing a range of skills from data engineering to data analysis and business intelligence.
