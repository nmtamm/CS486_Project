-- ============================================================================
-- Step 6 — Normal Test Cases: School of Computer Science Space Booking System
-- Group: G02
-- DBMS:  Microsoft SQL Server
-- Execute after: 06-sample-data-G02.sql
-- All test cases must PASS (return expected result)
-- ============================================================================

USE SpaceBookingDB;
GO


-- ============================================================================
-- RECORD COUNT VERIFICATION
-- ============================================================================

-- TC-N01: Verify CampusUser record count
-- Expected: 8
SELECT COUNT(*) AS user_count FROM CampusUser;

-- TC-N02: Verify CampusSpace record count
-- Expected: 8
SELECT COUNT(*) AS space_count FROM CampusSpace;

-- TC-N03: Verify CampusFacility record count
-- Expected: 6
SELECT COUNT(*) AS facility_count FROM CampusFacility;

-- TC-N04: Verify SpaceBooking record count
-- Expected: 10
SELECT COUNT(*) AS booking_count FROM SpaceBooking;

-- TC-N05: Verify BookingApproval record count
-- Expected: 6
SELECT COUNT(*) AS approval_count FROM BookingApproval;

-- TC-N06: Verify SpaceUsageSession record count
-- Expected: 4
SELECT COUNT(*) AS session_count FROM SpaceUsageSession;

-- TC-N07: Verify SpaceMaintenance record count
-- Expected: 6
SELECT COUNT(*) AS maintenance_count FROM SpaceMaintenance;


-- ============================================================================
-- PRIMARY KEY UNIQUENESS
-- ============================================================================

-- TC-N08: No duplicate campus_user_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_users
FROM (SELECT campus_user_id FROM CampusUser GROUP BY campus_user_id HAVING COUNT(*) > 1) AS dup;

-- TC-N09: No duplicate campus_space_code values
-- Expected: 0
SELECT COUNT(*) AS duplicate_spaces
FROM (SELECT campus_space_code FROM CampusSpace GROUP BY campus_space_code HAVING COUNT(*) > 1) AS dup;

-- TC-N10: No duplicate campus_facility_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_facilities
FROM (SELECT campus_facility_id FROM CampusFacility GROUP BY campus_facility_id HAVING COUNT(*) > 1) AS dup;

-- TC-N11: No duplicate space_booking_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_bookings
FROM (SELECT space_booking_id FROM SpaceBooking GROUP BY space_booking_id HAVING COUNT(*) > 1) AS dup;

-- TC-N12: No duplicate booking_approval_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_approvals
FROM (SELECT booking_approval_id FROM BookingApproval GROUP BY booking_approval_id HAVING COUNT(*) > 1) AS dup;

-- TC-N13: No duplicate space_usage_session_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_sessions
FROM (SELECT space_usage_session_id FROM SpaceUsageSession GROUP BY space_usage_session_id HAVING COUNT(*) > 1) AS dup;

-- TC-N14: No duplicate space_maintenance_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_maintenance
FROM (SELECT space_maintenance_id FROM SpaceMaintenance GROUP BY space_maintenance_id HAVING COUNT(*) > 1) AS dup;


-- ============================================================================
-- UNIQUE CONSTRAINT VERIFICATION
-- ============================================================================

-- TC-N15: No duplicate email values in CampusUser
-- Expected: 0
SELECT COUNT(*) AS duplicate_emails
FROM (SELECT email FROM CampusUser GROUP BY email HAVING COUNT(*) > 1) AS dup;

-- TC-N16: No duplicate (building, floor, room_number) in CampusSpace
-- Expected: 0
SELECT COUNT(*) AS duplicate_rooms
FROM (SELECT building, floor, room_number FROM CampusSpace GROUP BY building, floor, room_number HAVING COUNT(*) > 1) AS dup;

-- TC-N17: No duplicate facility_name values in CampusFacility
-- Expected: 0
SELECT COUNT(*) AS duplicate_facility_names
FROM (SELECT facility_name FROM CampusFacility GROUP BY facility_name HAVING COUNT(*) > 1) AS dup;

