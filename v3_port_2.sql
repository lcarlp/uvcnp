-- This was run after the go-live on July 28, 2020
-- to update a few fields that we missed the first time around.
-- We only update records that existed at the end of the go-live.
.read v3_port_views.sql
.headers on
.mode csv
.once v3_port/v3_profile_nurse_and_date.csv
select * from v3_profile_nurse_and_date;
.once v3_port/v3_encounter_nurse.csv
select * from v3_encounter_nurse;
.once v3_port/v3_status_update_nurse.csv
select * from v3_status_update_nurse;
