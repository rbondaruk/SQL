CREATE OR REPLACE PROCEDURE TRG_RPT_NR21_SP (
    a_cursor        IN OUT TYPES.cursorType,
    nOBSUnit        IN     NUMBER DEFAULT 0,
    nOBSLevel       IN     NUMBER,
    nProject        IN     NUMBER,
    p_startdate     IN     VARCHAR2,
    p_enddate       IN     VARCHAR2,
    p_forum         IN     VARCHAR2,
    p_SR            IN     VARCHAR2
)

IS
    CURSOR projects_cur(p_id nbi_project_current_facts.project_id%TYPE)
    IS
        SELECT DISTINCT b.project_id
          FROM nbi_project_current_facts b
         WHERE SUBSTR(b.project_code,1,2) = 'SR'
           AND b.project_id = NVL (p_id, b.project_id);

    CURSOR phases_cur(p_id nbi_project_current_facts.project_id%TYPE, c_forum VARCHAR2)
    IS
        SELECT a.prwbssequence,
               a.prname,
               SUBSTR(a.prname,1,2) AS forum
          FROM prtask a
         WHERE a.prwbslevel = 1
           AND a.prprojectid = p_id
           AND UPPER(SUBSTR(a.prname,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
           AND (UPPER(SUBSTR(a.prname,1,2)) = c_forum OR c_forum = 'ALL')
           AND SUBSTR(a.prname,5,1) = '-'
      ORDER BY a.prwbssequence;

    CURSOR tasks_cur(p_id nbi_project_current_facts.project_id%TYPE,
        wbsseq_1 prtask.prwbssequence%TYPE,
        wbsseq_2 prtask.prwbssequence%TYPE)
    IS
        SELECT a.prid,
               b.prresourceid
          FROM prtask a,
               prassignment b
         WHERE a.prprojectid = p_id
           AND a.prwbssequence >= wbsseq_1
           AND (a.prwbssequence < wbsseq_2 OR wbsseq_2 = 0)
           AND a.prid = b.prtaskid;

    xOBSUnit           NUMBER;
    x_startdate        nbi_project_res_task_facts.fact_date%TYPE;
    x_enddate          nbi_project_res_task_facts.fact_date%TYPE;
    x_forum            VARCHAR2(25);
    x_SR               VARCHAR2(5);
    xProject           NUMBER;
    current_wbsseq     prtask.prwbssequence%TYPE;
    previous_wbsseq    prtask.prwbssequence%TYPE;
    current_forum      trg_nr21_temp.forum%TYPE;
    previous_forum     trg_nr21_temp.forum%TYPE;
    current_SR_name    trg_nr21_temp.sr_name%TYPE;
    previous_SR_name   trg_nr21_temp.sr_name%TYPE;
    current_SR_number  trg_nr21_temp.sr_number%TYPE;
    previous_SR_number trg_nr21_temp.sr_number%TYPE;
    previous_start     trg_nr21_temp.startdate%TYPE;
    current_start      trg_nr21_temp.startdate%TYPE;
    previous_finish    trg_nr21_temp.finishdate%TYPE;
    current_finish     trg_nr21_temp.finishdate%TYPE;
    max_phase_count    NUMBER;
    phase_count        NUMBER;

BEGIN
    DELETE trg_nr21_temp;
    DELETE trg_nr21b_temp;

    IF nOBSUnit = 0 THEN
        xOBSUnit := NULL;
    ELSE
        xOBSUnit := nOBSUnit;
    END IF;

    IF p_forum = 'TRG_FORUM_FN' THEN
        x_forum := 'FN';
    ELSIF p_forum = 'TRG_FORUM_HC' THEN
        x_forum := 'HC';
    ELSIF p_forum = 'TRG_FORUM_HR' THEN
        x_forum := 'HR';
    ELSIF p_forum = 'TRG_FORUM_MK' THEN
        x_forum := 'MK';
    ELSIF p_forum = 'TRG_FORUM_MS' THEN
        x_forum := 'MS';
    ELSIF p_forum = 'TRG_FORUM_RT' THEN
        x_forum := 'RT';
    ELSIF p_forum = 'TRG_FORUM_SL' THEN
        x_forum := 'SL';
    ELSE
        x_forum := 'ALL';
    END IF;

    IF p_SR = 'TRG_SR_OVER_300' THEN
        x_SR := 'OVER';
    ELSIF p_SR = 'TRG_SR_UNDER_300' THEN
        x_SR := 'UNDER';
    ELSE
        x_SR := 'ALL';
    END IF;

    IF p_startdate = '' OR p_startdate IS NULL THEN
        x_startdate := TRUNC(TO_DATE('01/01/1950', 'MM/DD/YYYY'));
    ELSE
        x_startdate := TRUNC(TO_DATE(p_startdate, 'MM/DD/YYYY'));
    END IF;

    IF p_enddate = '' OR p_enddate IS NULL THEN
        x_enddate := TRUNC(SYSDATE + 1);
    ELSE
        x_enddate := TRUNC(TO_DATE(p_enddate, 'MM/DD/YYYY') + 1);
    END IF;

    IF nProject = 0 THEN
        xProject := NULL;
    ELSE
        xProject := nProject;
    END IF;

    IF x_SR IN ('ALL','UNDER') THEN

        FOR projects_rec IN projects_cur(xProject)
        LOOP

                BEGIN

                    SELECT COUNT(*)
                      INTO max_phase_count
                      FROM prtask a
                     WHERE a.prwbslevel = 1
                       AND a.prprojectid = projects_rec.project_id
                       AND UPPER(SUBSTR(a.prname,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                       AND (UPPER(SUBSTR(a.prname,1,2)) = x_forum OR x_forum = 'ALL')
                       AND SUBSTR(a.prname,5,1) = '-';
                           EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                                max_phase_count := 0;

                END;
            
                phase_count := 1;
                previous_wbsseq := NULL;
                previous_forum := NULL;
                current_wbsseq := NULL;
                current_forum := NULL;
                current_SR_name := NULL;
                previous_SR_name := NULL;
                previous_start := NULL;
                current_start := NULL;
                previous_finish := NULL;
                current_finish := NULL;

                FOR phases_rec IN phases_cur(projects_rec.project_id,x_forum)
                LOOP

                    previous_SR_name := current_SR_name;
                    previous_start := current_start;
                    previous_finish := current_finish;

                    BEGIN

                        SELECT a.prname,
                               a.prstart,
                               a.prfinish
                          INTO current_SR_name,
                               current_start,
                               current_finish
                          FROM prtask a
                         WHERE a.prwbssequence = phases_rec.prwbssequence + 1
                           AND a.prwbslevel = 2
                           AND a.prprojectid = projects_rec.project_id;
                               EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                    current_SR_name := NULL;

                       END;

                    -- only one phase level record
                    IF max_phase_count = 1 THEN
    
                        FOR tasks_rec IN tasks_cur(projects_rec.project_id,
                            phases_rec.prwbssequence,
                            0)
                        LOOP

                            -- insert the under 300 hour SR's
                            INSERT INTO trg_nr21_temp(
                                        projectid,
                                        taskid,
                                        resourceid,
                                        forum,
                                        SR_number,
                                        SR_name,
                                        startdate,
                                        finishdate,
                                        fact_date,
                                        actual_qty,
                                        etc_qty)
                                 SELECT a.project_id,
                                        a.task_id,
                                        a.resource_id,
                                        phases_rec.forum,
                                        phases_rec.prname,
                                        current_SR_name,
                                        current_start,
                                        current_finish,
                                        a.fact_date,
                                        a.actual_qty,
                                        a.base_qty
                                   FROM nbi_project_res_task_facts a
                                  WHERE a.task_id = tasks_rec.prid
                                    AND a.fact_date BETWEEN x_startdate AND x_enddate
                                    AND a.resource_id = tasks_rec.prresourceid;

                        END LOOP;

                    -- more than one phase level record
                    ELSE

                        -- processing first of many records
                        IF phase_count = 1 THEN
                    
                            current_wbsseq := phases_rec.prwbssequence;
                            current_forum := phases_rec.forum;
                            current_SR_number := phases_rec.prname;

                        -- processing records after the first
                        ELSIF phase_count > 1 THEN

                            previous_wbsseq := current_wbsseq;
                            previous_forum := current_forum;
                            previous_SR_number := current_SR_number;
                            current_wbsseq := phases_rec.prwbssequence;
                            current_forum := phases_rec.forum;
                            current_SR_number := phases_rec.prname;

                            FOR tasks_rec IN tasks_cur(projects_rec.project_id,
                                previous_wbsseq,
                                current_wbsseq)
                            LOOP

                                -- insert the under 300 hour SR's
                                INSERT INTO trg_nr21_temp(
                                            projectid,
                                            taskid,
                                            resourceid,
                                            forum,
                                            SR_number,
                                            SR_name,
                                            startdate,
                                            finishdate,
                                            fact_date,
                                            actual_qty,
                                            etc_qty)
                                     SELECT a.project_id,
                                            a.task_id,
                                            a.resource_id,
                                            previous_forum,
                                            previous_SR_number,
                                            previous_SR_name,
                                            previous_start,
                                            previous_finish,
                                            a.fact_date,
                                            a.actual_qty,
                                            a.base_qty
                                       FROM nbi_project_res_task_facts a
                                      WHERE a.task_id = tasks_rec.prid
                                        AND a.fact_date BETWEEN x_startdate AND x_enddate
                                        AND a.resource_id = tasks_rec.prresourceid;

                            END LOOP;

                        END IF;
        
                        phase_count := phase_count + 1;

                    END IF;
                
                END LOOP;

                -- processing the last record
                IF phase_count > 1 THEN
            
                    FOR tasks_rec IN tasks_cur(projects_rec.project_id,
                        current_wbsseq,
                        0)
                    LOOP

                        -- insert the under 300 hour SR's
                        INSERT INTO trg_nr21_temp(
                                    projectid,
                                    taskid,
                                    resourceid,
                                    forum,
                                    SR_number,
                                    SR_name,
                                    startdate,
                                    finishdate,
                                    fact_date,
                                    actual_qty,
                                    etc_qty)
                             SELECT a.project_id,
                                    a.task_id,
                                    a.resource_id,
                                    current_forum,
                                    current_SR_number,
                                    current_SR_name,
                                    current_start,
                                    current_finish,
                                    a.fact_date,
                                    a.actual_qty,
                                    a.base_qty
                               FROM nbi_project_res_task_facts a
                              WHERE a.task_id = tasks_rec.prid
                                AND a.fact_date BETWEEN x_startdate AND x_enddate
                                AND a.resource_id = tasks_rec.prresourceid;

                    END LOOP;

                END IF;

        END LOOP;

        -- insert the under 300 hour SR's summary data
        INSERT INTO trg_nr21b_temp(
                    forum,
                    obs_unit_id,
                    SR_number,
                    SR_name,
                    startdate,
                    finishdate,
                    manager,
                    actual_qty,
                    etc_qty)
             SELECT CASE WHEN a.forum = 'FN' -- Finance
                         THEN 'Finance'
                         WHEN a.forum = 'HR' -- Human Resources
                         THEN 'Human Resources'
                         WHEN a.forum = 'RT' -- RITS
                         THEN 'RITS'
                         WHEN a.forum = 'SL' -- Sales
                         THEN 'Sales'
                         WHEN a.forum = 'MK' -- Marketing
                         THEN 'Marketing'
                         WHEN a.forum = 'MS' -- Member Services
                         THEN 'Member Services'
                         WHEN a.forum = 'HC' -- Health Care Services
                         THEN 'Health Care Services'
                         ELSE 'No Forum'
                    END AS forum,
                    c.obs2_unit_id AS obs_unit_id,
                    a.sr_number,
                    a.sr_name,
                    a.startdate,
                    a.finishdate,
                    b.manager_last_name || ', ' || b.manager_first_name,
                    NVL(SUM(a.actual_qty),0) AS actual_qty,
                    NVL(SUM(a.etc_qty),0) AS etc_qty
               FROM trg_nr21_temp a,
                    nbi_project_current_facts b,
                    nbi_resource_current_facts c
              WHERE a.projectid = b.project_id
                AND a.resourceid = c.resource_id
           GROUP BY a.forum,
                    a.sr_number,
                    a.sr_name,
                    a.startdate,
                    a.finishdate,
                    b.manager_last_name || ', ' || b.manager_first_name,
                    c.obs2_unit_id;

    END IF;

    IF x_SR IN ('ALL','OVER') THEN

        -- insert the over 300 hour SR's summary data
        INSERT INTO trg_nr21b_temp(
                    forum,
                    obs_unit_id,
                    SR_number,
                    SR_name,
                    startdate,
                    finishdate,
                    manager,
                    actual_qty,
                    etc_qty)
             SELECT CASE WHEN SUBSTR(b.project_code,1,2) = 'FN' -- Finance
                         THEN 'Finance'
                         WHEN SUBSTR(b.project_code,1,2) = 'HR' -- Human Resources
                         THEN 'Human Resources'
                         WHEN SUBSTR(b.project_code,1,2) = 'RT' -- RITS
                         THEN 'RITS'
                         WHEN SUBSTR(b.project_code,1,2) = 'SL' -- Sales
                         THEN 'Sales'
                         WHEN SUBSTR(b.project_code,1,2) = 'MK' -- Marketing
                         THEN 'Marketing'
                         WHEN SUBSTR(b.project_code,1,2) = 'MS' -- Member Services
                         THEN 'Member Services'
                         WHEN SUBSTR(b.project_code,1,2) = 'HC' -- Health Care Services
                         THEN 'Health Care Services'
                         ELSE 'No Forum'
                    END AS forum,
                    c.obs2_unit_id AS obs_unit_id,
                    b.project_code AS SR_number,
                    b.project_name AS SR_name,
                    b.start_date,
                    b.finish_date,
                    b.manager_last_name || ', ' || b.manager_first_name,
                    SUM(a.actual_qty) AS actual_qty,
                    SUM(a.base_qty) AS etc_qty
               FROM nbi_resource_current_facts c,
                    nbi_project_res_task_facts a,
                    nbi_project_current_facts b
              WHERE c.resource_id = a.resource_id
                AND a.fact_date BETWEEN x_startdate AND x_enddate
                AND (NVL(a.actual_qty,0) > 0 OR NVL(a.base_qty,0) > 0)
                AND a.project_id = b.project_id
                AND b.project_id = NVL (xProject, b.project_id)
                AND UPPER(SUBSTR(b.project_code,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                AND (UPPER(SUBSTR(b.project_code,1,2)) = x_forum OR x_forum = 'ALL')
                AND SUBSTR(b.project_code,5,1) = '-'
           GROUP BY CASE WHEN SUBSTR(b.project_code,1,2) = 'FN' -- Finance
                         THEN 'Finance'
                         WHEN SUBSTR(b.project_code,1,2) = 'HR' -- Human Resources
                         THEN 'Human Resources'
                         WHEN SUBSTR(b.project_code,1,2) = 'RT' -- RITS
                         THEN 'RITS'
                         WHEN SUBSTR(b.project_code,1,2) = 'SL' -- Sales
                         THEN 'Sales'
                         WHEN SUBSTR(b.project_code,1,2) = 'MK' -- Marketing
                         THEN 'Marketing'
                         WHEN SUBSTR(b.project_code,1,2) = 'MS' -- Member Services
                         THEN 'Member Services'
                         WHEN SUBSTR(b.project_code,1,2) = 'HC' -- Health Care Services
                         THEN 'Health Care Services'
                         ELSE 'No Forum'
                    END,
                    b.project_code,
                    b.project_name,
                    b.start_date,
                    b.finish_date,
                    b.manager_last_name || ', ' || b.manager_first_name,
                    c.obs2_unit_id;

    END IF;
    
    -- set the orgchart and path for the matching table entries
    UPDATE trg_nr21b_temp a
       SET (orgchart,path) =
           (SELECT CASE WHEN e.hierarchy_level = 2
                        THEN e.level2_name
                        WHEN e.hierarchy_level = 3
                        THEN e.level3_name
                        WHEN e.hierarchy_level = 4
                        THEN e.level4_name
                        WHEN e.hierarchy_level = 5
                        THEN e.level5_name
                        WHEN e.hierarchy_level = 6
                        THEN e.level6_name
                        WHEN e.hierarchy_level = 7
                        THEN e.level7_name
                        WHEN e.hierarchy_level = 8
                        THEN e.level8_name
                        WHEN e.hierarchy_level = 9
                        THEN e.level9_name
                        WHEN e.hierarchy_level = 10
                        THEN e.level10_name
                        ELSE ''
                   END AS orgchart,
                   e.path AS path
              FROM nbi_dim_obs e
             WHERE e.obs_unit_id = a.obs_unit_id
               AND (   (e.level1_unit_id = xOBSUnit AND 1 = nOBSLevel)
                    OR (e.level2_unit_id = xOBSUnit AND 2 = nOBSLevel)
                    OR (e.level3_unit_id = xOBSUnit AND 3 = nOBSLevel)
                    OR (e.level4_unit_id = xOBSUnit AND 4 = nOBSLevel)
                    OR (e.level5_unit_id = xOBSUnit AND 5 = nOBSLevel)
                    OR (e.level6_unit_id = xOBSUnit AND 6 = nOBSLevel)
                    OR (e.level7_unit_id = xOBSUnit AND 7 = nOBSLevel)
                    OR (e.level8_unit_id = xOBSUnit AND 8 = nOBSLevel)
                    OR (e.level9_unit_id = xOBSUnit AND 9 = nOBSLevel)
                    OR (e.level10_unit_id = xOBSUnit AND 10 = nOBSLevel)
                   )
           );

    -- delete table entries that were not matched
    DELETE trg_nr21b_temp a
     WHERE a.orgchart IS NULL;

    OPEN a_cursor FOR
        SELECT a.forum AS forum,
               a.SR_number AS SR_number,
               a.SR_name AS SR_name,
               a.startdate,
               a.finishdate,
               a.manager,
               SUM(a.actual_qty) AS actual_qty,
               SUM(a.etc_qty) AS etc_qty
          FROM trg_nr21b_temp a
      GROUP BY a.forum,
               a.SR_number,
               a.SR_name,
               a.startdate,
               a.finishdate,
               a.manager
      ORDER BY a.forum,
               a.SR_number,
               a.SR_name,
               a.manager;

END TRG_RPT_NR21_SP;