-- TC-N18: No duplicate space_booking_id in BookingApproval (1:1 relationship)
-- Expected: 0
SELECT COUNT(*) AS duplicate_approval_bookings
FROM (SELECT space_booking_id FROM BookingApproval GROUP BY space_booking_id HAVING COUNT(*) > 1) AS dup;

-- TC-N19: No duplicate space_booking_id in SpaceUsageSession (1:1 relationship)
-- Expected: 0
SELECT COUNT(*) AS duplicate_session_bookings
FROM (SELECT space_booking_id FROM SpaceUsageSession GROUP BY space_booking_id HAVING COUNT(*) > 1) AS dup;


-- ============================================================================
-- FOREIGN KEY INTEGRITY (no orphaned references)
-- ============================================================================

-- TC-N20: All SpaceBooking.requester_id reference existing CampusUser records
-- Expected: 0
SELECT COUNT(*) AS orphaned_requester
FROM SpaceBooking
WHERE requester_id NOT IN (SELECT campus_user_id FROM CampusUser);

-- TC-N21: All SpaceBooking.campus_space_code reference existing CampusSpace records
-- Expected: 0
SELECT COUNT(*) AS orphaned_booking_space
FROM SpaceBooking
WHERE campus_space_code NOT IN (SELECT campus_space_code FROM CampusSpace);

-- TC-N22: All BookingApproval.space_booking_id reference existing SpaceBooking records
-- Expected: 0
SELECT COUNT(*) AS orphaned_approval_booking
FROM BookingApproval
WHERE space_booking_id NOT IN (SELECT space_booking_id FROM SpaceBooking);

-- TC-N23: All BookingApproval.staff_id reference existing CampusUser records
-- Expected: 0
SELECT COUNT(*) AS orphaned_approver
FROM BookingApproval
WHERE staff_id NOT IN (SELECT campus_user_id FROM CampusUser);

-- TC-N24: All SpaceUsageSession.space_booking_id reference existing SpaceBooking records
-- Expected: 0
SELECT COUNT(*) AS orphaned_session_booking
FROM SpaceUsageSession
WHERE space_booking_id NOT IN (SELECT space_booking_id FROM SpaceBooking);

-- TC-N25: All SpaceUsageSession.checked_in_by reference existing CampusUser records
-- Expected: 0
SELECT COUNT(*) AS orphaned_checkin_staff
FROM SpaceUsageSession
WHERE checked_in_by NOT IN (SELECT campus_user_id FROM CampusUser);

-- TC-N26: All SpaceMaintenance.campus_space_code reference existing CampusSpace records
-- Expected: 0
SELECT COUNT(*) AS orphaned_maint_space
FROM SpaceMaintenance
WHERE campus_space_code NOT IN (SELECT campus_space_code FROM CampusSpace);

-- TC-N27: All SpaceMaintenance.reporter_id reference existing CampusUser records
-- Expected: 0
SELECT COUNT(*) AS orphaned_reporter
FROM SpaceMaintenance
WHERE reporter_id NOT IN (SELECT campus_user_id FROM CampusUser);

-- TC-N28: All non-null SpaceMaintenance.assigned_staff_id reference existing CampusUser records
-- Expected: 0
SELECT COUNT(*) AS orphaned_assignee
FROM SpaceMaintenance
WHERE assigned_staff_id IS NOT NULL
  AND assigned_staff_id NOT IN (SELECT campus_user_id FROM CampusUser);


-- ============================================================================
-- CHECK CONSTRAINT VERIFICATION (all values are valid)
-- ============================================================================

-- TC-N29: All CampusUser.role values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_roles
FROM CampusUser
WHERE role NOT IN ('student', 'lecturer', 'teaching_assistant', 'facility_staff', 'department_admin', 'facility_manager');

-- TC-N30: All CampusUser.account_status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_account_statuses
FROM CampusUser
WHERE account_status NOT IN ('active', 'inactive', 'suspended');

