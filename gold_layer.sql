-- Gold Layer: Transform wide-format annual production data into a clean, long-format time-series fact table via UNPIVOT


CREATE OR REPLACE TABLE
`my-project-17182-514115.gold_FAOSTAT_Agriculture_Data.time_series_transformation` AS

SELECT
    f.Area_Code,
    a.M49_Code AS Area_Code_M49,
    a.Area,
    f.Item_Code,
    i.CPC_Code AS Item_Code_CPC,
    i.Item,
    e.Element,
    f.Element_Code,
    f.Unit,
    REGEXP_EXTRACT(f.year_column, r'[0-9]+') AS year,
    f.value

FROM (
    SELECT *
    FROM
    `my-project-17182-514115.silver_FAOSTAT_Agriculture_Data.Clean_Production_Crops_Livestock_E_All_Data`

    UNPIVOT(
        value FOR year_column IN (Y2019, Y2020, Y2021, Y2022, Y2023)
    )
) AS f

LEFT JOIN
`my-project-17182-514115.silver_FAOSTAT_Agriculture_Data.clean_Production_Crops_Livestock_E_AreaCodes` AS a
ON f.Area_Code = a.Area_Code

LEFT JOIN
`my-project-17182-514115.silver_FAOSTAT_Agriculture_Data.clean_Production_Crops_Livestock_E_Elements` AS e
ON f.Element_Code = e.Element_Code

LEFT JOIN
`my-project-17182-514115.silver_FAOSTAT_Agriculture_Data.clean_Production_Crops_Livestock_E_ItemCodes` AS i
ON f.Item_Code = i.Item_Code;


-- Gold Layer: Aggregate 5-year total production/value per item for Canada

CREATE OR REPLACE TABLE
`my-project-17182-514115.gold_FAOSTAT_Agriculture_Data.aggregation_by_region_and_year` AS

SELECT
    Area,
    Item,
    year,
    Unit,
    ROUND(SUM(value), 2) AS total_production

FROM
`my-project-17182-514115.gold_FAOSTAT_Agriculture_Data.time_series_transformation`

WHERE
    Area = 'CANADA'
    AND LOWER(Element) = 'production'

GROUP BY
    Area,
    Item,
    year,
    Unit;


-- Gold Layer: Create ranking table for top-performing items and regions based on total value


CREATE OR REPLACE TABLE
`my-project-17182-514115.gold_FAOSTAT_Agriculture_Data.top_performance_rank` AS

WITH aggregateData AS (
    SELECT
        Area,
        Item,
        Unit,
        ROUND(SUM(value), 2) AS total_production

    FROM
    `my-project-17182-514115.gold_FAOSTAT_Agriculture_Data.time_series_transformation`

    WHERE LOWER(Element) = 'production'

    GROUP BY
        Area,
        Item,
        Unit
)

SELECT
    Area,
    Item,
    Unit,
    total_production,
    RANK() OVER (
        PARTITION BY Unit
        ORDER BY total_production DESC
    ) AS rank_number

FROM aggregateData;


-- Gold Layer: Unpivot 5-year data into long format and cluster by area and item for performance


CREATE OR REPLACE TABLE
`my-project-17182-514115.gold_FAOSTAT_Agriculture_Data.gold_Production_Crops_Livestock_E_All_Data`

CLUSTER BY Area, Item AS

SELECT *
FROM
`my-project-17182-514115.gold_FAOSTAT_Agriculture_Data.time_series_transformation`;