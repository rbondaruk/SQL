SELECT d.* ,b.name
  FROM prj_obs_associations a, srm_projects b, prj_projects c, prj_obs_units d
 WHERE a.table_name = 'SRM_PROJECTS'
   AND a.record_id = b.id
   AND b.id = c.prid
   AND a.unit_id = d.id

