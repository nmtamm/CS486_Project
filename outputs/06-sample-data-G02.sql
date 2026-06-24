-- ============================================================
-- Step 6: Sample Data Preparation
-- School Shared Space Booking System
-- Group: G02
-- DBMS: Microsoft SQL Server
-- Based on: 05-db-definition-G02.sql
-- ============================================================

USE SpaceBookingDB;
GO

-- ============================================================
-- 1. Valid Sample Data
-- ============================================================

-- ============================================================
-- 1.1. Primary Tables (no foreign key dependencies)
-- ============================================================

-- --------------------------------
-- 1.1.1. Users (6 records)
-- --------------------------------
insert into Users
(
    user_id,
    full_name,
    email,
    phone_number,
    role,
    department,
    account_status
)
values
('USR001', N'Nguyễn Văn An',       'an.nguyen@university.edu.vn',  '0901234001', 'student',                  N'Khoa Công nghệ Thông tin',         'active'),
('USR002', N'Trần Thị Bình',        'binh.tran@university.edu.vn',  '0901234002', 'lecturer',                  N'Khoa Công nghệ Thông tin',         'active'),
('USR003', N'Lê Hoàng Cường',       'cuong.le@university.edu.vn',   '0901234003', 'teaching_assistant',        N'Khoa Toán - Cơ - Tin học',         'active'),
('USR004', N'Phạm Minh Đức',        'duc.pham@university.edu.vn',   '0901234004', 'facility_staff',            N'Ban Quản lý Cơ sở vật chất',       'active'),
('USR005', N'Hoàng Thị Mai',        'mai.hoang@university.edu.vn',  '0901234005', 'facility_manager',          N'Ban Quản lý Cơ sở vật chất',       'active'),
('USR006', N'Vũ Văn Em',            'em.vu@university.edu.vn',      '0901234006', 'department_administrator',  N'Khoa Khoa học Máy tính',           'active');
GO

-- --------------------------------
-- 1.1.2. Space (5 records)
-- --------------------------------
insert into Space
(
    space_code,
    space_name,
    space_type,
    building,
    floor,
    room_number,
    capacity,
    current_status,
    usage_policy
)
values
('SPC001', N'Hội trường A',          'auditorium',          N'Tòa nhà Trung tâm',  1, 'A101', 200, 'available',          N'Phù hợp cho hội thảo, lễ lớn, bài giảng đông người'),
('SPC002', N'Phòng học B201',        'classroom',           N'Tòa nhà B',          2, 'B201',  50, 'available',          N'Phòng học lý thuyết tiêu chuẩn'),
('SPC003', N'Phòng máy tính C301',   'computer_laboratory',  N'Tòa nhà C',          3, 'C301',  40, 'available',          N'Trang bị máy tính cho thực hành lập trình'),
('SPC004', N'Phòng họp D101',        'meeting_room',        N'Tòa nhà Hành chính', 1, 'D101',  20, 'available',          N'Phòng họp nội bộ, tối đa 20 người'),
('SPC005', N'Không gian sinh viên E', 'student_workspace',  N'Tòa nhà E',          1, 'E101',  30, 'available',          N'Không gian mở cho sinh viên học nhóm');
GO

-- --------------------------------
-- 1.1.3. Facility (6 records)
-- --------------------------------
insert into Facility
(
    facility_id,
    facility_name,
    description
)
values
('FAC001', 'projector',              N'Máy chiếu Epson EB-2155W, độ phân giải WXGA'),
('FAC002', 'whiteboard',             N'Bảng trắng kích thước 2m x 1.2m, kèm bút lông'),
('FAC003', 'microphone',             N'Micro không dây Shure BLX288, tầm xa 50m'),
('FAC004', 'computer',               N'Máy tính Dell OptiPlex 7080, Core i7, RAM 16GB'),
('FAC005', 'livestreaming_equipment',N'Bộ thiết bị livestream Logitech MeetUp, webcam 4K'),
('FAC006', 'air_conditioner',        N'Máy lạnh Daikin FTKQ50TVMV, công suất 2HP');
GO

