-- ============================================================================
-- Step 13 - Concurrency Tests
-- School of Computer Science Space Booking System
-- Group: G02
-- DBMS:  Microsoft SQL Server
-- Target Database: SpaceBookingDB_Phase2
-- ============================================================================
--
-- VERIFIES: 12-concurrency-implementation-G02.sql (Step 12 procedures)
--   * dbo.sp_SubmitSpaceBooking      (against Step 11 Error 1, 11 Section 2.1)
--   * dbo.sp_ApproveSpaceBooking     )
--   * dbo.sp_EscalateSpaceMaintenance) against Step 11 Error 2, 11 Section 2.2
--
-- INVARIANTS UNDER TEST:
--   * BR-01 / BR-12  : at most one active booking per space per overlapping
--                      time window (double-allocation prevention).
--   * BR-02 / BR-09  : a booking may not be approved for a window overlapping
--                      active out_of_service maintenance.
--   * BR-14          : escalation flags already-approved bookings that overlap
--                      the maintenance period (staff outreach list).
--
-- SCOPE: tests only the objects produced in Step 12. It does not add any
-- procedure, trigger, or constraint, and does not modify the schema created
-- by 10-schema-migration-G02.sql. Test setup rows are created and removed
-- by this script itself; a test-only policy change (classroom instant booking)
-- is restored at the end.
--
-- RUN INSTRUCTIONS: see 13-concurrency-tests-G02.md Section 5. A pass is
-- signalled by the 'TEST n PASSED' PRINT messages; any failed assertion
-- raises a THROW with a distinctive message.
--
-- PREREQUISITES (run in order, see 13-concurrency-tests-G02.md Section 5.1):
--   1) 05-db-definition-G02.sql          (SpaceBookingDB)
--   2) 06-sample-data-G02.sql            (SpaceBookingDB sample data)
--   3) 10-schema-migration-G02.sql       (SpaceBookingDB_Phase2)
--   4) 12-concurrency-implementation-G02.sql (the three procedures)
-- ============================================================================

USE [SpaceBookingDB_Phase2];
GO

SET NOCOUNT ON;
GO

-- ============================================================================
-- TEST 1 - Error 1: Concurrent Instant Booking Double-Allocation
-- Invariant: BR-01 / BR-12  (Step 11 Section 2.1, Section 4.1)
-- Procedure under test: dbo.sp_SubmitSpaceBooking
-- Space: B201 (Lecture Room 201, classroom, capacity 60, 'available')
-- Users: 4 (Hoang Thi Mai, lecturer) and 5 (Truong Minh Tam, student)
-- Window: 2026-09-10 10:00-12:00
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TEST 1.0 - Precondition setup
-- ----------------------------------------------------------------------------
-- Enable instant booking for classrooms (BR-11) exactly as the Step 11
-- reproduction did. The migrated default is 0; it is restored in TEST 1.3.
UPDATE SpaceTypeBookingPolicy
SET instant_booking_eligible = 1
WHERE space_type = N'classroom';

-- Remove any leftover rows from a previous run of this script for the same
-- window (the script is re-runnable).
DELETE FROM SpaceBooking
WHERE campus_space_code = N'B201'
  AND requested_start_time = '2026-09-10 10:00:00';

PRINT 'TEST 1: precondition ready (classroom instant booking enabled, B201 window clean).';
GO

-- ----------------------------------------------------------------------------
-- TEST 1.1 - Session 1: first submission must succeed as an instant booking
-- ----------------------------------------------------------------------------
DECLARE @t1_bid   INT;
DECLARE @t1_status NVARCHAR(20);
DECLARE @t1_notified BIT;

EXEC dbo.sp_SubmitSpaceBooking
    @requester_id          = 4,
    @campus_space_code     = N'B201',
    @requested_start_time  = '2026-09-10 10:00:00',
    @requested_end_time    = '2026-09-10 12:00:00',
    @purpose_type          = N'lecture',
    @expected_participants = 30,
    @space_booking_id      = @t1_bid OUTPUT,
    @result_status         = @t1_status OUTPUT,
    @advisories_notified   = @t1_notified OUTPUT;

IF @t1_status <> N'approved'
    THROW 59101, N'TEST 1 FAILED: first submission did not become an instant-approved booking.', 1;
