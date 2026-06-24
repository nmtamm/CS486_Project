-- ============================================================
-- Step 6: Exceptional Test Cases — CS486 Shared Space Booking System
-- DBMS: Microsoft SQL Server
-- Execute after: 06-sample-data-G02.sql
-- All test cases must FAIL with a constraint violation error
-- ============================================================

USE SpaceBookingDB;

-- ============================================================
-- PRIMARY KEY Violations
-- ============================================================

-- TC-01: Duplicate User user_id
-- Expected Result: PRIMARY KEY violation
INSERT INTO User
(
    user_id, full_name, email, phone_number, role, department, account_status
)
VALUES
('SV0001', N'Fake Name', 'fake@university.edu.vn', '0999999999', 'student', N'CS', 'active');

GO

-- TC-02: Duplicate Space space_code
-- Expected Result: PRIMARY KEY violation
INSERT INTO Space
(
    space_code, space_name, space_type, building, floor, room_number, capacity, current_status
)
VALUES
('A101', N'Fake Space', 'auditorium', N'Building X', 1, '001', 100, 'available');

GO

-- TC-03: Duplicate BookingRequest booking_id
-- Expected Result: PRIMARY KEY violation
INSERT INTO BookingRequest
(
    booking_id, requester_id, space_code, requested_start_time, requested_end_time,
    booking_type, expected_participants, booking_status
)
VALUES
(1, 'SV0001', 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00',
 'meeting', 10, 'pending');

GO

-- TC-04: Duplicate Facility facility_id
-- Expected Result: PRIMARY KEY violation
INSERT INTO Facility
(
    facility_id, facility_name, description
)
VALUES
(1, N'Fake Facility', N'Description');

GO

-- ============================================================
-- UNIQUE Constraint Violations
-- ============================================================

-- TC-05: Duplicate User email
-- Expected Result: UNIQUE constraint violation
INSERT INTO User
(
    user_id, full_name, email, phone_number, role, department, account_status
)
VALUES
('XX0001', N'Duplicate Email', 'an.nguyen@university.edu.vn', '0999999998', 'student', N'CS', 'active');

GO

-- TC-06: Duplicate Space space_name
-- Expected Result: UNIQUE constraint violation
INSERT INTO Space
(
    space_code, space_name, space_type, building, floor, room_number, capacity, current_status
)
VALUES
('ZZ999', N'Auditorium A101', 'auditorium', N'Building Z', 1, '999', 100, 'available');

GO

-- ============================================================
-- FK Violations (referencing non-existent parent records)
-- ============================================================

-- TC-07: BookingRequest with non-existent requester_id
-- Expected Result: FOREIGN KEY violation
INSERT INTO BookingRequest
(
    booking_id, requester_id, space_code, requested_start_time, requested_end_time,
    booking_type, expected_participants, booking_status
)
VALUES
(100, 'NONEXIST', 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00',
 'meeting', 10, 'pending');

GO

-- TC-08: BookingRequest with non-existent space_code
-- Expected Result: FOREIGN KEY violation
INSERT INTO BookingRequest
(
    booking_id, requester_id, space_code, requested_start_time, requested_end_time,
    booking_type, expected_participants, booking_status
)
VALUES
(101, 'SV0001', 'ZZZZZ', '2026-07-01 08:00:00', '2026-07-01 10:00:00',
 'meeting', 10, 'pending');

GO

-- TC-09: BookingRequest.approved_by with non-existent User
-- Expected Result: FOREIGN KEY violation
INSERT INTO BookingRequest
(
    booking_id, requester_id, space_code, requested_start_time, requested_end_time,
    booking_type, expected_participants, booking_status, approved_by
)
VALUES
(102, 'SV0001', 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00',
 'meeting', 10, 'approved', 'GHOST01');

GO

-- TC-10: SpaceFacility with non-existent space_code
-- Expected Result: FOREIGN KEY violation
INSERT INTO SpaceFacility
(
    space_code, facility_id, quantity
)
VALUES
('ZZZZZ', 1, 1);

GO

-- TC-11: SpaceFacility with non-existent facility_id
-- Expected Result: FOREIGN KEY violation
INSERT INTO SpaceFacility
(
    space_code, facility_id, quantity
)
VALUES
('A101', 999, 1);

GO

-- TC-12: MaintenanceRecord with non-existent space_code
-- Expected Result: FOREIGN KEY violation
INSERT INTO MaintenanceRecord
(
    maintenance_id, space_code, reported_by, problem_description, status
)
VALUES
(100, 'ZZZZZ', 'SV0001', N'Test problem', 'reported');

