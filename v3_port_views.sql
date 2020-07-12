drop view if exists v3_encounters;
create view v3_encounters as
select a.record_id
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
  from redcap_export_v2_v3 a
 where redcap_repeat_instrument = ''
   and ( date_1st_contact != '' or 
   exists(select null 
            from redcap_export_v2_v3 
           where redcap_repeat_instrument like 'interval_contacts%'
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
     , '[record #'||redcap_repeat_instance+1||' imported from V2]' encounter_todo_notes
     , datetime('now','localtime') encounter_created_on
     , 2 encounters_complete --2 means record completed.
  from redcap_export_v2_v3
 where redcap_repeat_instrument like 'interval_contacts%'
 order by 1,3;

drop view if exists v3_status_update;
create view v3_status_update as
select a.record_id
     , 'status_update' redcap_repeat_instrument
     , 1 redcap_repeat_instance
     , a.redcap_data_access_group
     , coalesce(b.date_today_dis,date('now')) client_redcap_status_date
     , '' status_update_nurse
     , 3 client_redcap_status
     , case b.reason_disch when 1 then 1 when 2 then 5 when 3 then 4 when 4 then 3 when 5 then 6 end status_update_reason
     , b.notes_45 status_update_reason_note
     , 0 status_update_outcome___1
     , 0 status_update_outcome___2
     , 0 status_update_outcome___3
     , 0 status_update_outcome___4
     , 0 status_update_outcome___5
     , 0 status_update_outcome___6
     , 0 status_update_outcome___7
     , 0 status_update_outcome___8
     , 0 status_update_outcome___9
     , 0 status_update_outcome___10
     , 0 status_update_outcome___11
     , 0 status_update_outcome___12
     , 0 status_update_outcome___13
     , 0 status_update_outcome___14
     , 0 status_update_outcome___30
     , 0 status_update_outcome___50
     , '[Discharged record #1 imported from V2]' status_update_outcome_note
     , datetime('now','localtime') status_updated_on
     , 2 status_update_complete
  from redcap_export_v2_v3 a
  left join redcap_export_v2_v3 b
    on b.redcap_repeat_instrument like '%discharge%'
   and b.record_id = a.record_id
   and b.redcap_repeat_instance = (
         select max(redcap_repeat_instance) 
           from redcap_export_v2_v3 c
          where c.redcap_repeat_instrument like '%discharge%'
            and c.record_id = a.record_id )
 where a.redcap_repeat_instrument = ''
   and a.status_profile = 3 --Discharged
union all
select record_id
     , 'status_update' redcap_repeat_instrument
     , 1 redcap_repeat_instance
     , redcap_data_access_group
     , date('now') client_redcap_status_date
     , '' status_update_nurse
     , 2 client_redcap_status
     , 6 status_update_reason --Other.
     , '[Deactivated record #1 imported from V2]' status_update_reason_note
     , 0 status_update_outcome___1
     , 0 status_update_outcome___2
     , 0 status_update_outcome___3
     , 0 status_update_outcome___4
     , 0 status_update_outcome___5
     , 0 status_update_outcome___6
     , 0 status_update_outcome___7
     , 0 status_update_outcome___8
     , 0 status_update_outcome___9
     , 0 status_update_outcome___10
     , 0 status_update_outcome___11
     , 0 status_update_outcome___12
     , 0 status_update_outcome___13
     , 0 status_update_outcome___14
     , 0 status_update_outcome___30
     , 0 status_update_outcome___50
     , '[Deactivated record #1 imported from V2]'  status_update_outcome_note
     , datetime('now','localtime') status_updated_on
     , 2 status_update_complete
  from redcap_export_v2_v3
 where redcap_repeat_instrument = ''
   and status_profile = 2 --Inactive
 order by 1,3;

drop view if exists v3_problem_list_clear;
create view v3_problem_list_clear as
select record_id
     , redcap_data_access_group
     , '' problem_type___1 --Mobility
     , '' problem_type___2 --Fall Risk
     , '' problem_type___3 --Social isolation/weak social support
     , '' problem_type___4 --symptom management
     , '' problem_type___5 --Frailty
     , '' problem_type___6 --Self-care deficit
     , '' problem_type___7 --medication management
     , '' problem_type___8 --Mental health
     , '' problem_type___9 --cognitive
     , '' problem_type___10 --nutrition
     , '' problem_type___11 --Financial
     , '' problem_type___12 --Transportation
     , '' problem_type___13 --Struggling to remain at home
     , '' problem_type___14 --caregiver burnout, nothing like this in V2
     , '' problem_type___20 --Other
     , '' problem_other_note --
     , '' problem_allergies
     , '' problem_diagnose
     , '' problem_list_complete
  from redcap_export_v2_v3
 where redcap_repeat_instrument = ''
-- Requires setting "blank values to overwrite existing saved values"
-- during import.
;

drop view if exists v3_problem_list;
create view v3_problem_list as
select record_id
     , redcap_data_access_group
     , max(imp_phys_mob___1,imp_phys_mob___2) problem_type___1 --Mobility
     , max(fall___1,fall___2) problem_type___2 --Fall Risk
     , max(sdoh_iso___1,sdoh_iso___2) problem_type___3 --Social isolation/weak social support
     , max(sympt_manag___1,sympt_manag___2) problem_type___4 --symptom management
     , max(frailty___1,frailty___2) problem_type___5 --Frailty
     , max(self_care_prob_list___1,self_care_prob_list___2) problem_type___6 --Self-care deficit
     , max(incorrect_meds___1,incorrect_meds___2) problem_type___7 --medication management
     , max(ment_heal___1,ment_heal___2) problem_type___8 --Mental health
     , max(impair_cog___1,impair_cog___2) problem_type___9 --cognitive
     , max(nutr_poor___1,nutr_poor___2) problem_type___10 --nutrition
     , max(sdoh_finance___1,sdoh_finance___2) problem_type___11 --Financial
     , max(sdoh_transp___1,sdoh_transp___2) problem_type___12 --Transportation
     , max(stay_home___1,stay_home___2) problem_type___13 --Struggling to remain at home
     , 0 problem_type___14 --caregiver burnout, nothing like this in V2
     , max(ed_visits___1,ed_visits___2,
           ineff_ther___1,ineff_ther___2,
           prob_bills___1,prob_bills___2,
           stress_trans___1,stress_trans___2,
           incom_acp___1,incom_acp___2,
           hous_def___1,hous_def___2,
           other_prob_list___1,other_prob_list___2,
           sdoh_other_2___1,sdoh_other_2___2) problem_type___20 --Other
     , case when max(ed_visits___1,ed_visits___2) then 'Frequent ED visits or EMS calls; ' end ||
         case when max(ineff_ther___1,ineff_ther___2) then 'Ineffective enactment of therapeutic recommendations; ' end ||
         case when max(prob_bills___1,prob_bills___2) then 'Problems with bills, insurance paperwork, enrollments; ' end ||
         case when max(hous_def___1,hous_def___2) then 'Housing; ' end problem_other_note --
     , notes_56 problem_allergies
     , med_diag_list_v2_v2_v2 problem_diagnose
     , 2 problem_list_complete
  from redcap_export_v2_v3
 where redcap_repeat_instrument = ''
   and ( max(ed_visits___1,ed_visits___2,
        incorrect_meds___1,incorrect_meds___2,
        ineff_ther___1,ineff_ther___2,
        sympt_manag___1,sympt_manag___2,
        frailty___1,frailty___2,
        impair_cog___1,impair_cog___2,
        ment_heal___1,ment_heal___2,
        self_care_prob_list___1,self_care_prob_list___2,
        imp_phys_mob___1,imp_phys_mob___2,
        fall___1,fall___2,
        stay_home___1,stay_home___2,
        prob_bills___1,prob_bills___2,
        stress_trans___1,stress_trans___2,
        incom_acp___1,incom_acp___2,
        other_prob_list___1,other_prob_list___2,
        sdoh_iso___1,sdoh_iso___2,
        nutr_poor___1,nutr_poor___2,
        hous_def___1,hous_def___2,
        sdoh_transp___1,sdoh_transp___2,
        sdoh_finance___1,sdoh_finance___2,
        sdoh_other_2___1,sdoh_other_2___2) > '0'
    or length(allerg||notes_56||med_diag_list_v2_v2_v2) > 0 );

drop view if exists v3_primary_referrer;
create view v3_primary_referrer as
select record_id
     , redcap_data_access_group
     , case 
          when referred_by___1 = 1 then 1 --Self
          when referred_by___2 = 1 then 2 --Family
          when referred_by___3 = 1 then 3 --Neighbord/Friend
          when referred_by___4 = 1 then 4 --PCP
          when referred_by___5 = 1 then 8 --Community Agency
          when referred_by___6 = 1 then 9 --Clergy
          when referred_by___7 = 1 then 10 --Hospital/SNF discharge coordinator
          when referred_by___8 = 1 then 11 --First Responder/Ambulance Service
          when referred_by___9 = 1 then 12 --Other
       end as primary_referrer
  from redcap_export_v2_v3
 where redcap_repeat_instrument = ''
   and referred_by___1+referred_by___2+referred_by___3+
       referred_by___4+referred_by___5+referred_by___6+
       referred_by___7+referred_by___8+referred_by___9 = 1
union all
select record_id
     , redcap_data_access_group
     , 12 primary_referrer --Other
  from redcap_export_v2_v3
 where redcap_repeat_instrument = ''
   and referred_by___1+referred_by___2+referred_by___3+
       referred_by___4+referred_by___5+referred_by___6+
       referred_by___7+referred_by___8+referred_by___9 > 1;
