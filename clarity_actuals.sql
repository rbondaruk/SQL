select a.project_code
	  ,b.role_name
      ,c.resource_code
      ,TO_CHAR(b.fact_date,'MON')
      ,TO_CHAR(b.fact_date,'YYYY')
      ,b.actual_qty
from NBI_PROJECT_CURRENT_FACTS a
    ,NBI_PROJECT_RES_TASK_FACTS b
    ,NBI_RESOURCE_CURRENT_FACTS c
where a.project_id = b.project_id
and b.resource_id = c.resource_id
and a.project_code in 
('P0530038','P0530048','P0530043','P0530036','P0530053','P0530041','P0530037','P0530044','P0530039','P0530035'
,'P0530045','P0530042','P0530047','P0530046','P0530050','P0530049','P0530051','P0530052','PR0530056','PR0530000'
,'PR0530054','PR0530055')
and b.fact_date BETWEEN TO_DATE('1/1/2006','MM/DD/YYYY') AND TO_DATE('12/31/2006','MM/DD/YYYY')
and b.actual_qty > 0