GO

-- TC-13: MaintenanceRecord with non-existent reported_by
-- Expected Result: FOREIGN KEY violation
INSERT INTO MaintenanceRecord
(
    maintenance_id, space_code, reported_by, problem_description, status
)
VALUES
(101, 'A101', 'GHOST01', N'Test problem', 'reported');

GO

-- TC-14: MaintenanceRecord.assigned_to with non-existent User
-- Expected Result: FOREIGN KEY violation
INSERT INTO MaintenanceRecord
(
    maintenance_id, space_code, reported_by, assigned_to, problem_description, status
)
VALUES
(102, 'A101', 'SV0001', 'GHOST01', N'Test problem', 'assigned');

GO

-- ============================================================
-- CHECK Constraint Violations (invalid enum values)
-- ============================================================

-- TC-15: User.role with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO User
(
    user_id, full_name, email, phone_number, role, department, account_status
)
VALUES
('XX0002', N'Bad Role', 'bad.role@university.edu.vn', '0999999997', 'admin', N'CS', 'active');

GO

-- TC-16: User.account_status with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO User
(
    user_id, full_name, email, phone_number, role, department, account_status
)
VALUES
('XX0003', N'Bad Status', 'bad.status@university.edu.vn', '0999999996', 'student', N'CS', 'locked');

GO

-- TC-17: Space.space_type with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO Space
(
    space_code, space_name, space_type, building, floor, room_number, capacity, current_status
)
VALUES
('ZZ001', N'Invalid Type Space', 'gymnasium', N'Building Z', 1, '001', 100, 'available');

GO

-- TC-18: Space.current_status with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO Space
(
    space_code, space_name, space_type, building, floor, room_number, capacity, current_status
)
VALUES
('ZZ002', N'Invalid Status Space', 'classroom', N'Building Z', 1, '002', 100, 'closed');

GO

-- TC-19: Space.capacity with non-positive value
-- Expected Result: CHECK constraint violation
INSERT INTO Space
(
    space_code, space_name, space_type, building, floor, room_number, capacity, current_status
)
VALUES
('ZZ003', N'Zero Capacity', 'classroom', N'Building Z', 1, '003', 0, 'available');

GO

-- TC-20: BookingRequest.booking_type with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO BookingRequest
(
    booking_id, requester_id, space_code, requested_start_time, requested_end_time,
    booking_type, expected_participants, booking_status
)
VALUES
(200, 'SV0001', 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00',
 'party', 10, 'pending');

GO

-- TC-21: BookingRequest.booking_status with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO BookingRequest
(
    booking_id, requester_id, space_code, requested_start_time, requested_end_time,
    booking_type, expected_participants, booking_status
)
VALUES
(201, 'SV0001', 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00',
 'meeting', 10, 'unknown');

GO

-- TC-22: BookingRequest.expected_participants with non-positive value
-- Expected Result: CHECK constraint violation
INSERT INTO BookingRequest
(
    booking_id, requester_id, space_code, requested_start_time, requested_end_time,
    booking_type, expected_participants, booking_status
)
VALUES
(202, 'SV0001', 'A101', '2026-07-01 08:00:00', '2026-07-01 10:00:00',
 'meeting', 0, 'pending');

GO

-- TC-23: MaintenanceRecord.status with invalid value
-- Expected Result: CHECK constraint violation
INSERT INTO MaintenanceRecord
(
    maintenance_id, space_code, reported_by, problem_description, status
)
VALUES
(200, 'A101', 'SV0001', N'Test problem', 'on_hold');

GO

-- TC-24: SpaceFacility.quantity with non-positive value
-- Expected Result: CHECK constraint violation
INSERT INTO SpaceFacility
(
    space_code, facility_id, quantity
)
VALUES
('A101', 1, 0);

GO

-- ============================================================
-- NOT NULL Constraint Violations
-- ============================================================

-- TC-25: User without required full_name
-- Expected Result: NOT NULL constraint violation
INSERT INTO User
(
    user_id, full_name, email, role, account_status
)
VALUES
('XX0004', NULL, 'noname@university.edu.vn', 'student', 'active');

GO

-- TC-26: Space without required space_name
-- Expected Result: NOT NULL constraint violation
INSERT INTO Space
(
    space_code, space_name, space_type, building, floor, room_number, capacity, current_status
)
VALUES
('ZZ004', NULL, 'classroom', N'Building Z', 1, '004', 100, 'available');

GO
