-- ============================================================================
-- Database Definition for School of Computer Science Space Booking System
-- Group: G02
-- DBMS:  Microsoft SQL Server
-- Date:  2026-06-27
-- ============================================================================

CREATE DATABASE SpaceBookingDB;
GO
USE SpaceBookingDB;
GO

-- ----------------------------------------------------------------------------
-- 1. CAMPUS USER
-- ----------------------------------------------------------------------------
CREATE TABLE CampusUser (
    campus_user_id  INT             NOT NULL IDENTITY(1,1),
    full_name       NVARCHAR(100)   NOT NULL,
    email           NVARCHAR(255)   NOT NULL,
    phone           NVARCHAR(20)    NULL,
    role            NVARCHAR(30)    NOT NULL,
    department      NVARCHAR(100)   NOT NULL,
    account_status  NVARCHAR(20)    NOT NULL DEFAULT 'active',

    PRIMARY KEY (campus_user_id),
    UNIQUE (email),
    CHECK (role IN (
        'student', 'lecturer', 'teaching_assistant',
        'facility_staff', 'department_admin', 'facility_manager'
    )),
    CHECK (account_status IN ('active', 'inactive', 'suspended'))
);


-- ----------------------------------------------------------------------------
-- 2. CAMPUS SPACE
-- ----------------------------------------------------------------------------
CREATE TABLE CampusSpace (
    campus_space_code NVARCHAR(20)  NOT NULL,
    space_name        NVARCHAR(100) NOT NULL,
    space_type        NVARCHAR(30)  NOT NULL,
    building          NVARCHAR(100) NOT NULL,
    floor             INT           NOT NULL,
    room_number       NVARCHAR(20)  NOT NULL,
    capacity          INT           NOT NULL,
    current_status    NVARCHAR(30)  NOT NULL DEFAULT 'available',
    usage_policy      NVARCHAR(MAX) NULL,

    PRIMARY KEY (campus_space_code),
    UNIQUE (building, floor, room_number),
    CHECK (space_type IN (
        'auditorium', 'classroom', 'computer_lab', 'meeting_room'
    )),
    CHECK (current_status IN (
        'available', 'in_use', 'under_maintenance',
        'temporarily_closed', 'retired'
    )),
    CHECK (capacity > 0)
);


-- ----------------------------------------------------------------------------
-- 3. CAMPUS FACILITY
-- ----------------------------------------------------------------------------
CREATE TABLE CampusFacility (
    campus_facility_id INT           NOT NULL IDENTITY(1,1),
    facility_name      NVARCHAR(100) NOT NULL,
    description        NVARCHAR(255) NULL,

    PRIMARY KEY (campus_facility_id),
    UNIQUE (facility_name)
);


-- ----------------------------------------------------------------------------
-- 4. CAMPUS SPACE FACILITY (Bridge Table)
-- ----------------------------------------------------------------------------
CREATE TABLE CampusSpaceFacility (
    campus_space_facility_id INT          NOT NULL IDENTITY(1,1),
    campus_space_code        NVARCHAR(20) NOT NULL,
    campus_facility_id       INT          NOT NULL,
    quantity                 INT          NOT NULL DEFAULT 1,

    PRIMARY KEY (campus_space_facility_id),
    UNIQUE (campus_space_code, campus_facility_id),
    FOREIGN KEY (campus_space_code) REFERENCES CampusSpace (campus_space_code),
    FOREIGN KEY (campus_facility_id) REFERENCES CampusFacility (campus_facility_id),
    CHECK (quantity > 0)
);


