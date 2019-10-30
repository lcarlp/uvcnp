-- SQL Script to generate the "At A Glance" (AAG) report.
-- Table all1 is assumed to have been imported from a CSV export of the REDCap database.
-- Table aag_town is manually populated to contain a list of towns included in the report.
-- Table aag_date_range is manually populated to contain an inclusive range of dates for the report.

drop view if exists aag1;
create view aag1 as
select * from all1
join aag_town using (redcap_data_access_group);

drop view if exists aag1_profile;
create view aag1_profile as
select record_id
     , status_profile
     , cast(age as real) as age
     , gender
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
     , end_life_plan___2 -- Living will DPOAH
     , case 
          when end_life_plan___1 + end_life_plan___2 + end_life_plan___3 + 
               end_life_plan___4 + end_life_plan___5 + end_life_plan___6 = 0 then 1 
          else 0
       end as no_end_life_plan 
     , client_anx_before
     , care_giver
     , provider1_affiliation
     , hospital_used
  from aag1
 where redcap_repeat_instrument = '';

-- The following superfically complicated view takes into account that the
-- user might select more than one method for a contact.  For methods 1-9,
-- if more than one is selected, we count that as multiple encounters.  We 
-- do not add to the count if "Other" is also selected, but we do count as
-- "Other" any encounter where none of the other 9 methods are selected.
-- Note that most of the selects being UNIONed together follow a pattern.
drop view if exists aag1_encounter_all;
create view aag1_encounter_all as
select record_id
     , date_1st_contact as encounter_date
     , 1 as initial
     , meth_1st_contact as type
  from aag1
 where redcap_repeat_instrument = ''
union all
select record_id
     , today_date_v2 as encounter_date
     , 0 as initial
     , 1 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___1 = 1
union all
select record_id
     , today_date_v2 as encounter_date
     , 0 as initial
     , 2 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___2 = 1
union all
select record_id
     , today_date_v2 as encounter_date
     , 0 as initial
     , 3 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___3 = 1
union all
select record_id
     , today_date_v2 as encounter_date
     , 0 as initial
     , 4 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___4 = 1
union all
select record_id
     , today_date_v2 as encounter_date
     , 0 as initial
     , 5 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___5 = 1
union all
select record_id
     , today_date_v2 as encounter_date
     , 0 as initial
     , 6 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___6 = 1
union all
select record_id
     , today_date_v2 as encounter_date
     , 0 as initial
     , 7 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___7 = 1
union all
select record_id
     , today_date_v2 as encounter_date
     , 0 as initial
     , 8 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___8 = 1
union all
select record_id
     , today_date_v2 as encounter_date
     , 0 as initial
     , 9 as type
  from aag1
 where redcap_repeat_instrument = 'interval_contacts'
   and cont_meth_v2___9 = 1
union all
select record_id
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
     , encounter_date
     , initial
     , type
  from aag1_encounter_all e
  join aag_date_range d
 where e.encounter_date between d.first and d.last;

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
    on first_month.number = strftime('%m',d.first)
  join month as last_month
    on last_month.number = strftime('%m',d.last);

drop view if exists aag1_problem;
create view aag1_problem as
select record_id
     , ed_visits___1 as ed_visits                        
     , incorrect_meds___1 as incorrect_meds              
     , ineff_ther___1 as ineff_ther                      
     , sympt_manag___1 as sympt_manag                    
     , frailty___1 as frailty                            
     , impair_cog___1 as impair_cog                      
     , ment_heal___1 as ment_heal                        
     , self_care_prob_list___1 as self_care_prob_list    
     , imp_phys_mob___1 as imp_phys_mob                  
     , fall___1 as fall                                  
     , stay_home___1 as stay_home                        
     , prob_bills___1 as prob_bills                      
     , stress_trans___1 as stress_trans                  
     , incom_acp___1 as incom_acp                        
     , other_prob_list___1 as other_prob_list            
     , sdoh_iso___1 as sdoh_iso                          
     , nutr_poor___1 as nutr_poor                        
     , hous_def___1 as hous_def                          
     , sdoh_transp___1 as sdoh_transp                    
     , sdoh_finance___1 as sdoh_finance                  
     , sdoh_other_2___1 as sdoh_other_2                  
     , ed_visits___1
     +   incorrect_meds___1
     +   ineff_ther___1
     +   sympt_manag___1
     +   frailty___1
     +   impair_cog___1
     +   ment_heal___1
     +   self_care_prob_list___1
     +   imp_phys_mob___1
     +   fall___1
     +   stay_home___1
     +   prob_bills___1
     +   stress_trans___1
     +   incom_acp___1
     +   other_prob_list___1
     +   sdoh_iso___1
     +   nutr_poor___1
     +   hous_def___1
     +   sdoh_transp___1
     +   sdoh_finance___1
     +   sdoh_other_2___1 problems
  from aag1
 where redcap_repeat_instrument = '';

