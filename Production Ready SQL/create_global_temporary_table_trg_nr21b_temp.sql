DROP TABLE trg_nr21b_temp;

CREATE GLOBAL TEMPORARY TABLE trg_nr21b_temp
   (forum        VARCHAR2(25),
    obs_unit_id  NUMBER,
    orgchart     VARCHAR2(96),
    path         VARCHAR2(2000),
    SR_number    VARCHAR2(240),
    SR_name      VARCHAR2(240),
    startdate    DATE,
    finishdate   DATE,
    manager      VARCHAR2(200),
    actual_qty   NUMBER,
    etc_qty      NUMBER)
;
