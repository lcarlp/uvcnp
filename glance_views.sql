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
     , status_profile
     , cast(age as real) as age
     , gender
     , today as admit_date
     , date_1st_contact
     , referred_by___1
     , referred_by___2
     , referred_by___3
     , referred_by___4
     , referred_by___5
     , referred_by___6
     , referred_by___7
     , referred_by___8
     , referred_by___9
     , case
        when referred_by___1 +
                referred_by___2 +
                referred_by___3 +
                referred_by___4 +
                referred_by___5 +
                referred_by___6 +
                referred_by___7 +
                referred_by___8 +
                referred_by___9 > 0 then 1
        else 0
        end as referred_by_any
     , end_life_plan___2 -- Living will DPOAH
     , case 
          when end_life_plan___1 + end_life_plan___2 + end_life_plan___3 + 
               end_life_plan___4 + end_life_plan___5 + end_life_plan___6 > 0 then 1 
          else 0
       end as end_life_plan_any
     , client_anx_before
     , care_giver
     , provider1_affiliation
     , case when provider1_affiliation = '' then 0 else 1 end as provider1_affiliation_any
     , hospital_used
     , case when hospital_used = '' then 0 else 1 end as hospital_used_any
  from aag1
 where redcap_repeat_instrument = ''
 ;

drop view if exists aag1_encountered1;
create view aag1_encountered1 as
select record_id
     , redcap_data_access_group town
     , date_1st_contact as encounter_date
     , 1 as initial
  from aag1
 where redcap_repeat_instrument = ''
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
  from aag1
 where redcap_repeat_instrument = 'interval_contacts';

drop view if exists aag1_encountered;
create view aag1_encountered as
select record_id
     , town
     , encounter_date
     , initial
  from aag1_encountered1 e
  join aag_date_range d
 where e.encounter_date between d.first and d.last
 -- Picks up anyone with an encounter in the range.
 ;


drop view if exists aag1_client;
create view aag1_client as
select *
  from aag1_client_all
 where record_id in(
         select record_id from aag1_encountered )
 -- For clients served, only show them if they had an encounter
 -- within the range.
 ;


drop view if exists aag1_client_age;
create view aag1_client_age as
select record_id, age
  from aag1_client
 where age >= 1
-- Ignore low ages that likely resulted from the nurse entering today's
-- date into the birthday field.
;


-- The following superfically complicated view takes into account that the
-- user might select more than one method for a contact.  For methods 1-9,
-- if more than one is selected, we count that as multiple encounters.  We 
-- do not add to the count if "Other" is also selected, but we do count as
-- "Other" any encounter where none of the other 9 methods are selected.
-- Note that most of the selects being UNIONed together follow a pattern.
drop view if exists aag1_encounter_all;
create view aag1_encounter_all as
select record_id
     , redcap_data_access_group town
     , date_1st_contact as encounter_date
     , 1 as initial
     , cast(meth_1st_contact as integer) as type
  from aag1
 where redcap_repeat_instrument = ''
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
     , 1 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___1 = 1
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
     , 2 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___2 = 1
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
     , 3 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___3 = 1
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
     , 4 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___4 = 1
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
     , 5 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___5 = 1
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
     , 6 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___6 = 1
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
     , 7 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___7 = 1
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
     , 8 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___8 = 1
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
     , 9 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___9 = 1
union all
select record_id
     , redcap_data_access_group town
     , today_date_v2 as encounter_date
     , 0 as initial
     , 10 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___1
        + cont_meth_v2___2
        + cont_meth_v2___3
        + cont_meth_v2___4
        + cont_meth_v2___5
        + cont_meth_v2___6
        + cont_meth_v2___7
        + cont_meth_v2___8
        + cont_meth_v2___9 = 0;

drop view if exists aag1_encounter;
create view aag1_encounter as
select record_id
     , town
     , encounter_date
     , initial
     , type
  from aag1_encounter_all e
  join aag_date_range d
 where e.encounter_date between d.first and d.last;


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

