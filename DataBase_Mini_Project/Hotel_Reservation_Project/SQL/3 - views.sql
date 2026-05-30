-- ============================================================
-- Hotel Reservation System - Views
-- Sprint 2: Simple, Join-based, and Aggregate Views
-- ============================================================

USE Demo2_HotelReservationDB;
GO

-- ============================================================
-- VIEW 1: vw_ActiveReservations
-- Simple view — currently active (Confirmed / CheckedIn) bookings
-- ============================================================
IF OBJECT_ID('dbo.vw_ActiveReservations', 'V') IS NOT NULL DROP VIEW dbo.vw_ActiveReservations;
GO
CREATE VIEW dbo.vw_ActiveReservations AS
SELECT
    r.ReservationID,
    c.FirstName + ' ' + c.LastName          AS CustomerName,
    c.Phone                                  AS CustomerPhone,
    c.Email                                  AS CustomerEmail,
    h.HotelName,
    h.City,
    rm.RoomNumber,
    rc.CategoryName                          AS RoomType,
    rm.BedType,
    r.CheckInDate,
    r.CheckOutDate,
    DATEDIFF(DAY, r.CheckInDate, r.CheckOutDate) AS Nights,
    r.Adults,
    r.Children,
    r.TotalAmount,
    r.DiscountPercent,
    r.Status,
    r.SpecialRequests
FROM dbo.Reservations r
INNER JOIN dbo.Customers      c  ON r.CustomerID  = c.CustomerID
INNER JOIN dbo.Rooms          rm ON r.RoomID       = rm.RoomID
INNER JOIN dbo.Hotels         h  ON rm.HotelID     = h.HotelID
INNER JOIN dbo.RoomCategories rc ON rm.CategoryID  = rc.CategoryID
WHERE r.Status IN ('Confirmed', 'CheckedIn');
GO

-- ============================================================
-- VIEW 2: vw_RoomAvailability
-- Join-based view — real-time availability for all rooms
-- ============================================================
IF OBJECT_ID('dbo.vw_RoomAvailability', 'V') IS NOT NULL DROP VIEW dbo.vw_RoomAvailability;
GO
CREATE VIEW dbo.vw_RoomAvailability AS
SELECT
    h.HotelID,
    h.HotelName,
    h.City,
    h.StarRating,
    rm.RoomID,
    rm.RoomNumber,
    rm.Floor,
    rm.Status                    AS RoomStatus,
    rm.BedType,
    rm.HasBalcony,
    rm.HasSeaView,
    rc.CategoryName              AS RoomType,
    rc.BasePrice                 AS PricePerNight,
    rc.MaxOccupancy
FROM dbo.Rooms          rm
INNER JOIN dbo.Hotels         h  ON rm.HotelID    = h.HotelID
INNER JOIN dbo.RoomCategories rc ON rm.CategoryID = rc.CategoryID;
GO

-- ============================================================
-- VIEW 3: vw_RevenueByHotel
-- Aggregate view — revenue summary per hotel
-- ============================================================
IF OBJECT_ID('dbo.vw_RevenueByHotel', 'V') IS NOT NULL DROP VIEW dbo.vw_RevenueByHotel;
GO
CREATE VIEW dbo.vw_RevenueByHotel AS
SELECT
    h.HotelID,
    h.HotelName,
    h.City,
    h.StarRating,
    COUNT(DISTINCT r.ReservationID)                    AS TotalReservations,
    COUNT(DISTINCT CASE WHEN r.Status='CheckedOut' THEN r.ReservationID END) AS CompletedStays,
    COUNT(DISTINCT CASE WHEN r.Status='Cancelled'  THEN r.ReservationID END) AS Cancellations,
    ISNULL(SUM(CASE WHEN p.Status='Completed' THEN p.Amount END), 0) AS TotalRevenue,
    ISNULL(AVG(CASE WHEN p.Status='Completed' THEN p.Amount END), 0) AS AvgBookingValue
FROM dbo.Hotels h
LEFT JOIN dbo.Rooms        rm ON rm.HotelID      = h.HotelID
LEFT JOIN dbo.Reservations r  ON r.RoomID        = rm.RoomID
LEFT JOIN dbo.Payments     p  ON p.ReservationID = r.ReservationID
GROUP BY h.HotelID, h.HotelName, h.City, h.StarRating;
GO

-- ============================================================
-- VIEW 4: vw_CustomerHistory
-- Join-based view — full booking history per customer
-- ============================================================
IF OBJECT_ID('dbo.vw_CustomerHistory', 'V') IS NOT NULL DROP VIEW dbo.vw_CustomerHistory;
GO
CREATE VIEW dbo.vw_CustomerHistory AS
SELECT
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Email,
    c.Phone,
    c.MembershipTier,
    c.LoyaltyPoints,
    r.ReservationID,
    h.HotelName,
    h.City,
    rm.RoomNumber,
    rc.CategoryName              AS RoomType,
    r.CheckInDate,
    r.CheckOutDate,
    DATEDIFF(DAY, r.CheckInDate, r.CheckOutDate) AS Nights,
    r.TotalAmount,
    r.Status                     AS ReservationStatus,
    p.Amount                     AS AmountPaid,
    p.PaymentMethod,
    p.Status                     AS PaymentStatus
