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

SELECT *
FROM CampusSpace as CS
WHERE dbo.fn_IsSpaceAvailable(CS.campus_space_code,@AQ03_RequiredStart,@AQ03_RequiredEnd,NULL) = 1
and @AQ03_MinCapacity <= CS.capacity
and exists (select *
			from @AQ03_RequiredFacilities
			where facility_type in (
				select distinct facility_type
				from CampusFacility
				where campus_space_code = CS.campus_space_code and status = 'available')
			)

-- ============================================================================
-- AQ-04
-- Business question:
-- Which approved bookings are affected when a maintenance record is escalated
-- to out-of-service?
--
-- Target user: Facility Staff / Facility Manager
-- Purpose:
-- Find approved bookings affected by either:
--   1. SpaceMaintenance escalated to out_of_service, or
--   2. FacilityMaintenance escalated to out_of_service.
-- ============================================================================

select *
from SpaceBooking
where status = 'approved' and campus_space_code in (
	select distinct campus_space_code
	from SpaceMaintenance
	where notify_status = 'updated_to_out_of_service'
	union
	select distinct CF.campus_space_code
	from FacilityMaintenance as FM
	join CampusFacility as CF on FM.campus_facility_id = CF.campus_facility_id
	where notify_status = 'updated_to_out_of_service'
)