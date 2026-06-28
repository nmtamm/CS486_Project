-- ============================================================================
-- Step 6 — Sample Data: School of Computer Science Space Booking System
-- Group: G02
-- DBMS:  Microsoft SQL Server
-- Execute after: 05-db-definition-G02.sql
-- ============================================================================

USE SpaceBookingDB;
GO

-- ============================================================================
-- Primary Tables (no FK dependencies)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. CAMPUS USER
--    Roles: facility_manager(1), facility_staff(2), lecturer(1),
--           student(2), teaching_assistant(1), department_admin(1)
--    account_status: active(7), inactive(1)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT CampusUser ON;
GO

INSERT INTO CampusUser (campus_user_id, full_name, email, phone, role, department, account_status)
VALUES
    (1, N'Nguyễn Văn An',      'an.nguyenvan@university.edu.vn',   '0901000001', 'facility_manager',  N'School of Computer Science', 'active'),
    (2, N'Trần Thị Bình',      'binh.tranthi@university.edu.vn',    '0901000002', 'facility_staff',    N'School of Computer Science', 'active'),
    (3, N'Lê Văn Cường',       'cuong.levan@university.edu.vn',     '0901000003', 'facility_staff',    N'School of Computer Science', 'active'),
    (4, N'Hoàng Thị Mai',      'mai.hoangthi@university.edu.vn',    '0901000004', 'lecturer',          N'Faculty of Information Technology', 'active'),
    (5, N'Trương Minh Tâm',    'tam.truongminh@university.edu.vn',  '0901000005', 'student',           N'Faculty of Computer Science', 'active'),
    (6, N'Phan Văn Long',      'long.phanvan@university.edu.vn',    NULL,          'student',           N'Faculty of Information Technology', 'inactive'),
    (7, N'Ngô Thị Phương',     'phuong.ngothi@university.edu.vn',   '0901000006', 'teaching_assistant', N'Faculty of Information Technology', 'active'),
    (8, N'Phạm Minh Đức',      'duc.phamminh@university.edu.vn',    '0901000007', 'department_admin',  N'School of Computer Science', 'active');
GO

SET IDENTITY_INSERT CampusUser OFF;
GO


