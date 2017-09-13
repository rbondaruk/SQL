DROP TABLE trg_epmo_assignments_3_temp;

CREATE TABLE trg_epmo_assignments_3_temp(
    nikurole           VARCHAR2(96),
    rsc_name           VARCHAR2(240),
    peoplesoft_number  VARCHAR2(60),
    project            VARCHAR2(240),
    prstart            DATE,
    prfinish           DATE,
    cm_available_hours NUMBER(3),
    nm_available_hours NUMBER(3),
    fm_available_hours NUMBER(3),
    cm_etc_hours       NUMBER(3),
    nm_etc_hours       NUMBER(3),
    fm_etc_hours       NUMBER(3),
    current_pcnt       NUMBER(5,2),
    next_pcnt          NUMBER(5,2),
    final_pcnt         NUMBER(5,2));
    
    

