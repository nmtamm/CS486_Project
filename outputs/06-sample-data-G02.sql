-- ============================================================
-- Step 6: Sample Data — CS486 Shared Space Booking System
-- DBMS: Microsoft SQL Server
-- Execute after: 05-db-definition-G02.sql
-- ============================================================

USE SpaceBookingDB;

-- ============================================================
-- Primary Tables (no FK dependencies)
-- ============================================================

-- User (covers all roles and statuses)
INSERT INTO User
(
    user_id, full_name, email, phone_number, role, department, account_status
)
VALUES
('SV0001', N'Nguyen Van An', 'an.nguyen@university.edu.vn', '0901000001', 'student', N'Computer Science', 'active'),
('GV0001', N'Tran Thi Binh', 'binh.tran@university.edu.vn', '0901000002', 'lecturer', N'Computer Science', 'active'),
('TA0001', N'Le Van Cuong', 'cuong.le@university.edu.vn', '0901000003', 'teaching_assistant', N'Computer Science', 'active'),
('FS0001', N'Pham Thi Dung', 'dung.pham@university.edu.vn', '0901000004', 'facility_staff', N'Facilities', 'active'),
('DA0001', N'Hoang Van Em', 'em.hoang@university.edu.vn', '0901000005', 'department_administrator', N'Computer Science', 'active'),
('FM0001', N'Vo Thi Phuong', 'phuong.vo@university.edu.vn', '0901000006', 'facility_manager', N'Facilities', 'active'),
('SV0002', N'Do Van Giang', 'giang.do@university.edu.vn', '0901000007', 'student', N'Computer Science', 'active'),
('GV0002', N'Bui Thi Hanh', 'hanh.bui@university.edu.vn', '0901000008', 'lecturer', N'Computer Science', 'active'),
('FS0002', N'Nguyen Van Hieu', 'hieu.nguyen@university.edu.vn', '0901000009', 'facility_staff', N'Facilities', 'inactive'),
('TA0002', N'Pham Thi Mai', 'mai.pham@university.edu.vn', '0901000010', 'teaching_assistant', N'Computer Science', 'active');

-- Space (covers all types and statuses)
INSERT INTO Space
(
    space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy
)
VALUES
('A101', N'Auditorium A101', 'auditorium', N'Building A', 1, '101', 200, 'available', N'Lectures and seminars only'),
('B202', N'Classroom B202', 'classroom', N'Building B', 2, '202', 50, 'available', N'General teaching'),
('C301', N'Computer Lab C301', 'computer_laboratory', N'Building C', 3, '301', 40, 'available', N'Computer-related courses'),
('D101', N'Project Lab D101', 'project_laboratory', N'Building D', 1, '101', 30, 'available', N'Student projects'),
('E201', N'Meeting Room E201', 'meeting_room', N'Building E', 2, '201', 15, 'available', N'Meetings and discussions'),
('F101', N'Workspace F101', 'student_workspace', N'Building F', 1, '101', 20, 'available', N'Student self-study'),
('B101', N'Classroom B101', 'classroom', N'Building B', 1, '101', 40, 'in_use', N'General teaching'),
('C201', N'Computer Lab C201', 'computer_laboratory', N'Building C', 2, '201', 35, 'under_maintenance', N'Computer-related courses'),
('A201', N'Auditorium A201', 'auditorium', N'Building A', 2, '201', 150, 'temporarily_closed', N'Under renovation'),
('E101', N'Meeting Room E101', 'meeting_room', N'Building E', 1, '101', 10, 'retired', N'No longer in use');

-- Facility
INSERT INTO Facility
(
    facility_id, facility_name, description
)
VALUES
(1, N'Projector', N'HD projector for presentations'),
(2, N'Whiteboard', N'Standard whiteboard with markers'),
(3, N'Microphone', N'Wireless microphone system'),
(4, N'Computer', N'Desktop PC with standard software'),
(5, N'Livestreaming Equipment', N'Camera and streaming setup'),
(6, N'Air Conditioner', N'Air conditioning unit'),
(7, N'Speaker System', N'Surround sound speakers'),
(8, N'Printer', N'Network printer');

-- ============================================================
-- Dependent Tables (FK references)
-- ============================================================

-- SpaceFacility (M:N junction)
INSERT INTO SpaceFacility
(
    space_code, facility_id, quantity
)
VALUES
('A101', 1, 2),
('A101', 2, 1),
('A101', 3, 2),
('A101', 6, 2),
('A101', 7, 1),
('B202', 1, 1),
('B202', 2, 1),
('B202', 6, 1),
('C301', 4, 20),
('C301', 1, 1),
('C301', 6, 2),
('D101', 4, 5),
('D101', 2, 1),
('D101', 6, 1),
('E201', 1, 1),
('E201', 2, 1),
('E201', 3, 1),
('F101', 2, 1),
('F101', 6, 1),
('B101', 1, 1),
('B101', 2, 1),
('B101', 6, 1),
('C201', 4, 15),
('C201', 1, 1),
('C201', 6, 1);

