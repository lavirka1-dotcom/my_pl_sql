create or replace FUNCTION get_dep_name(p_employee_id IN NUMBER) RETURN VARCHAR2 IS

    v_dep_name irina_vyx.departments.department_name%TYPE;

BEGIN
    SELECT d.department_name
    INTO v_dep_name
    FROM irina_vyx.employees em
    JOIN irina_vyx.departments d ON em.department_id = d.department_id
    WHERE em.employee_id = p_employee_id;

    RETURN v_dep_name;

END get_dep_name;
/

SELECT em.employee_id
      ,em.first_name
      ,em.last_name
      ,em.email
      ,em.phone_number
      ,em.hire_date
--      ,irina_vyx.get_job_title(em.employee_id) as job_title --виклик функції зі схеми
      ,irina_vyx.util.get_job_title(em.employee_id) as job_title --додала виклик функції з пакету, бо зі схеми видалила дану функцію згідно 3-го завдання
      ,em.salary
      ,em.commission_pct
      ,em.manager_id
--      ,irina_vyx.get_dep_name(em.employee_id) as dep_name --виклик функції зі схеми
      ,irina_vyx.util.get_dep_name(em.employee_id) as dep_name --додала виклик функції з пакету, бо зі схеми видалила дану функцію згідно 3-го завдання
FROM irina_vyx.employees em
;
