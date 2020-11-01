-- Views used by the "At A Glance" (AAG) report.

-- Note that missing dates are '', not null, so coalesce may not
-- do what you expect or want.

drop view if exists aag1;
create view aag1 as
select * 
  from redcap_export
  join aag_town 
    on redcap_data_access_group = lower(town);

drop view if exists aag1_client_all;
create view aag1_client_all as
select record_id
     , redcap_data_access_group town
     , cast(age as real) as age
     , household_comp
     , primary_referrer
     , case
         when primary_referrer = '' then 0
         else 1
       end as referred_by_any
     , provider1_affiliation
     , case when provider1_affiliation = '' then 0 else 1 end as provider1_affiliation_any
     , hospital_used
     , case when hospital_used = '' then 0 else 1 end as hospital_used_any
  from aag1
 where redcap_repeat_instrument = ''
;


drop view if exists aag1_encounter1;
create view aag1_encounter1 as
select *
  from aag1
  join aag_date_range d
    on encounter_date between d.first and d.last
 where redcap_repeat_instrument = 'encounters'
 -- This version of encounters is one-to-one with
 -- encounters, unlike the other one that adds 
 -- additional encounters if there is more than one type
 -- in one encounter.
;


drop view if exists aag1_client_served;
create view aag1_client_served as
select *
  from aag1_client_all
 where record_id in(
         select record_id from aag1_encounter1 )
 -- For clients served, only show them if they had an encounter
 -- within the range.
 ;


drop view if exists aag1_client_age;
create view aag1_client_age as
select record_id, age
  from aag1_client_served
 where age >= 1
-- Ignore low ages that likely resulted from the nurse entering today's
-- date into the birthday field.
;


drop view if exists aag1_client_served_first_encounter;
create view aag1_client_served_first_encounter as
select client.record_id
     , ( select min(encounter_date) --Allow for encounters out of date order.
           from aag1 encounter
          where encounter.redcap_repeat_instrument= 'encounters'
            and encounter.record_id = client.record_id ) date_1st_encounter
     , d.first 
  from aag1_client_served client
  join aag_date_range d;


drop view if exists aag1_client_served_with_status;
create view aag1_client_served_with_status as
select client.record_id
     , case status_update.client_redcap_status
         when '' then 1
         else coalesce(cast(status_update.client_redcap_status as integer),1)
       end client_redcap_status
  from aag1_client_served client
  join aag_date_range d
  left join aag1 status_update
    on status_update.redcap_repeat_instrument = 'status_update'
   and status_update.record_id = client.record_id
   and status_update.client_redcap_status_date <= d.last
   and not exists(
        select null from aag1 status_update2
         where status_update2.redcap_repeat_instrument = 'status_update'
           and status_update2.record_id = client.record_id
           and status_update2.client_redcap_status_date <= d.last
           and status_update2.redcap_repeat_instance > status_update.redcap_repeat_instance )
;


drop view if exists aag1_encounter_all;
create view aag1_encounter_all as
select record_id
     , redcap_data_access_group town
     , encounter_date
     , encounter_type___1
     , encounter_type___2
     , encounter_type___3
     , encounter_type___4
     , encounter_type___5
     , encounter_type___6
     , encounter_type___11
     , encounter_type___12
     , encounter_type___13
     , encounter_type___10
  from aag1 encounter
  join aag_date_range d
 where encounter.redcap_repeat_instrument = 'encounters'
   and encounter.encounter_date between d.first and d.last
 -- This view is currently only used as a building block
 -- for aag1_encounter.
 ;

drop view if exists aag1_encounter;
create view aag1_encounter as -- See comments at end of view.
select record_id
     , town
     , encounter_date
     , 1 as type
  from aag1_encounter_all
 where encounter_type___1 = 1
union all
select record_id
     , town
     , encounter_date
     , 2 as type
  from aag1_encounter_all
 where encounter_type___2 = 1
union all
select record_id
     , town
     , encounter_date
     , 3 as type
  from aag1_encounter_all
 where encounter_type___3 = 1
union all
select record_id
     , town
     , encounter_date
     , 4 as type
  from aag1_encounter_all
 where encounter_type___4 = 1
union all
select record_id
     , town
     , encounter_date
     , 5 as type
  from aag1_encounter_all
 where encounter_type___5 = 1
union all
select record_id
     , town
     , encounter_date
     , 6 as type
  from aag1_encounter_all
 where encounter_type___6 = 1
union all
select record_id
     , town
     , encounter_date
     , 11 as type
  from aag1_encounter_all
 where encounter_type___11 = 1
