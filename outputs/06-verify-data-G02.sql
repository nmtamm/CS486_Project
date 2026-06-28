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

-- TC-N04: Verify CampusSpaceFacility record count
-- Expected: 12
SELECT COUNT(*) AS space_facility_count FROM CampusSpaceFacility;

-- TC-N05: Verify SpaceBooking record count
-- Expected: 8
SELECT COUNT(*) AS booking_count FROM SpaceBooking;

-- TC-N06: Verify BookingApproval record count
-- Expected: 5
SELECT COUNT(*) AS approval_count FROM BookingApproval;

-- TC-N07: Verify SpaceUsageSession record count
-- Expected: 4
SELECT COUNT(*) AS session_count FROM SpaceUsageSession;

-- TC-N08: Verify SpaceMaintenance record count
-- Expected: 6
SELECT COUNT(*) AS maintenance_count FROM SpaceMaintenance;


-- ============================================================================
-- PRIMARY KEY UNIQUENESS
-- ============================================================================

-- TC-N09: No duplicate campus_user_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_users
FROM (SELECT campus_user_id FROM CampusUser GROUP BY campus_user_id HAVING COUNT(*) > 1) AS dup;

-- TC-N10: No duplicate campus_space_code values
-- Expected: 0
SELECT COUNT(*) AS duplicate_spaces
FROM (SELECT campus_space_code FROM CampusSpace GROUP BY campus_space_code HAVING COUNT(*) > 1) AS dup;

-- TC-N11: No duplicate campus_facility_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_facilities
FROM (SELECT campus_facility_id FROM CampusFacility GROUP BY campus_facility_id HAVING COUNT(*) > 1) AS dup;

-- TC-N12: No duplicate campus_space_facility_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_space_facilities
FROM (SELECT campus_space_facility_id FROM CampusSpaceFacility GROUP BY campus_space_facility_id HAVING COUNT(*) > 1) AS dup;

-- TC-N13: No duplicate space_booking_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_bookings
FROM (SELECT space_booking_id FROM SpaceBooking GROUP BY space_booking_id HAVING COUNT(*) > 1) AS dup;

-- TC-N14: No duplicate booking_approval_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_approvals
FROM (SELECT booking_approval_id FROM BookingApproval GROUP BY booking_approval_id HAVING COUNT(*) > 1) AS dup;

-- TC-N15: No duplicate space_usage_session_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_sessions
FROM (SELECT space_usage_session_id FROM SpaceUsageSession GROUP BY space_usage_session_id HAVING COUNT(*) > 1) AS dup;

-- TC-N16: No duplicate space_maintenance_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_maintenance
FROM (SELECT space_maintenance_id FROM SpaceMaintenance GROUP BY space_maintenance_id HAVING COUNT(*) > 1) AS dup;


-- ============================================================================
-- UNIQUE CONSTRAINT VERIFICATION
-- ============================================================================

-- TC-N17: No duplicate email values in CampusUser
-- Expected: 0
SELECT COUNT(*) AS duplicate_emails
FROM (SELECT email FROM CampusUser GROUP BY email HAVING COUNT(*) > 1) AS dup;

-- TC-N18: No duplicate (building, floor, room_number) in CampusSpace
-- Expected: 0
SELECT COUNT(*) AS duplicate_rooms
FROM (SELECT building, floor, room_number FROM CampusSpace GROUP BY building, floor, room_number HAVING COUNT(*) > 1) AS dup;

-- TC-N19: No duplicate facility_name values in CampusFacility
-- Expected: 0
SELECT COUNT(*) AS duplicate_facility_names
FROM (SELECT facility_name FROM CampusFacility GROUP BY facility_name HAVING COUNT(*) > 1) AS dup;

-- TC-N20: No duplicate (campus_space_code, campus_facility_id) in CampusSpaceFacility
-- Expected: 0
SELECT COUNT(*) AS duplicate_space_facility_combos
FROM (SELECT campus_space_code, campus_facility_id FROM CampusSpaceFacility GROUP BY campus_space_code, campus_facility_id HAVING COUNT(*) > 1) AS dup;

-- TC-N21: No duplicate space_booking_id in BookingApproval (1:1 relationship)
-- Expected: 0
SELECT COUNT(*) AS duplicate_approval_bookings
FROM (SELECT space_booking_id FROM BookingApproval GROUP BY space_booking_id HAVING COUNT(*) > 1) AS dup;

-- TC-N22: No duplicate space_booking_id in SpaceUsageSession (1:1 relationship)
-- Expected: 0
SELECT COUNT(*) AS duplicate_session_bookings
FROM (SELECT space_booking_id FROM SpaceUsageSession GROUP BY space_booking_id HAVING COUNT(*) > 1) AS dup;


