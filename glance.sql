-- SQL Script to generate the "At A Glance" (AAG) report.
-- Table all1 is assumed to have been imported from a CSV export of the REDCap database.
-- Table aag_town is manually populated to contain a list of towns included in the report.
-- Table aag_date_range is manually populated to contain an inclusive range of dates for the report.

.read glance_views.sql

-- See comments after .mode & .width
.mode column
.width 150
-- .mode colum seems to be the only thing that really works
-- unfortunately, .width 150 seems to pad to 150.
-- Based on the SQLite3 documentation, .width 0 should work, but it
-- seems to mess up some queries.  Why?

select '';
select '----------------------------------------------------------------------';
select '';
select 'Upper Valley Community Nursing Project';
select town||' Community Nurse'
  from aag_town;
select first_day||' '||first_month||' '||first_year||' - ' ||
         last_day||' '||last_month||' '||last_year 
  from aag1_dates;
select 'At A Glance';
select '';
select '';

--select 'Town Population:  11,428						(Gov. census estimates 2017)';
--select '   # Residents age 65-74:  588 (5%)		# residents 75 or over:	837 (7%)';
--select 'WHERE DID ABOVE NUMBERS COME FROM??????';

select '';
select 'Community/Parish Nurse Program details';
select '   Program Founded:  2018';
select '   Annual Budget:  $';
select '   Funding (town appropriation or other):  $';
select '   Organizational Structure:';
select '   Contact information:  ###-###-####';
select '   Website (url):';


select '';
select 'Client Demographics & Social Context';
-- Clients served, total:	 39
select '   Clients served, total: '||count(*)
  from aag1_client;

--     As of July 11, 2019:      Active:  21 (54%)    Inactive:  10 (26%)     Discharged:  8 (20%)
select '      As of '||last_month||' '||last_day||', '||last_year||'    '||
          (select 'Active: '||count(*)||' ('||cast(round(count(*)*100/total) as int)||'%)' from aag1_client where status_profile=1)||
          (select '    Inactive: '||count(*)||' ('||cast(round(count(*)*100/total) as int)||'%)' from aag1_client where status_profile=2)||
          (select '    Discharged: '||count(*)||' ('||cast(round(count(*)*100/total) as int)||'%)' from aag1_client where status_profile=3)||
          (select '    Blank: '||count(*) from aag1_client where status_profile not in(1,2,3))
from aag1_dates
join (select cast(count(*) as real) as total from aag1_client where status_profile in(1,2,3));
--
-- Age Range:   37 – 106 y/o
select '   Age Range:   '||min(cast(age as int))||' - '||max(cast(age as int))||' y/o' from aag1_client;
--
-- Half of the Clients are older than (median age):   83 y/o
select '   Half of Clients are older than (median age): '||cast(avg(age) as int)
  from (select age
          from aag1_client
         order by age
         limit 2 - (select count(*) from aag1_client) % 2    -- odd 1, even 2
         offset (select (count(*) - 1) / 2 from aag1_client) );


-- Gender:    male    41%      female      59%
select (select '   Gender: male  '||cast(round(count(*)*100/total) as int)||'%' from aag1_client where gender=1)||
(select '    female: '||cast(round(count(*)*100/total) as int)||'%' from aag1_client where gender=2)||
(select '    Blank: '||count(*) from aag1_client where gender not in(1,2))
from (select cast(count(*) as real) as total from aag1_client where gender in(1,2));

-- Ethnicity/Cultural Identity:    unk.
select '   Ethnicity/Cultural Identity:    unk.';
-- Lives Alone:     unk.
select '   Live Alone:  unk.';

select '';
select 'Program Services';
-- Nursing hours worked per week (avg.):   #
select '   Nursing hours worked per week (avg.):   #';
-- Total number of initial contacts/assessments:    19
select '   Total number of initial contacts/assessments:  '||count(*)
  from aag1_encounter as e
 where e.initial = 1;
-- Total number of follow-up contacts:	    317
select '   Total number of follow-up contacts:	  '||count(*)
  from aag1_encounter e
 where e.initial = 0;
