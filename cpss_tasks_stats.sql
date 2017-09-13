/*
    INSERT INTO TRG_TEMP_EPMO_OBS_UNITS(obs_unit_id)
    SELECT obs.obs_unit_id
      FROM NBI_DIM_OBS obs
     WHERE UPPER(obs.obs_type_name) = 'TRGPROJECT'
       AND UPPER(obs.level0_name) = 'ALL'
       AND UPPER(obs.level1_name) = 'ALL REGENCE PROGRAMS - PROJECTS'
       AND UPPER(obs.level2_name) = 'APPROVED PROJECTS'
       AND UPPER(obs.level3_name) = 'COMMON PROCESS - SINGLE SYSTEM'
       AND UPPER(obs.level4_name) = 'PHASE 1';
*/
--ROUND(AVG(t.prduration),2)

SELECT ROUND(AVG(hours.prduration),2) AVG_DURATION
      ,ROUND(AVG(hours.hours),2) AVG_HOURS
      ,ROUND(MAX(hours.prduration),2) MAX_DURATION
      ,ROUND(MAX(hours.hours),2) MAX_HOURS
      ,ROUND(MIN(hours.prduration),2) MIN_DURATION
      ,ROUND(MIN(hours.hours),2) MIN_HOURS
      ,ROUND(STDDEV(hours.prduration),2) STDDEV_DURATION
      ,ROUND(STDDEV(hours.hours),2) STDDEV_HOURS
  FROM (
    SELECT t.prid
          ,t.prduration
          ,ROUND(SUM(a.practsum + a.prestsum)/3600,2) hours
      FROM PRTASK t
          ,PRASSIGNMENT a
          ,PRJ_OBS_ASSOCIATIONS oa
          ,TRG_TEMP_EPMO_OBS_UNITS ou
     WHERE t.pristask = 1
       AND t.prprojectid = oa.record_id
       AND oa.table_name = 'SRM_PROJECTS'
       AND oa.unit_id = ou.obs_unit_id
       AND t.prid = a.prtaskid
  GROUP BY t.prid
          ,t.prduration
) hours


