--лабораторная выполняется в субд  oracle.
--cкопируйте файл  edu6.txt  в каталог c:\temp .
--раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
--база данных имеет дополнительную таблицу t_error.
--произведите запуск oracle.  запустите скрипты edu6.txt на выполнение.
--вставте в эту строку ваши фио, номер группы, курса. фио                       , группа            , курс 4.
--файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных вами программ после пунктов 1a, 1b.
--файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в каталоu.

--1a. имеются pl_sql-блоки, содержащий следующие операторы:
declare
    emp_num integer;
    code    integer;
    message varchar2(100);
begin
    insert into bonus values (505, 15, 2018, 500, null);

exception
    when others then
        code := sqlcode;
        message := substr(sqlerrm, 1, 70);
        insert into t_error values (code, message, sysdate);
end;

declare
    emp_num integer;
    code    integer;
    message varchar2(100);
begin
    insert into job values (1010, 'accountant xxxxxxxxxx', 5500);

exception
    when others then
        code := sqlcode;
        message := substr(sqlerrm, 1, 70);
        insert into t_error values (code, message, sysdate);
end;

declare
    empnum  integer;
    code    integer;
    message varchar2(100);
begin
    select empno into empnum from emp where empno = 505 or empno = 403;

exception
    when others then
        code := sqlcode;
        message := substr(sqlerrm, 1, 50);
        insert into t_error values (code, message, sysdate);
end;
--оператор исполняемого раздела в каждом из блоков вызывает предопределённое исключение со своими предопределёнными
--кодом и сообщением.
--дополните блоки разделами обработки исключительных ситуаций.
--обработка каждой ситуации состоит в занесении в таблицу t_error предопределённых кода ошибки,
--сообщения об ошибке и текущих даты и времени, когда ошибка произошла.

--1b. создайте собственную исключительную ситуацию ex_one с кодом -16000 и сообщением
--'premium more than possible by m for n months', где m - превышение премиального фонда при введении очередной записи
--в таблицу bonus для месяца n.
--исключительная ситуация ex_one наступает при нарушении бизнес-правила: "сумма всех премий (премии в столбце bonvalue), начисленных с начала 2020 года
--за n месяцев, не может быть больше 1000*n" 1<= n<=12. то есть, если премиальный фонд в 1000 денежных единиц полностью не
--израсходован в текущем месяце, то его остаток может быть израсходован в последующие месяцы, но без нарушения суммарного
--премиального фонда за каждые n месяцев.
create or replace trigger trg_bon1
    before update or insert
    on bonus
    for each row
declare
    all_bonuses number;
    pragma autonomous_transaction;
begin
    select sum(bonvalue) into all_bonuses from bonus where month <= :new.month and year = 2020;
    if updating then
        all_bonuses := all_bonuses + :new.bonvalue - :old.bonvalue;
    end if;
    if inserting then
        all_bonuses := all_bonuses + :new.bonvalue;
    end if;
    if all_bonuses > :new.month * 1000 then
        raise_application_error(-20000, concat('premium more than possible by ',
                                               concat(to_char(all_bonuses - :new.month * 1000),
                                                      concat(' for ', concat(to_char(:new.month), ' months')))));
    end if;
    commit;
end;

declare
    code    integer;
    message varchar2(100);
begin
    insert into BONUS
    values (505, 8, 2020, 8000, null);

exception
    when others then
        code := sqlcode;
        message := substr(sqlerrm, 1, 58);
        insert into t_error values (code, message, sysdate);
end;

--создайте собственную исключительную ситуацию ex_two с кодом -16001 и сообщением "the amount of bonuses in the n-th month is less than in the previous month",
--где n+1 номер месяца в первой записи вводимой в таблицу bonus для (n+1)-го месяца(как признак завершения записей для n-го месяца).

--исключительная ситуация ex_two наступает, при нарушении бизнес-правила: "сумма всех премий за n-ый месяц не может быть меньше, чем
--сумма всех премий за предыдущий месяц. как уже указано выше, признак окончания начислений за n-ый месяц - появление первой записи с новым значением
--номера месяца n+1 (доначисление премий за предыдущие месяцы не допускается). для января исключительная ситуация не рассматривается.
--рассматривается только 2020 года.
create or replace trigger trg_bon2
    before update or insert
    on bonus
    for each row
declare
    all_bonuses_prev number := 0;
    all_bonuses_curr number := 0;
    current_month    number := 1;
    pragma autonomous_transaction;
begin
    select sum(bonvalue) into all_bonuses_prev from bonus where month = :new.month - 1 and year = 2020;
    select sum(bonvalue) into all_bonuses_curr from bonus where month = :new.month and year = 2020;
    select max(month) into current_month from bonus where year = 2020;
    if updating then
        all_bonuses_curr := all_bonuses_curr + :new.bonvalue - :old.bonvalue;
    end if;
    if inserting then
        if all_bonuses_curr is null then
            all_bonuses_curr := 0;
        end if;
        all_bonuses_curr := all_bonuses_curr + :new.bonvalue;
    end if;

--     1)
    if current_month > :new.month then
        raise_application_error(-20001, 'No possibility add/change bonuses for previous months');
    end if;
--     2)
    LOG_P(concat('1 ', all_bonuses_curr));
    LOG_P(concat('2 ', all_bonuses_prev));
    if all_bonuses_curr < all_bonuses_prev then
        raise_application_error(-20001,
                                replace('the amount of bonuses in the n-th month is less than in the previous month',
                                        'n-', concat(to_char(:new.month), '-')));
    end if;
    commit;
end;

-- to test 1)
declare
    code    integer;
    message varchar2(100);
begin
    insert into BONUS
    values (505, 2, 2020, 500, null);

exception
    when others then
        code := sqlcode;
        message := substr(sqlerrm, 1, 58);
        insert into t_error values (code, message, sysdate);
end;
-- to test 2)
declare
    code    integer;
    message varchar2(100);
begin
    insert into BONUS
    values (505, 9, 2020, 299, null);

exception
    when others then
        code := sqlcode;
        message := substr(sqlerrm, 1, 86);
        insert into t_error values (code, message, sysdate);
end;
commit;
--создайте блок с операторами, вызывающими нарушение бизнес-правил и обработку соответсвующих ситуаций.
--при наступлении пользовательской исключительной ситуации ex_two обработка состоит в занесении данных о ней
--(аналогично разделу 1a) в таблицу t_error и отмене фиксации записи в таблице bonus (оператор rollback).

