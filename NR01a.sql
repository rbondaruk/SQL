SELECT  sp.name as project_name,
        t.prname as key_milestone,
        pp.prusertext1 as phase,
        t.prbasefinish as baseline_finish,
        CASE WHEN t.prstatus = 0 -- NotStarted
             THEN 'Not Started'
             WHEN t.prstatus = 1 -- Started
             THEN 'Started'
        END as task_status
  FROM  niku.prtask t, niku.srm_projects sp, niku.prj_projects pp
 WHERE  t.prprojectid = sp.id
   AND  sp.id = pp.prid
   AND  t.prbasefinish < SYSDATE
   AND  t.prstatus <> 2 -- Completed
   AND  t.prismilestone = 1
   AND  t.priskey = 1
   AND  t.prbasefinish Is Not Null


