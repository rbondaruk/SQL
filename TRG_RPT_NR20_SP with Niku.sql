CREATE OR REPLACE PROCEDURE TRG_RPT_NR20_SP (
    a_cursor        IN OUT TYPES.cursorType,
    nOBSUnit        IN     NUMBER DEFAULT 0,
    nOBSLevel       IN     NUMBER,
    p_startdate     IN     VARCHAR2,
    p_enddate       IN     VARCHAR2,
    p_plan_type     IN     VARCHAR2
)

IS
    CURSOR projects_cur
    IS
        SELECT DISTINCT b.project_id
          FROM niku_tst.nbi_project_current_facts b
         WHERE SUBSTR(b.project_code,1,2) = 'SR';

    CURSOR phases_cur(p_id niku_tst.nbi_project_current_facts.project_id%TYPE)
    IS
        SELECT a.prwbssequence,
               SUBSTR(a.prname,1,2) AS forum
          FROM niku_tst.prtask a
         WHERE a.prwbslevel = 1
           AND a.prprojectid = p_id
           AND UPPER(SUBSTR(a.prname,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
      ORDER BY a.prwbssequence;

    CURSOR tasks_cur(p_id niku_tst.nbi_project_current_facts.project_id%TYPE,
        wbsseq_1 prtask.prwbssequence%TYPE,
        wbsseq_2 prtask.prwbssequence%TYPE)
    IS
        SELECT a.prid,
               b.prresourceid
          FROM niku_tst.prtask a,
               niku_tst.prassignment b
         WHERE a.prprojectid = p_id
           AND a.prwbssequence >= wbsseq_1
           AND a.prwbssequence < wbsseq_2
           AND a.prid = b.prtaskid;

    xOBSUnit      NUMBER;
    x_startdate   niku_tst.nbi_prt_facts.fact_date%TYPE;
    x_enddate     niku_tst.nbi_prt_facts.fact_date%TYPE;
    x_plan_type   VARCHAR2(25);
    first_wbsseq  niku_tst.prtask.prwbssequence%TYPE;
    second_wbsseq niku_tst.prtask.prwbssequence%TYPE;
    forum1        VARCHAR2(2);
    forum2        VARCHAR2(2);
    loop_counter  NUMBER(1);
    plan_type     VARCHAR2(25);

BEGIN
    IF nOBSUnit = 0 THEN
        xOBSUnit := NULL;
    ELSE
        xOBSUnit := nOBSUnit;
    END IF;

    IF p_plan_type = 'TRG_WP_PROJECT' THEN
        x_plan_type := 'TRG_WP_PROJECT';
    ELSIF p_plan_type = 'TRG_WP_SERVICE_REQUEST' THEN
        x_plan_type := 'TRG_WP_SERVICE_REQUEST';
    ELSIF p_plan_type = 'TRG_WP_SUSTAINMENT' THEN
        x_plan_type := 'TRG_WP_SUSTAINMENT';
    ELSE
        x_plan_type := 'TRG_WP_ALL';
    END IF;

    IF p_startdate = '' OR p_startdate IS NULL THEN
        x_startdate := TRUNC(TO_DATE('01/01/1950', 'MM/DD/YYYY'));
    ELSE
        x_startdate := TRUNC(TO_DATE(p_startdate, 'MM/DD/YYYY'));
    END IF;

    IF p_enddate = '' OR p_enddate IS NULL THEN
        x_enddate := TRUNC(SYSDATE);
    ELSE
        x_enddate := TRUNC(TO_DATE(p_enddate, 'MM/DD/YYYY'));
    END IF;

    IF x_plan_type IN ('TRG_WP_SERVICE_REQUEST','TRG_WP_ALL') THEN

        FOR projects_rec IN projects_cur
        LOOP

            first_wbsseq := 0;
            second_wbsseq := 0;
            forum1 := NULL;
            forum2 := NULL;
            
            FOR phases_rec IN phases_cur(projects_rec.project_id)
            LOOP

                IF first_wbsseq = 0 THEN
                    first_wbsseq := phases_rec.prwbssequence;
                    forum1 := phases_rec.forum;
                ELSIF second_wbsseq = 0 THEN
                    second_wbsseq := phases_rec.prwbssequence;
                    forum2 := phases_rec.forum;
                ELSIF first_wbsseq > 0 AND second_wbsseq > 0 THEN
                    first_wbsseq := second_wbsseq;
                    second_wbsseq := phases_rec.prwbssequence;
                    forum1 := forum2;
                    forum2 := phases_rec.forum;
                END IF;
            
                IF first_wbsseq > 0 AND second_wbsseq > 0 THEN

                    FOR tasks_rec IN tasks_cur(projects_rec.project_id,
                        first_wbsseq,
                        second_wbsseq)
                    LOOP

                        -- insert the under 300 hour SR's
                        INSERT INTO trg_nr20_temp(
                                    projectid,
                                    taskid,
                                    resourceid,
                                    forum,
                                    fact_date,
                                    actual_qty,
                                    etc_qty)
                             SELECT a.project_id,
                                    a.task_id,
                                    a.resource_id,
                                    forum1,
                                    a.fact_date,
                                    a.actual_qty,
                                    a.etc_qty
                               FROM niku_tst.nbi_project_res_task_facts a
                              WHERE a.task_id = tasks_rec.prid
                                AND a.fact_date BETWEEN x_startdate AND x_enddate
                                AND a.resource_id = tasks_rec.prresourceid;

                    END LOOP;

                END IF;

            END LOOP;

        END LOOP;

        -- insert the under 300 hour SR's summary data
        INSERT INTO trg_nr20b_temp(
                    type,
                    obs_unit_id,
                    project_name,
                    actual_qty,
                    etc_qty)
             SELECT 'Service Request' AS type,
                    c.obs1_unit_id AS obs_unit_id,
                    b.project_name AS project_name,
                    NVL(SUM(a.actual_qty),0) AS actual_qty,
                    NVL(SUM(a.etc_qty),0) AS etc_qty
               FROM trg_nr20_temp a,
                    niku_tst.nbi_project_current_facts b,
                    niku_tst.nbi_resource_current_facts c
              WHERE a.projectid = b.project_id
                AND a.resourceid = c.resource_id
                AND c.is_role = 0
           GROUP BY c.obs1_unit_id,
                    b.project_name;

        -- insert the over 300 hour SR's summary data
        INSERT INTO trg_nr20b_temp(
                    type,
                    obs_unit_id,
                    project_name,
                    actual_qty,
                    etc_qty)
             SELECT 'Service Request' AS type,
                    c.obs1_unit_id AS obs_unit_id,
                    b.project_name AS project_name,
                    SUM(a.actual_qty) AS actual_qty,
                    SUM(a.etc_qty) AS etc_qty
               FROM niku_tst.nbi_resource_current_facts c,
                    niku_tst.nbi_prt_facts a,
                    niku_tst.nbi_project_current_facts b
              WHERE c.is_role = 0
                AND c.resource_id = a.resource_id
                AND a.fact_date BETWEEN x_startdate AND x_enddate
                AND (NVL(a.actual_qty,0) > 0 OR NVL(a.etc_qty,0) > 0)
                AND a.project_id = b.project_id
                AND UPPER(SUBSTR(b.project_code,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
           GROUP BY c.obs1_unit_id,
                    b.project_name;

    END IF;

    IF x_plan_type IN ('TRG_WP_PROJECT','TRG_WP_ALL') THEN

        -- insert the project summary data
        INSERT INTO trg_nr20b_temp(
                    type,
                    obs_unit_id,
                    project_name,
                    actual_qty,
                    etc_qty)
             SELECT 'Project' AS type,
                    c.obs1_unit_id AS obs_unit_id,
                    b.project_name AS project_name,
                    SUM(a.actual_qty) AS actual_qty,
                    SUM(a.etc_qty) AS etc_qty
               FROM niku_tst.nbi_resource_current_facts c,
                    niku_tst.nbi_prt_facts a,
                    niku_tst.nbi_project_current_facts b
              WHERE c.is_role = 0
                AND c.resource_id = a.resource_id
                AND (NVL(a.actual_qty,0) > 0 OR NVL(a.etc_qty,0) > 0)
                AND a.project_id = b.project_id
                AND a.fact_date BETWEEN x_startdate AND x_enddate
                AND SUBSTR(b.project_code,1,2) <> 'SR'
                AND UPPER(SUBSTR(b.project_code,1,2)) <> 'SU'
                AND UPPER(SUBSTR(b.project_code,1,2)) NOT IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
           GROUP BY c.obs1_unit_id,
                    b.project_name;

    END IF;
    
    IF x_plan_type IN ('TRG_WP_SUSTAINMENT','TRG_WP_ALL') THEN

        -- insert the sustainment summary data
        INSERT INTO trg_nr20b_temp(
                    type,
                    obs_unit_id,
                    project_name,
                    actual_qty,
                    etc_qty)
             SELECT 'Sustainment' AS type,
                    c.obs1_unit_id AS obs_unit_id,
                    b.project_name AS project_name,
                    SUM(a.actual_qty) AS actual_qty,
                    SUM(a.etc_qty) AS etc_qty
               FROM niku_tst.nbi_resource_current_facts c,
                    niku_tst.nbi_prt_facts a,
                    niku_tst.nbi_project_current_facts b
              WHERE c.is_role = 0
                AND c.resource_id = a.resource_id
                AND (NVL(a.actual_qty,0) > 0 OR NVL(a.etc_qty,0) > 0)
                AND a.project_id = b.project_id
                AND a.fact_date BETWEEN x_startdate AND x_enddate
                AND UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
                AND SUBSTR(b.project_code,1,2) <> 'SR'
                AND UPPER(SUBSTR(b.project_code,1,2)) NOT IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
           GROUP BY c.obs1_unit_id,
                    b.project_name;

    END IF;
    
    -- set the orgchart and path for the matching table entries
    UPDATE trg_nr20b_temp a
       SET (orgchart,path) =
           (SELECT CASE WHEN e.hierarchy_level = 1
                        THEN e.level1_name
                        WHEN e.hierarchy_level = 2
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
              FROM niku_tst.nbi_dim_obs e
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
    DELETE trg_nr20b_temp a
     WHERE a.orgchart IS NULL;

    FOR loop_counter IN 1 .. 3
    LOOP

        IF loop_counter = 1 THEN
            plan_type := 'Project';
        ELSIF loop_counter = 2 THEN
            plan_type := 'Service Request';
        ELSIF loop_counter = 3 THEN
            plan_type := 'Sustainment';
        END IF;

        IF (x_plan_type = 'TRG_WP_PROJECT' AND loop_counter = 1)
        OR (x_plan_type = 'TRG_WP_SERVICE_REQUEST' AND loop_counter = 2)
        OR (x_plan_type = 'TRG_WP_SUSTAINMENT' AND loop_counter = 3)
        OR x_plan_type = 'TRG_WP_ALL'
        THEN

            -- insert all orgchart entries that have no matching entries already
            INSERT INTO trg_nr20b_temp(
                        type,
                        orgchart,
                        path)
                 SELECT plan_type AS type,
                        CASE WHEN e.hierarchy_level = 1
                             THEN e.level1_name
                             WHEN e.hierarchy_level = 2
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
                   FROM niku_tst.nbi_dim_obs e
                  WHERE (   (e.level1_unit_id = xOBSUnit AND 1 = nOBSLevel)
                     OR     (e.level2_unit_id = xOBSUnit AND 2 = nOBSLevel)
                     OR     (e.level3_unit_id = xOBSUnit AND 3 = nOBSLevel)
                     OR     (e.level4_unit_id = xOBSUnit AND 4 = nOBSLevel)
                     OR     (e.level5_unit_id = xOBSUnit AND 5 = nOBSLevel)
                     OR     (e.level6_unit_id = xOBSUnit AND 6 = nOBSLevel)
                     OR     (e.level7_unit_id = xOBSUnit AND 7 = nOBSLevel)
                     OR     (e.level8_unit_id = xOBSUnit AND 8 = nOBSLevel)
                     OR     (e.level9_unit_id = xOBSUnit AND 9 = nOBSLevel)
                     OR     (e.level10_unit_id = xOBSUnit AND 10 = nOBSLevel)
                        )
                    AND e.obs_type_name = 'TRG Organization'
                    AND e.obs_unit_id NOT IN (SELECT b.obs_unit_id
                                                FROM trg_nr20b_temp b
                                               WHERE b.type = plan_type);

        END IF;

    END LOOP;

    OPEN a_cursor FOR
        SELECT a.type AS type,
               a.orgchart AS orgchart,
               a.project_name AS project_name,
               SUM(a.actual_qty) AS actual_qty,
               SUM(a.etc_qty) AS etc_qty
          FROM trg_nr20b_temp a
      GROUP BY a.type,
               a.orgchart,
               a.path,
               a.project_name
      ORDER BY a.type,
               a.path,
               a.project_name;

END TRG_RPT_NR20_SP;