drop view if exists aag1_problem1;
create view aag1_problem1 as
select record_id
     , redcap_data_access_group town
     , ed_visits___1 + ed_visits___2 ed_visits
     , incorrect_meds___1 + incorrect_meds___2 incorrect_meds
     , ineff_ther___1 + ineff_ther___2 ineff_ther
     , sympt_manag___1 + sympt_manag___2 sympt_manag
     , frailty___1 + frailty___2 frailty
     , impair_cog___1 + impair_cog___2 impair_cog
     , ment_heal___1 + ment_heal___2 ment_heal
     , self_care_prob_list___1 + self_care_prob_list___2 self_care_prob_list
     , imp_phys_mob___1 + imp_phys_mob___2 imp_phys_mob
     , fall___1 + fall___2 fall
     , stay_home___1 + stay_home___2 stay_home
     , prob_bills___1 + prob_bills___2 prob_bills
     , stress_trans___1 + stress_trans___2 stress_trans
     , incom_acp___1 + incom_acp___2 incom_acp
     , other_prob_list___1 + other_prob_list___2 other_prob_list
     , sdoh_iso___1 + sdoh_iso___2 sdoh_iso
     , nutr_poor___1 + nutr_poor___2 nutr_poor
     , hous_def___1 + hous_def___2 hous_def
     , sdoh_transp___1 + sdoh_transp___2 sdoh_transp
     , sdoh_finance___1 + sdoh_finance___2 sdoh_finance
     , sdoh_other_2___1 + sdoh_other_2___2 sdoh_other_2
  from aag1
 where redcap_repeat_instrument = ''
   and record_id in(
         select record_id from aag1_encountered )
 -- For clients served, only show them if they had an encounter
 -- within the range.
 ;


drop view if exists aag1_problem;
create view aag1_problem as
select aag1_problem1.*
     , ed_visits
     +   incorrect_meds
     +   ineff_ther
     +   sympt_manag
     +   frailty
     +   impair_cog
     +   ment_heal
     +   self_care_prob_list
     +   imp_phys_mob
     +   fall
     +   stay_home
     +   prob_bills
     +   stress_trans
     +   incom_acp
     +   other_prob_list
     +   sdoh_iso
     +   nutr_poor
     +   hous_def
     +   sdoh_transp
     +   sdoh_finance
     +   sdoh_other_2 problems
  from aag1_problem1;

drop view if exists aag1_has_problems;
create view aag1_has_problems as
select cast(count(*) as real) as it
  from aag1_problem
 where problems > 0;

drop view if exists aag1_problem_percent1;
create view aag1_problem_percent1 as
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Frequent ED visits/EMS calls' label
  from aag1_problem
  join aag1_has_problems
 where ed_visits > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Not taking medications correctly' label
  from aag1_problem
  join aag1_has_problems
 where incorrect_meds > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Ineffective enactment of therapeutic recommendations' label
  from aag1_problem
  join aag1_has_problems
 where ineff_ther > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Symptom(s) not well controlled' label
  from aag1_problem
  join aag1_has_problems
 where sympt_manag > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Frailty' label
  from aag1_problem
  join aag1_has_problems
 where frailty > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Impaired cognitive functioning' label
  from aag1_problem
  join aag1_has_problems
 where impair_cog > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Mental Health or Substance Abuse Issue' label
  from aag1_problem
  join aag1_has_problems
 where ment_heal > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Self-care deficit in performing ADLs' label
  from aag1_problem
  join aag1_has_problems
 where self_care_prob_list > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Impaired Mobility' label
  from aag1_problem
  join aag1_has_problems
 where imp_phys_mob > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'High Fall Risk' label
  from aag1_problem
  join aag1_has_problems
 where fall > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Difficulty living at home' label
  from aag1_problem
  join aag1_has_problems
 where stay_home > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Problems with bills, insurance etc.' label
  from aag1_problem
  join aag1_has_problems
 where prob_bills > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Anticipated stressful transition to another level of care' label
  from aag1_problem
  join aag1_has_problems
 where stress_trans > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Incomplete end of life planning' label
  from aag1_problem
  join aag1_has_problems
 where incom_acp > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Other problems' label
  from aag1_problem
  join aag1_has_problems
 where other_prob_list > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Social isolation' label
  from aag1_problem
  join aag1_has_problems
 where sdoh_iso > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Poor Nutrition' label
  from aag1_problem
  join aag1_has_problems
 where nutr_poor > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Deficient Housing' label
  from aag1_problem
  join aag1_has_problems
 where hous_def > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Lack of Transportation' label
  from aag1_problem
  join aag1_has_problems
 where sdoh_transp > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Financial struggles' label
  from aag1_problem
  join aag1_has_problems
 where sdoh_finance > 0
