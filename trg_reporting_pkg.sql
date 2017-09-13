CREATE OR REPLACE PACKAGE TRG_REPORTING_PKG AS
TYPE record_cursor IS REF CURSOR;
TYPE record_type IS RECORD (
    nikurole          srm_resources.last_name%TYPE,
    rsc_name          cmn_sec_users.description%TYPE,
    peoplesoft_number srm_projects.unique_name%TYPE,
    project           srm_projects.name%TYPE,
    prstart           prj_projects.prstart%TYPE,
    prfinish          prj_projects.prfinish%TYPE,
    current_pcnt      prassignment.prestmax%TYPE,
    next_pcnt         prassignment.prestmax%TYPE,
    final_pcnt        prassignment.prestmax%TYPE);
TYPE pls_table IS TABLE OF record_type
   INDEX BY BINARY_INTEGER;
/******************************************************************************

   Author                          	: Robert Bondaruk
   Date Written                    	: 04/06/2004
   Objects invoking this procedure 	: Niku Scheduled Job
   Events Called from              	: None
   Detailed Description            	:
      This package contains the procedures to be used by the Niku custom
      Actuate reports created for Regence.
      
      RPT_NR01_SP is called by Niku report NR01.
      RPT_NR01A_SP is called by Niku report NR01a.
      RPT_NR09_SP is called by Niku report NR09.
      RPT_NR10_SP is called by Niku report NR10.
      
      Procedures were used rather than passing sql from the reports because the
      Actuate Oracle driver could not handle the Oracle Union statement.
      
   Modified By                     	:
   Modified Date                   	:
   Modified Desc.                   :

******************************************************************************/

PROCEDURE RPT_NR01_SP(
    a_cursor IN OUT TRG_REPORTING_PKG.record_cursor
);

PROCEDURE RPT_NR01A_SP(
    a_cursor IN OUT TRG_REPORTING_PKG.record_cursor
);

PROCEDURE RPT_NR09_SP(
    a_cursor IN OUT TRG_REPORTING_PKG.record_cursor
);

PROCEDURE RPT_NR09_GRAPH2_SP(
    a_cursor IN OUT TRG_REPORTING_PKG.record_cursor
);

PROCEDURE RPT_NR10_SP(
    a_cursor IN OUT TRG_REPORTING_PKG.record_cursor
);

PROCEDURE RPT_NR09_10_SP (
   P_JOB_RUN_ID    IN   NUMBER,
   P_JOB_USER_ID   IN   NUMBER
);

PROCEDURE RPT_EPMO_ASSIGNMENTS(
    a_table OUT pls_table
);

END TRG_REPORTING_PKG;
/

CREATE OR REPLACE PACKAGE BODY TRG_REPORTING_PKG AS

PROCEDURE RPT_NR01_SP(
    a_cursor IN OUT TRG_REPORTING_PKG.record_cursor
)

IS

