-- ============================================================================
-- Step 10 - Schema Migration: School of Computer Science Space Booking System
-- Group: G02
-- DBMS:  Microsoft SQL Server
-- Date:  2026-08-02
-- ============================================================================
--
-- OBJECTIVE
-- Create the Phase 2 database implementation (per 09-updated-erd-and-logical-design)
-- and migrate all applicable data from the Phase 1 database (per
-- 05-db-definition-G02.sql + 06-sample-data-G02.sql).
--
-- PREREQUISITE
-- The Phase 1 database "SpaceBookingDB" must exist and be populated by running:
--   1) outputs/05-db-definition-G02.sql
--   2) outputs/06-sample-data-G02.sql
-- The Phase 1 database is NEVER modified; it is only read as the migration source.
--
-- TARGET DATABASE
-- The Phase 2 schema is implemented in a NEW database: SpaceBookingDB_Phase2
-- (the source database keeps the name SpaceBookingDB so that both coexist on
-- the same server during migration). All Phase 2 artifacts that follow
-- (Steps 11-16) must run against SpaceBookingDB_Phase2.
--
-- SCRIPT CONTENTS (in order)
--   1. New database schema creation.
--   2. Constraint creation (CHECK and TRIGGER).
--   3. Data migration statements (source: SpaceBookingDB).
--   4. Data transformation statements (rename, remap, new defaults).
--   5. Default value insertion for newly introduced mandatory attributes.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. Create the new Phase 2 database (drop only the TARGET database if re-run)
-- ----------------------------------------------------------------------------
IF DB_ID(N'SpaceBookingDB') IS NULL
BEGIN
    SET NOEXEC ON;
    RAISERROR(N'Source database SpaceBookingDB was not found. Run 05-db-definition-G02.sql and 06-sample-data-G02.sql first.', 16, 1);
END
GO

IF DB_ID(N'SpaceBookingDB_Phase2') IS NOT NULL
BEGIN
    ALTER DATABASE SpaceBookingDB_Phase2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SpaceBookingDB_Phase2;
END
GO

CREATE DATABASE SpaceBookingDB_Phase2;
GO
USE SpaceBookingDB_Phase2;
GO


-- ============================================================================
-- 1. NEW DATABASE SCHEMA CREATION
-- Tables are created in dependency order (referenced tables before referencing
-- tables). Definitions follow 09-updated-erd-and-logical-design-G02.md
-- Section 4.2 (Relation Definitions).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1.1 SPACE TYPE BOOKING POLICY  (new entity, Phase 2)
--     Configuration relation keyed by space_type (09 Section 3.2, 4.2)
-- ----------------------------------------------------------------------------
CREATE TABLE SpaceTypeBookingPolicy (
    space_type              NVARCHAR(30)  NOT NULL,
    instant_booking_eligible BIT           NOT NULL DEFAULT 0,
    policy_note             NVARCHAR(MAX) NULL,

    PRIMARY KEY (space_type),
    CHECK (space_type IN ('auditorium', 'classroom', 'computer_lab', 'meeting_room')),
    CHECK (instant_booking_eligible IN (0, 1))
);
GO


-- ----------------------------------------------------------------------------
-- 1.2 CAMPUS USER  (unchanged - definition retained from Phase 1)
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
GO


-- ----------------------------------------------------------------------------
-- 1.3 CAMPUS SPACE  (modified - space_type now FK to SpaceTypeBookingPolicy)
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
    FOREIGN KEY (space_type) REFERENCES SpaceTypeBookingPolicy (space_type),
    CHECK (space_type IN (
        'auditorium', 'classroom', 'computer_lab', 'meeting_room'
    )),
    CHECK (current_status IN (
        'available', 'in_use', 'under_maintenance',
        'temporarily_closed', 'retired'
    )),
    CHECK (capacity > 0)
);
GO


-- ----------------------------------------------------------------------------
-- 1.4 CAMPUS FACILITY  (modified - facility_name renamed to facility_type)
-- ----------------------------------------------------------------------------
CREATE TABLE CampusFacility (
    campus_facility_id INT           NOT NULL IDENTITY(1,1),
    facility_type      NVARCHAR(100) NOT NULL,
    description        NVARCHAR(MAX) NULL,
    campus_space_code  NVARCHAR(20)  NULL,
    status             NVARCHAR(30)  NOT NULL DEFAULT 'available',

    PRIMARY KEY (campus_facility_id),
    UNIQUE (facility_type),
    FOREIGN KEY (campus_space_code) REFERENCES CampusSpace (campus_space_code),
    CHECK (status IN ('available', 'in_use', 'under_maintenance'))
);
GO