-- Total number of client contacts:     336
select '   Total number of client contacts:  '||count(*)
  from aag1_encounter e;

-- Avg. number of client contacts per week (38 wks.):	8.8
select '   Avg. number of client contacts per week ('||
          cast(round(w.weeks) as int)||' wks.):	'||
          round(count(*)/w.weeks,1)
  from aag1_encounter
  join aag1_dates as w;


-- Home visits:	218  (65% of all client contacts/visits)
select '   Home visits: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=1 then 1 else 0 end) as portion
          from aag1_encounter);

-- Phone calls/emails with clients/families/providers:	68  (20% of all client contacts/visits)
select '   Phone calls/emails with clients/families/providers: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=2 or type=3 then 1 else 0 end) as portion
          from aag1_encounter);

-- Office visits:	0 (0% of all client contacts/visits)
select '   Office visits: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=5 then 1 else 0 end) as portion
          from aag1_encounter);

-- Hosp./Rehab/ECF visits:   38  (11% of all client contacts/visits)
select '   Hosp./Rehab/ECF visits: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=6 or type=7 then 1 else 0 end) as portion
          from aag1_encounter);

-- Family meetings:	     6  (2% of all client contacts/visits)
select '   Family meetings: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=4 or type=8 then 1 else 0 end) as portion
          from aag1_encounter);

-- Other:      7  (2% of all client contacts/visits)
select '   Other: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=9 or type=10 then 1 else 0 end) as portion
          from aag1_encounter);

select '';
select 'Client Referrals (referred by…)';
-- Primary Care Provider:  33%
select '   Primary Care Provider: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___4 = 1 then 1 else 0 end) as portion
          from aag1_client);
-- Family:   26%
select '   Family: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___2 = 1 then 1 else 0 end) as portion
          from aag1_client);
-- Self:   13%
select '   Self: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___1 = 1 then 1 else 0 end) as portion
          from aag1_client);
-- Neighbor/Friend:   13%
select '   Neighbor/Friend: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___3 = 1 then 1 else 0 end) as portion
          from aag1_client);
-- Fast Squad/Ambulance Service:   5%
select '   Fast Squad/Ambulance Service: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___8 = 1 then 1 else 0 end) as portion
          from aag1_client);
-- Community Agency:  0%
select '   Community Agency: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___5 = 1 then 1 else 0 end) as portion
          from aag1_client);
-- Clergy:   0%
select '   Clergy: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___6 = 1 then 1 else 0 end) as portion
          from aag1_client);
-- Hosp./SNF Discharge Coord.:   0%
select '   Hosp./SNF Discharge Coord.: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___7 = 1 then 1 else 0 end) as portion
          from aag1_client);
-- Other:   18%
select '   Other: '||
          cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when referred_by___9 = 1 then 1 else 0 end) as portion
          from aag1_client);
select '   Missing: '||
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
          from aag1_client );

select '';
select 'Other Client Profile Information';
-- Has a Living Will/DPOAH Doc:   81%
select '   Has a Living Will/DPOAH Doc:   '||cast(round(portion*100./total) as int)||'%  ('||
          portion||')'
  from (select count(*) as total
             , sum(case when end_life_plan___2 = 1 then 1 else 0 end) as portion
          from aag1_client);
select '   No end of life plan entered:   '||cast(round(portion*100./total) as int)||'%   ('||
          portion||')'
  from (select count(*) as total
             , sum(case when no_end_life_plan = 1 then 1 else 0 end) as portion
          from aag1_client);
-- Anxious/Fearful about health and well-being?:   Often: 29%      Sometimes: 68%
select '   Anxious/Fearful about health and well-being?:'||
         (select '   Often: '|| cast(round(count(*)*100/total) as int)||'%' from aag1_client where client_anx_before=1)||
         (select '    Sometimes: '|| cast(round(count(*)*100/total) as int)||'%' from aag1_client where client_anx_before=2)||
         (select '    Not often: '|| cast(round(count(*)*100/total) as int)||'%' from aag1_client where client_anx_before=3)||
         (select '    No data: '|| cast(round(count(*)*100/total) as int)||'%  ('||count(*)||')' from aag1_client where client_anx_before='')
  from (select cast(count(*) as real) as total from aag1_client);
