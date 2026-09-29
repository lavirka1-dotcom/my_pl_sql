/*Пошук свого логіну в табличці EMPLOYEES та конкатенацію з поштовим доменом винесено в окрему функцію (get_email_func).
  Це спростило код, а також дозволяє повторно використовувати цю логіку в інших об'єктах БД.*/
create or replace FUNCTION get_email_func (p_empl_id IN NUMBER,
                                           p_dom     IN VARCHAR2) RETURN VARCHAR2 IS
        v_recipient VARCHAR2(50);
        v_dom       VARCHAR2(50) := p_dom;
BEGIN
    SELECT em.email
    INTO v_recipient
    FROM irina_vyx.employees em
    WHERE em.employee_id = p_empl_id;

    RETURN v_recipient || v_dom;
END get_email_func;
/

--відправка сформованого звіту на пошту
DECLARE
    v_recipient VARCHAR2(50);
    v_subject   VARCHAR2(1000)  := 'Звіт кількості працівників у розрізі департаментів';
    v_mes       VARCHAR2(10000) := 'Доброго дня, шановні колеги! </br> Надаю звіт по кількості працівників у розрізі департаментів: </br></br>';

BEGIN

    v_recipient := get_email_func (p_empl_id => 207,
                                   p_dom => '@GMAIL.COM');

    SELECT 
v_mes ||'<!DOCTYPE html>
        <html>
        <head>
            <title></title>
            <style>
                table, th, td { border: 1px solid; }
                .center { text-align: center; }
            </style>
        </head>
        <body>
            <table border=1 cellspacing=0 cellpadding=2 rules=GROUPS frame=HSIDES>
                <thead>
                    <tr align=left>
                        <th>Ід департаменту</th>
                        <th>Кількість співробітників</th>
                    </tr>
                </thead>
                <tbody>
                ' || list_html || '
                </tbody>
            </table>
        </body>
        </html>' AS html_table

INTO v_mes
FROM (SELECT 
        LISTAGG(
            '<tr align=left>
                <td>' || department_id || '</td>
                <td align="center" style="text-align: center;">' || empl_cnt || '</td>
            </tr>' 
               )
        WITHIN GROUP (ORDER BY department_id) AS list_html
        FROM (SELECT em.department_id, COUNT(em.employee_id) AS empl_cnt
              FROM employees em
              WHERE em.department_id is not null
              GROUP BY em.department_id
             )
    );

    v_mes := v_mes || '</br></br> З повагою, Ірина ';

    sys.sendmail(p_recipient => v_recipient,
                 p_subject   => v_subject,
                 p_message   => v_mes);

END;
/
