CREATE OR REPLACE PROCEDURE trg_update_reporting_dates_sp
/******************************************************************************

   Author                          	: Robert Bondaruk
   Date Written                    	: 03/29/2004
   Objects invoking this procedure 	: Niku Scheduled Job
   Events Called from              	: None
   Detailed Description            	:
      This proc maintains the data in the trg_reporting_dates table. The table
      contains a rolling thirteen week calendar used by Niku Report NR 09. This
      proc runs weekly and deletes the oldest weekly calendar entry and inserts
      a new entry for the coming week. The trg_reporting_dates table also
      contains a rolling twelve month calendar. When the proc runs during the
      first week of the month it will delete the oldest monthly calendar entry
      and inserts a new entry for the coming month. 
   Modified By                     	:
   Modified Date                   	:
   Modified Desc.                   :

******************************************************************************/

IS
    date_week_begin trg_reporting_dates.begin_date%TYPE;
    date_week_end   trg_reporting_dates.end_date%TYPE;
    date_month_end  trg_reporting_dates.end_date%TYPE;
    num_id          trg_reporting_dates.reporting_date_id%TYPE;
    
BEGIN

    SELECT MAX(rd.end_date) 
      INTO date_week_end
      FROM trg_reporting_dates rd
     WHERE rd.period = 'WEEK';

    IF SYSDATE > date_week_end THEN

        SELECT MAX(rd.begin_date) 
          INTO date_week_begin
          FROM trg_reporting_dates rd
         WHERE rd.period = 'WEEK';

        INSERT INTO trg_reporting_dates (
            reporting_date_id,
            begin_date,
            end_date,
            period)
        VALUES (
            trg_reporting_dates_seq.NEXTVAL,
            date_week_end + 1,
            date_week_end + 7,
            'WEEK');

        SELECT rd.reporting_date_id
          INTO num_id
          FROM trg_reporting_dates rd
         WHERE rd.begin_date = (
               SELECT MIN(r.begin_date)
                 FROM trg_reporting_dates r
                WHERE r.period = 'WEEK');
     
        DELETE trg_reporting_dates
         WHERE reporting_date_id = num_id;
     
    END IF;

    SELECT MAX(rd.end_date) 
      INTO date_month_end
      FROM trg_reporting_dates rd
     WHERE rd.period = 'MONTH';
   
    IF SYSDATE > date_month_end THEN
     
        INSERT INTO trg_reporting_dates (
            reporting_date_id,
            begin_date,
            end_date,
            period)
        VALUES (
            trg_reporting_dates_seq.NEXTVAL,
            TRUNC(SYSDATE,'MM'),
            LAST_DAY(SYSDATE),
            'MONTH');
            
        SELECT rd.reporting_date_id
          INTO num_id
          FROM trg_reporting_dates rd
         WHERE rd.begin_date = (
               SELECT MIN(r.begin_date)
                 FROM trg_reporting_dates r
                WHERE r.period = 'MONTH');
     
        DELETE trg_reporting_dates
         WHERE reporting_date_id = num_id;
     
    END IF;

COMMIT;

END trg_update_reporting_dates_sp;
/

