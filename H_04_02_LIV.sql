--оновлена логіка процедури del_jobs в тілі пакету UTIL з використанням EXCEPTION-нів та check_work_time
PROCEDURE del_jobs (p_job_id  IN   VARCHAR2, 
                    po_result OUT  VARCHAR2) IS    

    v_delete_no_data_found EXCEPTION;    

    BEGIN
    -- перевірка робочих днів тижня 
    check_work_time;

        BEGIN
            DELETE
            FROM irina_vyx.jobs j
            WHERE j.job_id = p_job_id;                        

            IF SQL%ROWCOUNT = 0 THEN
                RAISE v_delete_no_data_found;
            END IF;

        po_result := 'Посада ' || p_job_id || ' успішно видалена';
        COMMIT;

        EXCEPTION
            WHEN v_delete_no_data_found THEN
            raise_application_error(-20004, 'Посада ' || p_job_id || ' не існує');

        END;
    
    END del_jobs;