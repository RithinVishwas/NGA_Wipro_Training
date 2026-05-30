-- ============================================================
-- Hotel Reservation System - Queries
-- Sprint 2: SELECT, JOINs, Subqueries, Aggregations
-- ============================================================

USE Demo2_HotelReservationDB;
GO

-- ============================================================
-- QUERY 1: All current active reservations with customer & room details
-- (INNER JOIN across 4 tables)
-- ============================================================
SELECT
    r.ReservationID,
    c.FirstName + ' ' + c.LastName          AS CustomerName,
    c.Phone                                  AS CustomerPhone,
    h.HotelName,
    rm.RoomNumber,
    rc.CategoryName                          AS RoomType,
    r.CheckInDate,
    r.CheckOutDate,
    DATEDIFF(DAY, r.CheckInDate, r.CheckOutDate) AS Nights,
    r.Adults,
    r.Children,
    r.TotalAmount,
    r.Status
FROM dbo.Reservations r
INNER JOIN dbo.Customers    c  ON r.CustomerID = c.CustomerID
INNER JOIN dbo.Rooms        rm ON r.RoomID     = rm.RoomID
INNER JOIN dbo.Hotels       h  ON rm.HotelID   = h.HotelID
INNER JOIN dbo.RoomCategories rc ON rm.CategoryID = rc.CategoryID
WHERE r.Status NOT IN ('Cancelled','CheckedOut')
ORDER BY r.CheckInDate;
GO

-- ============================================================
-- QUERY 2: Revenue report per hotel (GROUP BY + HAVING)
-- ============================================================
SELECT
    h.HotelName,
    h.City,
    COUNT(r.ReservationID)                          AS TotalReservations,
    COUNT(CASE WHEN r.Status = 'CheckedOut' THEN 1 END) AS CompletedStays,
    SUM(p.Amount)                                   AS TotalRevenue,
    AVG(p.Amount)                                   AS AvgRevenuePerBooking,
    MAX(p.Amount)                                   AS HighestPayment
FROM dbo.Hotels h
INNER JOIN dbo.Rooms        rm ON rm.HotelID      = h.HotelID
INNER JOIN dbo.Reservations r  ON r.RoomID        = rm.RoomID
INNER JOIN dbo.Payments     p  ON p.ReservationID = r.ReservationID
WHERE p.Status = 'Completed'
GROUP BY h.HotelID, h.HotelName, h.City
HAVING SUM(p.Amount) > 0
ORDER BY TotalRevenue DESC;
GO

-- ============================================================
-- QUERY 3: Room occupancy status across all hotels
-- (LEFT JOIN to include rooms with no reservations)
-- ============================================================
SELECT
    h.HotelName,
    rm.RoomNumber,
    rc.CategoryName,
    rm.BedType,
    rm.Floor,
    rm.Status                           AS CurrentStatus,
    rc.BasePrice                        AS PricePerNight,
    ISNULL(c.FirstName + ' ' + c.LastName, 'Vacant') AS CurrentGuest,
    r.CheckInDate,
    r.CheckOutDate
FROM dbo.Rooms rm
INNER JOIN dbo.Hotels         h  ON rm.HotelID   = h.HotelID
INNER JOIN dbo.RoomCategories rc ON rm.CategoryID = rc.CategoryID
LEFT JOIN dbo.Reservations    r  ON r.RoomID = rm.RoomID
    AND r.Status IN ('CheckedIn', 'Confirmed')
LEFT JOIN dbo.Customers       c  ON r.CustomerID = c.CustomerID
ORDER BY h.HotelName, rm.Floor, rm.RoomNumber;
GO

-- ============================================================
-- QUERY 4: Customers who have stayed more than once (Subquery)
-- ============================================================
SELECT
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Email,
    c.MembershipTier,
    c.LoyaltyPoints,
    (SELECT COUNT(*) FROM dbo.Reservations r2
     WHERE r2.CustomerID = c.CustomerID) AS TotalBookings,
    (SELECT SUM(p2.Amount)
     FROM dbo.Payments p2
     INNER JOIN dbo.Reservations r3 ON p2.ReservationID = r3.ReservationID
     WHERE r3.CustomerID = c.CustomerID
       AND p2.Status = 'Completed') AS TotalSpent
