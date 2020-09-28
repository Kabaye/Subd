create or replace trigger TRG_HIKE_TOURIST_LEVEL
    before insert or update of TOURIST_ID
    on HIKE_TOURIST
    for each row
declare
    lvl NUMBER;
    hlvl number;
begin
    select CURRENT_LEVEL into lvl from TOURIST where TOURIST.ID = :new.TOURIST_ID;
    select HIKE_LEVEL into hlvl from HIKE where ID = :new.HIKE_ID;
    if lvl < hlvl - 1
    then
        RAISE_APPLICATION_ERROR (
                -20001,
                'ERROR: Tourist level must be previous or same for that hike!'
            );
    end if;
end;