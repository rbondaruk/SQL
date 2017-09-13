select z.* 
from (

-- Get posted time entries
SELECT a.prStart, a.prFinish, b.prResourceID, b.prStatus, s.slice hours, d.first_name, d.last_name,  d.unique_name,                       
g.prName task_name, h.name project_name, '' CCDescription, 0 is_indirect, e.last_name manager_last_name,            
e.first_name manager_first_name, d.manager_id, TRUNC(s.slice_date) slice_date                     

FROM   PRTimePeriod a, PRTimeSheet b, PRTimeEntry c, srm_resources d, cmn_sec_users e, PRAssignment f, PRTask g,                          
srm_projects h, prj_blb_slices s, prj_blb_slicerequests sr

WHERE  a.prID = b.prTimePeriodID AND b.prID = c.prTimeSheetID AND b.prResourceID = d.id AND
d.manager_id = e.id(+) AND d.resource_type = 0 AND c.prAssignmentID = f.prID AND f.prTaskID = g.prID AND g.prProjectID = h.id AND f.prID = s.prj_object_id AND
s.slice_request_id = sr.id AND sr.request_name = 'DAILYRESOURCEACTCURVE' AND
TRUNC(s.slice_date) BETWEEN TRUNC(a.prStart) AND TRUNC(a.prFinish - 1)
AND b.prStatus = 4

-- Get unposted time entries
UNION 
SELECT a.prStart, a.prFinish,
b.prResourceID, b.prStatus, (c.prActSum/3600) hours, d.first_name, d.last_name, d.unique_name,
g.prName task_name, h.name project_name, '' CCDescription, 0 is_indirect,
e.last_name manager_last_name, e.first_name manager_first_name, d.manager_id,
TRUNC(SysDate) slice_date

FROM PRTimePeriod a, PRTimeSheet b,
PRTimeEntry c, srm_resources d, cmn_sec_users e, PRAssignment f, PRTask g, srm_projects h

WHERE a.prID = b.prTimePeriodID AND
b.prID = c.prTimeSheetID AND b.prResourceID = d.id AND d.manager_id = e.id (+) AND
c.prAssignmentID = f.prID AND f.prTaskID = g.prID AND
g.prProjectID = h.id AND b.prStatus <= 3

-- Get indirect time entries (Vacation, Sick, etc.)
UNION 
SELECT a.prStart, a.prFinish,
b.prResourceID, b.prStatus, (c.prActSum/3600) hours, d.first_name, d.last_name, d.unique_name,
'' task_name,'' project_name, f.prName CCDescription, 1 is_indirect,
e.last_name manager_last_name, e.first_name manager_first_name, d.manager_id,
TRUNC(SysDate) slice_date

FROM PRTimePeriod a, PRTimeSheet b,
PRTimeEntry c, srm_resources d, cmn_sec_users e, PRChargeCode f

WHERE a.prID = b.prTimePeriodID AND
b.prID = c.prTimeSheetID AND b.prResourceID = d.id AND d.manager_id = e.id (+) AND d.resource_type = 0 AND
c.prChargeCodeID = f.prID AND c.prChargeCodeID IS NOT NULL AND
c.prassignmentid IS NULL
) z
WHERE z.prstart > TRUNC(TO_DATE('04/01/2005','MM/DD/YYYY'))
--and z.prResourceID = 5004285


