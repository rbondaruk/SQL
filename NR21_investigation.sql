        SELECT DISTINCT b.project_id
          FROM nbi_project_current_facts b
         WHERE SUBSTR(b.project_code,1,2) = 'SR'
           AND b.project_id = (
select a.project_id from nbi_project_current_facts a where a.project_code = 'SR05-F351-10640'
)
--5042241

                    SELECT COUNT(*)
                      FROM prtask a
                     WHERE a.prwbslevel = 1
                       AND a.prprojectid = 5042241
                       AND UPPER(SUBSTR(a.prname,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
--6

        SELECT a.prwbssequence,
               a.prname,
               SUBSTR(a.prname,1,2) AS forum
          FROM prtask a
         WHERE a.prwbslevel = 1
           AND a.prprojectid = 5042241
           AND UPPER(SUBSTR(a.prname,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
           AND SUBSTR(a.prname,5,1) = '-'
      ORDER BY a.prwbssequence
--Row #	PRWBSSEQUENCE	PRNAME	FORUM	
--           13 RT05-F530-10772  RT
--           16 RT05-F351-10898  RT
                                                                                                                                                                                HC                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                        SELECT a.prname,
                               a.prstart,
                               a.prfinish
                          FROM prtask a
                         WHERE a.prwbssequence = 16 + 1
                           AND a.prwbslevel = 2
                           AND a.prprojectid = 5042241

--Row #	PRNAME	PRSTART	PRFINISH	
--Upgrade Caterpillar from NT to W2k3 server       7-Mar-2005 8:45:00 1-Jun-2005 16:00:00

--previous_wbsseq := 16;
--previous_forum := 'RT';
--previous_SR_number := RT05-F351-10898;
-- current_wbsseq := 16;
-- current_forum := 'RT';
-- current_SR_number := RT05-F351-10898;

        SELECT a.prid,
               b.prresourceid
          FROM prtask a,
               prassignment b
         WHERE a.prprojectid = 5042241
           AND a.prwbssequence >= 16
           AND (a.prwbssequence < 16 OR 0 = 0)
           AND a.prid = b.prtaskid
--   5018521      5004904
--   5018521      5004568
--   5018521      5004650
--   5018521      5004509

delete trg_nr21_temp

                            INSERT INTO trg_nr21_temp(
                                        projectid,
                                        taskid,
                                        resourceid,
                                        forum,
                                        SR_number,
                                        SR_name,
                                        startdate,
                                        finishdate,
                                        fact_date,
                                        actual_qty,
                                        etc_qty)
                                     SELECT a.project_id,
                                            a.task_id,
                                            a.resource_id,
                                            'RT',
                                            'RT05-F351-10898',
                                            'Upgrade Caterpillar from NT to W2k3 server',
                                            TRUNC(TO_DATE('3/7/2005','MM/DD/YYYY')) AS previous_start,
                                            TRUNC(TO_DATE('6/1/2005','MM/DD/YYYY')) AS previous_finish,
                                            a.fact_date,
                                            a.actual_qty,
                                            a.base_qty
                                       FROM nbi_project_res_task_facts a
                                      WHERE a.task_id = 5018521
                                        AND a.fact_date BETWEEN TRUNC(TO_DATE('01/01/1950', 'MM/DD/YYYY')) AND TRUNC(TO_DATE('01/02/2006', 'MM/DD/YYYY'))
                                        AND a.resource_id = 5004509
                                

        INSERT INTO trg_nr21b_temp(
                    forum,
                    obs_unit_id,
                    SR_number,
                    SR_name,
                    startdate,
                    finishdate,
                    manager,
                    actual_qty,
                    etc_qty)
             SELECT CASE WHEN a.forum = 'FN' -- Finance
                         THEN 'Finance'
                         WHEN a.forum = 'HR' -- Human Resources
                         THEN 'Human Resources'
                         WHEN a.forum = 'RT' -- RITS
                         THEN 'RITS'
                         WHEN a.forum = 'SL' -- Sales
                         THEN 'Sales'
                         WHEN a.forum = 'MK' -- Marketing
                         THEN 'Marketing'
                         WHEN a.forum = 'MS' -- Member Services
                         THEN 'Member Services'
                         WHEN a.forum = 'HC' -- Health Care Services
                         THEN 'Health Care Services'
                         ELSE 'No Forum'
                    END AS forum,
                    c.obs1_unit_id AS obs_unit_id,
                    a.sr_number,
                    a.sr_name,
                    a.startdate,
                    a.finishdate,
                    b.manager_last_name || ', ' || b.manager_first_name,
                    NVL(SUM(a.actual_qty),0) AS actual_qty,
                    NVL(SUM(a.etc_qty),0) AS etc_qty
               FROM trg_nr21_temp a,
                    nbi_project_current_facts b,
                    nbi_resource_current_facts c
              WHERE a.projectid = b.project_id
                AND a.resourceid = c.resource_id
           GROUP BY a.forum,
                    a.sr_number,
                    a.sr_name,
                    a.startdate,
                    a.finishdate,
                    b.manager_last_name || ', ' || b.manager_first_name,
                    c.obs1_unit_id;
                                                                                                                                                                    5025802                                                                                                                          5034023                                                                                                                                                                      MS                               HR03-B221-08176                  Instructor Role in ROLLS         9-Mar-2005 31-Mar-2006 9-Mar-2005 0                                                                                                                                                                            0                                                                                                                                                                           
select * from nbi_resource_current_facts a
where a.resource_id = 5034024 --5004260


    UPDATE trg_nr21b_temp a
       SET (orgchart,path) =
           (SELECT CASE WHEN e.hierarchy_level = 2
                        THEN e.level2_name
                        WHEN e.hierarchy_level = 3
                        THEN e.level3_name
                        WHEN e.hierarchy_level = 4
                        THEN e.level4_name
                        WHEN e.hierarchy_level = 5
                        THEN e.level5_name
                        WHEN e.hierarchy_level = 6
                        THEN e.level6_name
                        WHEN e.hierarchy_level = 7
                        THEN e.level7_name
                        WHEN e.hierarchy_level = 8
                        THEN e.level8_name
                        WHEN e.hierarchy_level = 9
                        THEN e.level9_name
                        WHEN e.hierarchy_level = 10
                        THEN e.level10_name
                        ELSE ''
                   END AS orgchart,
                   e.path AS path
              FROM nbi_dim_obs e
             WHERE e.obs_unit_id = a.obs_unit_id
           )

select * from trg_nr21_temp

select * from trg_nr21b_temp

-- Noelle Grant
-- where the 15 hours from the week ending 4/9/05
select * from NBI_RESOURCE_CURRENT_FACTS a
where a.resource_id = 5034023

select a.project_id, b.project_name, b.project_code, c.resource_id, c.first_name, c.last_name, c.resource_code, c.is_role,
TO_CHAR(a.fact_date,'MON') AS MONTH, TO_CHAR(a.fact_date,'YYYY') AS YEAR,
SUM(a.etc_qty) AS SUM_ETC, SUM(a.actual_qty) SUM_ACTUALS , SUM(a.base_qty) AS SUM_BASELINED_ETC, SUM(a.allocated_qty) AS SUM_ALLOCATION
from nbi_project_res_task_facts a, nbi_project_current_facts b, NBI_RESOURCE_CURRENT_FACTS c
where a.project_id = b.project_id
--and a.resource_id = 5004285
and a.resource_id = c.resource_id
and a.project_id IN (
SELECT d.project_id
FROM nbi_project_current_facts d
WHERE UPPER(SUBSTR(d.project_code,1,2)) NOT IN( 'FN','HR','RT','SL','MK','MS','HC','SR','SU')
)
group by a.project_id, b.project_name, b.project_code, c.resource_id, c.first_name, c.last_name, c.resource_code, c.is_role,
TO_CHAR(a.fact_date,'YYYY'), TO_CHAR(a.fact_date,'MON')

