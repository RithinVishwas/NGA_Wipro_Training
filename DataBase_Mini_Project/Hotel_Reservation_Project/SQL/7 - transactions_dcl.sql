-- ============================================================
-- Hotel Reservation System - Transactions & Access Control
-- Sprint 3: TCL (COMMIT, ROLLBACK) + DCL (GRANT, REVOKE)
-- ============================================================

USE Demo2_HotelReservationDB;
GO

-- ============================================================
-- TRANSACTION 1: New Reservation + Payment (COMMIT scenario)
-- A successful end-to-end booking
-- ============================================================
PRINT '========== TRANSACTION 1: New Booking (COMMIT) ==========';
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @NewResID   INT;
    DECLARE @RoomIDVar  INT = 12;    -- Room 102, Comfort Stay Chennai
    DECLARE @CustIDVar  INT = 6;
    DECLARE @CheckIn    DATE = '2025-08-15';
    DECLARE @CheckOut   DATE = '2025-08-18';
    DECLARE @Nights     INT = DATEDIFF(DAY, @CheckIn, @CheckOut);
    DECLARE @Price      DECIMAL(10,2);

    -- Get room price
    SELECT @Price = rc.BasePrice
    FROM dbo.Rooms rm
    INNER JOIN dbo.RoomCategories rc ON rc.CategoryID = rm.CategoryID
    WHERE rm.RoomID = @RoomIDVar;

    DECLARE @TotalAmt DECIMAL(10,2) = @Price * @Nights;

    -- Step 1: Insert reservation
    INSERT INTO dbo.Reservations
        (CustomerID, RoomID, StaffID, CheckInDate, CheckOutDate, Adults, Children, Status, TotalAmount)
    VALUES
        (@CustIDVar, @RoomIDVar, 6, @CheckIn, @CheckOut, 2, 0, 'Confirmed', @TotalAmt);

    SET @NewResID = SCOPE_IDENTITY();
    PRINT 'Step 1 done: Reservation #' + CAST(@NewResID AS VARCHAR) + ' created.';

    -- Step 2: Record advance payment (50%)
    INSERT INTO dbo.Payments
        (ReservationID, Amount, PaymentMethod, TransactionRef, Status, Notes)
    VALUES
        (@NewResID, @TotalAmt * 0.5, 'UPI', 'TXN_NEW_ADV_001', 'Completed', '50% advance payment');

    PRINT 'Step 2 done: Advance payment recorded.';

    -- Step 3: Update room status to Reserved
    UPDATE dbo.Rooms SET Status = 'Reserved' WHERE RoomID = @RoomIDVar;
    PRINT 'Step 3 done: Room status updated to Reserved.';

    COMMIT TRANSACTION;
    PRINT 'TRANSACTION 1 COMMITTED successfully.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'TRANSACTION 1 ROLLED BACK. Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- TRANSACTION 2: Check-In Process (COMMIT scenario)
-- ============================================================
PRINT '========== TRANSACTION 2: Check-In Process (COMMIT) ==========';
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @ResID INT = 9;   -- Reservation for Arjun Kapoor

    -- Verify reservation exists and is Confirmed
    IF NOT EXISTS (SELECT 1 FROM dbo.Reservations WHERE ReservationID = @ResID AND Status = 'Confirmed')
    BEGIN
        RAISERROR('Reservation not found or not in Confirmed status.', 16, 1);
    END

    -- Update reservation status to CheckedIn
    UPDATE dbo.Reservations
    SET Status = 'CheckedIn', ActualCheckIn = GETDATE()
    WHERE ReservationID = @ResID;
    PRINT 'Step 1 done: Reservation status → CheckedIn.';

    -- Update room status to Occupied (trigger also handles this, explicit for demo)
    UPDATE dbo.Rooms
    SET Status = 'Occupied'
    WHERE RoomID = (SELECT RoomID FROM dbo.Reservations WHERE ReservationID = @ResID);
    PRINT 'Step 2 done: Room status → Occupied.';

    COMMIT TRANSACTION;
    PRINT 'TRANSACTION 2 COMMITTED: Guest checked in successfully.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'TRANSACTION 2 ROLLED BACK. Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- TRANSACTION 3: Cancellation with Refund (ROLLBACK demo)
