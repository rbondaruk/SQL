select * from nbi_project_current_facts a
where a.project_code = 'SR05-T405-10654'
--5044267

                    SELECT COUNT(*)
                      FROM prtask a
                     WHERE a.prwbslevel = 1
                       AND a.prprojectid = 5044267
                       AND UPPER(SUBSTR(a.prname,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                       AND SUBSTR(a.prname,5,1) = '-';
-- 60


        SELECT a.prwbssequence,
               a.prname,
               SUBSTR(a.prname,1,2) AS forum
          FROM prtask a
         WHERE a.prwbslevel = 1
           AND a.prprojectid = 5044267
           AND UPPER(SUBSTR(a.prname,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
           AND SUBSTR(a.prname,5,1) = '-'
      ORDER BY a.prwbssequence;
      
--          172 SL05-1430-11326     SL
--          175 MS05-7320-11413     MS
--          178 SL04-1430-09955     SL

                        SELECT a.prname,
                               a.prstart,
                               a.prfinish
                          FROM prtask a
                         WHERE a.prwbssequence = 175 + 1
                           AND a.prwbslevel = 2
                           AND a.prprojectid = 5044267;

-- Issue ID cards for MBA 9/1/05 renewal    7/22/2005 8:45:00 AM    8/23/2005 4:00:00 PM


        SELECT a.prid,
               b.prresourceid
          FROM prtask a,
               prassignment b
         WHERE a.prprojectid = 5044267
           AND a.prwbssequence >= 175
           AND (a.prwbssequence < 178 OR 178 = 0)
           AND a.prid = b.prtaskid;
--   5031786      5062962

                                 SELECT a.project_id,
                                        a.task_id,
                                        a.resource_id,
                                        a.fact_date,
                                        a.actual_qty,
                                        a.base_qty
                                   FROM nbi_project_res_task_facts a
                                  WHERE a.task_id = 5031786
                                    --AND a.fact_date BETWEEN TRUNC(TO_DATE('01/01/1950', 'MM/DD/YYYY')) AND TRUNC(SYSDATE)
                                    --AND a.resource_id = 5062962;
                                    
                                 SELECT a.project_id,
                                        a.task_id,
                                        a.resource_id,
                                        'MS',
                                        'MS05-7320-11413',
                                        'Issue ID cards for MBA 9/1/05 renewal',
                                        '7/22/2005',
                                        '8/23/2005',
                                        a.fact_date,
                                        a.actual_qty,
                                        a.base_qty
                                   FROM nbi_project_res_task_facts a
                                  WHERE a.project_id = 5044267
                                    AND a.resource_id = 5062962
                                    AND a.fact_date BETWEEN TRUNC(TO_DATE('01/01/1950', 'MM/DD/YYYY')) AND TRUNC(SYSDATE)

select * from PRTASK a
WHERE a.prid = 5031786

select * from nbi_project_res_task_facts a
where a.project_id = 5044267
order by a.task_id
--where a.task_id = 5031786

select distinct a.prid 
  from prtask a
minus
select distinct b.task_id 
  from nbi_project_res_task_facts b

  
select *
  from prtask a
where a.prmodtime > SYSDATE - 90
  and not exists (
    select *
      from nbi_project_res_task_facts b
     where a.prid = b.task_id
       and a.prprojectid = b.project_id)

select * from prtask a
where a.prname = 'RT04-T121-09351'
--5029573

select MAX(a.prmodtime)
  from prtask a
where exists (
    select *
      from nbi_project_res_task_facts b
     where a.prid = b.task_id
       and a.prprojectid = b.project_id)


