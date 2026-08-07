-- ============================================================================
-- Step 16 - Analytical Queries: Campus Space Management System
-- Group: G02
-- DBMS: Microsoft SQL Server
-- Target database: SpaceBookingDB_Phase2
--
-- Implements every report required by Phase 2, Section 1.3:
--   AQ-01 Total approved booking hours of each space for a given semester.
--   AQ-02 Number of approved bookings by weekday and hour for a semester.
--   AQ-03 Available spaces satisfying capacity and required facilities.
--   AQ-04 Approved bookings affected by out-of-service maintenance.
--
-- Interval convention used throughout:
--   [start_time, end_time)
-- Two intervals overlap when start_1 < end_2 AND end_1 > start_2.
-- ============================================================================

USE SpaceBookingDB_Phase2;
GO

SET NOCOUNT ON;
GO

-- ============================================================================
-- AQ-01
-- Business question:
-- What are the total approved booking hours of each space for a given semester?
--
-- Target user: Facility Manager
-- Purpose:
-- Measures scheduled utilization by space during a selected semester. The query
-- includes staff-approved and instant-approved bookings and counts the portion
-- of each booking that falls inside the semester boundary.
--
-- Parameter example:
--   @SemesterId = 6  -- Summer Semester 2025/2026
-- ============================================================================
DECLARE @AQ01_SemesterId INT = 6;

;WITH SemesterWindow AS (
    SELECT
        semester_id,
        semester_name,
        CAST(start_date AS DATETIME2) AS semester_start,
        DATEADD(DAY, 1, CAST(end_date AS DATETIME2)) AS semester_end_exclusive
    FROM Semester
    WHERE semester_id = @AQ01_SemesterId
),
ApprovedBookingIntervals AS (
    SELECT
        sb.space_booking_id,
        sb.campus_space_code,
        CASE
            WHEN sb.requested_start_time < sw.semester_start
                THEN sw.semester_start
            ELSE sb.requested_start_time
        END AS effective_start,
        CASE
            WHEN sb.requested_end_time > sw.semester_end_exclusive
                THEN sw.semester_end_exclusive
            ELSE sb.requested_end_time
        END AS effective_end
    FROM SpaceBooking sb
    CROSS JOIN SemesterWindow sw
    WHERE sb.status IN ('approved', 'checked_in', 'completed', 'no-show')
      AND (
            sb.is_instant_booking = 1
            OR EXISTS (
                SELECT 1
                FROM BookingApproval ba
                WHERE ba.space_booking_id = sb.space_booking_id
                  AND ba.decision = 'approved'
            )
          )
      AND sb.requested_start_time < sw.semester_end_exclusive
      AND sb.requested_end_time > sw.semester_start
)
SELECT
    sw.semester_id,
    sw.semester_name,
    cs.campus_space_code,
    cs.space_name,
    cs.space_type,
    CAST(
        COALESCE(
            SUM(DATEDIFF_BIG(SECOND, abi.effective_start, abi.effective_end)),
            0
        ) / 3600.0
        AS DECIMAL(18, 2)
    ) AS total_approved_booking_hours
FROM SemesterWindow sw
CROSS JOIN CampusSpace cs
LEFT JOIN ApprovedBookingIntervals abi
    ON abi.campus_space_code = cs.campus_space_code
GROUP BY
    sw.semester_id,
    sw.semester_name,
    cs.campus_space_code,
    cs.space_name,
    cs.space_type
ORDER BY
    total_approved_booking_hours DESC,
    cs.campus_space_code;
GO


-- ============================================================================
-- AQ-02
-- Business question:
-- How many approved bookings occur by weekday and starting hour for a given
-- semester?
--
-- Target user: Facility Manager
-- Purpose:
-- Identifies peak demand periods for staffing, scheduling, and maintenance
-- planning. DATEFIRST is fixed to Monday for stable weekday ordering.
-- ============================================================================
SET DATEFIRST 1; -- Monday = 1, Sunday = 7