-- ============================================================================
-- FOREIGN KEY INTEGRITY (no orphaned references)
-- ============================================================================

-- TC-N23: All SpaceBooking.requester_id reference existing CampusUser records
-- Expected: 0
SELECT COUNT(*) AS orphaned_requester
FROM SpaceBooking
WHERE requester_id NOT IN (SELECT campus_user_id FROM CampusUser);

-- TC-N24: All SpaceBooking.campus_space_code reference existing CampusSpace records
-- Expected: 0
SELECT COUNT(*) AS orphaned_booking_space
FROM SpaceBooking
WHERE campus_space_code NOT IN (SELECT campus_space_code FROM CampusSpace);

-- TC-N25: All CampusSpaceFacility.campus_space_code reference existing CampusSpace records
-- Expected: 0
SELECT COUNT(*) AS orphaned_csf_space
FROM CampusSpaceFacility
WHERE campus_space_code NOT IN (SELECT campus_space_code FROM CampusSpace);

-- TC-N26: All CampusSpaceFacility.campus_facility_id reference existing CampusFacility records
-- Expected: 0
SELECT COUNT(*) AS orphaned_csf_facility
FROM CampusSpaceFacility
WHERE campus_facility_id NOT IN (SELECT campus_facility_id FROM CampusFacility);

-- TC-N27: All BookingApproval.space_booking_id reference existing SpaceBooking records
-- Expected: 0
SELECT COUNT(*) AS orphaned_approval_booking
FROM BookingApproval
WHERE space_booking_id NOT IN (SELECT space_booking_id FROM SpaceBooking);

-- TC-N28: All BookingApproval.staff_id reference existing CampusUser records
-- Expected: 0
SELECT COUNT(*) AS orphaned_approver
FROM BookingApproval
WHERE staff_id NOT IN (SELECT campus_user_id FROM CampusUser);

-- TC-N29: All SpaceUsageSession.space_booking_id reference existing SpaceBooking records
-- Expected: 0
SELECT COUNT(*) AS orphaned_session_booking
FROM SpaceUsageSession
WHERE space_booking_id NOT IN (SELECT space_booking_id FROM SpaceBooking);

-- TC-N30: All SpaceUsageSession.checked_in_by reference existing CampusUser records
-- Expected: 0
SELECT COUNT(*) AS orphaned_checkin_staff
FROM SpaceUsageSession
WHERE checked_in_by NOT IN (SELECT campus_user_id FROM CampusUser);

-- TC-N31: All SpaceMaintenance.campus_space_code reference existing CampusSpace records
-- Expected: 0
SELECT COUNT(*) AS orphaned_maint_space
FROM SpaceMaintenance
WHERE campus_space_code NOT IN (SELECT campus_space_code FROM CampusSpace);

-- TC-N32: All SpaceMaintenance.reporter_id reference existing CampusUser records
-- Expected: 0
SELECT COUNT(*) AS orphaned_reporter
FROM SpaceMaintenance
WHERE reporter_id NOT IN (SELECT campus_user_id FROM CampusUser);

-- TC-N33: All non-null SpaceMaintenance.assigned_staff_id reference existing CampusUser records
-- Expected: 0
SELECT COUNT(*) AS orphaned_assignee
FROM SpaceMaintenance
WHERE assigned_staff_id IS NOT NULL
  AND assigned_staff_id NOT IN (SELECT campus_user_id FROM CampusUser);


-- ============================================================================
-- CHECK CONSTRAINT VERIFICATION (all values are valid)
-- ============================================================================

-- TC-N34: All CampusUser.role values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_roles
FROM CampusUser
WHERE role NOT IN ('student', 'lecturer', 'teaching_assistant', 'facility_staff', 'department_admin', 'facility_manager');

-- TC-N35: All CampusUser.account_status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_account_statuses
FROM CampusUser
WHERE account_status NOT IN ('active', 'inactive', 'suspended');

-- TC-N36: All CampusSpace.space_type values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_space_types
FROM CampusSpace
WHERE space_type NOT IN ('auditorium', 'classroom', 'computer_lab', 'meeting_room');

-- TC-N37: All CampusSpace.current_status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_space_statuses
FROM CampusSpace
WHERE current_status NOT IN ('available', 'in_use', 'under_maintenance', 'temporarily_closed', 'retired');

-- TC-N38: All CampusSpace.capacity values are positive
-- Expected: 0
SELECT COUNT(*) AS non_positive_capacity
FROM CampusSpace
WHERE capacity <= 0;

