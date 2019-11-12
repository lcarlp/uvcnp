-- Adjust the settings in this file and then execute it in sqlite3
-- using .read glance_run.sql
drop table if exists aag_date_range;
create table aag_date_range(first date,last date);
--- Adjust starting and ending dates in the following line:
insert into aag_date_range values('2018-10-15','2019-10-14');

.mode csv
drop table if exists redcap_export;
--- Adjust name of export file in the following line:
.import UVCNPDocumentationPr_DATA_2019-11-01_0530.csv redcap_export
--- .import UVCNPDocumentationPr_DATA_2019-11-09_1217.csv redcap_export


--- Run for all towns that use REDCap
drop table if exists aag_town;
create table aag_town as 
select 'Hanover' town union
select 'Hartland' town union
select 'Lebanon' town union
select 'Lyme' town union
select 'Sharon' town union
select 'Thetford';

.output AAG_All.txt
.read glance.sql
.output

-- Now run each town individually.

drop table if exists aag_town;
create table aag_town as select 'Hanover' town;
.output AAG_Hanover.txt
.read glance.sql
.output

drop table if exists aag_town;
create table aag_town as select 'Hartland' town;
.output AAG_Hartland.txt
.read glance.sql
.output

drop table if exists aag_town;
create table aag_town as select 'Lebanon' town;
.output AAG_Lebanon.txt
.read glance.sql
.output

drop table if exists aag_town;
create table aag_town as select 'Lyme' town;
.output AAG_Lyme.txt
.read glance.sql
.output

drop table if exists aag_town;
create table aag_town as select 'Sharon' town;
.output AAG_Sharon.txt
.read glance.sql
.output

drop table if exists aag_town;
create table aag_town as select 'Thetford' town;
.output AAG_Thetford.txt
.read glance.sql
.output




.exit
