DECLARE
    v_date date := to_date('06.05.2026', 'DD.MM.YYYY');
    v_day number;

BEGIN

    v_day := to_number(to_char(v_date, 'dd')); 
/*    IF v_date = last_day(v_date) THEN --в залежності від дати присвоєної змінній v_date 
        dbms_output.put_line('Виплата зарплати');*/
    IF v_date = last_day(trunc(SYSDATE)) THEN --в залежності від поточної системної дати
        dbms_output.put_line('Виплата зарплати');
    ELSIF v_day = 15 THEN
        dbms_output.put_line('Виплата авансу');
    ELSIF v_day < 15 THEN
        dbms_output.put_line('Чекаємо на аванс');
    ELSIF v_day > 15 THEN
        dbms_output.put_line('Чекаємо на зарплату');
    END IF;

END;
/