drop view if exists aag1_has_problems;
create view aag1_has_problems as
select cast(count(*) as real) as it
  from aag1_problem
 where problems > 0;



-- See comments after .mode & .width
.mode column
.width 0
-- .mode colum seems to be the only thing that really works
-- .width 0 selects width based on query... which is ideal in our case.  

select '';
select '----------------------------------------------------------------------';
select '';
select 'Upper Valley Community Nursing Project';
select 'Hanover Community Nurse'; 
select first_day||' '||first_month||' '||first_year||' - ' ||
         last_day||' '||last_month||' '||last_year from aag1_dates;
select 'At A Glance';
select '';
select '';

select 'Town Population:  11,428						(Gov. census estimates 2017)';
select '# Residents age 65-74:  588 (5%)		# residents 75 or over:	837 (7%)';
select 'WHERE DID ABOVE NUMBERS COME FROM??????';

select '';
select 'Community/Parish Nurse Program details';
select 'Program Founded:  2018';
select 'Annual Budget:  $';
select 'Funding (town appropriation or other):  $';
select 'Organizational Structure:';
select 'Contact information:  ###-###-####';
select 'Website (url):';


select '';
select 'Client Demographics & Social Context';
-- Clients served, total:	 39
select 'Clients served, total: '||count(*)
  from aag1_profile;

--     As of July 11, 2019:      Active:  21 (54%)    Inactive:  10 (26%)     Discharged:  8 (20%)
select 'As of '||last_month||' '||last_day||', '||last_year||'    '||
          (select 'Active: '||count(*)||' ('||cast(round(count(*)*100/total) as int)||'%)' from aag1_profile where status_profile=1)||
          (select '    Inactive: '||count(*)||' ('||cast(round(count(*)*100/total) as int)||'%)' from aag1_profile where status_profile=2)||
          (select '    Discharged: '||count(*)||' ('||cast(round(count(*)*100/total) as int)||'%)' from aag1_profile where status_profile=3)||
          (select '    Blank: '||count(*) from aag1_profile where status_profile not in(1,2,3))
from aag1_dates
join (select cast(count(*) as real) as total from aag1_profile where status_profile in(1,2,3));
--
-- Age Range:   37 – 106 y/o
select 'Age Range:   '||min(cast(age as int))||' - '||max(cast(age as int))||' y/o' from aag1_profile;
--
-- Half of the Clients are older than (median age):   83 y/o
select 'Half of Clients are older than (median age): '||cast(avg(age) as int)
  from (select age
          from aag1_profile
         order by age
         limit 2 - (select count(*) from aag1_profile) % 2    -- odd 1, even 2
         offset (select (count(*) - 1) / 2 from aag1_profile) );


-- Gender:    male    41%      female      59%
select (select 'Gender: male  '||cast(round(count(*)*100/total) as int)||'%' from aag1_profile where gender=1)||
(select '    female: '||cast(round(count(*)*100/total) as int)||'%' from aag1_profile where gender=2)||
(select '    Blank: '||count(*) from aag1_profile where gender not in(1,2))
from (select cast(count(*) as real) as total from aag1_profile where gender in(1,2));

-- Ethnicity/Cultural Identity:    unk.
select 'Ethnicity/Cultural Identity:    unk.';
-- Lives Alone:     unk.
select 'Live Alone:  unk.';

select '';
select 'Program Services';
-- Nursing hours worked per week (avg.):   #
select 'Nursing hours worked per week (avg.):   #';
-- Total number of initial contacts/assessments:    19
select 'Total number of initial contacts/assessments:  '||count(*)
  from aag1_encounter as e
 where e.initial = 1;
-- Total number of follow-up contacts:	    317
select 'Total number of follow-up contacts:	  '||count(*)
  from aag1_encounter e
 where e.initial = 0;
-- Total number of client contacts:     336
select 'Total number of client contacts:  '||count(*)
  from aag1_encounter e;

-- Avg. number of client contacts per week (38 wks.):	8.8
select 'Avg. number of client contacts per week ('||
          cast(round(w.weeks) as int)||' wks.):	'||
          round(count(*)/w.weeks,1)
  from aag1_encounter
  join aag1_dates as w;


