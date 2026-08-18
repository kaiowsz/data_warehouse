# Data Warehouse & Data Mart Build: Production ETL Pipeline

An end-to-end Data Engineering pipeline built with **DuckDB** and **SQL**. It extracts job posting CSVs from Google Cloud Storage, models them into a Star Schema Data Warehouse, builds specialized Data Marts with incremental update capabilities (`MERGE`), and delivers advanced business analytics.

![Data Pipeline Architecture](./images/1_2_Project2_Data_Pipeline.png)

---

## 🧾 Project Overview

- **Extraction & Ingestion:** Remote CSV loading directly from Google Cloud Storage via DuckDB `httpfs`.
- **Dimensional Modeling:** Normalized **Star Schema** with fact tables, dimensions, and bridge tables for N:N relationships.
- **Analytical Data Marts:**
  - **Flat Mart:** Denormalized table utilizing DuckDB nested types (`ARRAY_AGG` + `STRUCT_PACK`).
  - **Skills Mart:** Time-series skill demand tracking with additive metrics over time.
  - **Priority Mart:** Role snapshot with production-ready **incremental MERGE (Upsert)** updates (`WHEN MATCHED`, `WHEN NOT MATCHED`, `WHEN NOT MATCHED BY SOURCE`).
- **Exploratory Data Analysis (EDA):** Business analytical queries answering market trends, salary distributions, and quarterly skill demands.
- **Orchestration:** Idempotent, automated execution via master script `build_dw_marts.sql`.

---

## 🧰 Tech Stack

- **Engine:** DuckDB (OLAP Database)
- **Language:** SQL (DDL, DML, Window Functions, Nested Arrays/Structs, MERGE)
- **Modeling:** Kimball Star Schema & Data Mart Architecture
- **Cloud Storage:** Google Cloud Storage (Remote CSV Sources)

---

## 📂 Repository Structure

```text
datawarehouse_pj/
├── 01_create_tables_dw.sql     # Star Schema DDL (Facts, Dimensions, Bridge)
├── 02_load_schema_dw.sql       # GCS Data Extraction & Ingestion
├── 03_create_flat_mart.sql     # Denormalized Flat Mart (Array/Struct)
├── 04_create_skills_mart.sql   # Skills Demand Time-Series Mart
├── 05_create_priority_mart.sql # Priority Roles Mart Initial Snapshot
├── 06_update_priority_mart.sql # Incremental MERGE (Upsert Pattern)
├── 07_data_analysis.sql        # Exploratory & Analytical Business Queries
├── build_dw_marts.sql          # Master Orchestration Script
└── images/                     # Architecture & Schema Diagrams
```

---

## 🏗️ Architecture & Data Marts

### 1. Data Warehouse (Star Schema)
Organizes raw data into a single source of truth: `company_dim`, `skills_dim`, `job_postings_fact`, and the bridge table `skills_job_dim`.

![Data Warehouse Schema](./images/1_2_Data_Warehouse.png)

---

### 2. Flat Mart (`flat_mart.job_postings`)
Denormalizes job postings and joins all dimensions into one line per job posting, storing skills as an array of structs (`ARRAY_AGG(STRUCT_PACK(...))`).

![Flat Mart Schema](./images/1_2_Flat_Mart.png)

---

### 3. Skills Demand Mart (`skills_mart`)
Tracks monthly skill demand across job roles. Includes `dim_skills`, `dim_date_month`, and `fact_skill_demand_monthly` with additive metrics.

![Skills Mart Schema](./images/1_2_Skills_Mart.png)

---

### 4. Priority Roles Mart (`priority_mart`)
Tracks priority job roles and maintains a snapshot table (`priority_jobs_snapshot`). Uses `MERGE INTO` to handle incremental `UPDATE`, `INSERT`, and `DELETE` operations atomically.

![Priority Mart Schema](./images/1_2_Priority_Mart.png)

---

## 📊 Data Analysis & Business Insights (`07_data_analysis.sql`)

The analytics script leverages the warehouse and marts to answer core business questions:

1. **Top Demanded Skills:** Uses `UNNEST()` to unwrap nested skill structs and rank top technologies with average salary metrics.
2. **Top Hiring Companies:** Aggregates hiring volume and salary offers per company for Data Engineering roles.
3. **Salary Distribution Brackets:** Categorizes jobs into custom salary buckets (`CASE WHEN`) and calculates market percentage distribution.
4. **Home Office vs. Presencial:** Evaluates remote vs. on-site salary differentials and market offer volume.
5. **Top Paying Companies in Priority Roles:** Employs `DENSE_RANK() OVER (PARTITION BY job_title_short ORDER BY avg_salary DESC)` to rank top-paying employers per role.
6. **Quarterly Skill Demand Trends:** Uses `PARTITION BY year_quarter` window functions on `skills_mart` to track top 5 quarterly technology shifts.

---

## 🚀 How to Run

Execute the complete ETL pipeline and analytics in a single command using DuckDB CLI:

```bash
duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"
```

---

## 💻 Key Data Engineering Concepts Demonstrated

- **Idempotency:** All scripts use `DROP ... IF EXISTS` and `CREATE OR REPLACE` for safe re-runs.
- **Many-to-Many Modeling:** Bridge tables (`skills_job_dim`) connecting fact and dimension tables.
- **Modern SQL Features:** `ARRAY_AGG`, `STRUCT_PACK`, `UNNEST`, `DATE_TRUNC`, `EXTRACT`, `GROUP BY ALL`.
- **Advanced Window Functions:** `DENSE_RANK() OVER (PARTITION BY ... ORDER BY ...)`.
- **Incremental Upserts:** Complete `MERGE` implementation with source/target matching logic.