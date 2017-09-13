  SELECT y.*,
         z.avail_hours,
         x.total_alloc_hours
    FROM (SELECT f.resource_id,
                 TRUNC(f.fact_date,'MM') month,
                 ROUND(SUM(NVL(f.available_hours,0)),2) avail_hours
            FROM nbi_resource_facts f
           WHERE f.fact_date BETWEEN TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
        GROUP BY f.resource_id,
                 TRUNC(f.fact_date,'MM')
         ) z,
         (SELECT e.last_name,
                 e.first_name,
                 c.resource_id,
                 e.manager_last_name,
                 e.manager_first_name,
                 e.manager_id,
                 d.project_name,
                 d.project_id,
                 TRUNC(c.fact_date,'MM') month,
                 ROUND(SUM(NVL(c.allocated_qty,0)),2) alloc_hours
            FROM nbi_project_res_task_facts c,
                 nbi_project_current_facts d,
                 nbi_resource_current_facts e
           WHERE c.fact_date BETWEEN TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
             AND c.project_id = d.project_id
             AND c.resource_id = e.resource_id
             AND e.is_role = 0
        GROUP BY e.last_name,
                 e.first_name,
                 c.resource_id,
                 e.manager_last_name,
                 e.manager_first_name,
                 e.manager_id,
                 d.project_name,
                 d.project_id,
                 TRUNC(c.fact_date,'MM')
         ) y,
         (SELECT c.resource_id,
                 TRUNC(c.fact_date,'MM') month,
                 ROUND(SUM(NVL(c.allocated_qty,0)),2) total_alloc_hours
            FROM nbi_project_res_task_facts c
           WHERE c.fact_date BETWEEN TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
        GROUP BY c.resource_id,
                 TRUNC(c.fact_date,'MM')
         ) x
     WHERE z.resource_id = y.resource_id
       AND z.month = y.month
       AND z.resource_id = x.resource_id
       AND z.month = x.month
       AND x.total_alloc_hours > z.avail_hours
  ORDER BY y.last_name,
           y.first_name,
           y.month


