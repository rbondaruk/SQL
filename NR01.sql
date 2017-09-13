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
                   AND  o.path = 'ALL/All Programs & Projects/Approved Programs & Projects/Program Manager 2 - Mark Pirkle/Regence Facets'
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
                 WHERE  t.prprojectid = p.project_id
                   AND  t.prismilestone = 1
                   AND  t.priskey = 1
                   AND  t.prbasefinish IS NOT NULL
                   AND  p.obs1_unit_id = o.obs_unit_id
                   AND  o.path = 'ALL/All Programs & Projects/Approved Programs & Projects/Program Manager 2 - Mark Pirkle/Regence Facets'
              GROUP BY  p.project_name
                )
      GROUP BY  project_name;

