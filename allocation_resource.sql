SELECT x.*
  FROM (
        SELECT z.last_name,
               z.first_name,
               z.resource_id,
               z.manager_last_name,
               z.manager_first_name,
               z.manager_id,
               z.month,
               SUM(NVL(z.alloc_hours,0)) alloc_hours,
               SUM(NVL(z.avail_hours,0)) avail_hours
          FROM (
                SELECT e.last_name,
                       e.first_name,
                       c.resource_id,
                       e.manager_last_name,
                       e.manager_first_name,
                       e.manager_id,
                       TRUNC(c.fact_date,'MM') month,
                       ROUND(SUM(NVL(c.allocated_qty,0)),2) alloc_hours,
                       0 avail_hours
                  FROM nbi_project_res_task_facts c,
                       nbi_resource_current_facts e
                 WHERE c.fact_date BETWEEN TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
                   AND c.resource_id = e.resource_id
                   AND e.is_role = 0
              GROUP BY e.last_name,
                       e.first_name,
                       c.resource_id,
                       e.manager_last_name,
                       e.manager_first_name,
                       e.manager_id,
                       TRUNC(c.fact_date,'MM')

                 UNION

                SELECT e.last_name,
                       e.first_name,
                       f.resource_id,
                       e.manager_last_name,
                       e.manager_first_name,
                       e.manager_id,
                       TRUNC(f.fact_date,'MM') month,
                       0 alloc_hours,
                       ROUND(SUM(NVL(f.available_hours,0)),2) avail_hours
                  FROM nbi_resource_facts f,
                       nbi_resource_current_facts e
                 WHERE f.fact_date BETWEEN TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
                   AND f.resource_id = e.resource_id
                   AND e.is_role = 0
              GROUP BY e.last_name,
                       e.first_name,
                       f.resource_id,
                       e.manager_last_name,
                       e.manager_first_name,
                       e.manager_id,
                       TRUNC(f.fact_date,'MM')
               ) z
        GROUP BY z.last_name,
                 z.first_name,
                 z.resource_id,
                 z.manager_last_name,
                 z.manager_first_name,
                 z.manager_id,
                 z.month
        ORDER BY z.last_name,
                 z.first_name,
                 z.month
       ) x
 WHERE x.alloc_hours > x.avail_hours
