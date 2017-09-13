DROP TABLE trg_epmo_assignments_temp;

CREATE GLOBAL TEMPORARY TABLE trg_epmo_assignments_temp(
    nikurole           VARCHAR2(96),
    rsc_name           VARCHAR2(240),
    peoplesoft_number  VARCHAR2(60),
    project            VARCHAR2(240),
    prstart            DATE,
    prfinish           DATE,
    current_pcnt       NUMBER(5,2),
    next_pcnt          NUMBER(5,2),
    final_pcnt         NUMBER(5,2)) ON COMMIT DELETE ROWS;


