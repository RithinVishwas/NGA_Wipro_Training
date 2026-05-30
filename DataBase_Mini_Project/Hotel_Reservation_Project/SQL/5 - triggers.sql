-- ============================================================
-- Hotel Reservation System - Triggers
-- Sprint 3: AFTER INSERT, UPDATE, DELETE triggers
-- ============================================================

USE Demo2_HotelReservationDB;
GO

-- ============================================================
-- TRIGGER 1: trg_AfterInsertReservation
-- After a new reservation is inserted:
--   - Update room Status to 'Reserved'
--   - Log to AuditLog
-- ============================================================
IF OBJECT_ID('dbo.trg_AfterInsertReservation', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AfterInsertReservation;
GO

CREATE TRIGGER dbo.trg_AfterInsertReservation
ON dbo.Reservations
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update room status to Reserved
    UPDATE dbo.Rooms
    SET Status = 'Reserved'
    WHERE RoomID IN (SELECT RoomID FROM inserted)
      AND Status = 'Available';

    -- Audit log
    INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, NewValue)
    SELECT
        'Reservations',
        'INSERT',
        i.ReservationID,
        'CustomerID=' + CAST(i.CustomerID AS VARCHAR) +
        ', RoomID='   + CAST(i.RoomID     AS VARCHAR) +
        ', CheckIn='  + CAST(i.CheckInDate AS VARCHAR) +
        ', CheckOut=' + CAST(i.CheckOutDate AS VARCHAR) +
        ', Amount='   + CAST(i.TotalAmount AS VARCHAR) +
        ', Status='   + i.Status
    FROM inserted i;

    PRINT 'Reservation created. Room status updated to Reserved.';
END;
GO

-- ============================================================
-- TRIGGER 2: trg_AfterUpdateReservation
-- After a reservation is updated:
--   - If status changes to CheckedIn  → Room becomes Occupied
--   - If status changes to CheckedOut → Room becomes Available
--   - If status changes to Cancelled  → Room becomes Available
--   - Log change to AuditLog
-- ============================================================
IF OBJECT_ID('dbo.trg_AfterUpdateReservation', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AfterUpdateReservation;
GO

CREATE TRIGGER dbo.trg_AfterUpdateReservation
ON dbo.Reservations
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Room → Occupied when customer checks in
    UPDATE dbo.Rooms
    SET Status = 'Occupied'
    WHERE RoomID IN (
        SELECT i.RoomID FROM inserted i
        INNER JOIN deleted d ON d.ReservationID = i.ReservationID
        WHERE i.Status = 'CheckedIn' AND d.Status != 'CheckedIn'
    );

    -- Room → Available when customer checks out or cancels
    UPDATE dbo.Rooms
    SET Status = 'Available'
    WHERE RoomID IN (
        SELECT i.RoomID FROM inserted i
        INNER JOIN deleted d ON d.ReservationID = i.ReservationID
        WHERE i.Status IN ('CheckedOut','Cancelled')
          AND d.Status NOT IN ('CheckedOut','Cancelled')
    );

    -- Audit log
    INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, OldValue, NewValue)
    SELECT
        'Reservations',
        'UPDATE',
        i.ReservationID,
        'Status=' + d.Status + ', Amount=' + CAST(d.TotalAmount AS VARCHAR),
        'Status=' + i.Status + ', Amount=' + CAST(i.TotalAmount AS VARCHAR)
    FROM inserted i
    INNER JOIN deleted d ON d.ReservationID = i.ReservationID;

    PRINT 'Reservation updated. Room status synchronized.';
END;
GO

-- ============================================================
-- TRIGGER 3: trg_AfterDeleteReservation
-- After a reservation is deleted:
--   - Set room Status back to Available
--   - Log deletion to AuditLog
-- ============================================================
IF OBJECT_ID('dbo.trg_AfterDeleteReservation', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AfterDeleteReservation;
GO

CREATE TRIGGER dbo.trg_AfterDeleteReservation
ON dbo.Reservations
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Free up the room
    UPDATE dbo.Rooms
    SET Status = 'Available'
    WHERE RoomID IN (SELECT RoomID FROM deleted);

    -- Audit log
    INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, OldValue)
    SELECT
        'Reservations',
        'DELETE',
        d.ReservationID,
        'CustomerID=' + CAST(d.CustomerID AS VARCHAR) +
        ', RoomID='   + CAST(d.RoomID     AS VARCHAR) +
        ', Status='   + d.Status +
        ', Amount='   + CAST(d.TotalAmount AS VARCHAR)
    FROM deleted d;

    PRINT 'Reservation deleted. Room status reset to Available.';
END;
GO

