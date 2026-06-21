-- ============================================================
-- Step 5: Database Implementation
-- School Shared Space Booking System
-- Group: G02
-- DBMS: Microsoft SQL Server
-- Based on: 03-logical-design-G02.md, 04-design-validation-G02.md
-- ============================================================

-- ============================================================
-- 1. Create Database
-- ============================================================
CREATE DATABASE SpaceBookingDB;
GO

-- ============================================================
-- 2. Go to the Newly Created Database
-- ============================================================
USE SpaceBookingDB;
GO

-- ============================================================
-- 3. Create Primary Tables (no foreign keys)
-- ============================================================

-- 3.1. Users
CREATE TABLE Users (
    user_id            VARCHAR(20)     NOT NULL,
    full_name          NVARCHAR(100)   NOT NULL,
    email              VARCHAR(255)    NOT NULL,
    phone_number       VARCHAR(20)     NOT NULL,
    role               VARCHAR(30)     NOT NULL,
    department         NVARCHAR(100)   NOT NULL,
    account_status     VARCHAR(20)     NOT NULL,

    PRIMARY KEY (user_id),
    UNIQUE (email),
    CHECK (role IN (
        'student',
        'lecturer',
        'teaching_assistant',
        'facility_staff',
        'department_administrator',
        'facility_manager'
    )),
    CHECK (account_status IN (
        'active',
        'inactive',
        'suspended'
    ))
);

-- 3.2. Space
CREATE TABLE Space (
    space_code         VARCHAR(20)     NOT NULL,
    space_name         NVARCHAR(100)   NOT NULL,
    space_type         VARCHAR(30)     NOT NULL,
    building           NVARCHAR(100)   NOT NULL,
    floor              INT             NOT NULL,
    room_number        VARCHAR(20)     NOT NULL,
    capacity           INT             NOT NULL,
    current_status     VARCHAR(30)     NOT NULL,
    usage_policy       NVARCHAR(500)   NULL,

    PRIMARY KEY (space_code),
    CHECK (space_type IN (
        'auditorium',
        'classroom',
        'computer_laboratory',
        'project_laboratory',
        'meeting_room',
        'student_workspace'
    )),
    CHECK (current_status IN (
        'available',
        'in_use',
        'under_maintenance',
        'temporarily_closed',
        'retired'
    )),
    CHECK (capacity > 0)
);

-- 3.3. Facility
CREATE TABLE Facility (
    facility_id        VARCHAR(20)     NOT NULL,
    facility_name      VARCHAR(100)    NOT NULL,
    description        NVARCHAR(500)   NULL,

    PRIMARY KEY (facility_id),
    CHECK (facility_name IN (
        'projector',
        'whiteboard',
        'microphone',
        'computer',
        'livestreaming_equipment',
        'air_conditioner'
    ))
);

-- ============================================================
-- 4. Create Tables with Foreign Keys
-- ============================================================

-- 4.1. SpaceFacility (junction table for M:N Space-Facility)
CREATE TABLE SpaceFacility (
    space_code         VARCHAR(20)     NOT NULL,
    facility_id        VARCHAR(20)     NOT NULL,
    quantity           INT             NOT NULL,

    PRIMARY KEY (space_code, facility_id),
    CHECK (quantity > 0)
);

