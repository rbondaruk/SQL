                                                          
        SELECT rcf.resource_id,
               rcf.role_name,
               rcf.first_name,
               rcf.last_name,
               SUM(CASE WHEN rf.fact_date BETWEEN SYSDATE AND LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY'))
                    THEN rf.available_hours
                    ELSE 0
                   END) AS cm_available_hours
               SUM(CASE WHEN rf.fact_date BETWEEN LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY'))+1 AND LAST_DAY(LAST_DAY(TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY')) + 1)
                    THEN rf.available_hours
                    ELSE 0
                   END) AS cm_available_hours
          FROM nbi_r_facts rf, NBI_RESOURCE_CURRENT_FACTS rcf
         WHERE rf.resource_id = rcf.resource_id
           AND rcf.role_name IN ('Program Manager','Project Manager','Project Coordinator')
           AND rf.fact_date >= SYSDATE
      GROUP BY rcf.resource_id,
               rcf.role_name,
               rcf.first_name,
               rcf.last_name
      ORDER BY DECODE(rcf.role_name,'Program Manager',    1,
                                    'Project Manager',    2,
                                    'Project Coordinator',3,
                                                          4)



