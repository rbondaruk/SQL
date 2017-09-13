SELECT SUM(a.hours)
  FROM (
SELECT a.prStart,
       a.prFinish,
       b.prResourceID,
       b.prStatus,
       s.slice hours,
       d.first_name,
       d.last_name, 
       d.unique_name,                       
       g.prName task_name,
       h.name project_name,
       '' CCDescription,
       0 is_indirect,
       e.last_name manager_last_name,            
       e.first_name manager_first_name,
       d.manager_id,
       TRUNC(s.slice_date) slice_date,
       o.level2_name obs_name                         
FROM   PRTimePeriod a,
       PRTimeSheet b,
       PRTimeEntry c,
       srm_resources d,
       cmn_sec_users e,
       PRAssignment f,
       PRTask g,                          
       srm_projects h,
       prj_blb_slices s,
       prj_blb_slicerequests sr, 
       prj_obs_associations l, 
       nbi_dim_obs o
WHERE  a.prID = b.prTimePeriodID
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
  AND TRUNC(s.slice_date) 
  BETWEEN TRUNC(a.prStart) AND TRUNC(a.prFinish - 1)
  AND b.prStatus = 4
  AND b.prResourceID = l.record_id
  AND l.unit_id = o.obs_unit_id
  AND l.table_name = 'SRM_RESOURCES'
  AND o.level2_unit_id = 5000018
/*--	'Get unposted time entries
UNION SELECT 
    a.prStart,
    a.prFinish,
    b.prResourceID, 
    b.prStatus, 
    (c.prActSum/3600) hours, 
    d.first_name, 
    d.last_name, 
    d.unique_name,
    g.prName task_name, 
    h.name project_name, 
    '' CCDescription, 
    0 is_indirect,
    e.last_name manager_last_name,
    e.first_name manager_first_name,
    d.manager_id,
    TRUNC(SysDate) slice_date, 
       o.level2_name obs_name                         
FROM PRTimePeriod a,
     PRTimeSheet b,
     PRTimeEntry c, 
     srm_resources d, 
     cmn_sec_users e, 
     PRAssignment f, 
     PRTask g, 
     srm_projects h, 
     prj_obs_associations l, 
     nbi_dim_obs o
WHERE a.prID = b.prTimePeriodID 
  AND b.prID = c.prTimeSheetID 
  AND b.prResourceID = d.id 
  AND d.manager_id = e.id (+) 
  AND c.prAssignmentID = f.prID 
  AND f.prTaskID = g.prID 
  AND g.prProjectID = h.id 
  AND b.prStatus <= 3
  AND b.prResourceID = l.record_id
  AND l.unit_id = o.obs_unit_id
  AND l.table_name = 'SRM_RESOURCES'
  AND o.level2_unit_id = 5000018
--	' Get indirect time entries (Vacation, Sick, etc.)

UNION SELECT 
    a.prStart, 
    a.prFinish,
    b.prResourceID, 
    b.prStatus, 
    (c.prActSum/3600) hours, 
    d.first_name, 
    d.last_name, 
    d.unique_name,
    '' task_name,
    '' project_name, 
    f.prName CCDescription, 
    1 is_indirect,
    e.last_name manager_last_name, 
    e.first_name manager_first_name, 
    d.manager_id,
    TRUNC(SysDate) slice_date,
       o.level2_name obs_name                         
FROM PRTimePeriod a, 
     PRTimeSheet b,
     PRTimeEntry c,
     srm_resources d,
     cmn_sec_users e,
     PRChargeCode f, 
     prj_obs_associations l, 
     nbi_dim_obs o
WHERE a.prID = b.prTimePeriodID
  AND b.prID = c.prTimeSheetID 
  AND b.prResourceID = d.id 
  AND d.manager_id = e.id (+) 
  AND d.resource_type = 0 
  AND c.prChargeCodeID = f.prID 
  AND c.prChargeCodeID IS NOT NULL 
  AND c.prassignmentid IS NULL
  AND b.prResourceID = l.record_id
  AND l.unit_id = o.obs_unit_id
  AND l.table_name = 'SRM_RESOURCES'
  AND o.level2_unit_id = 5000018
*/
) a
WHERE a.prstart > TRUNC(TO_DATE('01/01/2005', 'MM/DD/YYYY'))
  AND a.prfinish < TRUNC(TO_DATE('02/16/2005', 'MM/DD/YYYY'))