BEGIN
    OPEN a_cursor FOR
        SELECT  project_name,
                SUM(missed) AS missed,
                SUM(notstarted) AS notstarted,
                SUM(inprogress) AS inprogress,
                SUM(ahead) AS ahead,
                SUM(onschedule) AS onschedule,
                SUM(totalmilestones) AS totalmilestones,
                SUM(totalcompleted) AS totalcompleted,
                SUM(actual) AS actual,
                SUM(remaining) AS remaining,
                SUM(totalhours) AS totalhours
          FROM  (
                SELECT  p.project_name,
                        0 AS missed,
                        0 AS notstarted,
                        0 AS inprogress,
                        0 AS ahead,
                        0 AS onschedule,
                        0 AS totalmilestones,                
                        0 AS totalcompleted,
                        p.actual_hours AS actual,
                        p.etc_hours AS remaining,
                        p.actual_hours + p.etc_hours AS totalhours
                  FROM  niku.nbi_project_current_facts p
                 WHERE  p.project_id IN (
                                        SELECT  t.prprojectid
                                          FROM  niku.prtask t
                                         WHERE  t.prismilestone = 1
                                           AND  t.priskey = 1
                                           AND  t.prbasefinish IS NOT NULL
                                        )
                 UNION
                SELECT  p.name AS project_name,
                        SUM(CASE WHEN t.prbasefinish < TO_DATE('01/01/2004','MM/DD/YYYY') AND t.prstatus <> 2 -- Completed
                                 THEN 1
                                 ELSE 0
                            END) AS missed,
                        SUM(CASE WHEN t.prstatus = 0 -- NotStarted
                                 THEN 1
                                 ELSE 0
                            END) AS notstarted,
                        SUM(CASE WHEN t.prstatus = 1 -- Started
                                 THEN 1
                                 ELSE 0
                            END) AS inprogress,
                        SUM(CASE WHEN t.prbasefinish > TO_DATE('01/01/2004','MM/DD/YYYY') AND t.prstatus = 2 -- Completed
                                 THEN 1
                                 ELSE 0
                            END) AS ahead,
                        SUM(CASE WHEN t.prbasefinish < TO_DATE('01/01/2004','MM/DD/YYYY') AND t.prstatus = 2 -- Completed
                                 THEN 1
                                 ELSE 0
                            END) AS onschedule,
                        COUNT(t.prid) AS totalmilestones,                
                        SUM(CASE WHEN t.prstatus = 2 -- Completed
                                 THEN 1
                                 ELSE 0
                            END) AS totalcompleted,
                        0 AS actual,
                        0 AS remaining,
                        0 AS totalhours
                  FROM  niku.prtask t, niku.srm_projects p
                 WHERE  t.prprojectid = p.id
                   AND  t.prismilestone = 1
                   AND  t.priskey = 1
                   AND  t.prbasefinish IS NOT NULL
              GROUP BY  p.name
                )
      GROUP BY  project_name;
END;

PROCEDURE RPT_NR01A_SP(
    a_cursor IN OUT TRG_REPORTING_PKG.record_cursor
)

IS

BEGIN
    OPEN a_cursor FOR
        SELECT  sp.name as project_name,
                t.prname as key_milestone,
                pp.prusertext1 as phase,
                t.prbasefinish as baseline_finish,
                CASE WHEN t.prstatus = 0 -- NotStarted
                     THEN 'Not Started'
                     WHEN t.prstatus = 1 -- Started
                     THEN 'Started'
                END as task_status
          FROM  niku.prtask t, niku.srm_projects sp, niku.prj_projects pp
         WHERE  t.prprojectid = sp.id
           AND  sp.id = pp.prid
           AND  t.prbasefinish < SYSDATE
           AND  t.prstatus <> 2 -- Completed
           AND  t.prismilestone = 1
           AND  t.priskey = 1
           AND  t.prbasefinish IS NOT NULL;
END;

PROCEDURE RPT_NR09_SP(
    a_cursor IN OUT TRG_REPORTING_PKG.record_cursor
)

IS

BEGIN
    OPEN a_cursor FOR
        SELECT  TO_CHAR(end_date,'fmMM/DD/YYYY') AS display_date,
                milestone_type,
                SUM(milestone_count) AS milestone_count
          FROM  (
                 SELECT  rd.end_date,
                         'Completed' AS milestone_type,
                         COUNT(*) AS milestone_count
                   FROM  niku.prtask t, trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish > rd.begin_date
                    AND  t.prbasefinish <= rd.end_date
                    AND  t.prstatus = 2
                    AND  rd.period = 'WEEK'
               GROUP BY  rd.end_date,
                         'Completed'
                  UNION
                 SELECT  rd.end_date,
                         'Planned' AS milestone_type,
                         COUNT(*) AS milestone_count
                   FROM  niku.prtask t, trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish > rd.begin_date
                    AND  t.prbasefinish <= rd.end_date
                    AND  t.prstatus <> 2
                    AND  rd.period = 'WEEK'
               GROUP BY  rd.end_date,
                         'Planned'
                  UNION
                 SELECT  rd.end_date,
                         'Completed' AS milestone_type,
                         0 AS milestone_count
                   FROM  trg_reporting_dates rd
                  WHERE  rd.period = 'WEEK'
                  UNION
                 SELECT  rd.end_date,
                         'Planned' AS milestone_type,
                         0 AS milestone_count
                   FROM  trg_reporting_dates rd
                  WHERE  rd.period = 'WEEK'
                )
      GROUP BY  end_date,
                milestone_type
      ORDER BY  end_date,
                milestone_type DESC;
