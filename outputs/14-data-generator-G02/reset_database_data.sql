-- ============================================================================
-- Step 14 — Reset Database Data: School of Computer Science Space Booking System
-- Group: G02
-- DBMS:  Microsoft SQL Server
-- Database: SpaceBookingDB_Phase2
-- Purpose: Safely delete all data in reverse FK dependency order and reseed IDENTITY counters.
-- ============================================================================

USE SpaceBookingDB_Phase2;
GO

SET NOCOUNT ON;
PRINT '================================================================';
PRINT '  STARTING FULL DATABASE RESET (REVERSE FK DELETIONS)';
PRINT '================================================================';

-- Disable constraints temporarily to speed up deletion
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
GO

PRINT '[1/10] Deleting FacilityMaintenance...';
DELETE FROM FacilityMaintenance;

PRINT '[2/10] Deleting SpaceMaintenance...';
DELETE FROM SpaceMaintenance;

PRINT '[3/10] Deleting SpaceUsageSession...';
DELETE FROM SpaceUsageSession;

PRINT '[4/10] Deleting BookingApproval...';
DELETE FROM BookingApproval;

PRINT '[5/10] Deleting SpaceBooking...';
DELETE FROM SpaceBooking;

PRINT '[6/10] Deleting CampusFacility...';
DELETE FROM CampusFacility;

PRINT '[7/10] Deleting CampusSpace...';
DELETE FROM CampusSpace;

PRINT '[8/10] Deleting SpaceTypeBookingPolicy...';
DELETE FROM SpaceTypeBookingPolicy;

PRINT '[9/10] Deleting CampusUser...';
DELETE FROM CampusUser;

PRINT '[10/10] Deleting Semester...';
DELETE FROM Semester;
GO

PRINT 'Reseeding IDENTITY column counters...';
DBCC CHECKIDENT ('SpaceBooking', RESEED, 0);
DBCC CHECKIDENT ('BookingApproval', RESEED, 0);
DBCC CHECKIDENT ('SpaceUsageSession', RESEED, 0);
DBCC CHECKIDENT ('SpaceMaintenance', RESEED, 0);
DBCC CHECKIDENT ('FacilityMaintenance', RESEED, 0);
DBCC CHECKIDENT ('CampusUser', RESEED, 0);
DBCC CHECKIDENT ('CampusFacility', RESEED, 0);
DBCC CHECKIDENT ('Semester', RESEED, 0);
GO

-- Re-enable constraints
EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";
GO

PRINT '================================================================';
PRINT '  DATABASE RESET COMPLETE: 0 ROWS REMAINING IN ALL TABLES';
PRINT '================================================================';
GO
