# FAOSTAT Agriculture Data Engineering Pipeline

An end-to-end data engineering project that processes FAOSTAT agricultural production data using **Python, Pandas, SQL, and Google BigQuery**, following the **Medallion Architecture (Bronze, Silver, and Gold)**.

The project focuses on data ingestion, cleaning, transformation, validation, and analytical data preparation.

## Project Architecture

This project follows a three-layer data architecture to improve data quality, maintainability, and analytical usability.

### 1. Bronze Layer – Raw Data Ingestion

- Ingests 6 FAOSTAT CSV files using Python and Pandas.
- Reads CSV files from a configurable local directory.
- Standardizes column names by replacing special characters.
- Uploads raw datasets into Google BigQuery.
- Uses `if_exists='replace'` for full-refresh loading.

**Technology:** Python, Pandas, Pandas-Gbq.

### 2. Silver Layer – Data Cleaning and Standardization

The Silver Layer prepares raw datasets for reliable analysis.

Key transformations:

- Casts annual production columns (Y2019–Y2023) to `FLOAT64` in both Production and NOFLAG fact tables.
- Removes unnecessary whitespace from descriptions.
- Standardizes Area names using uppercase formatting.
- Standardizes Element descriptions using lowercase formatting.
- Handles missing Area names using `COALESCE` with `UNKNOWN`.
- Uses `DISTINCT` to create cleaned lookup tables.

**Silver Layer tables:**
- Production fact table
- NOFLAG fact table
- Area Codes dimension table
- Elements dimension table
- Flags dimension table
- Item Codes dimension table

**Technology:** Google BigQuery SQL.

### 3. Gold Layer – Analytical Transformation

The Gold Layer creates analytical tables from the cleaned Silver data.

Key transformations:

- Converts annual columns (Y2019–Y2023) into a long-format structure using `UNPIVOT`.
- Extracts year values into a separate `year` column.
- Joins Area, Element, and Item dimension tables with production data.
- Creates Canada-specific production aggregations by Area, Item, Year, and Unit.
- Filters production records before calculating production rankings.
- Uses the `RANK()` window function to rank production across areas and items, partitioned by Unit.
- Creates a clustered analytical table using `CLUSTER BY Area, Item`.
- Reuses the transformed time-series table instead of repeating the UNPIVOT operation.

**Technology:** Google BigQuery SQL.

## Dataset

**Source:** FAOSTAT – Food and Agriculture Organization of the United Nations.

The project uses 6 CSV datasets related to agricultural production, including production records and supporting lookup data.

The production dataset contains annual values from 2019 to 2023.

## Technology Stack

- Python
- Pandas
- Pandas-Gbq
- Google BigQuery
- SQL
- Git and GitHub

## Project Structure

```text
FAOSTAT-Agriculture-Data/
│
├── raw_data/
│   └── 6 CSV files
│
├── README.md
├── bronze_layer.py
├── config.py
├── silver_layer.sql
├── gold_layer.sql
├── requirements.txt
└── .gitignore
```

## Configuration

Update `config.py` with your local CSV directory and Google Cloud project ID.

```python
csv_file = r'YOUR_LOCAL_PATH\raw_data'

project_id = 'YOUR_GOOGLE_CLOUD_PROJECT_ID'

dataset_name = 'Bronze_FAOSTAT_Agriculture_Data'
```

The local CSV directory and Google Cloud project ID are configurable through this file.

## Setup and Installation

### 1. Clone the repository

```bash
git clone https://github.com/tanvir1396-byte/FAOSTAT-Agriculture-Data.git

cd FAOSTAT-Agriculture-Data
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Google Cloud Authentication

Authenticate using Google Cloud Application Default Credentials:

```bash
gcloud auth application-default login
```

Make sure the authenticated Google account has the required BigQuery permissions.

### 4. Configure the project

Update `config.py` with your local CSV directory and Google Cloud project ID.

## Pipeline Execution

Execute the pipeline in the following order:

**Step 1: Bronze Layer**

Run the Python ingestion script:

```bash
python bronze_layer.py
```

**Step 2: Silver Layer**

Open and execute `silver_layer.sql` in the Google BigQuery SQL Editor.

**Step 3: Gold Layer**

Open and execute `gold_layer.sql` in the Google BigQuery SQL Editor.

## Data Validation Results

The following validations were performed in BigQuery after executing the pipeline.

| Validation | Result |
|---|---:|
| Source rows in time-series transformation | 350,013 |
| Transformed rows | 350,013 |
| Distinct years | 5 |
| Year range | 2019–2023 |
| Null production values | 0 |
| Canada aggregation rows | 599 |
| Non-Canada rows in Canada aggregation | 0 |
| Top performance ranking rows | 27,719 |
| Null ranking values | 0 |

Additional checks confirmed that the transformed Gold table retained the same row count as its source and that the annual production columns were stored as `FLOAT64`.

## Key Project Outcomes

- Built a three-layer data pipeline using the Medallion Architecture.
- Ingested 6 raw CSV datasets into BigQuery.
- Standardized production data and supporting lookup tables.
- Converted wide annual data into a long-format time-series structure.
- Integrated dimension tables with production records.
- Created Canada-specific annual production aggregations.
- Developed production rankings using SQL window functions.
- Improved analytical query organization through BigQuery clustering.

