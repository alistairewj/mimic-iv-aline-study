-- ------------------------------------------------------------------
-- Title: Extract height and weight for BMI
-- Description: This query gets the first weight and height for a single stay.
-- It extracts data from the chartevents table.
-- ------------------------------------------------------------------

WITH ht AS
(
  SELECT 
    c.subject_id, c.stay_id, c.charttime,
    -- Ensure that all heights are in centimeters, and fix data as needed
    CASE
        -- rule for neonates
        WHEN pt.anchor_age = 0
         AND (c.valuenum * 2.54) < 80
          THEN c.valuenum * 2.54
        -- rule for adults
        WHEN pt.anchor_age > 0
         AND (c.valuenum * 2.54) > 120
         AND (c.valuenum * 2.54) < 230
          THEN c.valuenum * 2.54
        -- set bad data to NULL
        ELSE NULL
    END AS height
    , ROW_NUMBER() OVER (PARTITION BY stay_id ORDER BY charttime) AS rn
  FROM `physionet-data.mimic_icu.chartevents` c
  INNER JOIN `physionet-data.mimic_core.patients` pt
    ON c.subject_id = pt.subject_id
  WHERE c.valuenum IS NOT NULL
  AND c.valuenum != 0
  AND c.itemid IN
  (
      226707 -- Height (measured in inches)
    -- note we intentionally ignore the below ITEMID in metavision
    -- these are duplicate data in a different unit
    -- , 226730 -- Height (cm)
  )
)
, wt AS
(
    SELECT
        c.stay_id
      , c.charttime
      -- TODO: eliminate obvious outliers if there is a reasonable weight
      , c.valuenum as weight
      , ROW_NUMBER() OVER (PARTITION BY stay_id ORDER BY charttime) AS rn
    FROM `physionet-data.mimic_icu.chartevents` c
    WHERE c.valuenum IS NOT NULL
      AND c.itemid = 226512 -- Admit Wt
      AND c.stay_id IS NOT NULL
      AND c.valuenum > 0
)
select
    co.stay_id
    , case
        when ht.height is not null and wt.weight is not null
            then (wt.weight / (ht.height/100*ht.height/100))
        else null
    end as BMI
    , ht.height
    , wt.weight
from aline.cohort co
left join ht
  on co.stay_id = ht.stay_id
  AND ht.rn = 1
left join wt
  on co.stay_id = wt.stay_id
  AND wt.rn = 1