END;
    
/*
        SELECT *
          FROM TRG_RPT_NR09;


        SELECT  TO_CHAR(end_date,'fmMM/DD/YYYY') AS display_date,
                SUM(completed) AS completed,
                SUM(planned) AS planned,
                SUM(total_completed) AS total_completed,
                SUM(total_planned) AS total_planned
          FROM  (
                 SELECT  rd.end_date,
                         SUM(CASE WHEN t.prstatus = 2 -- Completed
                                  THEN 1
                                  ELSE 0
                             END) AS completed,
                         COUNT(*) AS planned,
                         0 as total_completed,
                         0 as total_planned
                   FROM  niku.prtask t, trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish > rd.begin_date
                    AND  t.prbasefinish <= rd.end_date
                    AND  rd.period = 'WEEK'
               GROUP BY  rd.end_date
                  UNION
                 SELECT  rd.end_date,
                         0 AS completed,
                         0 AS planned,
                         SUM(CASE WHEN t.prstatus = 2 -- Completed
                                  THEN 1
                                   ELSE 0
                             END) AS total_completed,
                         COUNT(*) AS total_planned
                   FROM  niku.prtask t, trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish <= rd.end_date
                    AND  rd.period = 'WEEK'
               GROUP BY  rd.end_date
                  UNION
                 SELECT  rd.end_date,
                         0 AS completed,
                         0 AS planned,
                         0 AS total_completed,
                         0 AS total_planned
                   FROM  trg_reporting_dates rd
                  WHERE  rd.period = 'WEEK'
                )
      GROUP BY  end_date
      ORDER BY  end_date;
*/

PROCEDURE RPT_NR09_GRAPH2_SP(
    a_cursor IN OUT TRG_REPORTING_PKG.record_cursor
)

IS

BEGIN
    OPEN a_cursor FOR
        SELECT  TO_CHAR(end_date,'fmMM/DD/YYYY') AS display_date_2,
                SUM(percent_complete) AS percent_complete
          FROM  (
                 SELECT  rd.end_date,
                         ((SUM(CASE WHEN t.prstatus = 2 -- Completed
                                  THEN 1
                                   ELSE 0
                             END)/
                         COUNT(*))*100) AS percent_complete
                   FROM  niku.prtask t, trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish <= rd.end_date
                    AND  rd.period = 'WEEK'
               GROUP BY  rd.end_date
                  UNION
                 SELECT  rd.end_date,
                         0 AS percent_complete
                   FROM  trg_reporting_dates rd
                  WHERE  rd.period = 'WEEK'
                )
      GROUP BY  end_date
      ORDER BY  end_date;
END;

PROCEDURE RPT_NR10_SP(
    a_cursor IN OUT TRG_REPORTING_PKG.record_cursor
)

IS

