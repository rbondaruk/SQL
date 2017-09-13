select a.prexternalid, a.prname, c.name, a.prstart, a.prfinish
  from prtask a, prj_projects b, srm_projects c, prtask z
 where a.prprojectid <> 5050297
   and a.prprojectid IN (5049306,5049307,5049308)
   and a.prprojectid = b.prid
   and b.prid = c.id
   and a.prexternalid = z.prexternalid
--   and a.prname = z.prname
--   and a.prwbssequence = z.prwbssequence
   and z.prprojectid = 5050297
   and z.prexternalid IS NOT NULL
order by z.prwbssequence, a.prstart, a.prfinish

