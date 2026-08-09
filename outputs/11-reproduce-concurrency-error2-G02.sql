-- ============================================================================
-- Step 11: Concurrency Error 2 Reproduction Script
-- Group: G02
-- Database: SpaceBookingDB_Phase2
-- Scenario: Concurrent Staff Approval vs. Maintenance Escalation (BR-02 Violation)
--
-- Sample Data Reference:
--   Space C301 = 'Computer Lab Alpha', computer_lab, capacity 40, status 'available'
--   User 2452 = (facility_staff) — approves the booking
--   User 2451 = (facility_staff) — escalates the maintenance
--   User 2001 = Hoàng Thị Mai (lecturer) — reporter of maintenance
--   User 5 = Trương Minh Tâm (student) — booking requester
-- ============================================================================

USE SpaceBookingDB_Phase2;
GO

-- ----------------------------------------------------------------------------
-- 1. SETUP (Run once before opening Session A and Session B)
-- ----------------------------------------------------------------------------

-- Create a pending booking for computer lab C301 (User 5, student)
INSERT INTO SpaceBooking (
    requester_id, campus_space_code, requested_start_time, requested_end_time,
    purpose_type, expected_participants, status, is_instant_booking
)
VALUES (
    5, 'C301', '2026-09-15 14:00:00', '2026-09-15 16:00:00',
    'seminar', 30, 'pending', 0
);

-- Create an active advisory maintenance record on C301
-- (reporter = User 2001, assigned_staff = User 2451)
INSERT INTO SpaceMaintenance (
    campus_space_code, reporter_id, assigned_staff_id, impact_level,
    problem_description, problem_type, start_time, completion_time, status
)
VALUES (
    'C301', 2001, 2451, 'advisory',
    'Faulty stage lighting system', 'other', '2026-09-15 13:00:00', NULL, 'in_progress'
);

PRINT 'Setup completed for Error 2. Open two parallel connections: Session A and Session B.';
GO

/*
-- ----------------------------------------------------------------------------
-- 2. INTERLEAVED EXECUTION STEPS
--    Execute these in order across two separate SSMS query windows.
-- ----------------------------------------------------------------------------

-- [STEP A1 - Session A Window (user 2452, facility_staff — approver)]
USE SpaceBookingDB_Phase2;
GO
BEGIN TRANSACTION;
SELECT COUNT(*) AS OutOfServiceMaintCount
FROM SpaceMaintenance
WHERE campus_space_code = 'C301'
  AND status IN ('reported', 'in_progress')
  AND impact_level = 'out_of_service'
  AND start_time < '2026-09-15 16:00:00'
  AND (completion_time IS NULL OR completion_time > '2026-09-15 14:00:00');
-- Expected result: OutOfServiceMaintCount = 0. No out-of-service maintenance!
-- DO NOT COMMIT YET. Switch to Session B.


-- [STEP B1 - Session B Window (user 2451, facility_staff — escalates)]
USE SpaceBookingDB_Phase2;
GO
BEGIN TRANSACTION;
UPDATE SpaceMaintenance
SET impact_level = 'out_of_service'
WHERE campus_space_code = 'C301'
  AND status IN ('reported', 'in_progress')
  AND impact_level = 'advisory';
COMMIT TRANSACTION;
PRINT 'Session B escalated maintenance to out_of_service.';
GO
-- Switch back to Session A.


-- [STEP A2 - Session A Window (user 2452 continues — approves the booking)]
DECLARE @TargetBookingID INT;
SELECT TOP 1 @TargetBookingID = space_booking_id 
FROM SpaceBooking 
WHERE campus_space_code = 'C301' 
  AND status = 'pending' 
  AND requested_start_time = '2026-09-15 14:00:00';

UPDATE SpaceBooking
SET status = 'approved'
WHERE space_booking_id = @TargetBookingID;

INSERT INTO BookingApproval (space_booking_id, staff_id, decision, decision_time, decision_note)
VALUES (@TargetBookingID, 2452, 'approved', GETDATE(), N'Approved by staff');

COMMIT TRANSACTION;
PRINT 'Session A approved the booking.';
GO


-- ----------------------------------------------------------------------------
-- 3. VERIFICATION QUERY (Run in a new query window after both sessions commit)
-- ----------------------------------------------------------------------------
USE SpaceBookingDB_Phase2;
GO
SELECT 
    b.space_booking_id, b.campus_space_code, b.status AS booking_status,
    b.requested_start_time, b.requested_end_time,
    m.space_maintenance_id, m.impact_level AS maint_impact_level, m.status AS maint_status
FROM SpaceBooking b
JOIN SpaceMaintenance m ON b.campus_space_code = m.campus_space_code
WHERE b.campus_space_code = 'C301'
  AND b.requested_start_time = '2026-09-15 14:00:00'
  AND m.status IN ('reported', 'in_progress');
-- VIOLATION OBSERVED: Booking is approved despite active out_of_service maintenance!
-- booking_status = 'approved' while maint_impact_level = 'out_of_service'
GO
*/