BEGIN
    OPEN a_cursor FOR
        SELECT  end_date,
                SUM(completed) AS completed,
                SUM(planned) AS planned,
                SUM(total_completed) AS total_completed,
                SUM(total_planned) AS total_planned
          FROM  (
                 SELECT  rd.end_date,
                         SUM(CASE WHEN t.prstatus = 2 -- Completed
                                  THEN 1
                                  ELSE 0
                             END) AS completed,
                         COUNT(*) AS planned,
                         0 AS total_completed,
                         0 AS total_planned
                   FROM  niku.prtask t, niku.trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish > rd.begin_date
                    AND  t.prbasefinish <= rd.end_date
                    AND  rd.period = 'MONTH'
               GROUP BY  rd.end_date
                  UNION
                 SELECT  rd.end_date,
                         0 AS completed,
                         0 AS planned,
                         SUM(CASE WHEN t.prstatus = 2 -- Completed
                                  THEN 1
                                  ELSE 0
                             END) AS total_completed,
                         COUNT(*) AS total_planned
                   FROM  niku.prtask t, niku.trg_reporting_dates rd
                  WHERE  t.prismilestone = 1
                    AND  t.priskey = 1
                    AND  t.prbasefinish IS NOT NULL
                    AND  t.prbasefinish <= rd.end_date
                    AND  rd.period = 'MONTH'
               GROUP BY  rd.end_date
                  UNION
                 SELECT  rd.end_date,
                         0 as completed,
                         0 as planned,
                         0 as total_completed,
                         0 as total_planned
                   FROM  niku.trg_reporting_dates rd
                  WHERE  rd.period = 'MONTH'
                )
      GROUP BY  end_date;
END;