union all
select record_id
     , town
     , encounter_date
     , 12 as type
  from aag1_encounter_all
 where encounter_type___12 = 1
union all
select record_id
     , town
     , encounter_date
     , 13 as type
  from aag1_encounter_all
 where encounter_type___13 = 1
union all
select record_id
     , town
     , encounter_date
     , 10 as type --Other
  from aag1_encounter_all
 where encounter_type___10 = 1 --Other
   and encounter_type___1 +
        encounter_type___2 +
        encounter_type___3 +
        encounter_type___4 +
        encounter_type___5 +
        encounter_type___6 +
        encounter_type___11 +
        encounter_type___12 +
        encounter_type___13 = 0
--
-- This superfically complicated view takes into account that the
-- user might select more than one type for an encounter.  For any types
-- except for type 10 (other),  if more than one is selected, we count 
-- that as multiple encounters.  We do not add to the count if "Other" 
-- is also selected, but we do count as "Other" encounters if none of 
-- the other encounter types are selected.
-- Note that most of the selects being UNIONed together follow a pattern.
;


drop view if exists month;
create view month(number,name) as 
select 1,'January' union all
select 2,'February' union all
select 3,'March' union all
select 4,'April' union all
select 5,'May' union all
select 6,'June' union all
select 7,'July' union all
select 8,'August' union all
select 9,'September' union all
select 10,'October' union all
select 11,'November' union all
select 12,'December';

drop view if exists aag1_dates;
create view aag1_dates as
select first
     , last
     , (julianday(last) - julianday(first))/7 as weeks
     , first_month.name first_month
     , strftime('%d',d.first) first_day
     , strftime('%Y',d.first) first_year     
     , last_month.name last_month
     , strftime('%d',d.last) last_day
     , strftime('%Y',d.last) last_year     
  from aag_date_range as d
  join month as first_month
    on first_month.number = cast(strftime('%m',d.first) as integer)
  join month as last_month
    on last_month.number = cast(strftime('%m',d.last) as integer);


drop view if exists aag1_affiliation1;
create view aag1_affiliation1 as
select 'DHMC' as label
     , '01' as provider1_affiliation --To use in sort_key
     , cast(round(portion*100./total) as integer) as percentage
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 1 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'APD'
     , '02'
     , cast(round(portion*100./total) as integer)
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 2 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Mt. Ascutney'
     , '03'
     , cast(round(portion*100./total) as integer)
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 3 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Gifford Medical Center'
     , '04'
     , cast(round(portion*100./total) as integer)
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 4 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Valley Regional'
     , '05'
     , cast(round(portion*100./total) as integer)
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 5 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Cottage'
     , '06'
     , cast(round(portion*100./total) as integer)
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 6 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'New London'
     , '07' 
     , cast(round(portion*100./total) as integer)
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 7 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Private or Community-based Practice'
     , '08' 
     , cast(round(portion*100./total) as integer)
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 8 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'VA'
     , '09' 
     , cast(round(portion*100./total) as integer)
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 9 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Other'
     , '10' 
     , cast(round(portion*100./total) as integer)
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 10 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0;

drop view if exists aag1_affiliation2;
create view aag1_affiliation2 as
select (100 + percentage)||provider1_affiliation as sort_key
     , label
     , percentage
  from aag1_affiliation1;
     
drop view if exists aag1_affiliation;
create view aag1_affiliation as
select ( select count(*) from aag1_affiliation2 where sort_key >= this.sort_key ) rank
     , percentage
     , label
  from aag1_affiliation2 this
-- This view is pretty slow to query.  If it gets too slow with more data,
-- it would probably help to use a temporary table for the output from 
-- aag1_affiliation2.
;