-- Home visits:	218  (65% of all client contacts/visits)
select 'Home visits: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=1 then 1 else 0 end) as portion
          from aag1_encounter);

-- Phone calls/emails with clients/families/providers:	68  (20% of all client contacts/visits)
select 'Phone calls/emails with clients/families/providers: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=2 or type=3 then 1 else 0 end) as portion
          from aag1_encounter);

-- Office visits:	0 (0% of all client contacts/visits)
select 'Office visits: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=5 then 1 else 0 end) as portion
          from aag1_encounter);

-- Hosp./Rehab/ECF visits:   38  (11% of all client contacts/visits)
select 'Hosp./Rehab/ECF visits: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=6 or type=7 then 1 else 0 end) as portion
          from aag1_encounter);

-- Family meetings:	     6  (2% of all client contacts/visits)
select 'Family meetings: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=4 or type=8 then 1 else 0 end) as portion
          from aag1_encounter);

-- Other:      7  (2% of all client contacts/visits)
select 'Other: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=9 or type=10 then 1 else 0 end) as portion
          from aag1_encounter);

select '';
select 'Client Referrals (referred by…)';
-- Primary Care Provider:  33%
select 'Primary Care Provider: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___4 = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- Family:   26%
select 'Family: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___2 = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- Self:   13%
select 'Self: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___1 = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- Neighbor/Friend:   13%
select 'Neighbor/Friend: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___3 = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- Fast Squad/Ambulance Service:   5%
select 'Fast Squad/Ambulance Service: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___8 = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- Community Agency:  0%
select 'Community Agency: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___5 = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- Clergy:   0%
select 'Clergy: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___6 = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- Hosp./SNF Discharge Coord.:   0%
select 'Hosp./SNF Discharge Coord.: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___7 = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- Other:   18%
select 'Other: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___9 = 1 then 1 else 0 end) as portion
          from aag1_profile);
select 'Missing: '||
          cast(round(portion*100./total) as int)||'%  ('||portion||')'
  from (select count(*) as total
             , sum(case when referred_by___1
                              + referred_by___2
                              + referred_by___3
                              + referred_by___4
                              + referred_by___5
                              + referred_by___6
                              + referred_by___7
                              + referred_by___8
                              + referred_by___9 = 0 then 1 else 0 end) as portion
          from aag1_profile );

select '';
select 'Other Client Profile Information';
-- Has a Living Will/DPOAH Doc:   81%
select 'Has a Living Will/DPOAH Doc:   '||cast(round(portion*100./total) as int)||'%  ('||
          portion||')'
  from (select count(*) as total
             , sum(case when end_life_plan___2 = 1 then 1 else 0 end) as portion
          from aag1_profile);
select 'No end of life plan entered:   '||cast(round(portion*100./total) as int)||'%   ('||
          portion||')'
  from (select count(*) as total
             , sum(case when no_end_life_plan = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- Anxious/Fearful about health and well-being?:   Often: 29%      Sometimes: 68%
select 'Anxious/Fearful about health and well-being?:'||
         (select '   Often: '|| cast(round(count(*)*100/total) as int)||'%' from aag1_profile where client_anx_before=1)||
         (select '    Sometimes: '|| cast(round(count(*)*100/total) as int)||'%' from aag1_profile where client_anx_before=2)||
         (select '    Not often: '|| cast(round(count(*)*100/total) as int)||'%' from aag1_profile where client_anx_before=3)||
         (select '    No data: '|| cast(round(count(*)*100/total) as int)||'%  ('||count(*)||')' from aag1_profile where client_anx_before='')
  from (select cast(count(*) as real) as total from aag1_profile);
-- Client has a caregiver(s)?:   Yes:  33%     No:  67%
select 'Client has a caregiver(s)?:'||
          (select '   Yes:  '||cast(round(count(*)*100/total) as int)||'%' from aag1_profile where care_giver=1)||
          (select '   No:  '||cast(round(count(*)*100/total) as int)||'%' from aag1_profile where care_giver=0)||
          (select '   No data:  '||cast(round(count(*)*100/total) as int)||'% ('||count(*)||')' from aag1_profile where care_giver='')
  from (select cast(count(*) as real) as total from aag1_profile);

select '';
select 'Affiliation of Primary Care Provider';
-- DHMC:   87%
select 'DHMC:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- APD:   3%
select 'APD:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 2 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'Mt. Ascutney Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 3 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'Gifford Medical Center:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 4 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'Valley Regional Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 5 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'Cottage Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 6 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'New London Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 7 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
-- Private/Community-based Practice:   3%
select 'Private/Community-based Practice:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 8 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
-- VAH:   7%
select 'VA:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 9 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'Other:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 10 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'No data:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = '' then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;

select '';
select 'Hospital Most Often Used';
-- DHMC:   97%
select 'DHMC:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 1 then 1 else 0 end) as portion
          from aag1_profile);
-- APD:   3%
select 'APD:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 2 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'Mt. Ascutney Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 3 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'Gifford Medical Center:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 4 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'Valley Regional Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 5 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'Cottage Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 6 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'New London Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 7 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'Other:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 8 then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;
select 'No data:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = '' then 1 else 0 end) as portion
          from aag1_profile)
 where portion > 0;


