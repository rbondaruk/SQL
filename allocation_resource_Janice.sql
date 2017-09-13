  SELECT y.last_name,
         y.first_name,
         y.resource_code,
         y.manager_last_name,
         y.manager_first_name,
         y.project_name,
         y.project_code,
         y.alloc_hours,
         z.avail_hours,
         DECODE(z.avail_hours,0,0,
                                y.alloc_hours / z.avail_hours) alloc_percent,
         x.total_alloc_hours
    FROM (SELECT f.resource_id,
                 ROUND(SUM(NVL(f.available_hours,0)),2) avail_hours
            FROM nbi_resource_facts f
           WHERE f.fact_date BETWEEN TRUNC(TO_DATE('11/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
        GROUP BY f.resource_id) z,
         (SELECT e.last_name,
                 e.first_name,
                 e.resource_code,
                 c.resource_id,
                 e.manager_last_name,
                 e.manager_first_name,
                 d.project_name,
                 d.project_code,
                 ROUND(SUM(NVL(c.allocated_qty,0)),2) alloc_hours
            FROM nbi_project_res_task_facts c,
                 nbi_project_current_facts d,
                 nbi_resource_current_facts e
           WHERE c.fact_date BETWEEN TRUNC(TO_DATE('11/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
             AND c.project_id = d.project_id
             AND c.resource_id = e.resource_id
             AND e.is_role = 0
             AND d.is_active = 1
        GROUP BY e.last_name,
                 e.first_name,
                 e.resource_code,
                 c.resource_id,
                 e.manager_last_name,
                 e.manager_first_name,
                 e.manager_id,
                 d.project_name,
                 d.project_code,
                 d.project_id) y,
         (SELECT c.resource_id,
                 ROUND(SUM(NVL(c.allocated_qty,0)),2) total_alloc_hours
            FROM nbi_project_res_task_facts c,
                 nbi_project_current_facts d
           WHERE c.fact_date BETWEEN TRUNC(TO_DATE('11/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
             AND c.project_id = d.project_id
             AND d.is_active = 1
        GROUP BY c.resource_id) x
     WHERE z.resource_id = y.resource_id
       AND z.resource_id = x.resource_id
  ORDER BY y.last_name,
           y.first_name
