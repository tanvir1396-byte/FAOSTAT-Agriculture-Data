# FAOSTAT Agriculture Data - Medallion Architecture Pipeline

A complete end-to-end Data Engineering pipeline built using **Python (Pandas)** for data ingestion and **Google BigQuery (GBQ)** for data storage and transformation, implementing the **Medallion Architecture (Bronze - Silver - Gold)**.

---

## 🏗️ Architecture Overview

1. **Bronze Layer**: Raw CSV files ingested into BigQuery with automated column name cleaning using RegEx (`r'[\.\s\(\)]+'`) and type handling.
2. **Silver Layer**: Cleaned and standardized tables with proper casting (`FLOAT64`), trimming, lowercase mapping, and deduplication (`DISTINCT`).
3. **Gold Layer**: Analytical models, unpivoted long-format time-series fact tables, region/item aggregations, and ranked performance metrics optimized with table clustering (`CLUSTER BY`).

---

## 📁 Dataset Scope
Processing 6 primary FAOSTAT datasets:
- Crops & Livestock Production (`All_Data` & `All_Data_NOFLAG`)
- Area Codes & M49 Mappings
- Elements & Element Codes
- Flag Descriptions
- Item Codes & CPC Codes

---

## 🛠️ Tech Stack
- **Language**: Python
- **Libraries**: Pandas, Re (Regular Expressions)
- **Cloud Data Warehouse**: Google BigQuery (GBQ)
- **Version Control**: Git & GitHub