PROCEDURE RPT_NR09_10_SP (
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

  SELECT sysdate
    INTO display_date
    FROM dual;
    
    display_date := TO_DATE(TO_CHAR(display_date,'MM/DD/YYYY'),'MM/DD/YYYY');
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

END;

PROCEDURE RPT_EPMO_ASSIGNMENTS(
    a_table OUT pls_table
)

IS

    CURSOR resources_cur
    IS
        SELECT rcf.resource_id,
               rcf.role_name,
               rcf.first_name,
               rcf.last_name
          FROM NBI_RESOURCE_CURRENT_FACTS rcf
         WHERE rcf.role_name in ('Program Manager','Project Manager','Project Coordinator')
      ORDER BY DECODE(rcf.role_name,'Program Manager',    1,
                                    'Project Manager',    2,
                                    'Project Coordinator',3,
                                                          4);
         
    resources_rec resources_cur%ROWTYPE;

    CURSOR projects_cur(resource_id NBI_RESOURCE_CURRENT_FACTS.resource_id%TYPE)
    IS
        SELECT UNIQUE pf.project_id
          FROM NBI_PRT_FACTS pf
         WHERE pf.resource_id = resource_id;

    projects_rec projects_cur%ROWTYPE;
/*
    last_name         cmn_sec_users.last_name%TYPE;
    middle_name       cmn_sec_users.middle_name%TYPE;
    first_name        cmn_sec_users.first_name%TYPE;
    csu_id            cmn_sec_users.id%TYPE;
    peoplesoft_number srm_projects.unique_name%TYPE;
    project           srm_projects.name%TYPE;
*/    
    current_month       nbi_r_facts.fact_date%TYPE;
    next_month          nbi_r_facts.fact_date%TYPE;
    final_month         nbi_r_facts.fact_date%TYPE;
    rsc_name            cmn_sec_users.description%TYPE;
    cm_available_hours  nbi_r_facts.available_hours%TYPE;
    nm_available_hours  nbi_r_facts.available_hours%TYPE;
    fm_available_hours  nbi_r_facts.available_hours%TYPE;
    cm_etc_hours        nbi_r_facts.available_hours%TYPE;
    nm_etc_hours        nbi_r_facts.available_hours%TYPE;
    fm_etc_hours        nbi_r_facts.available_hours%TYPE;
    peoplesoft_number   nbi_project_current_facts.project_code%TYPE;
    project             nbi_project_current_facts.project_name%TYPE;
    prstart             nbi_project_current_facts.start_date%TYPE;
    prfinish            nbi_project_current_facts.finish_date%TYPE;


    cnt         INTEGER;

BEGIN
    current_month := LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY'));
    next_month := LAST_DAY(current_month + 1);
    final_month := LAST_DAY(next_month + 1);

    IF NOT resources_cur%ISOPEN
    THEN
        OPEN resources_cur;
    END IF;
    
    FETCH resources_cur INTO resources_rec;
    
    cnt := 1;

    WHILE resources_cur%FOUND
    LOOP

        rsc_name := resources_rec.first_name || resources_rec.last_name;
        rsc_name := TRIM(rsc_name);

        SELECT SUM(rf.available_hours)
          INTO cm_available_hours
          FROM nbi_r_facts rf
         WHERE rf.resource_id = resources_rec.resource_id
           AND rf.fact_date BETWEEN SYSDATE AND current_month;
         
        SELECT SUM(rf.available_hours)
          INTO nm_available_hours
          FROM nbi_r_facts rf
         WHERE rf.resource_id = resources_rec.resource_id
           AND rf.fact_date BETWEEN current_month + 1 AND next_month;

        SELECT SUM(rf.available_hours)
          INTO fm_available_hours
          FROM nbi_r_facts rf
         WHERE rf.resource_id = resources_rec.resource_id
           AND rf.fact_date BETWEEN next_month + 1 AND final_month;

        IF NOT projects_cur%ISOPEN
        THEN
            OPEN projects_cur(resources_rec.resource_id);
        END IF;
    
        FETCH projects_cur INTO projects_rec;
    
        WHILE projects_cur%FOUND
        LOOP

            a_table(cnt).nikurole := resources_rec.role_name;
            a_table(cnt).rsc_name := rsc_name;

            SELECT pcf.project_code,
                   pcf.project_name,
                   pcf.start_date,
                   pcf.finish_date
              INTO peoplesoft_number,
                   project,
                   prstart,
                   prfinish
              FROM nbi_project_current_facts pcf
             WHERE pcf.project_id = projects_rec.project_id;

            a_table(cnt).peoplesoft_number := peoplesoft_number;
            a_table(cnt).project := project;
            a_table(cnt).prstart := prstart;
            a_table(cnt).prfinish := prfinish;

            SELECT SUM(pf.etc_qty + pf.actual_qty)
              INTO cm_etc_hours
              FROM nbi_prt_facts pf
             WHERE pf.resource_id = resources_rec.resource_id
               AND pf.project_id = projects_rec.project_id
               AND pf.fact_date BETWEEN SYSDATE AND current_month;
         
            SELECT SUM(pf.etc_qty + pf.actual_qty)
              INTO nm_etc_hours
              FROM nbi_prt_facts pf
             WHERE pf.resource_id = resources_rec.resource_id
               AND pf.project_id = projects_rec.project_id
               AND pf.fact_date BETWEEN current_month + 1 AND next_month;

            SELECT SUM(pf.etc_qty + pf.actual_qty)
              INTO fm_etc_hours
              FROM nbi_prt_facts pf
             WHERE pf.resource_id = resources_rec.resource_id
               AND pf.project_id = projects_rec.project_id
               AND pf.fact_date BETWEEN next_month + 1 AND final_month;

            IF cm_available_hours = 0 THEN
                a_table(cnt).current_pcnt  := 0;
            ELSE
                a_table(cnt).current_pcnt  := ROUND((cm_etc_hours/cm_available_hours)*100,2);
            END IF;
            
            IF nm_available_hours = 0 THEN
                a_table(cnt).next_pcnt := 0;
            ELSE
                a_table(cnt).next_pcnt := ROUND((nm_etc_hours/nm_available_hours)*100,2);
            END IF;

            IF fm_available_hours = 0 THEN
                a_table(cnt).next_pcnt := 0;
            ELSE
                a_table(cnt).final_pcnt := ROUND((fm_etc_hours/fm_available_hours)*100,2);
            END IF;

            cnt := cnt + 1;

        END LOOP;
        CLOSE projects_cur;

    END LOOP;
    CLOSE resources_cur;

/*
    CURSOR roles_cur
    IS
        SELECT sr.last_name AS nikurole,
               sr.id AS sr_id
          FROM srm_resources sr
         WHERE sr.unique_name in ('_PC','_PM','_PGM')
           AND sr.person_type = 0
      ORDER BY DECODE(sr.last_name,'Program Manager',    1,
                                   'Project Manager',    2,
                                   'Project Coordinator',3,
                                                         4);
         
    roles_rec roles_cur%ROWTYPE;
    
    CURSOR dates_cur(csu_id cmn_sec_users.id%TYPE)
    IS
        SELECT pp.prid,
               pp.prstart,
               pp.prfinish
          FROM prj_projects pp
         WHERE pp.manager_id = csu_id;

    dates_rec dates_cur%ROWTYPE;

    last_name         cmn_sec_users.last_name%TYPE;
    middle_name       cmn_sec_users.middle_name%TYPE;
    first_name        cmn_sec_users.first_name%TYPE;
    rsc_name          cmn_sec_users.description%TYPE;
    csu_id            cmn_sec_users.id%TYPE;
    peoplesoft_number srm_projects.unique_name%TYPE;
    project           srm_projects.name%TYPE;
    
    cnt         INTEGER;

BEGIN

    IF NOT roles_cur%ISOPEN
    THEN
        OPEN roles_cur;
    END IF;
    
    FETCH roles_cur INTO roles_rec;
    
    cnt := 1;

    WHILE roles_cur%FOUND
    LOOP
    
        SELECT csu.id,
               csu.last_name,
               csu.middle_name,
               csu.first_name
          INTO csu_id,
               last_name,
               middle_name,
               first_name
          FROM prj_resources pr,
               srm_resources sr,
               cmn_sec_users csu
         WHERE csu.user_name = sr.unique_name
           AND sr.id = pr.prid
           AND pr.prprimaryroleid = roles_rec.sr_id
      ORDER BY csu.last_name, 
               csu.first_name,
               csu.middle_name;
           
        rsc_name := first_name || middle_name;
        rsc_name := TRIM(rsc_name);
        rsc_name := rsc_name || last_name;
        rsc_name := TRIM(rsc_name);

        IF NOT dates_cur%ISOPEN
        THEN
            OPEN dates_cur(csu_id);
        END IF;
    
        FETCH dates_cur INTO dates_rec;
    
        WHILE dates_cur%FOUND
        LOOP

            SELECT sp.unique_name,
                   sp.name AS project
              INTO peoplesoft_number,
                   project
              FROM srm_projects sp
             WHERE sp.id = dates_rec.prid;

            a_table(cnt).nikurole          := roles_rec.nikurole;
            a_table(cnt).rsc_name          := rsc_name;
            a_table(cnt).peoplesoft_number := peoplesoft_number;
            a_table(cnt).project           := project;
            a_table(cnt).prstart           := dates_rec.prstart;
            a_table(cnt).prfinish          := dates_rec.prfinish;
        
            cnt := cnt + 1;

        END LOOP;
        CLOSE dates_cur;

    END LOOP;
    CLOSE roles_cur;

        SELECT sr.last_name AS title,
               csu.last_name,
               csu.middle_name,
               csu.first_name,
               sp.unique_name,
               sp.name AS project,
               pp.prstart,
               pp.prfinish
          FROM srm_resources sr,
               prj_resources pr,
               srm_resources sr2,
               CMN_SEC_USERS csu,
               prj_projects pp,
               srm_projects sp
         WHERE sr.unique_name in ('_PC','_PM','_PGM')
           AND sr.person_type = 0
           AND sr.id = pr.prprimaryroleid
           AND pr.prid = sr2.id
           AND sr2.unique_name = csu.user_name
           AND csu.id = pp.manager_id (+)
           AND pp.prid = sp.id (+)
      ORDER BY DECODE(sr.last_name,'Program Manager',    1,
                                   'Project Manager',    2,
                                   'Project Coordinator',3,
                                                         4),
               csu.last_name, 
               csu.first_name,
               csu.middle_name;
*/

END;
END TRG_REPORTING_PKG;
/