-- ----------------------------------------------------------------------------
-- 5. SPACE BOOKING
-- ----------------------------------------------------------------------------
CREATE TABLE SpaceBooking (
    space_booking_id        INT           NOT NULL IDENTITY(1,1),
    requester_id            INT           NOT NULL,
    campus_space_code       NVARCHAR(20)  NOT NULL,
    requested_start_time    DATETIME2     NOT NULL,
    requested_end_time      DATETIME2     NOT NULL,
    purpose_type            NVARCHAR(30)  NOT NULL,
    expected_participants   INT           NOT NULL,
    status                  NVARCHAR(20)  NOT NULL DEFAULT 'pending',
    submitted_at            DATETIME2     NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (space_booking_id),
    FOREIGN KEY (requester_id) REFERENCES CampusUser (campus_user_id),
    FOREIGN KEY (campus_space_code) REFERENCES CampusSpace (campus_space_code),
    CHECK (purpose_type IN (
        'lecture', 'examination', 'seminar', 'workshop',
        'meeting', 'student_activity', 'administrative_event'
    )),
    CHECK (status IN (
        'pending', 'approved', 'rejected', 'cancelled',
        'checked_in', 'completed', 'no-show'
    )),
    CHECK (expected_participants > 0),
    CHECK (requested_end_time > requested_start_time)
);


-- ----------------------------------------------------------------------------
-- 6. BOOKING APPROVAL
-- ----------------------------------------------------------------------------
CREATE TABLE BookingApproval (
    booking_approval_id INT           NOT NULL IDENTITY(1,1),
    space_booking_id    INT           NOT NULL,
    staff_id            INT           NOT NULL,
    decision            NVARCHAR(10)  NOT NULL,
    decision_time       DATETIME2     NOT NULL DEFAULT GETDATE(),
    decision_note       NVARCHAR(MAX) NULL,
    rejection_reason    NVARCHAR(MAX) NULL,

    PRIMARY KEY (booking_approval_id),
    UNIQUE (space_booking_id),
    FOREIGN KEY (space_booking_id) REFERENCES SpaceBooking (space_booking_id),
    FOREIGN KEY (staff_id) REFERENCES CampusUser (campus_user_id),
    CHECK (decision IN ('approved', 'rejected')),
    CHECK (
        (decision = 'rejected' AND rejection_reason IS NOT NULL)
        OR
        (decision = 'approved')
    )
);


-- ----------------------------------------------------------------------------
-- 7. SPACE USAGE SESSION
-- ----------------------------------------------------------------------------
CREATE TABLE SpaceUsageSession (
    space_usage_session_id INT           NOT NULL IDENTITY(1,1),
    space_booking_id       INT           NOT NULL,
    checked_in_by          INT           NOT NULL,
    actual_start_time      DATETIME2     NOT NULL,
    initial_condition      NVARCHAR(MAX) NULL,
    actual_end_time        DATETIME2     NULL,
    final_condition        NVARCHAR(MAX) NULL,
    usage_notes            NVARCHAR(MAX) NULL,

    PRIMARY KEY (space_usage_session_id),
    UNIQUE (space_booking_id),
    FOREIGN KEY (space_booking_id) REFERENCES SpaceBooking (space_booking_id),
    FOREIGN KEY (checked_in_by) REFERENCES CampusUser (campus_user_id)
);


-- ----------------------------------------------------------------------------
-- 8. SPACE MAINTENANCE
-- ----------------------------------------------------------------------------
CREATE TABLE SpaceMaintenance (
    space_maintenance_id INT           NOT NULL IDENTITY(1,1),
    campus_space_code    NVARCHAR(20)  NOT NULL,
    reporter_id          INT           NOT NULL,
    assigned_staff_id    INT           NULL,
    problem_description  NVARCHAR(MAX) NOT NULL,
    problem_type         NVARCHAR(30)  NOT NULL,
    start_time           DATETIME2     NOT NULL DEFAULT GETDATE(),
    completion_time      DATETIME2     NULL,
    status               NVARCHAR(20)  NOT NULL DEFAULT 'reported',
    result_note          NVARCHAR(MAX) NULL,

    PRIMARY KEY (space_maintenance_id),
    FOREIGN KEY (campus_space_code) REFERENCES CampusSpace (campus_space_code),
    FOREIGN KEY (reporter_id) REFERENCES CampusUser (campus_user_id),
    FOREIGN KEY (assigned_staff_id) REFERENCES CampusUser (campus_user_id),
    CHECK (problem_type IN (
        'broken_projector', 'ac_failure', 'damaged_furniture',
        'cleaning', 'network', 'other'
    )),
    CHECK (status IN ('reported', 'in_progress', 'completed', 'cancelled'))
);
