-- Change nurse fields from 'cpedersen' to 'smorgan'.
-- There are four new fields in V3 that are filled in automatically
-- with the nurse's username using REDCap feature: @READONLY @USERNAME
-- On July 12-15, I filled them all in with 'cpedersen', not knowing for
-- sure who the actual nurse was and not willing to hunt through the log
-- to determine it.  
-- We had a legal case in Lyme where Sharon Morgan needed her name to
-- appear in the extracted PDF, so I wrote this script to make that happen
-- for one client.
.headers on
.mode csv
.once /Users/lcarl/Documents/REDCap/lyme_client_fix/fix.csv
select record_id
     , redcap_data_access_group
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , 'smorgan' admitting_nurse
     , '' encounter_nurse
     , '' status_update_nurse 
     , '' six_month_nurse
  from redcap_export_20200809
 where record_id='64860-116'
   and 'cpedersen' = admitting_nurse
union   
select record_id
     , redcap_data_access_group
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , '' admitting_nurse
     , 'smorgan' encounter_nurse
     , '' status_update_nurse 
     , '' six_month_nurse
  from redcap_export_20200809
 where record_id='64860-116'
   and 'cpedersen' = encounter_nurse
union   
select record_id
     , redcap_data_access_group
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , '' admitting_nurse
     , '' encounter_nurse
     , 'smorgan' status_update_nurse 
     , '' six_month_nurse
  from redcap_export_20200809
 where record_id='64860-116'
   and 'cpedersen' = status_update_nurse
union   
select record_id
     , redcap_data_access_group
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , '' admitting_nurse
     , '' encounter_nurse
     , '' status_update_nurse 
     , 'smorgan' six_month_nurse
  from redcap_export_20200809
 where record_id='64860-116'
   and 'cpedersen' = six_month_nurse;