-- ----------------------------------------------------------------------------
-- 1.5 SEMESTER  (new entity, Phase 2 - reference relation for reporting)
-- ----------------------------------------------------------------------------
CREATE TABLE Semester (
    semester_id   INT           NOT NULL IDENTITY(1,1),
    academic_year NVARCHAR(9)   NOT NULL,
    semester_no   NVARCHAR(20)  NOT NULL,
    semester_name NVARCHAR(100) NOT NULL,
    start_date    DATE          NOT NULL,
    end_date      DATE          NOT NULL,

    PRIMARY KEY (semester_id),
    UNIQUE (academic_year, semester_no),
    CHECK (end_date > start_date)
);
GO


-- ----------------------------------------------------------------------------
-- 1.6 SPACE BOOKING  (modified - new is_instant_booking attribute)
-- ----------------------------------------------------------------------------
CREATE TABLE SpaceBooking (
    space_booking_id        INT           NOT NULL IDENTITY(1,1),
    requester_id            INT           NOT NULL,
    campus_space_code       NVARCHAR(20)  NOT NULL,
    requested_start_time    DATETIME2     NOT NULL,
    requested_end_time      DATETIME2     NOT NULL,
    purpose_type            NVARCHAR(40)  NOT NULL,
    expected_participants   INT           NOT NULL,
    status                  NVARCHAR(20)  NOT NULL DEFAULT 'pending',
    is_instant_booking      BIT           NOT NULL DEFAULT 0,
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
    CHECK (is_instant_booking IN (0, 1)),
    CHECK (expected_participants > 0),
    CHECK (requested_end_time > requested_start_time)
);
GO


-- ----------------------------------------------------------------------------
-- 1.7 BOOKING APPROVAL  (unchanged - responsible only for staff approvals)
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
GO


-- ----------------------------------------------------------------------------
-- 1.8 SPACE USAGE SESSION  (unchanged)
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
GO


-- ----------------------------------------------------------------------------
-- 1.9 SPACE MAINTENANCE  (modified - new impact_level; problem_type domain
--     reduced; maintenance interval consistency rules)
-- ----------------------------------------------------------------------------
CREATE TABLE SpaceMaintenance (
    space_maintenance_id INT           NOT NULL IDENTITY(1,1),
    campus_space_code    NVARCHAR(20)  NOT NULL,
    reporter_id          INT           NOT NULL,
    assigned_staff_id    INT           NULL,
    impact_level         NVARCHAR(20)  NOT NULL DEFAULT 'out_of_service',
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
    CHECK (impact_level IN ('out_of_service', 'advisory')),
    CHECK (problem_type IN (
        'ac_failure', 'damaged_furniture', 'cleaning', 'network', 'other'
    )),
    CHECK (status IN ('reported', 'in_progress', 'completed', 'cancelled')),
    CHECK (completion_time IS NULL OR completion_time > start_time),
    CHECK (status <> 'completed' OR completion_time IS NOT NULL),
    CHECK (status NOT IN ('reported', 'in_progress') OR completion_time IS NULL)
);
GO


-- ----------------------------------------------------------------------------
-- 1.10 FACILITY MAINTENANCE  (new entity, Phase 2)
-- ----------------------------------------------------------------------------
CREATE TABLE FacilityMaintenance (
    facility_maintenance_id INT           NOT NULL IDENTITY(1,1),
    campus_facility_id      INT           NOT NULL,
    reporter_id             INT           NOT NULL,
    assigned_staff_id       INT           NULL,
    impact_level            NVARCHAR(20)  NOT NULL DEFAULT 'advisory',
    problem_description     NVARCHAR(MAX) NOT NULL,
    start_time              DATETIME2     NOT NULL DEFAULT GETDATE(),
    completion_time         DATETIME2     NULL,
    status                  NVARCHAR(20)  NOT NULL DEFAULT 'reported',
    notify_status           NVARCHAR(40)  NOT NULL DEFAULT 'nothing_to_notify',
    result_note             NVARCHAR(MAX) NULL,

    PRIMARY KEY (facility_maintenance_id),
    FOREIGN KEY (campus_facility_id) REFERENCES CampusFacility (campus_facility_id),
    FOREIGN KEY (reporter_id) REFERENCES CampusUser (campus_user_id),
    FOREIGN KEY (assigned_staff_id) REFERENCES CampusUser (campus_user_id),
    CHECK (impact_level IN ('out_of_service', 'advisory')),
    CHECK (status IN ('reported', 'in_progress', 'completed', 'cancelled')),
    CHECK (notify_status IN (
        'nothing_to_notify', 'updated_to_advisory', 'updated_to_out_of_service'
    )),
    CHECK (completion_time IS NULL OR completion_time > start_time),
    CHECK (status <> 'completed' OR completion_time IS NOT NULL),
    CHECK (status NOT IN ('reported', 'in_progress') OR completion_time IS NULL)
);
GO


