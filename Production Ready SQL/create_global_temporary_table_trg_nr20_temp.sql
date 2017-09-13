DROP TABLE trg_nr20_temp;

CREATE TABLE trg_nr20_temp(
    (projectid                      NUMBER NOT NULL,
    taskid                         NUMBER NOT NULL,
    resourceid                     NUMBER NOT NULL,
    forum                          VARCHAR2(2) NOT NULL,
    fact_date                      DATE,
    actual_qty                     NUMBER,
    etc_qty                        NUMBER
);
