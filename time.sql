/*
select * from (
  select a.resource_code,
         a.last_name,
         a.first_name,
         sum(a.actual_hours) AS actual_hours
    from niku.NBI_RESOURCE_TIME_FACTS a
   where a.is_role = 0
     and a.calendar_time_key IN (SELECT DISTINCT b.month_key
                                   FROM niku.NBI_DIM_CALENDAR_TIME b
                                  WHERE b.day BETWEEN TO_DATE('10/30/2004','MM/DD/YYYY') AND TO_DATE('11/06/2004','MM/DD/YYYY'))
group by a.resource_code,
         a.last_name,
         a.first_name
)
where actual_hours > 0
*/

select * from PRTimePeriod

--posted time entries
SELECT a.prStart, a.prFinish, b.prResourceID, b.prStatus, s.slice hours, d.first_name, d.last_name,  d.unique_name,                       
       g.prName task_name, h.name project_name, '' CCDescription, 0 is_indirect, e.last_name manager_last_name,            
       e.first_name manager_first_name, d.manager_id, TRUNC(s.slice_date) slice_date, 'OBS_NAME' obs_name                         
FROM   PRTimePeriod a,
       PRTimeSheet b,
       PRTimeEntry c,
       srm_resources d,
       cmn_sec_users e,
       PRAssignment f,
       PRTask g,
       srm_projects h,
       prj_blb_slices s,
       prj_blb_slicerequests sr
 WHERE a.prID = b.prTimePeriodID
   AND b.prID = c.prTimeSheetID
   AND b.prResourceID = d.id
   AND d.manager_id = e.id(+)
   AND d.resource_type = 0
   AND c.prAssignmentID = f.prID
   AND f.prTaskID = g.prID
   AND g.prProjectID = h.id
   AND f.prID = s.prj_object_id
   AND s.slice_request_id = sr.id
   AND sr.request_name = 'DAILYRESOURCEACTCURVE'
   AND TRUNC(s.slice_date) BETWEEN TRUNC(a.prStart) AND TRUNC(a.prFinish - 1)
   AND b.prStatus = 4 -- means posted
   AND a.prID = 5000113 -- this is the week starting 10/30/04 and ending 11/6/04


--Get unposted time entries
--UNION 
SELECT prstatus,
       COUNT(prstatus)
  FROM (
SELECT a.prStart, a.prFinish, b.prResourceID, b.prStatus, (c.prActSum/3600) hours, d.first_name, d.last_name, 
       d.unique_name, g.prName task_name, h.name project_name, '' CCDescription, 0 is_indirect, 
       e.last_name manager_last_name, e.first_name manager_first_name, d.manager_id, TRUNC(SysDate) slice_date
  FROM PRTimePeriod a,
       PRTimeSheet b,
       PRTimeEntry c,
       srm_resources d,
       cmn_sec_users e,
       PRAssignment f,
       PRTask g,
       srm_projects h
 WHERE a.prID = b.prTimePeriodID
   AND b.prID = c.prTimeSheetID 
   AND b.prResourceID = d.id 
   AND d.manager_id = e.id (+) 
   AND c.prAssignmentID = f.prID
   AND f.prTaskID = g.prID
   AND g.prProjectID = h.id
   AND b.prStatus <= 3
   AND a.prID = 5000113 -- this is the week starting 10/30/04 and ending 11/6/04
   AND (c.prActSum/3600) > 0
)
GROUP BY prstatus
--Get indirect time entries (Vacation, Sick, etc.)
--UNION
SELECT a.prStart, a.prFinish, b.prResourceID, b.prStatus, (c.prActSum/3600) hours, d.first_name, d.last_name,
       d.unique_name, '' task_name, '' project_name, f.prName CCDescription, 1 is_indirect,
       e.last_name manager_last_name, e.first_name manager_first_name, d.manager_id, TRUNC(SysDate) slice_date
  FROM PRTimePeriod a,
       PRTimeSheet b,
       PRTimeEntry c,
       srm_resources d,
       cmn_sec_users e,
       PRChargeCode f
 WHERE a.prID = b.prTimePeriodID
   AND b.prID = c.prTimeSheetID
   AND b.prResourceID = d.id
   AND d.manager_id = e.id (+)
   AND d.resource_type = 0
   AND c.prChargeCodeID = f.prID
   AND c.prChargeCodeID IS NOT NULL
   AND c.prassignmentid IS NULL
   AND a.prID = 5000113 -- this is the week starting 10/30/04 and ending 11/6/04


