select rcf.is_active
       ,rcf.resource_code
       ,rcf.first_name
       ,rcf.last_name 
--       ,count(rcf.resource_id)
  from NBI_RESOURCE_CURRENT_FACTS rcf
 where rcf.resource_id IN (
       SELECT rtf.resource_id
         FROM NBI_RESOURCE_TIME_FACTS rtf,
              NBI_DIM_CALENDAR_TIME dct
        where rtf.calendar_time_key = dct.time_key
          and dct.hierarchy_level = 'MONTH'
          and rtf.available_hours = 0 --between 125 and 140
          and rtf.is_role = 0)
group by rcf.is_active
         ,rcf.resource_code
         ,rcf.first_name
         ,rcf.last_name


/*
select sr.last_name,
       sr.first_name,
       bs.slice
  from PRJ_RESOURCES r
       ,SRM_RESOURCES sr
       ,PRJ_BLB_SLICES bs
       ,PRJ_BLB_SLICEREQUESTS bsr
 where r.prid = bs.prj_object_id
   and bs.slice_request_id = bsr.id
   and r.prid = sr.id
   and bs.slice = 0
   and bsr.field = 3

*/