-- Simulates a failure mid-way through to demonstrate ROLLBACK
-- ============================================================
PRINT '========== TRANSACTION 3: Cancellation + ROLLBACK Demo ==========';
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @CancelResID INT = 10;  -- Reservation for Lakshmi Venkat

    -- Step 1: Update reservation status to Cancelled
    UPDATE dbo.Reservations
    SET Status = 'Cancelled'
    WHERE ReservationID = @CancelResID;
    PRINT 'Step 1: Reservation marked Cancelled.';

    -- Step 2: Insert refund payment record
    INSERT INTO dbo.Payments (ReservationID, Amount, PaymentMethod, TransactionRef, Status, Notes)
    SELECT ReservationID, TotalAmount * 0.8, 'CreditCard', 'REFUND_' + CAST(ReservationID AS VARCHAR), 'Refunded', '80% refund on cancellation'
    FROM dbo.Reservations
    WHERE ReservationID = @CancelResID;
    PRINT 'Step 2: Refund record inserted.';

    -- Step 3: Simulate a business rule violation (force ROLLBACK)
    -- Example: No refunds allowed within 24 hours of CheckIn
    DECLARE @CheckInDate DATE;
    SELECT @CheckInDate = CheckInDate FROM dbo.Reservations WHERE ReservationID = @CancelResID;

    IF DATEDIFF(HOUR, GETDATE(), CAST(@CheckInDate AS DATETIME)) < 24
    BEGIN
        RAISERROR('Cancellation rejected: Check-in is within 24 hours. No refund applicable.', 16, 1);
    END

    COMMIT TRANSACTION;
    PRINT 'TRANSACTION 3 COMMITTED.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'TRANSACTION 3 ROLLED BACK. Reason: ' + ERROR_MESSAGE();
    PRINT '→ All cancellation changes have been reversed.';
END CATCH;
GO

-- ============================================================
-- TRANSACTION 4: Room Swap (transfer a guest to a different room)
-- ============================================================
PRINT '========== TRANSACTION 4: Room Swap (COMMIT) ==========';
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @SwapResID    INT  = 7;
    DECLARE @OldRoomID    INT;
    DECLARE @NewRoomID    INT  = 5;  -- Upgrade to Suite

    SELECT @OldRoomID = RoomID FROM dbo.Reservations WHERE ReservationID = @SwapResID;

    -- Verify new room is available
    IF NOT EXISTS (SELECT 1 FROM dbo.Rooms WHERE RoomID = @NewRoomID AND Status = 'Available')
    BEGIN
        RAISERROR('Target room is not available for swap.', 16, 1);
    END

    -- Update reservation with new room
    UPDATE dbo.Reservations SET RoomID = @NewRoomID WHERE ReservationID = @SwapResID;
    PRINT 'Step 1: Reservation room updated.';

    -- Free old room
    UPDATE dbo.Rooms SET Status = 'Available' WHERE RoomID = @OldRoomID;
    PRINT 'Step 2: Old room freed.';

    -- Mark new room as Occupied
    UPDATE dbo.Rooms SET Status = 'Occupied' WHERE RoomID = @NewRoomID;
    PRINT 'Step 3: New room marked Occupied.';

    -- Log in audit table
    INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, OldValue, NewValue)
    VALUES ('Reservations', 'UPDATE', @SwapResID,
            'RoomID=' + CAST(@OldRoomID AS VARCHAR),
            'RoomID=' + CAST(@NewRoomID AS VARCHAR) + ' (Room Swap)');

    COMMIT TRANSACTION;
    PRINT 'TRANSACTION 4 COMMITTED: Room swap successful.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'TRANSACTION 4 ROLLED BACK. Error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ============================================================
