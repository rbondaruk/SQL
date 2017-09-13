/*
select SUM(NVL(b.available_hours,0))
  from nbi_resource_facts b
 where b.resource_id = c.resource_id
   and b.fact_date between TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
*/


        SELECT z.*,
               ROUND(DECODE(z.avail_hours,0,(z.alloc_hours / 1)*100,
                                      (z.alloc_hours / z.avail_hours)*100),2) alloc_percent,
               TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AS startdate,
               TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY')) AS enddate
          FROM (
                SELECT e.last_name,
                       e.first_name,
                       c.resource_id,
                       e.manager_last_name,
                       e.manager_first_name,
                       e.manager_id,
                       d.project_name,
                       d.project_id,
                       TRUNC(c.fact_date,'MM') month,
                       SUM(NVL(c.allocated_qty,0)) alloc_hours,
                       SUM(NVL(f.available_hours,0)) avail_hours
                  FROM nbi_project_res_task_facts c,
                       nbi_project_current_facts d,
                       nbi_resource_current_facts e,
                       nbi_resource_facts f
                 WHERE c.fact_date BETWEEN TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
                   AND c.project_id = d.project_id
                   AND c.resource_id = e.resource_id
                   AND e.is_role = 0
                   AND c.resource_id = f.resource_id
                   AND f.fact_date = c.fact_date
              GROUP BY e.last_name,
                       e.first_name,
                       c.resource_id,
                       e.manager_last_name,
                       e.manager_first_name,
                       e.manager_id,
                       d.project_name,
                       d.project_id,
                       TRUNC(c.fact_date,'MM')
               ) z
--         WHERE ((z.resource_id = r_id AND NVL(r_id,0) > 0) OR (NVL(r_id,0) = 0))
--           AND ((z.project_id = p_id AND NVL(p_id,0) > 0) OR (NVL(p_id,0) = 0))
--           AND ((z.manager_id = r_manager_id AND NVL(r_manager_id,0) > 0) OR (NVL(r_manager_id,0) = 0))
      ORDER BY z.last_name,
               z.first_name,
               z.month,
               z.project_name




        SELECT z.*,
               ROUND(DECODE(z.avail_hours,0,(z.alloc_hours / 1)*100,
                                      (z.alloc_hours / z.avail_hours)*100),2) alloc_percent,
               TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AS startdate,
               TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY')) AS enddate
          FROM (
                SELECT e.last_name,
                       e.first_name,
                       c.resource_id,
                       e.manager_last_name,
                       e.manager_first_name,
                       e.manager_id,
                       TRUNC(c.fact_date,'MM') month,
                       SUM(NVL(c.allocated_qty,0)) alloc_hours,
                       SUM(NVL(f.available_hours,0)) avail_hours
                  FROM nbi_project_res_task_facts c,
                       nbi_resource_current_facts e,
                       nbi_resource_facts f
                 WHERE c.fact_date BETWEEN TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
                   AND c.resource_id = e.resource_id
                   AND e.is_role = 0
                   AND c.resource_id = f.resource_id
                   AND f.fact_date = c.fact_date
              GROUP BY e.last_name,
                       e.first_name,
                       c.resource_id,
                       e.manager_last_name,
                       e.manager_first_name,
                       e.manager_id,
                       TRUNC(c.fact_date,'MM')
               ) z
--         WHERE ((z.resource_id = r_id AND NVL(r_id,0) > 0) OR (NVL(r_id,0) = 0))
--           AND ((z.manager_id = r_manager_id AND NVL(r_manager_id,0) > 0) OR (NVL(r_manager_id,0) = 0))
--           WHERE z.alloc_hours > z.avail_hours
      ORDER BY z.last_name,
               z.first_name,
               z.month

