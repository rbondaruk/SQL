select f.name as projectname, f.unique_name as projectcode, f.is_active, d.prname as taskname, b.last_name as role
from PRJ_RESOURCES a, SRM_RESOURCES b, prassignment c, prtask d, prj_projects e, srm_projects f
where a.prisrole = 1
and a.prid = b.id
and b.last_name like 'IBM%'
and b.id = c.prresourceid
and c.prtaskid = d.prid
and d.prprojectid = e.prid
and e.prid = f.id
