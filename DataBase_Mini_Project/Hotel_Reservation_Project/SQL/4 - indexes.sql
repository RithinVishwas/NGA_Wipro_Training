-- ============================================================
-- Hotel Reservation System - Indexes
-- Sprint 2: Clustered & Non-Clustered Index Creation
-- ============================================================

USE Demo2_HotelReservationDB;
GO

-- ============================================================
-- Non-Clustered Indexes on Reservations
-- (Most queried table — needs heavy indexing)
-- ============================================================

-- Index on CustomerID (frequent JOIN and WHERE filter)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Reservations_CustomerID' AND object_id = OBJECT_ID('dbo.Reservations'))
CREATE NONCLUSTERED INDEX IX_Reservations_CustomerID
    ON dbo.Reservations (CustomerID)
    INCLUDE (RoomID, CheckInDate, CheckOutDate, Status, TotalAmount);
GO

-- Index on RoomID + CheckInDate + CheckOutDate (availability checks)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Reservations_Room_Dates' AND object_id = OBJECT_ID('dbo.Reservations'))
CREATE NONCLUSTERED INDEX IX_Reservations_Room_Dates
    ON dbo.Reservations (RoomID, CheckInDate, CheckOutDate)
    INCLUDE (Status);
GO

-- Index on Status (filter by Confirmed, CheckedIn, etc.)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Reservations_Status' AND object_id = OBJECT_ID('dbo.Reservations'))
CREATE NONCLUSTERED INDEX IX_Reservations_Status
    ON dbo.Reservations (Status)
    INCLUDE (CustomerID, RoomID, TotalAmount, CheckInDate, CheckOutDate);
GO

-- Index on CheckInDate (date range queries, scheduling)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Reservations_CheckInDate' AND object_id = OBJECT_ID('dbo.Reservations'))
CREATE NONCLUSTERED INDEX IX_Reservations_CheckInDate
    ON dbo.Reservations (CheckInDate, CheckOutDate);
GO

-- ============================================================
-- Non-Clustered Indexes on Rooms
-- ============================================================

-- Index on HotelID + Status (room availability per hotel)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Rooms_HotelID_Status' AND object_id = OBJECT_ID('dbo.Rooms'))
CREATE NONCLUSTERED INDEX IX_Rooms_HotelID_Status
    ON dbo.Rooms (HotelID, Status)
    INCLUDE (CategoryID, RoomNumber, Floor, BedType);
GO

-- Index on CategoryID (filter by room type)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Rooms_CategoryID' AND object_id = OBJECT_ID('dbo.Rooms'))
CREATE NONCLUSTERED INDEX IX_Rooms_CategoryID
    ON dbo.Rooms (CategoryID, Status);
GO

-- ============================================================
-- Non-Clustered Indexes on Payments
-- ============================================================

-- Index on ReservationID + Status (payment lookups)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Payments_ReservationID' AND object_id = OBJECT_ID('dbo.Payments'))
CREATE NONCLUSTERED INDEX IX_Payments_ReservationID
    ON dbo.Payments (ReservationID, Status)
    INCLUDE (Amount, PaymentMethod, PaymentDate);
GO

-- Index on PaymentDate (monthly revenue reports)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Payments_PaymentDate' AND object_id = OBJECT_ID('dbo.Payments'))
CREATE NONCLUSTERED INDEX IX_Payments_PaymentDate
    ON dbo.Payments (PaymentDate, Status)
    INCLUDE (Amount);
GO

-- ============================================================
-- Non-Clustered Indexes on Customers
-- ============================================================

-- Index on Email (fast customer lookup)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Customers_Email' AND object_id = OBJECT_ID('dbo.Customers'))
CREATE NONCLUSTERED INDEX IX_Customers_Email
    ON dbo.Customers (Email)
    INCLUDE (FirstName, LastName, Phone, MembershipTier);
GO

-- Index on MembershipTier (loyalty program queries)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Customers_MembershipTier' AND object_id = OBJECT_ID('dbo.Customers'))
CREATE NONCLUSTERED INDEX IX_Customers_MembershipTier
    ON dbo.Customers (MembershipTier)
    INCLUDE (CustomerID, FirstName, LastName, LoyaltyPoints);
GO

-- ============================================================
-- Non-Clustered Index on AuditLog
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AuditLog_Table_Op' AND object_id = OBJECT_ID('dbo.AuditLog'))
CREATE NONCLUSTERED INDEX IX_AuditLog_Table_Op
    ON dbo.AuditLog (TableName, Operation, ChangedAt);
GO

-- ============================================================
-- Verify indexes created
-- ============================================================
SELECT
    t.name          AS TableName,
    i.name          AS IndexName,
    i.type_desc     AS IndexType,
    i.is_unique     AS IsUnique
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.name IS NOT NULL
  AND t.name IN ('Reservations','Rooms','Payments','Customers','AuditLog')
ORDER BY t.name, i.name;
GO

-- ============================================================
-- Performance validation: Compare query plan with/without index
-- Run this query and view Execution Plan (Ctrl+M in SSMS)
-- ============================================================
-- Availability check query (should use IX_Reservations_Room_Dates)
SELECT r.RoomID, r.CheckInDate, r.CheckOutDate, r.Status
FROM dbo.Reservations r
WHERE r.RoomID = 5
  AND r.Status NOT IN ('Cancelled','CheckedOut')
  AND r.CheckInDate  < '2025-08-05'
  AND r.CheckOutDate > '2025-08-01';
GO

PRINT 'All indexes created and verified.';
GO