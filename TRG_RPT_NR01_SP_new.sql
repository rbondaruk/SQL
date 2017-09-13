CREATE OR REPLACE PROCEDURE TRG_RPT_NR01_SP(
    nOBSUnit  IN       prj_obs_units.id%TYPE DEFAULT 0,
    nOBSLevel IN       prj_obs_levels.id%TYPE DEFAULT 0,
    a_cursor  IN OUT TYPES.cursorType
)

IS

BEGIN
    IF nOBSUnit = 0 THEN
        OPEN a_cursor FOR
            SELECT  project_name,
                    SUM(missed) AS missed,
                    SUM(notstarted) AS notstarted,
                    SUM(inprogress) AS inprogress,
                    SUM(ahead) AS ahead,
                    SUM(onschedule) AS onschedule,
                    SUM(totalmilestones) AS totalmilestones,
                    SUM(totalcompleted) AS totalcompleted,
                    SUM(actual) AS actual,
                    SUM(remaining) AS remaining,
                    SUM(totalhours) AS totalhours
              FROM  (
                    SELECT  p.project_name,
                            0 AS missed,
                            0 AS notstarted,
                            0 AS inprogress,
                            0 AS ahead,
                            0 AS onschedule,
                            0 AS totalmilestones,                
                            0 AS totalcompleted,
                            p.actual_hours AS actual,
                            p.etc_hours AS remaining,
                            p.actual_hours + p.etc_hours AS totalhours
                      FROM  nbi_project_current_facts p
                     WHERE  p.project_id IN (
                                            SELECT  t.prprojectid
                                              FROM  niku.prtask t
                                             WHERE  t.prismilestone = 1
                                               AND  t.priskey = 1
                                               AND  t.prbasefinish IS NOT NULL
                                            )
                     UNION
                    SELECT  p.project_name,
                            SUM(CASE WHEN t.prbasefinish < TRUNC(SYSDATE()) AND t.prstatus <> 2 -- Completed
                                     THEN 1
                                     ELSE 0
                                END) AS missed,
                            SUM(CASE WHEN t.prstatus = 0 -- NotStarted
                                     THEN 1
                                     ELSE 0
                                END) AS notstarted,
                            SUM(CASE WHEN t.prstatus = 1 -- Started
                                     THEN 1
                                     ELSE 0
                                END) AS inprogress,
                            SUM(CASE WHEN t.prbasefinish > TRUNC(SYSDATE()) AND t.prstatus = 2 -- Completed
                                     THEN 1
                                     ELSE 0
                                END) AS ahead,
                            SUM(CASE WHEN t.prbasefinish <= TRUNC(SYSDATE()) AND t.prstatus = 2 -- Completed
                                     THEN 1
                                     ELSE 0
                                END) AS onschedule,
                            COUNT(t.prid) AS totalmilestones,                
                            SUM(CASE WHEN t.prstatus = 2 -- Completed
                                     THEN 1
                                     ELSE 0
                                END) AS totalcompleted,
                            0 AS actual,
                            0 AS remaining,
                            0 AS totalhours
                      FROM  prtask t,
                            nbi_project_current_facts p
                     WHERE  t.prprojectid = p.project_id
                       AND  t.prismilestone = 1
                       AND  t.priskey = 1
                       AND  t.prbasefinish IS NOT NULL
                  GROUP BY  p.project_name
                    )
          GROUP BY  project_name;
    ELSE
        OPEN a_cursor FOR
            SELECT  project_name,
                    SUM(missed) AS missed,
                    SUM(notstarted) AS notstarted,
                    SUM(inprogress) AS inprogress,
                    SUM(ahead) AS ahead,
                    SUM(onschedule) AS onschedule,
                    SUM(totalmilestones) AS totalmilestones,
                    SUM(totalcompleted) AS totalcompleted,
                    SUM(actual) AS actual,
                    SUM(remaining) AS remaining,
                    SUM(totalhours) AS totalhours
              FROM  (
                    SELECT  p.project_name,
                            0 AS missed,
                            0 AS notstarted,
                            0 AS inprogress,
                            0 AS ahead,
                            0 AS onschedule,
                            0 AS totalmilestones,                
                            0 AS totalcompleted,
                            p.actual_hours AS actual,
                            p.etc_hours AS remaining,
                            p.actual_hours + p.etc_hours AS totalhours
                      FROM  nbi_project_current_facts p,
                            nbi_dim_obs o
                     WHERE  p.project_id IN (
                                            SELECT  t.prprojectid
                                              FROM  niku.prtask t
                                             WHERE  t.prismilestone = 1
                                               AND  t.priskey = 1
                                               AND  t.prbasefinish IS NOT NULL
                                            )
                       AND  p.obs1_unit_id = o.obs_unit_id
                       AND (   (nOBSLevel = 1 AND o.level1_unit_id = nOBSUnit)
                            OR (nOBSLevel = 2 AND o.level2_unit_id = nOBSUnit)
                            OR (nOBSLevel = 3 AND o.level3_unit_id = nOBSUnit)
                            OR (nOBSLevel = 4 AND o.level4_unit_id = nOBSUnit)
                            OR (nOBSLevel = 5 AND o.level5_unit_id = nOBSUnit)
                            OR (nOBSLevel = 6 AND o.level6_unit_id = nOBSUnit)
                            OR (nOBSLevel = 7 AND o.level7_unit_id = nOBSUnit)
                            OR (nOBSLevel = 8 AND o.level8_unit_id = nOBSUnit)
                            OR (nOBSLevel = 9 AND o.level9_unit_id = nOBSUnit)
                            OR (nOBSLevel = 10 AND o.level10_unit_id = nOBSUnit)
                           )

                     UNION
                    SELECT  p.project_name,
                            SUM(CASE WHEN t.prbasefinish < TRUNC(SYSDATE()) AND t.prstatus <> 2 -- Completed
                                     THEN 1
                                     ELSE 0
                                END) AS missed,
                            SUM(CASE WHEN t.prstatus = 0 -- NotStarted
                                     THEN 1
                                     ELSE 0
                                END) AS notstarted,
                            SUM(CASE WHEN t.prstatus = 1 -- Started
                                     THEN 1
                                     ELSE 0
                                END) AS inprogress,
                            SUM(CASE WHEN t.prbasefinish > TRUNC(SYSDATE()) AND t.prstatus = 2 -- Completed
                                     THEN 1
                                     ELSE 0
                                END) AS ahead,
                            SUM(CASE WHEN t.prbasefinish <= TRUNC(SYSDATE()) AND t.prstatus = 2 -- Completed
                                     THEN 1
                                     ELSE 0
                                END) AS onschedule,
                            COUNT(t.prid) AS totalmilestones,                
                            SUM(CASE WHEN t.prstatus = 2 -- Completed
                                     THEN 1
                                     ELSE 0
                                END) AS totalcompleted,
                            0 AS actual,
                            0 AS remaining,
                            0 AS totalhours
                      FROM  prtask t,
                            nbi_project_current_facts p,
                            nbi_dim_obs o
                     WHERE  t.prprojectid = p.project_id
                       AND  t.prismilestone = 1
                       AND  t.priskey = 1
                       AND  t.prbasefinish IS NOT NULL
                       AND  p.obs1_unit_id = o.obs_unit_id
                       AND (   (nOBSLevel = 1 AND o.level1_unit_id = nOBSUnit)
                            OR (nOBSLevel = 2 AND o.level2_unit_id = nOBSUnit)
                            OR (nOBSLevel = 3 AND o.level3_unit_id = nOBSUnit)
                            OR (nOBSLevel = 4 AND o.level4_unit_id = nOBSUnit)
                            OR (nOBSLevel = 5 AND o.level5_unit_id = nOBSUnit)
                            OR (nOBSLevel = 6 AND o.level6_unit_id = nOBSUnit)
                            OR (nOBSLevel = 7 AND o.level7_unit_id = nOBSUnit)
                            OR (nOBSLevel = 8 AND o.level8_unit_id = nOBSUnit)
                            OR (nOBSLevel = 9 AND o.level9_unit_id = nOBSUnit)
                            OR (nOBSLevel = 10 AND o.level10_unit_id = nOBSUnit)
                           )
                  GROUP BY  p.project_name
                    )
          GROUP BY  project_name;
      END IF;
           
END TRG_RPT_NR01_SP;
/
