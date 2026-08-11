USE [SpaceBookingDB_Phase2];
GO
SET NOCOUNT ON;
WAITFOR DELAY '00:00:00.500';
DECLARE @booking_id INT;
SELECT @booking_id = space_booking_id
FROM SpaceBooking
WHERE campus_space_code = N'C301'
  AND requested_start_time = '2026-09-15T14:00:00';

BEGIN TRY
    EXEC dbo.sp_ApproveSpaceBooking
        @space_booking_id = @booking_id,
        @staff_id = 2,
        @decision = N'approved',
        @decision_note = N'Two-session concurrency test';
    PRINT 'APPROVAL_SESSION_UNEXPECTED_SUCCESS';
END TRY
BEGIN CATCH
    PRINT 'APPROVAL_SESSION_REJECTED error=' + CAST(ERROR_NUMBER() AS NVARCHAR(12));
    PRINT ERROR_MESSAGE();
END CATCH;
GO