-- 4.2. BookingRequest
CREATE TABLE BookingRequest (
    booking_id               VARCHAR(20)     NOT NULL,
    space_code               VARCHAR(20)     NOT NULL,
    requester_id             VARCHAR(20)     NOT NULL,
    requested_start_time     DATETIME        NOT NULL,
    requested_end_time       DATETIME        NOT NULL,
    purpose                  VARCHAR(30)     NOT NULL,
    expected_participants    INT             NOT NULL,
    booking_status           VARCHAR(20)     NOT NULL,
    approver_id              VARCHAR(20)     NULL,
    decision_time            DATETIME        NULL,
    decision_note            NVARCHAR(500)   NULL,
    rejection_reason         NVARCHAR(500)   NULL,
    actual_start_time        DATETIME        NULL,
    checked_in_by            VARCHAR(20)     NULL,
    initial_condition        NVARCHAR(500)   NULL,
    actual_end_time          DATETIME        NULL,
    completed_by             VARCHAR(20)     NULL,
    final_condition          NVARCHAR(500)   NULL,
    usage_notes              NVARCHAR(500)   NULL,

    PRIMARY KEY (booking_id),
    CHECK (purpose IN (
        'lecture',
        'examination',
        'seminar',
        'workshop',
        'meeting',
        'student_activity',
        'administrative_event'
    )),
    CHECK (booking_status IN (
        'pending',
        'approved',
        'rejected',
        'cancelled',
        'checked_in',
        'completed',
        'no_show'
    )),
    CHECK (requested_end_time > requested_start_time),
    CHECK (expected_participants > 0),
    CHECK (
        (booking_status = 'rejected' AND rejection_reason IS NOT NULL)
        OR
        (booking_status <> 'rejected' AND rejection_reason IS NULL)
    )
);

-- 4.3. MaintenanceRecord
CREATE TABLE MaintenanceRecord (
    maintenance_id       VARCHAR(20)     NOT NULL,
    space_code           VARCHAR(20)     NOT NULL,
    reporter_id          VARCHAR(20)     NOT NULL,
    assigned_staff_id    VARCHAR(20)     NULL,
    problem_description  NVARCHAR(1000)  NOT NULL,
    problem_type         VARCHAR(30)     NOT NULL,
    start_time           DATETIME        NOT NULL,
    completion_time      DATETIME        NULL,
    status               VARCHAR(20)     NOT NULL,
    result_note          NVARCHAR(500)   NULL,

    PRIMARY KEY (maintenance_id),
    CHECK (problem_type IN (
        'broken_projector',
        'air_conditioning_failure',
        'damaged_furniture',
        'cleaning_issue',
        'network_problem'
    )),
    CHECK (status IN (
        'reported',
        'in_progress',
        'completed',
        'cancelled'
    )),
    CHECK (
        (status = 'completed' AND completion_time IS NOT NULL AND result_note IS NOT NULL)
        OR
        (status <> 'completed')
    )
);

-- ============================================================
-- 5. Add Foreign Key Constraints
-- ============================================================

-- 5.1. SpaceFacility foreign keys
ALTER TABLE SpaceFacility ADD FOREIGN KEY (space_code) REFERENCES Space(space_code);
ALTER TABLE SpaceFacility ADD FOREIGN KEY (facility_id) REFERENCES Facility(facility_id);

-- 5.2. BookingRequest foreign keys
ALTER TABLE BookingRequest ADD FOREIGN KEY (space_code) REFERENCES Space(space_code);
ALTER TABLE BookingRequest ADD FOREIGN KEY (requester_id) REFERENCES Users(user_id);
ALTER TABLE BookingRequest ADD FOREIGN KEY (approver_id) REFERENCES Users(user_id);
ALTER TABLE BookingRequest ADD FOREIGN KEY (checked_in_by) REFERENCES Users(user_id);
ALTER TABLE BookingRequest ADD FOREIGN KEY (completed_by) REFERENCES Users(user_id);

-- 5.3. MaintenanceRecord foreign keys
ALTER TABLE MaintenanceRecord ADD FOREIGN KEY (space_code) REFERENCES Space(space_code);
ALTER TABLE MaintenanceRecord ADD FOREIGN KEY (reporter_id) REFERENCES Users(user_id);
ALTER TABLE MaintenanceRecord ADD FOREIGN KEY (assigned_staff_id) REFERENCES Users(user_id);

GO

-- ============================================================
-- 6. Triggers for Business Rule Enforcement
-- ============================================================

-- 6.1. BR-14: Prevent new approved bookings for a space under maintenance
CREATE TRIGGER TR_BookingRequest_PreventMaintenanceBooking
ON BookingRequest
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN Space s ON i.space_code = s.space_code
        WHERE i.booking_status = 'approved' 
          AND s.current_status = 'under_maintenance'
    )
    BEGIN
        RAISERROR ('Cannot book or approve a booking for a space that is under maintenance (BR-14).', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
