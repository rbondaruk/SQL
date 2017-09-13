CREATE OR REPLACE PROCEDURE TRG_RPT_NR9_SP(
    a_cursor IN OUT TYPES.cursorType
)

IS

BEGIN
    OPEN a_cursor FOR
        SELECT  display_date,
                open_incidents,
                planned_milestones,
                completed_milestones,
                percent_planned,
                percent_completed
          FROM  TRG_RPT_NR09_10
         WHERE  display_date > (SYSDATE - (13 * 7));
      
END TRG_RPT_NR9_SP;
/