-- BookingRequest (covers all statuses)
INSERT INTO BookingRequest
(
    booking_id, requester_id, space_code, requested_start_time, requested_end_time,
    booking_type, expected_participants, booking_status,
    approved_by, decision_time, decision_note, rejection_reason,
    actual_start_time, checked_in_by, initial_condition,
    actual_end_time, completed_by, final_condition, usage_notes
)
VALUES
(1, 'GV0001', 'A101', '2026-06-01 07:00:00', '2026-06-01 09:00:00',
 'lecture', 180, 'approved',
 'FS0001', '2026-05-25 10:00:00', N'Approved for weekly lecture', NULL,
 '2026-06-01 07:05:00', 'FS0001', N'Clean and tidy',
 '2026-06-01 09:00:00', 'FS0001', N'Good condition', N'Lecture completed on time'),
(2, 'SV0001', 'D101', '2026-06-02 13:00:00', '2026-06-02 17:00:00',
 'student_activity', 10, 'approved',
 'FS0001', '2026-05-26 14:00:00', N'Approved for project work', NULL,
 NULL, NULL, NULL,
 NULL, NULL, NULL, NULL),
(3, 'GV0002', 'C301', '2026-06-03 09:00:00', '2026-06-03 11:00:00',
 'examination', 35, 'pending',
 NULL, NULL, NULL, NULL,
 NULL, NULL, NULL,
 NULL, NULL, NULL, NULL),
(4, 'TA0001', 'E201', '2026-06-04 10:00:00', '2026-06-04 12:00:00',
 'meeting', 12, 'rejected',
 'FM0001', '2026-05-28 09:00:00', NULL, N'Room reserved for faculty meeting',
 NULL, NULL, NULL,
 NULL, NULL, NULL, NULL),
(5, 'DA0001', 'F101', '2026-06-05 08:00:00', '2026-06-05 10:00:00',
 'administrative_event', 15, 'cancelled',
 NULL, NULL, NULL, NULL,
 NULL, NULL, NULL,
 NULL, NULL, NULL, NULL),
(6, 'GV0001', 'B202', '2026-06-06 07:00:00', '2026-06-06 09:00:00',
 'lecture', 45, 'checked_in',
 'FS0001', '2026-06-01 08:00:00', N'Approved', NULL,
 '2026-06-06 07:10:00', 'FS0002', N'Clean, ready for use',
 NULL, NULL, NULL, NULL),
(7, 'SV0002', 'F101', '2026-06-07 14:00:00', '2026-06-07 17:00:00',
 'student_activity', 8, 'completed',
 'FS0001', '2026-06-02 11:00:00', N'Approved', NULL,
 '2026-06-07 14:00:00', 'FS0001', N'Normal condition',
 '2026-06-07 17:00:00', 'FS0001', N'Good', N'Students cleaned up after use'),
(8, 'TA0002', 'E201', '2026-06-08 09:00:00', '2026-06-08 11:00:00',
 'workshop', 10, 'no_show',
 'FM0001', '2026-06-03 10:00:00', N'Approved for workshop', NULL,
 NULL, NULL, NULL,
 NULL, NULL, NULL, NULL);

-- MaintenanceRecord (covers all statuses)
INSERT INTO MaintenanceRecord
(
    maintenance_id, space_code, reported_by, assigned_to, problem_description,
    start_time, completion_time, status, result_note
)
VALUES
(1, 'C201', 'GV0001', 'FS0001', N'Projector not turning on',
 '2026-05-20 08:00:00', '2026-05-22 16:00:00', 'completed', N'Replaced projector bulb'),
(2, 'A101', 'FS0001', 'FS0001', N'Air conditioner leaking water',
 '2026-05-25 09:00:00', NULL, 'in_progress', N'Waiting for replacement part'),
(3, 'B101', 'SV0001', NULL, N'Broken chair in row 3',
 '2026-05-28 10:00:00', NULL, 'reported', NULL),
(4, 'E201', 'DA0001', 'FS0001', N'Whiteboard damaged',
 '2026-05-30 14:00:00', '2026-06-01 11:00:00', 'completed', N'Whiteboard replaced'),
(5, 'D101', 'TA0001', 'FS0002', N'Network connectivity issues',
 '2026-06-01 08:00:00', NULL, 'assigned', NULL),
(6, 'F101', 'SV0002', NULL, N'Light flickering',
 NULL, NULL, 'cancelled', N'Resolved by building maintenance');