union all
select cast(round(count(*)*100./aag1_has_problems.it) as integer) percentage
     , 'Other social' label
  from aag1_problem
  join aag1_has_problems
 where sdoh_other_2 > 0;

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

drop view if exists aag1_encounter1;
create view aag1_encounter1 as
select *
  from aag1
  join aag_date_range d
    on today_date_v2 between d.first and d.last
 where redcap_repeat_instrument = 'interval_contacts'
 -- This version of encounters is one-to-one with
 -- interval_contacts, unlike the other one that adds 
 -- additional encounters if there is more than one type
 -- in one encounter
 ;

drop view if exists aag1_intervene1;
create view aag1_intervene1 as
select record_id
     , redcap_data_access_group town
     , redcap_repeat_instance
     , pcp_for_v2___1 +
       pcp_for_v2___2 +
       pcp_for_v2___3 +
       pcp_for_v2___4 +
       pcp_for_v2___5 +
       pcp_for_v2___6 as pcp_for_v2
     , med_interv___1 +
       med_interv___2 +
       med_interv___3 +
       med_interv___4 +
       med_interv___5 +
       med_interv___6 as med_interv
     , sympt_interv___1 +
       sympt_interv___2 +
       sympt_interv___3 +
       sympt_interv___4 +
       sympt_interv___5 +
       sympt_interv___6 as sympt_interv
     , mob_interv___1 +
       mob_interv___2 +
       mob_interv___3 +
       mob_interv___4 +
       mob_interv___5 +
       mob_interv___6 as mob_interv
     , cg_fam_interv___1 +
       cg_fam_interv___2 +
       cg_fam_interv___3 +
       cg_fam_interv___4 +
       cg_fam_interv___5 as cg_fam_interv
     , house_fina_food_interv___1 +
       house_fina_food_interv___2 +
       house_fina_food_interv___3 +
       house_fina_food_interv___4 +
       house_fina_food_interv___5 +
       house_fina_food_interv___6 +
       house_fina_food_interv___7 +
       house_fina_food_interv___8 +
       house_fina_food_interv___9 as house_fina_food_interv
  from aag1_encounter1;

drop view if exists aag1_intervene_all;
create view aag1_intervene_all as
select record_id
     , redcap_data_access_group town
     , redcap_repeat_instance
     , pcp_for_v2 + med_interv + sympt_interv + mob_interv + 
            cg_fam_interv + house_fina_food_interv as interv_sum
     , pcp_for_v2 || med_interv || sympt_interv || mob_interv || 
            cg_fam_interv || house_fina_food_interv as interv
  from aag1_intervene1;

drop view if exists aag1_intervene2;
create view aag1_intervene2 as
select 'pcp_for_v2' name, sum(case when pcp_for_v2 > 0 then 1 else 0 end) value, count(*) total
  from aag1_intervene1
union all
select 'med_interv', sum(case when med_interv> 0 then 1 else 0 end), count(*)
  from aag1_intervene1
union all
select 'sympt_interv', sum(case when sympt_interv > 0 then 1 else 0 end), count(*)
  from aag1_intervene1
union all
select 'mob_interv', sum(case when mob_interv > 0 then 1 else 0 end), count(*)
  from aag1_intervene1
union all
select 'cg_fam_interv', sum(case when cg_fam_interv > 0 then 1 else 0 end), count(*)
  from aag1_intervene1
