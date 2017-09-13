CREATE OR REPLACE PROCEDURE TRG_RPT_EPMO_ASSIGNMENTS_SP(
    a_cursor IN OUT TYPES.cursorType
)

IS
    current_month       nbi_r_facts.fact_date%TYPE;
    next_month          nbi_r_facts.fact_date%TYPE;
    final_month         nbi_r_facts.fact_date%TYPE;

BEGIN
    current_month := LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY'));
    next_month := LAST_DAY(current_month + 1);
    final_month := LAST_DAY(next_month + 1);
    
    INSERT INTO trg_epmo_assignments_temp(
        project_id,
        resource_id,
        nikurole,
        last_name,
        first_name,
        peoplesoft_number,
        project,
        prstart,
        prfinish,
        cm_available_hours,
        nm_available_hours,
        fm_available_hours,
        cm_etc_hours,
        nm_etc_hours,
        fm_etc_hours,
        current_pcnt,
        next_pcnt,
        final_pcnt)
    SELECT project_id,
           resource_id,
           '', -- nikurole
           '', -- last_name
           '', -- first_name
           '', -- peoplesoft_number
           '', -- project
           NULL, -- prstart
           NULL, -- prfinish
           NULL, -- cm_available_hours,
           NULL, -- nm_available_hours,
           NULL, -- fm_available_hours,
           ROUND(SUM(CASE WHEN prtf.fact_date BETWEEN SYSDATE AND current_month
                          THEN prtf.etc_qty + prtf.actual_qty
                          ELSE 0
                      END),2),
           ROUND(SUM(CASE WHEN prtf.fact_date BETWEEN current_month AND next_month
                          THEN prtf.etc_qty + prtf.actual_qty
                          ELSE 0
                      END),2),
           ROUND(SUM(CASE WHEN prtf.fact_date BETWEEN next_month AND final_month
                          THEN prtf.etc_qty + prtf.actual_qty
                          ELSE 0
                      END),2),
           0, -- current_pcnt
           0, -- next_pcnt
           0 -- final_pcnt
      FROM nbi_project_res_task_facts prtf
     WHERE prtf.fact_date >= SYSDATE
       AND prtf.resource_id IN (
           SELECT rcf.resource_id
             FROM nbi_resource_current_facts rcf
            WHERE rcf.role_name IN ('Program Manager','Project Manager','Project Coordinator'))
  GROUP BY project_id,
           resource_id;

    UPDATE trg_epmo_assignments_temp eat
       SET (eat.nikurole, eat.last_name, eat.first_name, eat.cm_available_hours, eat.nm_available_hours, eat.fm_available_hours) =
           (SELECT rcf.role_name,
                   rcf.first_name,
                   rcf.last_name,
                   ROUND(SUM(CASE WHEN rf.fact_date BETWEEN SYSDATE AND LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY'))
                                  THEN rf.available_hours
                                  ELSE 0
                              END),2) AS cm_hours,
                    ROUND(SUM(CASE WHEN rf.fact_date BETWEEN LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY'))+1 AND LAST_DAY(LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY')) + 1)
                                   THEN rf.available_hours
                                   ELSE 0
                              END),2) AS nm_hours,
                    ROUND(SUM(CASE WHEN rf.fact_date BETWEEN LAST_DAY(LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY')) + 1)+1 AND LAST_DAY(LAST_DAY(LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY')) + 1) + 1)
                                   THEN rf.available_hours
                                   ELSE 0
                              END),2) AS fm_hours
               FROM nbi_r_facts rf, nbi_resource_current_facts rcf
              WHERE eat.resource_id = rcf.resource_id
                AND rf.resource_id = rcf.resource_id
                AND rcf.role_name IN ('Program Manager','Project Manager','Project Coordinator')
                AND rf.fact_date >= SYSDATE
           GROUP BY rcf.resource_id,
                    rcf.role_name,
                    rcf.first_name,
                    rcf.last_name)
     WHERE EXISTS
           (SELECT 1
               FROM nbi_r_facts rf, nbi_resource_current_facts rcf
              WHERE eat.resource_id = rcf.resource_id
                AND rf.resource_id = rcf.resource_id
                AND rcf.role_name IN ('Program Manager','Project Manager','Project Coordinator')
                AND rf.fact_date >= SYSDATE);

    UPDATE trg_epmo_assignments_temp eat
       SET (eat.peoplesoft_number, eat.project, eat.prstart, eat.prfinish) =
           (SELECT pcf.project_code,
                   pcf.project_name,
                   pcf.start_date,
                   pcf.finish_date
              FROM nbi_project_current_facts pcf
             WHERE pcf.project_id = eat.project_id)
    WHERE EXISTS             
           (SELECT 1
              FROM nbi_project_current_facts pcf
             WHERE pcf.project_id = eat.project_id);

    UPDATE trg_epmo_assignments_temp eat
       SET (eat.current_pcnt, eat.next_pcnt,eat.final_pcnt) =
           (SELECT DECODE(eat.cm_available_hours,0,0,ROUND(eat.cm_etc_hours/eat.cm_available_hours,2)),
                   DECODE(eat.nm_available_hours,0,0,ROUND(eat.nm_etc_hours/eat.nm_available_hours,2)),
                   DECODE(eat.fm_available_hours,0,0,ROUND(eat.fm_etc_hours/eat.fm_available_hours,2))
              FROM trg_epmo_assignments_temp eat2
             WHERE eat2.project_id = eat.project_id
               AND eat2.resource_id = eat.resource_id)
     WHERE EXISTS
           (SELECT 1
              FROM trg_epmo_assignments_temp eat2
             WHERE eat2.project_id = eat.project_id
               AND eat2.resource_id = eat.resource_id);

/*

update
  2    ( select t1.y t1_y, t2.y t2_y
  3            from t1, t2
  4           where t1.x = t2.x )
  5     set t1_y = t2_y



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

            IF cm_available_hours = 0 THEN
                cm_percent := 0;
            ELSE
                cm_percent := ROUND((cm_etc_hours/cm_available_hours)*100,2);
            END IF;
            
            IF nm_available_hours = 0 THEN
                nm_percent := 0;
            ELSE
                nm_percent := ROUND((nm_etc_hours/nm_available_hours)*100,2);
            END IF;

            IF fm_available_hours = 0 THEN
                fm_percent := 0;
            ELSE
                fm_percent := ROUND((fm_etc_hours/fm_available_hours)*100,2);
            END IF;
*/

    
    OPEN a_cursor FOR
        SELECT *
          FROM trg_epmo_assignments_temp;
      
END TRG_RPT_EPMO_ASSIGNMENTS_SP;
/
