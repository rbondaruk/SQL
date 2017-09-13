  SELECT e.last_name,
         e.first_name,
         e.resource_code
    FROM nbi_resource_current_facts e
   WHERE e.is_role = 0
     AND e.manager_id IS NULL
ORDER BY e.last_name