union all
select 'house_fina_food_interv', sum(case when house_fina_food_interv > 0 then 1 else 0 end), count(*)
  from aag1_intervene1;

drop view if exists aag1_intervene_label;
create view aag1_intervene_label as
select 'pcp_for_v2' name,'Care coordination & clarification with providers' label union all
select 'med_interv','Medication reconciliation, education and management coaching' union all
select 'sympt_interv','Symptom management - assessment & education' union all
select 'mob_interv','Address ADLs & mobility-related support' union all
select 'cg_fam_interv','Family and caregiver support' union all
select 'house_fina_food_interv','Address other support services';

drop view if exists aag1_intervene3;
create view aag1_intervene3 as
select name
     , value
     , cast(round(value*100./total) as integer) percentage
     , label
  from aag1_intervene2
  join aag1_intervene_label
 using (name);

drop view if exists aag1_intervene4;
create view aag1_intervene4 as
select name
     , value
     , percentage
     , label
     , (100 + percentage)||name as sort_key
  from aag1_intervene3;

drop view if exists aag1_intervene5;
create view aag1_intervene5 as
select ( select count(*) from aag1_intervene4 where sort_key >= this.sort_key ) rank
     , name
     , value
     , percentage
     , label
  from aag1_intervene4 this;

drop view if exists aag1_intervene_sub1;
create view aag1_intervene_sub1 as
select 'pcp_for_v2' name, 1 i, count(*) value, 'For Symptom Management' label from aag1_encounter1 where pcp_for_v2___1=1 union all
select 'pcp_for_v2', 2, count(*), 'To be seen' from aag1_encounter1 where pcp_for_v2___2=1 union all
select 'pcp_for_v2', 3, count(*), 'Medication or care clarification' from aag1_encounter1 where pcp_for_v2___3=1 union all
select 'pcp_for_v2', 4, count(*), 'Worsening condition' from aag1_encounter1 where pcp_for_v2___4=1 union all
select 'pcp_for_v2', 5, count(*), 'Discuss referral to VNA, Hospice,  PT' from aag1_encounter1 where pcp_for_v2___5=1 union all
select 'pcp_for_v2', 6, count(*), 'Other' from aag1_encounter1 where pcp_for_v2___6=1 union all
select 'med_interv', 1, count(*), 'Educate re medications and how to take them' from aag1_encounter1 where med_interv___1=1 union all
select 'med_interv', 2, count(*), 'Fill pill box(es)' from aag1_encounter1 where med_interv___2=1 union all
select 'med_interv', 3, count(*), 'Help to obtain medications' from aag1_encounter1 where med_interv___3=1 union all
select 'med_interv', 4, count(*), 'Monitor medication adherence' from aag1_encounter1 where med_interv___4=1 union all
select 'med_interv', 5, count(*), 'Change in medications' from aag1_encounter1 where med_interv___5=1 union all
select 'med_interv', 6, count(*), 'Other' from aag1_encounter1 where med_interv___6=1 union all
select 'sympt_interv', 1, count(*), 'Teach re symptom management and monitor symptoms over time' from aag1_encounter1 where sympt_interv___1=1 union all
select 'sympt_interv', 2, count(*), 'Reassure client and make recommendations re anxiety, depression, sleep, and mental health concerns' from aag1_encounter1 where sympt_interv___2=1 union all
select 'sympt_interv', 3, count(*), 'Instruct and reassure re: what to do if s/he needs emergency help' from aag1_encounter1 where sympt_interv___3=1 union all
select 'sympt_interv', 4, count(*), 'Give/ recommend and discuss educational materials re: health maintenance, medical conditions, and related resources' from aag1_encounter1 where sympt_interv___4=1 union all
select 'sympt_interv', 5, count(*), 'Monitor BP, heart rate, SOB, weight, blood sugar level, pulse, oxygen, hydration' from aag1_encounter1 where sympt_interv___5=1 union all
select 'sympt_interv', 6, count(*), 'Other' from aag1_encounter1 where sympt_interv___6=1 union all
select 'mob_interv', 1, count(*), 'Teach client self-care r/t incontinence, bowel problems, dressing and hygiene' from aag1_encounter1 where mob_interv___1=1 union all
select 'mob_interv', 2, count(*), 'Teach and make recommendations re: mobility, activity, and/or exercise' from aag1_encounter1 where mob_interv___2=1 union all
select 'mob_interv', 3, count(*), 'Obtain durable medical equipment and instruct on usage' from aag1_encounter1 where mob_interv___3=1 union all
select 'mob_interv', 4, count(*), 'Make recommendations to reduce fall risk' from aag1_encounter1 where mob_interv___4=1 union all
select 'mob_interv', 5, count(*), 'Point out and make suggestions re: environmental safety risks' from aag1_encounter1 where mob_interv___5=1 union all
select 'mob_interv', 6, count(*), 'Other' from aag1_encounter1 where mob_interv___6=1 union all
select 'cg_fam_interv', 1, count(*), 'Support family/care giver(s) with family member who is frail or has a cognitive deficit' from aag1_encounter1 where cg_fam_interv___1=1 union all
select 'cg_fam_interv', 2, count(*), 'Facilitate family dialogue re caregiving decisions & strategies' from aag1_encounter1 where cg_fam_interv___2=1 union all
select 'cg_fam_interv', 3, count(*), 'Discuss and plan respite for care giver' from aag1_encounter1 where cg_fam_interv___3=1 union all
select 'cg_fam_interv', 4, count(*), 'Coordinate a care setting transition' from aag1_encounter1 where cg_fam_interv___4=1 union all
select 'cg_fam_interv', 5, count(*), 'Other' from aag1_encounter1 where cg_fam_interv___5=1 union all
select 'house_fina_food_interv', 1, count(*), 'Discuss options for getting help with household tasks (shopping, cleaning, food prep, house repairs)' from aag1_encounter1 where house_fina_food_interv___1=1 union all
select 'house_fina_food_interv', 2, count(*), 'Suggest or arrange socialization opportunities' from aag1_encounter1 where house_fina_food_interv___2=1 union all
select 'house_fina_food_interv', 3, count(*), 'Identify resources for help with transportation' from aag1_encounter1 where house_fina_food_interv___3=1 union all
select 'house_fina_food_interv', 4, count(*), 'Address food insecurity' from aag1_encounter1 where house_fina_food_interv___4=1 union all
select 'house_fina_food_interv', 5, count(*), 'Address housing inadequacy' from aag1_encounter1 where house_fina_food_interv___5=1 union all
select 'house_fina_food_interv', 6, count(*), 'Facilitate getting help for finances, legal documents, taxes' from aag1_encounter1 where house_fina_food_interv___6=1 union all
select 'house_fina_food_interv', 7, count(*), 'Initiate advance planning discussions and document completion' from aag1_encounter1 where house_fina_food_interv___7=1 union all
select 'house_fina_food_interv', 8, count(*), 'Advise re immunizations' from aag1_encounter1 where house_fina_food_interv___8=1 union all
select 'house_fina_food_interv', 9, count(*), 'Other' from aag1_encounter1 where house_fina_food_interv___9=1;

