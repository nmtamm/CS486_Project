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


-- ----------------------------------------------------------------------------
-- Vo Huy Dang
-- 20125022
-- ----------------------------------------------------------------------------

-- Business question: What is the total number of bookings and average expected participants for each space type
-- Target user: Facility Manager
-- Short explanation: Helps management understand which types of spaces are in highest demand and whether spaces are being utilized appropriately relative to their capacity
SELECT 
    s.space_type,
    COUNT(b.space_booking_id) AS total_bookings,
    ISNULL(AVG(CAST(b.expected_participants AS DECIMAL(10, 2))), 0.00) AS avg_expected_participants
FROM 
    CampusSpace s
LEFT JOIN 
    SpaceBooking b ON s.campus_space_code = b.campus_space_code
GROUP BY 
    s.space_type;

-- Business question: Which departments have the highest number of "no-show" bookings?
-- Target user: Facility Manager, Department Administrator
-- Short explanation: Identifies academic departments that frequently reserve shared spaces without actually using them
SELECT 
    u.department,
    COUNT(b.space_booking_id) AS no_show_bookings
FROM 
    CampusUser u
JOIN 
    SpaceBooking b ON u.campus_user_id = b.requester_id
WHERE 
    b.status = 'no-show'
GROUP BY 
    u.department
ORDER BY 
    no_show_bookings DESC;

-- Business question: What are the most common rejection reasons provided by staff?
-- Target user: Department Administrator, Facility Manager
-- Short explanation: Provides transparency into why requests fail, helping administrators provide clearer booking guidelines to students and faculty to improve approval rates.
SELECT 
    rejection_reason,
    COUNT(*) AS occurrence_count
FROM 
    BookingApproval
WHERE 
    decision = 'rejected'
GROUP BY 
    rejection_reason
ORDER BY 
    occurrence_count DESC;

-- Business question: Which campus amenities/facilities (e.g., projectors, specialized software labs) are equipped in the spaces that receive the highest volume of booking requests?
-- Target user: Facility Manager, Department Administrator
-- Short explanation: Directs future procurement budgets by revealing which equipment features drive the most demand among students and staff.
SELECT 
    f.facility_name,
    COUNT(b.space_booking_id) AS total_bookings_received,
    COUNT(DISTINCT sf.campus_space_code) AS equipped_spaces_count
FROM 
    CampusFacility f
JOIN 
    CampusSpaceFacility sf ON f.campus_facility_id = sf.campus_facility_id
JOIN 
    SpaceBooking b ON sf.campus_space_code = b.campus_space_code
GROUP BY 
    f.facility_name
ORDER BY 
    total_bookings_received DESC;

-- Business question: Which classrooms or meeting rooms with a capacity of at least 5 people are currently available and equipped with a projector for upcoming group study sessions?
-- Target user: Student
-- Short explanation: Allows students to filter and find suitable study spaces that meet their group size and presentation equipment needs before submitting a booking request. 
SELECT 
    s.campus_space_code,
    s.space_name
FROM 
    CampusSpace s
JOIN 
    CampusSpaceFacility sf ON s.campus_space_code = sf.campus_space_code
JOIN 
    CampusFacility f ON sf.campus_facility_id = f.campus_facility_id
WHERE 
    s.space_type IN ('classroom', 'meeting_room')
    AND s.capacity >= 5
    AND s.current_status = 'available'
    AND LOWER(f.facility_name) = 'projector';