  select b.project_name,
         b.project_code,
         b.is_active,
         c.last_name,
         c.first_name,
         c.resource_code,
         c.manager_last_name,
         c.manager_first_name,
         NVL(SUM(a.actual_qty),0) actual_hours
    from nbi_prt_facts a,
         nbi_project_current_facts b,
         nbi_resource_current_facts c
   where a.fact_date BETWEEN TRUNC(TO_DATE('09/01/2004','MM/DD/YYYY')) AND TRUNC(TO_DATE('11/30/2004','MM/DD/YYYY'))
     and a.project_id = b.project_id
     and a.resource_id = c.resource_id
group by a.project_id,
         b.project_name,
         b.project_code,
         b.is_active,
         a.resource_id,
         c.last_name,
         c.first_name,
         c.resource_code,
         c.manager_last_name,
         c.manager_first_name