IF @t1_bid IS NULL
    THROW 59102, N'TEST 1 FAILED: first submission returned no booking id.', 1;

PRINT 'TEST 1: Session 1 (user 4) submitted and was approved instantly (booking id ' + CAST(@t1_bid AS NVARCHAR(10)) + ').';
GO

-- ----------------------------------------------------------------------------
-- TEST 1.2 - Session 2: the conflicting overlapping submission must be
--            rejected by the guard (error 50008, BR-01/BR-12).
--            In the un-isolated Step 11 reproduction this second operation
--            also committed, violating the invariant.
-- ----------------------------------------------------------------------------
DECLARE @t1_op2_error INT = 0;

BEGIN TRY
    DECLARE @t1_bid2   INT;
    DECLARE @t1_status2 NVARCHAR(20);
    DECLARE @t1_notified2 BIT;

    EXEC dbo.sp_SubmitSpaceBooking
        @requester_id          = 5,
        @campus_space_code     = N'B201',
        @requested_start_time  = '2026-09-10 10:00:00',
        @requested_end_time    = '2026-09-10 12:00:00',
        @purpose_type          = N'seminar',
        @expected_participants = 25,
        @space_booking_id      = @t1_bid2 OUTPUT,
        @result_status         = @t1_status2 OUTPUT,
        @advisories_notified   = @t1_notified2 OUTPUT;

    -- Reaching this line means the guard FAILED to reject the second booking.
    RAISERROR(N'TEST 1 FAILED: the conflicting instant booking was NOT rejected by sp_SubmitSpaceBooking.', 16, 1);
END TRY
BEGIN CATCH
    SET @t1_op2_error = ERROR_NUMBER();
END CATCH;

-- Assertion 1: the guard's own BR-01/BR-12 error (50008) was raised.
IF @t1_op2_error <> 50008
    THROW 59103, N'TEST 1 FAILED: expected error 50008 (BR-01/BR-12) was not raised by the conflicting submission.', 1;

-- Assertion 2: exactly one active booking overlaps the B201 window.
IF (SELECT COUNT(*)
    FROM SpaceBooking
    WHERE campus_space_code = N'B201'
      AND status IN (N'approved', N'checked_in', N'completed', N'no-show')
      AND requested_start_time < '2026-09-10 12:00:00'
      AND requested_end_time > '2026-09-10 10:00:00') <> 1
    THROW 59104, N'TEST 1 FAILED: BR-01/BR-12 overlap invariant does not hold for B201.', 1;

PRINT 'TEST 1 PASSED: conflicting instant submission rejected (error 50008) and only 1 active booking overlaps the B201 window.';
GO

-- ----------------------------------------------------------------------------
-- TEST 1.3 - Cleanup: remove the test booking and restore the classroom
--            policy to the migrated default (0).
-- ----------------------------------------------------------------------------
DELETE FROM SpaceBooking
WHERE campus_space_code = N'B201'
  AND requested_start_time = '2026-09-10 10:00:00';

UPDATE SpaceTypeBookingPolicy
SET instant_booking_eligible = 0
WHERE space_type = N'classroom';

PRINT 'TEST 1: cleanup complete (test booking removed, classroom policy restored).';
GO

-- ============================================================================
-- TEST 2 - Error 2: Staff Approval Racing Maintenance Escalation
-- Invariant: BR-02 / BR-09  (Step 11 Section 2.2, Section 4.2, Section 4.3)
-- Procedures under test: dbo.sp_ApproveSpaceBooking, dbo.sp_EscalateSpaceMaintenance
-- Space: C301 (Computer Lab Alpha, computer_lab, capacity 40, 'available')
--   (A101 cannot isolate this race in the migrated data: it already carries an
--    open-ended out_of_service maintenance, space_maintenance_id = 6.)
-- Users: 2 (facility_staff, approver), 3 (facility_staff, escalation),
--        4 (lecturer, maintenance reporter), 5 (student, booking requester)
-- Window: 2026-09-15 14:00-16:00 ; advisory maintenance 2026-09-15 13:00 (open)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TEST 2.0 - Precondition setup
-- ----------------------------------------------------------------------------
-- Clean any leftovers from a previous run of this script.
DELETE a FROM BookingApproval a
WHERE a.space_booking_id IN (
    SELECT space_booking_id FROM SpaceBooking
    WHERE campus_space_code = N'C301'
      AND requested_start_time = '2026-09-15 14:00:00');

