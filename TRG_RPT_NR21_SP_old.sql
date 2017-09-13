CREATE OR REPLACE PROCEDURE TRG_RPT_NR21_SP (
    a_cursor        IN OUT TYPES.cursorType,
    nOBSUnit        IN     NUMBER DEFAULT 0,
    nOBSLevel       IN     NUMBER,
    p_startdate     IN     VARCHAR2,
    p_enddate       IN     VARCHAR2,
    p_forum         IN     VARCHAR2
)

IS
    CURSOR projects_cur
    IS
        SELECT DISTINCT b.project_id
          FROM nbi_project_current_facts b
         WHERE SUBSTR(b.project_code,1,2) = 'SR';

    CURSOR phases_cur(p_id nbi_project_current_facts.project_id%TYPE)
    IS
        SELECT a.prwbssequence,
               SUBSTR(a.prname,1,2) AS forum
          FROM prtask a
         WHERE a.prwbslevel = 1
           AND a.prprojectid = p_id
           AND UPPER(SUBSTR(a.prname,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
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
           AND a.prwbssequence < wbsseq_2
           AND a.prid = b.prtaskid;

    xOBSUnit      NUMBER;
    x_startdate   nbi_prt_facts.fact_date%TYPE;
    x_enddate     nbi_prt_facts.fact_date%TYPE;
    x_forum       VARCHAR2(25);
    first_wbsseq  prtask.prwbssequence%TYPE;
    second_wbsseq prtask.prwbssequence%TYPE;
    forum1        VARCHAR2(2);
    forum2        VARCHAR2(2);
    loop_counter  NUMBER(1);
    forum_name    VARCHAR2(25);

BEGIN
    IF nOBSUnit = 0 THEN
        xOBSUnit := NULL;
    ELSE
        xOBSUnit := nOBSUnit;
    END IF;

    IF p_forum = 'TRG_FORUM_FN' THEN
        x_forum := 'TRG_FORUM_FN';
    ELSIF p_forum = 'TRG_FORUM_HC' THEN
        x_forum := 'TRG_FORUM_HC';
    ELSIF p_forum = 'TRG_FORUM_HR' THEN
        x_forum := 'TRG_FORUM_HR';
    ELSIF p_forum = 'TRG_FORUM_MK' THEN
        x_forum := 'TRG_FORUM_MK';
    ELSIF p_forum = 'TRG_FORUM_MS' THEN
        x_forum := 'TRG_FORUM_MS';
    ELSIF p_forum = 'TRG_FORUM_RITS' THEN
        x_forum := 'TRG_FORUM_RITS';
    ELSIF p_forum = 'TRG_FORUM_SL' THEN
        x_forum := 'TRG_FORUM_SL';
    ELSE
        x_forum := 'TRG_FORUM_ALL';
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
                    INSERT INTO trg_nr21_temp(
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
                           FROM nbi_project_res_task_facts a
                          WHERE a.task_id = tasks_rec.prid
                            AND a.fact_date BETWEEN x_startdate AND x_enddate
                            AND a.resource_id = tasks_rec.prresourceid;

                END LOOP;

            END IF;

        END LOOP;

    END LOOP;

    -- insert the under 300 hour SR's summary data
    INSERT INTO trg_nr21b_temp(
                forum,
                obs_unit_id,
                project_name,
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
                c.obs1_unit_id AS obs_unit_id,
                b.project_name AS project_name,
                NVL(SUM(a.actual_qty),0) AS actual_qty,
                NVL(SUM(a.etc_qty),0) AS etc_qty
           FROM trg_nr21_temp a,
                nbi_project_current_facts b,
                nbi_resource_current_facts c
          WHERE a.projectid = b.project_id
            AND a.resourceid = c.resource_id
            AND c.is_role = 0
       GROUP BY a.forum,
                c.obs1_unit_id,
                b.project_name;

    -- insert the over 300 hour SR's summary data
    INSERT INTO trg_nr21b_temp(
                forum,
                obs_unit_id,
                project_name,
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
                c.obs1_unit_id AS obs_unit_id,
                b.project_name AS project_name,
                SUM(a.actual_qty) AS actual_qty,
                SUM(a.etc_qty) AS etc_qty
           FROM nbi_resource_current_facts c,
                nbi_prt_facts a,
                nbi_project_current_facts b
          WHERE c.is_role = 0
            AND c.resource_id = a.resource_id
            AND a.fact_date BETWEEN x_startdate AND x_enddate
            AND (NVL(a.actual_qty,0) > 0 OR NVL(a.etc_qty,0) > 0)
            AND a.project_id = b.project_id
            AND UPPER(SUBSTR(b.project_code,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
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
                c.obs1_unit_id,
                b.project_name;
    
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
               AND e.level2_unit_id = 5000018
               AND (   (e.level2_unit_id = xOBSUnit AND 2 = nOBSLevel)
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

    FOR loop_counter IN 1 .. 7
    LOOP

        IF loop_counter = 1 THEN
            forum_name := 'Finance';
        ELSIF loop_counter = 2 THEN
            forum_name := 'Human Resources';
        ELSIF loop_counter = 3 THEN
            forum_name := 'RITS';
        ELSIF loop_counter = 4 THEN
            forum_name := 'Sales';
        ELSIF loop_counter = 5 THEN
            forum_name := 'Marketing';
        ELSIF loop_counter = 6 THEN
            forum_name := 'Member Services';
        ELSIF loop_counter = 7 THEN
            forum_name := 'Health Care Services';
        END IF;

        IF (x_forum = 'TRG_FORUM_FN' AND loop_counter = 1)
        OR (x_forum = 'TRG_FORUM_HR' AND loop_counter = 2)
        OR (x_forum = 'TRG_FORUM_RITS' AND loop_counter = 3)
        OR (x_forum = 'TRG_FORUM_SL' AND loop_counter = 4)
        OR (x_forum = 'TRG_FORUM_MK' AND loop_counter = 5)
        OR (x_forum = 'TRG_FORUM_MS' AND loop_counter = 6)
        OR (x_forum = 'TRG_FORUM_HC' AND loop_counter = 7)
        OR x_forum = 'TRG_FORUM_ALL'
        THEN

            -- insert all orgchart entries that have no matching entries already
            INSERT INTO trg_nr21b_temp(
                        forum,
                        orgchart,
                        path)
                 SELECT forum_name AS forum,
                        CASE WHEN e.hierarchy_level = 2
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
                  WHERE e.level2_unit_id = 5000018
                    AND (   (e.level2_unit_id = xOBSUnit AND 2 = nOBSLevel)
                         OR (e.level3_unit_id = xOBSUnit AND 3 = nOBSLevel)
                         OR (e.level4_unit_id = xOBSUnit AND 4 = nOBSLevel)
                         OR (e.level5_unit_id = xOBSUnit AND 5 = nOBSLevel)
                         OR (e.level6_unit_id = xOBSUnit AND 6 = nOBSLevel)
                         OR (e.level7_unit_id = xOBSUnit AND 7 = nOBSLevel)
                         OR (e.level8_unit_id = xOBSUnit AND 8 = nOBSLevel)
                         OR (e.level9_unit_id = xOBSUnit AND 9 = nOBSLevel)
                         OR (e.level10_unit_id = xOBSUnit AND 10 = nOBSLevel)
                        )
                    AND e.obs_type_name = 'TRG Organization'
                    AND e.obs_unit_id NOT IN (SELECT b.obs_unit_id
                                                FROM trg_nr21b_temp b
                                               WHERE b.forum = forum_name);

        END IF;

    END LOOP;

    OPEN a_cursor FOR
/*

SELECT 'A TEST PAGE' AS forum,
       'x_forum = ' || x_forum AS orgchart,
       'p_forum = ' || p_forum AS project_name,
       0 AS actual_qty,
       0 AS etc_qty
  FROM DUAL;
*/
        SELECT a.forum AS forum,
               a.orgchart AS orgchart,
               a.project_name AS project_name,
               SUM(a.actual_qty) AS actual_qty,
               SUM(a.etc_qty) AS etc_qty
          FROM trg_nr21b_temp a
      GROUP BY a.forum,
               a.orgchart,
               a.path,
               a.project_name
      ORDER BY a.forum,
               a.path,
               a.project_name;

END TRG_RPT_NR21_SP;
