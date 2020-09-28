-- # 1
select *
from TOURIST
where ID in (select TOURIST_ID from HIKE_TOURIST where HIKE_ID = :HIKE_ID);

-- # 2
with WID_HID_AMOUNT as (select WAYPOINT_ID,
                               COUNT(HIKE_ID)
                                   as HID_AMOUNT
                        from HIKE_WAYPOINT
                        group by WAYPOINT_ID)
select distinct HIKE_ID, START_DATE, LEADER_ID, HIKE_LEVEL, END_DATE
from HIKE
         inner join HIKE_WAYPOINT on HIKE.ID = HIKE_WAYPOINT.HIKE_ID
         inner join WID_HID_AMOUNT
                    on HIKE_WAYPOINT.WAYPOINT_ID = WID_HID_AMOUNT.WAYPOINT_ID and WID_HID_AMOUNT.HID_AMOUNT > 1

-- # 3
select CURRENT_LEVEL
from TOURIST
where NAME = :NAME;

