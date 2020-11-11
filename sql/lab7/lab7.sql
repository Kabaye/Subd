--лабораторная выполняется в СУБД Oracle.
--Скопируйте файлы EDU3.txt в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной. Таблица Bonus имеет дополнительный столбец tax (налог) со значениями null.
--Произведите запуск SQLPlus, PLSQLDeveloper или другого инструментария Oracle и соеденитесь с БД. Запустите скрипты EDU3.txt на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО , группа , курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных Вами программ после пунктов 1a), 1b), 1c), 2), 3).
--Файл отчёта именуется фамилией студента в английской транскрипции, с расширением .txt и сохраняется в каталог . .
--Вам необходимо создать ананимные блоки (программы) для начисления налога на прибыль и занесения его в соответсвующую запись таблицы Bonus.
--Налог вычисляется по следующему правилу:
--налог равен 9% от начисленной в месяце премии, если суммарная премия с начала года до конца рассматриваемого месяца не превышает 500;
--налог равен 12% от начисленной в месяце премии, если суммарная премия с начала года до конца рассматриваемого месяца больше 500, но не превышает 1 000;
--налог равен 15% от начисленной в месяце премии, если суммарная премия с начала года до конца рассматриваемого месяца больше 1 000.
--1. Составьте программу вычисления налога и вставки его в таблицу Bonus:
--a) с помощью простого цикла (loop) с курсором, оператора if или опретора case;
DECLARE
    i                    NUMBER := 1;
    current_emp          NUMBER := 0;
    payed_bonus          NUMBER := 0;
    payed_in_month_bonus NUMBER := 0;
    counter              NUMBER := 0;
BEGIN
    select COUNT(*) into counter from BONUS;
    LOOP
        LOG_P(to_char(i));
        select EMPNO into current_emp from BONUS offset i - 1 rows fetch next 1 row only;
        select SUM(BONVALUE)
        into payed_bonus
        from BONUS
        where EMPNO = current_emp
          and YEAR = extract(year from current_date)
          and BONUS.MONTH <= extract(month from current_date);
        select BONVALUE
        into payed_in_month_bonus
        from BONUS
        where ROWNUM = i;
        if payed_bonus <= 500 then
            UPDATE BONUS
            SET TAX = 0.09 * payed_in_month_bonus
            where ROWNUM = i;
        else
            if payed_bonus > 500 and payed_bonus <= 1000 then
                UPDATE BONUS
                SET TAX = 0.12 * payed_in_month_bonus
                where ROWNUM = i;
            else
                if payed_bonus > 1000 then
                    UPDATE BONUS
                    SET TAX = 0.15 * payed_in_month_bonus
                    where ROWNUM = i;
                end if;
            end if;
        end if;
        i := i + 1;

        if i = counter then
            exit;
        end if;

    END LOOP;
END;
rollback;
select ROWNUM, EMPNO, MONTH, YEAR, BONVALUE, TAX
from BONUS;
-- b) с помощью курсорного цикла FOR;
-- c) с помощью курсора с параметром, передавая номер сотрудника, для которого необходимо посчитать налог.
--2. Создайте процедуру, вычисления налога и вставки его в таблицу Bonus за всё время начислений для конкретного сотрудника. В качестве параметров передать проценты налога (до 500, от 501 до 1000, выше 1000), номер сотрудника.
--3. Создайте функцию, вычисляющую суммарный налог на премию сотрудника за всё время начислений. В качестве параметров передать процент налога (до 500, от 501 до 100 , выше 1000), номер сотрудника.
-- Возвращаемое значение – суммарный налог.