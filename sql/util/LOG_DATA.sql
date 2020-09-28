create or replace procedure log_p (p_message in varchar)
    is
    pragma autonomous_transaction;
begin
    insert into MESSAGE_LOG (datetime, message)
    values (sysdate, p_message);
    commit;
end;