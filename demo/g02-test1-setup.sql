USE [SpaceBookingDB_Phase2];
GO
SET NOCOUNT ON;
UPDATE SpaceTypeBookingPolicy
SET instant_booking_eligible = 1
WHERE space_type = N'classroom';

DELETE FROM SpaceBooking
WHERE campus_space_code = N'B201'
  AND requested_start_time = '2026-09-10T10:00:00';

PRINT 'TEST1_SETUP_OK';
GO
