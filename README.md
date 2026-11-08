# FAOSTAT Agriculture Data – End-to-End Data Engineering Pipeline

An end-to-end Data Engineering project that processes FAOSTAT agricultural production datasets using **Python, Pandas, and Google BigQuery**, following the **Medallion Architecture (Bronze, Silver, and Gold)**.

The pipeline ingests raw agricultural datasets, performs data cleaning and standardization, transforms annual production data into an analytical time-series format, and builds aggregated and ranked analytical tables.

## 🏗️ Project Architecture

This project follows a three-layer Medallion Architecture to improve data quality, maintainability, and analytical usability.

### 1. Bronze Layer – Raw Data Ingestion

- Ingests six FAOSTAT CSV datasets into Google BigQuery.
- Uses Python and Pandas for CSV ingestion.
- Automatically infers data types during CSV ingestion.
- Cleans column names using Python Regular Expressions (RegEx).
- Loads raw datasets into BigQuery using `replace` mode.

### 2. Silver Layer – Data Cleaning and Standardization

The Silver Layer prepares the raw datasets for analytical processing.

Key transformations include:

- Standardizing column names and text values.
- Trimming unnecessary whitespace.
- Converting annual production columns (`Y2019`–`Y2023`) into `FLOAT64`.
- Standardizing text fields using `LOWER()` and `UPPER()`.
- Handling missing Area values using `COALESCE()`.
- Removing duplicate records using `DISTINCT`.
- Creating cleaned lookup/dimension tables for Area, Element, Flag, and Item information.

**Silver Tables:**

| Table | Purpose |
|---|---|
| `Clean_Production_Crops_Livestock_E_All_Data` | Cleaned production dataset |
| `clean_Production_Crops_Livestock_E_All_Data_NOFLAG` | Cleaned production dataset without flag information |
| `clean_Production_Crops_Livestock_E_AreaCodes` | Cleaned Area and M49 code mapping |
| `clean_Production_Crops_Livestock_E_Elements` | Cleaned Element information |
| `clean_Production_Crops_Livestock_E_Flags` | Cleaned Flag descriptions |
| `clean_Production_Crops_Livestock_E_ItemCodes` | Cleaned Item and CPC code mapping |

### 3. Gold Layer – Analytical Data Modeling

The Gold Layer transforms cleaned Silver data into analytical tables designed for reporting and analysis.

**Gold Tables:**

| Table | Purpose |
|---|---|
| `time_series_transformation` | Converts annual columns into a long-format time-series table and enriches records using Area, Element, and Item lookup tables |
| `gold_Production_Crops_Livestock_E_All_Data` | Analytical time-series table derived from the transformed dataset and clustered by Area and Item |
| `aggregation_by_region_and_year` | Aggregates Canadian agricultural production by Area, Item, and Year |
| `top_performance_rank` | Ranks agricultural production across areas and items, separately by measurement unit |

**Key Gold Layer transformations:**

- Uses `UNPIVOT` to transform annual columns (`Y2019`–`Y2023`) into Year and Value columns.
- Uses `LEFT JOIN` to enrich production records with lookup information.
- Filters Canadian production records for the regional aggregation.
- Filters the `Production` element to avoid mixing different agricultural measures.
- Uses `SUM()` for production aggregation.
- Uses `RANK()` with `PARTITION BY Unit` to rank production separately for each measurement unit.
- Uses BigQuery table clustering (`CLUSTER BY Area, Item`) to organize analytical data.

## 📊 Dataset Scope

This project processes six FAOSTAT CSV datasets:

1. **Crops and Livestock Products – All Data**
2. **Crops and Livestock Products – All Data NOFLAG**
3. **Area Codes and M49 Mappings**
4. **Elements and Element Codes**
5. **Flag Descriptions**
6. **Item Codes and CPC Codes**

The production datasets contain annual agricultural measurements from 2019 to 2023.

## 🛠️ Technology Stack

