--Лабораторная выполняется в СУБД  Oracle. 
--Cкопируйте файл  edu8.txt  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной. 
--Запустите скрипт edu8.sql на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО                       , группа            , курс 4.      
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных 
--Вами операторов после пунктов 1- 9.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt 
--и сохраняется в каталог.

--1.	Создайте таблицу emp_tel, с полями empno, phone_num. Первое из них - поле идентичное полю empno 
--таблицы emp и служит внешним ключом для связывания таблиц emp и emp_tel. 
--Второе поле – массив переменной длины с максимальным числом элементов равным четырём. 
--Поле может содержать телефоны сотрудника (рабочий, МТС, Велком, Лайф). 
create or replace type phone_numbers_type as varying array (4) of varchar2(15);
create table emp_tel
(
    empno         number not null,
    phone_numbers phone_numbers_type,
    constraint fk_empno
        foreign key (empno)
            references emp (empno)
);

--2.	Вставьте записи в таблицу  emp_tel со следующими данными:
--505, 2203415, 80297121314, 80296662332, Null
--303, 2240070, 80297744543, 80296667766, 80443345543
--503, 2233014, Null, 80296171717, 80443161612
--104, 22333015, 80297654321, Null, 90443939398

insert into emp_tel
values (505, phone_numbers_type('2203415', '80297121314', '80296662332', null));
insert into emp_tel
values (303, phone_numbers_type('2240070', '80297744543', '80296667766', '80443345543'));
insert into emp_tel
values (503, phone_numbers_type('2233014', null, '80296171717', '80443161612'));
insert into emp_tel
values (104, phone_numbers_type('22333015', '80297654321', null, '90443939398'));

--3.	Создайте запросы:
--a)	 для сотрудников с номерами 104, 303 указать имена и номера телефонов;

select emp.empname,
       emp_tel.phone_numbers
from emp,
     emp_tel
where emp.empno = emp_tel.empno
  and emp.empno in (104, 303);

--b)	для сотрудника с номером 505, используя функцию Table, укажите его номер и телефоны.

select emp_tel.empno,
       column_value
from emp_tel,
    table (emp_tel.phone_numbers)
where emp_tel.empno = 505;

--4.	Создайте таблицу children с полями empno, child. 
--Первое из них - поле идентичное полю empno таблицы emp и служит внешним ключом для связывания 
--таблиц emp и children. Второе является вложенной таблицей и содержит данные об имени (name) 
--и дате рождения ребёнка (birthdate) сотрудника.

create type children_obj as object
(
    name      varchar2(15),
    birthdate date
);

create type children_nested_table is table of children_obj;

create table children
(
    empno    number,
    children children_nested_table,
    constraint fk1_empno
        foreign key (empno)
            references emp (empno)
)
    nested table children store as children_data;

--5.	Вставьте в таблицу children записи:
--для сотрудника с номером 102 двое детей: Jack, 02.02.2009
--				               Mari, 10.11.2014;

insert into children
values (102,
        children_nested_table(
                children_obj('Jack', to_date('02-02-2000')),
                children_obj('Mari', to_date('10-11-2004'))
            ));

--для сотрудника с номером 327 двое детей: Alex, 22.09.2015
--						Janis, 04.10.2018.

insert into children
values (327,
        children_nested_table(
                children_obj('Alex', to_date('22-09-2015')),
                children_obj('Janis', to_date('04-10-2018'))
            ));

--6.	Создайте запросы:
--a)	укажите все сведения из таблицы children;

select children.empno, nested_children_data.*
from children,
     table (children.children) nested_children_data;

--b)	укажите номер сотрудника, имеющего ребёнка с именем Janis, имя ребёнка и дату рождения ребёнка.

select children.empno, nested_children_data.*
from children,
     table (children.children) nested_children_data
where name = 'Janis';

--7.	Измените дату рождения ребёнка с именем Alex на 10.10.2016.

update table (select children.children
              from children,
                   table (children.children) nested_children_data
              where name = 'Alex') children
set birthdate = to_date('10-10-2016');

--8.	Добавьте для сотрудника с номером 102 ребёнка с именем Julio и датой рождения 01.12.2019.

insert into table (select children.children
                   from children
                   where children.empno = 102)
values (children_obj('Julio', to_date('01-12-2019')));

--9.	Удалите сведения о ребёнке с именем Mari для сотрудника с номером 102.	

delete
from table (select children.children
            from children
            where children.empno = 102) children
where children.name = 'Mari';