-- ----------------------------------------------------------------------------
-- 2. CAMPUS SPACE (8 rows)
--    Types: auditorium(1), classroom(3), computer_lab(2), meeting_room(1),
--           temporarily_closed(1)
--    current_status: available(4), under_maintenance(1), in_use(1),
--                    temporarily_closed(1), retired(1)
-- ----------------------------------------------------------------------------
INSERT INTO CampusSpace (campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES
    ('A101', N'Main Auditorium',     'auditorium',          N'Building A', 1, '101', 200, 'available',           N'Lectures, seminars, and academic events.'),
    ('A201', N'Small Auditorium',    'auditorium',          N'Building A', 2, '201', 100, 'temporarily_closed',  N'Under renovation.'),
    ('B201', N'Lecture Room 201',    'classroom',           N'Building B', 2, '201', 60,  'available',           N'General teaching.'),
    ('B202', N'Lecture Room 202',    'classroom',           N'Building B', 2, '202', 50,  'in_use',             N'Currently occupied.'),
    ('C301', N'Computer Lab Alpha',  'computer_lab',        N'Building C', 3, '301', 40,  'available',           N'Practical sessions.'),
    ('C302', N'Computer Lab Beta',   'computer_lab',        N'Building C', 3, '302', 35,  'under_maintenance',   N'AC failure. Under maintenance.'),
    ('D401', N'Meeting Room 401',    'meeting_room',        N'Building D', 4, '401', 20,  'available',           N'Meetings and small groups.'),
    ('E501', N'Old Lecture Hall',    'classroom',           N'Building E', 5, '501', 80,  'retired',             N'No longer in service.');
GO


-- ----------------------------------------------------------------------------
-- 3. CAMPUS FACILITY (6 rows)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT CampusFacility ON;
GO

INSERT INTO CampusFacility (campus_facility_id, facility_name, description)
VALUES
    (1, N'Projector',     N'HD projector for presentations'),
    (2, N'Whiteboard',    N'Standard whiteboard with markers'),
    (3, N'Microphone',    N'Wireless microphone system'),
    (4, N'Computer',      N'Desktop PC'),
    (5, N'Air Conditioner', N'Split-type air conditioner'),
    (6, N'Speaker System', N'Surround sound speakers');
GO

SET IDENTITY_INSERT CampusFacility OFF;
GO


-- ============================================================================
-- Dependent Tables (have FK references)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 4. CAMPUS SPACE FACILITY (12 rows)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT CampusSpaceFacility ON;
GO

INSERT INTO CampusSpaceFacility (campus_space_facility_id, campus_space_code, campus_facility_id, quantity)
VALUES
    (1,  'A101', 1, 2),
    (2,  'A101', 2, 1),
    (3,  'A101', 3, 2),
    (4,  'A101', 5, 4),
    (5,  'A101', 6, 1),
    (6,  'B201', 1, 1),
    (7,  'B201', 2, 1),
    (8,  'B201', 5, 2),
    (9,  'C301', 1, 1),
    (10, 'C301', 2, 1),
    (11, 'C301', 4, 41),
    (12, 'C301', 5, 2);
GO

SET IDENTITY_INSERT CampusSpaceFacility OFF;
GO


-- ----------------------------------------------------------------------------
-- 5. SPACE BOOKING (8 rows)
--    purpose_type: lecture(2), meeting(1), workshop(1), examination(1),
--                  administrative_event(1), student_activity(1), seminar(1)
--    status: completed(1), approved(1), checked_in(1), pending(2),
--            rejected(1), cancelled(1), no-show(1)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT SpaceBooking ON;
GO

INSERT INTO SpaceBooking (space_booking_id, requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, submitted_at)
VALUES
    (1, 4, 'A101', '2026-06-20 07:00:00', '2026-06-20 09:00:00', 'lecture',             150, 'completed',          '2026-06-15 08:00:00'),
    (2, 5, 'D401', '2026-07-02 14:00:00', '2026-07-02 16:00:00', 'meeting',              15, 'approved',           '2026-06-23 11:00:00'),
    (3, 4, 'C301', '2026-06-25 08:00:00', '2026-06-25 12:00:00', 'workshop',             35, 'checked_in',         '2026-06-18 09:00:00'),
    (4, 5, 'B201', '2026-07-05 09:00:00', '2026-07-05 11:00:00', 'examination',          55, 'pending',            '2026-06-27 14:00:00'),
    (5, 5, 'A101', '2026-06-22 10:00:00', '2026-06-22 12:00:00', 'administrative_event', 180, 'rejected',           '2026-06-17 08:00:00'),
    (6, 5, 'D401', '2026-06-26 08:00:00', '2026-06-26 10:00:00', 'student_activity',     10, 'cancelled',          '2026-06-19 10:00:00'),
    (7, 4, 'B201', '2026-06-23 07:00:00', '2026-06-23 09:00:00', 'seminar',              45, 'no-show',            '2026-06-18 07:00:00'),
    (8, 5, 'E501', '2026-07-10 08:00:00', '2026-07-10 10:00:00', 'lecture',              30, 'pending',            '2026-06-28 08:00:00');
GO

SET IDENTITY_INSERT SpaceBooking OFF;
GO


-- ----------------------------------------------------------------------------
-- 6. BOOKING APPROVAL (5 rows)
--    decision: approved(4), rejected(1 with rejection_reason)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT BookingApproval ON;
GO

INSERT INTO BookingApproval (booking_approval_id, space_booking_id, staff_id, decision, decision_time, decision_note, rejection_reason)
VALUES
    (1, 1, 2, 'approved', '2026-06-16 09:00:00', N'Approved for weekly lecture.',               NULL),
    (2, 2, 1, 'approved', '2026-06-24 10:00:00', N'Meeting room approved.',                     NULL),
    (3, 3, 2, 'approved', '2026-06-19 09:30:00', N'Workshop approved. Ensure computers ready.', NULL),
    (4, 5, 2, 'rejected', '2026-06-18 09:00:00', NULL,                                          N'A101 already booked at that time.'),
    (5, 7, 2, 'approved', '2026-06-19 10:00:00', N'Seminar approved.',                          NULL);
GO

SET IDENTITY_INSERT BookingApproval OFF;
GO


-- ----------------------------------------------------------------------------
-- 7. SPACE USAGE SESSION (4 rows)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT SpaceUsageSession ON;
GO

INSERT INTO SpaceUsageSession (space_usage_session_id, space_booking_id, checked_in_by, actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes)
VALUES
    (1, 1, 2, '2026-06-20 07:05:00', N'Clean and tidy. All equipment working.', '2026-06-20 09:10:00', N'Good condition.', N'Lecture completed on time.'),
    (2, 3, 2, '2026-06-25 08:00:00', N'All computers working. Room clean.',     NULL,                  NULL,              NULL),
    (3, 7, 2, '2026-06-23 07:00:00', N'No user arrived at start time.',         '2026-06-23 07:30:00', N'N/A',            N'User did not show up.'),
    (4, 2, 3, '2026-06-26 15:00:00', N'Room tidy.',                             NULL,                  NULL,              NULL);
GO

SET IDENTITY_INSERT SpaceUsageSession OFF;
GO


-- ----------------------------------------------------------------------------
-- 8. SPACE MAINTENANCE (6 rows)
--    problem_type: ac_failure(1), broken_projector(1), network(1), cleaning(1),
--                  damaged_furniture(1), other(1)
--    status: in_progress(1), completed(2), reported(2), cancelled(1)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT SpaceMaintenance ON;
GO

INSERT INTO SpaceMaintenance (space_maintenance_id, campus_space_code, reporter_id, assigned_staff_id, problem_description, problem_type, start_time, completion_time, status, result_note)
VALUES
    (1, 'C302', 4, 3,    N'Air conditioner not cooling. Room temperature above 35°C.',  'ac_failure',       '2026-06-22 08:00:00', NULL,                     'in_progress', N'Waiting for replacement AC unit.'),
    (2, 'E501', 5, 2,    N'Projector lamp burned out. No image visible.',               'broken_projector', '2026-06-10 09:00:00', '2026-06-11 16:00:00',    'completed',   N'Lamp replaced. Working normally.'),
    (3, 'D401', 5, NULL, N'WiFi not working in meeting room.',                           'network',          '2026-06-27 14:00:00', NULL,                     'reported',    NULL),
    (4, 'A101', 4, 3,    N'Stains on floor after event.',                                'cleaning',         '2026-06-15 10:00:00', '2026-06-15 10:30:00',    'completed',   N'Floor cleaned.'),
    (5, 'B201', 5, 2,    N'Broken chair in row 3, seat 12.',                             'damaged_furniture','2026-06-20 09:00:00', '2026-06-21 11:00:00',    'completed',   N'Chair replaced.'),
    (6, 'A101', 5, NULL, N'Strange noise from speaker system.',                          'other',            '2026-06-28 09:00:00', NULL,                     'reported',    NULL);
GO

SET IDENTITY_INSERT SpaceMaintenance OFF;
GO
