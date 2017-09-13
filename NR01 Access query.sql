INSERT INTO [t060-65 Key Milestone Matrix Raw Data] ( 
    prName, 
    prProgram, 
    prManager, 
    prExternalID, 
    prUserText1,
    prTrackMode, 
    prUserText2, 
    prIsOpen, 
    Task, 
    prStart, 
    prFinish, 
    prBaseStart, 
    Baseline_Finish, 
    Completed,
    AsOfDate, 
    prIsKey, 
    prIsMilestone, 
    TaskStatus)

SELECT PRProject.prName, 
       PRProject.prProgram, 
       PRProject.prManager, 
       [ts00 Task].prExternalID, 
       PRProject.prUserText1, 
       PRProject.prTrackMode, 
       PRProject.prUserText2, 
       PRProject.prIsOpen, 
       [ts00 Task].prName AS Task, 
       [ts00 Task].prStart, 
       [ts00 Task].prFinish, 
       [ts00 Task].prBaseStart, 
       [ts00 Task].prBaseFinish AS Baseline_Finish, 
       [ts00 Task].Completed, 
       [ts03 TempDates].AsOfDate, 
       [ts00 Task].prIsKey, 
       [ts00 Task].prIsMilestone, 
       [ts00 Task].TaskStatus

FROM [ts03 TempDates], 
     PRProject 

INNER JOIN [ts00 Task] ON PRProject.prID = [ts00 Task].prProjectID

WHERE PRProject.prUserText1 in ('FRII','Production')
  AND PRProject.prTrackMode=2
  AND PRProject.prUserText2='Complete' 
  AND PRProject.prIsOpen=-1 
  AND [ts00 Task].prBaseFinish Is Not Null 
  AND [ts00 Task].prIsKey=-1 
  AND [ts00 Task].prIsMilestone=-1

SELECT Raw_Data.prProgram, 
       Raw_Data.prUserText1 AS Phase, 
       Raw_Data.Task AS Task,
       Raw_Data.AsOfDate, 
       Raw_Data.Baseline_Finish,
       Raw_Data.TaskStatus,
       Raw_Data.Completed,
       IIf([Baseline_Finish]>[AsOfDate] And [TaskStatus]='Complete',1,0) AS Ahead, 
       IIf([Baseline_Finish]<[AsOfDate] And [TaskStatus]='Complete',1,0) AS OnSchedule, 
       IIf([Baseline_Finish]< [AsOfDate] And [TaskStatus]<>'Complete',1,0) AS Missed, 
       IIf([TaskStatus]='Not Started',1,0) AS NotStarted,
       IIf([TaskStatus]='Started',1,0) AS InProgress, 
       [Ahead]+[OnSchedule] AS TotalCompletedMilestones,
       1 as TotalMilestones,
       0 AS ActualHrs,
       0 AS EstimatedHrs,
       0 AS TotalHrs
  FROM [t060-65 Key Milestone Matrix Raw Data] AS Raw_Data
 WHERE Raw_Data.Baseline_Finish Is Not Null

UNION ALL

SELECT PRProject.prProgram,
       PRProject.prUserText1 AS Phase, 
       [ts00 Task].prName as Task,
       [ts03 TempDates].AsOfDate,
       [ts00 Task].prBaseFinish as Baseline_Finish,
       [ts00 Task].TaskStatus,
       [ts00 Task].Completed, 
       0 AS Ahead, 
       0 As OnSchedule, 
       0 As Missed,
       0 As NotStarted, 
       0 As InProgress, 
       0 AS TotalCompletedMilestones, 
       0 as TotalMilestones, 
       [PRAssignment].[prActSum]/3600 AS ActualHrs,
       [prEstSum])/3600 AS EstimatedHrs,
       [ActualHrs]+[EstimatedHrs] AS TotalHrs
  FROM [ts03 TempDates],
       PRProject
INNER JOIN [ts00 Task] ON PRProject.prID = [ts00 Task].prProjectID
INNER JOIN PRAssignment ON [ts00 Task].TaskID = PRAssignment.prTaskID 

 Where PRProject.prUserText1 in ('FRII', 'Production')
