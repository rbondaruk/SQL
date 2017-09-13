select r.first_name || r.last_name
      ,r.unique_name
      ,b.permission_code
      ,e.component_code
      ,a.*
  from CMN_SEC_ASSGND_OBJ_PERM a
      ,CMN_SEC_PERMISSIONS b
      ,SRM_RESOURCES r
      ,CMN_SEC_OBJECTS d
      ,CMN_COMPONENTS e
 where a.permission_id = b.id
   and a.principal_id = r.id
   and a.object_id = d.id
   and d.component_id = e.id