-- Top Client Problems: (% of clients for whom problems were identified and documented. R=23 (59%))
select 'Top Client Problems: (% of clients for whom problems were identified and documented. R='||
          portion||'  ('||cast(round(portion*100./total) as int)||'%))'
  from (select count(*) as total
             , sum(case when problems > 0 then 1 else 0 end) as portion
          from aag1_problem);
--     •	Impaired Mobility 	65%
--     •	High Fall Risk	57%
--     •	Social Isolation	57%
--     •	Frailty	39%
--     •	Problems w/ self-care		35%
--     •	Impaired Cognitive Function	35%
--     •	Mental Health or Substance Abuse Issue		35%
-- Other problems:  Difficulty living at home (26%); Lack of transportation (26%); 
--   Ineffective enactment of therapeutic recommendations (17%); Not taking medications correctly (17%); 
--   Financial struggles (13%); Anticipating stressful transition to another level of care (13%); 
--   Frequent ED Visits/EMS Calls (9%); Poor nutrition (9%); Problems with bills, insurance, etc. (9%); 
--   Incomplete end-of-life planning (9%); Symptoms not well controlled (4%); Deficient housing (4%)
select '    '||label||':  '||percentage
  from (
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Frequent ED visits or EMS calls' label
    from aag1_problem
    join aag1_has_problems
  where ed_visits = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Not taking meds correctly' label
    from aag1_problem
    join aag1_has_problems
  where incorrect_meds = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Ineffective enactment of therapeutic recommendations (diet, exercise, wound care)' label
    from aag1_problem
    join aag1_has_problems
  where ineff_ther = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Symptom(s) not well controlled' label
    from aag1_problem
    join aag1_has_problems
  where sympt_manag = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Frailty' label
    from aag1_problem
    join aag1_has_problems
  where frailty = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Impaired cognitive functioning, poor decision making, and/or problem solving' label
    from aag1_problem
    join aag1_has_problems
  where impair_cog = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Mental health issue, depression, anxiety or substance abuse' label
    from aag1_problem
    join aag1_has_problems
  where ment_heal = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Self-care deficit in performing ADLs' label
    from aag1_problem
    join aag1_has_problems
  where self_care_prob_list = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Impaired physical mobility' label
    from aag1_problem
    join aag1_has_problems
  where imp_phys_mob = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Fall risk' label
    from aag1_problem
    join aag1_has_problems
  where fall = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Difficulty living at home' label
    from aag1_problem
    join aag1_has_problems
  where stay_home = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Problems with bills, insurance paperwork, enrollments' label
    from aag1_problem
    join aag1_has_problems
  where prob_bills = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Anticipated stressful transition to another level of care' label
    from aag1_problem
    join aag1_has_problems
  where stress_trans = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Incomplete end of life planning and documentation' label
    from aag1_problem
    join aag1_has_problems
  where incom_acp = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Other problems' label
    from aag1_problem
    join aag1_has_problems
  where other_prob_list = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Social isolation' label
    from aag1_problem
    join aag1_has_problems
  where sdoh_iso = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Nutrition, poor' label
    from aag1_problem
    join aag1_has_problems
  where nutr_poor = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Housing, deficient' label
    from aag1_problem
    join aag1_has_problems
  where hous_def = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Transportation, lack' label
    from aag1_problem
    join aag1_has_problems
  where sdoh_transp = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Finances, struggling/inadequate' label
    from aag1_problem
    join aag1_has_problems
  where sdoh_finance = 1
  union all
  select cast(round(count(*)*100./aag1_has_problems.it) as int) percentage,
        'Other social' label
    from aag1_problem
    join aag1_has_problems
  where sdoh_other_2 = 1 )
order by percentage desc;


-- Top Nurse interventions:   (% of client visits in which nursing interventions were performed and documented.)
--     •	Medication reconciliation, education and management coaching   33%
-- [Educate re medications and how to take them (21%), Fill pill box(es) (29%), Help to obtain medications (20%), Monitor medication adherence (69%), Assist with change in medications (9%)]