drop view if exists aag1_intervene_sub2;
create view aag1_intervene_sub2 as
select name, sub1.i, sub1.value, sub1.label
     , cast(round(100.*sub1.value/a.value) as integer) percentage
  from aag1_intervene_sub1 sub1
  join aag1_intervene2 a
 using (name);


drop view if exists aag1_social_context;
create view aag1_social_context as
select record_id
     , max(redcap_repeat_instance)
     , address_v2
  from aag1
  join aag_date_range d
    on date_sc <= d.last
    or date_sc = ''
 where redcap_repeat_instrument = 'social_context'
   and record_id in(select record_id from aag1_encountered)
 group by record_id
 -- The date should be required, but it is not.
 -- We attempt to exclude recently entered records, and
 -- we only look at clients who are included.
 -- Uses a SQLite trick to get address_v2 for max repeat instance.
 ;

drop view if exists aag1_discharge;
create view aag1_discharge as
select *
  from aag1
  join aag_date_range d
    on coalesce(date_today_dis,d.last) between d.first and d.last
    or date_today_dis = ''
 where redcap_repeat_instrument = 'discharge_report'
   and record_id in(select record_id from aag1_encountered)
 -- The date should be required, but it is not.
 ;


drop view if exists aag1_discharge_reason1;
create view aag1_discharge_reason1 as
select 'Services no longer needed' label
     , cast(round(sum(case when reason_disch=1 then 1 else 0 end)*100./count(*)) as integer) percentage
  from aag1_discharge
