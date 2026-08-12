
-- Create star schema tables
.read 01_create_tables_dw.sql

-- Load data from CSV files
.read 02_load_schema_dw.sql

-- Create flat mart
.read 03_create_flat_mart.sql

