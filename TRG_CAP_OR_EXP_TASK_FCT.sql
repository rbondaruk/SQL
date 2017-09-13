CREATE OR REPLACE FUNCTION TRG_CAP_OR_EXP_TASK_FCT (taskid IN prtask.prid%TYPE)
    RETURN prtask.prshortname%TYPE
IS
    return_value prtask.prshortname%TYPE;
    predid       prdependency.prpredtaskid%TYPE;
BEGIN

    predid := taskid;    
    LOOP

        SELECT UPPER(t.prshortname)
          INTO return_value
          FROM prtask t
         WHERE t.prid = predid;

        EXIT WHEN return_value IN ('CAP','EXP');

        BEGIN
            SELECT p.prpredtaskid
              INTO predid
              FROM prdependency p
             WHERE p.prsucctaskid = taskid;
             
        IF predid = NULL OR predid = '' THEN
            return_value := NULL;
            EXIT WHEN predid = NULL;
        END IF;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                return_value := NULL;
        END;
        
    END LOOP;
     
    RETURN return_value;
END;