FROM dbo.Customers c
WHERE c.CustomerID IN (
    SELECT CustomerID
    FROM dbo.Reservations
    GROUP BY CustomerID
    HAVING COUNT(*) > 1
)
ORDER BY TotalBookings DESC;
GO

-- ============================================================
-- QUERY 5: Available rooms for a given date range
-- (Correlated subquery / NOT EXISTS for availability check)
-- ============================================================
DECLARE @CheckIn  DATE = '2025-08-01';
DECLARE @CheckOut DATE = '2025-08-05';

SELECT
    h.HotelName,
    h.City,
    rm.RoomNumber,
    rc.CategoryName,
    rm.BedType,
    rc.BasePrice                    AS PricePerNight,
    rc.BasePrice * DATEDIFF(DAY, @CheckIn, @CheckOut) AS EstimatedTotal,
    rc.MaxOccupancy,
    rm.HasBalcony,
    rm.HasSeaView
FROM dbo.Rooms rm
INNER JOIN dbo.Hotels         h  ON rm.HotelID    = h.HotelID
INNER JOIN dbo.RoomCategories rc ON rm.CategoryID = rc.CategoryID
WHERE rm.Status = 'Available'
  AND NOT EXISTS (
        SELECT 1
        FROM dbo.Reservations r
        WHERE r.RoomID = rm.RoomID
          AND r.Status NOT IN ('Cancelled','CheckedOut')
          AND r.CheckInDate  < @CheckOut
          AND r.CheckOutDate > @CheckIn
      )
ORDER BY rc.BasePrice;
GO

-- ============================================================
-- QUERY 6: Payment method breakdown (GROUP BY + aggregate)
-- ============================================================
SELECT
    PaymentMethod,
    COUNT(*)                AS TransactionCount,
    SUM(Amount)             AS TotalCollected,
    ROUND(AVG(Amount),2)    AS AvgTransactionValue,
    MIN(Amount)             AS MinPayment,
    MAX(Amount)             AS MaxPayment
FROM dbo.Payments
WHERE Status = 'Completed'
GROUP BY PaymentMethod
ORDER BY TotalCollected DESC;
GO

-- ============================================================
-- QUERY 7: Monthly revenue trend (GROUP BY month)
-- ============================================================
SELECT
    YEAR(p.PaymentDate)   AS PaymentYear,
    MONTH(p.PaymentDate)  AS PaymentMonth,
    DATENAME(MONTH, p.PaymentDate) AS MonthName,
    COUNT(p.PaymentID)    AS Transactions,
    SUM(p.Amount)         AS MonthlyRevenue
FROM dbo.Payments p
WHERE p.Status = 'Completed'
GROUP BY YEAR(p.PaymentDate), MONTH(p.PaymentDate), DATENAME(MONTH, p.PaymentDate)
ORDER BY PaymentYear, PaymentMonth;
GO

-- ============================================================
-- QUERY 8: Staff performance — number of bookings handled per staff
-- (RIGHT JOIN to include staff with zero bookings)
-- ============================================================
SELECT
    s.StaffID,
    s.FirstName + ' ' + s.LastName AS StaffName,
    s.Role,
    h.HotelName,
    COUNT(r.ReservationID)          AS BookingsHandled,
    ISNULL(SUM(r.TotalAmount),0)    AS TotalRevenueHandled
FROM dbo.Staff      s
RIGHT JOIN dbo.Reservations r ON r.StaffID  = s.StaffID
INNER JOIN dbo.Hotels       h ON s.HotelID  = h.HotelID
GROUP BY s.StaffID, s.FirstName, s.LastName, s.Role, h.HotelName
ORDER BY BookingsHandled DESC;
GO

-- ============================================================
-- QUERY 9: Rooms with ALL amenities listed (STRING_AGG)
-- ============================================================
SELECT
    h.HotelName,
    rm.RoomNumber,
    rc.CategoryName,
    COUNT(ra.AmenityID)             AS AmenityCount,
    STRING_AGG(a.AmenityName, ', ') AS Amenities
