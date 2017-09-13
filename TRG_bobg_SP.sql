CREATE OR REPLACE PROCEDURE TRG_bobg_SP

IS

BEGIN

-- clear the old data
delete trg_bobg_temp;

-- Get the actuals
                 INSERT INTO trg_bobg_temp
                    (projectid, resource_id, hours_type, Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec)
                 SELECT a.project_id,
                        a.resource_id,
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
                        DECODE(TO_CHAR(a.fact_date,'MM'),'12',SUM(a.actual_qty),0) AS Dec
                   FROM niku.nbi_project_res_task_facts a
                  WHERE a.fact_date BETWEEN TRUNC(TO_DATE('01/01/2005','MM/DD/YYYY')) AND TRUNC(TO_DATE('01/01/2006','MM/DD/YYYY'))
                    AND a.fact_date < (
                        SELECT TRUNC(MIN(b.day)) - 2
                          FROM niku.nbi_dim_calendar_time a, niku.nbi_dim_calendar_time b
                         WHERE a.day = TRUNC(SYSDATE)
                           AND a.week_key = b.week_key)
                    AND (NVL(a.actual_qty,0) > 0 OR NVL(a.base_qty,0) > 0)
                    AND a.obs1_unit_id IN (
                        SELECT DISTINCT o.obs_unit_id
                          FROM niku.nbi_dim_obs o
                         WHERE o.obs_type_name = 'TRGOrg'
                           AND o.level2_name = 'A')
               GROUP BY a.project_id,
                        a.resource_id,
                        a.obs1_unit_id,
                        TO_CHAR(a.fact_date,'MM');

-- Get the ETC
                 INSERT INTO trg_bobg_temp
                    (projectid, resource_id, hours_type, Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec)
                 SELECT a.project_id,
                        a.resource_id,
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
                        DECODE(TO_CHAR(a.fact_date,'MM'),'12',SUM(a.etc_qty),0) AS Dec
                   FROM niku.nbi_project_res_task_facts a
                  WHERE a.fact_date BETWEEN TRUNC(TO_DATE('01/01/2005','MM/DD/YYYY')) AND TRUNC(TO_DATE('01/01/2006','MM/DD/YYYY'))
                    AND a.fact_date >= (
                        SELECT TRUNC(MIN(b.day)) - 2
                          FROM niku.nbi_dim_calendar_time a, niku.nbi_dim_calendar_time b
                         WHERE a.day = TRUNC(SYSDATE)
                           AND a.week_key = b.week_key)
                    AND (NVL(a.actual_qty,0) > 0 OR NVL(a.base_qty,0) > 0)
                    AND a.obs1_unit_id IN (
                        SELECT DISTINCT o.obs_unit_id
                          FROM niku.nbi_dim_obs o
                         WHERE o.obs_type_name = 'TRGOrg'
                           AND o.level2_name = 'A')
               GROUP BY a.project_id,
                        a.resource_id,
                        a.obs1_unit_id,
                        TO_CHAR(a.fact_date,'MM');

-- Get the Allocation
                 INSERT INTO trg_bobg_temp
                    (projectid, resource_id, hours_type, Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec)
                 SELECT a.project_id,
                        a.resource_id,
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
                        DECODE(TO_CHAR(a.fact_date,'MM'),'12',SUM(a.etc_qty),0) AS Dec
                   FROM niku.nbi_project_res_task_facts a
                  WHERE a.fact_date BETWEEN TRUNC(TO_DATE('01/01/2005','MM/DD/YYYY')) AND TRUNC(TO_DATE('01/01/2006','MM/DD/YYYY'))
                    AND (NVL(a.actual_qty,0) > 0 OR NVL(a.base_qty,0) > 0)
                    AND a.obs1_unit_id IN (
                        SELECT DISTINCT o.obs_unit_id
                          FROM niku.nbi_dim_obs o
                         WHERE o.obs_type_name = 'TRGOrg'
                           AND o.level2_name = 'A')
               GROUP BY a.project_id,
                        a.resource_id,
                        a.obs1_unit_id,
                        TO_CHAR(a.fact_date,'MM');
    
COMMIT;

END TRG_bobg_SP;
/
