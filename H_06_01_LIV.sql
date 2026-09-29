--SET DEFINE OFF;
--==============================================================================
--створення таблиці

CREATE TABLE interbank_index_ua_history (dt        DATE,
                                         id_api    VARCHAR2(100),
                                         val       NUMBER,
                                         special   VARCHAR2(10),
                                         update_dt DATE --додала стовпець з датою оновлення
                                         );
--==============================================================================
--створення вьюшки

CREATE VIEW interbank_index_ua_v AS
    SELECT TO_DATE(tb.dt,'dd.mm.yyyy') as dt, tb.id_api, tb.value as val, tb.special, SYSDATE AS update_dt
    FROM (SELECT SYS.GET_NBU(p_url => 'https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json') AS res
          FROM dual) t
    CROSS JOIN json_table (
        res, '$[*]'
        COLUMNS(
                dt      VARCHAR2(100) PATH '$.dt',
                id_api  VARCHAR2(100) PATH '$.id_api',
                value   NUMBER        PATH '$.value',
                special VARCHAR2(10)  PATH '$.special'
                )
                           ) tb;
--==============================================================================
--створення процедури

CREATE OR REPLACE PROCEDURE download_ibank_index_ua IS
BEGIN
    INSERT INTO interbank_index_ua_history (dt, id_api, val, special, update_dt)
        SELECT dt, id_api, val, special, update_dt
        FROM interbank_index_ua_v;
    COMMIT;

END download_ibank_index_ua;
/
--==============================================================================
--створення джоба (щодня о 9 ранку, початок: 21.09.2026 о 09:00)

BEGIN
    sys.dbms_scheduler.create_job(
        job_name        => 'update_ibank_index_ua',   
        job_type        => 'PLSQL_BLOCK', 
        job_action      => 'begin download_ibank_index_ua(); end;', 
        start_date      => TO_TIMESTAMP('2026-09-21 09:00:00', 'YYYY-MM-DD HH24:MI:SS'),    
        repeat_interval => 'FREQ=DAILY; BYHOUR=9; BYMINUTE=0; BYSECOND=0',
        end_date        => TO_DATE(NULL),         
        job_class       => 'DEFAULT_JOB_CLASS',             
        enabled         => TRUE,                          
        auto_drop       => FALSE,                        
        comments        => 'Оновлення Українського індексу міжбанківських ставок овернайт' 
    );
END;
/
--==============================================================================
SELECT * FROM interbank_index_ua_v;
------------------------------------------
SELECT * FROM interbank_index_ua_history;