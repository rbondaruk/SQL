SELECT a.id,
       a.last_name,
       a.first_name,
       a.unique_name,
       e.user_status_id,
       h.lookup_code,
       a.manager_id,
       b.last_name mgr_last_name,         
       b.first_name mgr_first_name,
       d.full_name role_name,
       a.date_of_hire,
       g.path
  FROM srm_resources a,
       cmn_sec_users b,
       prj_resources c,      
       srm_resources d,
       cmn_sec_users e,
       prj_obs_associations f,
       nbi_dim_obs g,
       cmn_lookups h
 WHERE a.manager_id = b.id  (+)
   AND a.id = c.prID (+)
   AND c.prisrole = 0
   AND c.prPrimaryRoleID = d.id (+)
   AND a.user_id = e.id
   AND e.user_status_id = h.id
   AND h.lookup_code = 'ACTIVE'
   AND a.is_active = 1
   AND a.id = f.record_id
   AND f.table_name = 'SRM_RESOURCES'
   AND f.unit_id = g.obs_unit_id (+)
   AND g.level2_unit_id <> 5000018
   AND g.obs_type_name = 'TRGOrg'
order by a.unique_name
--order by a.last_name,
--         a.first_name

