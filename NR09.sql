  SELECT  end_date,
          SUM(completed) as completed,
          SUM(planned) as planned,
          SUM(total_completed) as total_completed,
          SUM(total_planned) as total_planned
    FROM  (
          SELECT  rd.end_date,
                  SUM(CASE WHEN t.prstatus = 2 -- Completed
                           THEN 1
                           ELSE 0
                      END) as completed,
                  COUNT(*) as planned,
                  0 as total_completed,
                  0 as total_planned
            FROM  niku.prtask t, r608358.trg_reporting_dates rd
           WHERE  t.prismilestone = 1
             AND  t.priskey = 1
             AND  t.prbasefinish IS NOT NULL
             AND  t.prbasefinish > rd.begin_date
             AND  t.prbasefinish <= rd.end_date
             AND  rd.period = 'WEEK'
        GROUP BY  rd.end_date

           UNION
   
          SELECT  rd.end_date,
                  0 as completed,
                  0 as planned,
                  SUM(CASE WHEN t.prstatus = 2 -- Completed
                           THEN 1
                           ELSE 0
                      END) as total_completed,
                  COUNT(*) as total_planned
            FROM  niku.prtask t, r608358.trg_reporting_dates rd
           WHERE  t.prismilestone = 1
             AND  t.priskey = 1
             AND  t.prbasefinish IS NOT NULL
             AND  t.prbasefinish <= rd.end_date
             AND  rd.period = 'WEEK'
        GROUP BY  rd.end_date

           UNION
   
          SELECT  rd.end_date,
                  0 as completed,
                  0 as planned,
                  0 as total_completed,
                  0 as total_planned
            FROM  r608358.trg_reporting_dates rd
           WHERE  rd.period = 'WEEK'
          )
GROUP BY  end_date
