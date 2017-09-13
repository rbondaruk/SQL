SELECT z.work_type,
       z.project_code,
       z.project_name,
       z.staff_name,
       z.contractor,
       SUM(z.Jan) AS Jan,
       SUM(z.Feb) AS Feb,
       SUM(z.Mar) AS Mar,
       SUM(z.Apr) AS Apr,
       SUM(z.May) AS May,
       SUM(z.Jun) AS Jun,
       SUM(z.Jul) AS Jul,
       SUM(z.Aug) AS Aug,
       SUM(z.Sep) AS Sep,
       SUM(z.Oct) AS Oct,
       SUM(z.Nov) AS Nov,
       SUM(z.Dec) AS Dec,
       z.manager,
       z.hours_type
FROM (
-- Get the actuals
                 SELECT CASE WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SR'
                             THEN 'Service Request'
                             WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
                             THEN 'Sustainment'
                             ELSE 'Project'
                        END AS work_type,
                        b.project_code,
                        b.project_name AS project_name,
                        c.first_name || ' ' || c.last_name AS staff_name,
                        DECODE(UPPER(SUBSTR(c.resource_code,1,1)),'R','N','Y') AS contractor,
                        'Actual' AS hours_type,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'01',SUM(a.actual_qty),0) AS Jan,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'02',SUM(a.actual_qty),0) AS Feb,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'03',SUM(a.actual_qty),0) AS Mar,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'04',SUM(a.actual_qty),0) AS Apr,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'05',SUM(a.actual_qty),0) AS May,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'06',SUM(a.actual_qty),0) AS Jun,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'07',SUM(a.actual_qty),0) AS Jul,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'08',SUM(a.actual_qty),0) AS Aug,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'09',SUM(a.actual_qty),0) AS Sep,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'10',SUM(a.actual_qty),0) AS Oct,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'11',SUM(a.actual_qty),0) AS Nov,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'12',SUM(a.actual_qty),0) AS Dec,
                        c.manager_first_name || ' ' || c.manager_last_name AS manager
                   FROM nbi_resource_current_facts c,
                        nbi_project_res_task_facts a,
                        nbi_project_current_facts b
                  WHERE c.resource_id = a.resource_id
                    AND a.fact_date BETWEEN TRUNC(TO_DATE('01/01/2005','MM/DD/YYYY')) AND TRUNC(TO_DATE('01/01/2006','MM/DD/YYYY'))
                    AND a.fact_date < (
                        SELECT TRUNC(MIN(b.day)) - 2
                          FROM nbi_dim_calendar_time a, nbi_dim_calendar_time b
                         WHERE a.day = TRUNC(SYSDATE)
                           AND a.week_key = b.week_key)
                    AND (NVL(a.actual_qty,0) > 0 OR NVL(a.base_qty,0) > 0)
                    AND a.project_id = b.project_id
                    AND a.obs1_unit_id IN (
                        SELECT DISTINCT o.obs_unit_id
                          FROM nbi_dim_obs o
                         WHERE o.obs_type_name = 'TRGOrg'
                           AND o.level2_name = 'A')
               GROUP BY CASE WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SR'
                             THEN 'Service Request'
                             WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
                             THEN 'Sustainment'
                             ELSE 'Project'
                        END,
                        b.project_code,
                        b.project_name,
                        c.first_name,
                        c.last_name,
                        c.manager_first_name,
                        c.manager_last_name,
                        DECODE(UPPER(SUBSTR(c.resource_code,1,1)),'R','N','Y'),
                        a.obs1_unit_id,
                        TO_CHAR(a.fact_date,'MM')