DELETE FROM SpaceBooking
WHERE campus_space_code = N'C301'
  AND requested_start_time = '2026-09-15 14:00:00';

DELETE FROM SpaceMaintenance
WHERE campus_space_code = N'C301'
  AND start_time = '2026-09-15 13:00:00'
  AND problem_description = N'Faulty stage lighting system';

-- Create the pending booking (staff workflow: status 'pending', is_instant 0).
INSERT INTO SpaceBooking (
    requester_id, campus_space_code, requested_start_time, requested_end_time,
    purpose_type, expected_participants, status, is_instant_booking
)
VALUES (
    5, N'C301', '2026-09-15 14:00:00', '2026-09-15 16:00:00',
    N'seminar', 30, N'pending', 0
);

-- Create the active advisory maintenance record on C301 (mirrors Step 11
-- reproduction setup: reporter user 4, assigned staff user 3).
INSERT INTO SpaceMaintenance (
    campus_space_code, reporter_id, assigned_staff_id, impact_level,
    problem_description, problem_type, start_time, completion_time, status
)
VALUES (
    N'C301', 4, 3, N'advisory',
    N'Faulty stage lighting system', N'other', '2026-09-15 13:00:00', NULL, N'in_progress'
);

PRINT 'TEST 2: precondition ready (pending booking + advisory maintenance on C301).';
GO

-- ----------------------------------------------------------------------------
-- TEST 2.1 - Operation A (Session B in the Step 11 reproduction): escalate the
--            advisory maintenance to out_of_service. Must succeed; the pending
--            booking is NOT yet affected (BR-14 counts only approved/checked_in).
-- ----------------------------------------------------------------------------
DECLARE @t2_affected INT;
DECLARE @t2_mid INT;
SELECT @t2_mid = space_maintenance_id
FROM SpaceMaintenance
WHERE campus_space_code = N'C301'
  AND start_time = '2026-09-15 13:00:00'
  AND problem_description = N'Faulty stage lighting system';

IF @t2_mid IS NULL
    THROW 59207, N'TEST 2 FAILED: test maintenance record was not found before escalation.', 1;

EXEC dbo.sp_EscalateSpaceMaintenance
    @space_maintenance_id = @t2_mid,
    @staff_id             = 3,
    @new_impact_level     = N'out_of_service',
    @affected_count       = @t2_affected OUTPUT;

IF @t2_affected <> 0
    THROW 59201, N'TEST 2 FAILED: escalation should flag 0 bookings while the booking is still pending.', 1;

IF (SELECT impact_level FROM SpaceMaintenance WHERE space_maintenance_id = @t2_mid) <> N'out_of_service'
    THROW 59202, N'TEST 2 FAILED: escalation did not set impact_level = out_of_service.', 1;

PRINT 'TEST 2: escalation succeeded (impact_level = out_of_service, affected_count = 0).';
GO

-- ----------------------------------------------------------------------------
-- TEST 2.2 - Operation B (Session A in the Step 11 reproduction): approve the
--            pending booking AFTER the escalation committed. The approval's
--            blocking-state re-check must reject it (error 50017, BR-02/BR-09).
-- ----------------------------------------------------------------------------
DECLARE @t2_op2_error INT = 0;
DECLARE @t2_bid INT;
SELECT @t2_bid = space_booking_id
FROM SpaceBooking
WHERE campus_space_code = N'C301'
  AND requested_start_time = '2026-09-15 14:00:00';

IF @t2_bid IS NULL
    THROW 59208, N'TEST 2 FAILED: test pending booking was not found before approval.', 1;

BEGIN TRY
    EXEC dbo.sp_ApproveSpaceBooking
        @space_booking_id = @t2_bid,
        @staff_id         = 2,
        @decision         = N'approved',
        @decision_note    = N'Approved by staff';

    -- Reaching this line means the guard FAILED to reject the approval.
    RAISERROR(N'TEST 2 FAILED: the conflicting approval was NOT rejected by sp_ApproveSpaceBooking.', 16, 1);
END TRY
BEGIN CATCH
    SET @t2_op2_error = ERROR_NUMBER();
END CATCH;

