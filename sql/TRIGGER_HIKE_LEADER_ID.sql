create or replace trigger TRG_HIKE_LEADER_ID
    before insert or update
    on HIKE
    for each row
declare
    lvl NUMBER;
begin
    select TOURIST.CURRENT_LEVEL into lvl from TOURIST where TOURIST.ID = :new.LEADER_ID;
    if lvl < :new.HIKE_LEVEL
    then
        RAISE_APPLICATION_ERROR (
                -20001,
                'ERROR: Leader level must be same or greater than hike level'
            );
    end if;
end;