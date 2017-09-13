CREATE OR REPLACE PROCEDURE TRG_RPT_EPMO_ASSIGNMENTS_SP(
    a_cursor IN OUT TYPES.cursorType
)

IS

    CURSOR resources_cur
    IS
        SELECT rcf.resource_id,
               rcf.role_name,
               rcf.first_name,
               rcf.last_name
          FROM NBI_RESOURCE_CURRENT_FACTS rcf
         WHERE rcf.role_name in ('Program Manager','Project Manager','Project Coordinator');
         
    CURSOR projects_cur(r_id NBI_RESOURCE_CURRENT_FACTS.resource_id%TYPE)
    IS
        SELECT DISTINCT pf.project_id
          FROM NBI_PRT_FACTS pf
         WHERE pf.resource_id = r_id;

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
    cm_percent          NUMBER(5,2);
    nm_percent          NUMBER(5,2);
    fm_percent          NUMBER(5,2);
    peoplesoft_number   nbi_project_current_facts.project_code%TYPE;
    project             nbi_project_current_facts.project_name%TYPE;
    prstart             nbi_project_current_facts.start_date%TYPE;
    prfinish            nbi_project_current_facts.finish_date%TYPE;

BEGIN
    current_month := LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY'));
    next_month := LAST_DAY(current_month + 1);
    final_month := LAST_DAY(next_month + 1);

    FOR resources_rec IN resources_cur
    LOOP

        rsc_name := resources_rec.first_name || ' ' || resources_rec.last_name;
        rsc_name := TRIM(rsc_name);

        BEGIN
            SELECT SUM(rf.available_hours)
              INTO cm_available_hours
              FROM nbi_r_facts rf
             WHERE rf.resource_id = resources_rec.resource_id
               AND rf.fact_date BETWEEN SYSDATE AND current_month;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                cm_available_hours := 0;
        END;               
         
        IF cm_available_hours IS NULL OR cm_available_hours = '' THEN
            cm_available_hours := 0;
        END IF;
           
        BEGIN
            SELECT SUM(rf.available_hours)
              INTO nm_available_hours
              FROM nbi_r_facts rf
             WHERE rf.resource_id = resources_rec.resource_id
               AND rf.fact_date BETWEEN current_month + 1 AND next_month;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                nm_available_hours := 0;
        END;               

        IF nm_available_hours IS NULL OR nm_available_hours = '' THEN
            nm_available_hours := 0;
        END IF;
           
        BEGIN
            SELECT SUM(rf.available_hours)
              INTO fm_available_hours
              FROM nbi_r_facts rf
             WHERE rf.resource_id = resources_rec.resource_id
               AND rf.fact_date BETWEEN next_month + 1 AND final_month;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                fm_available_hours := 0;
        END;
        
        IF fm_available_hours IS NULL OR fm_available_hours = '' THEN
            fm_available_hours := 0;
        END IF;
           
        FOR projects_rec IN projects_cur(resources_rec.resource_id)
        LOOP

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

            BEGIN
                SELECT SUM(pf.etc_qty + pf.actual_qty)
                  INTO cm_etc_hours
                  FROM nbi_prt_facts pf
                 WHERE pf.resource_id = resources_rec.resource_id
                   AND pf.project_id = projects_rec.project_id
                   AND pf.fact_date BETWEEN SYSDATE AND current_month;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    cm_etc_hours := 0;
            END;               
         
            IF cm_etc_hours IS NULL OR cm_etc_hours = '' THEN
                cm_etc_hours := 0;
            END IF;
           
            BEGIN
                SELECT SUM(pf.etc_qty + pf.actual_qty)
                  INTO nm_etc_hours
                  FROM nbi_prt_facts pf
                 WHERE pf.resource_id = resources_rec.resource_id
                   AND pf.project_id = projects_rec.project_id
                   AND pf.fact_date BETWEEN current_month + 1 AND next_month;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    nm_etc_hours := 0;
            END;               

            IF nm_etc_hours IS NULL OR nm_etc_hours = '' THEN
                nm_etc_hours := 0;
            END IF;
           
            BEGIN
                SELECT SUM(pf.etc_qty + pf.actual_qty)
                  INTO fm_etc_hours
                  FROM nbi_prt_facts pf
                 WHERE pf.resource_id = resources_rec.resource_id
                   AND pf.project_id = projects_rec.project_id
                   AND pf.fact_date BETWEEN next_month + 1 AND final_month;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fm_etc_hours := 0;
            END;               

            IF fm_etc_hours IS NULL OR fm_etc_hours = '' THEN
                fm_etc_hours := 0;
            END IF;
           
            IF cm_available_hours = 0 THEN
                cm_percent := 0;
            ELSE
                cm_percent := ROUND((cm_etc_hours/cm_available_hours)*100);
            END IF;
            
            IF nm_available_hours = 0 THEN
                nm_percent := 0;
            ELSE
                nm_percent := ROUND((nm_etc_hours/nm_available_hours)*100);
            END IF;

            IF fm_available_hours = 0 THEN
                fm_percent := 0;
            ELSE
                fm_percent := ROUND((fm_etc_hours/fm_available_hours)*100);
            END IF;

            INSERT INTO trg_epmo_assignments_temp(
                    nikurole,
                    rsc_name,
                    peoplesoft_number,
                    project,
                    prstart,
                    prfinish,
                    current_pcnt,
                    next_pcnt,
                    final_pcnt)
            VALUES(
                resources_rec.role_name,
                rsc_name,
                peoplesoft_number,
                project,
                prstart,
                prfinish,
                cm_percent,
                nm_percent,
                fm_percent);
                
        END LOOP;

    END LOOP;
    
    OPEN a_cursor FOR
        SELECT t.*
          FROM trg_epmo_assignments_temp t
      ORDER BY DECODE(t.nikurole,'Program Manager',    1,
                                 'Project Manager',    2,
                                 'Project Coordinator',3,
                                                       4),
               t.rsc_name,
               t.prstart,
               t.prfinish,
               t.peoplesoft_number;
      
END TRG_RPT_EPMO_ASSIGNMENTS_SP;
/
