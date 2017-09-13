select b.unique_name, a.*
  from prtask a,
       srm_projects b
 where a.prprojectid = b.id
   and a.prmodtime > SYSDATE - 90
   and a.prstart BETWEEN TO_DATE('01/01/2005','MM/DD/YYYY') AND TO_DATE('12/31/2005','MM/DD/YYYY')
   and a.prfinish BETWEEN TO_DATE('01/01/2005','MM/DD/YYYY') AND TO_DATE('12/31/2005','MM/DD/YYYY')
   and not exists (
       select *
         from nbi_project_res_task_facts b
        where a.prid = b.task_id
          and a.prprojectid = b.project_id)