-- TC-N31: All CampusSpace.space_type values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_space_types
FROM CampusSpace
WHERE space_type NOT IN ('auditorium', 'classroom', 'computer_lab', 'meeting_room');

-- TC-N32: All CampusSpace.current_status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_space_statuses
FROM CampusSpace
WHERE current_status NOT IN ('available', 'in_use', 'under_maintenance', 'temporarily_closed', 'retired');

-- TC-N33: All CampusSpace.capacity values are positive
-- Expected: 0
SELECT COUNT(*) AS non_positive_capacity
FROM CampusSpace
WHERE capacity <= 0;

-- TC-N34: All SpaceBooking.purpose_type values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_purpose_types
FROM SpaceBooking
WHERE purpose_type NOT IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student_activity', 'administrative_event');

-- TC-N35: All SpaceBooking.status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_booking_statuses
FROM SpaceBooking
WHERE status NOT IN ('pending', 'approved', 'rejected', 'cancelled', 'checked_in', 'completed', 'no-show');

-- TC-N36: All SpaceBooking.expected_participants values are positive
-- Expected: 0
SELECT COUNT(*) AS non_positive_participants
FROM SpaceBooking
WHERE expected_participants <= 0;

-- TC-N37: All SpaceBooking time ranges have end > start
-- Expected: 0
SELECT COUNT(*) AS invalid_time_ranges
FROM SpaceBooking
WHERE requested_end_time <= requested_start_time;

-- TC-N38: All BookingApproval.decision values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_decisions
FROM BookingApproval
WHERE decision NOT IN ('approved', 'rejected');

-- TC-N39: All rejected BookingApproval records have a rejection_reason
-- Expected: 0
SELECT COUNT(*) AS missing_rejection_reasons
FROM BookingApproval
WHERE decision = 'rejected' AND rejection_reason IS NULL;

-- TC-N40: All SpaceMaintenance.problem_type values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_problem_types
FROM SpaceMaintenance
WHERE problem_type NOT IN ('broken_projector', 'ac_failure', 'damaged_furniture', 'cleaning', 'network', 'other');

-- TC-N41: All SpaceMaintenance.status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_maint_statuses
FROM SpaceMaintenance
WHERE status NOT IN ('reported', 'in_progress', 'completed', 'cancelled');

-- TC-N42: CampusFacility.status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_facility_statuses
FROM CampusFacility
WHERE status NOT IN ('available', 'in_use', 'under_maintenance');


-- ============================================================================
-- NOT NULL VERIFICATION (required columns have no NULLs)
-- ============================================================================

-- TC-N43: CampusUser.full_name has no NULLs
-- Expected: 0
SELECT COUNT(*) AS null_full_name FROM CampusUser WHERE full_name IS NULL;

-- TC-N44: CampusUser.email has no NULLs
-- Expected: 0
SELECT COUNT(*) AS null_email FROM CampusUser WHERE email IS NULL;

-- TC-N45: CampusUser.role has no NULLs
-- Expected: 0
SELECT COUNT(*) AS null_role FROM CampusUser WHERE role IS NULL;

-- TC-N46: CampusUser.department has no NULLs
-- Expected: 0
SELECT COUNT(*) AS null_department FROM CampusUser WHERE department IS NULL;

-- TC-N47: CampusUser.account_status has no NULLs
-- Expected: 0
SELECT COUNT(*) AS null_account_status FROM CampusUser WHERE account_status IS NULL;


-- ============================================================================
-- BUSINESS LOGIC: STATUS COVERAGE
-- ============================================================================

-- TC-N48: SpaceBooking statuses cover most valid values
-- Expected: 7 rows (if all statuses used)
SELECT status, COUNT(*) AS count
FROM SpaceBooking
GROUP BY status
ORDER BY status;

-- TC-N49: SpaceMaintenance statuses cover all expected values
-- Expected: 4 rows
SELECT status, COUNT(*) AS count
FROM SpaceMaintenance
GROUP BY status
ORDER BY status;

-- TC-N50: BookingApproval decisions cover all expected values
-- Expected: 2 rows (approved, rejected)
SELECT decision, COUNT(*) AS count
FROM BookingApproval
GROUP BY decision
ORDER BY decision;