/*
SELECT a.prStart, a.prFinish, b.prResourceID, b.prStatus, s.slice hours, d.first_name, d.last_name,  d.unique_name,                       
g.prName task_name, h.name project_name, '' CCDescription, 0 is_indirect, e.last_name manager_last_name,            
e.first_name manager_first_name, d.manager_id, TRUNC(s.slice_date) slice_date, 'OBS_NAME' obs_name                         
FROM   PRTimePeriod a, PRTimeSheet b, PRTimeEntry c, srm_resources d, cmn_sec_users e, PRAssignment f, PRTask g,                          
srm_projects h, prj_blb_slices s, prj_blb_slicerequests sr

Function ObtainSelectStatement( ) As String
    Dim extraWhere As String
    Dim filler As String
	Dim securitySelect As String

    NewReportApp::gUnSubmitted = TranslateValue("UnsubmittedKey")
    NewReportApp::gSubmitted = TranslateValue("SubmittedKey")
    NewReportApp::gRejected = TranslateValue("RejectedKey")
    NewReportApp::gApproved = TranslateValue("ApprovedKey")
    NewReportApp::gPosted = TranslateValue("PostedKey")
    NewReportApp::gAdjusted = TranslateValue("AdjustedKey")
    NewReportApp::gStatus = GetLookupCode(NikuSequential::db_type,NewReportApp::param_status)

    If NikuSequential::param_obs_unit <> 0 Then
      SelectStatement = SelectStatement & ", prj_obs_associations l, nbi_dim_obs o "
    End If

    SelectStatement = SelectStatement & " WHERE  a.prID = b.prTimePeriodID AND b.prID = c.prTimeSheetID AND b.prResourceID = d.id AND " &
+ "d.manager_id = e.id(+) AND d.resource_type = 0 AND c.prAssignmentID = f.prID AND f.prTaskID = g.prID AND g.prProjectID = h.id AND f.prID = s.prj_object_id AND " &
+ "s.slice_request_id = sr.id AND sr.request_name = 'DAILYRESOURCEACTCURVE' AND " &
+ "TRUNC(s.slice_date) BETWEEN TRUNC(a.prStart) AND TRUNC(a.prFinish - 1) " &
+ "AND b.prStatus = 4 "

    extraWhere = Null
    If NewReportApp::param_time_period <> 0 Then
        extraWhere = extraWhere &
+                    " AND a.prID = " & NewReportApp::param_time_period
    End If
    If NewReportApp::param_manager <> 0 Then
        extraWhere = extraWhere &
+                    " AND d.manager_id = " & NewReportApp::param_manager
    End If
    If NewReportApp::param_status <> 0 Then
        extraWhere = extraWhere &
+                    " AND b.prStatus = " & NewReportApp::gStatus
    End If
    If NikuSequential::param_obs_unit <> 0 Then
        extraWhere = extraWhere & " AND b.prResourceID = l.record_id AND " &
+                    "l.unit_id = o.obs_unit_id AND l.table_name = 'SRM_RESOURCES'"
        Select Case obs_level
            Case 1
                filler = "o.level1_name obs_name"
                extraWhere = extraWhere &
+                            " AND o.level1_unit_id = " & NikuSequential::param_obs_unit
            Case 2
                filler = "o.level2_name obs_name"
                extraWhere = extraWhere &
+                            " AND o.level2_unit_id = " & NikuSequential::param_obs_unit
            Case 3
                filler = "o.level3_name obs_name"
                extraWhere = extraWhere &
+                            " AND o.level3_unit_id = " & NikuSequential::param_obs_unit
            Case 4
                filler = "o.level4_name obs_name"
                extraWhere = extraWhere &
+                            " AND o.level4_unit_id = " & NikuSequential::param_obs_unit
            Case 5
                filler = "o.level5_name obs_name"
                extraWhere = extraWhere &
+                            " AND o.level5_unit_id = " & NikuSequential::param_obs_unit
            Case 6
                filler = "o.level6_name obs_name"
                extraWhere = extraWhere &
+                            " AND o.level6_unit_id = " & NikuSequential::param_obs_unit
            Case 7
                filler = "o.level7_name obs_name"
                extraWhere = extraWhere &
+                            " AND o.level7_unit_id = " & NikuSequential::param_obs_unit
            Case 8
                filler = "o.level8_name obs_name"
                extraWhere = extraWhere &
+                            " AND o.level8_unit_id = " & NikuSequential::param_obs_unit
            Case 9
                filler = "o.level9_name obs_name"
                extraWhere = extraWhere &
+                            " AND o.level9_unit_id = " & NikuSequential::param_obs_unit
            Case 10 
                filler = "o.level10_name obs_name"
                extraWhere = extraWhere &
+                            " AND o.level10_unit_id = " & NikuSequential::param_obs_unit
        End Select
        SelectStatement = ReplaceString( SelectStatement, "'OBS_NAME' obs_name", filler)
        SelectStatement = Mid(SelectStatement,1,InStr(SelectStatement, "WHERE") - 2) &
+           Mid(SelectStatement, InStr(SelectStatement, "WHERE"))
    Else
        filler = "'OBS_NAME' obs_name"
    End If


	securitySelect = GetSecurityJoinCondition( 1, "d.id", NikuSequential::UserID, "SEC_OBJECT_TYPE", NikuSequential::ObjectType,  NikuSequential::ComponentCode, NikuSequential::ObjectCode, NikuSequential::PermissionCode )
	extraWhere = extraWhere & securitySelect

	NikuSequential::ObjectCode = "PRJ_PROJECT"
    NikuSequential::PermissionCode = "ProjectViewManagement','ProjectEditManagement','ProjectViewTasks"
	securitySelect = GetSecurityJoinCondition( 1, "h.id", NikuSequential::UserID, "SEC_OBJECT_TYPE", NikuSequential::ObjectType,  NikuSequential::ComponentCode, NikuSequential::ObjectCode, NikuSequential::PermissionCode )
    SelectStatement = SelectStatement & " " & extraWhere & securitySelect

	'Get unposted time entries
    SelectStatement = SelectStatement & " UNION SELECT a.prStart, a.prFinish, " &
+       "b.prResourceID, b.prStatus, (c.prActSum/3600) hours, d.first_name, d.last_name, d.unique_name, " &
+       "g.prName task_name, h.name project_name, '' CCDescription, 0 is_indirect, " &
+       "e.last_name manager_last_name, e.first_name manager_first_name, d.manager_id, " &
+       "TRUNC(SysDate) slice_date, " & filler & " FROM PRTimePeriod a, PRTimeSheet b, " &
+       "PRTimeEntry c, srm_resources d, cmn_sec_users e, PRAssignment f, PRTask g, srm_projects h"
    If NikuSequential::param_obs_unit <> 0 Then
        SelectStatement = SelectStatement & 
+           ", prj_obs_associations l, nbi_dim_obs o"
    End If
    SelectStatement = SelectStatement & " WHERE a.prID = b.prTimePeriodID AND " &
+       "b.prID = c.prTimeSheetID AND b.prResourceID = d.id AND d.manager_id = e.id (+) AND " &
+       "c.prAssignmentID = f.prID AND f.prTaskID = g.prID AND " &
+       "g.prProjectID = h.id AND b.prStatus <= 3 " & extraWhere & " " &  securitySelect 

	' Get indirect time entries (Vacation, Sick, etc.)
	' Note there is no project involved in indirect time, so the security check should only
	' check for rights on viewing the resource (which is part of the 'extraWhere') and not include
    ' the securitySelect, which contains checks for project edit rights.  
    ' srm_projects is not needed here either.
    SelectStatement = SelectStatement & " UNION SELECT a.prStart, a.prFinish, " &
+       "b.prResourceID, b.prStatus, (c.prActSum/3600) hours, d.first_name, d.last_name, d.unique_name, " &
+       "'' task_name,'' project_name, f.prName CCDescription, 1 is_indirect, " &
+       "e.last_name manager_last_name, e.first_name manager_first_name, d.manager_id, " &
+       "TRUNC(SysDate) slice_date, " & filler & " FROM PRTimePeriod a, PRTimeSheet b, " &
+       "PRTimeEntry c, srm_resources d, cmn_sec_users e, PRChargeCode f"
    If NikuSequential::param_obs_unit <> 0 Then
        SelectStatement = SelectStatement & 
+           ", prj_obs_associations l, nbi_dim_obs o"
    End If
    SelectStatement = SelectStatement & " WHERE a.prID = b.prTimePeriodID AND " &
+       "b.prID = c.prTimeSheetID AND b.prResourceID = d.id AND d.manager_id = e.id (+) AND d.resource_type = 0 AND " &
+       "c.prChargeCodeID = f.prID AND c.prChargeCodeID IS NOT NULL AND " & 
+       "c.prassignmentid IS NULL " & extraWhere 

    ObtainSelectStatement = Super::ObtainSelectStatement( )
End Function

*/
