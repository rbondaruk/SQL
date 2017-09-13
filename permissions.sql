select distinct table_name
select *
  from all_tab_columns
 where owner = 'NIKU'
   and data_type = 'VARCHAR2'
   and data_length > 600


select * 
  from CMN_CAPTIONS_NLS a
 where a.language_code = 'en'
   and a.table_name = 'CMN_SEC_GROUPS'


select * 
  from CMN_CAPTIONS_NLS a,
       CMN_SEC_PERMISSIONS b
 where a.language_code = 'en'
   and a.table_name = 'CMN_SEC_GROUPS'
   and a.pk_id = b.id

select * from CMN_SEC_PERMISSIONS

select * 
  from CMN_SEC_OBJ_TYPE_PERM a,
       CMN_LOOKUPS b,
       CMN_SEC_OBJECTS c
 where a.object_type_id = b.id
   and b.id = c.object_type_id
 


select *
  from CMN_SEC_GROUPS a,
       CMN_CAPTIONS_NLS b,
       CMN_LOOKUPS c
 where a.id = b.pk_id
   and b.language_code = 'en'
   and b.table_name = 'CMN_SEC_GROUPS'
   and a.group_role_type = 'ROLE'
   and a.group_type_id = c.id
   
select distinct table_name from CMN_CAPTIONS_NLS

select *
  from CMN_CAPTIONS_NLS a
 where a.table_name = 'CMN_SEC_OBJECTS'
   and a.language_code = 'en'

select * from CMN_SEC_OBJECTS

 

