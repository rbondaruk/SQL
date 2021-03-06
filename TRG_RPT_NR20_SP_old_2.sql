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
   x_plan_type   VARCHAR2(25);
   first_wbsseq  prtask.prwbssequence%TYPE;
   second_wbsseq prtask.prwbssequence%TYPE;
   forum1        VARCHAR2(2);
   forum2        VARCHAR2(2);

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
                          FROM nbi_project_res_task_facts a
                         WHERE a.task_id = tasks_rec.prid
                           AND a.fact_date BETWEEN x_startdate AND x_enddate
                           AND a.resource_id = tasks_rec.prresourceid;

                    END LOOP;

                END IF;

            END LOOP;

        END LOOP;

    END IF;

    OPEN a_cursor FOR
      SELECT y.type,
             z.orgchart,
             y.project_name,
             y.actual_qty,
             y.etc_qty
        FROM (
             SELECT e.obs_unit_id,
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
                    e.path,
                    'Project' AS type
               FROM nbi_dim_obs e
              WHERE e.level2_unit_id = 5000018
                AND (   (e.level2_unit_id = 5000018 AND 2 = 2)
                     OR (e.level3_unit_id = 5000018 AND 2 = 3)
                     OR (e.level4_unit_id = 5000018 AND 2 = 4)
                     OR (e.level5_unit_id = 5000018 AND 2 = 5)
                     OR (e.level6_unit_id = 5000018 AND 2 = 6)
                     OR (e.level7_unit_id = 5000018 AND 2 = 7)
                     OR (e.level8_unit_id = 5000018 AND 2 = 8)
                     OR (e.level9_unit_id = 5000018 AND 2 = 9)
                     OR (e.level10_unit_id = 5000018 AND 2 = 10)
                    )

              UNION

             SELECT e.obs_unit_id,
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
                    e.path,
                    'Service Request' AS type
               FROM nbi_dim_obs e
              WHERE e.level2_unit_id = 5000018
                AND (   (e.level2_unit_id = 5000018 AND 2 = 2)
                     OR (e.level3_unit_id = 5000018 AND 2 = 3)
                     OR (e.level4_unit_id = 5000018 AND 2 = 4)
                     OR (e.level5_unit_id = 5000018 AND 2 = 5)
                     OR (e.level6_unit_id = 5000018 AND 2 = 6)
                     OR (e.level7_unit_id = 5000018 AND 2 = 7)
                     OR (e.level8_unit_id = 5000018 AND 2 = 8)
                     OR (e.level9_unit_id = 5000018 AND 2 = 9)
                     OR (e.level10_unit_id = 5000018 AND 2 = 10)
                    )

              UNION

             SELECT e.obs_unit_id,
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
                    e.path,
                    'Sustainment' AS type
               FROM nbi_dim_obs e
              WHERE e.level2_unit_id = 5000018
                AND (   (e.level2_unit_id = 5000018 AND 2 = 2)
                     OR (e.level3_unit_id = 5000018 AND 2 = 3)
                     OR (e.level4_unit_id = 5000018 AND 2 = 4)
                     OR (e.level5_unit_id = 5000018 AND 2 = 5)
                     OR (e.level6_unit_id = 5000018 AND 2 = 6)
                     OR (e.level7_unit_id = 5000018 AND 2 = 7)
                     OR (e.level8_unit_id = 5000018 AND 2 = 8)
                     OR (e.level9_unit_id = 5000018 AND 2 = 9)
                     OR (e.level10_unit_id = 5000018 AND 2 = 10)
                    )
             ) z,
             (
             SELECT c.obs1_unit_id AS obs_unit_id,
                    'Service Request' AS type,
                    b.project_name,
                    NVL(SUM(a.actual_qty),0) AS actual_qty,
                    NVL(SUM(a.etc_qty),0) AS etc_qty
               FROM trg_nr20_temp a,
                    nbi_project_current_facts b,
                    nbi_resource_current_facts c
              WHERE 'TRG_WP_ALL' IN ('TRG_WP_SERVICE_REQUEST','TRG_WP_ALL') --x_plan_type
                AND a.fact_date BETWEEN TRUNC(TO_DATE('01/01/1950', 'MM/DD/YYYY')) AND TRUNC(SYSDATE)
                AND a.projectid = b.project_id
                AND c.is_role = 0
                AND a.resourceid = c.resource_id
           GROUP BY c.obs1_unit_id,
                    b.project_name

              UNION

             SELECT obs_unit_id,
                    type,
                    project_name,
                    SUM(actual_qty) AS actual_qty,
                    SUM(etc_qty) AS etc_qty
               FROM (
             SELECT c.obs1_unit_id AS obs_unit_id,
                    CASE WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
                         THEN 'Sustainment'
                         WHEN UPPER(SUBSTR(b.project_code,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                         THEN 'Service Request'
                         ELSE 'Project'
                    END AS type,
                    b.project_name,
                    a.actual_qty,
                    a.etc_qty
               FROM nbi_resource_current_facts c,
                    nbi_prt_facts a,
                    nbi_project_current_facts b,
                    prtask d
              WHERE c.is_role = 0
                AND c.resource_id = a.resource_id
                AND a.fact_date BETWEEN TRUNC(TO_DATE('01/01/1950', 'MM/DD/YYYY')) AND TRUNC(SYSDATE)
                AND (NVL(a.actual_qty,0) > 0 OR NVL(a.etc_qty,0) > 0)
                AND a.project_id = b.project_id
                AND SUBSTR(b.project_code,1,2) <> 'SR'
                AND a.task_id = d.prid
                AND a.project_id = d.prprojectid
                )
              WHERE ((type = 'Sustainment' AND 'TRG_WP_ALL' IN ('TRG_WP_SUSTAINMENT','TRG_WP_ALL'))
                 OR  (type = 'Service Request' AND 'TRG_WP_ALL' IN ('TRG_WP_SERVICE_REQUEST','TRG_WP_ALL'))
                 OR  (type = 'Project' AND 'TRG_WP_ALL' IN ('TRG_WP_PROJECT','TRG_WP_ALL'))
                    )
           GROUP BY obs_unit_id,
                    type,
                    project_name
       ) y
--WHERE z.obs_unit_id = y.obs_unit_id (+)
--ORDER BY z.path
        WHERE z.obs_unit_id = y.obs_unit_id (+)
          AND z.type = y.type (+)
--     GROUP BY y.type,
--              z.path,
--              z.orgchart,
--              y.project_name
     ORDER BY y.type,
              z.path;
*/
END TRG_RPT_NR20_SP;