-- Client has a caregiver(s)?:   Yes:  33%     No:  67%
select '   Client has a caregiver(s)?:'||
          (select '   Yes:  '||cast(round(count(*)*100/total) as int)||'%' from aag1_client where care_giver=1)||
          (select '   No:  '||cast(round(count(*)*100/total) as int)||'%' from aag1_client where care_giver=0)||
          (select '   No data:  '||cast(round(count(*)*100/total) as int)||'% ('||count(*)||')' from aag1_client where care_giver='')
  from (select cast(count(*) as real) as total from aag1_client);

select '';
select 'Affiliation of Primary Care Provider';
-- DHMC:   87%
select '   DHMC:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 1 then 1 else 0 end) as portion
          from aag1_client);
-- APD:   3%
select '   APD:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 2 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   Mt. Ascutney Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 3 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   Gifford Medical Center:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 4 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   Valley Regional Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 5 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   Cottage Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 6 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   New London Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 7 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
-- Private/Community-based Practice:   3%
select '   Private/Community-based Practice:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 8 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
-- VAH:   7%
select '   VA:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 9 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   Other:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = 10 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   No data:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when provider1_affiliation = '' then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;

select '';
select 'Hospital Most Often Used';
-- DHMC:   97%
select '   DHMC:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 1 then 1 else 0 end) as portion
          from aag1_client);
