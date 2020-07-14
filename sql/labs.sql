with labs_preceeding as
(
  select co.stay_id
    , l.valuenum, l.charttime
    , case
            when itemid = 51006 then 'BUN'
            when itemid = 50806 then 'CHLORIDE'
            when itemid = 50902 then 'CHLORIDE'
            when itemid = 50912 then 'CREATININE'
            when itemid = 50811 then 'HEMOGLOBIN'
            when itemid = 51222 then 'HEMOGLOBIN'
            when itemid = 51265 then 'PLATELET'
            when itemid = 50822 then 'POTASSIUM'
            when itemid = 50971 then 'POTASSIUM'
            when itemid = 50824 then 'SODIUM'
            when itemid = 50983 then 'SODIUM'
            when itemid = 50803 then 'TOTALCO2' -- actually is 'BICARBONATE'
            when itemid = 50882 then 'TOTALCO2' -- actually is 'BICARBONATE'
            when itemid = 50804 then 'TOTALCO2'
            when itemid = 51300 then 'WBC'
            when itemid = 51301 then 'WBC'
          else null
        end as label
    , case when l.charttime > co.vent_starttime then 1 else 0 end as obs_after_vent
  from aline.cohort co
  inner join `physionet-data.mimic_hosp.labevents` l
    on l.subject_id = co.subject_id
    and l.charttime <= DATETIME_ADD(co.vent_starttime, INTERVAL 4 HOUR)
    and l.charttime >= DATETIME_SUB(co.vent_starttime, INTERVAL 2 day)
  where l.itemid in
  (
     51300,51301 -- wbc
    ,50811,51222 -- hgb
    ,51265 -- platelet
    ,50824, 50983 -- sodium
    ,50822, 50971 -- potassium
    ,50804 -- Total CO2 or ...
    ,50803, 50882  -- bicarbonate
    ,50806,50902 -- chloride
    ,51006 -- bun
    ,50912 -- creatinine
  )
  and valuenum is not null
)
, labs_rn as
(
  select
    stay_id, valuenum, label, obs_after_vent
    , ROW_NUMBER() over (partition by stay_id, label, obs_after_vent order by charttime DESC) as rn
  from labs_preceeding
)
, labs_grp as
(
  select
    stay_id
    , coalesce(max(case when label = 'BUN' and obs_after_vent = 0 then valuenum else null end),
              max(case when label = 'BUN' and obs_after_vent = 1 then valuenum else null end)
              ) as BUN
    , coalesce(max(case when label = 'CHLORIDE' and obs_after_vent = 0 then valuenum else null end),
              max(case when label = 'CHLORIDE' and obs_after_vent = 1 then valuenum else null end)
              ) as CHLORIDE
    , coalesce(max(case when label = 'CREATININE' and obs_after_vent = 0 then valuenum else null end),
              max(case when label = 'CREATININE' and obs_after_vent = 1 then valuenum else null end)
              ) as CREATININE
    , coalesce(max(case when label = 'HEMOGLOBIN' and obs_after_vent = 0 then valuenum else null end),
              max(case when label = 'HEMOGLOBIN' and obs_after_vent = 1 then valuenum else null end)
              ) as HEMOGLOBIN
    , coalesce(max(case when label = 'PLATELET' and obs_after_vent = 0 then valuenum else null end),
              max(case when label = 'PLATELET' and obs_after_vent = 1 then valuenum else null end)
              ) as PLATELET
    , coalesce(max(case when label = 'POTASSIUM' and obs_after_vent = 0 then valuenum else null end),
              max(case when label = 'POTASSIUM' and obs_after_vent = 1 then valuenum else null end)
              ) as POTASSIUM
    , coalesce(max(case when label = 'SODIUM' and obs_after_vent = 0 then valuenum else null end),
              max(case when label = 'SODIUM' and obs_after_vent = 1 then valuenum else null end)
              ) as SODIUM
    , coalesce(max(case when label = 'TOTALCO2' and obs_after_vent = 0 then valuenum else null end),
              max(case when label = 'TOTALCO2' and obs_after_vent = 1 then valuenum else null end)
              ) as TOTALCO2
    , coalesce(max(case when label = 'WBC' and obs_after_vent = 0 then valuenum else null end),
              max(case when label = 'WBC' and obs_after_vent = 1 then valuenum else null end)
              ) as WBC

  from labs_rn
  where rn = 1
  group by stay_id
)
select co.stay_id
  , lg.bun as bun_first
  , lg.chloride as chloride_first
  , lg.creatinine as creatinine_first
  , lg.HEMOGLOBIN as hgb_first
  , lg.platelet as platelet_first
  , lg.potassium as potassium_first
  , lg.sodium as sodium_first
  , lg.TOTALCO2 as tco2_first
  , lg.wbc as wbc_first

from aline.cohort co
left join labs_grp lg
  on co.stay_id = lg.stay_id
