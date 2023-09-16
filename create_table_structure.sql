-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS company_analytics
WITH OWNER = postgres
ENCODING = 'UTF8'
LC_COLLATE = 'Russian_Russia.utf8'
LC_CTYPE = 'Russian_Russia.utf8'
TABLESPACE = pg_default
CONNECTION LIMIT = -1
IS_TEMPLATE = False;

-- Connect to the database
\c company_analytics;

-- Enable the "uuid-ossp" extension for generating UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Define the "dim_regions" table
CREATE TABLE dim_regions (
    "region_code" SERIAL PRIMARY KEY,
    "region_name" text NOT NULL
);

-- Define the "dim_dc" table
CREATE TABLE dim_dc (
    "region_code" SERIAL FOREIGN KEY REFERENCES dim_regions(region_code),
    "sku_internal_code" text FOREIGN KEY REFERENCES dim_sku_base(sku_internal_code),
    "stock_qty" int
);

-- Define the "dim_geo_base" tableeh                                                                                                                         
CREATE TABLE dim_geo_base (
    "pos_internal_code" text PRIMARY KEY NOT NULL,
    "region_code" SERIAL FOREIGN KEY REFERENCES dim_regions(region_code),
    "city" text,
    "address" text
);

-- Define the "dim_geo_mapping" table
CREATE TABLE dim_geo_mapping (
    "pos_ext_code" uuid PRIMARY KEY DEFAULT uuid_generate_v4() NOT NULL,
    "pos_internal_code" text FOREIGN KEY REFERENCES dim_geo_base(pos_internal_code)
);

-- Define the "dim_matrix_goals" table
CREATE TABLE dim_matrix_goals (
    "pos_internal_code" text REFERENCES dim_geo_base(pos_internal_code),
    "matrix" bigint NOT NULL,

);

-- Define the "dim_matrix_assortment" table
CREATE TABLE dim_matrix_assortment (
    "sku_internal_code" text FOREIGN KEY REFERENCES dim_sku_base(sku_internal_code),
    "matrix" bigint
);

-- Define the "dim_sku_base" table
CREATE TABLE dim_sku_base (
    "sku_internal_code" text PRIMARY KEY NOT NULL,
    "sku_internal_name" text,
    "manufacturer" text
);

-- Define the "dim_sku_mapping" table
CREATE TABLE dim_sku_mapping (
    "sku_ext_code" text PRIMARY KEY,
    "sku_internal_code" text,
    FOREIGN KEY ("sku_internal_code") REFERENCES dim_sku_base("sku_internal_code")
);

-- Define the "fact_daily_sales" table
CREATE TABLE fact_daily_sales (
    "sales_qty_rsv" double precision,
    "sales_qty_units" double precision,
    "date" date,
    "sku_ext_code" text,
    "pos_ext_code" uuid
);

-- Define the "fact_daily_stock" table
CREATE TABLE fact_daily_stock (
    "stock_qty" double precision,
    "date" date,
    "sku_ext_code" text,
    "pos_ext_code" uuid
);
