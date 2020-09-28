alter session set "_ORACLE_SCRIPT"=true;

CREATE USER TOURISM IDENTIFIED BY Password123
    DEFAULT TABLESPACE users
    TEMPORARY TABLESPACE temp;

GRANT connect to TOURISM;
GRANT resource to TOURISM;

GRANT create session TO TOURISM;
GRANT create table TO TOURISM;
GRANT create view TO TOURISM;
GRANT create any trigger TO TOURISM;
GRANT create any procedure TO TOURISM;
GRANT create sequence TO TOURISM;
GRANT create synonym TO TOURISM;

ALTER USER TOURISM QUOTA UNLIMITED ON USERS