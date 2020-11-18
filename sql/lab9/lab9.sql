--Лабораторная выполняется в СУБД  Oracle.
--Cкопируйте файл  EDU5.txt  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
--Произведите запуск Oracle.  Запустите скрипты EDU5.txt на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО                       , группа            , курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных Вами программ после пунктов 1-6.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в каталог.                  .

--1. Создайте триггер, который при обновлении записи в таблице EMP
-- должен отменять действие и сообщать об ошибке
-- a) если семейное положение сотрудника холост/одинокая (s) изменяется на семейное положение разведен/разведена (d);
-- b) семейное положение женат/замужем (m) изменяется  на семейное положение холост/одинокая (s);
create or replace trigger trg_emp_mstat_changing
    before update
    on EMP
    for each row
begin
    --     a)
    if :OLD.MSTAT = 's' and :NEW.MSTAT = 'd' then
        raise_application_error(-20010, 'ERROR: Emp status is changing from s to d!');
    end if;
-- b)
    if :OLD.MSTAT = 'm' and :NEW.MSTAT = 's' then
        raise_application_error(-20010, 'ERROR: Emp status is changing from m to s!');
    end if;
end;
--2. Создайте триггер, который при добавлении или обновлении записи в таблице EMP должен:
-- a) осуществлять вставку данного равного 0,
-- если для сотрудника с семейным положением холост/одинокая (s)  в столбце Nchild указывается данное, отличное от 0;
-- b) осуществлять вставку данного NULL,
-- если для любого сотрудника указывается отрицательное количество детей.
create or replace trigger trg_emp_child_mstat_amount_upd
    before update or insert
    on EMP
    for each row
begin
    --     a)
    if :NEW.MSTAT = 's' and :NEW.NCHILD != 0 then
        :NEW.NCHILD := 0;
    end if;
-- b)
    if :NEW.NCHILD < 0 then
        :NEW.NCHILD := NULL;
    end if;
end;
--3. Создайте триггер, который при обновлении записи в таблице EMP
-- должен отменять действие и сообщать об ошибке, если для сотрудников, находящихся в браке (m) в столбце Nchild
-- новое значение увеличивается (рождение ребёнка) или уменьшается (достижение ребёнком совершеннолетия) более чем на 1.
create or replace trigger trg_emp_child_mstat_amount_upd2
    before update
    on EMP
    for each row
begin
    if abs(:OLD.NCHILD - :NEW.NCHILD) > 1 and :OLD.MSTAT = 'm' then
        raise_application_error(-20010, 'ERROR: Emp child new amount is not correct!');
    end if;
end;
--4. Создать триггер, который отменяет любые действия (начисление, изменение, удаление) с премиями (таблица bonus)
-- неработающих в настоящий момент в организации сотрудников и сообщает об ошибке.
create or replace trigger trg_bonus_changing
    before update or delete or insert
    on BONUS
    for each row
declare
    counter NUMBER := 0;
begin
    if inserting and updating then
        select COUNT(*) into counter from CAREER where CAREER.EMPNO = :NEW.EMPNO and ENDDATE is null;
    end if;
    if deleting then
        select COUNT(*) into counter from CAREER where CAREER.EMPNO = :OLD.EMPNO and ENDDATE is null;
    end if;
    if counter = 0 then
        raise_application_error(-20010, 'ERROR: Bonuses are changing on currently now working user');
    end if;
end;
--5. Создайте триггер, который после выполнения действия (вставка, обновление, удаление) с таблицей job
-- создаёт запись в таблице temp_table, с указанием названия действия (delete, update, insert) активизирующего триггер.
create or replace trigger trg_job_changing
    before update or insert or delete
    on JOB
    for each row
declare
    action Varchar(6) := '';
begin
    if inserting then
        action := 'insert';
    end if;
    if updating then
        action := 'update';
    end if;
    if deleting then
        action := 'delete';
    end if;
    insert into TEMP_TABLE (MSG) values (action);
end;
--6. Создайте триггер, который до выполнения обновления в таблице job столбца minsalary отменяет действие, сообщает об ошибке
-- и создаёт запись в таблице temp_table c указанием "более 10%",
-- если должностной оклад изменяется более чем 10% (увеличивается или уменьшается).
create or replace procedure insert_into_temp_table (p_message in varchar)
    is
    pragma autonomous_transaction;
begin
    insert into TEMP_TABLE
    values (p_message);
    commit;
end;

create or replace trigger trg_job_changing_2
    before update of MINSALARY
    on JOB
    for each row
declare
    new_var  FLOAT;
    temp_str Varchar2(9) := 'more10%';
begin
    new_var := abs((:NEW.MINSALARY * 100 / :OLD.MINSALARY) - 100);
    if new_var > 10 then
        insert_into_temp_table(temp_str);
        raise_application_error(-20010, 'ERROR: Changing minsalary more than 10%');
    end if;
end;

