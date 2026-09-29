DECLARE
    v_year number := 2026;
    v_check_year number;

BEGIN

    v_check_year := mod(v_year, 4); 
    IF v_check_year = 0 THEN
        dbms_output.put_line('Високосний рік');
    ELSE
        dbms_output.put_line('Не високосний рік');
    END IF;

END;
/