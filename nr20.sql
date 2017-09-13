              -- Get posted time entries
              SELECT CASE WHEN SUBSTR(h.unique_name,1,2) = 'SU'
                               THEN 'Sustainment'
                          WHEN SUBSTR(h.unique_name,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                               THEN 'Service Request'
                          ELSE 'Project'
                     END AS type,
                     x2.name parent_name,
                     x.name unit_name,
                     d.unique_name AS rnumber,
                     d.first_name first_name,
                     d.last_name last_name,
                     e.last_name manager_last_name,
                     e.first_name manager_first_name,
                     h.name AS project_name,
                     g.prname AS task_name,
                     CASE WHEN b.prstatus = 0
                               THEN 'unsubmitted'
                          WHEN b.prstatus = 1
                               THEN 'submitted'
                          WHEN b.prstatus = 2
                               THEN 'rejected (returned)'
                          WHEN b.prstatus = 3
                               THEN 'approved'
                          WHEN b.prstatus = 4
                               THEN 'posted'
                          WHEN b.prstatus = 5
                               THEN 'adjusted'
                     END AS status,
                     SUM(s.slice) AS hours
                FROM PRTimePeriod a,
                     PRTimeSheet b,
                     PRTimeEntry c,
                     srm_resources d,
                     cmn_sec_users e,
                     PRAssignment f,
                     PRTask g,                          
                     srm_projects h,
                     prj_blb_slices s,
                     prj_blb_slicerequests sr,
                     nbi_resource_current_facts z,
                     nbi_dim_obs y,
                     prj_obs_units x,
                     prj_obs_units x2,
                     prj_obs_types w,
                     prj_obs_levels v
               WHERE a.prID = b.prTimePeriodID
                 AND b.prID = c.prTimeSheetID
                 AND b.prResourceID = d.id
                 AND d.manager_id = e.id(+) 
                 AND d.resource_type = 0
                 AND c.prAssignmentID = f.prID
                 AND f.prTaskID = g.prID
                 AND g.prProjectID = h.id
                 AND f.prID = s.prj_object_id
                 AND s.slice_request_id = sr.id
                 AND sr.request_name = 'DAILYRESOURCEACTCURVE'
                 AND TRUNC(s.slice_date) BETWEEN TRUNC(a.prStart) AND TRUNC(a.prFinish - 1) 
--                 AND TRUNC(s.slice_date) BETWEEN start_date AND finish_date
                 AND d.id = z.resource_id
                 AND z.obs1_unit_id = y.obs_unit_id
                 AND y.level2_unit_id = 5000018
                 AND y.obs_unit_id = x.id
                 AND x.parent_id = x2.id (+)
                 AND w.id = x.type_id
                 AND w.id = 5000009
                 AND x.type_id = v.type_id
                 AND x.depth = v.obs_level
            GROUP BY CASE WHEN SUBSTR(h.unique_name,1,2) = 'SU'
                               THEN 'Sustainment'
                          WHEN SUBSTR(h.unique_name,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                               THEN 'Service Request'
                          ELSE 'Project'
                     END,
                     x2.name,
                     x.name,
                     d.unique_name,
                     d.last_name,
                     d.first_name,
                     e.last_name,
                     e.first_name,
                     h.name,
                     g.prname,
                     CASE WHEN b.prstatus = 0
                               THEN 'unsubmitted'
                          WHEN b.prstatus = 1
                               THEN 'submitted'
                          WHEN b.prstatus = 2
                               THEN 'rejected (returned)'
                          WHEN b.prstatus = 3
                               THEN 'approved'
                          WHEN b.prstatus = 4
                               THEN 'posted'
                          WHEN b.prstatus = 5
                               THEN 'adjusted'
                     END
            ORDER BY x2.name,
                     x.name,
                     d.last_name,
                     d.first_name

/*

       
select b.path
  from nbi_resource_current_facts a,
       nbi_dim_obs b
 where a.obs1_unit_id = b.obs_unit_id
   and b.obs_type_id = 5000009
and b.level2_unit_id = 5000018;


  SELECT T.unique_name,
         T.category,
         T.name,
         l.obs_level,
         l.name level_name,
         u.parent_id,
         u.depth,
         u.unique_name unit_unique_name,
         u.name unit_name,
         u2.unique_name parent_unique_name,
         u2.name parent_name   
    FROM prj_obs_types T,
         prj_obs_levels l,
         prj_obs_units u,
         prj_obs_units u2,
         nbi_dim_obs a,
         nbi_resource_current_facts b
   WHERE T.id = u.type_id
     AND u.type_id = l.type_id
     AND u.depth = l.obs_level
     AND u.parent_id = u2.id (+)
     AND T.id = 5000009
     AND u.id = a.obs_unit_id
     AND a.level2_unit_id = 5000018
     AND a.obs_unit_id = b.obs1_unit_id
ORDER BY T.unique_name, u.depth, u2.name, u.unique_name


SELECT b.resource_id,
       b.resource_code,
       b.first_name,
       b.last_name,
       b.fact_date summary_date,             
       NVL(b.available_hours,0) avail_hours,
       NVL(c.actual_qty,0) actual_hours,
       NVL(c.etc_qty,0) etc_hours,
       c.task_id,   
       c.hardbooked,
       d.project_id,
       d.project_code,
       TRUNC(e.prstart) task_start,
       TRUNC(e.prfinish) task_finish,
       e.prName task_name,           
       d.project_name,
       h.level2_name obs_name 
  FROM nbi_resource_facts b,
       nbi_project_res_task_facts c,
       nbi_project_current_facts d,    
       prTask e,
       prj_obs_associations g,
       nbi_dim_obs h 
 WHERE b.resource_id = c.resource_id
   AND b.fact_date = c.fact_date
   AND c.project_id = d.project_id
   AND c.task_id = e.prID
   AND b.resource_id = g.record_id
   AND g.table_name = 'SRM_RESOURCES'
   AND g.unit_id = h.obs_unit_id
   AND h.level2_unit_id = 




       
  SELECT CASE WHEN SUBSTR(e.unique_name,1,2) = 'SU'
                   THEN 'Sustainment'
              WHEN SUBSTR(e.unique_name,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                   THEN 'Service Request'
                   ELSE 'Project'
         END AS type,
         x2.name parent_unit_name,
         x.name unit_name,
         a.resource_code rnumber,
         a.first_name,
         a.last_name,
         a.manager_first_name,
         a.manager_last_name,
         c.project_name,
         d.prname task_name,
         SUM(NVL(b.actual_qty,0)) actual_hours,
         SUM(NVL(b.etc_qty,0)) etc_hours
    FROM nbi_resource_facts a,
         nbi_project_res_task_facts b,
         nbi_project_current_facts c,
         prTask d,
         srm_projects e,
         nbi_dim_obs y,
         prj_obs_units x,
         prj_obs_units x2,
         prj_obs_types w,
         prj_obs_levels v
   WHERE a.resource_id = b.resource_id
     AND a.fact_date = b.fact_date
     AND b.project_id = c.project_id
     AND b.task_id = d.prID
     AND c.project_id = e.id
     AND a.obs1_unit_id = y.obs_unit_id
     AND y.level2_unit_id = 5000018
     AND y.obs_unit_id = x.id
     AND x.parent_id = x2.id (+)
     AND w.id = x.type_id
     AND w.id = 5000009
     AND x.type_id = v.type_id
     AND x.depth = v.obs_level
GROUP BY CASE WHEN SUBSTR(e.unique_name,1,2) = 'SU'
                   THEN 'Sustainment'
              WHEN SUBSTR(e.unique_name,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                   THEN 'Service Request'
                   ELSE 'Project'
         END,
         x2.name,
         x.name,
         a.resource_code,
         a.first_name,
         a.last_name,
         a.manager_first_name,
         a.manager_last_name,
         c.project_name,
         d.prname


*/