-- ============================================================
-- 1.2. Dependent Tables (contain foreign keys)
-- ============================================================

-- --------------------------------
-- 1.2.1. SpaceFacility (8 records)
-- --------------------------------
insert into SpaceFacility
(
    space_code,
    facility_id,
    quantity
)
values
('SPC001', 'FAC001', 2),
('SPC001', 'FAC003', 4),
('SPC001', 'FAC006', 4),
('SPC002', 'FAC001', 1),
('SPC002', 'FAC002', 1),
('SPC002', 'FAC006', 2),
('SPC003', 'FAC004', 40),
('SPC003', 'FAC006', 2);
GO

-- --------------------------------
-- 1.2.2. BookingRequest (8 records)
-- --------------------------------
insert into BookingRequest
(
    booking_id,
    space_code,
    requester_id,
    requested_start_time,
    requested_end_time,
    purpose,
    expected_participants,
    booking_status,
    approver_id,
    decision_time,
    decision_note,
    rejection_reason,
    actual_start_time,
    checked_in_by,
    initial_condition,
    actual_end_time,
    completed_by,
    final_condition,
    usage_notes
)
values
(
    'BR001', 'SPC002', 'USR001',
    '2026-06-25 08:00:00', '2026-06-25 10:00:00',
    'lecture', 30,
    'pending',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
),
(
    'BR002', 'SPC001', 'USR002',
    '2026-06-26 07:00:00', '2026-06-26 09:00:00',
    'lecture', 150,
    'approved',
    'USR005', '2026-06-24 10:00:00', N'Đã phê duyệt. Hội trường sẵn sàng.', NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
),
(
    'BR003', 'SPC002', 'USR003',
    '2026-06-27 13:00:00', '2026-06-27 15:00:00',
    'workshop', 20,
    'rejected',
    'USR005', '2026-06-24 11:00:00', N'Từ chối do trùng lịch.', N'Phòng đã được đặt trước cho buổi hội thảo khác.',
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
),
(
    'BR004', 'SPC002', 'USR002',
    '2026-06-24 08:00:00', '2026-06-24 10:00:00',
    'lecture', 45,
    'checked_in',
    'USR005', '2026-06-23 14:00:00', N'Đã phê duyệt.', NULL,
    '2026-06-24 08:05:00',
    'USR004', N'Phòng sạch sẽ, bảng trắng đã được lau, máy chiếu hoạt động tốt.',
    NULL, NULL, NULL, NULL
),
(
    'BR005', 'SPC001', 'USR002',
    '2026-06-23 07:00:00', '2026-06-23 09:00:00',
    'examination', 180,
    'completed',
    'USR005', '2026-06-22 09:00:00', N'Đã phê duyệt cho kỳ thi.', NULL,
    '2026-06-23 07:00:00',
    'USR004', N'Hội trường sạch sẽ, đủ bàn ghế cho 180 thí sinh.',
    '2026-06-23 09:00:00',
    'USR004', N'Phòng trả lại trong tình trạng tốt, không hư hỏng.', N'Kỳ thi diễn ra suôn sẻ, đúng tiến độ.'
),
(
    'BR006', 'SPC005', 'USR001',
    '2026-06-28 14:00:00', '2026-06-28 17:00:00',
    'student_activity', 10,
    'cancelled',
    'USR005', '2026-06-26 08:00:00', N'Đã phê duyệt.', NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
),
(
    'BR007', 'SPC003', 'USR003',
    '2026-06-22 09:00:00', '2026-06-22 11:00:00',
    'seminar', 25,
    'no_show',
    'USR005', '2026-06-21 15:00:00', N'Đã phê duyệt.', NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
),
(
    'BR008', 'SPC004', 'USR006',
    '2026-06-30 10:00:00', '2026-06-30 11:30:00',
    'meeting', 10,
    'approved',
    'USR005', '2026-06-25 09:00:00', N'Phòng họp đã sẵn sàng.', NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);
GO

