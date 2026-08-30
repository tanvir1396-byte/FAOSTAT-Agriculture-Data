-- Gold Layer: Transform wide-format annual production data into a clean, long-format time-series fact table via UNPIVOT

CREATE OR REPLACE TABLE `elite-vista-474514-t0.gold_FAOSTAT_Agriculture_Data.time_series_transformation` as
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
REGEXP_EXTRACT(year_column, r'[0-9]+') as year,
value
FROM (
  SELECT *
  FROM `elite-vista-474514-t0.silver_FAOSTAT_Agriculture_Data.Clean_Production_Crops_Livestock_E_All_Data`
)

UNPIVOT(
  value for year_column in (Y2019,Y2020,Y2021,Y2022,Y2023)
);


-- Gold Layer: Aggregate 5-year total production/value per item for Canada

CREATE OR REPLACE TABLE `elite-vista-474514-t0.gold_FAOSTAT_Agriculture_Data.aggregation_by_region_and_year` AS
SELECT
Area,
item,
ROUND(SUM(value),2) as total_value

FROM(SELECT *
 FROM `elite-vista-474514-t0.silver_FAOSTAT_Agriculture_Data.Clean_Production_Crops_Livestock_E_All_Data`
)

UNPIVOT(
  value for year_column in (Y2019,Y2020,Y2021,Y2022,Y2023)
)

WHERE area ='Canada'
GROUP BY area,item


-- Gold Layer: Create ranking table for top-performing items and regions based on total value


CREATE OR REPLACE TABLE `elite-vista-474514-t0.gold_FAOSTAT_Agriculture_Data.top_performance_rank` AS
WITH aggregateData AS (
  SELECT
  area,
  item,
  ROUND(SUM(value),2) as total_value
  FROM `elite-vista-474514-t0.gold_FAOSTAT_Agriculture_Data.time_series_transformation`
  GROUP BY area,item

)

SELECT 
aggregateData.area,aggregateData.item,
aggregateData.total_value,
Rank() OVER (ORDER BY total_value DESC) as rank_number
FROM aggregateData;



-- Gold Layer: Unpivot 5-year data into long format and cluster by area and item for performance


CREATE OR REPLACE TABLE `elite-vista-474514-t0.gold_FAOSTAT_Agriculture_Data.gold_Production_Crops_Livestock_E_All_Data`

CLUSTER by area,item
AS
SELECT
Area_Code,
Area_Code_M49,
Area,
Item,
Item_Code,
Item_Code_CPC,
Element,
Element_Code,
Unit,
REGEXP_EXTRACT(column_year, r'[0-9]+') as year,
value

FROM (
  SELECT *
  FROM `elite-vista-474514-t0.silver_FAOSTAT_Agriculture_Data.Clean_Production_Crops_Livestock_E_All_Data`
)

UNPIVOT(
  value for column_year in (Y2019, Y2020,Y2021,Y2022, Y2023)
)