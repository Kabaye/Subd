--Выбирите СУБД Oracle для выполнения лабораторной.
--Скопируйте файлы  edu1.sql, edu2.sql в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
--Запустите скрипты EDU1.sql, EDU2.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО                       , группа            , курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки соответсвующего предложения после строки с текстом задания.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt и сохраняется в каталог                      .
--Тексты заданий:
--1.Поднимите нижнюю границу минимальной заработной платы в таблице JOB на 50 единиц.
update JOB
set MINSALARY = MINSALARY + 50;
rollback;
--2. Поднимите минимальную зарплату в таблице JOB на 15%  для всех должностей, минимальная зарплата для которых не превышает 1500 единиц..
update JOB
set MINSALARY = MINSALARY * 1.15
where MINSALARY <= 1500;
rollback;
--3. Поднимите минимальную зарплату в таблице JOB на 10% для водителей  (Driver) и опустите минимальную зарплату для исполнительных директоров (Executive Director) на 10%  (одним оператором).
update JOB
set MINSALARY = CASE
                    when JOBNAME = 'Driver' then MINSALARY * 1.10
                    when JOBNAME = 'Executive Director' then MINSALARY * 0.9
                    else MINSALARY
    end;
rollback;
--4. Установите минимальную зарплату клерка (Clerk) равной половине от зарплаты  финансового директора ( Financial Director}.
update JOB
set MINSALARY = (select MINSALARY from JOB where JOBNAME = 'Financial Director') / 2
where JOBNAME = 'Clerk';
rollback;
--5. Приведите в таблице EMP имена и фамилии служащих, имена которых начинаются на буквы 'D', ‘J’ и ‘R’, полностью к верхнему регистру.
update EMP
set EMPNAME = UPPER(EMPNAME)
where EMPNAME like 'D%'
   or EMPNAME like 'R%'
   or EMPNAME like 'J%';
rollback;
--6. Приведите в таблице EMP имена и фамилии служащих, имена которых начинаются на буквы 'A', ‘D’ и ‘O’, полностью к нижнему регистру.
update EMP
set EMPNAME = LOWER(EMPNAME)
where EMPNAME like 'A%'
   or EMPNAME like 'D%'
   or EMPNAME like 'O%';
rollback;
--7. Приведите в таблице EMP имена и фамилии служащих, с именами Jon,  Ivan, полностью к нижнему регистру.
update EMP
set EMPNAME = LOWER(EMPNAME)
where EMPNAME like 'Jon %'
   or EMPNAME like 'Ivan %';
rollback;
--8. Оставте в таблице EMP только фамилии сотрудников (имена удалите).
update EMP
set EMPNAME = SUBSTR(EMPNAME, INSTR(EMPNAME, ' ') + 1);
rollback;
--9. Перенесите отдел продаж (Sales) по адресу отдела с кодом C02.
update DEPT
set DEPTADDRESS = (select DEPTADDRESS
                   from DEPT
                   where DEPTID = 'C02')
where DEPTNAME = 'Sales';
rollback;
--10. Добавьте нового сотрудника в таблицу EMP. Его номер равен  900, имя и фамилия ‘Frank Hayes’, дата рождения ‘12-09-1978’.
insert into EMP (EMPNO, EMPNAME, BIRTHDATE)
values (900, 'Frank Hayes', to_date('12-09-1978'));
--11. Определите нового сотрудника (см. предыдущее задание) на работу в административный отдел (Administration) с адресом 'USA, San-Diego', начиная с текущей даты в должности водителя (Driver).

rollback;
--12. Удалите все записи из таблицы TMP_EMP. Добавьте в нее информацию о сотрудниках, которые работают инженерами (Engineer) или программистами (Programmer) в настоящий момент.

rollback;
--13. Добавьте в таблицу TMP_EMP информацию о тех сотрудниках, которые увольнялись, но затем опять зачислялись на работу и работают на предприятии в настоящий момент.

rollback;
--14. Добавьте в таблицу TMP_EMP информацию о тех сотрудниках, которые были уволены и не работают на предприятии в настоящий момент.

rollback;
--15. Удалите все записи из таблицы TMP_JOB и добавьте в нее информацию по тем должностям, на которых работает ровно два служащих  в  настоящий момент.

rollback;
--16. Удалите всю информацию о начислениях премий сотрудникам, которые в настоящий момент уже не работают на предприятии.

rollback;
--17. Начислите премию в размере 20% минимального должностного оклада всем сотрудникам, работающим на предприятии.
--Зарплату начислять по должности, занимаемой сотрудником в настоящий момент и отнести ее на текущий месяц.

rollback;
--18. Удалите данные о премиях  за все годы до 2018 включительно.

rollback;
--19. Удалите информацию о прошлой карьере тех сотрудников, которые в настоящий момент  работают на предприятии.

rollback;
--20. Удалите записи из таблицы EMP для тех сотрудников, которые не работают на предприятии в настоящий момент.

rollback;