-- Extract data which is based on ICD-9 codes
WITH dx AS
(
  SELECT hadm_id, icd_version, TRIM(icd_code) AS icd_code
  FROM `physionet-data.mimic_hosp.diagnoses_icd`
)
, icd9 AS
(
  select
  hadm_id
  , max(case when icd_code in
  (  '03642','07422','09320','09321','09322','09323','09324','09884'
    ,'11281','11504','11514','11594'
    ,'3911', '4210', '4211', '4219'
    ,'42490','42491','42499'
  ) then 1 else 0 end) as endocarditis

  -- chf
  , max(case when icd_code in
  (  '39891','40201','40291','40491','40413'
    ,'40493','4280','4281','42820','42821'
    ,'42822','42823','42830','42831','42832'
    ,'42833','42840','42841','42842','42843'
    ,'4289','428','4282','4283','4284'
  ) then 1 else 0 end) as chf

  -- atrial fibrilliation or atrial flutter
  , max(case when icd_code like '4273%' then 1 else 0 end) as afib

  -- renal
  , max(case when icd_code like '585%' then 1 else 0 end) as renal

  -- liver
  , max(case when icd_code like '571%' then 1 else 0 end) as liver

  -- copd
  , max(case when icd_code in
  (  '4660','490','4910','4911','49120'
    ,'49121','4918','4919','4920','4928'
    ,'494','4940','4941','496') then 1 else 0 end) as copd

  -- coronary artery disease
  , max(case when icd_code like '414%' then 1 else 0 end) as cad

  -- stroke
  , max(case when icd_code like '430%'
      or icd_code like '431%'
      or icd_code like '432%'
      or icd_code like '433%'
      or icd_code like '434%'
       then 1 else 0 end) as stroke

  -- malignancy, includes remissions
  , max(case when icd_code between '140' and '239' then 1 else 0 end) as malignancy

  -- resp failure
  , max(case when icd_code like '518%' then 1 else 0 end) as respfail

  -- ARDS
  , max(case when icd_code = '51882' or icd_code = '5185' then 1 else 0 end) as ards

  -- pneumonia
  , max(case when icd_code between '486' and '48881'
      or icd_code between '480' and '48099'
      or icd_code between '482' and '48299'
      or icd_code between '506' and '5078'
        then 1 else 0 end) as pneumonia
  from dx
  WHERE icd_version = 9
  group by hadm_id
)
-- ICD-10
, icd10 AS
(
  select
  hadm_id
  , max(case when icd_code in
    (
      'A3951' -- ENDOCARDITIS
    , 'B3321' -- VIRAL ENDOCARDITIS
    , 'A5203' -- SYPHILITIC ENDOCARDITIS
    , 'A5483' -- GONOCOCCAL HEART INFECTION
    , 'B376' -- CANDIDAL ENDOCARDITIS
    , 'I39' -- ENDOCARDITIS AND HEART VALVE DISORDERS IN DISEASES CLASSIFIED ELSEWHERE
    , 'I011' -- ACUTE RHEUMATIC ENDOCARDITISI011
    , 'I330' -- ACUTE AND SUBACUTE INFECTIVE ENDOCARDITIS
    , 'I339'
    , 'I38'
  ) then 1 else 0 end) as endocarditis

  -- chf
  , max(case when icd_code in
  (
    'I0981', 'I110', 'I110', 'I132', 'I130', 'I132',
    'I509', 'I501', 'I5020', 'I5021', 'I5022', 'I5023',
    'I5030', 'I5031', 'I5032', 'I5033', 'I5040', 'I5041',
    'I5042', 'I5043', 'I509'
  ) then 1 else 0 end) as chf

  -- atrial fibrilliation or atrial flutter
  , max(case when icd_code like 'I48%' then 1 else 0 end) as afib

  -- renal (chronic kidney disease)
  , max(case when icd_code like 'N18%' then 1 else 0 end) as renal

  -- liver
  , max(case when icd_code IN
        (
          'K7010', 'K7030', 'K709', 'K739', 'K730', 'K754',
          'K732', 'K738', 'K740', 'K7460', 'K7469', 'K743',
          'K744', 'K745', 'K760', 'K7689', 'K741', 'K769'
        ) then 1 else 0 end
  ) as liver

  -- copd
  , max(case when icd_code in
  ('J209', 'J40', 'J410', 'J411', 'J449', 'J441', 'J418', 'J42', 'J439', 'J439', 'J479', 'J471', 'J449') then 1 else 0 end) as copd

  -- coronary artery disease
  , max(case when icd_code IN
        (
          'I2510', 'I2510', 'I25810', 'I25810', 'I25810', 'I25810',
          'I25811', 'I25812', 'I253', 'I2541', 'I2542', 'I253',
          'I2582', 'I2583', 'I2584', 'I255', 'I2589', 'I259', 'I259'
        ) then 1
  else 0 end) as cad

  -- stroke
  , max(case when icd_code IN
        (
          'I609', 'I619', 'I621', 'I6200', 'I629', 'I651', 'I6322',
          'I6529', 'I63139', 'I63239', 'I6509', 'I63019', 'I63119',
          'I63219', 'I658', 'I6359', 'I658', 'I6359', 'I659', 'I6320',
          'I6609', 'I6619', 'I6629', 'I6330', 'I6609', 'I6619', 'I6629',
          'I669', 'I6340', 'I669', 'I6350'
        )
       then 1 else 0 end) as stroke

  -- malignancy, includes remissions
  , max(case when icd_code between 'C00' and 'D09' then 1
             when icd_code between 'D37' and 'D48' then 1
    else 0 end) as malignancy

  -- resp failure
  , max(case when icd_code IN
      (
        'J9811', 'J9819', 'J982', 'J983', 'J82', 'J810', 'J95821',
        'J9600', 'J951', 'J952', 'J953', 'J95822', 'J9620', 'B4481',
        'J9584', 'J9600', 'J9690', 'J80', 'J9610', 'J9620', 'J984'
      ) then 1 else 0 end
    ) as respfail

  -- ARDS
  , max(case when icd_code IN ('J80', 'J95821', 'J9600', 'J951', 'J952', 'J953', 'J95822', 'J9620') THEN 1
        else 0 end) as ards

  -- pneumonia
  , max(case
        when icd_code IN (
            'J189', 'J1100', 'J129', 'J101', 'J111', 'J112', 'J1181', 'J1189',
            'J09X1', 'J09X2', 'J09X3', 'J09X9', 'J1008',
            'J120', 'J121', 'J122', 'J1281', 'J1289', 'J129',
            'J150', 'J151', 'J14', 'J154', 'J153', 'J1520', 'J15211', 'J15212',
            'J1529', 'J158', 'J155', 'J156', 'A481', 'J159',
            'J680', 'J681', 'J682', 'J683', 'J684', 'J689', 'J690', 'J691', 'J698'
        )
        then 1 else 0 end) as pneumonia
  from dx
  WHERE icd_version = 10
  group by hadm_id
)
SELECT
  co.hadm_id
  -- merge icd-9 and icd-10 codes
  , GREATEST(COALESCE(icd9.endocarditis, 0), COALESCE(icd10.endocarditis, 0)) AS endocarditis
  , GREATEST(COALESCE(icd9.chf, 0), COALESCE(icd10.chf, 0)) AS chf
  , GREATEST(COALESCE(icd9.afib, 0), COALESCE(icd10.afib, 0)) AS afib
  , GREATEST(COALESCE(icd9.renal, 0), COALESCE(icd10.renal, 0)) AS renal
  , GREATEST(COALESCE(icd9.liver, 0), COALESCE(icd10.liver, 0)) AS liver
  , GREATEST(COALESCE(icd9.copd, 0), COALESCE(icd10.copd, 0)) AS copd
  , GREATEST(COALESCE(icd9.cad, 0), COALESCE(icd10.cad, 0)) AS cad
  , GREATEST(COALESCE(icd9.stroke, 0), COALESCE(icd10.stroke, 0)) AS stroke
  , GREATEST(COALESCE(icd9.malignancy, 0), COALESCE(icd10.malignancy, 0)) AS malignancy
  , GREATEST(COALESCE(icd9.respfail, 0), COALESCE(icd10.respfail, 0)) AS respfail
  , GREATEST(COALESCE(icd9.ards, 0), COALESCE(icd10.ards, 0)) AS ards
  , GREATEST(COALESCE(icd9.pneumonia, 0), COALESCE(icd10.pneumonia, 0)) AS pneumonia
FROM aline.cohort co
LEFT JOIN icd9
  ON co.hadm_id = icd9.hadm_id
LEFT JOIN icd10
  ON co.hadm_id = icd10.hadm_id
