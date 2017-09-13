--select * from nbi_resource_facts



        SELECT z.*,
--               ROUND(DECODE(z.avail_hours,0,(z.alloc_hours / 1)*100,
--                                      (z.alloc_hours / z.avail_hours)*100),2) alloc_percent,
--               ROUND(DECODE(z.total_alloc_hours,0,0,
--                                      (z.alloc_hours / z.total_alloc_hours)*100),2) percent_of_total_alloc,
               TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AS startdate,
               TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY')) AS enddate
          FROM (
                SELECT e.last_name,
                       e.first_name,
                       e.manager_id,
                       d.project_name,
                       SUM(NVL(c.allocated_qty,0)) alloc_hours,
                       c.resource_id,
                       d.project_id--,
--                       (
--                        SELECT SUM(NVL(b.available_hours,0))
--                          FROM nbi_resource_facts b
--                         WHERE b.resource_id = c.resource_id
--                           AND b.fact_date between TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
--                       ) avail_hours,
--                       (
--                        SELECT SUM(NVL(a.allocated_qty,0))
--                          FROM nbi_project_res_task_facts a
--                         WHERE a.resource_id = c.resource_id
--                           AND a.fact_date between TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
--                       ) total_alloc_hours
                  FROM nbi_project_res_task_facts c,
                       nbi_project_current_facts d,
                       nbi_resource_facts e
                 WHERE c.fact_date between TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('12/31/2004','MM/DD/YYYY'))
                   AND c.project_id = d.project_id
                   AND c.resource_id = e.resource_id
                   AND e.is_role = 0
              GROUP BY e.last_name,
                       e.first_name,
                       e.manager_id,
                       c.resource_id,
                       d.project_name,
                       d.project_id
               ) z
--         WHERE ((z.resource_id = r_id AND NVL(r_id,0) > 0) OR (NVL(r_id,1) > 0))
--           AND ((z.project_id = p_id AND NVL(p_id,0) > 0) OR (NVL(p_id,1) > 0))
--           AND ((z.manager_id = r_manager_id AND NVL(r_manager_id,0) > 0) OR (NVL(r_manager_id,1) > 0))
--           AND ((z.total_alloc_hours > z.avail_hours AND only_overallocated = 1) OR only_overallocated = 0)
      ORDER BY z.project_name,
               z.last_name,
               z.first_name;
