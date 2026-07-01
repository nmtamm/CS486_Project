USE SpaceBookingDB
GO

-- ----------------------------------------------------------------------------
-- Nguyen Minh Tam
-- 24125042
-- ----------------------------------------------------------------------------

SELECT * FROM BookingApproval
-- Business question: Find lists of booking that a specific staff accepted
-- Target user: staff
-- Short explanation: To track the workload of that specific staff

SELECT booking_approval_id
FROM CampusUser join BookingApproval ON campus_user_id = staff_id
WHERE campus_user_id = 2;

-- Business question: Find users who always appear later after the requested start time
-- Target user: Lecturer, Student, TA
-- Short explanation: To track those who does not appear on time as they requested. This helps staff to easy track and prevent users from booking a space but did not utilize its function.

SELECT U.*
FROM (SpaceBooking as B join SpaceUsageSession as S on B.space_booking_id = S.space_booking_id) join CampusUser as U on B.requester_id = U.campus_user_id
WHERE B.requested_start_time < S.actual_start_time

-- Business question: Find spaces that are booked most
-- Target user: Facility Manager
-- Short explanation: To find spaces that are most preferred by users in the campus
-- TOP 1 WITH TIES is used to find all spaces that have the same highest usage

SELECT TOP 1 WITH TIES COUNT(B.campus_space_code) as booking_count, S.campus_space_code, S.space_name
FROM SpaceBooking AS B 
JOIN CampusSpace AS S ON B.campus_space_code = S.campus_space_code
GROUP BY B.campus_space_code, S.campus_space_code, S.space_name
ORDER BY booking_count DESC

-- Business question: Find spaces that are under maintenance
-- Target user: Facility Manager
-- Short explanation: To easily check and urge staffs to repair quickly if needed
SELECT *
FROM CampusSpace
WHERE current_status = 'under_maintenance'

-- Business question: Find spaces with the highest booking cancellation rate
-- Target user: Facility Manager
-- Short explanation: Identify spaces that users frequently cancel, indicating possible issues with location, equipment, or scheduling.
SELECT TOP 1 WITH TIES COUNT(B.campus_space_code) as booking_count, S.campus_space_code, S.space_name
FROM SpaceBooking AS B 
JOIN CampusSpace AS S ON B.campus_space_code = S.campus_space_code
WHERE B.status = 'cancelled'
GROUP BY B.campus_space_code, S.campus_space_code, S.space_name
ORDER BY booking_count DESC


-- ----------------------------------------------------------------------------
-- Tran Trung Hau
-- 24125055
-- ----------------------------------------------------------------------------

-- Business question: Which approved bookings do not have any recorded check-in session yet?
-- Target user: Facility Staff
-- Short explanation: Helps staff identify approved bookings that still need check-in monitoring
SELECT 
    sb.space_booking_id, sb.requester_id, sb.campus_space_code, sb.requested_start_time, sb.requested_end_time, sb.purpose_type, sb.expected_participants, sb.submitted_at
FROM SpaceBooking sb LEFT JOIN SpaceUsageSession sus on sb.space_booking_id = sus.space_booking_id
WHERE sb.status = 'approved' AND sus.space_booking_id IS NULL;

-- Business question: Which completed bookings ended later than their requested end time?
-- Target user: Facility Staff
-- Short explanation: Helps identify overtime usage and possible scheduling conflict risks
SELECT sb.space_booking_id, sb.campus_space_code, sb.requester_id, sb.requested_start_time, sb.requested_end_time, sus.actual_start_time, sus.actual_end_time, DATEDIFF(MINUTE, sb.requested_end_time, sus.actual_end_time) AS minutes_late
FROM SpaceBooking sb LEFT JOIN SpaceUsageSession sus on sb.space_booking_id = sus.space_booking_id
WHERE sb.status = 'completed' AND sus.actual_end_time > sb.requested_end_time
ORDER BY minutes_late DESC;

-- Business question: Which spaces have never been booked?
-- Target user: Facility Manager
-- Short explanation: Helps identify underutilized spaces that may require promotion, repurposing, or further investigation
SELECT cs.campus_space_code, cs.space_name, cs.space_type, cs.building, cs.room_number, cs.capacity
FROM CampusSpace cs LEFT JOIN sb on sb.campus_space_code = cs.campus_space_code
WHERE sb.campus_space_code IS NULL;

-- Business question: Find spaces with the number of booking request where expected participants exceed the space capacity
-- Target user: Facility Manager
-- Short explanation: Identifies spaces that cannot adequately satisfy user demand and may require expansion or alternative allocation strategies
SELECT cs.campus_space_code, cs.space_name, cs.space_type, cs.capacity, COUNT(sb.space_booking_id) AS exceed_capacity_booking_count
FROM CampusSpace cs JOIN SpaceBooking sb ON sb.campus_space_code = cs.campus_space_code
WHERE sb.expected_participants > cs.capacity
GROUP BY cs.campus_space_code, cs.space_name, cs.space_type, cs.capacity
ORDER BY exceed_capacity_booking_count DESC;

-- Business question: How many unresolved maintenance records does each space currently have?
-- Target user: Facility Manager
-- Short explanation: Helps monitor maintenance workload and identify spaces with recurring unresolved issues
SELECT cs.campus_space_code, cs.space_name, COUNT(sm.space_maintenance_id) AS unresolved_maintainance_record_count
FROM CampusSpace cs JOIN SpaceMaintenance sm ON sm.campus_space_code = cs.campus_space_code
WHERE sm.status <> 'completed' AND sm.status <> 'cancelled'
GROUP BY cs.campus_space_code, cs.space_name
ORDER BY COUNT(sm.space_maintenance_id) DESC;