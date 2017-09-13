  SELECT '07/01/2004' AS start_date,
         '07/31/2004' AS end_date,
         CASE WHEN SUBSTR(b.project_code,1,2) = 'SU'
                   THEN 'Sustainment'
              WHEN SUBSTR(b.project_code,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                   THEN 'Service Request'
              ELSE 'Project'
         END AS type,
         SUBSTR(e.path,33) AS orgchart,
         b.project_name,
         NVL(SUM(a.actual_qty),0) AS actual_qty,
         NVL(SUM(a.etc_qty),0) AS etc_qty
    FROM nbi_dim_obs e,
         nbi_resource_current_facts c,
         nbi_prt_facts a,
         nbi_project_current_facts b,
         prtask d
   WHERE e.level2_unit_id = 5000018
     AND e.obs_unit_id = c.obs1_unit_id (+)
     AND c.is_role (+) = 0
     AND c.resource_id = a.resource_id (+)
     AND a.fact_date (+) BETWEEN TO_DATE('07/01/2004','MM/DD/YYYY') AND TO_DATE('07/31/2004','MM/DD/YYYY')
     AND a.project_id = b.project_id (+)
     AND a.task_id = d.prid (+)
     AND a.project_id = d.prprojectid (+)
GROUP BY CASE WHEN SUBSTR(b.project_code,1,2) = 'SU'
                   THEN 'Sustainment'
              WHEN SUBSTR(b.project_code,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                   THEN 'Service Request'
              ELSE 'Project'
         END,
         e.path,
         b.project_name
ORDER BY CASE WHEN SUBSTR(b.project_code,1,2) = 'SU'
                   THEN 'Sustainment'
              WHEN SUBSTR(b.project_code,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                   THEN 'Service Request'
              ELSE 'Project'
         END,
         e.path


/*
  SELECT '07/01/2004' AS start_date,
         '07/31/2004' AS end_date,
         CASE WHEN SUBSTR(b.project_code,1,2) = 'SU'
                   THEN 'Sustainment'
              WHEN SUBSTR(b.project_code,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                   THEN 'Service Request'
              ELSE 'Project'
         END AS type,
         SUBSTR(e.path,33) AS orgchart,
         b.project_name,
         NVL(SUM(a.actual_qty),0) AS actual_qty,
         NVL(SUM(a.etc_qty),0) AS etc_qty
    FROM nbi_dim_obs e,
         nbi_project_res_task_facts a,
         nbi_project_current_facts b,
         prtask d
   WHERE e.level2_unit_id = 5000018
     AND e.obs_unit_id = a.obs1_unit_id (+)
     AND a.fact_date (+) BETWEEN TO_DATE('07/01/2004','MM/DD/YYYY') AND TO_DATE('07/31/2004','MM/DD/YYYY')
     AND a.project_id = b.project_id (+)
     AND a.task_id = d.prid (+)
     AND a.project_id = d.prprojectid (+)
GROUP BY CASE WHEN SUBSTR(b.project_code,1,2) = 'SU'
                   THEN 'Sustainment'
              WHEN SUBSTR(b.project_code,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                   THEN 'Service Request'
              ELSE 'Project'
         END,
         e.path,
         b.project_name
ORDER BY CASE WHEN SUBSTR(b.project_code,1,2) = 'SU'
                   THEN 'Sustainment'
              WHEN SUBSTR(b.project_code,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                   THEN 'Service Request'
              ELSE 'Project'
         END,
         e.path
*/

