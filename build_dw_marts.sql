-- duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"

-- Create star schema tables
.read 01_create_tables_dw.sql

-- Load data from CSV files
.read 02_load_schema_dw.sql

-- Create flat mart
.read 03_create_flat_mart.sql

-- Create skills demand mart
.read 04_create_skills_mart.sql

-- Create priority roles mart
.read 05_create_priority_mart.sql

-- Update priority roles mart
.read 06_update_priority_mart.sql  