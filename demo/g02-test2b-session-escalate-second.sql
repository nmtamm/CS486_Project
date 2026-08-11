USE [SpaceBookingDB_Phase2];
GO
SET NOCOUNT ON;
WAITFOR DELAY '00:00:00.500';
DECLARE @maintenance_id INT;
DECLARE @affected_count INT;

SELECT @maintenance_id = space_maintenance_id
FROM SpaceMaintenance
WHERE campus_space_code = N'C301'
  AND start_time = '2026-09-15T13:00:00'
  AND problem_description = N'Faulty stage lighting system';

EXEC dbo.sp_EscalateSpaceMaintenance
    @space_maintenance_id = @maintenance_id,
    @staff_id = 3,
    @new_impact_level = N'out_of_service',
    @affected_count = @affected_count OUTPUT;

PRINT 'ESCALATION_SECOND_COMMITTED affected_count=' + CAST(@affected_count AS NVARCHAR(12));
GO
