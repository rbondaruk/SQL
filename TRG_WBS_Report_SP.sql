CREATE OR REPLACE PROCEDURE TRG_WBS_Report_SP (
   a_cursor        IN OUT TYPES.cursorType
)

IS
    
BEGIN
    OPEN a_cursor FOR
        select z.prwbssequence,
               a.prexternalid,
               a.prname,
               c.name,
               TO_CHAR(a.prstart,'MM/DD/YYYY') as pstart,
               TO_CHAR(a.prfinish,'MM/DD/YYYY') as pfinish
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
        order by z.prwbssequence,
                 a.prstart,
                 a.prfinish;

END TRG_WBS_Report_SP;
/
