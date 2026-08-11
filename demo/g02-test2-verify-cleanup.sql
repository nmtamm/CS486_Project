USE [SpaceBookingDB_Phase2];
GO
SET NOCOUNT ON;
SELECT sb.status AS booking_status,
       sm.impact_level,
       cs.current_status,
       (SELECT COUNT(*)
        FROM SpaceBooking AS x
        WHERE x.campus_space_code = N'C301'
          AND x.status IN (N'approved', N'checked_in', N'completed', N'no-show')
          AND x.requested_start_time < '2026-09-15T16:00:00'
          AND x.requested_end_time > '2026-09-15T14:00:00') AS overlapping_active_bookings
FROM SpaceBooking AS sb
JOIN CampusSpace AS cs ON cs.campus_space_code = sb.campus_space_code
JOIN SpaceMaintenance AS sm ON sm.campus_space_code = sb.campus_space_code
WHERE sb.campus_space_code = N'C301'
  AND sb.requested_start_time = '2026-09-15T14:00:00'
  AND sm.start_time = '2026-09-15T13:00:00'
  AND sm.problem_description = N'Faulty stage lighting system';

DELETE a FROM BookingApproval AS a
WHERE a.space_booking_id IN (
    SELECT space_booking_id
    FROM SpaceBooking
    WHERE campus_space_code = N'C301'
      AND requested_start_time = '2026-09-15T14:00:00'
);

DELETE FROM SpaceBooking
WHERE campus_space_code = N'C301'
  AND requested_start_time = '2026-09-15T14:00:00';

DELETE FROM SpaceMaintenance
WHERE campus_space_code = N'C301'
  AND start_time = '2026-09-15T13:00:00'
  AND problem_description = N'Faulty stage lighting system';

UPDATE CampusSpace
SET current_status = N'available'
WHERE campus_space_code = N'C301';
PRINT 'TEST2_CLEANUP_OK';
GO
