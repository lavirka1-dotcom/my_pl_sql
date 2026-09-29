--логіка функції get_sum_price_sales (повернення суми з таблиць products/products_old) в тілі пакету UTIL
--функція також додана і в специфікацію пакета.
FUNCTION get_sum_price_sales (p_table IN VARCHAR2)
         RETURN NUMBER IS

    v_sum_price_sales NUMBER;
    v_dynamic_sql     VARCHAR2(500);
    v_error_msg       VARCHAR2(500);

    BEGIN
        IF p_table NOT IN ('products', 'products_old') OR p_table IS NULL THEN
           v_error_msg := 'Неприпустиме значення! Очікується products або products_old';
    
           to_log (p_appl_proc => 'get_sum_price_sales', 
                p_message   => v_error_msg);
    
           raise_application_error(-20001, v_error_msg);
        END IF;
    
        v_dynamic_sql := 'SELECT SUM(pr.price_sales) FROM HR.' || p_table || ' pr';
            EXECUTE IMMEDIATE v_dynamic_sql INTO v_sum_price_sales;
            RETURN v_sum_price_sales;
    
    END get_sum_price_sales;