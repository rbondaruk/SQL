CREATE OR REPLACE PROCEDURE TRG_RPT_NR21_SP (
   a_cursor        IN OUT TYPES.cursorType,
   p_startdate     IN       VARCHAR2,
   p_enddate       IN       VARCHAR2
)

IS
   x_startdate   nbi_prt_facts.fact_date%TYPE;
   x_enddate     nbi_prt_facts.fact_date%TYPE;

BEGIN
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

    OPEN a_cursor FOR
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
             END AS business_forum,
             SUBSTR(e.path,33) AS orgchart,
             b.project_name,
             NVL(SUM(a.actual_qty),0) AS actual_qty,
             NVL(SUM(a.etc_qty),0) AS etc_qty
        FROM nbi_dim_obs e,
             nbi_resource_current_facts c,
             nbi_prt_facts a,
             nbi_project_current_facts b,
             prtask d
       WHERE e.level2_unit_id = 5000018
         AND e.obs_unit_id = c.obs1_unit_id (+)
         AND c.is_role (+) = 0
         AND c.resource_id = a.resource_id (+)
         AND a.fact_date (+) BETWEEN x_startdate AND x_enddate
         AND a.project_id = b.project_id (+)
         AND SUBSTR(b.project_code,1,2) IN ('FN','HR','RT','SL','MK','MS','HC') -- Finance,Human Resources,RITS,Sales,Marketing,Member Services,Health Care Services
         AND a.task_id = d.prid (+)
         AND a.project_id = d.prprojectid (+)
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
             END,
             e.path,
             b.project_name
    ORDER BY CASE WHEN SUBSTR(b.project_code,1,2) = 'FN' -- Finance
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
             END,
             e.path;

END TRG_RPT_NR21_SP;
/
