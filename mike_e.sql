select a.project_name,
       b.task_description,
       b.etc_qty
  from NBI_PROJECT_CURRENT_FACTS a,
       NBI_PROJECT_RES_TASK_FACTS b,
       srm_resources c
 where a.project_id = b.project_id
   and b.resource_id = c.id
   and c.is_active = 0