-- TC-N39: All SpaceBooking.purpose_type values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_purpose_types
FROM SpaceBooking
WHERE purpose_type NOT IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student_activity', 'administrative_event');

-- TC-N40: All SpaceBooking.status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_booking_statuses
FROM SpaceBooking
WHERE status NOT IN ('pending', 'approved', 'rejected', 'cancelled', 'checked_in', 'completed', 'no-show');

-- TC-N41: All SpaceBooking.expected_participants values are positive
-- Expected: 0
SELECT COUNT(*) AS non_positive_participants
FROM SpaceBooking
WHERE expected_participants <= 0;

-- TC-N42: All SpaceBooking time ranges have end > start
-- Expected: 0
SELECT COUNT(*) AS invalid_time_ranges
FROM SpaceBooking
WHERE requested_end_time <= requested_start_time;

-- TC-N43: All BookingApproval.decision values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_decisions
FROM BookingApproval
WHERE decision NOT IN ('approved', 'rejected');

-- TC-N44: All rejected BookingApproval records have a rejection_reason
-- Expected: 0
SELECT COUNT(*) AS missing_rejection_reasons
FROM BookingApproval
WHERE decision = 'rejected' AND rejection_reason IS NULL;

-- TC-N45: All CampusSpaceFacility.quantity values are positive
-- Expected: 0
SELECT COUNT(*) AS non_positive_quantities
FROM CampusSpaceFacility
WHERE quantity <= 0;

-- TC-N46: All SpaceMaintenance.problem_type values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_problem_types
FROM SpaceMaintenance
WHERE problem_type NOT IN ('broken_projector', 'ac_failure', 'damaged_furniture', 'cleaning', 'network', 'other');

-- TC-N47: All SpaceMaintenance.status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_maint_statuses
FROM SpaceMaintenance
WHERE status NOT IN ('reported', 'in_progress', 'completed', 'cancelled');


-- ============================================================================
-- NOT NULL VERIFICATION (required columns have no NULLs)
-- ============================================================================

-- TC-N48: CampusUser.full_name has no NULLs
-- Expected: 0
SELECT COUNT(*) AS null_full_name FROM CampusUser WHERE full_name IS NULL;

-- TC-N49: CampusUser.email has no NULLs
-- Expected: 0
SELECT COUNT(*) AS null_email FROM CampusUser WHERE email IS NULL;

-- TC-N50: CampusUser.role has no NULLs
-- Expected: 0
SELECT COUNT(*) AS null_role FROM CampusUser WHERE role IS NULL;

-- TC-N51: CampusUser.department has no NULLs
-- Expected: 0
SELECT COUNT(*) AS null_department FROM CampusUser WHERE department IS NULL;

-- TC-N52: CampusUser.account_status has no NULLs
-- Expected: 0
SELECT COUNT(*) AS null_account_status FROM CampusUser WHERE account_status IS NULL;


-- ============================================================================
-- BUSINESS LOGIC: STATUS COVERAGE
-- ============================================================================

-- TC-N53: SpaceBooking statuses cover all expected values
-- Expected: 7 rows (one per status)
SELECT status, COUNT(*) AS count
FROM SpaceBooking
GROUP BY status
ORDER BY status;

-- TC-N54: SpaceMaintenance statuses cover all expected values
-- Expected: 4 rows (one per status)
SELECT status, COUNT(*) AS count
FROM SpaceMaintenance
GROUP BY status
ORDER BY status;

-- TC-N55: BookingApproval decisions cover all expected values
-- Expected: 2 rows (approved, rejected)
SELECT decision, COUNT(*) AS count
FROM BookingApproval
GROUP BY decision
ORDER BY decision;

-- TC-N56: CampusSpace current_status covers multiple statuses
-- Expected: 5 rows
SELECT current_status, COUNT(*) AS count
FROM CampusSpace
GROUP BY current_status
ORDER BY current_status;


-- ============================================================================
-- BUSINESS LOGIC: SPECIFIC SCENARIOS
-- ============================================================================

-- TC-N57: User with inactive account exists
-- Expected: 1
SELECT COUNT(*) AS inactive_users
FROM CampusUser
WHERE account_status = 'inactive';

-- TC-N58: Space under maintenance exists
-- Expected: 1
SELECT COUNT(*) AS maintenance_spaces
FROM CampusSpace
WHERE current_status = 'under_maintenance';

-- TC-N59: Retired space exists
-- Expected: 1
SELECT COUNT(*) AS retired_spaces
FROM CampusSpace
WHERE current_status = 'retired';

-- TC-N60: Temporarily closed space exists
-- Expected: 1
SELECT COUNT(*) AS closed_spaces
FROM CampusSpace
WHERE current_status = 'temporarily_closed';
GO
