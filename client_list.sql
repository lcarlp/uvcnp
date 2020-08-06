-- List clients from Lyme in Alphabetical order.
-- To use for other towns, change town name, but, importantly,
-- make sure you use the correct export table, which is
-- referenced multiple times.
select client.last_name
     , client.first_name
     , client.record_id
     , case status.client_redcap_status
            when 2 then 'Inactive'
            when 3 then 'Discharged'
            else 'Active'
       end status
  from redcap_export_20200805 client
  left join redcap_export_20200805 status
    on status.record_id = client.record_id
   and status.redcap_repeat_instrument = 'status_update'
   and not exists( --No newer status rows
        select null
          from redcap_export_20200805 status2
         where status2.record_id = client.record_id
           and status2.redcap_repeat_instrument = 'status_update'
           and status2.redcap_repeat_instance > status.redcap_repeat_instance )
 where client.redcap_repeat_instrument = ''
   and client.redcap_data_access_group = 'lyme'
 order by 1,2,3;
