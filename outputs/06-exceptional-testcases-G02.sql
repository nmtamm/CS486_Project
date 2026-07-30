-- ============================================================================
-- Step 6 — Exceptional Test Cases: School of Computer Science Space Booking
-- Group: G02
-- DBMS:  Microsoft SQL Server
-- Execute after: 06-sample-data-G02.sql (but BEFORE 06-verify-data-G02.sql
--   to avoid cleaning up records that normal tests may depend on)
-- All test cases must FAIL with a constraint violation error
-- ============================================================================

USE SpaceBookingDB;
GO


-- ============================================================================
-- PRIMARY KEY VIOLATIONS
-- ============================================================================

-- TC-01: Duplicate CampusUser.campus_user_id
-- Expected Result: PRIMARY KEY violation
SET IDENTITY_INSERT CampusUser ON;
INSERT INTO CampusUser (campus_user_id, full_name, email, phone, role, department, account_status)
VALUES (1, N'Fake User', 'fake.user@university.edu.vn', '0999999999', 'student', N'CS', 'active');
SET IDENTITY_INSERT CampusUser OFF;
GO

-- TC-02: Duplicate CampusSpace.campus_space_code
-- Expected Result: PRIMARY KEY violation
INSERT INTO CampusSpace (campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status)
VALUES ('A101', N'Fake Space', 'classroom', N'Building X', 9, '999', 50, 'available');
GO

-- TC-03: Duplicate CampusFacility.campus_facility_id
-- Expected Result: PRIMARY KEY violation
SET IDENTITY_INSERT CampusFacility ON;
INSERT INTO CampusFacility (campus_facility_id, facility_name, description)
VALUES (1, N'Fake Facility', N'Fake description');
SET IDENTITY_INSERT CampusFacility OFF;
GO

