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