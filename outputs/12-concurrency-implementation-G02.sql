-- ============================================================================
-- Step 12 - Concurrency Implementation
-- School of Computer Science Space Booking System
-- Group: G02
-- DBMS:  Microsoft SQL Server
-- Target Database: SpaceBookingDB_Phase2
-- ============================================================================
--
-- IMPLEMENTS: 11-concurrency-design-G02.md (Step 11, Sections 3 and 4)
--   * Procedure 1: sp_SubmitSpaceBooking       (11 Section 4.1)
--   * Procedure 2: sp_ApproveSpaceBooking      (11 Section 4.2)
--   * Procedure 3: sp_EscalateSpaceMaintenance (11 Section 4.3)
--
-- TARGET SCHEMA: 10-schema-migration-G02.sql (SpaceBookingDB_Phase2).
-- This script runs ON TOP of the migrated schema. It does not modify any
-- base table, drop any existing object, or bypass the triggers and CHECK
-- constraints created by the migration.
--
-- CONCURRENCY MODEL (11 Section 3.2):
--   * Exclusive application lock per campus space: sp_getapplock on
--     resource N'Lock_Space_' + @campus_space_code, lock owner 'Transaction',
--     timeout 5000 ms. Serializes all write workflows per space while
--     operations on different spaces run in parallel. All availability and
--     overlap re-checks reuse the shared function fn_IsSpaceAvailable
--     (10-schema-migration-G02.sql) inside the locked section.
--   * Key-range update lock hint WITH (UPDLOCK, HOLDLOCK) on the affected
--     SpaceBooking read inside sp_EscalateSpaceMaintenance (BR-14 outreach).
--
-- PREREQUISITES: run in order
--   1) 05-db-definition-G02.sql  (Phase 1 database SpaceBookingDB)
--   2) 06-sample-data-G02.sql    (Phase 1 sample data)
--   3) 10-schema-migration-G02.sql (creates and populates SpaceBookingDB_Phase2)
-- Then execute this script against SpaceBookingDB_Phase2 to create the
-- three procedures. The script is idempotent.
--
-- HOW TO EXECUTE EACH PROCEDURE: worked examples with real sample data are
-- given in 12-concurrency-implementation-G02.md Section 5.2.
--
-- Testing and expected outcomes are covered by Step 13 (test scripts).
-- ============================================================================

USE [SpaceBookingDB_Phase2];
GO

