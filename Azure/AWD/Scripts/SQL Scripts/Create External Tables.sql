CREATE DATABASE SCOPED CREDENTIAL cred_val
WITH
    IDENTITY = 'Managed Identity'

CREATE EXTERNAL DATA SOURCE source_silver
with(
    LOCATION = 'https://awdstoragedatalake.dfs.core.windows.net/silver',
    CREDENTIAL = cred_val
)

CREATE EXTERNAL DATA SOURCE source_gold
with
(
    LOCATION = 'https://awdstoragedatalake.dfs.core.windows.net/gold',
    CREDENTIAL = cred_val
)

CREATE EXTERNAL FILE FORMAT format_parquet
WITH(
    FORMAT_TYPE = PARQUET,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
)

--------------------
-- CREATE EXT TABLES
--------------------

-- CALENDAR

CREATE EXTERNAL TABLE gold.extcalendar
WITH(
    LOCATION = 'extcalendar',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)
AS 
SELECT * FROM gold.calendar

-- CUSTOMERS

CREATE EXTERNAL TABLE gold.extcustomers
WITH(
    LOCATION = 'extcustomers',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)
AS 
SELECT * FROM gold.customers

-- PRODUCTS

CREATE EXTERNAL TABLE gold.products
WITH(
    LOCATION = 'extproducts',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)
AS 
SELECT * FROM gold.products

-- RETURNS

CREATE EXTERNAL TABLE gold.returns_items
WITH(
    LOCATION = 'extreturns',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)
AS 
SELECT * FROM gold.returns_items

-- SALES

CREATE EXTERNAL TABLE gold.sales
WITH(
    LOCATION = 'extsales',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)
AS 
SELECT * FROM gold.sales

-- TERRITORY

CREATE EXTERNAL TABLE gold.territories
WITH(
    LOCATION = 'extterritories',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)
AS 
SELECT * FROM gold.territories

-- PRODUCTSUBCAT

CREATE EXTERNAL TABLE gold.productsubcat
WITH(
    LOCATION = 'extproductsubcat',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)
AS 
SELECT * FROM gold.productsubcat














