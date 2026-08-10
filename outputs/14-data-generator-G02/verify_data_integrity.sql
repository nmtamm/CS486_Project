-- ============================================================================
-- Step 14 — Data Verification Script: School of Computer Science Space Booking System
-- Group: G02
-- DBMS:  Microsoft SQL Server
-- Database: SpaceBookingDB_Phase2
-- Purpose: Verify record counts, foreign key integrity, workflow rules, and zero schedule overlaps.
-- ============================================================================

USE SpaceBookingDB_Phase2;
GO

SET NOCOUNT ON;
PRINT '================================================================';
PRINT '  PHASE 2 DATA GENERATION INTEGRITY VERIFICATION REPORT';
PRINT '================================================================';

-- 1. Table Record Counts
PRINT '';
PRINT '--- 1. Table Record Counts ---';
SELECT 'Semester' AS TableName, COUNT(*) AS TotalRows FROM Semester
UNION ALL SELECT 'SpaceTypeBookingPolicy', COUNT(*) FROM SpaceTypeBookingPolicy
UNION ALL SELECT 'CampusUser', COUNT(*) FROM CampusUser
UNION ALL SELECT 'CampusSpace', COUNT(*) FROM CampusSpace
UNION ALL SELECT 'CampusFacility', COUNT(*) FROM CampusFacility
UNION ALL SELECT 'SpaceMaintenance', COUNT(*) FROM SpaceMaintenance
UNION ALL SELECT 'SpaceBooking', COUNT(*) FROM SpaceBooking
UNION ALL SELECT 'BookingApproval', COUNT(*) FROM BookingApproval
UNION ALL SELECT 'SpaceUsageSession', COUNT(*) FROM SpaceUsageSession;
GO

-- 2. Foreign Key Integrity Check (Orphan Records)
PRINT '';
PRINT '--- 2. Foreign Key Integrity Check (Orphan Records) ---';
SELECT 'Orphan Bookings (Invalid User)' AS CheckDescription, COUNT(*) AS FaultCount 
FROM SpaceBooking WHERE requester_id NOT IN (SELECT campus_user_id FROM CampusUser)
UNION ALL
SELECT 'Orphan Bookings (Invalid Space)', COUNT(*) 
FROM SpaceBooking WHERE campus_space_code NOT IN (SELECT campus_space_code FROM CampusSpace)
UNION ALL
SELECT 'Orphan Approvals (Invalid Booking)', COUNT(*) 
FROM BookingApproval WHERE space_booking_id NOT IN (SELECT space_booking_id FROM SpaceBooking)
UNION ALL
SELECT 'Orphan Approvals (Invalid Staff)', COUNT(*) 
FROM BookingApproval WHERE staff_id NOT IN (SELECT campus_user_id FROM CampusUser)
UNION ALL
SELECT 'Orphan Sessions (Invalid Booking)', COUNT(*) 
FROM SpaceUsageSession WHERE space_booking_id NOT IN (SELECT space_booking_id FROM SpaceBooking)
UNION ALL
SELECT 'Orphan Sessions (Invalid Staff)', COUNT(*) 
FROM SpaceUsageSession WHERE checked_in_by NOT IN (SELECT campus_user_id FROM CampusUser);
GO

-- 3. Workflow Consistency Checks
PRINT '';
PRINT '--- 3. Workflow Consistency Checks ---';
SELECT 
    'Completed Bookings without Usage Session' AS CheckDescription,
    COUNT(*) AS ViolationCount
FROM SpaceBooking b
LEFT JOIN SpaceUsageSession s ON b.space_booking_id = s.space_booking_id
WHERE b.status = 'completed' AND s.space_usage_session_id IS NULL

UNION ALL

SELECT 
    'Non-Instant Reviewed Bookings without Approval Record',
    COUNT(*)
FROM SpaceBooking b
LEFT JOIN BookingApproval a ON b.space_booking_id = a.space_booking_id
WHERE b.is_instant_booking = 0 
  AND b.status IN ('approved', 'completed', 'checked_in', 'rejected', 'no-show') 
  AND a.booking_approval_id IS NULL;
GO

-- 4. Non-Overlapping Invariant Verification for Approved/Completed Bookings
PRINT '';
PRINT '--- 4. Overlap Invariant Verification (Approved/Completed) ---';
SELECT COUNT(*) AS OverlapViolations
FROM SpaceBooking b1
JOIN SpaceBooking b2 
  ON b1.campus_space_code = b2.campus_space_code
 AND b1.space_booking_id < b2.space_booking_id
 AND b1.status IN ('approved', 'completed', 'checked_in')
 AND b2.status IN ('approved', 'completed', 'checked_in')
 AND b1.requested_start_time < b2.requested_end_time
 AND b1.requested_end_time > b2.requested_start_time;
GO

PRINT '';
PRINT '================================================================';
PRINT '  VERIFICATION REPORT COMPLETE';
PRINT '================================================================';
GO
