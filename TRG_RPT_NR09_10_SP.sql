CREATE OR REPLACE PROCEDURE TRG_RPT_NR09_10_SP (
   P_JOB_RUN_ID    IN   NUMBER,
   P_JOB_USER_ID   IN   NUMBER
)

IS
    display_date                trg_rpt_nr09_10.display_date%TYPE;
    display_month               trg_rpt_nr09_10.display_month%TYPE;
    open_incidents              trg_rpt_nr09_10.open_incidents%TYPE;
    planned_milestones          trg_rpt_nr09_10.planned_milestones%TYPE;
    completed_milestones        trg_rpt_nr09_10.completed_milestones%TYPE;
    percent_planned             trg_rpt_nr09_10.percent_planned%TYPE;
    percent_completed           trg_rpt_nr09_10.percent_completed%TYPE;
    total_milestones            trg_rpt_nr09_10.planned_milestones%TYPE;
    total_planned_milestones    trg_rpt_nr09_10.planned_milestones%TYPE;
    total_completed_milestones  trg_rpt_nr09_10.planned_milestones%TYPE;
    
BEGIN

  SELECT TRUNC(sysdate)
    INTO display_date
    FROM dual;
    
    display_month := INITCAP(TO_CHAR(display_date,'MON'));
    
  SELECT count(*)
    INTO planned_milestones
    FROM prtask
   WHERE prismilestone = 1
     AND priskey = 1
     AND prstatus <> 2
     AND prbasefinish IS NOT NULL
     AND prbasefinish BETWEEN (display_date - 6) AND (display_date + 1);

  SELECT count(*)
    INTO completed_milestones
    FROM prtask
   WHERE prismilestone = 1
     AND priskey = 1
     AND prstatus = 2
     AND prbasefinish IS NOT NULL
     AND prbasefinish BETWEEN (display_date - 6) AND (display_date + 1);

  SELECT count(*)
    INTO total_milestones
    FROM prtask
   WHERE prismilestone = 1
     AND priskey = 1
     AND prbasefinish IS NOT NULL;

  SELECT count(*)
    INTO total_planned_milestones
    FROM prtask
   WHERE prismilestone = 1
     AND priskey = 1
     AND prbasefinish IS NOT NULL
     AND prstatus <> 2; -- Completed
   
  SELECT count(*)
    INTO total_completed_milestones
    FROM prtask
   WHERE prismilestone = 1
     AND priskey = 1
     AND prbasefinish IS NOT NULL
     AND prstatus = 2; -- Completed
   
  IF total_milestones = 0 THEN
    percent_planned := 0;
    percent_completed := 0;
  ELSE  
    percent_planned := ROUND(total_planned_milestones/total_milestones,2);
    percent_completed := ROUND(total_completed_milestones/total_milestones,2);
  END IF;

  INSERT INTO trg_rpt_nr09_10 (
    rpt_nr09_10_id,
    display_date,
    display_month,
    open_incidents,
    planned_milestones,
    completed_milestones,
    percent_planned,
    percent_completed)
  VALUES (
    TRG_RPT_NR09_10_SEQ.NEXTVAL,    -- rpt_nr09_10_id
    display_date,                   -- display_date
    display_month,                  -- display_month
    0,                              -- open_incidents
    planned_milestones,             -- planned_milestones
    completed_milestones,           -- completed_milestones
    percent_planned,                -- percent_planned
    percent_completed);             -- percent_completed
    
COMMIT;

END TRG_RPT_NR09_10_SP;
/
