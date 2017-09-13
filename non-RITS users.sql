

select c.*,
       b.path
  from PRJ_OBS_ASSOCIATIONS a,
       NBI_DIM_OBS b,
       SRM_RESOURCES c,
       PRJ_RESOURCES d
 where a.table_name = 'SRM_RESOURCES'
   and b.obs_type_name = 'TRGOrg'
   and a.unit_id = b.obs_unit_id
   and b.level2_unit_id <> 5000018
   and a.record_id = c.id
   and NVL(c.date_of_termination,sysdate+1) > sysdate
   and c.id = d.prid
   and d.prisrole = 0
   and c.is_active = 1
order by c.last_name,
         c.first_name


