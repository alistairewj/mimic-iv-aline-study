gcloud config set project lcp-internal

# we use standard SQL and replace a table if it already exists
export BQ_FLAGS="--use_legacy_sql=False --replace"

# these tables are needed for generating the cohort
bq query $BQ_FLAGS --destination_table=aline.ventdurations < sql/ventdurations.sql
bq query $BQ_FLAGS --destination_table=aline.angus_sepsis < sql/angus_sepsis.sql
bq query $BQ_FLAGS --destination_table=aline.vaso_flag < sql/vaso_flag.sql

# create a table with columns indicating if a patient is excluded from the study
bq query $BQ_FLAGS --destination_table=aline.cohort_all < sql/cohort_all.sql
# the below is identical to cohort_all, but only has stay_id in our cohort
# we inner join to this table to subselect data to only our cohort
bq query $BQ_FLAGS --destination_table=aline.cohort < sql/cohort.sql

# the remaining tables do not have an order, aside from requiring the cohort table
bq query $BQ_FLAGS --destination_table=aline.bmi < sql/bmi.sql
bq query $BQ_FLAGS --destination_table=aline.icd < sql/icd.sql
bq query $BQ_FLAGS --destination_table=aline.labs < sql/labs.sql
bq query $BQ_FLAGS --destination_table=aline.sedatives < sql/sedatives.sql
bq query $BQ_FLAGS --destination_table=aline.sofa < sql/sofa.sql
bq query $BQ_FLAGS --destination_table=aline.vitals < sql/vitals.sql