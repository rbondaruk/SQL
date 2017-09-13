CREATE OR REPLACE PROCEDURE trg_rpt_nr02_sp(
    a_cursor        IN OUT TYPES.cursorType,
    nOBSUnit        IN     NUMBER DEFAULT 0,
    nOBSLevel       IN     NUMBER,
    nProject        IN     NUMBER,
    p_startdate     IN     VARCHAR2,
    p_enddate       IN     VARCHAR2
)

IS
    xOBSUnit        NUMBER;
    xProject        NUMBER;
    x_startdate     nbi_prt_facts.fact_date%TYPE;
    x_enddate       nbi_prt_facts.fact_date%TYPE;

BEGIN
    IF nOBSUnit = 0 THEN
        xOBSUnit := NULL;
    ELSE
        xOBSUnit := nOBSUnit;
    END IF;

    IF nProject = 0 THEN
        xProject := NULL;
    ELSE
        xProject := nProject;
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

    IF nOBSUnit = 0 THEN

        OPEN a_cursor FOR
            SELECT  p.project_name,
                    p.manager_first_name || ' ' || p.manager_last_name AS manager,
                    t.prname as key_milestone,
                    t.prbasefinish as baseline_finish,
                    CASE WHEN t.prstatus = 0 -- NotStarted
                         THEN 'Not Started'
                         WHEN t.prstatus = 1 -- Started
                         THEN 'Started'
                         WHEN t.prstatus = 2 -- Completed
                         THEN 'Completed'
                    END as task_status
              FROM  prtask t,
                    nbi_project_current_facts p
             WHERE  t.prbasefinish BETWEEN x_startdate AND x_enddate
               AND  t.prismilestone = 1
               AND  t.priskey = 1
               AND  t.prbasefinish IS NOT NULL
               AND  t.prprojectid = p.project_id
               AND  p.project_id = NVL(xProject, p.project_id)
               AND  p.is_active = 1;

    ELSE

        OPEN a_cursor FOR
            SELECT  p.project_name,
                    p.manager_first_name || ' ' || p.manager_last_name AS manager,
                    t.prname as key_milestone,
                    t.prbasefinish as baseline_finish,
                    CASE WHEN t.prstatus = 0 -- NotStarted
                         THEN 'Not Started'
                         WHEN t.prstatus = 1 -- Started
                         THEN 'Started'
                         WHEN t.prstatus = 2 -- Completed
                         THEN 'Completed'
                    END as task_status
              FROM  prtask t,
                    nbi_project_current_facts p,
                    nbi_dim_obs o
             WHERE  t.prbasefinish BETWEEN x_startdate AND x_enddate
               AND  t.prismilestone = 1
               AND  t.priskey = 1
               AND  t.prbasefinish IS NOT NULL
               AND  t.prprojectid = p.project_id
               AND  p.project_id = NVL(xProject, p.project_id)
               AND  p.is_active = 1
               AND  p.obs1_unit_id = o.obs_unit_id
               AND (   (o.level1_unit_id = xOBSUnit AND 1 = nOBSLevel)
                    OR (o.level2_unit_id = xOBSUnit AND 2 = nOBSLevel)
                    OR (o.level3_unit_id = xOBSUnit AND 3 = nOBSLevel)
                    OR (o.level4_unit_id = xOBSUnit AND 4 = nOBSLevel)
                    OR (o.level5_unit_id = xOBSUnit AND 5 = nOBSLevel)
                    OR (o.level6_unit_id = xOBSUnit AND 6 = nOBSLevel)
                    OR (o.level7_unit_id = xOBSUnit AND 7 = nOBSLevel)
                    OR (o.level8_unit_id = xOBSUnit AND 8 = nOBSLevel)
                    OR (o.level9_unit_id = xOBSUnit AND 9 = nOBSLevel)
                    OR (o.level10_unit_id = xOBSUnit AND 10 = nOBSLevel)
                    )
               ;


    END IF;

END trg_rpt_nr02_sp;
/