-- --------------------------------
-- 1.2.3. MaintenanceRecord (4 records)
-- --------------------------------
insert into MaintenanceRecord
(
    maintenance_id,
    space_code,
    reporter_id,
    assigned_staff_id,
    problem_description,
    problem_type,
    start_time,
    completion_time,
    status,
    result_note
)
values
(
    'MNT001', 'SPC001', 'USR004', NULL,
    N'Máy chiếu tại Hội trường A không lên hình, đèn báo nguồn nhấp nháy.',
    'broken_projector',
    '2026-06-20 08:00:00',
    NULL,
    'reported',
    NULL
),
(
    'MNT002', 'SPC003', 'USR001', 'USR004',
    N'Máy lạnh trong phòng máy tính C301 kêu to và không mát.',
    'air_conditioning_failure',
    '2026-06-21 10:00:00',
    NULL,
    'in_progress',
    NULL
),
(
    'MNT003', 'SPC002', 'USR004', 'USR004',
    N'Ghế trong phòng B201 bị gãy chân, nguy hiểm cho người dùng.',
    'damaged_furniture',
    '2026-06-15 09:00:00',
    '2026-06-16 16:00:00',
    'completed',
    N'Đã thay ghế mới. Kiểm tra an toàn toàn bộ phòng học.'
),
(
    'MNT004', 'SPC005', 'USR001', NULL,
    N'Mạng WiFi tại khu vực E101 chập chờn, mất kết nối thường xuyên.',
    'network_problem',
    '2026-06-18 14:00:00',
    NULL,
    'cancelled',
    NULL
);
GO

-- ============================================================
-- 2. Exceptional Test Cases (constraint enforcement)
-- ============================================================

-- TC-01: Invalid role for Users
-- Expected Result: FAIL (CHECK constraint on role)
insert into Users
(
    user_id,
    full_name,
    email,
    phone_number,
    role,
    department,
    account_status
)
values
(
    'ERR001',
    N'Người Dùng Lỗi',
    'error.user@university.edu.vn',
    '0999999001',
    'janitor',
    N'Khoa không tồn tại',
    'active'
);
GO

-- TC-02: Invalid account_status for Users
-- Expected Result: FAIL (CHECK constraint on account_status)
insert into Users
(
    user_id,
    full_name,
    email,
    phone_number,
    role,
    department,
    account_status
)
values
(
    'ERR002',
    N'Người Dùng Lỗi 2',
    'error.user2@university.edu.vn',
    '0999999002',
    'student',
    N'Khoa Công nghệ Thông tin',
    'banned'
);
GO

-- TC-03: Duplicate email for Users
-- Expected Result: FAIL (UNIQUE constraint on email)
insert into Users
(
    user_id,
    full_name,
    email,
    phone_number,
    role,
    department,
    account_status
)
values
(
    'ERR003',
    N'Người Dùng Lỗi 3',
    'an.nguyen@university.edu.vn',
    '0999999003',
    'student',
    N'Khoa Công nghệ Thông tin',
    'active'
);
GO

-- TC-04: Invalid space_type for Space
-- Expected Result: FAIL (CHECK constraint on space_type)
insert into Space
(
    space_code,
    space_name,
    space_type,
    building,
    floor,
    room_number,
    capacity,
    current_status,
    usage_policy
)
values
(
    'ERRSPC01',
    N'Phòng không hợp lệ',
    'gymnasium',
    N'Tòa nhà X',
    1,
    'X001',
    100,
    'available',
    NULL
);
GO

-- TC-05: Invalid current_status for Space
-- Expected Result: FAIL (CHECK constraint on current_status)
insert into Space
(
    space_code,
    space_name,
    space_type,
    building,
    floor,
    room_number,
    capacity,
    current_status,
    usage_policy
)
values
(
    'ERRSPC02',
    N'Phòng không hợp lệ 2',
    'classroom',
    N'Tòa nhà X',
    1,
    'X002',
    100,
    'destroyed',
    NULL
);
GO