-- ============================================================
-- TRIGGER 4: trg_AfterInsertPayment
-- After a payment is inserted:
--   - Update customer loyalty points (+1 point per ₹100 paid)
--   - Auto-upgrade membership tier
--   - Log to AuditLog
-- ============================================================
IF OBJECT_ID('dbo.trg_AfterInsertPayment', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AfterInsertPayment;
GO

CREATE TRIGGER dbo.trg_AfterInsertPayment
ON dbo.Payments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Award 1 loyalty point per ₹100 for completed payments
    UPDATE dbo.Customers
    SET LoyaltyPoints = LoyaltyPoints + CAST(i.Amount / 100 AS INT)
    FROM dbo.Customers c
    INNER JOIN dbo.Reservations r ON r.CustomerID = c.CustomerID
    INNER JOIN inserted          i ON i.ReservationID = r.ReservationID
    WHERE i.Status = 'Completed';

    -- Auto-update membership tier
    UPDATE dbo.Customers
    SET MembershipTier =
        CASE
            WHEN LoyaltyPoints >= 2500 THEN 'Platinum'
            WHEN LoyaltyPoints >= 1000 THEN 'Gold'
            WHEN LoyaltyPoints >= 500  THEN 'Silver'
            ELSE 'Bronze'
        END
    WHERE CustomerID IN (
        SELECT r.CustomerID
        FROM dbo.Reservations r
        INNER JOIN inserted i ON i.ReservationID = r.ReservationID
        WHERE i.Status = 'Completed'
    );

    -- Audit log
    INSERT INTO dbo.AuditLog (TableName, Operation, RecordID, NewValue)
    SELECT
        'Payments',
        'INSERT',
        i.PaymentID,
        'ReservationID=' + CAST(i.ReservationID AS VARCHAR) +
        ', Amount='      + CAST(i.Amount         AS VARCHAR) +
        ', Method='      + i.PaymentMethod +
        ', Status='      + i.Status
    FROM inserted i;

    PRINT 'Payment recorded. Loyalty points updated.';
END;
GO

-- ============================================================
-- TRIGGER 5: trg_PreventDoubleBooking
-- INSTEAD OF INSERT on Reservations:
--   - Checks if room is already booked for overlapping dates
--   - Rejects booking if conflict found
-- ============================================================
IF OBJECT_ID('dbo.trg_PreventDoubleBooking', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_PreventDoubleBooking;
GO

CREATE TRIGGER dbo.trg_PreventDoubleBooking
ON dbo.Reservations
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Conflict INT;

    SELECT @Conflict = COUNT(*)
    FROM dbo.Reservations r
    INNER JOIN inserted i ON i.RoomID = r.RoomID
    WHERE r.Status NOT IN ('Cancelled', 'CheckedOut')
      AND r.CheckInDate  < i.CheckOutDate
      AND r.CheckOutDate > i.CheckInDate;

    IF @Conflict > 0
    BEGIN
        RAISERROR('Double booking detected: Room is already reserved for the selected dates.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- If no conflict, proceed with insert
    INSERT INTO dbo.Reservations
        (CustomerID, RoomID, StaffID, CheckInDate, CheckOutDate,
         ActualCheckIn, ActualCheckOut, Adults, Children, Status,
         SpecialRequests, TotalAmount, DiscountPercent, CreatedAt)
    SELECT
        CustomerID, RoomID, StaffID, CheckInDate, CheckOutDate,
        ActualCheckIn, ActualCheckOut, Adults, Children, Status,
        SpecialRequests, TotalAmount, DiscountPercent, CreatedAt
    FROM inserted;

    PRINT 'Reservation created successfully. No double booking conflict.';
END;
GO

-- ============================================================
-- TRIGGER DEMO: Test the triggers
-- ============================================================

-- Test 1: Insert a new reservation → should trigger Room → Reserved
-- (Uses a customer and available room)
-- INSERT INTO dbo.Reservations (CustomerID, RoomID, StaffID, CheckInDate, CheckOutDate, Adults, Status, TotalAmount)
-- VALUES (3, 12, 8, '2025-08-10', '2025-08-13', 2, 'Confirmed', 7500.00);

-- Test 2: Update status to CheckedIn → Room becomes Occupied
-- UPDATE dbo.Reservations SET Status='CheckedIn', ActualCheckIn=GETDATE() WHERE ReservationID=9;

-- Test 3: Update status to CheckedOut → Room becomes Available
-- UPDATE dbo.Reservations SET Status='CheckedOut', ActualCheckOut=GETDATE() WHERE ReservationID=9;

-- Test 4: Cancel a booking → Room becomes Available
-- UPDATE dbo.Reservations SET Status='Cancelled' WHERE ReservationID=10;

-- View AuditLog after trigger runs
SELECT TOP 20 * FROM dbo.AuditLog ORDER BY ChangedAt DESC;
GO

PRINT 'All triggers created successfully.';
GO