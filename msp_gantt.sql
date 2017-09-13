select q.Text10, q.Outline_Level, q.Name, q.Start_Date, q.Finish_Date
from (
        select z.prwbssequence,
               '' AS Text10,
               CASE WHEN INSTR(a.prexternalid,'.',1,3) > 0
                    THEN 4
                    WHEN INSTR(a.prexternalid,'.',1,2) > 0
                    THEN 3
                    WHEN INSTR(a.prexternalid,'.',1,1) > 0
                    THEN 2
               END Outline_Level,
               c.name Name,
               TO_CHAR(a.prstart,'MM/DD/YYYY') as Start_Date,
               TO_CHAR(a.prfinish,'MM/DD/YYYY') as Finish_Date
          from prtask a,
               prj_projects b,
               srm_projects c,
               prtask z
         where a.prprojectid <> 5050297
           and a.prprojectid IN (5049306,5049307,5049308)
           and a.prprojectid = b.prid
           and b.prid = c.id
           and a.prexternalid = z.prexternalid
           and z.prprojectid = 5050297
           and z.prexternalid IS NOT NULL

UNION

        select x.prwbssequence,
               x.prexternalid AS Text10,
               CASE WHEN INSTR(x.prexternalid,'.',1,3) > 0
                    THEN 3
                    WHEN INSTR(x.prexternalid,'.',1,2) > 0
                    THEN 2
                    WHEN INSTR(x.prexternalid,'.',1,1) > 0
                    THEN 1
               END Outline_Level,
               x.prname Name,
               NULL as Start_Date,
               NULL as Finish_Date
          from prtask x
         where x.prprojectid = 5050297
           and x.prexternalid IS NOT NULL
) q
order by q.prwbssequence, q.Text10, q.Outline_Level, q.Start_Date, q.Finish_Date
