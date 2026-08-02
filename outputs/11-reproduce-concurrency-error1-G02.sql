-- ============================================================================
-- Step 11: Concurrency Error 1 Reproduction Script
-- Group: G02
-- Database: SpaceBookingDB_Phase2
-- Scenario: Concurrent Instant Booking Double-Allocation (BR-01 / BR-12 Violation)
--
-- Sample Data Reference:
--   Space B201 = 'Lecture Room 201', classroom, capacity 60, status 'available'
--   User 4 = Hoàng Thị Mai (lecturer)
--   User 5 = Trương Minh Tâm (student)
-- ============================================================================

USE SpaceBookingDB_Phase2;
GO

-- ----------------------------------------------------------------------------
-- 1. SETUP (Run once before opening Session A and Session B)
-- ----------------------------------------------------------------------------

-- Enable instant booking for classrooms (required for this scenario)
UPDATE SpaceTypeBookingPolicy
SET instant_booking_eligible = 1
WHERE space_type = 'classroom';
GO

-- Clean up any existing test bookings for space B201 on the target date
DELETE FROM SpaceBooking 
WHERE campus_space_code = 'B201' 
  AND requested_start_time = '2026-09-10 10:00:00';
GO

PRINT 'Setup completed. Open two parallel connections: Session A and Session B.';
GO

/*
-- ----------------------------------------------------------------------------
-- 2. INTERLEAVED EXECUTION STEPS
--    Execute these in order across two separate SSMS query windows.
-- ----------------------------------------------------------------------------

-- [STEP A1 - Session A Window (User 4: Hoàng Thị Mai, lecturer)]
USE SpaceBookingDB_Phase2;
GO
BEGIN TRANSACTION;
SELECT COUNT(*) AS OverlapCount
FROM SpaceBooking
WHERE campus_space_code = 'B201'
  AND status IN ('approved', 'checked_in', 'completed', 'no-show')
  AND requested_start_time < '2026-09-10 12:00:00'
  AND requested_end_time > '2026-09-10 10:00:00';
-- Expected result: OverlapCount = 0. Space appears available!
-- DO NOT COMMIT YET. Switch to Session B.


-- [STEP B1 - Session B Window (User 5: Trương Minh Tâm, student)]
USE SpaceBookingDB_Phase2;
GO
BEGIN TRANSACTION;
SELECT COUNT(*) AS OverlapCount
FROM SpaceBooking
WHERE campus_space_code = 'B201'
  AND status IN ('approved', 'checked_in', 'completed', 'no-show')
  AND requested_start_time < '2026-09-10 12:00:00'
  AND requested_end_time > '2026-09-10 10:00:00';
-- Expected result: OverlapCount = 0 (Session A has not committed!)


-- [STEP B2 - Session B Window (continue)]
INSERT INTO SpaceBooking (
    requester_id, campus_space_code, requested_start_time, requested_end_time,
    purpose_type, expected_participants, status, is_instant_booking
)
VALUES (
    5, 'B201', '2026-09-10 10:00:00', '2026-09-10 12:00:00',
    'seminar', 25, 'approved', 1
);
COMMIT TRANSACTION;
PRINT 'Session B committed successfully.';
GO
-- Switch back to Session A.


-- [STEP A2 - Session A Window (continue)]
INSERT INTO SpaceBooking (
    requester_id, campus_space_code, requested_start_time, requested_end_time,
    purpose_type, expected_participants, status, is_instant_booking
)
VALUES (
    4, 'B201', '2026-09-10 10:00:00', '2026-09-10 12:00:00',
    'lecture', 30, 'approved', 1
);
COMMIT TRANSACTION;
PRINT 'Session A committed successfully.';
GO


-- ----------------------------------------------------------------------------
-- 3. VERIFICATION QUERY (Run in a new query window after both sessions commit)
-- ----------------------------------------------------------------------------
USE SpaceBookingDB_Phase2;
GO
SELECT space_booking_id, requester_id, campus_space_code, 
       requested_start_time, requested_end_time, status, is_instant_booking
FROM SpaceBooking
WHERE campus_space_code = 'B201'
  AND requested_start_time = '2026-09-10 10:00:00';
-- VIOLATION OBSERVED: Two overlapping approved bookings exist for B201!
-- Both requester_id 4 and 5 have 'approved' bookings at the same time.
GO
*/
