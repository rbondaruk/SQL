        SELECT  TO_CHAR(end_date,'fmMM/DD/YYYY') AS display_date,
                milestone_type,
                SUM(milestone_count) AS milestone_count
          FROM  (
                 SELECT  rd.end_date,
                         'Completed' AS milestone_type,
                         COUNT(*) AS milestone_count
                   FROM  niku.prtask t, trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish > rd.begin_date
                    AND  t.prbasefinish <= rd.end_date
                    AND  t.prstatus = 2
                    AND  rd.period = 'WEEK'
               GROUP BY  rd.end_date,
                         'Completed'
                  UNION
                 SELECT  rd.end_date,
                         'Planned' AS milestone_type,
                         COUNT(*) AS milestone_count
                   FROM  niku.prtask t, trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish > rd.begin_date
                    AND  t.prbasefinish <= rd.end_date
                    AND  t.prstatus <> 2
                    AND  rd.period = 'WEEK'
               GROUP BY  rd.end_date,
                         'Planned'
                  UNION
                 SELECT  rd.end_date,
                         'Completed' AS milestone_type,
                         0 AS milestone_count
                   FROM  trg_reporting_dates rd
                  WHERE  rd.period = 'WEEK'
                  UNION
                 SELECT  rd.end_date,
                         'Planned' AS milestone_type,
                         0 AS milestone_count
                   FROM  trg_reporting_dates rd
                  WHERE  rd.period = 'WEEK'
                )
      GROUP BY  end_date,
                milestone_type
      ORDER BY  end_date,
                milestone_type DESC;


/*
        SELECT  end_date,
                SUM(completed) AS completed,
                SUM(planned) AS planned,
                SUM(total_completed) AS total_completed,
                SUM(total_planned) AS total_planned
          FROM  (
                 SELECT  rd.end_date,
                         SUM(CASE WHEN t.prstatus = 2 -- Completed
                                  THEN 1
                                  ELSE 0
                             END) AS completed,
                         COUNT(*) AS planned,
                         0 as total_completed,
                         0 as total_planned
                   FROM  niku.prtask t, trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish > rd.begin_date
                    AND  t.prbasefinish <= rd.end_date
                    AND  rd.period = 'WEEK'
               GROUP BY  rd.end_date
                  UNION
                 SELECT  rd.end_date,
                         0 AS completed,
                         0 AS planned,
                         SUM(CASE WHEN t.prstatus = 2 -- Completed
                                  THEN 1
                                   ELSE 0
                             END) AS total_completed,
                         COUNT(*) AS total_planned
                   FROM  niku.prtask t, trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish <= rd.end_date
                    AND  rd.period = 'WEEK'
               GROUP BY  rd.end_date
                  UNION
                 SELECT  rd.end_date,
                         0 AS completed,
                         0 AS planned,
                         0 AS total_completed,
                         0 AS total_planned
                   FROM  trg_reporting_dates rd
                  WHERE  rd.period = 'WEEK'
                )
      GROUP BY  end_date

  */
