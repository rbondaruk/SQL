CREATE OR REPLACE PROCEDURE TRG_UPDATE_CAP_EXP_SP

IS
    CURSOR capexp_cur IS
        SELECT t.prprojectid AS projectid,
               t.prexternalid AS externalid,
               t.prshortname AS caporexp
          FROM prtask t,
               prj_projects a,
               srm_projects b
         WHERE t.prshortname IN ('CAP','EXP')
           AND t.prprojectid = a.prid
           AND a.prid = b.id
           AND b.is_active = 1
      ORDER BY t.prprojectid,
               t.prexternalid;
         
    capexp_rec capexp_cur%ROWTYPE;
       
    TYPE record_type IS RECORD (
        projectid prtask.prprojectid%TYPE,
        externalid prtask.prexternalid%TYPE,
        caporexp prtask.prshortname%TYPE);

    TYPE tasks_type IS TABLE OF record_type
        INDEX BY BINARY_INTEGER;
        
    tasks_tab tasks_type;
    insertcnt NUMBER(10);
    readcnt NUMBER(10);
         
    projectid prtask.prid%TYPE;
    externalid prtask.prexternalid%TYPE;
    caporexp prtask.prshortname%TYPE;
    temp number;
BEGIN

    insertcnt := 0;

    FOR capexp_rec IN capexp_cur
    LOOP

        insertcnt := insertcnt + 1;
        tasks_tab(insertcnt).projectid := capexp_rec.projectid;
        tasks_tab(insertcnt).externalid := capexp_rec.externalid;
        tasks_tab(insertcnt).caporexp := capexp_rec.caporexp;
        
    END LOOP;
    
    IF insertcnt > 0 THEN

        readcnt := 1;
        projectid := tasks_tab(readcnt).projectid;
        externalid := tasks_tab(readcnt).externalid;
        caporexp := tasks_tab(readcnt).caporexp;

        LOOP

            UPDATE prtask t
               SET t.prshortname = caporexp
             WHERE t.prprojectid = projectid
               AND t.prexternalid LIKE externalid || '%'
               AND t.prshortname IS NULL
               AND t.prismilestone = 0;

            readcnt := readcnt + 1;

            EXIT WHEN readcnt > insertcnt;

            projectid := tasks_tab(readcnt).projectid;
            externalid := tasks_tab(readcnt).externalid;
            caporexp := tasks_tab(readcnt).caporexp;
    
        END LOOP;
        
        COMMIT;

    END IF;        

END TRG_UPDATE_CAP_EXP_SP;
/
