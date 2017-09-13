CREATE OR REPLACE PROCEDURE TRG_RPT_12_SP (
   enddate         IN     DATE,
   a_cursor        IN OUT TYPES.cursorType
)

IS
    
BEGIN
    OPEN a_cursor FOR
        SELECT (enddate - 14) AS start_date,
               enddate AS finish_date,
               project_name,
               niku_id,
               caporexp,
               pm_first_name,
               pm_last_name,
               rnumber,
               first_name,
               last_name,
               hours
          FROM
            (
              -- Get posted time entries
              SELECT d.first_name first_name,
                     d.last_name last_name, 
                     d.unique_name AS rnumber,                       
                     h.name AS project_name,
                     h.unique_name AS niku_id,
                     g.prshortname AS caporexp,
                     j.first_name AS pm_first_name,
                     j.last_name AS pm_last_name,
                     SUM(s.slice) AS hours
                FROM PRTimePeriod a,
                     PRTimeSheet b,
                     PRTimeEntry c,
                     srm_resources d,
                     PRAssignment f,
                     PRTask g,                          
                     srm_projects h,
                     prj_blb_slices s,
                     prj_blb_slicerequests sr,
                     prj_projects i,
                     cmn_sec_users j
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
                 AND TRUNC(s.slice_date) BETWEEN TRUNC(a.prStart) AND TRUNC(a.prFinish - 1) 
                 AND TRUNC(s.slice_date) BETWEEN (enddate - 14) AND enddate 
                 AND b.prStatus = 4
                 AND h.id = i.prid
                 AND i.manager_id = j.id
            GROUP BY d.first_name,
                     d.last_name, 
                     d.unique_name,                       
                     h.name,
                     h.unique_name,
                     g.prshortname,
                     j.first_name,
                     j.last_name

               UNION

              -- Get indirect time entries (Vacation, Sick, etc.)
              SELECT d.first_name,
                     d.last_name,
                     d.unique_name,
                     f.prName project_name,
                     '' AS niku_id,
                     '' AS caporexp,
                     '' AS pm_first_name,
                     '' AS pm_last_name,
                     SUM(c.prActSum/3600) hours
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
                 AND TRUNC(a.prStart) BETWEEN (enddate - 14) AND enddate 
                 AND TRUNC(a.prFinish) BETWEEN (enddate - 14) AND enddate 
                 AND c.prActSum > 0
            GROUP BY d.first_name,
                     d.last_name,
                     d.unique_name,
                     f.prName
            )
    ORDER BY last_name,
             first_name,
             niku_id;

END TRG_RPT_12_SP;
/
