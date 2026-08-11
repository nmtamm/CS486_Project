USE [SpaceBookingDB_Phase2];
GO
SET NOCOUNT ON;
WAITFOR DELAY '00:00:00.500';
BEGIN TRY
    DECLARE @booking_id INT;
    DECLARE @result_status NVARCHAR(20);
    DECLARE @notified BIT;

    EXEC dbo.sp_SubmitSpaceBooking
        @requester_id = 5,
        @campus_space_code = N'B201',
        @requested_start_time = '2026-09-10T10:00:00',
        @requested_end_time = '2026-09-10T12:00:00',
        @purpose_type = N'seminar',
        @expected_participants = 25,
        @space_booking_id = @booking_id OUTPUT,
        @result_status = @result_status OUTPUT,
        @advisories_notified = @notified OUTPUT;

    PRINT 'SESSION_B_UNEXPECTED_SUCCESS booking_id=' + CAST(@booking_id AS NVARCHAR(12));
END TRY
BEGIN CATCH
    PRINT 'SESSION_B_REJECTED error=' + CAST(ERROR_NUMBER() AS NVARCHAR(12));
    PRINT ERROR_MESSAGE();
END CATCH;
GO