-- TC-06: capacity = 0 for Space
-- Expected Result: FAIL (CHECK constraint capacity > 0)
insert into Space
(
    space_code,
    space_name,
    space_type,
    building,
    floor,
    room_number,
    capacity,
    current_status,
    usage_policy
)
values
(
    'ERRSPC03',
    N'Phòng không hợp lệ 3',
    'classroom',
    N'Tòa nhà X',
    1,
    'X003',
    0,
    'available',
    NULL
);
GO

-- TC-07: Invalid facility_name for Facility
-- Expected Result: FAIL (CHECK constraint on facility_name)
insert into Facility
(
    facility_id,
    facility_name,
    description
)
values
(
    'ERRFAC01',
    'television',
    N'TV màn hình phẳng 65 inch'
);
GO

-- TC-08: quantity <= 0 for SpaceFacility
-- Expected Result: FAIL (CHECK constraint quantity > 0)
insert into SpaceFacility
(
    space_code,
    facility_id,
    quantity
)
values
(
    'SPC001',
    'FAC002',
    0
);
GO

-- TC-09: Non-existent space_code in SpaceFacility
-- Expected Result: FAIL (FOREIGN KEY constraint)
insert into SpaceFacility
(
    space_code,
    facility_id,
    quantity
)
values
(
    'NONEXIST',
    'FAC001',
    1
);
GO

-- TC-10: Non-existent facility_id in SpaceFacility
-- Expected Result: FAIL (FOREIGN KEY constraint)
insert into SpaceFacility
(
    space_code,
    facility_id,
    quantity
)
values
(
    'SPC001',
    'NONEXIST',
    1
);
GO

-- TC-11: Invalid purpose for BookingRequest
-- Expected Result: FAIL (CHECK constraint on purpose)
insert into BookingRequest
(
    booking_id,
    space_code,
    requester_id,
    requested_start_time,
    requested_end_time,
    purpose,
    expected_participants,
    booking_status
)
values
(
    'ERRBR01',
    'SPC001',
    'USR001',
    '2026-07-01 08:00:00',
    '2026-07-01 10:00:00',
    'party',
    50,
    'pending'
);
GO

-- TC-12: Invalid booking_status for BookingRequest
-- Expected Result: FAIL (CHECK constraint on booking_status)
insert into BookingRequest
(
    booking_id,
    space_code,
    requester_id,
    requested_start_time,
    requested_end_time,
    purpose,
    expected_participants,
    booking_status
)
values
(
    'ERRBR02',
    'SPC001',
    'USR001',
    '2026-07-01 08:00:00',
    '2026-07-01 10:00:00',
    'lecture',
    50,
    'deleted'
);
GO

-- TC-13: requested_end_time <= requested_start_time for BookingRequest
-- Expected Result: FAIL (CHECK constraint requested_end_time > requested_start_time)
insert into BookingRequest
(
    booking_id,
    space_code,
    requester_id,
    requested_start_time,
    requested_end_time,
    purpose,
    expected_participants,
    booking_status
)
values
(
    'ERRBR03',
    'SPC001',
    'USR001',
    '2026-07-01 10:00:00',
    '2026-07-01 08:00:00',
    'lecture',
    50,
    'pending'
);
GO

-- TC-14: expected_participants = 0 for BookingRequest
-- Expected Result: FAIL (CHECK constraint expected_participants > 0)
insert into BookingRequest
(
    booking_id,
    space_code,
    requester_id,
    requested_start_time,
    requested_end_time,
    purpose,
    expected_participants,
    booking_status
)
values
(
    'ERRBR04',
    'SPC001',
    'USR001',
    '2026-07-01 08:00:00',
    '2026-07-01 10:00:00',
    'lecture',
    0,
    'pending'
);
GO

-- TC-15: Rejected booking without rejection_reason
-- Expected Result: FAIL (CHECK constraint: rejected requires rejection_reason)
insert into BookingRequest
(
    booking_id,
    space_code,
    requester_id,
    requested_start_time,
    requested_end_time,
    purpose,
    expected_participants,
    booking_status,
    approver_id,
    decision_time,
    rejection_reason
)
values
(
    'ERRBR05',
    'SPC001',
    'USR001',
    '2026-07-01 08:00:00',
    '2026-07-01 10:00:00',
    'lecture',
    50,
    'rejected',
    'USR005',
    '2026-06-28 10:00:00',
    NULL
);
GO