-- ============================================================================
-- 2. CONSTRAINT CREATION - TRIGGERS
-- (CHECK constraints are declared inline above, per the updated design.)
--
-- Scope decision (09 Section 4.3, Section 5, Section 6):
--   * BR-03 (status transitions) and BR-07 (capacity) are trigger-enforceable
--     and are created here.
--   * BR-01/BR-12 (overlap invariant) and BR-02/BR-09 (maintenance blocking)
--     are explicitly deferred to the concurrency implementation (Steps 11-13)
--     and are intentionally NOT created in this migration.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TRG-02: Validate booking status transitions (BR-03)
-- INSERT rule extended for Phase 2 (BR-11):
--   staff workflow -> status must be 'pending'
--   instant booking -> status must be 'approved' at submission
-- UPDATE flow (unchanged): pending -> approved/rejected/cancelled
--                           approved -> checked_in
--                           checked_in -> completed/no-show
-- Trigger Type: AFTER INSERT, UPDATE
-- On: SpaceBooking
-- ----------------------------------------------------------------------------
GO
CREATE TRIGGER trg_SpaceBooking_StatusTransition
ON SpaceBooking
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT check: staff bookings enter as 'pending'; instant bookings as 'approved'
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE NOT EXISTS (SELECT 1 FROM deleted)
          AND NOT (
                (i.status = 'pending'   AND i.is_instant_booking = 0)
             OR (i.status = 'approved'  AND i.is_instant_booking = 1)
              )
    )
    BEGIN
        RAISERROR('BR-03 violation: New booking status must be ''pending'' (staff workflow) or ''approved'' (instant booking).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- UPDATE check: validate status transition
    IF UPDATE(status)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN deleted d ON i.space_booking_id = d.space_booking_id
            WHERE i.status <> d.status
              AND NOT (
                  (d.status = 'pending' AND i.status IN ('approved', 'rejected', 'cancelled'))
                  OR
                  (d.status = 'approved' AND i.status = 'checked_in')
                  OR
                  (d.status = 'checked_in' AND i.status IN ('completed', 'no-show'))
              )
        )
        BEGIN
            RAISERROR('BR-03 violation: Invalid booking status transition.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
    END;
END;
GO


-- ----------------------------------------------------------------------------
-- TRG-03: Prevent expected_participants exceeding space capacity (BR-07)
-- Trigger Type: AFTER INSERT, UPDATE
-- On: SpaceBooking
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_SpaceBooking_CapacityCheck
ON SpaceBooking
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN CampusSpace cs ON i.campus_space_code = cs.campus_space_code
        WHERE i.expected_participants > cs.capacity
    )
    BEGIN
        RAISERROR('BR-07 violation: Expected participants exceed space capacity.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO


-- ----------------------------------------------------------------------------
-- TRG-04: Auto-update CampusSpace.current_status on maintenance changes
-- Refined for Phase 2 impact levels: only active maintenance with
-- impact_level = 'out_of_service' marks the space as 'under_maintenance';
-- advisory maintenance does not make the space unavailable.
-- CampusSpace.current_status remains a convenience attribute (09 Section 3.2);
-- booking availability is derived from maintenance intervals.
-- Trigger Type: AFTER INSERT, UPDATE
-- On: SpaceMaintenance
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_SpaceMaintenance_UpdateSpaceStatus
ON SpaceMaintenance
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Active out-of-service maintenance => space under maintenance
    UPDATE cs
    SET current_status = 'under_maintenance'
    FROM CampusSpace cs
    JOIN inserted i ON cs.campus_space_code = i.campus_space_code
    WHERE i.status IN ('reported', 'in_progress')
      AND i.impact_level = 'out_of_service'
      AND cs.current_status NOT IN ('temporarily_closed', 'retired');

    -- Restore the space when no active out-of-service maintenance remains
    UPDATE cs
    SET current_status = 'available'
    FROM CampusSpace cs
    JOIN inserted i ON cs.campus_space_code = i.campus_space_code
    WHERE cs.current_status = 'under_maintenance'
      AND NOT EXISTS (
          SELECT 1
          FROM SpaceMaintenance sm
          WHERE sm.campus_space_code = i.campus_space_code
            AND sm.status IN ('reported', 'in_progress')
            AND sm.impact_level = 'out_of_service'
      );
END;
GO


-- ============================================================================
-- 3. DATA MIGRATION
-- Source:  SpaceBookingDB (Phase 1)   Target: SpaceBookingDB_Phase2
-- The triggers created above are disabled for the duration of the migration so
-- that historical records can be inserted with their original final statuses
-- (the Phase 1 sample data achieved the same result through explicit UPDATE
-- transitions). Triggers are re-enabled after migration completes.
-- ============================================================================

-- Disable migration-sensitive triggers
ALTER TABLE SpaceBooking    DISABLE TRIGGER trg_SpaceBooking_StatusTransition;
ALTER TABLE SpaceBooking    DISABLE TRIGGER trg_SpaceBooking_CapacityCheck;
ALTER TABLE SpaceMaintenance DISABLE TRIGGER trg_SpaceMaintenance_UpdateSpaceStatus;
GO


-- ----------------------------------------------------------------------------
-- 3.1 Seed SPACE TYPE BOOKING POLICY (newly introduced configuration entity)
--     instant_booking_eligible defaults to 0 (staff approval) until the
--     Facility Manager enables it (09 Section 3.2, Section 10).
-- ----------------------------------------------------------------------------
INSERT INTO SpaceTypeBookingPolicy (space_type, instant_booking_eligible, policy_note)
VALUES
    (N'auditorium',     0, N'Instant booking disabled by default. Staff approval workflow applies until the Facility Manager opts in.'),
    (N'classroom',      0, N'Instant booking disabled by default. Staff approval workflow applies until the Facility Manager opts in.'),
    (N'computer_lab',   0, N'Instant booking disabled by default. Staff approval workflow applies until the Facility Manager opts in.'),
    (N'meeting_room',   0, N'Instant booking disabled by default. Staff approval workflow applies until the Facility Manager opts in.');
GO


-- ----------------------------------------------------------------------------
-- 3.2 Seed SEMESTER (newly introduced reference relation)
--     Three academic years covering the sample booking window
--     (sample bookings fall inside 2025-2026 semester 3).
-- ----------------------------------------------------------------------------
INSERT INTO Semester (academic_year, semester_no, semester_name, start_date, end_date)
VALUES
    (N'2024-2025', N'1', N'Semester 1 - 2024/2025',        '2024-09-02', '2024-12-28'),
    (N'2024-2025', N'2', N'Semester 2 - 2024/2025',        '2025-01-06', '2025-05-31'),
    (N'2024-2025', N'3', N'Summer Semester - 2024/2025',   '2025-06-02', '2025-08-30'),
    (N'2025-2026', N'1', N'Semester 1 - 2025/2026',        '2025-09-01', '2025-12-27'),
    (N'2025-2026', N'2', N'Semester 2 - 2025/2026',        '2026-01-05', '2026-05-30'),
    (N'2025-2026', N'3', N'Summer Semester - 2025/2026',   '2026-06-01', '2026-08-29'),
    (N'2026-2027', N'1', N'Semester 1 - 2026/2027',        '2026-09-07', '2026-12-26'),
    (N'2026-2027', N'2', N'Semester 2 - 2026/2027',        '2027-01-04', '2027-05-29'),
    (N'2026-2027', N'3', N'Summer Semester - 2026/2027',   '2027-06-01', '2027-08-28');
GO


-- ----------------------------------------------------------------------------
-- 3.3 CAMPUS USER  (unchanged - preserve all rows and primary keys)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT CampusUser ON;
GO
INSERT INTO CampusUser (campus_user_id, full_name, email, phone, role, department, account_status)
SELECT campus_user_id, full_name, email, phone, role, department, account_status
FROM SpaceBookingDB.dbo.CampusUser;
GO
SET IDENTITY_INSERT CampusUser OFF;
GO


-- ----------------------------------------------------------------------------
-- 3.4 CAMPUS SPACE  (modified - space_type values unchanged, FK satisfied by
--     the SpaceTypeBookingPolicy seed above)
-- ----------------------------------------------------------------------------
INSERT INTO CampusSpace (campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
SELECT campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy
FROM SpaceBookingDB.dbo.CampusSpace;
GO


-- ----------------------------------------------------------------------------
-- 3.5 CAMPUS FACILITY  (TRANSFORM - attribute rename facility_name -> facility_type)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT CampusFacility ON;
GO
INSERT INTO CampusFacility (campus_facility_id, facility_type, description, campus_space_code, status)
SELECT campus_facility_id,
       facility_name,               -- renamed to facility_type in the new schema
       description,
       campus_space_code,
       status
FROM SpaceBookingDB.dbo.CampusFacility;
GO
SET IDENTITY_INSERT CampusFacility OFF;
GO


-- ----------------------------------------------------------------------------
-- 3.6 SPACE BOOKING  (TRANSFORM - new mandatory attribute is_instant_booking
--     defaulted to 0: every Phase 1 booking used the staff workflow; there was
--     no instant-booking path in Phase 1)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT SpaceBooking ON;
GO
INSERT INTO SpaceBooking (space_booking_id, requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status, is_instant_booking, submitted_at)
SELECT space_booking_id,
       requester_id,
       campus_space_code,
       requested_start_time,
       requested_end_time,
       purpose_type,
       expected_participants,
       status,
       CAST(0 AS BIT),              -- new mandatory attribute default (staff workflow)
       submitted_at
FROM SpaceBookingDB.dbo.SpaceBooking;
GO
SET IDENTITY_INSERT SpaceBooking OFF;
GO


-- ----------------------------------------------------------------------------
-- 3.7 BOOKING APPROVAL  (unchanged)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT BookingApproval ON;
GO
INSERT INTO BookingApproval (booking_approval_id, space_booking_id, staff_id, decision, decision_time, decision_note, rejection_reason)
SELECT booking_approval_id, space_booking_id, staff_id, decision, decision_time, decision_note, rejection_reason
FROM SpaceBookingDB.dbo.BookingApproval;
GO
SET IDENTITY_INSERT BookingApproval OFF;
GO


-- ----------------------------------------------------------------------------
-- 3.8 SPACE USAGE SESSION  (unchanged)
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT SpaceUsageSession ON;
GO
INSERT INTO SpaceUsageSession (space_usage_session_id, space_booking_id, checked_in_by, actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes)
SELECT space_usage_session_id, space_booking_id, checked_in_by, actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes
FROM SpaceBookingDB.dbo.SpaceUsageSession;
GO
SET IDENTITY_INSERT SpaceUsageSession OFF;
GO


-- ----------------------------------------------------------------------------
-- 3.9 SPACE MAINTENANCE  (TRANSFORMS - see 10-schema-migration-G02.md Section 6)
--     * impact_level  : new mandatory attribute default 'out_of_service'
--                       (Phase 1 behaviour: maintenance blocked booking)
--     * problem_type  : 'broken_projector' removed from the allowed domain in
--                       Phase 2; remapped to 'other'
-- ----------------------------------------------------------------------------
SET IDENTITY_INSERT SpaceMaintenance ON;
GO
INSERT INTO SpaceMaintenance (space_maintenance_id, campus_space_code, reporter_id, assigned_staff_id, impact_level, problem_description, problem_type, start_time, completion_time, status, result_note)
SELECT space_maintenance_id,
       campus_space_code,
       reporter_id,
       assigned_staff_id,
       N'out_of_service',                    -- new mandatory attribute default
       problem_description,
       CASE WHEN problem_type = N'broken_projector' THEN N'other' ELSE problem_type END,
       start_time,
       completion_time,
       status,
       result_note
FROM SpaceBookingDB.dbo.SpaceMaintenance;
GO
SET IDENTITY_INSERT SpaceMaintenance OFF;
GO


-- ----------------------------------------------------------------------------
-- 3.10 FACILITY MAINTENANCE  (new entity - NO Phase 1 data exists)
--     The Phase 1 database had no facility-level maintenance records, so the
--     table is intentionally created empty. Its new mandatory attributes
--     (impact_level DEFAULT 'advisory', notify_status DEFAULT 'nothing_to_notify',
--     status DEFAULT 'reported') are covered by the column defaults above.
-- ----------------------------------------------------------------------------

-- Re-enable migration-sensitive triggers
ALTER TABLE SpaceMaintenance ENABLE TRIGGER trg_SpaceMaintenance_UpdateSpaceStatus;
ALTER TABLE SpaceBooking    ENABLE TRIGGER trg_SpaceBooking_CapacityCheck;
ALTER TABLE SpaceBooking    ENABLE TRIGGER trg_SpaceBooking_StatusTransition;
GO


-- ============================================================================
-- 4. DATA INTEGRITY VALIDATION
-- Post-migration verification queries. Expected results:
--   SpaceTypeBookingPolicy  4 rows        CampusUser            8 rows
--   CampusSpace             8 rows        CampusFacility        6 rows
--   SpaceBooking           10 rows        BookingApproval       6 rows
--   SpaceUsageSession       4 rows        SpaceMaintenance      6 rows
--   FacilityMaintenance     0 rows        Semester              9 rows
-- ============================================================================
SELECT N'SpaceTypeBookingPolicy' AS table_name, COUNT(*) AS row_count FROM SpaceTypeBookingPolicy
UNION ALL SELECT N'CampusUser',               COUNT(*) FROM CampusUser
UNION ALL SELECT N'CampusSpace',              COUNT(*) FROM CampusSpace
UNION ALL SELECT N'CampusFacility',           COUNT(*) FROM CampusFacility
UNION ALL SELECT N'Semester',                 COUNT(*) FROM Semester
UNION ALL SELECT N'SpaceBooking',             COUNT(*) FROM SpaceBooking
UNION ALL SELECT N'BookingApproval',          COUNT(*) FROM BookingApproval
UNION ALL SELECT N'SpaceUsageSession',        COUNT(*) FROM SpaceUsageSession
UNION ALL SELECT N'SpaceMaintenance',         COUNT(*) FROM SpaceMaintenance
UNION ALL SELECT N'FacilityMaintenance',      COUNT(*) FROM FacilityMaintenance;
GO

-- Every campus space must reference an existing space-type policy
SELECT cs.campus_space_code
FROM CampusSpace cs
LEFT JOIN SpaceTypeBookingPolicy p ON cs.space_type = p.space_type
WHERE p.space_type IS NULL;
GO

-- No orphaned foreign keys: migrated bookings / approvals / sessions / maintenance
SELECT space_booking_id FROM SpaceBooking s
WHERE NOT EXISTS (SELECT 1 FROM CampusUser u WHERE u.campus_user_id = s.requester_id)
   OR NOT EXISTS (SELECT 1 FROM CampusSpace cs WHERE cs.campus_space_code = s.campus_space_code);
GO
SELECT booking_approval_id FROM BookingApproval a
WHERE NOT EXISTS (SELECT 1 FROM SpaceBooking s WHERE s.space_booking_id = a.space_booking_id)
   OR NOT EXISTS (SELECT 1 FROM CampusUser u WHERE u.campus_user_id = a.staff_id);
GO
SELECT space_usage_session_id FROM SpaceUsageSession ses
WHERE NOT EXISTS (SELECT 1 FROM SpaceBooking s WHERE s.space_booking_id = ses.space_booking_id)
   OR NOT EXISTS (SELECT 1 FROM CampusUser u WHERE u.campus_user_id = ses.checked_in_by);
GO
SELECT space_maintenance_id FROM SpaceMaintenance m
WHERE NOT EXISTS (SELECT 1 FROM CampusSpace cs WHERE cs.campus_space_code = m.campus_space_code)
   OR NOT EXISTS (SELECT 1 FROM CampusUser u WHERE u.campus_user_id = m.reporter_id)
   OR (m.assigned_staff_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CampusUser u WHERE u.campus_user_id = m.assigned_staff_id));
GO

-- No leftover legacy problem_type values after the transformation
SELECT space_maintenance_id, problem_type
FROM SpaceMaintenance
WHERE problem_type NOT IN ('ac_failure', 'damaged_furniture', 'cleaning', 'network', 'other');
GO

-- Duplicate primary keys / unique keys must not be introduced
SELECT campus_user_id FROM CampusUser GROUP BY campus_user_id HAVING COUNT(*) > 1;
GO
SELECT space_booking_id FROM SpaceBooking GROUP BY space_booking_id HAVING COUNT(*) > 1;
GO
SELECT email FROM CampusUser GROUP BY email HAVING COUNT(*) > 1;
GO
SELECT facility_type FROM CampusFacility GROUP BY facility_type HAVING COUNT(*) > 1;
GO
SELECT academic_year, semester_no FROM Semester GROUP BY academic_year, semester_no HAVING COUNT(*) > 1;
GO

PRINT 'Schema migration to SpaceBookingDB_Phase2 completed successfully.';
GO
