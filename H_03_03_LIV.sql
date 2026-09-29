--===СТВОРЕННЯ ПАКЕТУ UTIL===
create or replace PACKAGE util AS

--функція (отримати назву посади до ID-співробітника)
    FUNCTION get_job_title (p_employee_id IN NUMBER) RETURN VARCHAR2;

--------------------------------------------------------------------------------
--функція (отримати назву департаменту до ID-співробітника)
    FUNCTION get_dep_name (p_employee_id IN NUMBER) RETURN VARCHAR2;

--------------------------------------------------------------------------------    
--процедура (видалення посад по ID-посаді)
    PROCEDURE del_jobs (p_job_id  IN   VARCHAR2, 
                        po_result OUT  VARCHAR2);
--------------------------------------------------------------------------------

END util;
/
--===СТВОРЕННЯ ТІЛА ПАКЕТУ UTIL===
create or replace PACKAGE BODY util AS
--------------------------------------------------------------------------------
--логіка функції (отримати назву посади до ID-співробітника)
    FUNCTION get_job_title (p_employee_id IN NUMBER) RETURN VARCHAR2 IS
    
            v_job_title jobs.job_title%TYPE;
    BEGIN

        SELECT j.job_title
        INTO v_job_title
        FROM employees em
        JOIN jobs j ON em.job_id = j.job_id
        WHERE em.employee_id = p_employee_id;
    
        RETURN v_job_title;

    END get_job_title;
    
--------------------------------------------------------------------------------
--логіка функції (отримати назву департаменту до ID-співробітника)
    FUNCTION get_dep_name (p_employee_id IN NUMBER) RETURN VARCHAR2 IS
    
        v_dep_name irina_vyx.departments.department_name%TYPE;
    
    BEGIN

        SELECT d.department_name
        INTO v_dep_name
        FROM irina_vyx.employees em
        JOIN irina_vyx.departments d ON em.department_id = d.department_id
        WHERE em.employee_id = p_employee_id;
    
        RETURN v_dep_name;
    
    END get_dep_name;

--------------------------------------------------------------------------------    
--логіка процедури (видалення посад по ID-посаді)
    PROCEDURE del_jobs (p_job_id  IN   VARCHAR2, 
                        po_result OUT  VARCHAR2) IS 
    
            v_is_exist_job NUMBER;
    
    BEGIN
    
            SELECT COUNT(j.job_id)
            INTO v_is_exist_job
            FROM irina_vyx.jobs j
            WHERE j.job_id = p_job_id;
    
            IF v_is_exist_job = 0 THEN
               po_result := 'Посада '||p_job_id||' не існує';
               ELSE
                    DELETE
                    FROM irina_vyx.jobs j
                    WHERE j.job_id = p_job_id;               
                    COMMIT;
                po_result := 'Посада '||p_job_id||' успішно видалена';
            END IF;
    
    END del_jobs;

--------------------------------------------------------------------------------

END util;
/
--==============================================================================

--==============================================================================
--ВИДАЛЕННЯ перенесених функцій та процедури зі схеми
DROP PROCEDURE irina_vyx.del_jobs;
DROP FUNCTION irina_vyx.get_job_title;
DROP FUNCTION irina_vyx.get_dep_name;
--==============================================================================

--==============================================================================
--ВИКЛИКИ функцій та процедури з пакету через PL-SQL блок:
DECLARE
    v_result VARCHAR2(100);
    v_emplid NUMBER(5) := 150;

BEGIN

    dbms_output.put_line('Посада співробітника з ID '||v_emplid||' - '||irina_vyx.util.get_job_title(v_emplid));

    dbms_output.put_line('Департамент співробітника з ID '||v_emplid||' - '||irina_vyx.util.get_dep_name(v_emplid));

    irina_vyx.util.del_jobs (p_job_id  => 'PR_REP', 
                             po_result => v_result);

    dbms_output.put_line(v_result);

END;
/