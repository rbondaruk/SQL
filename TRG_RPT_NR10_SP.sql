CREATE OR REPLACE PROCEDURE TRG_RPT_NR10_SP(
    a_cursor IN OUT TYPES.cursorType
)

IS

BEGIN
    OPEN a_cursor FOR
        SELECT  display_month,
                SUM(open_incidents) as open_incidents,
                SUM(planned_milestones) as planned_milestones,
                SUM(completed_milestones) as completed_milestones,
                MAX(percent_planned) as percent_planned,
                MAX(percent_completed) percent_completed
          FROM  TRG_RPT_NR09_10
      GROUP BY  display_month;
      
END TRG_RPT_NR10_SP;
/
