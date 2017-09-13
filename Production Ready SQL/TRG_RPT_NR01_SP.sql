CREATE OR REPLACE PROCEDURE trg_rpt_nr01_sp(
    a_cursor        IN OUT TYPES.cursorType,
    nOBSUnit        IN     NUMBER DEFAULT 0,
    nOBSLevel       IN     NUMBER,
    nProject        IN     NUMBER
)

IS
    xOBSUnit        NUMBER;
    xProject        NUMBER;

BEGIN
    IF nOBSUnit = 0 THEN
        xOBSUnit := NULL;
    ELSE
        xOBSUnit := nOBSUnit;
    END IF;

    IF nProject = 0 THEN
        xProject := NULL;
    ELSE
        xProject := nProject;
    END IF;

    IF nOBSUnit = 0 THEN

        OPEN a_cursor FOR
            SELECT  project_name,
                    1 AS groupby,
                    SUM(missed) AS missed,
                    SUM(notstarted) AS notstarted,
                    SUM(inprogress) AS inprogress,
                    SUM(ahead) AS ahead,
                    SUM(onschedule) AS onschedule,
                    SUM(totalmilestones) AS totalmilestones,
                    SUM(totalcompleted) AS totalcompleted,
                    CASE WHEN SUM(totalmilestones)>0
                        THEN (SUM(totalcompleted)/SUM(totalmilestones))*100
                        ELSE 0
                    END AS percentcompleted,
                    SUM(actual) AS actual,
                    SUM(remaining) AS remaining,
                    SUM(totalhours) AS totalhours,
                    CASE WHEN SUM(actual)>0
                        THEN (SUM(actual)/SUM(totalhours))*100
                        ELSE 0
                    END AS percenthours
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
                                              FROM  prtask t
                                             WHERE  t.prismilestone = 1
                                               AND  t.priskey = 1
                                               AND  t.prbasefinish IS NOT NULL
                                               AND  t.prprojectid = NVL(xProject, t.prprojectid)
                                            )
                       AND  p.is_active = 1
                     UNION
                    SELECT  p.project_name,
                            SUM(CASE WHEN t.prbasefinish < TRUNC(SYSDATE) AND t.prstatus <> 2 -- Completed
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
                            SUM(CASE WHEN t.prbasefinish > TRUNC(SYSDATE) AND t.prstatus = 2 -- Completed
                                     THEN 1
                                     ELSE 0
                                END) AS ahead,
                            SUM(CASE WHEN t.prbasefinish <= TRUNC(SYSDATE) AND t.prstatus = 2 -- Completed
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
                     WHERE  t.prprojectid = NVL(xProject, t.prprojectid)
                       AND  t.prismilestone = 1
                       AND  t.priskey = 1
                       AND  p.is_active = 1
                       AND  t.prbasefinish IS NOT NULL
                       AND  t.prprojectid = p.project_id
                  GROUP BY  p.project_name
                    )
          GROUP BY  project_name;

    ELSE

        OPEN a_cursor FOR
            SELECT  project_name,
                    1 AS groupby,
                    SUM(missed) AS missed,
                    SUM(notstarted) AS notstarted,
                    SUM(inprogress) AS inprogress,
                    SUM(ahead) AS ahead,
                    SUM(onschedule) AS onschedule,
                    SUM(totalmilestones) AS totalmilestones,
                    SUM(totalcompleted) AS totalcompleted,
                    CASE WHEN SUM(totalmilestones)>0
                        THEN (SUM(totalcompleted)/SUM(totalmilestones))*100
                        ELSE 0
                    END AS percentcompleted,
                    SUM(actual) AS actual,
                    SUM(remaining) AS remaining,
                    SUM(totalhours) AS totalhours,
                    CASE WHEN SUM(actual)>0
                        THEN (SUM(actual)/SUM(totalhours))*100
                        ELSE 0
                    END AS percenthours
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
                                              FROM  prtask t
                                             WHERE  t.prismilestone = 1
                                               AND  t.priskey = 1
                                               AND  t.prbasefinish IS NOT NULL
                                               AND  t.prprojectid = NVL(xProject, t.prprojectid)
                                            )
                       AND  p.is_active = 1
                       AND  p.obs1_unit_id = o.obs_unit_id
                       AND (   (o.level1_unit_id = xOBSUnit AND 1 = nOBSLevel)
                            OR (o.level2_unit_id = xOBSUnit AND 2 = nOBSLevel)
                            OR (o.level3_unit_id = xOBSUnit AND 3 = nOBSLevel)
                            OR (o.level4_unit_id = xOBSUnit AND 4 = nOBSLevel)
                            OR (o.level5_unit_id = xOBSUnit AND 5 = nOBSLevel)
                            OR (o.level6_unit_id = xOBSUnit AND 6 = nOBSLevel)
                            OR (o.level7_unit_id = xOBSUnit AND 7 = nOBSLevel)
                            OR (o.level8_unit_id = xOBSUnit AND 8 = nOBSLevel)
                            OR (o.level9_unit_id = xOBSUnit AND 9 = nOBSLevel)
                            OR (o.level10_unit_id = xOBSUnit AND 10 = nOBSLevel)
                           )
                     UNION
                    SELECT  p.project_name,
                            SUM(CASE WHEN t.prbasefinish < TRUNC(SYSDATE) AND t.prstatus <> 2 -- Completed
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
                            SUM(CASE WHEN t.prbasefinish > TRUNC(SYSDATE) AND t.prstatus = 2 -- Completed
                                     THEN 1
                                     ELSE 0
                                END) AS ahead,
                            SUM(CASE WHEN t.prbasefinish <= TRUNC(SYSDATE) AND t.prstatus = 2 -- Completed
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
                     WHERE  t.prprojectid = NVL(xProject, t.prprojectid)
                       AND  t.prismilestone = 1
                       AND  t.priskey = 1
                       AND  t.prbasefinish IS NOT NULL
                       AND  t.prprojectid = p.project_id
                       AND  p.is_active = 1
                       AND  p.obs1_unit_id = o.obs_unit_id
                       AND (   (o.level1_unit_id = xOBSUnit AND 1 = nOBSLevel)
                            OR (o.level2_unit_id = xOBSUnit AND 2 = nOBSLevel)
                            OR (o.level3_unit_id = xOBSUnit AND 3 = nOBSLevel)
                            OR (o.level4_unit_id = xOBSUnit AND 4 = nOBSLevel)
                            OR (o.level5_unit_id = xOBSUnit AND 5 = nOBSLevel)
                            OR (o.level6_unit_id = xOBSUnit AND 6 = nOBSLevel)
                            OR (o.level7_unit_id = xOBSUnit AND 7 = nOBSLevel)
                            OR (o.level8_unit_id = xOBSUnit AND 8 = nOBSLevel)
                            OR (o.level9_unit_id = xOBSUnit AND 9 = nOBSLevel)
                            OR (o.level10_unit_id = xOBSUnit AND 10 = nOBSLevel)
                           )
                  GROUP BY  p.project_name
                    )
          GROUP BY  project_name;

    END IF;

END TRG_RPT_NR01_SP;
/
