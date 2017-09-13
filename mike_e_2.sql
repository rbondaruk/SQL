SELECT c.resource_code AS resourceid,
       c.first_name,
       c.last_name,
       b.project_code,
       b.project_name,
       d.prexternalid AS taskid,
       d.prname AS taskname,
       sum(a.etc_qty)
  FROM nbi_prt_facts a,
       nbi_project_current_facts b,
       nbi_resource_current_facts c,
       prtask d
 WHERE (a.project_id = 5001001 OR a.project_id = 5003017 OR a.project_id = 5003018)
   AND a.project_id = b.project_id
   AND a.resource_id = c.resource_id
   AND c.is_role = 0
   AND a.task_id = d.prid
   AND a.project_id = d.prprojectid
--   AND a.fact_date BETWEEN TO_DATE('07/01/2004','MM/DD/YYYY') AND TO_DATE('07/31/2004','MM/DD/YYYY')
--   AND a.etc_qty > 0
GROUP BY c.resource_code,
       c.first_name,
       c.last_name,
       b.project_code,
       b.project_name,
       d.prexternalid,
       d.prname
ORDER BY c.resource_code,
         b.project_code,
         d.prexternalid,
         sum(a.etc_qty)


