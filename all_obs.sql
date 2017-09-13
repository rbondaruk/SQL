  SELECT T.unique_name,
         T.category,
         T.name,
         l.obs_level,
         l.name level_name,
         u.parent_id,
         u.depth,
         u.unique_name unit_unique_name,
         u.name unit_name,
         u2.unique_name parent_unique_name,
         u2.name parent_name   
    FROM prj_obs_types T,
         prj_obs_levels l,
         prj_obs_units u,
         prj_obs_units u2   
   WHERE T.id = u.type_id
     AND u.type_id = l.type_id
     AND u.depth = l.obs_level
     AND u.parent_id = u2.id (+)
ORDER BY T.unique_name, u.depth, u2.name, u.unique_name

