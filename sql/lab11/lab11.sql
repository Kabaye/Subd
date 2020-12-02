--Лабораторная выполняется в СУБД  Oracle.
--Cкопируйте файл  EDU7.txt  в каталог C:\TEMP .
--Раскройте файл и ознакомтесь со скриптом создания и заполнения таблиц для выполнения лабораторной.
--Запустите скрипт EDU7.txt на выполнение.
--Вставте в эту строку Ваши ФИО, номер группы, курса. ФИО                       , группа            , курс 4.
--Файл с отчётом о выполнении лабораторной создаётся путём вставки скриптов, созданных
--Вами операторов после пунктов 1- 8.
--Файл отчёта именуется фамилией студента  в английской транскрипции, с расширением .txt
--и сохраняется в каталог.

--1. Модифицируйте таблицу emp, добавив поле empaddr, содержащую сведения об адресе сотрудника.
--Данное поле должно являться полем объектного типа empaddr_ty  с атрибутами
--country varchar (10), city varchar (10), street varchar (10), homenumber integer, postcode integer, startlifedate date (дата заселения).
--Объектный тип должен содержать метод , определяющий время проживания (в днях) сотрудника по указанному
--адресу до текущего момента, округлённое до дня.

create or replace type empaddr_ty as object
(
    country       varchar(10),
    city          varchar(10),
    street        varchar(10),
    homenumber    integer,
    postcode      integer,
    startlifedate date,
    member
    function days_of_living return integer
) not final;

create or replace type body empaddr_ty as
    member function days_of_living return integer is
    begin
        return sysdate - startlifedate;
    end days_of_living;
end;

alter table emp
    add empaddr empaddr_ty;

--2. Дополните таблицу emp следующими данными для сотрудников:
--505	Belarus	Minsk	Chkalova 		2	220039		15.01.2007
--303	Belarus	Minsk	Poushkina		12	220087		16.05.2005
--205	Belarus	Minsk	Serova			14	220013		20.11.2008
--412	Belarus	Minsk	Serova			23	220013		14.12.2005
--503	Belarus	Minsk	Chkalova		6	220039		28.10.2008
--Для остальных сотрудников атрибуты поля  empaddr не определены.

update emp
set empaddr = empaddr_ty('Belarus', 'Minsk', 'Chkalova', 2, 220039, to_date('15-01-2007'))
where empno = 505;
update emp
set empaddr = empaddr_ty('Belarus', 'Minsk', 'Poushkina', 12, 220087, to_date('16-05-2005'))
where empno = 303;
update emp
set empaddr = empaddr_ty('Belarus', 'Minsk', 'Serova', 14, 220013, to_date('20-11-2008'))
where empno = 205;
update emp
set empaddr = empaddr_ty('Belarus', 'Minsk', 'Serova', 23, 220013, to_date('14-12-2005'))
where empno = 412;
update emp
set empaddr = empaddr_ty('Belarus', 'Minsk', 'Chkalova', 6, 220039, to_date('28-10-2008'))
where empno = 503;

--3. Создайте запрос, определяющий номер сотрудника, его имя,  время проживания по данному в таблице  emp адресу
--для сотрудников с номерами 505, 205, 503. Использовать метод, созданный в п.1.

select empno,
       empname,
       e.empaddr.days_of_living()
from emp e
where empno in (505, 205, 503);

--4. Используя наследование, создайте объектный тип empaddres_ty на основе ранее созданного объектного типа
--empaddr_ty с дополнительными атрибутами
--houmtel varchar (15), mtstel varchar (15), welcomtel varchar (15).

create or replace type empaddres_ty
    under empaddr_ty
(
    houmtel   varchar(15),
    mtstel    varchar(15),
    welcomtel varchar(15)
);
--5. Создайте таблицу emphouminf с полями empno, empaddres (объектного типа  empaddres_ty),
--связанную с таблицей emp по полю empno.
create table emphouminf
(
    empno     integer not null,
    empaddres empaddres_ty,
    constraint fk_empno
        foreign key (empno)
            references emp (empno)
);

--6. Внесите в таблицу emphouminf следующие данные для сотрудников:
--505	Belarus	Minsk	Chkalova    	2    220039	15.01.2007	2241412	    7111111      6111111
--303	Belarus	Minsk	Poushkina  	12   220087	16.05.2005	2341516     Null         6137677
--205	Belarus	Minsk	Serova	 	14   220013	20.11.2008   	Null	    Null         6276655
--412	Belarus	Minsk	Serova       	23   220013	14.12.2005	2351412	    Null         Null
--503	Belarus	Minsk	Chkalova    	6    220039	28.10.2008      Null	    7161512      6122334

insert into emphouminf (empno, empaddres)
values (505,
        empaddres_ty('Belarus', 'Minsk', 'Chkalova', 2, 220039, to_date('15.01.2007', 'dd-mm-yyyy'), 2241412, 7111111,
                     6111111));
insert into emphouminf (empno, empaddres)
values (303,
        empaddres_ty('Belarus', 'Minsk', 'Poushkina', 12, 220087, to_date('16.05.2005', 'dd-mm-yyyy'), 2341516, null,
                     6137677));
insert into emphouminf (empno, empaddres)
values (205, empaddres_ty('Belarus', 'Minsk', 'Serova', 14, 220013, to_date('20.11.2008', 'dd-mm-yyyy'), null, null,
                          6276655));
insert into emphouminf (empno, empaddres)
values (412, empaddres_ty('Belarus', 'Minsk', 'Serova', 23, 220013, to_date('14.12.2005', 'dd-mm-yyyy'), 2351412, null,
                          null));
insert into emphouminf (empno, empaddres)
values (503, empaddres_ty('Belarus', 'Minsk', 'Chkalova', 6, 220039, to_date('28.10.2008', 'dd-mm-yyyy'), null, 7161512,
                          6122334));

--7. Создайте запрос, определяющий номер сотрудника, его имя, домашний телефон и время проживания
--по указанному адресу для сотрудников с номерами 303, 205, 412. Использовать метод, созданный в п.1.

SELECT e.empno,
       e.empname,
       e2.empaddres.houmtel,
       e.empaddr.days_of_living()
FROM emp e,
     emphouminf e2
WHERE e.empno IN (303, 205, 412)
  and e.empno = e2.empno;

--8. Удалите созданные таблицы и объектные типы.

drop table emphouminf purge;
drop type empaddres_ty force;
drop type empaddr_ty force;

