-- ============================================================
-- Step 6: Normal Test Cases — CS486 Shared Space Booking System
-- DBMS: Microsoft SQL Server
-- Execute after: 06-sample-data-G02.sql
-- All test cases must PASS (return expected result)
-- ============================================================

USE SpaceBookingDB;

-- ============================================================
-- Record Count Verification
-- ============================================================

-- TC-N01: Verify User record count
-- Expected: 10
SELECT COUNT(*) AS user_count FROM User;

-- TC-N02: Verify Space record count
-- Expected: 10
SELECT COUNT(*) AS space_count FROM Space;

-- TC-N03: Verify Facility record count
-- Expected: 8
SELECT COUNT(*) AS facility_count FROM Facility;

-- TC-N04: Verify SpaceFacility record count
-- Expected: 25
SELECT COUNT(*) AS space_facility_count FROM SpaceFacility;

-- TC-N05: Verify BookingRequest record count
-- Expected: 8
SELECT COUNT(*) AS booking_count FROM BookingRequest;

-- TC-N06: Verify MaintenanceRecord record count
-- Expected: 6
SELECT COUNT(*) AS maintenance_count FROM MaintenanceRecord;

-- ============================================================
-- PK Uniqueness
-- ============================================================

-- TC-N07: No duplicate user_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_users
FROM (
    SELECT user_id FROM User
    GROUP BY user_id
    HAVING COUNT(*) > 1
) AS dup;

-- TC-N08: No duplicate space_code values
-- Expected: 0
SELECT COUNT(*) AS duplicate_spaces
FROM (
    SELECT space_code FROM Space
    GROUP BY space_code
    HAVING COUNT(*) > 1
) AS dup;

-- TC-N09: No duplicate booking_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_bookings
FROM (
    SELECT booking_id FROM BookingRequest
    GROUP BY booking_id
    HAVING COUNT(*) > 1
) AS dup;

-- TC-N10: No duplicate maintenance_id values
-- Expected: 0
SELECT COUNT(*) AS duplicate_maintenance
FROM (
    SELECT maintenance_id FROM MaintenanceRecord
    GROUP BY maintenance_id
    HAVING COUNT(*) > 1
) AS dup;

-- ============================================================
-- UNIQUE Constraint Verification
-- ============================================================

-- TC-N11: No duplicate email values in User
-- Expected: 0
SELECT COUNT(*) AS duplicate_emails
FROM (
    SELECT email FROM User
    GROUP BY email
    HAVING COUNT(*) > 1
) AS dup;

-- TC-N12: No duplicate space_name values in Space
-- Expected: 0
SELECT COUNT(*) AS duplicate_space_names
FROM (
    SELECT space_name FROM Space
    GROUP BY space_name
    HAVING COUNT(*) > 1
) AS dup;

-- ============================================================
-- FK Integrity Verification (no orphaned references)
-- ============================================================

-- TC-N13: All BookingRequest.requester_id reference existing User records
-- Expected: 0
SELECT COUNT(*) AS orphaned_requester
FROM BookingRequest
WHERE requester_id NOT IN (SELECT user_id FROM User);

-- TC-N14: All BookingRequest.space_code reference existing Space records
-- Expected: 0
SELECT COUNT(*) AS orphaned_booking_space
FROM BookingRequest
WHERE space_code NOT IN (SELECT space_code FROM Space);

-- TC-N15: All BookingRequest.approved_by reference existing User records (when not NULL)
-- Expected: 0
SELECT COUNT(*) AS orphaned_approver
FROM BookingRequest
WHERE approved_by IS NOT NULL
  AND approved_by NOT IN (SELECT user_id FROM User);

-- TC-N16: All BookingRequest.checked_in_by reference existing User records (when not NULL)
-- Expected: 0
SELECT COUNT(*) AS orphaned_checkin
FROM BookingRequest
WHERE checked_in_by IS NOT NULL
  AND checked_in_by NOT IN (SELECT user_id FROM User);

-- TC-N17: All BookingRequest.completed_by reference existing User records (when not NULL)
-- Expected: 0
SELECT COUNT(*) AS orphaned_completer
FROM BookingRequest
WHERE completed_by IS NOT NULL
  AND completed_by NOT IN (SELECT user_id FROM User);

-- TC-N18: All SpaceFacility.space_code reference existing Space records
-- Expected: 0
SELECT COUNT(*) AS orphaned_sf_space
FROM SpaceFacility
WHERE space_code NOT IN (SELECT space_code FROM Space);

-- TC-N19: All SpaceFacility.facility_id reference existing Facility records
-- Expected: 0
SELECT COUNT(*) AS orphaned_sf_facility
FROM SpaceFacility
WHERE facility_id NOT IN (SELECT facility_id FROM Facility);

-- TC-N20: All MaintenanceRecord.space_code reference existing Space records
-- Expected: 0
SELECT COUNT(*) AS orphaned_mt_space
FROM MaintenanceRecord
WHERE space_code NOT IN (SELECT space_code FROM Space);

-- TC-N21: All MaintenanceRecord.reported_by reference existing User records
-- Expected: 0
SELECT COUNT(*) AS orphaned_reporter
FROM MaintenanceRecord
WHERE reported_by NOT IN (SELECT user_id FROM User);

-- TC-N22: All MaintenanceRecord.assigned_to reference existing User records (when not NULL)
-- Expected: 0
SELECT COUNT(*) AS orphaned_assignee
FROM MaintenanceRecord
WHERE assigned_to IS NOT NULL
  AND assigned_to NOT IN (SELECT user_id FROM User);

-- ============================================================
-- CHECK Constraint Verification (all values are valid)
-- ============================================================

-- TC-N23: All User.role values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_roles
FROM User
WHERE role NOT IN ('student', 'lecturer', 'teaching_assistant', 'facility_staff', 'department_administrator', 'facility_manager');

-- TC-N24: All User.account_status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_account_statuses
FROM User
WHERE account_status NOT IN ('active', 'inactive', 'suspended');

-- TC-N25: All Space.space_type values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_space_types
FROM Space
WHERE space_type NOT IN ('auditorium', 'classroom', 'computer_laboratory', 'project_laboratory', 'meeting_room', 'student_workspace');

-- TC-N26: All Space.current_status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_space_statuses
FROM Space
WHERE current_status NOT IN ('available', 'in_use', 'under_maintenance', 'temporarily_closed', 'retired');

-- TC-N27: All BookingRequest.booking_type values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_booking_types
FROM BookingRequest
WHERE booking_type NOT IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student_activity', 'administrative_event');

-- TC-N28: All BookingRequest.booking_status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_booking_statuses
FROM BookingRequest
WHERE booking_status NOT IN ('pending', 'approved', 'rejected', 'cancelled', 'checked_in', 'completed', 'no_show');

-- TC-N29: All MaintenanceRecord.status values are valid
-- Expected: 0
SELECT COUNT(*) AS invalid_maintenance_statuses
FROM MaintenanceRecord
WHERE status NOT IN ('reported', 'assigned', 'in_progress', 'completed', 'cancelled');

-- ============================================================
-- Business Logic: Status Coverage
-- ============================================================

-- TC-N30: Booking statuses cover all expected values
-- Expected: at least 1 row per status (7 rows)
SELECT booking_status, COUNT(*) AS count
FROM BookingRequest
GROUP BY booking_status;