union all
select 'Services not wanted' label
     , cast(round(sum(case when reason_disch=2 then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge
union all
select 'Death' label
     , cast(round(sum(case when reason_disch=3 then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge
union all
select 'Moved away from Service Area' label
     , cast(round(sum(case when reason_disch=4 then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge
union all
select 'Other' label
     , cast(round(sum(case when reason_disch=5 then 1 else 0 end)*100./count(*)) as integer)
  from aag1_discharge
union all
select 'Not recorded' label
     , cast(round(sum(case when reason_disch in(1,2,3,4,5) then 0 else 1 end)*100./count(*)) as integer)
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


drop view if exists aag1_6month;
create view aag1_6month as
select *
  from aag1
  join aag_date_range d
    on coalesce(date_sixmonth,d.last) between d.first and d.last
    or date_sixmonth = ''
 where redcap_repeat_instrument = 'month_report'
   and record_id in(select record_id from aag1_encountered);

drop view if exists aag1_outcome1;
create view aag1_outcome1 as 
select record_id
     , redcap_data_access_group town
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , nurse_out_6_mont___1 as outcome_1
     , nurse_out_6_mont___2 as outcome_2
     , nurse_out_6_mont___3 as outcome_3
     , nurse_out_6_mont___4 as outcome_4
     , nurse_out_6_mont___5 as outcome_5
     , nurse_out_6_mont___6 as outcome_6
     , nurse_out_6_mont___7 as outcome_7
     , nurse_out_6_mont___8 as outcome_8
     , nurse_out_6_mont___9 as outcome_9
  from aag1_6month
union all
select record_id
     , redcap_data_access_group town
     , redcap_repeat_instrument
     , redcap_repeat_instance
     , 0 as outcome_1
     , 0 as outcome_2
     , nurse_report_all___1 as outcome_3
     , nurse_report_all___2 as outcome_4
     , nurse_report_all___3 as outcome_5
     , nurse_report_all___4 as outcome_6
     , nurse_report_all___5 as outcome_7
     , nurse_report_all___6 as outcome_8
     , nurse_report_all___7 as outcome_9
  from aag1_discharge;


drop view if exists aag1_outcome2;
create view aag1_outcome2 as
select 'Decreased risk of falls' label
     ,  cast(round(portion*100./total) as integer) percentage
  from (select count(*) as total
             , sum(case when outcome_1 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Improved cognitive function, less confusion' label
     ,  cast(round(portion*100./total) as integer) percentage
  from (select count(*) as total
             , sum(case when outcome_2 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Prevented medication-related, adverse outcomes or ineffective therapeutic effect' label
     ,  cast(round(portion*100./total) as integer) percentage
  from (select count(*) as total
             , sum(case when outcome_3 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Helped client and/or family to be less anxious about dealing with their situation'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_4 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Helped improve client''s management of illness symptoms'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_5 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Prevented Emergency Call, ED Visit, or Re-hospitalization'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_6 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Improved client''s functioning in daily life'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_7 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Enabled client to continue living in home for at least 6 months'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_8 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)
union all
select 'Other'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case when outcome_9 = 1 then 1 else 0 end) as portion
          from aag1_outcome1)     
union all
select 'Not recorded'
     ,  cast(round(portion*100./total) as integer)
  from (select count(*) as total
             , sum(case 
                    when outcome_1 + outcome_2 + outcome_3 + 
                              outcome_4 + outcome_5 + outcome_6 + 
                              outcome_7 + outcome_8 + outcome_9 > 0 then 0
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
  
--- End of views.
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------