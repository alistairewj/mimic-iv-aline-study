-- Create a table which indicates if a patient was ever on a sedative before IAC

with sed as
(
  SELECT subject_id
  , starttime, stoptime
  , drug
  , CASE
    WHEN LOWER(drug) LIKE '%midazolam%' OR LOWER(drug) LIKE '%versed%'
      THEN 'midazolam'
    WHEN LOWER(drug) LIKE '%fentanyl%' OR LOWER(drug) LIKE '%actiq%' OR LOWER(drug) LIKE '%avinza%' OR LOWER(drug) LIKE '%abstral%'
      THEN 'fentanyl'
    WHEN LOWER(drug) LIKE '%propofol%' OR LOWER(drug) LIKE '%diprivan%'
      THEN 'propofol'
    WHEN LOWER(drug) LIKE '%hydromorphone%' OR LOWER(drug) LIKE '%dilaudid%'
      THEN 'dilaudid'
  ELSE NULL END AS sedative
  FROM `physionet-data.mimic_hosp.prescriptions`
  -- midazolam
  WHERE LOWER(drug) LIKE '%midazolam%' OR LOWER(drug) LIKE '%versed%'
  -- fentanyl
  OR LOWER(drug) LIKE '%fentanyl%' OR LOWER(drug) LIKE '%actiq%' OR LOWER(drug) LIKE '%avinza%' OR LOWER(drug) LIKE '%abstral%'
  -- propofol
  OR LOWER(drug) LIKE '%propofol%' OR LOWER(drug) LIKE '%diprivan%'
  -- dilaudid
  OR LOWER(drug) LIKE '%hydromorphone%' OR LOWER(drug) LIKE '%dilaudid%'
)
select
    co.subject_id, co.hadm_id, co.stay_id
  , max(case when sed.subject_id is not null then 1 else 0 end) as sedative_flag
  , max(case when sedative = 'dilaudid'  then 1 else 0 end) as dilaudid_flag
  , max(case when sedative = 'midazolam' then 1 else 0 end) as midazolam_flag
  , max(case when sedative = 'fentanyl' then 1 else 0 end) as fentanyl_flag
  , max(case when sedative = 'propofol'  then 1 else 0 end) as propofol_flag
from aline.cohort co
left join sed
  on co.subject_id = sed.subject_id
  -- sedative given after hospital admission
  AND sed.starttime >= co.admittime
  -- and sometime before/on ventilation
  and sed.starttime <= DATETIME_ADD(co.vent_starttime, INTERVAL 4 hour)
group by co.subject_id, co.hadm_id, co.stay_id
