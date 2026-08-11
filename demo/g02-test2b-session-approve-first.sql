USE [SpaceBookingDB_Phase2];
GO
SET NOCOUNT ON;
DECLARE @outer_lock_result INT;
DECLARE @booking_id INT;

SELECT @booking_id = space_booking_id
FROM SpaceBooking
WHERE campus_space_code = N'C301'
  AND requested_start_time = '2026-09-15T14:00:00';

BEGIN TRANSACTION;
EXEC @outer_lock_result = sys.sp_getapplock
    @Resource = N'Lock_Space_C301',
    @LockMode = 'Exclusive',
    @LockOwner = 'Transaction',
    @LockTimeout = 5000;

PRINT 'APPROVAL_FIRST_LOCK_RESULT=' + CAST(@outer_lock_result AS NVARCHAR(12));
WAITFOR DELAY '00:00:03';

EXEC dbo.sp_ApproveSpaceBooking
    @space_booking_id = @booking_id,
    @staff_id = 2,
    @decision = N'approved',
    @decision_note = N'Two-session reverse-order test';

COMMIT TRANSACTION;
PRINT 'APPROVAL_FIRST_COMMITTED booking_id=' + CAST(@booking_id AS NVARCHAR(12));
GO
