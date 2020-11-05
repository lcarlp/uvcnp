-- This only imported Lives Alone values.
.read v3_port_household_comp_views.sql
.headers on
.mode csv
.once v3_port/household_comp_other.csv
select * from household_comp_other;
