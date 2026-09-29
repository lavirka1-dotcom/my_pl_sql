--Додано в специфікацію пакету UTIL:
------------------------------------
TYPE rec_region_cnt_emp IS RECORD (region_name VARCHAR2(30),
                                   cnt_emp     NUMBER);

TYPE tab_region_cnt_emp IS TABLE OF rec_region_cnt_emp;
---------------------------------------------------------
FUNCTION get_region_cnt_emp (p_department_id IN NUMBER DEFAULT NULL)
                             RETURN tab_region_cnt_emp PIPELINED;
--==============================================================================  
--Додано в тіло пакету UTIL:
------------------------------------
FUNCTION get_region_cnt_emp (p_department_id IN NUMBER DEFAULT NULL)
                             RETURN tab_region_cnt_emp PIPELINED IS

    out_rec tab_region_cnt_emp := tab_region_cnt_emp();
    l_cur   SYS_REFCURSOR;

BEGIN

    OPEN l_cur FOR 
            SELECT r.region_name, COUNT(em.employee_id) as cnt_emp
            FROM hr.employees em
            JOIN hr.departments d ON d.department_id = em.department_id
            JOIN hr.locations l ON l.location_id = d.location_id
            JOIN hr.countries c ON c.country_id = l.country_id
            JOIN hr.regions r ON r.region_id = c.region_id
--якщо передаємо якесь значення параметру p_department_id, то виводиться конкретне значення для вказаного департаменту,
--якщо не передаємо (null), то виводяться значення по всіх департаментах
--якщо вказано неіснуючий department_id - поверне порожній результат (пусту таблицю)   
            WHERE em.department_id = p_department_id OR p_department_id IS NULL
            GROUP BY r.region_name;

        BEGIN
           LOOP

           FETCH l_cur BULK COLLECT INTO out_rec;
--якщо колекція порожня - виходимо з циклу
           EXIT WHEN out_rec.COUNT = 0;

              FOR i IN 1 .. out_rec.COUNT LOOP 
                  PIPE ROW(out_rec(i));
              END LOOP;
            END LOOP; 

    CLOSE l_cur;

    EXCEPTION
        WHEN OTHERS THEN
            IF (l_cur%ISOPEN) THEN
                CLOSE l_cur;
            END IF;
        RAISE;
        END;
                          
END get_region_cnt_emp;
