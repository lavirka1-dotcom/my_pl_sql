--створюємо вью для отримання даних звіту
CREATE VIEW rep_project_dep_v AS 
    SELECT proj_fl.project_id
          ,proj_fl.project_name
          ,proj_fl.department_id
          ,d.department_name
          ,COUNT(DISTINCT em.manager_id) AS uniq_managers_cnt
          ,COUNT(em.employee_id) AS emp_cnt
          ,NVL(SUM(em.salary),0) AS total_salary
    FROM EXTERNAL ( (project_id    NUMBER,
                     project_name  VARCHAR2(100),
                     department_id NUMBER )   
        TYPE oracle_loader DEFAULT DIRECTORY FILES_FROM_SERVER
        ACCESS PARAMETERS ( records delimited BY newline
                            nologfile 
                            nobadfile 
                            fields terminated BY ',' 
                            missing field VALUES are NULL )
        LOCATION('PROJECTS.csv') 
        REJECT LIMIT UNLIMITED
                 ) proj_fl
    
    JOIN departments d ON d.department_id = proj_fl.department_id
    JOIN employees em  ON em.department_id = d.department_id 
    
    GROUP BY proj_fl.project_id, proj_fl.project_name, proj_fl.department_id, d.department_name
    ORDER BY proj_fl.project_id
;

--записаний звіт завантажуємо в директорію FILES_FROM_SERVER
DECLARE
    file_handle   UTL_FILE.FILE_TYPE;
    file_location VARCHAR2(200)  := 'FILES_FROM_SERVER';
    file_name     VARCHAR2(200)  := 'TOTAL_PROJ_INDEX_IVL.csv'; 
    v_header      VARCHAR2(1000) := 'PROJECT_ID, PROJECT_NAME, DEPARTMENT_ID, DEPARTMENT_NAME, EMP_CNT, UNIQ_MANAGERS_CNT, TOTAL_SALARY';
BEGIN
    file_handle := UTL_FILE.FOPEN (file_location, file_name,'W');

    UTL_FILE.PUT_RAW(file_handle, UTL_RAW.CAST_TO_RAW(v_header || CHR(10)));    

    FOR cc IN (SELECT project_id ||','|| project_name ||','|| department_id ||','|| department_name ||','|| emp_cnt ||','|| uniq_managers_cnt ||','|| total_salary AS file_line
               FROM rep_project_dep_v) LOOP
        UTL_FILE.PUT_RAW(file_handle, UTL_RAW.CAST_TO_RAW(cc.file_line || CHR(10)));
    END LOOP;

    UTL_FILE.FCLOSE(file_handle);

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
END;
/