DROP TABLE trg_nr21_temp;

CREATE GLOBAL TEMPORARY TABLE trg_nr21_temp
   (projectid    NUMBER NOT NULL,
    taskid       NUMBER NOT NULL,
    resourceid   NUMBER NOT NULL,
    forum        VARCHAR2(2) NOT NULL,
    SR_number    VARCHAR2(240),
    SR_name      VARCHAR2(240),
    startdate    DATE,
    finishdate   DATE,
    fact_date    DATE,
    actual_qty   NUMBER,
    etc_qty      NUMBER)
;

