select b.first_name || ' ' || b.last_name, 
       b.last_name, b.first_name, b.unique_name
  from prj_resources a, srm_resources b
 where a.prid = b.id
   and a.prisrole = 0
   and b.is_active = 1
