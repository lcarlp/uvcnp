-- Change nurse fields from 'cpedersen' to 'unknown'.
-- There are four new fields in V3 that are filled in automatically
-- with the nurse's username using REDCap feature: @READONLY @USERNAME
-- On July 12-15, I filled them all in with 'cpedersen', not knowing for
-- sure who the actual nurse was and not willing to hunt through the log
-- to determine it.  
-- We had a legal case in Lyme where Sharon Morgan needed her name to
-- appear in the extracted PDF, so I wrote a script to make that happen
-- for one client, and used in on August 25, 2020.
-- Later, in October 2020, we decided it was better to use 'unknown' for 
-- all of the old records, so I created this script by modifying the one
-- I created in August.
-- Note that it is not necessary to check the value of redcap_repeat_instrument
-- for these records, since the nurse fields will only have a value in the 
-- rows for the associated value of redcap_repeat_instrument.
.headers on
.mode csv
.once nurse_cpedersen_fix.csv
select record_id
     , redcap_data_access_group
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , 'unknown' admitting_nurse
     , '' encounter_nurse
     , '' status_update_nurse 
     , '' six_month_nurse
  from redcap_export_20201013
 where 'cpedersen' = admitting_nurse
union   
select record_id
     , redcap_data_access_group
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , '' admitting_nurse
     , 'unknown' encounter_nurse
     , '' status_update_nurse 
     , '' six_month_nurse
  from redcap_export_20201013
 where 'cpedersen' = encounter_nurse
union   
select record_id
     , redcap_data_access_group
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , '' admitting_nurse
     , '' encounter_nurse
     , 'unknown' status_update_nurse 
     , '' six_month_nurse
  from redcap_export_20201013
 where 'cpedersen' = status_update_nurse
union   
select record_id
     , redcap_data_access_group
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , '' admitting_nurse
     , '' encounter_nurse
     , '' status_update_nurse 
     , 'unknown' six_month_nurse
  from redcap_export_20201013
 where 'cpedersen' = six_month_nurse;
