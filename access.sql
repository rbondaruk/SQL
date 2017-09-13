INSERT INTO FINANCE (
ProjectFileName,
Task,
Resource,
Group_Company,
WBS,
RateSched,
Backfill,
Month,
Year,
MonthHours)
SELECT
a.File_Name,
a.Task_Name,
a.Resource_Name,
a.Resource_Group,
a.WBS,
a.Rate_Schedule,
a.Backfill,
b.Month,
b.Year,
a.Scheduled_Work
FROM
Dates AS b,
Assignment_Table AS a,
task_business_days AS c
WHERE IIf(a.Start_Date<b.StartDate,b.StartDate,a.Start_Date)<IIf(a.Finish_Date>b.FinishDate,b.FinishDate,a.Finish_Date)
AND a.ID=c.ID
AND c.SumBusinessDays > 0
;

--ROUND(((((DateDiff("d",IIf(a.Start_Date<b.StartDate,b.StartDate,a.Start_Date),IIf(a.Finish_Date>b.FinishDate,b.FinishDate,a.Finish_Date))+1)/b.MonthDays)*b.NumberBusinessDays)/c.SumBusinessDays)*CDbl(a.Scheduled_Work),2) AS MonthHours,


--ROUND(((DateDiff("d",IIf(a.Start_Date<b.StartDate,b.StartDate,a.Start_Date),IIf(a.Finish_Date>b.FinishDate,b.FinishDate,a.Finish_Date))+1)/c.TaskDays)*CDbl(Mid(a.Scheduled_Work,1,(Instr(1,a.Scheduled_Work," hrs")-1)))*(CDbl(Left(a.Units,Len(a.Units)-1))/100)) AS PeriodHours,

DateDiff("d",IIf(a.Start_Date<b.StartDate,b.StartDate,a.Start_Date),IIf(a.Finish_Date>b.FinishDate,b.FinishDate,a.Finish_Date))+1 AS Days,
(DateDiff("d",IIf(a.Start_Date<b.StartDate,b.StartDate,a.Start_Date),IIf(a.Finish_Date>b.FinishDate,b.FinishDate,a.Finish_Date))+1)/b.MonthDays AS MonthPercent,
((DateDiff("d",IIf(a.Start_Date<b.StartDate,b.StartDate,a.Start_Date),IIf(a.Finish_Date>b.FinishDate,b.FinishDate,a.Finish_Date))+1)/b.MonthDays)*b.NumberBusinessDays AS CalculatedNumberBusinessDays,
(((DateDiff("d",IIf(a.Start_Date<b.StartDate,b.StartDate,a.Start_Date),IIf(a.Finish_Date>b.FinishDate,b.FinishDate,a.Finish_Date))+1)/b.MonthDays)*b.NumberBusinessDays)/c.SumBusinessDays AS PercentBusinessDays,
