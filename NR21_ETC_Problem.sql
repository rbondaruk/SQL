        SELECT DISTINCT b.project_id
          FROM nbi_project_current_facts b
         WHERE SUBSTR(b.project_code,1,2) = 'SR'
           AND b.project_code = 'SR04-T530-10171'
-- 5024123

                    SELECT COUNT(*)
                      FROM prtask a
                     WHERE a.prwbslevel = 1
                       AND a.prprojectid = 5024123
                       AND UPPER(SUBSTR(a.prname,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                       AND (UPPER(SUBSTR(a.prname,1,2)) = 'ALL' OR 'ALL' = 'ALL')
                       AND SUBSTR(a.prname,5,1) = '-'
-- 2

        SELECT a.prwbssequence,
               a.prname,
               SUBSTR(a.prname,1,2) AS forum
          FROM prtask a
         WHERE a.prwbslevel = 1
           AND a.prprojectid = 5024123
           AND UPPER(SUBSTR(a.prname,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
           AND (UPPER(SUBSTR(a.prname,1,2)) = 'ALL' OR 'ALL' = 'ALL')
           AND SUBSTR(a.prname,5,1) = '-'
      ORDER BY a.prwbssequence
-- Row #	PRWBSSEQUENCE	PRNAME	        FORUM	
                        1   FN04-B162-09813 FN
                       10   HR04-B231-09978 HR

                       SELECT a.prname,
                               a.prstart,
                               a.prfinish
                          FROM prtask a
                         WHERE a.prwbssequence = 1 + 1
                           AND a.prwbslevel = 2
                           AND a.prprojectid = 5024123
-- ITS Reconciliation   1-Aug-2004 8:00:00  15-Dec-2004 17:00:00

        SELECT a.prid,
               b.prresourceid
          FROM prtask a,
               prassignment b
         WHERE a.prprojectid = 5024123
           AND a.prwbssequence >= 1
           AND (a.prwbssequence < 10 OR 10 = 0)
           AND a.prid = b.prtaskid

--      PRID PRRESOURCEID
--   5011413      5004298
--   5011413      5005947
--   5011413      5004776
--   5011413      5004389
--   5011445      5004569
--   5011445      5004331
--   5011445      5012939
--   5011447      5004298
--   5011447      5005947
--   5011447      5004389
--   5011416      5004389
--   5011416      5004406
--   5011416      5004569
--   5011416      5004242
--   5011416      5004056
--   5011416      5004298
--   5011416      5004331
--   5011416      5004563
--   5011416      5004700

                                 SELECT a.project_id,
                                        a.task_id,
                                        b.prname,
                                        a.resource_id,
                                        'FN',
                                        'FN04-B162-09813',
                                        'ITS Reconciliation',
                                        '1-Aug-2004 8:00:00',
                                        '15-Dec-2004 17:00:00',
                                        a.fact_date,
                                        a.actual_qty,
                                        a.etc_qty
                                   FROM nbi_project_res_task_facts a,
                                        prtask b,
                                        prassignment c
                                  WHERE a.task_id = b.prid
                                    AND a.fact_date BETWEEN TRUNC(TO_DATE('01/01/1950', 'MM/DD/YYYY')) AND TRUNC(SYSDATE)
                                    AND a.resource_id = c.prresourceid
                                 AND b.prprojectid = 5024123
                                   AND b.prwbssequence >= 1
                                   AND (b.prwbssequence < 10 OR 10 = 0)
                                   AND b.prid = c.prtaskid