UNION
-- Get the ETC
                 SELECT CASE WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SR'
                             THEN 'Service Request'
                             WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
                             THEN 'Sustainment'
                             ELSE 'Project'
                        END AS work_type,
                        b.project_code,
                        b.project_name AS project_name,
                        c.first_name || ' ' || c.last_name AS staff_name,
                        DECODE(UPPER(SUBSTR(c.resource_code,1,1)),'R','N','Y') AS contractor,
                        'ETC' AS hours_type,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'01',SUM(a.etc_qty),0) AS Jan,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'02',SUM(a.etc_qty),0) AS Feb,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'03',SUM(a.etc_qty),0) AS Mar,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'04',SUM(a.etc_qty),0) AS Apr,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'05',SUM(a.etc_qty),0) AS May,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'06',SUM(a.etc_qty),0) AS Jun,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'07',SUM(a.etc_qty),0) AS Jul,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'08',SUM(a.etc_qty),0) AS Aug,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'09',SUM(a.etc_qty),0) AS Sep,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'10',SUM(a.etc_qty),0) AS Oct,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'11',SUM(a.etc_qty),0) AS Nov,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'12',SUM(a.etc_qty),0) AS Dec,
                        c.manager_first_name || ' ' || c.manager_last_name AS manager
                   FROM nbi_resource_current_facts c,
                        nbi_project_res_task_facts a,
                        nbi_project_current_facts b
                  WHERE c.resource_id = a.resource_id
                    AND a.fact_date BETWEEN TRUNC(TO_DATE('01/01/2005','MM/DD/YYYY')) AND TRUNC(TO_DATE('01/01/2006','MM/DD/YYYY'))
                    AND a.fact_date >= (
                        SELECT TRUNC(MIN(b.day)) - 2
                          FROM nbi_dim_calendar_time a, nbi_dim_calendar_time b
                         WHERE a.day = TRUNC(SYSDATE)
                           AND a.week_key = b.week_key)
                    AND (NVL(a.actual_qty,0) > 0 OR NVL(a.base_qty,0) > 0)
                    AND a.project_id = b.project_id
                    AND a.obs1_unit_id IN (
                        SELECT DISTINCT o.obs_unit_id
                          FROM nbi_dim_obs o
                         WHERE o.obs_type_name = 'TRGOrg'
                           AND o.level2_name = 'A')
               GROUP BY CASE WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SR'
                             THEN 'Service Request'
                             WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
                             THEN 'Sustainment'
                             ELSE 'Project'
                        END,
                        b.project_code,
                        b.project_name,
                        c.first_name,
                        c.last_name,
                        c.manager_first_name,
                        c.manager_last_name,
                        DECODE(UPPER(SUBSTR(c.resource_code,1,1)),'R','N','Y'),
                        a.obs1_unit_id,
                        TO_CHAR(a.fact_date,'MM')
UNION
-- Get the Allocation
                 SELECT CASE WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SR'
                             THEN 'Service Request'
                             WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
                             THEN 'Sustainment'
                             ELSE 'Project'
                        END AS work_type,
                        b.project_code,
                        b.project_name AS project_name,
                        c.first_name || ' ' || c.last_name AS staff_name,
                        DECODE(UPPER(SUBSTR(c.resource_code,1,1)),'R','N','Y') AS contractor,
                        'Allocation' AS hours_type,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'01',SUM(a.etc_qty),0) AS Jan,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'02',SUM(a.etc_qty),0) AS Feb,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'03',SUM(a.etc_qty),0) AS Mar,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'04',SUM(a.etc_qty),0) AS Apr,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'05',SUM(a.etc_qty),0) AS May,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'06',SUM(a.etc_qty),0) AS Jun,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'07',SUM(a.etc_qty),0) AS Jul,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'08',SUM(a.etc_qty),0) AS Aug,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'09',SUM(a.etc_qty),0) AS Sep,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'10',SUM(a.etc_qty),0) AS Oct,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'11',SUM(a.etc_qty),0) AS Nov,
                        DECODE(TO_CHAR(a.fact_date,'MM'),'12',SUM(a.etc_qty),0) AS Dec,
                        c.manager_first_name || ' ' || c.manager_last_name AS manager
                   FROM nbi_resource_current_facts c,
                        nbi_project_res_task_facts a,
                        nbi_project_current_facts b
                  WHERE c.resource_id = a.resource_id
                    AND a.fact_date BETWEEN TRUNC(TO_DATE('01/01/2005','MM/DD/YYYY')) AND TRUNC(TO_DATE('01/01/2006','MM/DD/YYYY'))
                    AND (NVL(a.actual_qty,0) > 0 OR NVL(a.base_qty,0) > 0)
                    AND a.project_id = b.project_id
                    AND a.obs1_unit_id IN (
                        SELECT DISTINCT o.obs_unit_id
                          FROM nbi_dim_obs o
                         WHERE o.obs_type_name = 'TRGOrg'
                           AND o.level2_name = 'A')
               GROUP BY CASE WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SR'
                             THEN 'Service Request'
                             WHEN UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
                             THEN 'Sustainment'
                             ELSE 'Project'
                        END,
                        b.project_code,
                        b.project_name,
                        c.first_name,
                        c.last_name,
                        c.manager_first_name,
                        c.manager_last_name,
                        DECODE(UPPER(SUBSTR(c.resource_code,1,1)),'R','N','Y'),
                        a.obs1_unit_id,
                        TO_CHAR(a.fact_date,'MM')
) z
GROUP BY z.work_type,
         z.project_code,
         z.project_name,
         z.staff_name,
         z.contractor,
         z.manager,
         z.hours_type

