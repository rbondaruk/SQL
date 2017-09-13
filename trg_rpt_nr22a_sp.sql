CREATE OR REPLACE PROCEDURE trg_rpt_nr22_sp(
    a_cursor           IN OUT TYPES.cursorType,
    p_startdate        IN     VARCHAR2,
    p_enddate          IN     VARCHAR2,
    r_id               IN     srm_resources.id%TYPE,
    p_id               IN     srm_projects.id%TYPE,
    r_manager_id       IN     srm_resources.manager_id%TYPE
)

IS
   x_startdate   nbi_prt_facts.fact_date%TYPE;
   x_enddate     nbi_prt_facts.fact_date%TYPE;

BEGIN
    IF p_startdate = '' OR p_startdate IS NULL THEN
       SELECT TRUNC(MIN(a.fact_date))
         INTO x_startdate
         FROM nbi_project_res_task_facts a;
    ELSE
       x_startdate := TRUNC(TO_DATE(p_startdate, 'MM/DD/YYYY'));
    END IF;

    IF p_enddate = '' OR p_enddate IS NULL THEN
       SELECT TRUNC(MAX(a.fact_date))
         INTO x_enddate
         FROM nbi_project_res_task_facts a;
    ELSE
       x_enddate := TRUNC(TO_DATE(p_enddate, 'MM/DD/YYYY'));
    END IF;
    
        OPEN a_cursor FOR
        SELECT z.*,
               ROUND(DECODE(z.avail_hours,0,(z.alloc_hours / 1)*100,
                                      (z.alloc_hours / z.avail_hours)*100),2) alloc_percent,
               x_startdate AS startdate,
               x_enddate AS enddate
          FROM (
                SELECT e.last_name,
                       e.first_name,
                       c.resource_id,
                       e.manager_last_name,
                       e.manager_first_name,
                       e.manager_id,
                       d.project_name,
                       d.project_id,
                       TRUNC(c.fact_date,'WW') week,
                       SUM(NVL(c.allocated_qty,0)) alloc_hours,
                       40 avail_hours
                  FROM nbi_project_res_task_facts c,
                       nbi_project_current_facts d,
                       nbi_resource_current_facts e
                 WHERE c.fact_date BETWEEN x_startdate AND x_enddate
                   AND c.project_id = d.project_id
                   AND c.resource_id = e.resource_id
                   AND e.is_role = 0
              GROUP BY e.last_name,
                       e.first_name,
                       c.resource_id,
                       e.manager_last_name,
                       e.manager_first_name,
                       e.manager_id,
                       d.project_name,
                       d.project_id,
                       TRUNC(c.fact_date,'WW')
               ) z
         WHERE ((z.resource_id = r_id AND NVL(r_id,0) > 0) OR (NVL(r_id,0) = 0))
           AND ((z.project_id = p_id AND NVL(p_id,0) > 0) OR (NVL(p_id,0) = 0))
           AND ((z.manager_id = r_manager_id AND NVL(r_manager_id,0) > 0) OR (NVL(r_manager_id,0) = 0))
      ORDER BY z.last_name,
               z.first_name,
               z.week,
               z.project_name;

END trg_rpt_nr22_sp;
/
