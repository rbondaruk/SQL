DROP SEQUENCE TRG_RPT_NR09_10_SEQ;

CREATE SEQUENCE TRG_RPT_NR09_10_SEQ INCREMENT BY 1;

DROP TABLE TRG_RPT_NR09_10;

CREATE TABLE TRG_RPT_NR09_10
  (
  RPT_NR09_10_ID NUMBER (5) PRIMARY KEY,
  DISPLAY_DATE DATE NOT NULL,
  DISPLAY_MONTH VARCHAR2(3) NOT NULL,
  OPEN_INCIDENTS NUMBER(5) NOT NULL,
  PLANNED_MILESTONES NUMBER(5) NOT NULL,
  COMPLETED_MILESTONES NUMBER(5) NOT NULL,
  PERCENT_PLANNED NUMBER(5,2) NOT NULL,
  PERCENT_COMPLETED NUMBER(5,2) NOT NULL
 );
 
DELETE TRG_RPT_NR09_10;

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('12/5/2003','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('12/5/2003','MM/DD/YYYY'),'MON')),68,10,10,70.05,64.16);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('12/12/2003','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('12/12/2003','MM/DD/YYYY'),'MON')),52,8,8,72.00,72.57);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('12/19/2003','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('12/19/2003','MM/DD/YYYY'),'MON')),38,18,18,76.15,76.55);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('12/26/2003','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('12/26/2003','MM/DD/YYYY'),'MON')),35,18,18,82.30,82.30);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('1/2/2004','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('1/2/2003','MM/DD/YYYY'),'MON')),29,23,23,91.59,91.59);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('1/9/2004','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('1/9/2003','MM/DD/YYYY'),'MON')),26,12,12,92.00,96.90);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('1/16/2004','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('1/16/2003','MM/DD/YYYY'),'MON')),14,5,4,99.25,98.23);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('1/23/2004','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('1/23/2003','MM/DD/YYYY'),'MON')),9,4,4,99.56,99.56);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('1/30/2004','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('1/30/2003','MM/DD/YYYY'),'MON')),6,1,1,99.56,99.56);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('2/6/2004','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('2/6/2003','MM/DD/YYYY'),'MON')),5,3,3,99.56,99.56);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('2/13/2004','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('2/13/2003','MM/DD/YYYY'),'MON')),0,0,0,99.56,99.56);

INSERT INTO TRG_RPT_NR09_10 (RPT_NR09_10_ID,DISPLAY_DATE,DISPLAY_MONTH,OPEN_INCIDENTS,PLANNED_MILESTONES,COMPLETED_MILESTONES,PERCENT_PLANNED,PERCENT_COMPLETED)
VALUES (TRG_RPT_NR09_10_SEQ.NEXTVAL,TO_DATE('2/20/2004','MM/DD/YYYY'),INITCAP(TO_CHAR(TO_DATE('2/20/2003','MM/DD/YYYY'),'MON')),0,1,1,100.00,100.00);

COMMIT;

