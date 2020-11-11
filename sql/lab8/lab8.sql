--1. Создайте пакет, включающий в свой состав процедуру ChildBonus и функцию EmpChildBonus.
--Процедура ChildBonus должна вычислять ежегодную добавку к
--зарплате сотрудников на детей за 2019 год и заносить её в виде дополнительной премии в первом месяце (январе) следующего 2020
--календарного года в поле Bonvalue таблицы Bonus.
--В качестве параметров процедуре передаются проценты в зависимости от количества детей (см. правило начисления добавки).
--Функция EmpChildBonus должна вычислять ежегодную добавку за 2019 год на детей к  зарплате конкретного сотрудника
--(номер сотрудника - параметр передаваемый функции) без занесения в таблицу.

--ПРАВИЛО ВЫЧИСЛЕНИЯ ДОБАВКИ

--Добавка к заработной плате на детей  вычисляется только для работавших в декабре 2019 году сотрудников по следующему правилу:
--добавка равна X% от суммы должностного месячного оклада (поле minsalary таблицы job) по занимаемой в декабре 2019 года должности и всех начисленных
--за 2019 год премий (поле bonvalue таблицы bonus), где:
--X% равны X1% , если сотрудник имеет одного ребёнка;
--X% равны X2% , если сотрудник имеет двух детей;
--X% равны X3% , если сотрудник имеет трёх и более детей.
--X1%<X2%<X3%  являются передаваемыми процедуре и функции параметрами. Кроме этого, функции в качестве параметра передаётся номер сотрудника (empno).

create or replace package ChildBonusPackage
as
    function EmpChildBonus(EMP_NUM in integer, X1 in real, X2 in real, X3 in real) return real;
    procedure ChildBonus(X1 in real, X2 in real, X3 in real);
end ChildBonusPackage;

create or replace package body ChildBonusPackage as
    procedure ChildBonus(X1 in real, X2 in real, X3 in real) is
        cursor CH_BON_CURSOR is
            select DISTINCT EMP.EMPNO
            from EMP;
        EMP_NUM        integer := 0;
        EARNED_BONUSES real    := 0;
        SALARY         real    := 0;
        TOTAL          real    := 0;
        CHILD_NUM      integer := 0;
        CHILD_BONUS    real    := 0;
    begin
        open CH_BON_CURSOR;
        loop
            fetch CH_BON_CURSOR into EMP_NUM;
            exit when CH_BON_CURSOR % notfound;

            begin
                select SUM(NVL(BONVALUE, 0))
                into EARNED_BONUSES
                from BONUS
                where EMPNO = EMP_NUM
                  and BONUS.YEAR = 2019
                group by EMPNO;
            exception
                when NO_DATA_FOUND then EARNED_BONUSES := 0;
            end;

            begin
                select SUM(NVL(MINSALARY, 0))
                into SALARY
                from CAREER,
                     JOB
                where CAREER.EMPNO = EMP_NUM
                  and JOB.JOBNO = CAREER.JOBNO
                  and EXTRACT(year from CAREER.STARTDATE) <= 2019
                  and (CAREER.ENDDATE is null or EXTRACT(year from CAREER.ENDDATE) > 2019)
                group by CAREER.EMPNO;
            exception
                when NO_DATA_FOUND then SALARY := 0;
            end;

            begin
                select NCHILD
                into CHILD_NUM
                from EMP
                where EMPNO = EMP_NUM;
            end;

            TOTAL := EARNED_BONUSES + SALARY;

            if CHILD_NUM = 1 then
                CHILD_BONUS := TOTAL * X1 / 100;
            elsif CHILD_NUM = 2 then
                CHILD_BONUS := TOTAL * X2 / 100;
            elsif CHILD_NUM > 2 then
                CHILD_BONUS := TOTAL * X3 / 100;
            end if;

            if CHILD_BONUS > 0 then
                insert into BONUS (EMPNO, MONTH, YEAR, BONVALUE, TAX)
                values (EMP_NUM, 1, 2020, CHILD_BONUS, NULL);
            end if;
        end loop;
        close CH_BON_CURSOR;
    end ChildBonus;

    function
        EmpChildBonus(EMP_NUM in integer, X1 in real, X2 in real, X3 in real) return real is
        EARNED_BONUSES real    := 0;
        SALARY         real    := 0;
        TOTAL          real    := 0;
        CHILD_NUM      integer := 0;
        CHILD_BONUS    real    := 0;

    begin
        begin
            select SUM(NVL(BONVALUE, 0))
            into EARNED_BONUSES
            from BONUS
            where EMPNO = EMP_NUM
              and BONUS.YEAR = 2019
            group by EMPNO;
        end;

        begin
            select SUM(NVL(MINSALARY, 0))
            into SALARY
            from CAREER,
                 JOB
            where CAREER.EMPNO = EMP_NUM
              and JOB.JOBNO = CAREER.JOBNO
              and EXTRACT(year from CAREER.STARTDATE) <= 2019
--               только те случаи, когда он весь месяц отработал
              and (CAREER.ENDDATE is null or EXTRACT(year from CAREER.ENDDATE) > 2019)
            group by CAREER.EMPNO;
        end;

        begin
            select NCHILD
            into CHILD_NUM
            from EMP
            where EMPNO = EMP_NUM;
        end;

        TOTAL := EARNED_BONUSES + SALARY;

        if CHILD_NUM = 1 then
            CHILD_BONUS := TOTAL * X1 / 100;
        elsif CHILD_NUM = 2 then
            CHILD_BONUS := TOTAL * X2 / 100;
        elsif CHILD_NUM > 2 then
            CHILD_BONUS := TOTAL * X3 / 100;
        end if;

        return CHILD_BONUS;
    end EmpChildBonus;
end ChildBonusPackage;

--- procedure call
begin
    ChildBonusPackage.ChildBonus(5, 10, 15);
end;

--- function call
declare
    V real;
begin
    V := ChildBonusPackage.EmpChildBonus(102, 5, 10, 15);
--     LOG_P(to_char(V));
end;

--2. Создайте триггер, который при добавлении или обновлении записи в таблице EMP
-- должен отменять действие и сообщать об ошибке:
--a) если для сотрудника с семейным положением холост (s)  в столбце Nchild указывается не нулевое количество детей или NULL:;
--b) если для любого сотрудника указывается отрицательное количество детей или Null.

create or replace trigger trg_emp_child_mstat_amount
    before update OR insert
    on EMP
    for each row
begin
--     a)
    if :NEW.MSTAT = 's' and (:NEW.NCHILD > 0 or :NEW.NCHILD is null) then
        raise_application_error(-20010, 'ERROR: Emp is single but has childs!');
    end if;
-- b)
    if :NEW.NCHILD is null or :NEW.NCHILD < 0 then
        raise_application_error(-20010, 'ERROR: Emp childs amount can not be null or negative!');
    end if;
end;