-- TC-N51: CampusSpace current_status covers multiple statuses
-- Expected: 5 rows
SELECT current_status, COUNT(*) AS count
FROM CampusSpace
GROUP BY current_status
ORDER BY current_status;


-- ============================================================================
-- BUSINESS LOGIC: SPECIFIC SCENARIOS
-- ============================================================================

-- TC-N52: User with inactive account exists
-- Expected: 1
SELECT COUNT(*) AS inactive_users
FROM CampusUser
WHERE account_status = 'inactive';

-- TC-N53: Retired space exists
-- Expected: 1
SELECT COUNT(*) AS retired_spaces
FROM CampusSpace
WHERE current_status = 'retired';

-- TC-N54: Temporarily closed space exists
-- Expected: 1
SELECT COUNT(*) AS closed_spaces
FROM CampusSpace
WHERE current_status = 'temporarily_closed';

-- TC-N55: Under-maintenance space exists (via TRG-04)
-- Expected: 3 (C302) and two space are in reported status
SELECT COUNT(*) AS maintenance_spaces
FROM CampusSpace
WHERE current_status = 'under_maintenance';

-- TC-N56: Completed booking exists
-- Expected: 1
SELECT COUNT(*) AS completed_bookings
FROM SpaceBooking
WHERE status = 'completed';

-- TC-N57: Rejected booking was given a rejection reason
-- Expected: 1
SELECT COUNT(*) AS rejected_with_reason
FROM SpaceBooking sb
JOIN BookingApproval ba ON sb.space_booking_id = ba.space_booking_id
WHERE sb.status = 'rejected' AND ba.rejection_reason IS NOT NULL;
GO


-- ============================================================================
-- TRIGGER VERIFICATION (normal/valid operations must succeed)
-- ============================================================================

-- -----------------------------------------------------------------------
-- TRG-01: Non-overlapping bookings can both be approved
-- -----------------------------------------------------------------------
-- TC-N58: Approve two non-overlapping bookings for the same space
-- Expected: Both become 'approved'
SET IDENTITY_INSERT SpaceBooking ON;
INSERT INTO SpaceBooking (space_booking_id, requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, submitted_at)
VALUES (200, 4, 'D401', '2026-08-10 08:00:00', '2026-08-10 10:00:00', 'meeting', 10, 'pending', GETDATE());
SET IDENTITY_INSERT SpaceBooking OFF;
GO
INSERT INTO SpaceBooking (requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, submitted_at)
VALUES (4, 'D401', '2026-08-10 14:00:00', '2026-08-10 16:00:00', 'meeting', 10, 'pending', GETDATE());
GO
-- Approve both (non-overlapping times -> TRG-01 passes)
UPDATE SpaceBooking SET status = 'approved' WHERE space_booking_id = 200;
GO
UPDATE SpaceBooking SET status = 'approved' WHERE space_booking_id = (SELECT MAX(space_booking_id) FROM SpaceBooking);
GO
SELECT COUNT(*) AS tc_n58_approved_both
FROM SpaceBooking
WHERE campus_space_code = 'D401'
  AND status = 'approved'
  AND requested_start_time >= '2026-08-10';
-- Clean up
DELETE FROM SpaceBooking WHERE space_booking_id >= 200;
GO


-- -----------------------------------------------------------------------
-- TRG-01 v2: Overlap prevention still allows non-overlapping on same day
-- -----------------------------------------------------------------------
-- TC-N59: New booking on different space cannot conflict with other space
-- Expected: 1 (inserted successfully)
SET IDENTITY_INSERT SpaceBooking ON;
INSERT INTO SpaceBooking (space_booking_id, requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, submitted_at)
VALUES (210, 4, 'B201', '2026-08-20 08:00:00', '2026-08-20 10:00:00', 'lecture', 30, 'pending', GETDATE());
SET IDENTITY_INSERT SpaceBooking OFF;
GO
UPDATE SpaceBooking SET status = 'approved' WHERE space_booking_id = 210;
GO
SELECT COUNT(*) AS tc_n59_approved_other
FROM SpaceBooking WHERE space_booking_id = 210 AND status = 'approved';
GO
DELETE FROM SpaceBooking WHERE space_booking_id = 210;
GO


