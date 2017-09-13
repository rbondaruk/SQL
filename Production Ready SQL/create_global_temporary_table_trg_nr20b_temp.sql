DROP TABLE trg_nr20b_temp;

CREATE GLOBAL TEMPORARY TABLE trg_nr20b_temp
   (type         VARCHAR2(20),
    obs_unit_id  NUMBER,
    orgchart     VARCHAR2(96),
    path         VARCHAR2(2000),
    project_name VARCHAR2(240),
    actual_qty   NUMBER,
    etc_qty      NUMBER)
;


