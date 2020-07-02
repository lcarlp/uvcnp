.read v3_port_views.sql
.headers on
.mode csv
.once v3_port/v3_encounters.csv
select * from v3_encounters;
.once v3_port/v3_status_update.csv
select * from v3_status_update;
.once v3_port/v3_problem_list_clear.csv
select * from v3_problem_list_clear;
.once v3_port/v3_problem_list.csv
select * from v3_problem_list;
.once v3_port/v3_primary_referrer.csv
select * from v3_primary_referrer;
