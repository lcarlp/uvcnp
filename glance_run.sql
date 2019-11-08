-- Adjust the settings in this file and then execute it in sqlite3
-- using .read glance_run.sql
drop table if exists aag_date_range;
create table aag_date_range(first date,last date);
--- Adjust starting and ending dates in the following line:
insert into aag_date_range values('2018-10-15','2019-10-14');
drop table if exists aag_town;
--- Adjust name of town in the following line:
create table aag_town as select 'Lebanon' town;
.mode csv
--- Adjust name of export file in the following line:
.import UVCNPDocumentationPr_DATA_2019-11-01_0530.csv redcap_export
--- Adjust name of output file in the following line:
.output Lebanon_AAG3.txt
.read glance.sql
.output
.exit
