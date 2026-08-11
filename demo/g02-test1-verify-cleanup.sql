USE [SpaceBookingDB_Phase2];
GO
SET NOCOUNT ON;
SELECT COUNT(*) AS overlapping_active_bookings
FROM SpaceBooking
WHERE campus_space_code = N'B201'
  AND status IN (N'approved', N'checked_in', N'completed', N'no-show')
  AND requested_start_time < '2026-09-10T12:00:00'
  AND requested_end_time > '2026-09-10T10:00:00';

DELETE FROM SpaceBooking
WHERE campus_space_code = N'B201'
  AND requested_start_time = '2026-09-10T10:00:00';

UPDATE SpaceTypeBookingPolicy
SET instant_booking_eligible = 0
WHERE space_type = N'classroom';
PRINT 'TEST1_CLEANUP_OK';
GO
