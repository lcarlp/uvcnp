drop view if exists v3_encounters;
create view v3_encounters as
select record_id
     , 'encounters' redcap_repeat_instrument
     , 1 redcap_repeat_instance
     , redcap_data_access_group
     , date_1st_contact encounter_date
     , case meth_1st_contact when 1 then 1 else 0 end encounter_type___1 --Home visit
     , case meth_1st_contact when 2 then 1 else 0 end encounter_type___2 --Phone
     , case meth_1st_contact when 3 then 1 else 0 end encounter_type___3 --Email
     , case meth_1st_contact when 5 then 1 else 0 end encounter_type___5 --Office hours
     , 0 encounter_type___11 --Phone, family
     , 0 encounter_type___12 --Email, family
     , case meth_1st_contact when 4 then 1 else 0 end encounter_type___4 --Family meeting
     , 0 encounter_type___13 --Family in office
     , case meth_1st_contact when 6 then 1 else 0 end encounter_type___6 --In-patient meeting.
     , case meth_1st_contact when 7 then 1 when 8 then 1 when 9 then 1 when 10 then 1 else 0 end encounter_type___10
     , notes encounter_type_note
     , 0 limited_concern___1
     , '' limited_concern_notes
     , '' encounter_nurse
     , '[record #1 imported from V2]' encounter_progress_notes
     , '' encounter_stat_phys
     , '' encounter_stat_emot
     , '' encounter_stat_cog
     , 0 encounter_stat_note_flag___1
     , '' encounter_stat_note
     , 0 encounter_intervention___1
     , 0 encounter_intervention___2
     , 0 encounter_intervention___3
     , 0 encounter_intervention___4
     , 0 encounter_intervention___5
     , 0 encounter_intervention___6
     , 0 encounter_intervention___7
     , 0 encounter_intervention___8
     , 0 encounter_intervention___9
     , 0 encounter_intervention___10
     , '' encounter_intervene_notes
     , '[record #1 imported from V2]' encounter_todo_notes
     , datetime('now','localtime') encounter_created_on
     , 2 encounters_complete --2 means record completed.
  from redcap_export a
 where redcap_repeat_instrument = ''
   and ( date_1st_contact != '' or 
   exists(select null 
            from redcap_export 
           where redcap_repeat_instrument = 'interval_contacts'
             and record_id = a.record_id) )
union all
select record_id
     , 'encounters' redcap_repeat_instrument
     , redcap_repeat_instance+1 redcap_repeat_instance
     , redcap_data_access_group
     , today_date_v2 encounter_date
     , cont_meth_v2___1 encounter_type___1 --Home visit
     , cont_meth_v2___2 encounter_type___2 --Phone
     , cont_meth_v2___3 encounter_type___3 --Email
     , cont_meth_v2___5 encounter_type___5 --Office hours
     , 0 encounter_type___11 --Phone, family
     , 0 encounter_type___12 --Email, family
     , case meth_1st_contact when 4 then 1 else 0 end encounter_type___4 --Family meeting
     , 0 encounter_type___13 --Family in office
     , cont_meth_v2___6 encounter_type___6 --In-patient meeting.
     , case when 1 in(cont_meth_v2___7,cont_meth_v2___8,cont_meth_v2___9,cont_meth_v2___10) then 1 else 0 end encounter_type___10
     , notes_57 encounter_type_note
     , 0 limited_concern___1
     , '' limited_concern_notes
     , '' encounter_nurse
     , '[record #'||redcap_repeat_instance+1||' imported from V2]' encounter_progress_notes
     , phys_cond_nursescale encounter_stat_phys
     , emot_stat_nursescale encounter_stat_emot
     , cog_stat_nursescale encounter_stat_cog
     , case when length(notes_48)>0 then 1 else 0 end encounter_stat_note_flag___1
     , notes_48 encounter_stat_note
     , 0 encounter_intervention___1
     , 0 encounter_intervention___2
     , 0 encounter_intervention___3
     , 0 encounter_intervention___4
     , 0 encounter_intervention___5
     , 0 encounter_intervention___6
     , 0 encounter_intervention___7
     , 0 encounter_intervention___8
     , 0 encounter_intervention___9
     , 0 encounter_intervention___10
     , '' encounter_intervene_notes
     , '[record #1 imported from V2]' encounter_todo_notes
     , datetime('now','localtime') encounter_created_on
     , 2 encounters_complete --2 means record completed.
  from redcap_export
 where redcap_repeat_instrument = 'interval_contacts'
 order by 1,3;
     