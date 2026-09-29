DECLARE
    v_def_percent VARCHAR2(30);
    v_percent VARCHAR2(5);

BEGIN

    FOR cc IN (SELECT manager_id
                     ,first_name || ' ' || last_name as emp_name
                     ,commission_pct*100 as percent_of_salary
                FROM hr.employees
                WHERE department_id = 80
                ORDER BY first_name) LOOP 

    IF cc.manager_id = 100 THEN   
       dbms_output.put_line('Співробітник - ' || cc.emp_name || ', процент до зарплати на зараз заборонений');
       CONTINUE;
    END IF;
    
    IF cc.percent_of_salary BETWEEN 10 and 20 THEN
        v_def_percent := 'мінімальний';
     ELSIF cc.percent_of_salary BETWEEN 25 and 30 THEN
        v_def_percent := 'середній';
     ELSIF cc.percent_of_salary BETWEEN 35 and 40 THEN
        v_def_percent := 'максимальний'; 
    END IF;

   v_percent := CONCAT(cc.percent_of_salary, '%');
   dbms_output.put_line('Співробітник - ' || cc.emp_name || '; процент до зарплати - ' || v_percent || '; опис процента - ' || v_def_percent);

    END LOOP;

END;
/
