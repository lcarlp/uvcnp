-- SQL Script to generate the "At A Glance" (AAG) report.
-- Table   from redcap_export is assumed to have been imported from a CSV export of the REDCap database.
-- Table aag_town is manually populated to contain a list of towns included in the report.
-- Table aag_date_range is manually populated to contain an inclusive range of dates for the report.

.read glance_views.sql

-- See comments after .mode & .width
.headers off
.mode column
.width 180
-- .mode colum seems to be the only thing that really works
-- unfortunately, .width 180 seems to pad to 180.
-- Based on the SQLite3 documentation, .width 0 should work, but it
-- seems to mess up some queries.  Why?

select '';
select '----------------------------------------------------------------------';
select '';
select '                    AT A GLANCE';
select '';
select 'Upper Valley Community Nursing Project';
select town||' Community Nurse'
  from aag_town
 where 1 = (select count(*) from aag_town);
select 'Community Nurses for '||group_concat(town,', ')
  from aag_town
 where 1 < (select count(*) from aag_town);
select first_day||' '||first_month||' '||first_year||' - ' ||
         last_day||' '||last_month||' '||last_year 
  from aag1_dates;

select '';
select '';
select 'Client Demographics & Social Context';
-- Half of the Clients are older than (median age):   83 y/o
select '   Half of Clients are older than (median age): '||cast(avg(age) as int)
  from (select age
          from aag1_client_age
         order by age
         limit 2 - (select count(*) from aag1_client_age) % 2    -- odd 1, even 2
         offset (select (count(*) - 1) / 2 from aag1_client_age) );
select 'WARNING:  MANY LOW AGES IGNORED.  ONLY CONSIDERED '||
       age_count||' OUT OF '||all_clients||'.'
  from (select count(*) as all_clients from aag1_client)
  join (select count(*) as age_count from aag1_client_age)
 where (100.*age_count/all_clients) < 90
-- Generate a warning if nore than 10% of clients are excluded.
;
select 'REMOVE EXTRA???   Lives Alone:'||
          (select '    Yes: '||count(*)||' ('||cast(round(count(*)*100./total) as int)||'%)' from aag1_social_context where address_v2=1)||
          (select '    No: '||count(*)||' ('||cast(round(count(*)*100./total) as int)||'%)' from aag1_social_context where cast(address_v2 as int) in(2,3,4,5))||
          '    Not recorded: '||no_social||' ('||cast(round(no_social*100./total) as int)||'%)' 
  from (select cast(count(*) as real) as total from aag1_client)
  join (select cast(count(*) as real) as total_social from aag1_social_context
         where cast(address_v2 as int) in(1,2,3,4,5))
  join (select count(*) as no_social 
          from (select record_id from aag1_client 
                except 
                select record_id from aag1_social_context 
                 where cast(address_v2 as int) in(1,2,3,4,5)));
select '   Financially stressed: '||percentage||'%' from aag1_problem_percent1 where label='Financial struggles';

select '';
select '';
select 'Program Services';
select '   Clients served, total: '||count(*)||
        '   (New: '||sum(case when date_1st_contact >= d.first then 1 end)||
        '    Carried over: '||sum(case when date_1st_contact >= d.first then 0 else 1 end)||')'
  from aag1_client
  join aag_date_range as d;
select '';
select '      As of '||last_month||' '||last_day||', '||last_year||'    '||
          (select 'Active: '||count(*)||' ('||cast(round(count(*)*100./total) as int)||'%)' from aag1_client where status_profile=1)||
          (select '    Inactive: '||count(*)||' ('||cast(round(count(*)*100./total) as int)||'%)' from aag1_client where status_profile=2)||
          (select '    Discharged: '||count(*)||' ('||cast(round(count(*)*100./total) as int)||'%)' from aag1_client where status_profile=3)||
          (select '    Not recorded: '||count(*) from aag1_client where status_profile not in(1,2,3))
from aag1_dates
join (select cast(count(*) as real) as total from aag1_client where status_profile in(1,2,3));
select '';
select '   Total number of client contacts:  '||count(*)
  from aag1_encounter;
select '   Avg. number of client contacts per week ('||
          cast(round(w.weeks) as int)||' wks.):	'||
          round(count(*)/w.weeks,1)
  from aag1_encounter
  join aag1_dates as w;
select '   Avg. number of contacts per client during period: '||mean||
        '      Range: '||low||' - '||high
  from (select round(cast(count(*) as real)/count(distinct record_id)) as mean
          from aag1_encounter),
      (select min(c) as low, max(c) as high
          from (select record_id, count(*) as c 
                  from aag1_encounter 
                group by record_id));

select '   Home visits: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=1 then 1 else 0 end) as portion
          from aag1_encounter);

select '   Phone calls/emails with clients/families/providers: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=2 or type=3 then 1 else 0 end) as portion
          from aag1_encounter);

select '   Office visits: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=5 then 1 else 0 end) as portion
          from aag1_encounter);

select '   Hosp./Rehab/ECF visits: '||portion||'  ('||
          cast(round(portion*100./total) as int)||
          '% of all client encounters)'
  from (select count(*) as total
             , sum(case when type=6 or type=7 then 1 else 0 end) as portion
          from aag1_encounter);

select '';
select 'Client Referrals (referred by…)';
-- Primary Care Provider:  33%
select '   Primary Care Provider: '||
          cast(round(portion*100./total) as int)||'%'
  from (select sum(referred_by_any) as total
             , sum(case when referred_by___4 = 1 then 1 else 0 end) as portion
          from aag1_client)
 where portion >0;
