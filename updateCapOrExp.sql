            UPDATE prtask t
               SET t.prshortname = 'EXP'
             WHERE t.prshortname IS NULL
               AND t.prismilestone = 0
               AND EXISTS (SELECT 'x'
                             FROM prtask a,
                                  prj_projects b,
                                  srm_projects c
                            WHERE a.prshortname = 'EXP'
                              AND a.prprojectid = b.prid
                              AND b.prid = c.id
                              AND c.is_active = 1
                              AND a.prprojectid = t.prprojectid
                              AND t.prexternalid LIKE a.prexternalid || '%'
                           )

            UPDATE prtask t
               SET t.prshortname = 'CAP'
             WHERE t.prshortname IS NULL
               AND t.prismilestone = 0
               AND EXISTS (SELECT 'x'
                             FROM prtask a,
                                  prj_projects b,
                                  srm_projects c
                            WHERE a.prshortname = 'CAP'
                              AND a.prprojectid = b.prid
                              AND b.prid = c.id
                              AND c.is_active = 1
                              AND a.prprojectid = t.prprojectid
                              AND t.prexternalid LIKE a.prexternalid || '%'
                           )