-- ============================================================================
-- PROCEDURE 1: sp_SubmitSpaceBooking
-- Design source: 11-concurrency-design-G02.md Section 4.1 (Booking Submission)
-- Enforces: BR-01, BR-02, BR-07, BR-09, BR-11, BR-12, BR-13
-- ============================================================================
IF OBJECT_ID(N'dbo.sp_SubmitSpaceBooking', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SubmitSpaceBooking;
GO
CREATE PROCEDURE dbo.sp_SubmitSpaceBooking
    @requester_id          INT,
    @campus_space_code     NVARCHAR(20),
    @requested_start_time  DATETIME2,
    @requested_end_time    DATETIME2,
    @purpose_type          NVARCHAR(40),
    @expected_participants INT,
    @space_booking_id      INT            OUTPUT,
    @result_status         NVARCHAR(20)   OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- ------------------------------------------------------------------
    -- Input sanity checks (mirror the schema CHECK constraints so the
    -- caller receives a clean error before the transaction starts).
    -- ------------------------------------------------------------------
    IF @expected_participants IS NULL OR @expected_participants <= 0
        THROW 50001, N'Invalid input: expected_participants must be greater than 0.', 1;
    IF @requested_start_time IS NULL OR @requested_end_time IS NULL
        OR @requested_end_time <= @requested_start_time
        THROW 50002, N'Invalid input: requested_end_time must be after requested_start_time.', 1;

    DECLARE @space_type      NVARCHAR(30);
    DECLARE @lock_resource   NVARCHAR(255) = N'Lock_Space_' + @campus_space_code;
    DECLARE @lock_result     INT;
    DECLARE @instant_eligible BIT;
    DECLARE @status          NVARCHAR(20);
    DECLARE @is_instant      BIT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Acquire the exclusive application lock on the parent resource
        --    (11 Section 3.3 lock-ordering rule: lock the space before any
        --    child rows). Lock is released on COMMIT/ROLLBACK.
        EXEC @lock_result = sp_getapplock
            @Resource   = @lock_resource,
            @LockMode   = 'Exclusive',
            @LockOwner  = 'Transaction',
            @LockTimeout = 5000;
        IF @lock_result < 0
            THROW 50003, N'System busy: another operation holds the lock on this space. Please retry.', 1;

        -- 2. Space-type lookup (BR-11). 
        SELECT @space_type = cs.space_type
        FROM CampusSpace AS cs
        WHERE cs.campus_space_code = @campus_space_code;

        IF @space_type IS NULL
            THROW 50004, N'Space does not exist.', 1;

        -- 3. Display set of available facilities for the space (BR-13).

        SELECT cf.campus_facility_id,
               cf.facility_type,
               cf.description,
               cf.status
        FROM CampusFacility AS cf
        WHERE cf.campus_space_code = @campus_space_code
          AND cf.status = N'available';

        -- 4. Overlap / availability guard (BR-01 / BR-12, BR-02 / BR-09):
        IF dbo.fn_IsSpaceAvailable(
			   @campus_space_code,
			   @requested_start_time,
			   @requested_end_time,
			   NULL
		   ) = 0
			THROW 50008,
				  N'BR-01/BR-12 violation: the requested period conflicts with an existing booking or the space is unavailable.',
				  1;

        -- 5. Policy lookup (BR-11): decide instant vs staff approval.
        SELECT @instant_eligible = p.instant_booking_eligible
        FROM SpaceTypeBookingPolicy AS p
        WHERE p.space_type = @space_type;

        IF @instant_eligible IS NULL
            THROW 50009, N'BR-11 violation: no instant-booking policy is configured for this space type.', 1;

        IF @instant_eligible = 1
        BEGIN
            SET @status     = N'approved';
            SET @is_instant = 1;
        END
        ELSE
        BEGIN
            SET @status     = N'pending';
            SET @is_instant = 0;
        END;

        -- 6. Insert the booking. 
        INSERT INTO SpaceBooking
        (
            requester_id,
            campus_space_code,
            requested_start_time,
            requested_end_time,
            purpose_type,
            expected_participants,
            status,
            is_instant_booking,
            advisory_acknowledged
        )
        VALUES
        (
            @requester_id,
            @campus_space_code,
            @requested_start_time,
            @requested_end_time,
            @purpose_type,
            @expected_participants,
            @status,
            @is_instant,
            1
        );

        SET @space_booking_id = SCOPE_IDENTITY();
        SET @result_status    = @status;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- PROCEDURE 2: sp_ApproveSpaceBooking
-- Design source: 11-concurrency-design-G02.md Section 4.2 (Staff Approval)
-- Enforces: BR-01, BR-02, BR-03, BR-04, BR-05, BR-09, BR-12
-- ============================================================================
IF OBJECT_ID(N'dbo.sp_ApproveSpaceBooking', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ApproveSpaceBooking;
GO
CREATE PROCEDURE dbo.sp_ApproveSpaceBooking
    @space_booking_id INT,
    @staff_id         INT,
    @decision         NVARCHAR(10),
    @decision_note    NVARCHAR(MAX) = NULL,
    @rejection_reason NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @campus_space_code     NVARCHAR(20);
    DECLARE @current_status        NVARCHAR(20);
    DECLARE @requested_start_time  DATETIME2;
    DECLARE @requested_end_time    DATETIME2;
    DECLARE @staff_role            NVARCHAR(30);
    DECLARE @lock_resource         NVARCHAR(255);
    DECLARE @lock_result           INT;

    -- ------------------------------------------------------------------
    -- Pre-lock validation.
    -- ------------------------------------------------------------------
    SELECT @staff_role = role
    FROM CampusUser
    WHERE campus_user_id = @staff_id;

    IF @staff_role IS NULL
        THROW 50010, N'Staff user does not exist.', 1;
    IF @staff_role NOT IN (N'facility_staff', N'facility_manager')
        THROW 50011, N'BR-05 violation: only facility staff or facility manager may approve bookings.', 1;

    SELECT @campus_space_code    = campus_space_code,
           @current_status       = status,
           @requested_start_time = requested_start_time,
           @requested_end_time   = requested_end_time
    FROM SpaceBooking
    WHERE space_booking_id = @space_booking_id;

    IF @campus_space_code IS NULL
        THROW 50012, N'Booking does not exist.', 1;
    IF @current_status <> N'pending'
        THROW 50013, N'BR-03 violation: only pending bookings may be approved or rejected.', 1;
    IF @decision NOT IN (N'approved', N'rejected')
        THROW 50014, N'Invalid input: decision must be ''approved'' or ''rejected''.', 1;
    IF @decision = N'rejected'
        AND (@rejection_reason IS NULL OR LTRIM(RTRIM(@rejection_reason)) = N'')
        THROW 50015, N'BR-04 violation: rejection_reason is required when a booking is rejected.', 1;

    SET @lock_resource = N'Lock_Space_' + @campus_space_code;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Acquire the exclusive application lock on the parent resource
        --    (11 Section 4.2 step 4).
        EXEC @lock_result = sp_getapplock
            @Resource    = @lock_resource,
            @LockMode    = 'Exclusive',
            @LockOwner   = 'Transaction',
            @LockTimeout = 5000;
        IF @lock_result < 0
            THROW 50016, N'System busy: another operation holds the lock on this space. Please retry.', 1;

        IF @decision = N'approved'
        BEGIN
            -- 2. Availability re-check (BR-02 / BR-09, BR-01 / BR-12):
            IF dbo.fn_IsSpaceAvailable(
                   @campus_space_code,
                   @requested_start_time,
                   @requested_end_time,
                   @space_booking_id
               ) = 0
                THROW 50017, N'BR-02/BR-09 violation: the space is unavailable for the requested period (closed/retired, out-of-service maintenance, or an overlapping approved booking).', 1;

            -- 3. Record the staff decision. 
            INSERT INTO BookingApproval
            (
                space_booking_id,
                staff_id,
                decision,
                decision_note
            )
            VALUES
            (
                @space_booking_id,
                @staff_id,
                N'approved',
                @decision_note
            );
        END
        ELSE
        BEGIN
            INSERT INTO BookingApproval
            (
                space_booking_id,
                staff_id,
                decision,
                decision_note,
                rejection_reason
            )
            VALUES
            (
                @space_booking_id,
                @staff_id,
                N'rejected',
                @decision_note,
                @rejection_reason
            );
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- PROCEDURE 3: sp_EscalateSpaceMaintenance
-- Design source: 11-concurrency-design-G02.md Section 4.3 (Escalation)
-- Enforces: BR-02, BR-09, BR-14
-- Note: @new_impact_level defaults to 'out_of_service' (escalation) and
-- also supports the Phase 2 downgrade direction ('advisory').
-- ============================================================================
IF OBJECT_ID(N'dbo.sp_EscalateSpaceMaintenance', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_EscalateSpaceMaintenance;
GO
CREATE PROCEDURE dbo.sp_EscalateSpaceMaintenance
    @space_maintenance_id INT,
    @staff_id             INT,
    @new_impact_level     NVARCHAR(20) = N'out_of_service',
    @affected_count       INT          OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @campus_space_code  NVARCHAR(20);
    DECLARE @current_impact     NVARCHAR(20);
    DECLARE @maint_status       NVARCHAR(20);
    DECLARE @start_time         DATETIME2;
    DECLARE @completion_time    DATETIME2;
    DECLARE @maint_end          DATETIME2;
    DECLARE @staff_role         NVARCHAR(30);
    DECLARE @lock_resource      NVARCHAR(255);
    DECLARE @lock_result        INT;

    -- ------------------------------------------------------------------
    -- Pre-lock validation.
    -- ------------------------------------------------------------------
    IF @new_impact_level NOT IN (N'out_of_service', N'advisory')
        THROW 50019, N'Invalid input: impact_level must be ''out_of_service'' or ''advisory''.', 1;

    SELECT @campus_space_code = campus_space_code,
           @current_impact    = impact_level,
           @maint_status      = status,
           @start_time        = start_time,
           @completion_time   = completion_time
    FROM SpaceMaintenance
    WHERE space_maintenance_id = @space_maintenance_id;

    IF @campus_space_code IS NULL
        THROW 50020, N'Maintenance record does not exist.', 1;
    IF @maint_status NOT IN (N'reported', N'in_progress')
        THROW 50021, N'BR-02/BR-09 violation: only open maintenance records (reported/in_progress) may change impact level.', 1;

    SELECT @staff_role = role
    FROM CampusUser
    WHERE campus_user_id = @staff_id;

    IF @staff_role IS NULL
        THROW 50022, N'Staff user does not exist.', 1;
    IF @staff_role NOT IN (N'facility_staff', N'facility_manager')
        THROW 50023, N'Only facility staff or facility manager may escalate maintenance.', 1;

    SET @lock_resource = N'Lock_Space_' + @campus_space_code;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Acquire the exclusive application lock on the parent resource
        --    (11 Section 4.3 step 3).
        EXEC @lock_result = sp_getapplock
            @Resource    = @lock_resource,
            @LockMode    = 'Exclusive',
            @LockOwner   = 'Transaction',
            @LockTimeout = 5000;
        IF @lock_result < 0
            THROW 50024, N'System busy: another operation holds the lock on this space. Please retry.', 1;

        -- 2. Update the impact level. trg_SpaceMaintenance_UpdateSpaceStatus
        --    fires within this transaction and keeps CampusSpace.current_status
        --    consistent (out_of_service => under_maintenance).
        UPDATE SpaceMaintenance
        SET impact_level = @new_impact_level
        WHERE space_maintenance_id = @space_maintenance_id;

        -- 3. Identify affected approved/checked-in bookings (BR-14) whose
        --    requested interval overlaps the maintenance interval.
        --    completion_time IS NULL is interpreted as an open-ended
        --    interval [start_time, +infinity).
        SET @maint_end = @completion_time;
        IF @maint_end IS NULL
            SET @maint_end = CONVERT(DATETIME2, N'9999-12-31 23:59:59');

        SELECT sb.space_booking_id,
               sb.requester_id,
               sb.campus_space_code,
               sb.requested_start_time,
               sb.requested_end_time,
               sb.status
        FROM SpaceBooking AS sb WITH (UPDLOCK, HOLDLOCK)
        WHERE sb.campus_space_code = @campus_space_code
          AND sb.status IN (N'approved', N'checked_in')
          AND sb.requested_start_time < @maint_end
          AND @start_time < sb.requested_end_time;

        SET @affected_count = @@ROWCOUNT;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- TRACEABILITY MATRIX (Step 12 -> Step 11 design document -> Step 09 rules)
-- All identifiers are sourced from 11-concurrency-design-G02.md and
-- 09-updated-erd-and-logical-design-G02.md.
--
-- | Procedure                       | Business rule / invariant            | Design-doc section (11) |
-- |---------------------------------|--------------------------------------|-------------------------|
-- | dbo.sp_SubmitSpaceBooking       | BR-01, BR-02, BR-07, BR-09, BR-11,   | Section 4.1             |
-- |                                 | BR-12, BR-13                         | (4.1.1 - 4.1.3)         |
-- | dbo.sp_ApproveSpaceBooking      | BR-01, BR-02, BR-03, BR-04, BR-05,   | Section 4.2             |
-- |                                 | BR-09, BR-12                         |                         |
-- | dbo.sp_EscalateSpaceMaintenance | BR-02, BR-09, BR-14                  | Section 4.3             |
-- ============================================================================

PRINT 'Step 12 concurrency implementation installed successfully on SpaceBookingDB_Phase2.';
GO