-- TC-16: Invalid problem_type for MaintenanceRecord
-- Expected Result: FAIL (CHECK constraint on problem_type)
insert into MaintenanceRecord
(
    maintenance_id,
    space_code,
    reporter_id,
    problem_description,
    problem_type,
    start_time,
    status
)
values
(
    'ERRMNT01',
    'SPC001',
    'USR004',
    N'Cửa phòng bị kẹt không thể đóng mở.',
    'broken_door',
    '2026-07-01 08:00:00',
    'reported'
);
GO

-- TC-17: Invalid status for MaintenanceRecord
-- Expected Result: FAIL (CHECK constraint on status)
insert into MaintenanceRecord
(
    maintenance_id,
    space_code,
    reporter_id,
    problem_description,
    problem_type,
    start_time,
    status
)
values
(
    'ERRMNT02',
    'SPC001',
    'USR004',
    N'Bóng đèn bị cháy.',
    'cleaning_issue',
    '2026-07-01 08:00:00',
    'pending_review'
);
GO

-- TC-18: Completed maintenance without completion_time and result_note
-- Expected Result: FAIL (CHECK constraint: completed requires completion_time AND result_note)
insert into MaintenanceRecord
(
    maintenance_id,
    space_code,
    reporter_id,
    assigned_staff_id,
    problem_description,
    problem_type,
    start_time,
    completion_time,
    status,
    result_note
)
values
(
    'ERRMNT03',
    'SPC001',
    'USR004',
    'USR004',
    N'Bóng đèn bị cháy.',
    'cleaning_issue',
    '2026-07-01 08:00:00',
    NULL,
    'completed',
    NULL
);
GO

-- TC-19: Non-existent space_code in BookingRequest
-- Expected Result: FAIL (FOREIGN KEY constraint)
insert into BookingRequest
(
    booking_id,
    space_code,
    requester_id,
    requested_start_time,
    requested_end_time,
    purpose,
    expected_participants,
    booking_status
)
values
(
    'ERRBR06',
    'NONEXIST',
    'USR001',
    '2026-07-01 08:00:00',
    '2026-07-01 10:00:00',
    'lecture',
    50,
    'pending'
);
GO

-- TC-20: Non-existent requester_id in BookingRequest
-- Expected Result: FAIL (FOREIGN KEY constraint)
insert into BookingRequest
(
    booking_id,
    space_code,
    requester_id,
    requested_start_time,
    requested_end_time,
    purpose,
    expected_participants,
    booking_status
)
values
(
    'ERRBR07',
    'SPC001',
    'NONEXIST',
    '2026-07-01 08:00:00',
    '2026-07-01 10:00:00',
    'lecture',
    50,
    'pending'
);
GO

-- TC-21: Non-existent space_code in MaintenanceRecord
-- Expected Result: FAIL (FOREIGN KEY constraint)
insert into MaintenanceRecord
(
    maintenance_id,
    space_code,
    reporter_id,
    problem_description,
    problem_type,
    start_time,
    status
)
values
(
    'ERRMNT04',
    'NONEXIST',
    'USR004',
    N'Kiểm tra định kỳ.',
    'cleaning_issue',
    '2026-07-01 08:00:00',
    'reported'
);
GO

-- TC-22: Non-existent reporter_id in MaintenanceRecord
-- Expected Result: FAIL (FOREIGN KEY constraint)
insert into MaintenanceRecord
(
    maintenance_id,
    space_code,
    reporter_id,
    problem_description,
    problem_type,
    start_time,
    status
)
values
(
    'ERRMNT05',
    'SPC001',
    'NONEXIST',
    N'Kiểm tra định kỳ.',
    'cleaning_issue',
    '2026-07-01 08:00:00',
    'reported'
);
GO