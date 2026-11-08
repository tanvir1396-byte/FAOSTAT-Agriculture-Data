--Silver Layer: Clean FAOSTAT Production data Cast annual value columns (Y2019 to Y2023) to FLOAT64 for numerical analysis.

CREATE OR REPLACE TABLE `my-project-17182-514115.silver_FAOSTAT_Agriculture_Data.Clean_Production_Crops_Livestock_E_All_Data` AS
SELECT
Area_Code,
Area_Code_M49,
Area,
Item_Code,
Item_Code_CPC,
Item,
Element,
Element_Code,
Unit,
CAST(Y2019 as Float64) as Y2019,
CAST(Y2020 as Float64) as Y2020,
CAST(Y2021 as Float64) as Y2021,
CAST(Y2022 as Float64) as Y2022,
CAST(Y2023 as Float64) as Y2023
FROM `my-project-17182-514115.Bronze_FAOSTAT_Agriculture_Data.extracted_Production_Crops_Livestock_E_All_Data`;


-- Silver Layer: Select and clean production data from NOFLAG table (retaining standard dimensions and annual values from 2019 to 2023)

CREATE OR REPLACE TABLE `my-project-17182-514115.silver_FAOSTAT_Agriculture_Data.clean_Production_Crops_Livestock_E_All_Data_NOFLAG` AS
SELECT
Area_Code,
Area_Code_M49,
Area,
Item_Code,
Item,
Item_Code_CPC,
Element,
Element_Code,
Unit,
CAST(Y2019 as Float64) as Y2019,
CAST(Y2020 as Float64) as Y2020,
CAST(Y2021 as Float64) as Y2021,
CAST(Y2022 as Float64) as Y2022,
CAST(Y2023 as Float64) as Y2023
FROM `my-project-17182-514115.Bronze_FAOSTAT_Agriculture_Data.extracted_Production_Crops_Livestock_E_All_Data_NOFLAG`;


-- Silver Layer: Extract unique, cleaned, and standardized area code dimensions with proper casing and null handling


CREATE OR REPLACE TABLE `my-project-17182-514115.silver_FAOSTAT_Agriculture_Data.clean_Production_Crops_Livestock_E_AreaCodes` AS
SELECT DISTINCT 
Area_Code,
M49_Code,
upper(TRIM(COALESCE(Area,'UNKNOWN')))   as Area
FROM `my-project-17182-514115.Bronze_FAOSTAT_Agriculture_Data.extracted_Production_Crops_Livestock_E_AreaCodes`;

-- Silver Layer: Extract unique and standardized element dimension table with lowercase and trimmed descriptions

CREATE OR REPLACE TABLE `my-project-17182-514115.silver_FAOSTAT_Agriculture_Data.clean_Production_Crops_Livestock_E_Elements` AS
SELECT DISTINCT 
LOWER(TRIM(Element)) as Element ,
Element_Code
FROM `my-project-17182-514115.Bronze_FAOSTAT_Agriculture_Data.extracted_Production_Crops_Livestock_E_Elements`;


-- Silver Layer: Extract unique flag codes and cleaned descriptions by removing unnecessary whitespaces

CREATE OR REPLACE TABLE `my-project-17182-514115.silver_FAOSTAT_Agriculture_Data.clean_Production_Crops_Livestock_E_Flags` AS
SELECT DISTINCT 
Flag,
TRIM(Description) as Description
FROM `my-project-17182-514115.Bronze_FAOSTAT_Agriculture_Data.extracted_Production_Crops_Livestock_E_Flags`;


-- Silver Layer: Extract unique and standardized item codes, CPC codes, and trimmed item descriptions for seamless joins

CREATE OR REPLACE TABLE `my-project-17182-514115.silver_FAOSTAT_Agriculture_Data.clean_Production_Crops_Livestock_E_ItemCodes` AS
SELECT DISTINCT 
Item_Code,
CPC_Code,
TRIM(Item) as Item
FROM `my-project-17182-514115.Bronze_FAOSTAT_Agriculture_Data.extracted_Production_Crops_Livestock_E_ItemCodes`;