-- APD:   3%
select '   APD:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 2 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   Mt. Ascutney Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 3 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   Gifford Medical Center:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 4 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   Valley Regional Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 5 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   Cottage Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 6 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   New London Hospital:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 7 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   Other:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = 8 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;
select '   No data:  '||cast(round(portion*100./total) as int)||'%'
  from (select count(*) as total
             , sum(case when hospital_used = '' then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;

select '';
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
select '    '||rank||'. '||label||'  '||percentage||'%'
  from aag1_problem_percent
order by rank;


select '';
select 'Top Nurse interventions:   (% of client visits in which nursing interventions were performed and documented.)';
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
-- We could use a view for this instead of a temporary table, but this seems a little easier to understand
-- and probably performs better.
drop table if exists aag1_temp1;
create table aag1_temp1 as
select (100+rank)||'00000' sort_key
     , rank||'. '||label||'  '||percentage||'%' as text
  from aag1_intervene5;

insert into aag1_temp1
select (100+rank)||'01'||100+i
     , '    '||sub2.label||'('||sub2.percentage||'%)'
  from aag1_intervene_sub2 sub2
  join aag1_intervene5
 using (name);
select text from aag1_temp1 order by cast(sort_key as text);

select '';
select 'Nurse-Reported Functional Health Assessment - Reported at every interval visit';
--     •	Physical Condition:  Declined:  15%    Unchanged:  73%    Improved:  12%
--     •	Emotional Status:    Declined:  18%    Unchanged:  70%    Improved:  12%
--     •	Cognitive Status:      Declined:  4%      Unchanged:  96%    Improved:  0.4%
--     •	Had a Fall Since Last Visit?:        Yes:  7%    No:  93%
--     •	Hospitalized Since Last Visit?:    Yes:  7%    No:  93%
select '  *  Physical Condition:'||
          (select '  Declined: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where phys_cond_nursescale=1)||
          (select '  Unchanged: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where phys_cond_nursescale=2)||
          (select '  Improved: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where phys_cond_nursescale=3)||
          (select '  Blank: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where phys_cond_nursescale not in(1,2,3))
  from (select count(*) as total from aag1_encounter1);

select '  *  Emotional Status:'||
          (select '  Declined: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where emot_stat_nursescale=1)||
          (select '  Unchanged: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where emot_stat_nursescale=2)||
          (select '  Improved: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where emot_stat_nursescale=3)||
          (select '  Blank: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where emot_stat_nursescale not in(1,2,3))
  from (select count(*) as total from aag1_encounter1);          

select '  *  Cognitive Status:'||
          (select '  Declined: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where cog_stat_nursescale=1)||
          (select '  Unchanged: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where cog_stat_nursescale=2)||
          (select '  Improved: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where cog_stat_nursescale=3)||
          (select '  Blank: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where cog_stat_nursescale not in(1,2,3))
  from (select count(*) as total from aag1_encounter1);          

select '  *  Had a Fall Since Last Visit?:'||
          (select '  Yes: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where fall_sincelast=1)||
          (select '  No: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where fall_sincelast=0)||
          (select '  Blank: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where fall_sincelast not in(0,1))
  from (select count(*) as total from aag1_encounter1);          

select '  *  Hospitalized Since Last Visit?:'||
          (select '  Yes: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where hospit_since_last=1)||
          (select '  No: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where hospit_since_last=0)||
          (select '  Blank: '||cast(round(count(*)*100./total) as int)||'%' from aag1_encounter1 where hospit_since_last not in(0,1))
  from (select count(*) as total from aag1_encounter1);          


select '';
-- Reason for Discharge  (R=7)
select 'Reason for Discharge  (R='||count(*)||')'
  from aag1_discharge;
--     •	Moved away from service area     43%
--     •	Death	     29%
--     •	Services no longer needed	29%
--     •	Services not wanted	0%
select '   '||rank||'.  '||label||'  '||percentage||'%'
  from aag1_discharge_reason
 order by rank; 


select '';
-- Nurse-Reported Outcomes - Reported at 6-months or Discharge: (% of clients who were discharged or had a 6-month assessment and were documented. R=7)
select 'Nurse-Reported Outcomes - Reported at 6-months or Discharge:'||
         ' (% of clients who were discharged or had a 6-month assessment and were documented. R='||count(*)
  from aag1_discharge;
--     •	Helped client and/or family to be less anxious about dealing with their situation     71%
--     •	Enabled client to continue living in home for at least 6 months	14%
--     •	Helped improve client’s management of illness symptoms	     0%
--     •	Improved client’s functioning in daily life	0%
--     •	Prevented medication-related, adverse outcomes or ineffective therapeutic effect	0%
--     •	Prevented Emergency Call, ED Visit, or Re-hospitalization	0%
--     •	Other	29%
select '  '||rank||'.  '||label||'  '||percentage||'%'
  from aag1_outcome
 order by rank;
select '';
select '✯ ✯ ✯';

select '';
select 'Clarifications:';
select '     •	The Client Problems, Nurse Interventions, and Nurse-Reported Outcomes in this report are based on';
select '        information entered into the Upper Valley Community Nurse Project’s Electronic Documentation';
select '        System used by your community/parish nurse. Importantly, Client Problems do not represent the';
select '        prevalence of these conditions in the larger community; rather, they profile the clients served by';
select '        your community or parish nurse.';
select '';
select '     •	The data reported here is based upon UVCNP Electronic Documentation Project input from';
select '        '||first_month||' '||first_day||', '||first_year||' - ' ||last_month||' '||last_day||', '||last_year||
        ' ('||cast(round(weeks) as int)||' weeks).  Utilization of the system to document client care (40-60% of '
  from aag1_dates;      
select '        clients for most forms) affects the data analysis and reported findings cannot be generalized to the';
select '        nurse’s entire client list.  We expect the relevance and accuracy of the data to improve over time as';
select '        the nurses gain experience and efficiency in using the documentation system and utilization of the ';
select '        EDS increases.';
select '';
select '     •	Every client does not necessarily need or receive a comprehensive assessment. Problems,';
select '        Interventions and Nurse-reported Outcomes are not done or documented for every client. Therefore,';
select '        these reported findings represent the percentage of clients for whom Problems, Interventions and';
select '        Outcomes were assessed and documented, not the percentage of ALL clients. Like the other findings,';
select '        this data cannot be generalized to ALL clients enrolled in your Community or Parish Nurse program.';
select '';
select '✯ ✯ ✯ ✯';
-- Go back to list mode, because it is more convenient for routine queries/debugging etc.
.mode list