DECLARE @AQ02_SemesterId INT = 6;

;WITH SemesterWindow AS (
    SELECT
        semester_id,
        semester_name,
        CAST(start_date AS DATETIME2) AS semester_start,
        DATEADD(DAY, 1, CAST(end_date AS DATETIME2)) AS semester_end_exclusive
    FROM Semester
    WHERE semester_id = @AQ02_SemesterId
),
ApprovedBookings AS (
    SELECT
        sb.space_booking_id,
        sb.requested_start_time
    FROM SpaceBooking sb
    CROSS JOIN SemesterWindow sw
    WHERE sb.status IN ('approved', 'checked_in', 'completed', 'no-show')
      AND (
            sb.is_instant_booking = 1
            OR EXISTS (
                SELECT 1
                FROM BookingApproval ba
                WHERE ba.space_booking_id = sb.space_booking_id
                  AND ba.decision = 'approved'
            )
          )
      AND sb.requested_start_time >= sw.semester_start
      AND sb.requested_start_time < sw.semester_end_exclusive
)
SELECT
    sw.semester_id,
    sw.semester_name,
    DATEPART(WEEKDAY, ab.requested_start_time) AS weekday_number,
    DATENAME(WEEKDAY, ab.requested_start_time) AS weekday_name,
    DATEPART(HOUR, ab.requested_start_time) AS starting_hour,
    COUNT_BIG(*) AS approved_booking_count
FROM SemesterWindow sw
CROSS JOIN ApprovedBookings ab
GROUP BY
    sw.semester_id,
    sw.semester_name,
    DATEPART(WEEKDAY, ab.requested_start_time),
    DATENAME(WEEKDAY, ab.requested_start_time),
    DATEPART(HOUR, ab.requested_start_time)
ORDER BY
    weekday_number,
    starting_hour;
GO


-- ============================================================================
-- AQ-03 - ROOM FINDER
-- Business question:
-- Which spaces are available for a required time period, support a minimum
-- capacity, and contain every facility type requested by the user?
--
-- Target user: Student, Lecturer, Teaching Assistant, Department Administrator
-- Purpose:
-- Finds usable rooms while excluding conflicting approved bookings, closed or
-- retired spaces, overlapping out-of-service space maintenance, unavailable
-- required facilities, and overlapping out-of-service facility maintenance.
--
-- Replace parameter values and required facility rows as needed.
-- ============================================================================
DECLARE @AQ03_RequiredStart DATETIME2 = '2026-07-15T09:00:00';
DECLARE @AQ03_RequiredEnd   DATETIME2 = '2026-07-15T11:00:00';
DECLARE @AQ03_MinCapacity   INT       = 20;

DECLARE @AQ03_RequiredFacilities TABLE (
    facility_type NVARCHAR(100) NOT NULL PRIMARY KEY
);

INSERT INTO @AQ03_RequiredFacilities (facility_type)
VALUES
    (N'Projector'),
    (N'Whiteboard');

IF @AQ03_RequiredEnd <= @AQ03_RequiredStart
    THROW 51000, 'AQ-03: Required end time must be later than required start time.', 1;

SELECT
    cs.campus_space_code,
    cs.space_name,
    cs.space_type,
    cs.building,
    cs.floor,
    cs.room_number,
    cs.capacity
