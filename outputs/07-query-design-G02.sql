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

-- ----------------------------------------------------------------------------
-- Kiet Trinh
-- ----------------------------------------------------------------------------

-- Business question: What is the current distribution of bookings across all statuses?
-- Target user: Facility Manager
-- Short explanation: Dashboard-level snapshot of how many bookings are pending, approved, rejected, etc.

SELECT status, COUNT(*) AS cnt
FROM SpaceBooking
GROUP BY status
ORDER BY cnt DESC;

-- Business question: Which spaces have the most pending booking requests waiting for approval?
-- Target user: Facility Staff
-- Short explanation: Helps staff prioritize which spaces need approval decisions first.

SELECT campus_space_code, COUNT(*) AS pending_cnt
FROM SpaceBooking
WHERE status = 'pending'
GROUP BY campus_space_code
ORDER BY pending_cnt DESC;

-- Business question: Which spaces generate the most maintenance requests and what problem types recur per space?
-- Target user: Facility Manager
-- Short explanation: Detects recurring issues in specific locations to guide preventive maintenance budgets.

SELECT s.campus_space_code, mr.problem_type, COUNT(*) AS cnt
FROM SpaceMaintenance mr
JOIN CampusSpace s ON mr.campus_space_code = s.campus_space_code
GROUP BY s.campus_space_code, mr.problem_type
ORDER BY s.campus_space_code, cnt DESC;

-- Business question: What is the distribution of bookings by purpose?
-- Target user: Facility Manager
-- Short explanation: Shows which event types (lecture, exam, meeting, etc.) generate the most booking requests.

SELECT purpose_type, COUNT(*) AS cnt
FROM SpaceBooking
GROUP BY purpose_type
ORDER BY cnt DESC;

-- Business question: Which users have the most bookings overall?
-- Target user: Facility Manager
-- Short explanation: Identifies the most frequent space users across all roles.

SELECT requester_id, COUNT(*) AS booking_cnt
FROM SpaceBooking
GROUP BY requester_id
ORDER BY booking_cnt DESC;

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