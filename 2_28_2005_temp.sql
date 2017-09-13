select *
from (
select CASE WHEN e.hierarchy_level = 1
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
                    z.type,
                    z.project_name,
                    z.last_name,
                    z.actual_qty,
                    z.etc_qty
from nbi_dim_obs e,
(
             SELECT 'Sustainment' AS type,
                    c.obs1_unit_id AS obs_unit_id,
                    b.project_name AS project_name,
                    SUM(a.actual_qty) AS actual_qty,
                    SUM(a.etc_qty) AS etc_qty,
                    c.last_name
               FROM nbi_resource_current_facts c,
                    nbi_prt_facts a,
                    nbi_project_current_facts b
              WHERE c.is_role = 0
                AND c.resource_id = a.resource_id
                AND (NVL(a.actual_qty,0) > 0 OR NVL(a.etc_qty,0) > 0)
                AND a.project_id = b.project_id
                AND b.project_name = '2005 BRM Sustainment Work'
                AND a.fact_date BETWEEN TRUNC(TO_DATE('01/01/2005', 'MM/DD/YYYY')) AND TRUNC(TO_DATE('02/28/2005', 'MM/DD/YYYY'))
                AND UPPER(SUBSTR(b.project_code,1,2)) = 'SU'
                AND SUBSTR(b.project_code,1,2) <> 'SR'
                AND NOT (UPPER(SUBSTR(b.project_code,1,2)) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
                    AND SUBSTR(b.project_code,5,1) = '-')
           GROUP BY c.obs1_unit_id,
                    b.project_name,
                    c.last_name
) z
where e.obs_unit_id = z.obs_unit_id
) x
order by x.orgchart