-- DCL: GRANT and REVOKE
-- Simulate role-based access control
-- ============================================================

-- Create logins (run as sysadmin; adjust if needed in your environment)
-- Uncomment the CREATE LOGIN blocks if running on a local SQL Server instance.

-- CREATE LOGIN HotelReceptionist WITH PASSWORD = 'Receptionist@123';
-- CREATE LOGIN HotelManager      WITH PASSWORD = 'Manager@456';
-- CREATE LOGIN HotelAuditor      WITH PASSWORD = 'Auditor@789';
-- CREATE LOGIN HotelReports      WITH PASSWORD = 'Reports@321';

-- CREATE USER HotelReceptionist FOR LOGIN HotelReceptionist;
-- CREATE USER HotelManager      FOR LOGIN HotelManager;
-- CREATE USER HotelAuditor      FOR LOGIN HotelAuditor;
-- CREATE USER HotelReports      FOR LOGIN HotelReports;

-- ============================================================
-- GRANT: Receptionist — can view & insert bookings/payments
-- ============================================================
-- GRANT SELECT, INSERT ON dbo.Reservations TO HotelReceptionist;
-- GRANT SELECT, INSERT ON dbo.Payments     TO HotelReceptionist;
-- GRANT SELECT         ON dbo.Customers    TO HotelReceptionist;
-- GRANT SELECT         ON dbo.Rooms        TO HotelReceptionist;
-- GRANT SELECT         ON dbo.RoomCategories TO HotelReceptionist;
-- GRANT SELECT         ON dbo.Hotels       TO HotelReceptionist;

-- ============================================================
-- GRANT: Manager — full data access, no schema changes
-- ============================================================
-- GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Reservations TO HotelManager;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Payments     TO HotelManager;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Customers    TO HotelManager;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Rooms        TO HotelManager;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Staff        TO HotelManager;
-- GRANT SELECT ON dbo.AuditLog         TO HotelManager;

-- ============================================================
-- GRANT: Auditor — read-only access to all tables
-- ============================================================
-- GRANT SELECT ON dbo.AuditLog      TO HotelAuditor;
-- GRANT SELECT ON dbo.Payments      TO HotelAuditor;
-- GRANT SELECT ON dbo.Reservations  TO HotelAuditor;
-- GRANT SELECT ON dbo.Customers     TO HotelAuditor;

-- ============================================================
-- GRANT: Reports user — can only use views, not base tables
-- ============================================================
-- GRANT SELECT ON dbo.vw_ActiveReservations  TO HotelReports;
-- GRANT SELECT ON dbo.vw_RevenueByHotel      TO HotelReports;
-- GRANT SELECT ON dbo.vw_OccupancyRate       TO HotelReports;
-- GRANT SELECT ON dbo.vw_PaymentSummary      TO HotelReports;
-- GRANT SELECT ON dbo.vw_CustomerHistory     TO HotelReports;

-- ============================================================
-- REVOKE: Remove update privilege from Receptionist
-- ============================================================
-- REVOKE UPDATE ON dbo.Reservations FROM HotelReceptionist;

-- ============================================================
-- Verify: Check current permissions
-- ============================================================
SELECT
    dp.name         AS Principal,
    dp.type_desc    AS PrincipalType,
    o.name          AS ObjectName,
    p.permission_name,
    p.state_desc    AS GrantStatus
FROM sys.database_permissions p
INNER JOIN sys.database_principals dp ON dp.principal_id = p.grantee_principal_id
INNER JOIN sys.objects             o  ON o.object_id     = p.major_id
WHERE dp.name IN ('HotelReceptionist','HotelManager','HotelAuditor','HotelReports')
ORDER BY dp.name, o.name;
GO

PRINT 'TCL and DCL scripts executed successfully.';
GO