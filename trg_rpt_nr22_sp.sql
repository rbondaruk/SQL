CREATE OR REPLACE PROCEDURE trg_rpt_nr22_sp(
    a_cursor           IN OUT TYPES.cursorType,
    p_startdate        IN     VARCHAR2,
    p_enddate          IN     VARCHAR2,
    r_id               IN     srm_resources.id%TYPE,
    p_id               IN     srm_projects.id%TYPE,
    r_manager_id       IN     srm_resources.manager_id%TYPE,
    only_overallocated IN     INTEGER DEFAULT 0,
    order_by           IN     VARCHAR2
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
    
    IF order_by = '' OR order_by IS NULL OR order_by = 'Resource' THEN
    
        OPEN a_cursor FOR
        SELECT z.*,
               ROUND(DECODE(z.avail_hours,0,(z.alloc_hours / 1)*100,
                                      (z.alloc_hours / z.avail_hours)*100),2) alloc_percent,
               ROUND(DECODE(z.total_alloc_hours,0,0,
                                      (z.alloc_hours / z.total_alloc_hours)*100),2) percent_of_total_alloc,
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
                       SUM(NVL(c.allocated_qty,0)) alloc_hours,
                       (
                        SELECT SUM(NVL(b.available_hours,0))
                          FROM nbi_r_facts b
                         WHERE b.resource_id = c.resource_id
                           AND b.fact_date BETWEEN x_startdate AND x_enddate
                       ) avail_hours,
                       (
                        SELECT SUM(NVL(a.allocated_qty,0))
                          FROM nbi_project_res_task_facts a
                         WHERE a.resource_id = c.resource_id
                           AND a.fact_date BETWEEN x_startdate AND x_enddate
                       ) total_alloc_hours
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
                       d.project_id
               ) z
         WHERE ((z.resource_id = r_id AND NVL(r_id,0) > 0) OR (NVL(r_id,0) = 0))
           AND ((z.project_id = p_id AND NVL(p_id,0) > 0) OR (NVL(p_id,0) = 0))
           AND ((z.manager_id = r_manager_id AND NVL(r_manager_id,0) > 0) OR (NVL(r_manager_id,0) = 0))
           AND ((z.total_alloc_hours > z.avail_hours AND only_overallocated = 1) OR only_overallocated = 0)
      ORDER BY z.last_name,
               z.first_name,
               z.project_name;

    ELSIF order_by = 'Project' THEN

        OPEN a_cursor FOR
        SELECT z.*,
               ROUND(DECODE(z.avail_hours,0,(z.alloc_hours / 1)*100,
                                      (z.alloc_hours / z.avail_hours)*100),2) alloc_percent,
               ROUND(DECODE(z.total_alloc_hours,0,0,
                                      (z.alloc_hours / z.total_alloc_hours)*100),2) percent_of_total_alloc,
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
                       SUM(NVL(c.allocated_qty,0)) alloc_hours,
                       (
                        SELECT SUM(NVL(b.available_hours,0))
                          FROM nbi_r_facts b
                         WHERE b.resource_id = c.resource_id
                           AND b.fact_date BETWEEN x_startdate AND x_enddate
                       ) avail_hours,
                       (
                        SELECT SUM(NVL(a.allocated_qty,0))
                          FROM nbi_project_res_task_facts a
                         WHERE a.resource_id = c.resource_id
                           AND a.fact_date BETWEEN x_startdate AND x_enddate
                       ) total_alloc_hours
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
                       d.project_id
               ) z
         WHERE ((z.resource_id = r_id AND NVL(r_id,0) > 0) OR (NVL(r_id,0) = 0))
           AND ((z.project_id = p_id AND NVL(p_id,0) > 0) OR (NVL(p_id,0) = 0))
           AND ((z.manager_id = r_manager_id AND NVL(r_manager_id,0) > 0) OR (NVL(r_manager_id,0) = 0))
           AND ((z.total_alloc_hours > z.avail_hours AND only_overallocated = 1) OR only_overallocated = 0)
      ORDER BY z.project_name,
               z.last_name,
               z.first_name;

    ELSIF order_by = 'Resource Manager' THEN

        OPEN a_cursor FOR
        SELECT z.*,
               ROUND(DECODE(z.avail_hours,0,(z.alloc_hours / 1)*100,
                                      (z.alloc_hours / z.avail_hours)*100),2) alloc_percent,
               ROUND(DECODE(z.total_alloc_hours,0,0,
                                      (z.alloc_hours / z.total_alloc_hours)*100),2) percent_of_total_alloc,
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
                       SUM(NVL(c.allocated_qty,0)) alloc_hours,
                       (
                        SELECT SUM(NVL(b.available_hours,0))
                          FROM nbi_r_facts b
                         WHERE b.resource_id = c.resource_id
                           AND b.fact_date BETWEEN x_startdate AND x_enddate
                       ) avail_hours,
                       (
                        SELECT SUM(NVL(a.allocated_qty,0))
                          FROM nbi_project_res_task_facts a
                         WHERE a.resource_id = c.resource_id
                           AND a.fact_date BETWEEN x_startdate AND x_enddate
                       ) total_alloc_hours
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
                       d.project_id
               ) z
         WHERE ((z.resource_id = r_id AND NVL(r_id,0) > 0) OR (NVL(r_id,0) = 0))
           AND ((z.project_id = p_id AND NVL(p_id,0) > 0) OR (NVL(p_id,0) = 0))
           AND ((z.manager_id = r_manager_id AND NVL(r_manager_id,0) > 0) OR (NVL(r_manager_id,0) = 0))
           AND ((z.total_alloc_hours > z.avail_hours AND only_overallocated = 1) OR only_overallocated = 0)
      ORDER BY z.manager_last_name,
               z.manager_first_name,
               z.last_name,
               z.first_name,
               z.manager_first_name;

    END IF;

END trg_rpt_nr22_sp;
/
