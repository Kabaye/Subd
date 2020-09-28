CREATE or replace TRIGGER TRG_HIKE_TOURIST_AMOUNT_UPDATE
    BEFORE UPDATE or DELETE
    ON HIKE_TOURIST
    FOR EACH ROW
DECLARE
    pragma autonomous_transaction;
    amount number;
BEGIN
    select COUNT(*) into amount from HIKE_TOURIST where HIKE_ID = :old.HIKE_ID;
    IF amount = 5 and (:old.HIKE_ID != :new.HIKE_ID or :new.HIKE_ID is null) then
        RAISE_APPLICATION_ERROR(-20010,
                                'ERROR: Hike must have at least 5 tourist in it! ' ||
                                'After this operation you will have only = ' || to_char(amount - 1));
    end if;
    commit;
END;