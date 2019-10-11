drop view if exists aag1;
create view aag1 as
select * from all1
join aag_town using (redcap_data_access_group);

drop view if exists aag1_profile;
create view aag1_profile as
select status_profile
     , cast(age as real) as age
     , gender
  from aag1
where redcap_repeat_instrument = '';

.mode column
-- Upper Valley Community Nursing Project
-- Hanover Community Nurse
-- 15 October 2018 – 11 July 2019
-- At A Glance


-- Town Population:  11,428						(Gov. census estimates 2017)
-- # Residents age 65-74:  588 (5%)		# residents 75 or over:	837 (7%)


-- Community/Parish Nurse Program details
-- Program Founded:  2018
-- Annual Budget:  $
-- Funding (town appropriation or other):  $
-- Organizational Structure:
-- Contact information:  ###-###-####
-- Website (url):


-- Client Demographics & Social Context
-- Clients served, total:	 39
select 'Clients served, total: '||count(*)
  from aag1_profile;

--     As of July 11, 2019:      Active:  21 (54%)    Inactive:  10 (26%)     Discharged:  8 (20%)
select (select 'Active: '||count(*)||' ('||cast(round(count(*)*100/total) as int)||'%)' from aag1_profile where status_profile=1)||
        (select '    Inactive: '||count(*)||' ('||cast(round(count(*)*100/total) as int)||'%)' from aag1_profile where status_profile=2)||
        (select '    Discharged: '||count(*)||' ('||cast(round(count(*)*100/total) as int)||'%)' from aag1_profile where status_profile=3)||
        (select '    Blank: '||count(*) from aag1_profile where status_profile not in(1,2,3))
from (select cast(count(*) as real) as total from aag1_profile where status_profile in(1,2,3));

-- Age Range:   37 – 106 y/o
select 'Age Range:   '||min(cast(age as int))||' - '||max(cast(age as int))||' y/o' from aag1_profile;

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
-- Lives Alone:     unk.

-- Program Services
-- Nursing hours worked per week (avg.):   #
-- Total number of initial contacts/assessments:    19
-- Total number of follow-up contacts:	    317
-- Total number of client contacts:     336
-- Avg. number of client contacts per week (38 wks.):	8.8
-- Home visits:	218  (65% of all client contacts/visits)
-- Phone calls/emails with clients/families/providers:	68  (20% of all client contacts/visits)
-- Office visits:	0 (0% of all client contacts/visits)
-- Hosp./Rehab/ECF visits:   38  (11% of all client contacts/visits)
-- Family meetings:	     6  (2% of all client contacts/visits)
-- Other:      7  (2% of all client contacts/visits)

-- Client Referrals (referred by…)
-- Primary Care Provider:  33%
-- Family:   26%
-- Client Referrals, (cont.)
-- Self:   13%
-- Neighbor/Friend:   13%
-- Fast Squad/Ambulance Service:   5%
-- Community Agency:  0%
-- Clergy:   0%
-- Hosp./SNF Discharge Coord.:   0%
-- Other:   18%

-- Other Client Profile Information
-- Has a Living Will/DPOAH Doc:   81%
-- Anxious/Fearful about health and well-being?:   Often: 29%      Sometimes: 68%
-- Client has a caregiver(s)?:   Yes:  33%     No:  67%

-- Affiliation of Primary Care Provider
-- DHMC:   87%
-- APD:   3%
-- Private/Community-based Practice:   3%
-- VAH:   7%

-- Hospital Most Often Used
-- DHMC:   97%
-- APD:   3%

-- Top Client Problems: (% of clients for whom problems were identified and documented. R=23 (59%))
--     •	Impaired Mobility 	65%
--     •	High Fall Risk	57%
--     •	Social Isolation	57%
--     •	Frailty	39%
--     •	Problems w/ self-care		35%
--     •	Impaired Cognitive Function	35%
--     •	Mental Health or Substance Abuse Issue		35%
-- Other problems:  Difficulty living at home (26%); Lack of transportation (26%); Ineffective enactment of therapeutic recommendations (17%); Not taking medications correctly (17%); Financial struggles (13%); Anticipating stressful transition to another level of care (13%); Frequent ED Visits/EMS Calls (9%); Poor nutrition (9%); Problems with bills, insurance, etc. (9%); Incomplete end-of-life planning (9%); Symptoms not well controlled (4%); Deficient housing (4%)

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

