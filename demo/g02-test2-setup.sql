USE [SpaceBookingDB_Phase2];
GO
SET NOCOUNT ON;
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

INSERT INTO SpaceBooking (
    requester_id, campus_space_code, requested_start_time, requested_end_time,
    purpose_type, expected_participants, status, is_instant_booking
)
VALUES (
    5, N'C301', '2026-09-15T14:00:00', '2026-09-15T16:00:00',
    N'seminar', 30, N'pending', 0
);

INSERT INTO SpaceMaintenance (
    campus_space_code, reporter_id, assigned_staff_id, impact_level,
    problem_description, problem_type, start_time, completion_time, status
)
VALUES (
    N'C301', 4, 3, N'advisory', N'Faulty stage lighting system', N'other',
    '2026-09-15T13:00:00', NULL, N'in_progress'
);
PRINT 'TEST2_SETUP_OK';
GO
