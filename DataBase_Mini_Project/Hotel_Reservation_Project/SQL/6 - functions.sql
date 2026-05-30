-- ============================================================
-- Hotel Reservation System - Functions
-- Sprint 3: Scalar & Table-Valued Functions
-- ============================================================

USE Demo2_HotelReservationDB;
GO

-- ============================================================
-- SCALAR FUNCTION 1: fn_CalculateRoomCharge
-- Calculates total charge for a room stay
-- Inputs: RoomID, CheckInDate, CheckOutDate, DiscountPercent
-- Returns: Total amount after discount
-- ============================================================
IF OBJECT_ID('dbo.fn_CalculateRoomCharge', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_CalculateRoomCharge;
GO

CREATE FUNCTION dbo.fn_CalculateRoomCharge
(
    @RoomID         INT,
    @CheckInDate    DATE,
    @CheckOutDate   DATE,
    @DiscountPct    DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @BasePrice    DECIMAL(10,2);
    DECLARE @Nights       INT;
    DECLARE @GrossAmount  DECIMAL(10,2);
    DECLARE @NetAmount    DECIMAL(10,2);

    SELECT @BasePrice = rc.BasePrice
    FROM dbo.Rooms          rm
    INNER JOIN dbo.RoomCategories rc ON rc.CategoryID = rm.CategoryID
    WHERE rm.RoomID = @RoomID;

    SET @Nights      = DATEDIFF(DAY, @CheckInDate, @CheckOutDate);
    SET @GrossAmount = @BasePrice * @Nights;
    SET @NetAmount   = @GrossAmount - (@GrossAmount * @DiscountPct / 100);

    RETURN ROUND(@NetAmount, 2);
END;
GO

-- ============================================================
-- SCALAR FUNCTION 2: fn_GetCustomerMembershipTier
-- Returns the current membership tier based on loyalty points
-- Input: CustomerID
-- Returns: Tier name as VARCHAR
-- ============================================================
IF OBJECT_ID('dbo.fn_GetCustomerMembershipTier', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_GetCustomerMembershipTier;
GO

CREATE FUNCTION dbo.fn_GetCustomerMembershipTier
(
    @CustomerID INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Points INT;
    DECLARE @Tier   VARCHAR(20);

    SELECT @Points = LoyaltyPoints FROM dbo.Customers WHERE CustomerID = @CustomerID;

    SET @Tier = CASE
        WHEN @Points >= 2500 THEN 'Platinum'
        WHEN @Points >= 1000 THEN 'Gold'
        WHEN @Points >= 500  THEN 'Silver'
        ELSE 'Bronze'
    END;

    RETURN @Tier;
END;
GO

-- ============================================================
-- SCALAR FUNCTION 3: fn_IsRoomAvailable
-- Checks if a room is available for given dates
-- Returns: 1 (Available) or 0 (Not Available)
-- ============================================================
IF OBJECT_ID('dbo.fn_IsRoomAvailable', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_IsRoomAvailable;
GO

CREATE FUNCTION dbo.fn_IsRoomAvailable
(
    @RoomID      INT,
    @CheckIn     DATE,
    @CheckOut    DATE
)
RETURNS BIT
AS
BEGIN
    DECLARE @Conflicts INT;

    SELECT @Conflicts = COUNT(*)
    FROM dbo.Reservations
    WHERE RoomID     = @RoomID
      AND Status NOT IN ('Cancelled', 'CheckedOut')
      AND CheckInDate  < @CheckOut
      AND CheckOutDate > @CheckIn;

    RETURN CASE WHEN @Conflicts = 0 THEN 1 ELSE 0 END;
END;
GO

-- ============================================================
-- SCALAR FUNCTION 4: fn_GetHotelOccupancyRate
-- Returns occupancy rate % for a hotel
-- Input: HotelID
-- Returns: DECIMAL occupancy percentage
-- ============================================================
IF OBJECT_ID('dbo.fn_GetHotelOccupancyRate', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_GetHotelOccupancyRate;
GO

CREATE FUNCTION dbo.fn_GetHotelOccupancyRate
(
    @HotelID INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Total    INT;
    DECLARE @Occupied INT;
    DECLARE @Rate     DECIMAL(5,2);

    SELECT @Total    = COUNT(*) FROM dbo.Rooms WHERE HotelID = @HotelID;
    SELECT @Occupied = COUNT(*) FROM dbo.Rooms WHERE HotelID = @HotelID AND Status IN ('Occupied','Reserved');

    IF @Total = 0
        RETURN 0.00;

    SET @Rate = ROUND(100.0 * @Occupied / @Total, 2);
    RETURN @Rate;
END;
GO

-- ============================================================
-- TABLE-VALUED FUNCTION 1: fn_GetAvailableRooms
-- Returns available rooms for given hotel, date range, category
-- ============================================================
IF OBJECT_ID('dbo.fn_GetAvailableRooms', 'IF') IS NOT NULL DROP FUNCTION dbo.fn_GetAvailableRooms;
GO

CREATE FUNCTION dbo.fn_GetAvailableRooms
(
    @HotelID    INT,
    @CheckIn    DATE,
    @CheckOut   DATE,
    @CategoryID INT = NULL   -- NULL means all categories
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        rm.RoomID,
        rm.RoomNumber,
        rm.Floor,
        rm.BedType,
        rm.HasBalcony,
        rm.HasSeaView,
        rc.CategoryName,
        rc.BasePrice,
        rc.MaxOccupancy,
        rc.BasePrice * DATEDIFF(DAY, @CheckIn, @CheckOut) AS EstimatedTotal
    FROM dbo.Rooms rm
    INNER JOIN dbo.RoomCategories rc ON rc.CategoryID = rm.CategoryID
    WHERE rm.HotelID = @HotelID
      AND rm.Status  = 'Available'
      AND (@CategoryID IS NULL OR rm.CategoryID = @CategoryID)
      AND NOT EXISTS (
            SELECT 1
            FROM dbo.Reservations r
            WHERE r.RoomID       = rm.RoomID
              AND r.Status NOT IN ('Cancelled','CheckedOut')
              AND r.CheckInDate  < @CheckOut
              AND r.CheckOutDate > @CheckIn
          )
);
GO

-- ============================================================
-- TABLE-VALUED FUNCTION 2: fn_GetCustomerReservationHistory
-- Returns full reservation history for a customer
-- ============================================================
IF OBJECT_ID('dbo.fn_GetCustomerReservationHistory', 'IF') IS NOT NULL DROP FUNCTION dbo.fn_GetCustomerReservationHistory;
GO

CREATE FUNCTION dbo.fn_GetCustomerReservationHistory
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        r.ReservationID,
        h.HotelName,
        h.City,
        rm.RoomNumber,
        rc.CategoryName                      AS RoomType,
        r.CheckInDate,
        r.CheckOutDate,
        DATEDIFF(DAY, r.CheckInDate, r.CheckOutDate) AS Nights,
        r.Adults,
        r.Children,
        r.TotalAmount,
        r.DiscountPercent,
        r.Status,
        p.Amount                             AS AmountPaid,
        p.PaymentMethod,
        p.PaymentDate
    FROM dbo.Reservations r
    INNER JOIN dbo.Rooms          rm ON rm.RoomID      = r.RoomID
    INNER JOIN dbo.Hotels         h  ON h.HotelID      = rm.HotelID
    INNER JOIN dbo.RoomCategories rc ON rc.CategoryID  = rm.CategoryID
    LEFT JOIN  dbo.Payments       p  ON p.ReservationID = r.ReservationID
    WHERE r.CustomerID = @CustomerID
);
GO

-- ============================================================
-- TABLE-VALUED FUNCTION 3: fn_GetHotelRevenueReport
-- Returns daily revenue breakdown for a hotel in a date range
-- ============================================================
IF OBJECT_ID('dbo.fn_GetHotelRevenueReport', 'IF') IS NOT NULL DROP FUNCTION dbo.fn_GetHotelRevenueReport;
GO

CREATE FUNCTION dbo.fn_GetHotelRevenueReport
(
    @HotelID   INT,
    @FromDate  DATE,
    @ToDate    DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        CAST(p.PaymentDate AS DATE)          AS PaymentDay,
        COUNT(p.PaymentID)                   AS Transactions,
        SUM(p.Amount)                        AS DailyRevenue,
        p.PaymentMethod
    FROM dbo.Payments     p
    INNER JOIN dbo.Reservations r  ON r.ReservationID = p.ReservationID
    INNER JOIN dbo.Rooms        rm ON rm.RoomID        = r.RoomID
    WHERE rm.HotelID     = @HotelID
      AND CAST(p.PaymentDate AS DATE) BETWEEN @FromDate AND @ToDate
      AND p.Status = 'Completed'
    GROUP BY CAST(p.PaymentDate AS DATE), p.PaymentMethod
);
GO

-- ============================================================
-- Function USAGE DEMOS
-- ============================================================

-- Scalar function: Calculate charge for Room 5, 3 nights, 10% discount
SELECT dbo.fn_CalculateRoomCharge(5, '2025-08-01', '2025-08-04', 10.00) AS ChargeAfterDiscount;
GO

-- Scalar function: Check availability of Room 3 for given dates
SELECT dbo.fn_IsRoomAvailable(3, '2025-08-01', '2025-08-05') AS IsAvailable;
GO

-- Scalar function: Get occupancy rate of Hotel 1
SELECT dbo.fn_GetHotelOccupancyRate(1) AS OccupancyRatePercent;
GO

-- Scalar function: Get tier of Customer 10
SELECT dbo.fn_GetCustomerMembershipTier(10) AS MembershipTier;
GO

-- Table-valued function: Available rooms in Hotel 1 for August
SELECT * FROM dbo.fn_GetAvailableRooms(1, '2025-08-01', '2025-08-05', NULL)
ORDER BY BasePrice;
GO

-- Table-valued function: Customer 2 reservation history
SELECT * FROM dbo.fn_GetCustomerReservationHistory(2)
ORDER BY CheckInDate;
GO

-- Table-valued function: Revenue report for Hotel 1 in June 2025
SELECT * FROM dbo.fn_GetHotelRevenueReport(1, '2025-06-01', '2025-06-30')
ORDER BY PaymentDay;
GO

PRINT 'All functions created successfully.';
GO