FROM dbo.Customers    c
LEFT JOIN dbo.Reservations    r  ON r.CustomerID   = c.CustomerID
LEFT JOIN dbo.Rooms           rm ON r.RoomID        = rm.RoomID
LEFT JOIN dbo.Hotels          h  ON rm.HotelID      = h.HotelID
LEFT JOIN dbo.RoomCategories  rc ON rm.CategoryID   = rc.CategoryID
LEFT JOIN dbo.Payments        p  ON p.ReservationID = r.ReservationID;
GO

-- ============================================================
-- VIEW 5: vw_OccupancyRate
-- Aggregate view — occupancy statistics per hotel
-- ============================================================
IF OBJECT_ID('dbo.vw_OccupancyRate', 'V') IS NOT NULL DROP VIEW dbo.vw_OccupancyRate;
GO
CREATE VIEW dbo.vw_OccupancyRate AS
SELECT
    h.HotelName,
    h.City,
    h.TotalRooms,
    COUNT(rm.RoomID)            AS RegisteredRooms,
    SUM(CASE WHEN rm.Status = 'Available'        THEN 1 ELSE 0 END) AS AvailableRooms,
    SUM(CASE WHEN rm.Status = 'Occupied'         THEN 1 ELSE 0 END) AS OccupiedRooms,
    SUM(CASE WHEN rm.Status = 'Reserved'         THEN 1 ELSE 0 END) AS ReservedRooms,
    SUM(CASE WHEN rm.Status = 'UnderMaintenance' THEN 1 ELSE 0 END) AS MaintenanceRooms,
    CAST(
        ROUND(
            100.0 * SUM(CASE WHEN rm.Status IN ('Occupied','Reserved') THEN 1 ELSE 0 END)
            / NULLIF(COUNT(rm.RoomID), 0)
        , 2)
    AS DECIMAL(5,2))            AS OccupancyRatePercent
FROM dbo.Hotels h
INNER JOIN dbo.Rooms rm ON rm.HotelID = h.HotelID
GROUP BY h.HotelID, h.HotelName, h.City, h.TotalRooms;
GO

-- ============================================================
-- VIEW 6: vw_PaymentSummary
-- Aggregate view — payment status overview
-- ============================================================
IF OBJECT_ID('dbo.vw_PaymentSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_PaymentSummary;
GO
CREATE VIEW dbo.vw_PaymentSummary AS
SELECT
    r.ReservationID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    h.HotelName,
    r.TotalAmount,
    ISNULL(SUM(CASE WHEN p.Status='Completed' THEN p.Amount END), 0) AS PaidAmount,
    r.TotalAmount - ISNULL(SUM(CASE WHEN p.Status='Completed' THEN p.Amount END), 0) AS BalanceDue,
    CASE
        WHEN r.TotalAmount - ISNULL(SUM(CASE WHEN p.Status='Completed' THEN p.Amount END), 0) = 0
            THEN 'Fully Paid'
        WHEN ISNULL(SUM(CASE WHEN p.Status='Completed' THEN p.Amount END), 0) = 0
            THEN 'Unpaid'
        ELSE 'Partially Paid'
    END                            AS PaymentStatus,
    r.Status                       AS ReservationStatus
FROM dbo.Reservations r
INNER JOIN dbo.Customers c  ON r.CustomerID  = c.CustomerID
INNER JOIN dbo.Rooms     rm ON r.RoomID      = rm.RoomID
INNER JOIN dbo.Hotels    h  ON rm.HotelID    = h.HotelID
LEFT JOIN  dbo.Payments  p  ON p.ReservationID = r.ReservationID
GROUP BY r.ReservationID, c.FirstName, c.LastName, h.HotelName,
         r.TotalAmount, r.Status;
GO

-- ============================================================
-- Sample SELECT from views
-- ============================================================
SELECT * FROM dbo.vw_ActiveReservations        ORDER BY CheckInDate;
SELECT * FROM dbo.vw_RoomAvailability          WHERE RoomStatus = 'Available' ORDER BY HotelName;
SELECT * FROM dbo.vw_RevenueByHotel            ORDER BY TotalRevenue DESC;
SELECT * FROM dbo.vw_OccupancyRate             ORDER BY OccupancyRatePercent DESC;
SELECT * FROM dbo.vw_PaymentSummary            WHERE BalanceDue > 0;
GO

PRINT 'All views created successfully.';
GO