-- Assertion 1: the guard's own BR-02/BR-09 error (50017) was raised.
IF @t2_op2_error <> 50017
    THROW 59203, N'TEST 2 FAILED: expected error 50017 (BR-02/BR-09) was not raised by the approval.', 1;

-- Assertion 2: the booking remained pending.
IF (SELECT status FROM SpaceBooking WHERE space_booking_id = @t2_bid) <> N'pending'
    THROW 59204, N'TEST 2 FAILED: booking status changed despite the rejected approval.', 1;

-- Assertion 3: the space status reflects the out_of_service maintenance.
IF (SELECT current_status FROM CampusSpace WHERE campus_space_code = N'C301') <> N'under_maintenance'
    THROW 59205, N'TEST 2 FAILED: CampusSpace.current_status was not set to under_maintenance.', 1;

-- Assertion 4: BR-02 invariant - no approved booking overlaps the maintenance.
IF EXISTS (
    SELECT 1
    FROM SpaceBooking
    WHERE campus_space_code = N'C301'
      AND status IN (N'approved', N'checked_in', N'completed', N'no-show')
      AND requested_start_time < '2026-09-15 16:00:00'
      AND requested_end_time > '2026-09-15 14:00:00'
)
    THROW 59206, N'TEST 2 FAILED: an approved booking overlaps out_of_service maintenance (BR-02 violated).', 1;

PRINT 'TEST 2 PASSED: approval rejected (error 50017); booking still pending; C301 under out_of_service maintenance.';
GO

-- ============================================================================
-- TEST 2B - Reverse ordering (supplementary): approval commits BEFORE the
--           escalation. The guard must allow the approval (no out_of_service
--           maintenance yet) and the later escalation must flag the approved
--           booking for staff outreach (BR-14, Step 11 Section 4.3 step 6).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TEST 2B.0 - Restore the maintenance to advisory (downgrade) so the approval
--             is evaluated against a clean space. The trigger
--             trg_SpaceMaintenance_UpdateSpaceStatus restores C301 to
--             'available' once no active out_of_service maintenance remains.
-- ----------------------------------------------------------------------------
DECLARE @t2b_cnt INT;
DECLARE @t2_mid INT;
SELECT @t2_mid = space_maintenance_id
FROM SpaceMaintenance
WHERE campus_space_code = N'C301'
  AND start_time = '2026-09-15 13:00:00'
  AND problem_description = N'Faulty stage lighting system';

EXEC dbo.sp_EscalateSpaceMaintenance
    @space_maintenance_id = @t2_mid,
    @staff_id             = 2,
    @new_impact_level     = N'advisory',
    @affected_count       = @t2b_cnt OUTPUT;

IF (SELECT current_status FROM CampusSpace WHERE campus_space_code = N'C301') <> N'available'
    THROW 59301, N'TEST 2B FAILED: C301 was not restored to available after downgrade.', 1;

-- ----------------------------------------------------------------------------
-- TEST 2B.1 - Operation A (approval first): must succeed now.
-- ----------------------------------------------------------------------------
DECLARE @t2_bid INT;
SELECT @t2_bid = space_booking_id
FROM SpaceBooking
WHERE campus_space_code = N'C301'
  AND requested_start_time = '2026-09-15 14:00:00';

EXEC dbo.sp_ApproveSpaceBooking
    @space_booking_id = @t2_bid,
    @staff_id         = 2,
    @decision         = N'approved',
    @decision_note    = N'Approved by staff';

IF (SELECT status FROM SpaceBooking WHERE space_booking_id = @t2_bid) <> N'approved'
    THROW 59302, N'TEST 2B FAILED: approval of the pending booking did not succeed.', 1;

PRINT 'TEST 2B: approval committed first (booking now approved).';
GO

-- ----------------------------------------------------------------------------
-- TEST 2B.2 - Operation B (escalation second): must succeed and flag the
--             approved booking (BR-14 outreach list, affected_count = 1).
-- ----------------------------------------------------------------------------
CREATE TABLE #t2b_affected (
    space_booking_id        INT          NOT NULL,
    requester_id            INT          NOT NULL,
    campus_space_code       NVARCHAR(20) NOT NULL,
    requested_start_time    DATETIME2    NOT NULL,
    requested_end_time      DATETIME2    NOT NULL,
    status                  NVARCHAR(20) NOT NULL
);
GO