drop view if exists aag1_hospital_used1;
create view aag1_hospital_used1 as
select 'DHMC' as label
     , '01' as hospital_used --Add to use in sort_key
     , cast(round(portion*100./total) as integer) as percentage
  from (select sum(hospital_used_any) as total
             , sum(case when hospital_used = 1 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all          
select 'APD'
     , '02'
     , cast(round(portion*100./total) as integer)
  from (select sum(hospital_used_any) as total
             , sum(case when hospital_used = 2 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Mt. Ascutney'
     , '03'
     , cast(round(portion*100./total) as integer)
  from (select sum(hospital_used_any) as total
             , sum(case when hospital_used = 3 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Gifford Medical Center'
     , '04'
     , cast(round(portion*100./total) as integer)
  from (select sum(hospital_used_any) as total
             , sum(case when hospital_used = 4 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Valley Regional'
     , '05'
     , cast(round(portion*100./total) as integer)
  from (select sum(hospital_used_any) as total
             , sum(case when hospital_used = 5 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Cottage'
     , '06'
     , cast(round(portion*100./total) as integer)
  from (select sum(hospital_used_any) as total
             , sum(case when hospital_used = 6 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'New London'
     , '07'
     , cast(round(portion*100./total) as integer)
  from (select sum(hospital_used_any) as total
             , sum(case when hospital_used = 7 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0
union all
select 'Other'
     , '08'
     , cast(round(portion*100./total) as integer)
  from (select sum(hospital_used_any) as total
             , sum(case when hospital_used = 8 then 1 else 0 end) as portion
          from aag1_client_served)
 where portion > 0;

drop view if exists aag1_hospital_used2;
create view aag1_hospital_used2 as
select (100 + percentage)||hospital_used as sort_key
     , label
     , percentage
  from aag1_hospital_used1;
     
drop view if exists aag1_hospital_used;
create view aag1_hospital_used as
select ( select count(*) from aag1_hospital_used2 where sort_key >= this.sort_key ) rank
     , percentage
     , label
  from aag1_hospital_used2 this
-- This view is pretty slow to query.  If it gets too slow with more data,
-- it would probably help to use a temporary table for the output from 
-- aag1_hospital_used2.
;


drop view if exists aag1_problem1;
create view aag1_problem1 as
select record_id
     , redcap_data_access_group town
     , problem_type___1  -- Impaired Mobility
     , problem_type___2  -- Fall Risk
     , problem_type___3  -- Social isolation/weak social support
     , problem_type___4  -- Ineffective symptom management
     , problem_type___5  -- Frailty
     , problem_type___6  -- Self-care deficit
     , problem_type___7  -- Ineffective medication management
     , problem_type___8  -- Mental health issue
     , problem_type___9  -- Impaired cognitive function
     , problem_type___10 -- Poor nutrition/food insecurity
     , problem_type___11 -- Financial stress
     , problem_type___12 -- Transportation
     , problem_type___13 -- Struggling to remain at home; options being considered
     , problem_type___14 -- Potential for caregiver burnout
     , problem_type___20 -- Other
  from aag1
 where redcap_repeat_instrument = ''
   and record_id in(
         select record_id from aag1_encounter1 )
 -- For clients served, only show them if they had an encounter
 -- within the range.
 ;

drop view if exists aag1_problem;
create view aag1_problem as
select aag1_problem1.*
     , problem_type___1 +
        problem_type___2 +
        problem_type___3 +
        problem_type___4 +
        problem_type___5 +
        problem_type___6 +
        problem_type___7 +
        problem_type___8 +
        problem_type___9 +
        problem_type___10 +
        problem_type___11 +
        problem_type___12 +
        problem_type___13 +
        problem_type___14 +
        problem_type___20 problems
  from aag1_problem1;

drop view if exists aag1_has_problems;
create view aag1_has_problems as
select cast(count(*) as real) as it
  from aag1_problem
 where problems > 0
-- Number of clients (served) who have any problems at all
;

drop view if exists aag1_problem_percent1;
create view aag1_problem_percent1 as
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Impaired Mobility' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___1 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Fall Risk' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___2 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Social isolation/weak social support' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___3 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Ineffective symptom management' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___4 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Frailty' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___5 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Self-care deficit' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___6 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Not taking medications correctly' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___7 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Mental health issue' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___8 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Impaired cognitive function' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___9 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Poor nutrition/food insecurity' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___10 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Financial stress' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___11 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Transportation' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___12 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Struggling to remain at home; options being considered' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___13 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Potential for caregiver burnout' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___14 > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Other problems' label
  from aag1_problem
  join aag1_has_problems
 where problem_type___20 > 0;

drop view if exists aag1_problem_percent2;
create view aag1_problem_percent2 as
select (100 + percentage)||label as sort_key
     , percentage
     , label||substr('                    ',1,min(length(label),20-length(label))) as label
  from aag1_problem_percent1
 where percentage > 0;

drop view if exists aag1_problem_percent;
create view aag1_problem_percent as
select ( select count(*) from aag1_problem_percent2 where sort_key >= this.sort_key ) rank
     , percentage
     , label
  from aag1_problem_percent2 this
-- This view is pretty slow to query.  If it gets too slow with more data,
-- it would probably help to use a temporary table for the output from 
-- aag1_problem_percent2.
;

drop view if exists aag1_intervene1;
create view aag1_intervene1 as
select record_id
     , redcap_data_access_group town
     , redcap_repeat_instance
     , encounter_intervention___1
     , encounter_intervention___2
     , encounter_intervention___3
     , encounter_intervention___4
     , encounter_intervention___5
     , encounter_intervention___6
     , encounter_intervention___7
     , encounter_intervention___8
     , encounter_intervention___9
     , encounter_intervention___10
     , encounter_intervention___12
     , encounter_intervention___13
     , encounter_intervention___11 --Other
  from aag1_encounter1;

drop view if exists aag1_intervene_all;
create view aag1_intervene_all as
select record_id
     , town
     , redcap_repeat_instance
     , encounter_intervention___1 +
        encounter_intervention___2 +
        encounter_intervention___3 +
        encounter_intervention___4 +
        encounter_intervention___5 +
        encounter_intervention___6 +
        encounter_intervention___7 +
        encounter_intervention___8 +
        encounter_intervention___9 +
        encounter_intervention___10 +
        encounter_intervention___12 +
        encounter_intervention___13 +
        encounter_intervention___11 as interv_sum
  from aag1_intervene1;

drop view if exists aag1_intervene2;
create view aag1_intervene2 as
select 'Care coordination/management, Referrals' label
     , sum(case when encounter_intervention___1 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'Facilitate/Participate in telehealth visit' label
     , sum(case when encounter_intervention___2 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'Advised or provided information about Covid-19' label
     , sum(case when encounter_intervention___3 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'Reassurance/emotional support' label
     , sum(case when encounter_intervention___4 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'Medication-related' label
     , sum(case when encounter_intervention___5 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'Symptom management' label
     , sum(case when encounter_intervention___6 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'ADL & Mobility' label
     , sum(case when encounter_intervention___7 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'Family & Caregiver' label
     , sum(case when encounter_intervention___8 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'Social risk factors/drivers' label
     , sum(case when encounter_intervention___9 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'IADL (Instrumental Activities of Daily Living)' label
     , sum(case when encounter_intervention___10 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'Delivered essential items to home' label
     , sum(case when encounter_intervention___12 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'Referred or Helped with End-of-life documents' label
     , sum(case when encounter_intervention___13 > 0 then 1 else 0 end) value
     , count(*) total
  from aag1_intervene1
union all
select 'Other' label
      , sum(case when encounter_intervention___11 > 0 then 1 else 0 end) value
      , count(*) total
  from aag1_intervene1;


drop view if exists aag1_intervene3;
create view aag1_intervene3 as
select label
     , value
     , cast(round(value*100./total) as integer) percentage
  from aag1_intervene2;

drop view if exists aag1_intervene4;
create view aag1_intervene4 as
select label
     , value
     , percentage
     , (100 + percentage)||label as sort_key
  from aag1_intervene3;

drop view if exists aag1_intervene5;
create view aag1_intervene5 as
select ( select count(*) from aag1_intervene4 where sort_key >= this.sort_key ) rank
     , label
     , value
     , percentage
     , label
  from aag1_intervene4 this;


drop view if exists aag1_outcome1;
create view aag1_outcome1 as 
select record_id
     , redcap_data_access_group town
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , six_month_outcome___1  outcome_1
     , six_month_outcome___2  outcome_2
     , six_month_outcome___3  outcome_3
     , six_month_outcome___4  outcome_4
     , six_month_outcome___5  outcome_5
     , six_month_outcome___6  outcome_6
     , six_month_outcome___7  outcome_7
     , six_month_outcome___8  outcome_8
     , six_month_outcome___9  outcome_9
     , six_month_outcome___10 outcome_10
     , six_month_outcome___11 outcome_11
     , six_month_outcome___12 outcome_12
     , six_month_outcome___13 outcome_13
     , six_month_outcome___14 outcome_14
     , six_month_outcome___30 outcome_30
     , six_month_outcome___50 outcome_50
  from aag1
  join aag_date_range d
    on coalesce(six_month_date,d.last) between d.first and d.last
    or six_month_date = ''
 where redcap_repeat_instrument = 'six_month_report'
   and record_id in(select record_id from aag1_encounter1)
union all
select record_id
     , redcap_data_access_group town
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , status_update_outcome___1  outcome_1
     , status_update_outcome___2  outcome_2
     , status_update_outcome___3  outcome_3
     , status_update_outcome___4  outcome_4
     , status_update_outcome___5  outcome_5
     , status_update_outcome___6  outcome_6
     , status_update_outcome___7  outcome_7
     , status_update_outcome___8  outcome_8
     , status_update_outcome___9  outcome_9
     , status_update_outcome___10 outcome_10
     , status_update_outcome___11 outcome_11
     , status_update_outcome___12 outcome_12
     , status_update_outcome___13 outcome_13
     , status_update_outcome___14 outcome_14
     , status_update_outcome___30 outcome_30
     , status_update_outcome___50 outcome_50
  from aag1
  join aag_date_range d
    on coalesce(six_month_date,d.last) between d.first and d.last
    or six_month_date = ''
 where redcap_repeat_instrument = 'status_update'
   and client_redcap_status = 3 -- Discharged.
   and record_id in(select record_id from aag1_encounter1);

drop view if exists aag1_outcome2;
create view aag1_outcome2 as
select 'Less client anxiety or worry' label
     ,  cast(round(portion*100./total) as integer) percentage
  from (select count(*) as total
             , sum(case when outcome_1 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Reduced caregiver stress' label
     ,  cast(round(portion*100./total) as integer) percentage
  from (select count(*) as total
             , sum(case when outcome_2 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Reduced social isolation' label
     ,  cast(round(portion*100./total) as integer) percentage
  from (select count(*) as total
             , sum(case when outcome_3 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Better family understanding, communication and/or dynamics'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_4 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Improved functioning in daily life'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_5 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Improved management of illness symptoms'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_6 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Improved medication taking'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_7 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Reduced fall risk or falls'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_8 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
-- The label for this next item is used elsewhere, so be careful.
select 'Prevented hospitalization or ED visit'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_9 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)     
union all
select 'Fewer EMT emergency calls'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_10 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)     
union all
select 'Reduced food insecurity'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_11 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)     
union all
select 'Able to live at home longer'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_12 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)     
union all
select 'Smooth Transition (to home or from home)'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_13 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)     
union all
select 'Better management of end-of-life'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_14 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)     
union all
select 'Other'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_30 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)     
union all
select 'No significant change'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_50 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)     
union all
select 'Not recorded'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case 
                    when outcome_1 + outcome_2 + outcome_3 + 
                            outcome_4 + outcome_5 + outcome_6 + 
                            outcome_7 + outcome_8 + outcome_9 +
                            outcome_10 + outcome_11 + outcome_12 + 
                            outcome_13 + outcome_14 + outcome_30 +
                            outcome_50 > 0 then 0
                    else 1
                   end) as portion
          from aag1_outcome1);          

drop view if exists aag1_outcome3;
create view aag1_outcome3 as
select (100 + percentage)||label as sort_key
     , label
     , percentage
  from aag1_outcome2
 where percentage > 0;
  
drop view if exists aag1_outcome;
create view aag1_outcome as
select ( select count(*) from aag1_outcome3 where sort_key >= this.sort_key ) rank
     , label
     , percentage
  from aag1_outcome3 this;


drop view if exists aag1_discharge;
create view aag1_discharge as
select *
  from aag1
  join aag_date_range d
    on coalesce(six_month_date,d.last) between d.first and d.last
    or six_month_date = ''
 where redcap_repeat_instrument = 'status_update'
   and client_redcap_status = 3 -- Discharged.
   and record_id in(select record_id from aag1_encounter1) 
-- The date should be required, but it is not.
;


drop view if exists aag1_discharge_reason1;
create view aag1_discharge_reason1 as
select 'Situation or illness improved' label
     , cast(round(sum(case when status_update_reason = 1 then 1 else 0 end)*100./count(*)) as integer) percentage
  from aag1_discharge
union all
select 'Transferred to assisted living or long term care' label
     , cast(round(sum(case when status_update_reason = 2 then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge
union all
select 'Moved' label
     , cast(round(sum(case when status_update_reason = 3 then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge
union all
select 'Died' label
     , cast(round(sum(case when status_update_reason = 4 then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge
union all
select 'Declined further service' label
     , cast(round(sum(case when status_update_reason = 5 then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge
union all
select 'Other' label
     , cast(round(sum(case when status_update_reason in(6,9) then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge
union all
select 'Limited Concern addressed' label
     , cast(round(sum(case when status_update_reason = 8 then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge
union all
select 'Not recorded' label
     , cast(round(sum(case when status_update_reason = '' then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge;

drop view if exists aag1_discharge_reason2;
create view aag1_discharge_reason2 as
select (100+percentage)||label sort_key
     , label
     , percentage
  from aag1_discharge_reason1
 where percentage > 0;

drop view if exists aag1_discharge_reason;
create view aag1_discharge_reason as
select ( select count(*) from aag1_discharge_reason2 where sort_key >= this.sort_key ) rank
     , label
     , percentage
  from aag1_discharge_reason2 this;

  
--- End of views.
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------