SELECT project_name,
       niku_id,
       rnumber,
       first_name,
       last_name,
       hours
FROM
(
      -- Get posted time entries
      SELECT h.name AS project_name,
             h.unique_name AS niku_id,
             d.unique_name AS rnumber,                       
             d.first_name AS first_name, 
             d.last_name AS last_name,  
             SUM(s.slice) AS hours
        FROM PRTimePeriod a, 
             PRTimeSheet b, 
             PRTimeEntry c, 
             srm_resources d, 
             PRAssignment f, 
             PRTask g,                          
             srm_projects h, 
             prj_blb_slices s, 
             prj_blb_slicerequests sr
       WHERE a.prID = b.prTimePeriodID
         AND b.prID = c.prTimeSheetID
         AND b.prResourceID = d.id
         AND d.resource_type = 0
         AND c.prAssignmentID = f.prID
         AND f.prTaskID = g.prID
         AND g.prProjectID = h.id
         AND f.prID = s.prj_object_id
         AND s.slice_request_id = sr.id
         AND sr.request_name = 'DAILYRESOURCEACTCURVE'
         AND TRUNC(s.slice_date) BETWEEN (TO_DATE('5/22/2004','MM/DD/YYYY') - 14) AND TO_DATE('5/22/2004','MM/DD/YYYY')
         AND s.slice > 0
         AND b.prStatus = 4
         AND a.prID = 5000011
    GROUP BY h.name,
             h.unique_name,
             d.unique_name,                       
             d.first_name, 
             d.last_name

       UNION

      -- Get indirect time entries (Vacation, Sick, etc.)
      SELECT f.prName AS project_name,
             '' AS niku_id,
             d.unique_name AS rnumber,
             d.first_name AS first_name,
             d.last_name AS last_name,
             SUM(c.prActSum/3600) AS hours
        FROM PRTimePeriod a,
             PRTimeSheet b,
             PRTimeEntry c,
             srm_resources d,
             PRChargeCode f
       WHERE a.prID = b.prTimePeriodID
         AND b.prID = c.prTimeSheetID
         AND b.prResourceID = d.id
         AND d.resource_type = 0
         AND c.prChargeCodeID = f.prID
         AND c.prChargeCodeID IS NOT NULL
         AND c.prassignmentid IS NULL
         AND c.prActSum > 0
         AND a.prID = 5000011
    GROUP BY f.prName,
             d.unique_name,
             d.first_name,
             d.last_name
)
ORDER BY last_name,
         first_name,
         niku_id


