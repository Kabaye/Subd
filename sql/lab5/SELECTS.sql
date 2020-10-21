-- 1
select DEPTADDRESS
from dept
where DEPTNAME = 'Sales';
-- 2
select *
from EMP
where BIRTHDATE >= to_date('01-01-1985');
-- 3
select MIN(MINSALARY)
from JOB
where JOBNAME = 'Driver';
-- 4
select COUNT(EMPNO)
from CAREER
where STARTDATE >= TO_DATE('01-06-2017')
  and (ENDDATE >= TO_DATE('02-06-2017') or ENDDATE is null);
-- 5
select YEAR, MIN(BONVALUE)
from BONUS
where YEAR in (2016, 2017, 2018, 2019)
group by YEAR
order by YEAR;
-- 6
select JOBNO
from CAREER,
     EMP
where CAREER.EMPNO = EMP.EMPNO
  and EMP.EMPNAME = 'Nina Tihanovich'
