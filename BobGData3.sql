  select CASE WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SR'
              THEN 'Service Request'
              WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
              THEN 'Sustainment'
              ELSE 'Project'
         END AS work_type,
         b.project_code,
         b.project_name,
         c.first_name || ' ' || c.last_name AS staff_name,
         DECODE(UPPER(SUBSTR(c.resource_code,1,1)),'R','N','Y') AS contractor,
         a.hours_type,
         SUM(Jan) AS Jan,
         SUM(Feb) AS Feb, 
         SUM(Mar) AS Mar, 
         SUM(Apr) AS Apr, 
         SUM(May) AS May, 
         SUM(Jun) AS Jun, 
         SUM(Jul) AS Jul, 
         SUM(Aug) AS Aug, 
         SUM(Sep) AS Sep, 
         SUM(Oct) AS Oct, 
         SUM(Nov) AS Nov, 
         SUM(Dec) AS Dec,
         c.manager_first_name || ' ' || c.manager_last_name AS manager
    from trg_bobgoetz_temp a,
         nbi_project_current_facts b,
         nbi_resource_current_facts c
   WHERE a.projectid = b.project_id
     AND a.resource_id = c.resource_id
group by CASE WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SR'
              THEN 'Service Request'
              WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
              THEN 'Sustainment'
              ELSE 'Project'
         END,
         b.project_code,
         b.project_name,
         c.first_name || ' ' || c.last_name,
         c.manager_first_name || ' ' || c.manager_last_name,
         DECODE(UPPER(SUBSTR(c.resource_code,1,1)),'R','N','Y'),
         a.hours_type
         