-- -----------------------------------------------------------------------
-- TRG-02: Valid status transitions (sample data already exercises these)
-- -----------------------------------------------------------------------
-- TC-N60: Pending booking exists
-- Expected: >= 1
SELECT COUNT(*) AS tc_n60_pending_bookings
FROM SpaceBooking WHERE status = 'pending';
GO

-- TC-N61: Approved booking exists (transitioned from pending)
-- Expected: >= 1
SELECT COUNT(*) AS tc_n61_approved_bookings
FROM SpaceBooking WHERE status = 'approved';
GO

-- TC-N62: Checked-in booking exists (transitioned from approved)
-- Expected: >= 1
SELECT COUNT(*) AS tc_n62_checked_in_bookings
FROM SpaceBooking WHERE status = 'checked_in';
GO

-- TC-N63: Completed booking exists (transitioned from checked_in)
-- Expected: >= 1
SELECT COUNT(*) AS tc_n63_completed_bookings
FROM SpaceBooking WHERE status = 'completed';
GO

-- TC-N64: No-show booking exists (transitioned from checked_in)
-- Expected: >= 1
SELECT COUNT(*) AS tc_n64_noshow_bookings
FROM SpaceBooking WHERE status = 'no-show';
GO

-- TC-N65: Rejected booking exists (transitioned from pending)
-- Expected: >= 1
SELECT COUNT(*) AS tc_n65_rejected_bookings
FROM SpaceBooking WHERE status = 'rejected';
GO

-- TC-N66: Cancelled booking exists (transitioned from pending)
-- Expected: >= 1
SELECT COUNT(*) AS tc_n66_cancelled_bookings
FROM SpaceBooking WHERE status = 'cancelled';
GO


-- -----------------------------------------------------------------------
-- TRG-03: Capacity check accepts valid bookings
-- -----------------------------------------------------------------------
-- TC-N67: Booking with participants within capacity succeeds
-- Expected: 1
SET IDENTITY_INSERT SpaceBooking ON;
INSERT INTO SpaceBooking (space_booking_id, requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, submitted_at)
VALUES (220, 4, 'D401', '2026-09-01 08:00:00', '2026-09-01 10:00:00', 'meeting', 18, 'pending', GETDATE());
SET IDENTITY_INSERT SpaceBooking OFF;
GO
SELECT COUNT(*) AS tc_n67_within_capacity
FROM SpaceBooking WHERE space_booking_id = 220;
GO
DELETE FROM SpaceBooking WHERE space_booking_id = 220;
GO


-- -----------------------------------------------------------------------
-- TRG-04: Maintenance status -> CampusSpace.current_status
-- -----------------------------------------------------------------------
-- TC-N68: Insert reported maintenance -> space becomes 'under_maintenance'
-- Expected: 'under_maintenance'
SET IDENTITY_INSERT SpaceMaintenance ON;
INSERT INTO SpaceMaintenance (space_maintenance_id, campus_space_code, reporter_id, problem_description, problem_type, start_time, status)
VALUES (100, 'B201', 4, N'Test TRG-04: reported maintenance.', 'other', GETDATE(), 'reported');
SET IDENTITY_INSERT SpaceMaintenance OFF;
GO
SELECT current_status AS tc_n68_under_maint
FROM CampusSpace WHERE campus_space_code = 'B201';
GO

-- TC-N69: Complete maintenance -> space returns to 'available'
-- Expected: 'available'
UPDATE SpaceMaintenance SET status = 'completed', completion_time = GETDATE() WHERE space_maintenance_id = 100;
GO
SELECT current_status AS tc_n69_back_available
FROM CampusSpace WHERE campus_space_code = 'B201';
GO

-- Clean up
DELETE FROM SpaceMaintenance WHERE space_maintenance_id = 100;
GO
