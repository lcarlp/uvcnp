-- When we went to produce AAGs in early November 2020, we
-- realized that we should have ported the "Lives Alone" data
-- from V2 to V3 for existing clients.
-- The household_comp field was changed too much to be able to
-- map all values, but "Lives Alone" can be ported where we have
-- it in V2, but not in V3.
-- This is made more difficult by the fact that the V2 field was
-- in a repeating form, apparently in an attempt to track changes.
-- It is important to make sure redcap_export has a recent export
-- from REDCap.

drop view if exists household_comp_v2;
create view household_comp_v2 as
select record_id
     , redcap_data_access_group
     , address_v2 household_comp
     , notes_52 household_comp_notes
  from redcap_export sc
 where sc.redcap_repeat_instrument = 'social_context_v2'
   and sc.date_sc||sc.redcap_repeat_instance =
        ( select max(sc2.date_sc||sc2.redcap_repeat_instance)
            from redcap_export sc2 
           where sc2.record_id = sc.record_id
             and sc2.redcap_repeat_instrument = 'social_context_v2'
             and sc2.date_sc > '' );

drop view if exists household_comp_v3;
create view household_comp_v3 as
select record_id
     , redcap_data_access_group
     , household_comp
  from redcap_export
 where redcap_repeat_instrument = '';

drop view if exists household_comp_port;
create view household_comp_port as
select v3.record_id
     , v3.redcap_data_access_group
     , v2.household_comp household_comp
  from household_comp_v3 v3
  join household_comp_v2 v2
    on v2.record_id = v3.record_id
 where v3.household_comp = '' --Missing in V3
   and v2.household_comp = 1 --Lives alone in V2.
 order by 1
;   

drop view if exists household_comp_v2_decode;
create view household_comp_v2_decode as
select 1 address_v2, 'One person living alone' label union
select 2 address_v2, 'Two persons in the same home' label union
select 3 address_v2, 'One or two persons living with family member' label union
select 4 address_v2, 'Independent/Assisted/Extended Care living, nursing home' label union
select 5 address_v2, 'Other' label;

drop view if exists household_comp_other;
create view household_comp_other as
select v3.record_id
     , v3.redcap_data_access_group
     , 5 household_comp --Other
     , rtrim('V2: '||d.label||': '||v2.household_comp_notes,': ') household_comp_notes
  from household_comp_v3 v3
  join household_comp_v2 v2
    on v2.record_id = v3.record_id
  join household_comp_v2_decode d
    on d.address_v2 = v2.household_comp
 where v3.household_comp = '' --Missing in V3
   and v2.household_comp > 1 --Something other than lives alone.
 order by 1
;   