| Technology | Usage |
|---|---|
| Python | Data ingestion |
| Pandas | CSV processing and data handling |
| Regular Expressions | Column name standardization |
| Google BigQuery | Cloud data warehouse |
| SQL | Data cleaning, transformation, aggregation, and ranking |
| Git | Version control |
| GitHub | Source code management |

## 📁 Project Configuration

The project uses a separate `config.py` file to manage ingestion settings.

Example configuration:

```python
csv_file = r'D:\FAOSTAT Agriculture Data_project'
project_id = 'YOUR_GOOGLE_CLOUD_PROJECT_ID'
dataset_name = 'Bronze_FAOSTAT_Agriculture_Data'
```

Update the CSV directory and Google Cloud Project ID according to your environment.

The project configuration keeps ingestion settings separate from the main Python script.

## 🚀 Setup and Installation

### 1. Clone the Repository

```bash
git clone https://github.com/tanvir1396-byte/FAOSTAT-Agriculture-Data.git

cd FAOSTAT-Agriculture-Data
```

### 2. Install Dependencies

Make sure Python and pip are installed.

Install the required Python packages:

```bash
pip install -r requirements.txt
```

### 3. Configure the Project

Update `config.py` with:

- Your local FAOSTAT CSV directory.
- Your Google Cloud Project ID.
- Your Bronze dataset name.

### 4. Authenticate with Google Cloud

Make sure the Google Cloud CLI is installed and authenticated.

```bash
gcloud auth application-default login
```

Select the appropriate Google Cloud project and ensure the account has the required BigQuery permissions.

## ⚙️ Pipeline Execution

Execute the pipeline in the following order:

### Step 1: Bronze Layer

Run the Python ingestion script to load the six CSV datasets into BigQuery.

The ingestion process:

1. Reads CSV files from the configured directory.
2. Cleans column names.
3. Loads the datasets into the Bronze dataset.

### Step 2: Silver Layer

Execute the Silver SQL transformations in BigQuery.

The Silver transformations:

- Clean and standardize production datasets.
- Cast annual production columns to `FLOAT64`.
- Clean Area, Element, Flag, and Item lookup tables.
- Remove duplicate records.

### Step 3: Gold Layer

Execute the Gold SQL transformations in BigQuery.

The Gold transformations:

- Generate the long-format time-series table.
- Enrich production data using lookup tables.
- Build the Canadian production aggregation.
- Generate unit-wise production rankings.
- Create a clustered analytical table.

## ✅ Data Quality and Validation

Validation queries were executed in BigQuery to check the output of the Gold Layer transformations.

**1. Time-Series Transformation**

| Validation | Result |
|---|---:|
| Total Rows | 350,013 |
| Distinct Years | 5 |
| Minimum Year | 2019 |
| Maximum Year | 2023 |
| NULL Values in Value Column | 0 |

**2. Gold Analytical Table**

The source and Gold analytical table row counts were compared.

| Table | Rows |
|---|---:|
| Time-Series Source | 350,013 |
| Gold Analytical Table | 350,013 |

**3. Canadian Production Aggregation**

| Validation | Result |
|---|---:|
| Total Rows | 599 |
| Distinct Years | 5 |
| Non-Canada Records | 0 |
| NULL Production Values | 0 |

**4. Top Performance Ranking**

| Validation | Result |
|---|---:|
| Total Rows | 27,719 |
| Distinct Measurement Units | 2 |
| NULL Ranks | 0 |
| Rank 1 Records | 2 |
| NULL Production Values | 0 |

These checks confirm the expected row counts, year coverage, filtering, and ranking output for the tested Gold tables.

## 📈 Project Outcomes

This project demonstrates an end-to-end agricultural data pipeline using Python and BigQuery.

Key outcomes include:

- Automated ingestion of six FAOSTAT datasets.
- Structured data organization using Bronze, Silver, and Gold layers.
- Standardized agricultural production data for analytical processing.
- Long-format time-series transformation for annual analysis.
- Canadian agricultural production aggregation by year and item.
- Unit-wise production ranking across areas and items.
- BigQuery clustering for analytical table organization.
- Data quality validation using SQL.



