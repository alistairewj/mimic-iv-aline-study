-- Create a table which indicates if a patient was ever on a sedative before IAC

-- List of sedatives used:
--  midazolam - 221668
--  fentanyl - 221744, 225972, 225942
--  propofol - 222168

with io_mv as
(
  select
    stay_id, linkorderid, itemid, starttime, endtime, rate, amount
  from `physionet-data.mimic_icu.inputevents` io
  where itemid in
  (
    221668 -- midazolam
  , 221744, 225972, 225942 -- fentanyl
  , 222168 -- propofol
  )
  and coalesce(rate, amount) is not null
  and (rate > 0 OR amount > 0)
)
select
    co.subject_id, co.hadm_id, co.stay_id
  , max(case when io_mv.stay_id is not null then 1 else 0 end) as sedative_flag
  , max(case when io_mv.itemid in (221668) then 1 else 0 end) as midazolam_flag
  , max(case when io_mv.itemid in (221744, 225972, 225942) then 1 else 0 end) as fentanyl_flag
  , max(case when io_mv.itemid in (222168) then 1 else 0 end) as propofol_flag
from aline.cohort co
left join io_mv
  on co.stay_id = io_mv.stay_id
  and co.starttime_aline > io_mv.starttime
  and co.starttime_aline <= io_mv.endtime
group by co.subject_id, co.hadm_id, co.stay_id
