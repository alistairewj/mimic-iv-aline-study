with vc AS
(
    select stay_id, charttime
    , LAG(charttime, 1) OVER (partition by stay_id order by charttime) AS charttime_lag

    from `physionet-data.mimic_icu.chartevents`
    WHERE itemid = 223849
    AND value != 'Standby'
)
, vd1 as
(
  select
      stay_id
      , charttime_lag
      , charttime
      -- split events if they occur more than 8 hours apart
      , case
            when CHARTTIME > DATETIME_ADD(charttime_lag, INTERVAL '8' HOUR)
            then 1
        else 0
        end as newvent
  FROM vc
)
, vd2 as
(
  select vd1.*
  -- create a cumulative sum of the instances of new ventilation
  -- this results in a monotonic integer assigned to each instance of ventilation
  , SUM( newvent ) OVER ( partition by stay_id order by charttime ) as ventnum
  --- now we convert CHARTTIME of ventilator settings into durations
  from vd1
)
-- create the durations for each mechanical ventilation instance
select stay_id
  -- regenerate ventnum so it's sequential
  , ROW_NUMBER() over (partition by stay_id order by ventnum) as vent_seq
  , min(charttime) as starttime
  , max(charttime) as endtime
  , DATETIME_DIFF(max(charttime), min(charttime), MINUTE)/60 AS duration_hours
from vd2
group by stay_id, vd2.ventnum
having min(charttime) != max(charttime)