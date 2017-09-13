select f.name, f.unique_name, b.prname, b.prstart, b.prfinish, b.prwbssequence, DECODE(b.prstatus,0,'Not Started',1,'Started',2,'Completed') status,
       g.name, g.unique_name, c.prname, c.prstart, c.prfinish, c.prwbssequence, DECODE(c.prstatus,0,'Not Started',1,'Started',2,'Completed') status_1,
       TRUNC(c.prfinish) - TRUNC(b.prfinish) taskdatedifference
  from prdependency a, prtask b, prtask c, prj_projects d, prj_projects e, srm_projects f, srm_projects g
 where a.prpredtaskid = b.prid
   and b.prprojectid = d.prid
   and d.prid = f.id
   and a.prsucctaskid = c.prid
   and c.prprojectid = e.prid
   and e.prid = g.id
--   and f.unique_name = 'P0400127 R_ARCH'
   and d.prid <> e.prid
   and b.prstatus <> 2
   and c.prstatus <> 2
   and f.id in (
    select d.prrefprojectid
    from prsubproject d
    where d.prtaskid in (
        select c.prid
        from prtask c
        where c.prprojectid in (
            select id 
            from srm_projects a, prj_projects b
            where lower(a.name) = 'cpss program'
            and a.id = b.prid
        )
    )
)