-- Family:   26%
select '   Family: '||
          cast(round(portion*100./total) as int)||'%'
  from (select sum(referred_by_any) as total
             , sum(case when referred_by___2 = 1 then 1 else 0 end) as portion
          from aag1_client)
 where portion >0;
-- Self:   13%
select '   Self: '||
          cast(round(portion*100./total) as int)||'%'
  from (select sum(referred_by_any) as total
             , sum(case when referred_by___1 = 1 then 1 else 0 end) as portion
          from aag1_client)
 where portion >0;
-- Neighbor/Friend:   13%
select '   Neighbor/Friend: '||
          cast(round(portion*100./total) as int)||'%'
  from (select sum(referred_by_any) as total
             , sum(case when referred_by___3 = 1 then 1 else 0 end) as portion
          from aag1_client)
 where portion >0;
-- Fast Squad/Ambulance Service:   5%
select '   Fast Squad/Ambulance Service: '||
          cast(round(portion*100./total) as int)||'%'
  from (select sum(referred_by_any) as total
             , sum(case when referred_by___8 = 1 then 1 else 0 end) as portion
          from aag1_client)
 where portion >0;
-- Community Agency:  0%
select '   Community Agency: '||
          cast(round(portion*100./total) as int)||'%'
  from (select sum(referred_by_any) as total
             , sum(case when referred_by___5 = 1 then 1 else 0 end) as portion
          from aag1_client)
 where portion >0;
-- Clergy:   0%
select '   Clergy: '||
          cast(round(portion*100./total) as int)||'%'
  from (select sum(referred_by_any) as total
             , sum(case when referred_by___6 = 1 then 1 else 0 end) as portion
          from aag1_client)
 where portion >0;
-- Hosp./SNF Discharge Coord.:   0%
select '   Hosp./SNF Discharge Coord.: '||
          cast(round(portion*100./total) as int)||'%'
  from (select sum(referred_by_any) as total
             , sum(case when referred_by___7 = 1 then 1 else 0 end) as portion
          from aag1_client)
 where portion >0;
-- Other:   18%
select '   Other: '||
          cast(round(portion*100./total) as int)||'%'
  from (select sum(referred_by_any) as total
             , sum(case when referred_by___9 = 1 then 1 else 0 end) as portion
          from aag1_client)
 where portion >0 and 1=2;
select '   Not recorded: '||
          cast(round(portion*100./total) as int)||'%  ('||portion||')'
  from (select count(*) as total
             , sum(1-referred_by_any) as portion
          from aag1_client )
 where portion >0 and 1=2;

select '';
select 'Affiliation of Primary Care Provider';
-- DHMC:   87%
select '   DHMC:  '||cast(round(portion*100./total) as int)||'%'
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 1 then 1 else 0 end) as portion
          from aag1_client);
-- APD:   3%
select '   APD:  '||cast(round(portion*100./total) as int)||'%'
  from (select sum(provider1_affiliation_any) as total
             , sum(case when provider1_affiliation = 2 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;

select '';
select 'Hospital Most Often Used';
-- DHMC:   97%
select '   DHMC:  '||cast(round(portion*100./total) as int)||'%'
  from (select sum(hospital_used_any) as total
             , sum(case when hospital_used = 1 then 1 else 0 end) as portion
          from aag1_client);
-- APD:   3%
select '   APD:  '||cast(round(portion*100./total) as int)||'%'
  from (select sum(hospital_used_any) as total
             , sum(case when hospital_used = 2 then 1 else 0 end) as portion
          from aag1_client)
 where portion > 0;

select '';
select 'Top 10 Client Problems: (% of clients for whom problems were identified and documented. R='||
          portion||'  ('||cast(round(portion*100./total) as int)||'%))'
  from (select count(*) as total
             , sum(case when problems > 0 then 1 else 0 end) as portion
          from aag1_problem);
select '    '||rank||'. '||label||'  '||percentage||'%'
  from aag1_problem_percent
 where rank <= 10
 order by rank;
 
select '';
select '   Avg. number of problems per client: '||
            round(avg(problems),1)||
            '      Range: '||min(problems)||' - '||max(problems)
  from aag1_problem;

select '';
select 'Top 5 Nurse interventions:   (% of client visits in which nursing interventions were performed and documented.)';
select '   '||rank||'. '||label||'  '||percentage||'%' as text
  from aag1_intervene5
 where rank <= 5
 order by rank;
select '';
select '   Avg. number of intervention categories per client: '||
            round(avg(interv_sum),1)||
            '      Range: '||min(interv_sum)||' - '||max(interv_sum)
  from aag1_intervene_all;

select '';
select 'Top 5 Nurse-Reported Outcomes - Reported at 6-months or Discharge:'||
         ' (% of clients who were discharged or had a 6-month assessment and were documented. R='||count(*)||')'
  from aag1_outcome1;
select '  '||rank||'.  '||label||'  '||percentage||'%'
  from aag1_outcome
 where rank <= 5
 order by rank;

select '';
select 'Reason for Discharge  (R='||count(*)||')'
  from aag1_discharge;
select '   '||rank||'.  '||label||'  '||percentage||'%'
  from aag1_discharge_reason
 order by rank; 

select '';
select '✯ ✯ ✯';

select '';
select 'Clarifications:';
select '     •	More detailed information available on request.';
select '';
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
select '        we revise the forms to be more nurse-usable and utilization of the EDS increases.';
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