DECLARE @t2b_affected INT;
DECLARE @t2_bid INT;
DECLARE @t2_mid INT;
SELECT @t2_bid = space_booking_id
FROM SpaceBooking
WHERE campus_space_code = N'C301'
  AND requested_start_time = '2026-09-15 14:00:00';

SELECT @t2_mid = space_maintenance_id
FROM SpaceMaintenance
WHERE campus_space_code = N'C301'
  AND start_time = '2026-09-15 13:00:00'
  AND problem_description = N'Faulty stage lighting system';

INSERT INTO #t2b_affected
EXEC dbo.sp_EscalateSpaceMaintenance
    @space_maintenance_id = @t2_mid,
    @staff_id             = 2,
    @new_impact_level     = N'out_of_service',
    @affected_count       = @t2b_affected OUTPUT;

-- Assertion 1: exactly one affected booking, and it is the approved one.
IF @t2b_affected <> 1
    THROW 59303, N'TEST 2B FAILED: escalation affected_count is not 1.', 1;

IF NOT EXISTS (SELECT 1 FROM #t2b_affected WHERE space_booking_id = @t2_bid)
    THROW 59304, N'TEST 2B FAILED: the approved booking was not returned in the escalation outreach list.', 1;

-- Assertion 2: the space status follows the escalated maintenance.
IF (SELECT current_status FROM CampusSpace WHERE campus_space_code = N'C301') <> N'under_maintenance'
    THROW 59305, N'TEST 2B FAILED: C301 not marked under_maintenance after escalation.', 1;

PRINT 'TEST 2B PASSED: reverse ordering — approval committed, escalation flagged ' + CAST(@t2b_affected AS NVARCHAR(10)) + ' affected booking (BR-14).';
GO

-- ----------------------------------------------------------------------------
-- TEST 2B.3 - Cleanup: remove the test rows and the temp table, and restore
--             C301 to its migrated status.
-- ----------------------------------------------------------------------------
DROP TABLE #t2b_affected;

DECLARE @t2_bid INT;
DECLARE @t2_mid INT;
SELECT @t2_bid = space_booking_id
FROM SpaceBooking
WHERE campus_space_code = N'C301'
  AND requested_start_time = '2026-09-15 14:00:00';

SELECT @t2_mid = space_maintenance_id
FROM SpaceMaintenance
WHERE campus_space_code = N'C301'
  AND start_time = '2026-09-15 13:00:00'
  AND problem_description = N'Faulty stage lighting system';

DELETE a FROM BookingApproval a
WHERE a.space_booking_id = @t2_bid;

DELETE FROM SpaceBooking
WHERE space_booking_id = @t2_bid;

DELETE FROM SpaceMaintenance
WHERE space_maintenance_id = @t2_mid;

-- The maintenance trigger only covers INSERT/UPDATE, so restore the status
-- explicitly after deleting the test maintenance row.
UPDATE CampusSpace
SET current_status = N'available'
WHERE campus_space_code = N'C301';

PRINT 'TEST 2/2B: cleanup complete (test rows removed, C301 restored).';
GO

-- ============================================================================
-- TRACEABILITY MATRIX (Step 13 -> Step 11 design document -> Step 12 objects)
-- All identifiers are sourced from 11-concurrency-design-G02.md,
-- 12-concurrency-implementation-G02.sql, and the migrated sample data.
--
-- | Test section    | Concurrency error                     | Invariant verified   | Design-doc section (11) |
-- |-----------------|---------------------------------------|----------------------|-------------------------|
-- | TEST 1          | Error 1 - instant-booking double       | BR-01 / BR-12        | Section 2.1, Section 4.1 |
-- |                 | allocation                             |                      |                         |
-- | TEST 2          | Error 2 - staff approval vs            | BR-02 / BR-09        | Section 2.2, Section 4.2 |
-- |                 | maintenance escalation                 |                      | + Section 4.3           |
-- | TEST 2B         | complementary ordering of Error 2      | BR-14 (outreach)     | Section 4.3 step 6       |
--
-- Error-number provenance: 50008 = sp_SubmitSpaceBooking overlap throw;
-- 50017 = sp_ApproveSpaceBooking maintenance throw (12-concurrency-
-- implementation-G02.sql).
-- ============================================================================

PRINT 'Step 13 concurrency tests completed against SpaceBookingDB_Phase2.';
GO