FROM dbo.Rooms rm
INNER JOIN dbo.Hotels         h  ON rm.HotelID   = h.HotelID
INNER JOIN dbo.RoomCategories rc ON rm.CategoryID = rc.CategoryID
INNER JOIN dbo.RoomAmenities  ra ON ra.RoomID     = rm.RoomID
INNER JOIN dbo.Amenities      a  ON a.AmenityID   = ra.AmenityID
GROUP BY h.HotelName, rm.RoomNumber, rc.CategoryName
ORDER BY AmenityCount DESC;
GO

-- ============================================================
-- QUERY 10: Customers above average spending (Subquery in WHERE)
-- ============================================================
SELECT
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.MembershipTier,
    SUM(p.Amount)                   AS TotalSpent
FROM dbo.Customers    c
INNER JOIN dbo.Reservations r ON r.CustomerID      = c.CustomerID
INNER JOIN dbo.Payments     p ON p.ReservationID   = r.ReservationID
WHERE p.Status = 'Completed'
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.MembershipTier
HAVING SUM(p.Amount) > (
    SELECT AVG(sub.TotalPaid)
    FROM (
        SELECT r2.CustomerID, SUM(p2.Amount) AS TotalPaid
        FROM dbo.Reservations r2
        INNER JOIN dbo.Payments p2 ON p2.ReservationID = r2.ReservationID
        WHERE p2.Status = 'Completed'
        GROUP BY r2.CustomerID
    ) sub
)
ORDER BY TotalSpent DESC;
GO

-- ============================================================
-- QUERY 11: FULL OUTER JOIN — all customers and all reservations
-- (shows customers with no reservations & reservations with no matching customer)
-- ============================================================
SELECT
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    r.ReservationID,
    r.Status,
    r.TotalAmount
FROM dbo.Customers    c
FULL OUTER JOIN dbo.Reservations r ON r.CustomerID = c.CustomerID
ORDER BY c.CustomerID;
GO

-- ============================================================
-- QUERY 12: Top 3 most booked room categories
-- ============================================================
SELECT TOP 3
    rc.CategoryName,
    COUNT(r.ReservationID)  AS TimesBooked,
    SUM(r.TotalAmount)      AS TotalRevenue,
    AVG(DATEDIFF(DAY, r.CheckInDate, r.CheckOutDate)) AS AvgNightsStayed
FROM dbo.RoomCategories rc
INNER JOIN dbo.Rooms        rm ON rm.CategoryID   = rc.CategoryID
INNER JOIN dbo.Reservations r  ON r.RoomID        = rm.RoomID
WHERE r.Status != 'Cancelled'
GROUP BY rc.CategoryName
ORDER BY TimesBooked DESC;
GO

-- ============================================================
-- QUERY 13: Pending payments (overdue / not yet collected)
-- ============================================================
SELECT
    r.ReservationID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Phone,
    h.HotelName,
    r.CheckInDate,
    r.CheckOutDate,
    r.TotalAmount,
    ISNULL(SUM(p.Amount), 0)                           AS AmountPaid,
    r.TotalAmount - ISNULL(SUM(p.Amount), 0)           AS BalanceDue,
    r.Status
FROM dbo.Reservations r
INNER JOIN dbo.Customers c  ON r.CustomerID  = c.CustomerID
INNER JOIN dbo.Rooms     rm ON r.RoomID      = rm.RoomID
INNER JOIN dbo.Hotels    h  ON rm.HotelID    = h.HotelID
LEFT JOIN  dbo.Payments  p  ON p.ReservationID = r.ReservationID
    AND p.Status = 'Completed'
WHERE r.Status NOT IN ('Cancelled')
GROUP BY r.ReservationID, c.FirstName, c.LastName, c.Phone,
         h.HotelName, r.CheckInDate, r.CheckOutDate, r.TotalAmount, r.Status
HAVING r.TotalAmount - ISNULL(SUM(p.Amount),0) > 0
ORDER BY BalanceDue DESC;
GO