--     •	Symptom management - assessment & education   28%
-- [Teach re symptom management and monitor symptoms over time (28%), Reassure client and make recommendations re anxiety, depression, sleep, and mental health concerns (35%), Instruct and reassure re: what to do if s/he needs emergency help (9%), Give/ recommend and discuss educational materials re: health maintenance, medical conditions, and related resources (2%), Monitor BP, heart rate, SOB, weight, blood sugar level, pulse, oxygen, hydration (29%)]

--     •	Care coordination & clarification with providers    16%
-- [For Symptom Management (21%), To be seen (9%), Medication or care clarification (30%), Worsening condition (9%), Discuss referral to VNA, Hospice, PT (7%), Other (39%)]

--     •	Address other support services    13%
-- [Discuss options for getting help with household tasks (shopping, cleaning, food prep, house repairs) (44%), Suggest or arrange socialization opportunities (15%), Identify resources for help with transportation (10%), Address food insecurity (7%), Address housing inadequacy (7%), Facilitate getting help for finances, legal documents, taxes (20%), Initiate advance planning discussions and document completion (2%), Advise re immunizations (0%), Other (15%)]

--     •	Family and caregiver support    10%
-- [Support family/care giver(s) with family member who is frail or has a cognitive deficit (6%), Facilitate family dialogue re caregiving decisions & strategies (56%), Discuss and plan respite for caregiver (0.0%), Coordinate a care setting transition (31%), Other (13%)]
--     •	Address ADLs & mobility-related support    7%
-- [Teach client self-care r/t incontinence, bowel problems, dressing and hygiene (10%), Teach and make recommendations re: mobility, activity, and/or exercise (38%), Obtain durable medical equipment and instruct on usage (10%), Make recommendations to reduce fall risk (14%), Point out and make suggestions re: environmental safety risks (5%), Other ( 33%)]


-- Nurse-Reported Functional Health Assessment - Reported at every interval visit
--     •	Physical Condition:  Declined:  15%    Unchanged:  73%    Improved:  12%
--     •	Emotional Status:    Declined:  18%    Unchanged:  70%    Improved:  12%
--     •	Cognitive Status:      Declined:  4%      Unchanged:  96%    Improved:  0.4%
--     •	Had a Fall Since Last Visit?:        Yes:  7%    No:  93%
--     •	Hospitalized Since Last Visit?:    Yes:  7%    No:  93%

-- Reason for Discharge  (R=7)
--     •	Moved away from service area     43%
--     •	Death	     29%
--     •	Services no longer needed	29%
--     •	Services not wanted	0%
-- Nurse-Reported Outcomes - Reported at 6-months or Discharge: (% of clients who were discharged or had a 6-month assessment and were documented. R=7)
--     •	Helped client and/or family to be less anxious about dealing with their situation     71%
--     •	Enabled client to continue living in home for at least 6 months	14%
--     •	Helped improve client’s management of illness symptoms	     0%
--     •	Improved client’s functioning in daily life	0%
--     •	Prevented medication-related, adverse outcomes or ineffective therapeutic effect	0%
--     •	Prevented Emergency Call, ED Visit, or Re-hospitalization	0%
--     •	Other	29%

-- ✯ ✯ ✯

-- Clarifications:
--     •	The Client Problems, Nurse Interventions, and Nurse-Reported Outcomes in this report are based on information entered into the Upper Valley Community Nurse Project’s Electronic Documentation System used by your community/parish nurse. Importantly, Client Problems do not represent the prevalence of these conditions in the larger community; rather, they profile the clients served by your community or parish nurse.

--     •	The data reported here is based upon UVCNP Electronic Documentation Project input from October 15, 2018 to July 11, 2019 (38 weeks). Utilization of the system to document client care (40-60% of clients for most forms) affects the data analysis and reported findings cannot be generalized to the nurse’s entire client list. We expect the relevance and accuracy of the data to improve over time as the nurses gain experience and efficiency in using the documentation system and utilization of the EDS increases.

--     •	Every client does not necessarily need or receive a comprehensive assessment. Problems, Interventions and Nurse-reported Outcomes are not done or documented for every client. Therefore, these reported findings represent the percentage of clients for whom Problems, Interventions and Outcomes were assessed and documented, not the percentage of ALL clients. Like the other findings, this data cannot be generalized to ALL clients enrolled in your Community or Parish Nurse program.

-- ✯ ✯ ✯ ✯
-- Go back to list mode, because it is more convenient for routine queries/debugging etc.
.mode list