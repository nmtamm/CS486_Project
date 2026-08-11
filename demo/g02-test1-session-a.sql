USE [SpaceBookingDB_Phase2];
GO
SET NOCOUNT ON;
DECLARE @outer_lock_result INT;
DECLARE @booking_id INT;
DECLARE @result_status NVARCHAR(20);
DECLARE @notified BIT;

BEGIN TRANSACTION;
EXEC @outer_lock_result = sys.sp_getapplock
    @Resource = N'Lock_Space_B201',
    @LockMode = 'Exclusive',
    @LockOwner = 'Transaction',
    @LockTimeout = 5000;

PRINT 'SESSION_A_LOCK_RESULT=' + CAST(@outer_lock_result AS NVARCHAR(12));
WAITFOR DELAY '00:00:03';

EXEC dbo.sp_SubmitSpaceBooking
    @requester_id = 4,
    @campus_space_code = N'B201',
    @requested_start_time = '2026-09-10T10:00:00',
    @requested_end_time = '2026-09-10T12:00:00',
    @purpose_type = N'lecture',
    @expected_participants = 30,
    @space_booking_id = @booking_id OUTPUT,
    @result_status = @result_status OUTPUT,
    @advisories_notified = @notified OUTPUT;

COMMIT TRANSACTION;
PRINT 'SESSION_A_APPROVED booking_id=' + CAST(@booking_id AS NVARCHAR(12));
GO
