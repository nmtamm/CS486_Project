USE [SpaceBookingDB_Phase2];
GO

-- ----------------------------------------------------------------------------
-- IDX-01: Booking conflict check + room finder overlap + query 4
-- Seek:  campus_space_code (equality) -> status (IN list)
-- Range: requested_start_time; residual: requested_end_time (included)
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_SpaceBooking_Space_Status_Start
    ON dbo.SpaceBooking (campus_space_code, status, requested_start_time)
    INCLUDE (requested_end_time);
GO

-- ----------------------------------------------------------------------------
-- IDX-02: Queries 1 and 2 - approved bookings inside a semester window
-- Seek:  status (equality) -> range on requested_start_time
-- Cover: campus_space_code (group by space), requested_end_time (hours)
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_SpaceBooking_Status_StartTime
    ON dbo.SpaceBooking (status, requested_start_time)
    INCLUDE (campus_space_code, requested_end_time);
GO

-- ----------------------------------------------------------------------------
-- IDX-03: Booking conflict check - blocking out-of-service maintenance
-- Seek:  campus_space_code -> status (IN list) -> impact_level
-- Range: start_time / completion_time (included)
-- Also accelerates trg_SpaceMaintenance_UpdateSpaceStatus lookups.
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_SpaceMaintenance_Space_Status_Impact
    ON dbo.SpaceMaintenance (campus_space_code, status, impact_level)
    INCLUDE (start_time, completion_time);
GO

-- ----------------------------------------------------------------------------
-- IDX-04: Booking conflict check - advisory FacilityMaintenance scan (BR-13)
-- Seek:  campus_facility_id (from CampusFacility join) -> status -> impact_level
-- Range: start_time / completion_time (included)
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_FacilityMaintenance_Facility_Status_Impact
    ON dbo.FacilityMaintenance (campus_facility_id, status, impact_level)
    INCLUDE (start_time, completion_time);
GO

-- ----------------------------------------------------------------------------
-- IDX-05: Booking conflict check - CampusFacility lookup by space (BR-13)
-- Seek:  campus_space_code (equality); cover join key + facility type
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_CampusFacility_SpaceCode
    ON dbo.CampusFacility (campus_space_code)
    INCLUDE (campus_facility_id, facility_type);
GO

-- ----------------------------------------------------------------------------
-- IDX-06: Room finder (query 3) - required facility list per space
-- Seek:  facility_type (IN list) -> campus_space_code
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_CampusFacility_Type_Space
    ON dbo.CampusFacility (facility_type, campus_space_code)
    INCLUDE (status);
GO

-- ----------------------------------------------------------------------------
-- IDX-07: Room finder (query 3) - capacity / availability filter
-- Seek:  capacity (>= required); residual: current_status (included)
-- Cover: typical room-finder output columns
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_CampusSpace_Capacity_Status
    ON dbo.CampusSpace (capacity)
    INCLUDE (current_status, space_type, space_name, building, floor, room_number);
GO

-- ----------------------------------------------------------------------------
-- IDX-08: AQ-04 - find spaces affected by
-- SpaceMaintenance escalated to out_of_service
-- Seek: notify_status
-- Cover: campus_space_code
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_SpaceMaintenance_NotifyStatus_Space
ON dbo.SpaceMaintenance
(
    notify_status,
    campus_space_code
);
GO

-- ----------------------------------------------------------------------------
-- IDX-09: AQ-04 - find facilities affected by
-- FacilityMaintenance escalated to out_of_service
-- Seek: notify_status
-- Cover: campus_facility_id
-- ----------------------------------------------------------------------------

CREATE NONCLUSTERED INDEX IX_FacilityMaintenance_NotifyStatus_Facility
ON dbo.FacilityMaintenance
(
    notify_status,
    campus_facility_id
);
GO

-- ============================================================================
-- OPTIONAL POST-IMPLEMENTATION VERIFICATION (do NOT run per instruction)
-- ----------------------------------------------------------------------------
-- List the newly created indexes and their columns:
--
	--SELECT i.name, i.type_desc,
	--       OBJECT_NAME(i.object_id) AS table_name
	--FROM sys.indexes i
	--WHERE i.name IN (
	--    N'IX_SpaceBooking_Space_Status_Start',
	--    N'IX_SpaceBooking_Status_StartTime',
	--    N'IX_SpaceMaintenance_Space_Status_Impact',
	--    N'IX_FacilityMaintenance_Facility_Status_Impact',
	--    N'IX_CampusFacility_SpaceCode',
	--    N'IX_CampusFacility_Type_Space',
	--    N'IX_CampusSpace_Capacity_Status'
	--);
--
-- Expected result: 7 rows, one per index created above.
-- ============================================================================

-- -- Disable indexes for testing purposes (optional):
 --ALTER INDEX IX_SpaceBooking_Space_Status_Start ON dbo.SpaceBooking DISABLE;
 --ALTER INDEX IX_SpaceBooking_Status_StartTime ON dbo.SpaceBooking DISABLE;
 --ALTER INDEX IX_SpaceMaintenance_Space_Status_Impact ON dbo.SpaceMaintenance DISABLE;
 --ALTER INDEX IX_FacilityMaintenance_Facility_Status_Impact ON dbo.FacilityMaintenance DISABLE;
 --ALTER INDEX IX_CampusFacility_SpaceCode ON dbo.CampusFacility DISABLE;
 --ALTER INDEX IX_CampusFacility_Type_Space ON dbo.CampusFacility DISABLE;
 --ALTER INDEX IX_CampusSpace_Capacity_Status ON dbo.CampusSpace DISABLE;
 --ALTER INDEX IX_SpaceMaintenance_NotifyStatus_Space ON dbo.SpaceMaintenance DISABLE;
 --ALTER INDEX IX_FacilityMaintenance_NotifyStatus_Facility ON dbo.FacilityMaintenance DISABLE;

-- -- Enable indexes after testing (optional):
 --ALTER INDEX IX_SpaceBooking_Space_Status_Start ON dbo.SpaceBooking REBUILD;
 --ALTER INDEX IX_SpaceBooking_Status_StartTime ON dbo.SpaceBooking REBUILD;
 --ALTER INDEX IX_SpaceMaintenance_Space_Status_Impact ON dbo.SpaceMaintenance REBUILD;
 --ALTER INDEX IX_FacilityMaintenance_Facility_Status_Impact ON dbo.FacilityMaintenance
 --REBUILD;
 --ALTER INDEX IX_CampusFacility_SpaceCode ON dbo.CampusFacility REBUILD;
 --ALTER INDEX IX_CampusFacility_Type_Space ON dbo.CampusFacility REBUILD;
 --ALTER INDEX IX_CampusSpace_Capacity_Status ON dbo.CampusSpace REBUILD;
 --ALTER INDEX IX_SpaceMaintenance_NotifyStatus_Space ON dbo.SpaceMaintenance REBUILD;
 --ALTER INDEX IX_FacilityMaintenance_NotifyStatus_Facility ON dbo.FacilityMaintenance REBUILD;

PRINT N'Step 15 index-tuning script generated (NOT executed per instruction).';
GO