FROM CampusSpace cs
WHERE cs.capacity >= @AQ03_MinCapacity
  AND cs.current_status NOT IN ('temporarily_closed', 'retired')

  -- No conflicting booking that has been approved through either path.
  AND NOT EXISTS (
        SELECT 1
        FROM SpaceBooking sb
        WHERE sb.campus_space_code = cs.campus_space_code
          AND sb.status IN ('approved', 'checked_in', 'completed', 'no-show')
          AND (
                sb.is_instant_booking = 1
                OR EXISTS (
                    SELECT 1
                    FROM BookingApproval ba
                    WHERE ba.space_booking_id = sb.space_booking_id
                      AND ba.decision = 'approved'
                )
              )
          AND sb.requested_start_time < @AQ03_RequiredEnd
          AND sb.requested_end_time > @AQ03_RequiredStart
  )

  -- Relational division: no requested facility may be missing or unavailable.
  AND NOT EXISTS (
        SELECT 1
        FROM @AQ03_RequiredFacilities rf
        WHERE NOT EXISTS (
            SELECT 1
            FROM CampusFacility cf
            WHERE cf.campus_space_code = cs.campus_space_code
              AND cf.facility_type = rf.facility_type
              AND cf.status <> 'under_maintenance'
              AND NOT EXISTS (
                    SELECT 1
                    FROM FacilityMaintenance fm
                    WHERE fm.campus_facility_id = cf.campus_facility_id
                      AND fm.status IN ('reported', 'in_progress')
                      AND fm.start_time < @AQ03_RequiredEnd
                      AND COALESCE(fm.completion_time, CONVERT(DATETIME2, '9999-12-31'))
                          > @AQ03_RequiredStart
              )
        )
  )
ORDER BY
    cs.capacity,
    cs.campus_space_code;
GO


-- ============================================================================
-- AQ-04
-- Business question:
-- Which approved bookings are affected when a maintenance record is escalated
-- to out-of-service?
--
-- Target user: Facility Staff / Facility Manager
-- Purpose:
-- Lists approved bookings whose requested intervals overlap the selected
-- out-of-service maintenance interval, so staff can contact requesters.
--
-- Schema limitation:
-- SpaceMaintenance stores the current impact_level but no impact-level history
-- or escalation timestamp. Therefore the query accepts the maintenance record
-- selected by the caller immediately after escalation and reports its currently
-- affected approved bookings. Historical proof of when escalation occurred is
-- not available from this schema alone.
-- ============================================================================
DECLARE @AQ04_MaintenanceId INT = 1;

;WITH EscalatedMaintenance AS (
    SELECT
        sm.space_maintenance_id,
        sm.campus_space_code,
        sm.problem_description,
        sm.start_time AS maintenance_start,
        COALESCE(sm.completion_time, CONVERT(DATETIME2, '9999-12-31'))
            AS maintenance_end
    FROM SpaceMaintenance sm
    WHERE sm.space_maintenance_id = @AQ04_MaintenanceId
      AND sm.impact_level = 'advisory'
      AND sm.status IN ('reported', 'in_progress')
)
SELECT
    em.space_maintenance_id,
    em.campus_space_code,
    cs.space_name,
    em.problem_description,
    em.maintenance_start,
    NULLIF(em.maintenance_end, CONVERT(DATETIME2, '9999-12-31'))
        AS maintenance_end,
    sb.space_booking_id,
    sb.requester_id,
    cu.full_name AS requester_name,
    cu.email AS requester_email,
    sb.requested_start_time,
    sb.requested_end_time,
    sb.purpose_type,
    sb.status,
    sb.is_instant_booking
FROM EscalatedMaintenance em
JOIN CampusSpace cs
    ON cs.campus_space_code = em.campus_space_code
JOIN SpaceBooking sb
    ON sb.campus_space_code = em.campus_space_code
   AND sb.requested_start_time < em.maintenance_end
   AND sb.requested_end_time > em.maintenance_start
JOIN CampusUser cu
    ON cu.campus_user_id = sb.requester_id
WHERE sb.status IN ('approved', 'checked_in', 'completed', 'no-show')
  AND (
        sb.is_instant_booking = 1
        OR EXISTS (
            SELECT 1
            FROM BookingApproval ba
            WHERE ba.space_booking_id = sb.space_booking_id
              AND ba.decision = 'approved'
        )
      )
ORDER BY
    sb.requested_start_time,
    sb.space_booking_id;
GO