-- TC-04: Duplicate SpaceBooking.space_booking_id
-- Expected Result: PRIMARY KEY violation
SET IDENTITY_INSERT SpaceBooking ON;
INSERT INTO SpaceBooking (space_booking_id, requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, submitted_at)
VALUES (1, 4, 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00', 'meeting', 10, 'pending', GETDATE());
SET IDENTITY_INSERT SpaceBooking OFF;
GO

-- TC-05: Duplicate BookingApproval.booking_approval_id
-- Expected Result: PRIMARY KEY violation
SET IDENTITY_INSERT BookingApproval ON;
INSERT INTO BookingApproval (booking_approval_id, space_booking_id, staff_id, decision, decision_time)
VALUES (1, 2, 1, 'approved', GETDATE());
SET IDENTITY_INSERT BookingApproval OFF;
GO

-- TC-06: Duplicate SpaceUsageSession.space_usage_session_id
-- Expected Result: PRIMARY KEY violation
SET IDENTITY_INSERT SpaceUsageSession ON;
INSERT INTO SpaceUsageSession (space_usage_session_id, space_booking_id, checked_in_by, actual_start_time)
VALUES (1, 2, 2, GETDATE());
SET IDENTITY_INSERT SpaceUsageSession OFF;
GO

-- TC-07: Duplicate SpaceMaintenance.space_maintenance_id
-- Expected Result: PRIMARY KEY violation
SET IDENTITY_INSERT SpaceMaintenance ON;
INSERT INTO SpaceMaintenance (space_maintenance_id, campus_space_code, reporter_id, problem_description, problem_type, start_time, status)
VALUES (1, 'A101', 4, N'Fake problem', 'other', GETDATE(), 'reported');
SET IDENTITY_INSERT SpaceMaintenance OFF;
GO


-- ============================================================================
-- UNIQUE CONSTRAINT VIOLATIONS
-- ============================================================================

-- TC-08: Duplicate CampusUser.email
-- Expected Result: UNIQUE constraint violation
INSERT INTO CampusUser (full_name, email, phone, role, department, account_status)
VALUES (N'Duplicate Email', 'an.nguyenvan@university.edu.vn', '0999999998', 'student', N'CS', 'active');
GO

-- TC-09: Duplicate CampusFacility.facility_name
-- Expected Result: UNIQUE constraint violation
INSERT INTO CampusFacility (facility_name, description)
VALUES (N'Projector', N'Duplicate projector entry');
GO

-- TC-10: Duplicate (building, floor, room_number) in CampusSpace
-- Expected Result: UNIQUE constraint violation
INSERT INTO CampusSpace (campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status)
VALUES ('ZZZZZ', N'Duplicate Room', 'classroom', N'Building A', 1, '101', 50, 'available');
GO

-- TC-11: Duplicate space_booking_id in BookingApproval (1:1 constraint)
-- Expected Result: UNIQUE constraint violation
INSERT INTO BookingApproval (space_booking_id, staff_id, decision, decision_time)
VALUES (1, 1, 'approved', GETDATE());
GO

-- TC-12: Duplicate space_booking_id in SpaceUsageSession (1:1 constraint)
-- Expected Result: UNIQUE constraint violation
INSERT INTO SpaceUsageSession (space_booking_id, checked_in_by, actual_start_time)
VALUES (1, 2, GETDATE());
GO


-- ============================================================================
-- FOREIGN KEY VIOLATIONS
-- ============================================================================

-- TC-13: SpaceBooking with non-existent requester_id
-- Expected Result: FOREIGN KEY violation
INSERT INTO SpaceBooking (requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status)
VALUES (999, 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00', 'lecture', 10, 'pending');
GO

-- TC-14: SpaceBooking with non-existent campus_space_code
-- Expected Result: FOREIGN KEY violation
INSERT INTO SpaceBooking (requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status)
VALUES (4, 'ZZZZZ', '2026-07-01 08:00:00', '2026-07-01 10:00:00', 'lecture', 10, 'pending');
GO

-- TC-15: BookingApproval with non-existent space_booking_id
-- Expected Result: FOREIGN KEY violation
INSERT INTO BookingApproval (space_booking_id, staff_id, decision, decision_time)
VALUES (999, 1, 'approved', GETDATE());
GO

-- TC-16: BookingApproval with non-existent staff_id
-- Expected Result: FOREIGN KEY violation
INSERT INTO BookingApproval (space_booking_id, staff_id, decision, decision_time)
VALUES (2, 999, 'approved', GETDATE());
GO

-- TC-17: SpaceUsageSession with non-existent space_booking_id
-- Expected Result: FOREIGN KEY violation
INSERT INTO SpaceUsageSession (space_booking_id, checked_in_by, actual_start_time)
VALUES (999, 2, GETDATE());
GO

-- TC-18: SpaceUsageSession with non-existent checked_in_by
-- Expected Result: FOREIGN KEY violation
INSERT INTO SpaceUsageSession (space_booking_id, checked_in_by, actual_start_time)
VALUES (2, 999, GETDATE());
GO

-- TC-19: SpaceMaintenance with non-existent campus_space_code
-- Expected Result: FOREIGN KEY violation
INSERT INTO SpaceMaintenance (campus_space_code, reporter_id, problem_description, problem_type, start_time, status)
VALUES ('ZZZZZ', 4, N'Test', 'other', GETDATE(), 'reported');
GO

-- TC-20: SpaceMaintenance with non-existent reporter_id
-- Expected Result: FOREIGN KEY violation
INSERT INTO SpaceMaintenance (campus_space_code, reporter_id, problem_description, problem_type, start_time, status)
VALUES ('A101', 999, N'Test', 'other', GETDATE(), 'reported');
GO

-- TC-21: SpaceMaintenance with non-existent assigned_staff_id
-- Expected Result: FOREIGN KEY violation
INSERT INTO SpaceMaintenance (campus_space_code, reporter_id, assigned_staff_id, problem_description, problem_type, start_time, status)
VALUES ('A101', 4, 999, N'Test', 'other', GETDATE(), 'reported');
GO


-- ============================================================================
-- CHECK CONSTRAINT VIOLATIONS
-- ============================================================================

-- TC-22: CampusUser.role with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO CampusUser (full_name, email, phone, role, department, account_status)
VALUES (N'Bad Role', 'bad.role@university.edu.vn', NULL, 'admin', N'CS', 'active');
GO

-- TC-23: CampusUser.account_status with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO CampusUser (full_name, email, phone, role, department, account_status)
VALUES (N'Bad Status', 'bad.status@university.edu.vn', NULL, 'student', N'CS', 'locked');
GO

-- TC-24: CampusSpace.space_type with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO CampusSpace (campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status)
VALUES ('ZZ001', N'Invalid Type', 'gymnasium', N'Building Z', 1, '001', 100, 'available');
GO

-- TC-25: CampusSpace.current_status with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO CampusSpace (campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status)
VALUES ('ZZ002', N'Invalid Status', 'classroom', N'Building Z', 1, '002', 100, 'demolished');
GO

-- TC-26: CampusSpace.capacity with non-positive value
-- Expected Result: CHECK constraint violation
INSERT INTO CampusSpace (campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status)
VALUES ('ZZ003', N'Zero Capacity', 'classroom', N'Building Z', 1, '003', 0, 'available');
GO

-- TC-27: SpaceBooking.purpose_type with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO SpaceBooking (requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status)
VALUES (4, 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00', 'party', 10, 'pending');
GO

-- TC-28: SpaceBooking.status with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO SpaceBooking (requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status)
VALUES (4, 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00', 'lecture', 10, 'unknown');
GO

-- TC-29: SpaceBooking.expected_participants with non-positive value
-- Expected Result: CHECK constraint violation
INSERT INTO SpaceBooking (requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status)
VALUES (4, 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00', 'lecture', 0, 'pending');
GO

-- TC-30: SpaceBooking with end_time <= start_time
-- Expected Result: CHECK constraint violation
INSERT INTO SpaceBooking (requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status)
VALUES (4, 'A101', '2026-07-01 10:00:00', '2026-07-01 08:00:00', 'lecture', 10, 'pending');
GO

-- TC-31: BookingApproval.decision with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO BookingApproval (space_booking_id, staff_id, decision, decision_time)
VALUES (2, 1, 'maybe', GETDATE());
GO

-- TC-32: BookingApproval rejected without rejection_reason
-- Expected Result: CHECK constraint violation
INSERT INTO BookingApproval (space_booking_id, staff_id, decision, decision_time)
VALUES (2, 1, 'rejected', GETDATE());
GO

-- TC-33: SpaceMaintenance.problem_type with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO SpaceMaintenance (campus_space_code, reporter_id, problem_description, problem_type, start_time, status)
VALUES ('A101', 4, N'Test', 'flood', GETDATE(), 'reported');
GO

-- TC-34: SpaceMaintenance.status with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO SpaceMaintenance (campus_space_code, reporter_id, problem_description, problem_type, start_time, status)
VALUES ('A101', 4, N'Test', 'other', GETDATE(), 'archived');
GO

-- TC-35: CampusFacility.status with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO CampusFacility (facility_name, description, status)
VALUES (N'Invalid Facility', N'Test', 'destroyed');
GO


-- ============================================================================
-- NOT NULL VIOLATIONS
-- ============================================================================

-- TC-36: CampusUser.full_name cannot be NULL
-- Expected Result: NOT NULL violation
INSERT INTO CampusUser (full_name, email, phone, role, department, account_status)
VALUES (NULL, 'noname@university.edu.vn', NULL, 'student', N'CS', 'active');
GO

-- TC-37: CampusUser.role cannot be NULL
-- Expected Result: NOT NULL violation
INSERT INTO CampusUser (full_name, email, phone, role, department, account_status)
VALUES (N'No Role', 'norole@university.edu.vn', NULL, NULL, N'CS', 'active');
GO

-- TC-38: CampusSpace.space_name cannot be NULL
-- Expected Result: NOT NULL violation
INSERT INTO CampusSpace (campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status)
VALUES ('ZZ004', NULL, 'classroom', N'Building Z', 1, '004', 50, 'available');
GO

-- TC-39: SpaceBooking.requester_id cannot be NULL
-- Expected Result: NOT NULL violation
INSERT INTO SpaceBooking (requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status)
VALUES (NULL, 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00', 'lecture', 10, 'pending');
GO

-- TC-40: SpaceBooking.expected_participants cannot be NULL
-- Expected Result: NOT NULL violation
INSERT INTO SpaceBooking (requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status)
VALUES (4, 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00', 'lecture', NULL, 'pending');
GO

-- TC-41: SpaceMaintenance.problem_description cannot be NULL
-- Expected Result: NOT NULL violation
INSERT INTO SpaceMaintenance (campus_space_code, reporter_id, problem_description, problem_type, start_time, status)
VALUES ('A101', 4, NULL, 'other', GETDATE(), 'reported');
GO

-- TC-42: SpaceUsageSession.checked_in_by cannot be NULL
-- Expected Result: NOT NULL violation
INSERT INTO SpaceUsageSession (space_booking_id, checked_in_by, actual_start_time)
VALUES (2, NULL, GETDATE());
GO


-- ============================================================================
-- TRIGGER VIOLATIONS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- TRG-01 (BR-01): Overlapping approved bookings
-- ---------------------------------------------------------------------------
-- TC-43: Approve a booking that overlaps with an existing approved booking
--   Booking 9 (B201, 10:00-12:00) is already approved.
--   Insert a new booking for B201 at the same time and try to approve it.
-- Expected Result: TRG-01 violation
--   (Note: PK 300 is chosen to be well above existing sample data IDs)
SET IDENTITY_INSERT SpaceBooking ON;
INSERT INTO SpaceBooking (space_booking_id, requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, submitted_at)
VALUES (300, 4, 'B201', '2026-07-15 10:00:00', '2026-07-15 12:00:00', 'meeting', 10, 'pending', GETDATE());
SET IDENTITY_INSERT SpaceBooking OFF;
GO
UPDATE SpaceBooking SET status = 'approved' WHERE space_booking_id = 300;
GO
-- Clean up if the UPDATE somehow succeeded
DELETE FROM SpaceBooking WHERE space_booking_id = 300;
GO


-- ---------------------------------------------------------------------------
-- TRG-02 (BR-03): Invalid status transitions
-- ---------------------------------------------------------------------------

-- TC-44: Insert booking with non-pending status
-- Expected Result: TRG-02 violation
SET IDENTITY_INSERT SpaceBooking ON;
INSERT INTO SpaceBooking (space_booking_id, requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, submitted_at)
VALUES (301, 4, 'A101', '2026-09-01 08:00:00', '2026-09-01 10:00:00', 'lecture', 50, 'approved', GETDATE());
SET IDENTITY_INSERT SpaceBooking OFF;
GO

-- TC-45: Transition pending -> checked_in (skip approved)
--   Booking 4 (B201) is still pending in the sample data.
-- Expected Result: TRG-02 violation
UPDATE SpaceBooking SET status = 'checked_in' WHERE space_booking_id = 4;
GO

-- TC-46: Transition pending -> completed (skip approved, checked_in)
--   Booking 8 (E501) is still pending in the sample data.
-- Expected Result: TRG-02 violation
UPDATE SpaceBooking SET status = 'completed' WHERE space_booking_id = 8;
GO

-- TC-47: Transition rejected -> approved (rejected is a final state)
--   Booking 5 (A101) was transitioned to 'rejected' in the sample data.
-- Expected Result: TRG-02 violation
UPDATE SpaceBooking SET status = 'approved' WHERE space_booking_id = 5;
GO

-- TC-48: Transition cancelled -> checked_in (cancelled is a final state)
--   Booking 6 (D401) was transitioned to 'cancelled' in the sample data.
-- Expected Result: TRG-02 violation
UPDATE SpaceBooking SET status = 'checked_in' WHERE space_booking_id = 6;
GO

-- TC-49: Transition completed -> checked_in (completed is a final state)
--   Booking 1 (A101) was transitioned to 'completed' in the sample data.
-- Expected Result: TRG-02 violation
UPDATE SpaceBooking SET status = 'checked_in' WHERE space_booking_id = 1;
GO

-- TC-50: Transition no-show -> approved (no-show is a final state)
--   Booking 7 (B201) was transitioned to 'no-show' in the sample data.
-- Expected Result: TRG-02 violation
UPDATE SpaceBooking SET status = 'approved' WHERE space_booking_id = 7;
GO

-- TC-51: Transition checked_in -> pending (cannot go backwards)
--   Booking 3 (C301) is currently 'checked_in' in the sample data.
-- Expected Result: TRG-02 violation
UPDATE SpaceBooking SET status = 'pending' WHERE space_booking_id = 3;
GO


-- ---------------------------------------------------------------------------
-- TRG-03 (BR-07): Expected participants exceeding space capacity
-- ---------------------------------------------------------------------------

-- TC-52: Insert booking with expected_participants exceeding space capacity
--   D401 has capacity 20; try to book 25 participants.
-- Expected Result: TRG-03 violation
SET IDENTITY_INSERT SpaceBooking ON;
INSERT INTO SpaceBooking (space_booking_id, requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, submitted_at)
VALUES (302, 4, 'D401', '2026-09-01 08:00:00', '2026-09-01 10:00:00', 'meeting', 25, 'pending', GETDATE());
SET IDENTITY_INSERT SpaceBooking OFF;
GO

-- TC-53: Update existing booking to exceed space capacity
--   Booking 10 (D401, capacity 20) currently has 15 participants.
--   Try to increase to 30.
-- Expected Result: TRG-03 violation
UPDATE SpaceBooking SET expected_participants = 30 WHERE space_booking_id = 10;
GO


-- ---------------------------------------------------------------------------
-- TRG-04: (BR — Auto-update CampusSpace.current_status)
--   TRG-04 does not raise errors; it silently propagates maintenance
--   status changes to the space.  No exceptional test case applies.
--   Normal tests are in 06-verify-data-G02.sql (TC-N68, TC-N69).
-- ---------------------------------------------------------------------------
GO
