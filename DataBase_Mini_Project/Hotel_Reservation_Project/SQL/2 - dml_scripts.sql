-- ============================================================
-- Hotel Reservation System - DML Scripts
-- Sprint 2: INSERT / UPDATE / DELETE
-- ============================================================

USE Demo2_HotelReservationDB;
GO

-- ============================================================
-- INSERT: Hotels
-- ============================================================
INSERT INTO dbo.Hotels (HotelName, Address, City, State, Country, Phone, Email, StarRating, TotalRooms)
VALUES
    ('The Grand Madurai',    '12 Meenakshi St',       'Madurai',   'Tamil Nadu', 'India', '9400001111', 'info@grandmadurai.com',    5, 120),
    ('Comfort Stay Chennai', '88 Anna Salai',          'Chennai',   'Tamil Nadu', 'India', '9400002222', 'info@comfortchennai.com',  3,  80),
    ('Royal Oasis Coimbatore','45 RS Puram Road',      'Coimbatore','Tamil Nadu', 'India', '9400003333', 'info@royalcoimbatore.com', 4,  60),
    ('Pearl Residency',      '7 Marina Beach Road',   'Chennai',   'Tamil Nadu', 'India', '9400004444', 'info@pearlresidency.com',  4,  90),
    ('Green Valley Resort',  '22 Ooty Road',           'Ooty',      'Tamil Nadu', 'India', '9400005555', 'info@greenvalleyooty.com', 3,  40);
GO

-- ============================================================
-- INSERT: Departments
-- ============================================================
INSERT INTO dbo.Departments (HotelID, DepartmentName)
VALUES
    (1,'Front Desk'), (1,'Housekeeping'), (1,'Food & Beverage'), (1,'Maintenance'), (1,'Security'),
    (2,'Front Desk'), (2,'Housekeeping'), (2,'Food & Beverage'),
    (3,'Front Desk'), (3,'Housekeeping'), (3,'Food & Beverage'),
    (4,'Front Desk'), (4,'Housekeeping'),
    (5,'Front Desk'), (5,'Housekeeping');
GO

-- ============================================================
-- INSERT: Staff
-- ============================================================
INSERT INTO dbo.Staff (HotelID, DepartmentID, FirstName, LastName, Role, Phone, Email, HireDate, Salary)
VALUES
    (1,1,'Arjun',    'Kumar',   'Receptionist',      '9500001001','arjun.k@grandmadurai.com',    '2020-03-15', 28000),
    (1,1,'Priya',    'Rajan',   'Front Desk Manager','9500001002','priya.r@grandmadurai.com',    '2018-07-01', 45000),
    (1,2,'Suresh',   'Babu',    'Housekeeping Staff','9500001003','suresh.b@grandmadurai.com',   '2021-01-10', 22000),
    (1,3,'Meena',    'Devi',    'Chef',              '9500001004','meena.d@grandmadurai.com',    '2019-05-20', 38000),
    (1,4,'Ravi',     'Shankar', 'Maintenance Lead',  '9500001005','ravi.s@grandmadurai.com',     '2017-11-05', 32000),
    (2,6,'Arun',     'Prasad',  'Receptionist',      '9500002001','arun.p@comfortchennai.com',   '2022-04-01', 26000),
    (2,6,'Kavitha',  'Nair',    'Front Desk Manager','9500002002','kavitha.n@comfortchennai.com','2019-09-15', 42000),
    (3,9,'Deepak',   'Raj',     'Receptionist',      '9500003001','deepak.r@royalcoimbatore.com','2021-06-10', 27000),
    (4,12,'Shalini', 'Mehta',   'Receptionist',      '9500004001','shalini.m@pearlresidency.com','2020-08-20', 27500),
    (5,14,'Venkat',  'Iyer',    'Receptionist',      '9500005001','venkat.i@greenvalleyooty.com','2023-01-15', 25000);
GO

-- ============================================================
-- INSERT: Room Categories
-- ============================================================
INSERT INTO dbo.RoomCategories (CategoryName, Description, BasePrice, MaxOccupancy)
VALUES
    ('Standard',     'Comfortable room with basic amenities',              2500.00, 2),
    ('Deluxe',       'Spacious room with premium furnishings',             4500.00, 2),
    ('Suite',        'Luxurious suite with living area and kitchenette',   8000.00, 3),
    ('Presidential', 'Top-floor presidential suite with panoramic view',  20000.00, 4),
    ('Family',       'Large room ideal for families with kids',            5500.00, 5);
GO

-- ============================================================
-- INSERT: Rooms
-- ============================================================
INSERT INTO dbo.Rooms (HotelID, CategoryID, RoomNumber, Floor, Status, BedType, HasBalcony, HasSeaView)
VALUES
    -- The Grand Madurai (HotelID=1)
    (1,1,'101',1,'Available','Double',0,0),
    (1,1,'102',1,'Available','Twin',0,0),
    (1,2,'201',2,'Available','Queen',1,0),
    (1,2,'202',2,'Occupied', 'King', 1,0),
    (1,3,'301',3,'Available','King', 1,0),
    (1,4,'401',4,'Available','King', 1,0),
    (1,5,'103',1,'Available','King', 0,0),
    -- Comfort Stay Chennai (HotelID=2)
    (2,1,'101',1,'Available','Single',0,0),
    (2,1,'102',1,'Available','Double',0,0),
    (2,2,'201',2,'Available','Queen', 1,0),
    (2,3,'301',3,'Available','King',  1,1),
    -- Royal Oasis Coimbatore (HotelID=3)
    (3,1,'101',1,'Available','Double',0,0),
    (3,2,'201',2,'Available','Queen', 1,0),
    (3,3,'301',3,'Available','King',  1,0),
    -- Pearl Residency Chennai (HotelID=4)
    (4,1,'101',1,'Available','Double',0,1),
    (4,2,'201',2,'Available','King',  1,1),
    (4,3,'301',3,'Available','King',  1,1),
    -- Green Valley Ooty (HotelID=5)
    (5,1,'101',1,'Available','Double',1,0),
    (5,2,'201',2,'Available','Queen', 1,0),
    (5,3,'301',3,'Available','King',  1,0);
GO

-- ============================================================
-- INSERT: Amenities
-- ============================================================
INSERT INTO dbo.Amenities (AmenityName, Description)
VALUES
    ('WiFi',           'High-speed wireless internet'),
    ('Air Conditioning','Central AC with temperature control'),
    ('Mini Bar',       'Stocked mini refrigerator with beverages'),
    ('Room Service',   '24/7 in-room dining service'),
    ('Flat Screen TV', '55-inch smart TV'),
    ('Jacuzzi',        'Private jacuzzi bathtub'),
    ('Safe',           'In-room electronic safe'),
    ('Hair Dryer',     'Provided complimentary'),
    ('Bathrobe',       'Premium quality bathrobe'),
    ('Balcony',        'Private outdoor balcony');
GO

-- ============================================================
-- INSERT: RoomAmenities (M-M)
-- ============================================================
-- Standard rooms: WiFi, AC, TV, Safe
INSERT INTO dbo.RoomAmenities VALUES (1,1),(1,2),(1,5),(1,7);
INSERT INTO dbo.RoomAmenities VALUES (2,1),(2,2),(2,5),(2,7);
INSERT INTO dbo.RoomAmenities VALUES (8,1),(8,2),(8,5),(8,7);
INSERT INTO dbo.RoomAmenities VALUES (9,1),(9,2),(9,5),(9,7);
-- Deluxe rooms: WiFi, AC, TV, Safe, Mini Bar, Balcony, Hair Dryer
INSERT INTO dbo.RoomAmenities VALUES (3,1),(3,2),(3,3),(3,5),(3,7),(3,8),(3,10);
INSERT INTO dbo.RoomAmenities VALUES (4,1),(4,2),(4,3),(4,5),(4,7),(4,8),(4,10);
INSERT INTO dbo.RoomAmenities VALUES (10,1),(10,2),(10,3),(10,5),(10,7),(10,8);
-- Suite rooms: All amenities
INSERT INTO dbo.RoomAmenities VALUES (5,1),(5,2),(5,3),(5,4),(5,5),(5,6),(5,7),(5,8),(5,9),(5,10);
INSERT INTO dbo.RoomAmenities VALUES (11,1),(11,2),(11,3),(11,4),(11,5),(11,6),(11,7),(11,8),(11,9);
-- Presidential room: All amenities
INSERT INTO dbo.RoomAmenities VALUES (6,1),(6,2),(6,3),(6,4),(6,5),(6,6),(6,7),(6,8),(6,9),(6,10);
GO

-- ============================================================
-- INSERT: Customers
-- ============================================================
INSERT INTO dbo.Customers (FirstName, LastName, Email, Phone, DateOfBirth, IDType, IDNumber, Nationality, Address, City, LoyaltyPoints)
VALUES
    ('Rajesh',    'Sharma',    'rajesh.sharma@gmail.com',    '9811001001', '1985-06-15', 'Aadhaar',       'AADH100000001', 'Indian', '10 Gandhi Nagar', 'Delhi',     500),
    ('Sunita',    'Patel',     'sunita.patel@gmail.com',     '9811002002', '1990-03-22', 'Passport',      'PASS200000002', 'Indian', '22 MG Road',      'Mumbai',    1200),
    ('Vikram',    'Singh',     'vikram.singh@gmail.com',     '9811003003', '1978-11-08', 'DrivingLicense','DL300000003',   'Indian', '5 Lake View',     'Bangalore', 200),
    ('Ananya',    'Reddy',     'ananya.reddy@gmail.com',     '9811004004', '1995-07-30', 'Aadhaar',       'AADH400000004', 'Indian', '8 Park Street',   'Hyderabad', 0),
    ('Mohammed',  'Khan',      'mohammed.khan@gmail.com',    '9811005005', '1982-01-25', 'Passport',      'PASS500000005', 'Indian', '3 Civil Lines',   'Chennai',   800),
    ('Deepa',     'Nair',      'deepa.nair@gmail.com',       '9811006006', '1993-09-12', 'PAN',           'PAN600000006',  'Indian', '15 Ooty Road',    'Coimbatore',300),
    ('Sanjay',    'Gupta',     'sanjay.gupta@gmail.com',     '9811007007', '1980-04-18', 'Aadhaar',       'AADH700000007', 'Indian', '7 Mall Road',     'Shimla',    1500),
    ('Pooja',     'Mehta',     'pooja.mehta@gmail.com',      '9811008008', '1998-12-05', 'VoterID',       'VOTER80000008', 'Indian', '9 Sea View',      'Goa',       100),
    ('Arjun',     'Kapoor',    'arjun.kapoor@gmail.com',     '9811009009', '1988-08-20', 'Passport',      'PASS900000009', 'Indian', '11 Hill Top',     'Pune',      600),
    ('Lakshmi',   'Venkat',    'lakshmi.venkat@gmail.com',   '9811010010', '1975-02-14', 'Aadhaar',       'AADH010000010', 'Indian', '4 Temple Street', 'Madurai',   2000),
    ('Ritu',      'Agarwal',   'ritu.agarwal@gmail.com',     '9811011011', '1992-05-28', 'Passport',      'PASS110000011', 'Indian', '6 Rose Garden',   'Jaipur',    400),
    ('Kartik',    'Iyer',      'kartik.iyer@gmail.com',      '9811012012', '1987-10-03', 'DrivingLicense','DL120000012',   'Indian', '2 Connaught Pl',  'Delhi',     700),
    ('Neha',      'Pillai',    'neha.pillai@gmail.com',      '9811013013', '1996-03-17', 'Aadhaar',       'AADH130000013', 'Indian', '18 Marine Drive', 'Mumbai',    150),
    ('Rohit',     'Mishra',    'rohit.mishra@gmail.com',     '9811014014', '1983-07-09', 'Passport',      'PASS140000014', 'Indian', '30 IT Park',      'Noida',     900),
    ('Preethi',   'Krishnan',  'preethi.krishnan@gmail.com', '9811015015', '1991-11-22', 'PAN',           'PAN150000015',  'Indian', '12 Beach Road',   'Chennai',   250);
GO

-- ============================================================
-- INSERT: Reservations
-- ============================================================
INSERT INTO dbo.Reservations (CustomerID, RoomID, StaffID, CheckInDate, CheckOutDate, Adults, Children, Status, SpecialRequests, TotalAmount, DiscountPercent)
VALUES
    (1,  3, 2, '2025-06-01','2025-06-04', 2,0,'CheckedOut','Extra pillows',                         13500.00, 0),
    (2,  5, 2, '2025-06-03','2025-06-07', 2,1,'CheckedOut','Vegetarian meals',                       32000.00, 0),
    (3,  1, 1, '2025-06-10','2025-06-12', 1,0,'CheckedOut',NULL,                                     5000.00,  0),
    (4,  6, 2, '2025-06-15','2025-06-18', 2,2,'CheckedOut','Anniversary decoration',                 60000.00,10),
    (5, 10, 7, '2025-06-20','2025-06-22', 2,0,'CheckedOut',NULL,                                     9000.00,  0),
    (6,  7, 1, '2025-06-25','2025-06-27', 3,2,'CheckedOut','Baby cot needed',                        11000.00, 5),
    (7,  4, 1, '2025-07-01','2025-07-03', 2,0,'CheckedIn', 'Late checkout if possible',              9000.00,  0),
    (8, 11, 7, '2025-07-02','2025-07-05', 2,0,'CheckedIn', 'Sea view preferred',                     24000.00, 0),
    (9, 14, 8, '2025-07-05','2025-07-08', 2,1,'Confirmed', 'Airport pickup',                         24000.00, 0),
    (10, 3, 2, '2025-07-10','2025-07-12', 2,0,'Confirmed', NULL,                                     9000.00,  0),
    (11,17, 9, '2025-07-12','2025-07-15', 2,0,'Confirmed', 'Honeymooners',                           24000.00,10),
    (12, 2, 1, '2025-07-15','2025-07-16', 1,0,'Confirmed', NULL,                                     2500.00,  0),
    (13,18, 10,'2025-07-18','2025-07-21', 2,1,'Confirmed', 'Ground floor preferred',                  7500.00,  0),
    (14, 6, 2, '2025-07-20','2025-07-25', 2,0,'Confirmed', 'Board meeting setup in suite',          100000.00,15),
    (15, 9, 7, '2025-07-22','2025-07-24', 1,0,'Cancelled', NULL,                                     5000.00,  0);
GO

-- ============================================================
-- INSERT: Payments
-- ============================================================
INSERT INTO dbo.Payments (ReservationID, Amount, PaymentMethod, TransactionRef, Status, Notes)
VALUES
    (1,  13500.00, 'CreditCard', 'TXN20250601CC001', 'Completed', NULL),
    (2,  32000.00, 'UPI',        'TXN20250603UP002', 'Completed', 'Paid in full'),
    (3,   5000.00, 'Cash',        NULL,              'Completed', 'Cash payment at desk'),
    (4,  54000.00, 'NetBanking', 'TXN20250615NB004', 'Completed', '10% discount applied'),
    (5,   9000.00, 'DebitCard',  'TXN20250620DC005', 'Completed', NULL),
    (6,  10450.00, 'UPI',        'TXN20250625UP006', 'Completed', '5% discount applied'),
    (7,   9000.00, 'CreditCard', 'TXN20250701CC007', 'Completed', 'Advance payment'),
    (8,  24000.00, 'UPI',        'TXN20250702UP008', 'Completed', NULL),
    (9,  12000.00, 'NetBanking', 'TXN20250705NB009', 'Pending',   'Partial advance'),
    (11, 21600.00, 'CreditCard', 'TXN20250712CC011', 'Completed', 'Honeymoon package 10% off'),
    (14, 85000.00, 'NetBanking', 'TXN20250720NB014', 'Pending',   'Corporate booking advance');
GO

-- ============================================================
-- UPDATE: Room status after check-ins
-- ============================================================
UPDATE dbo.Rooms SET Status = 'Occupied'  WHERE RoomID IN (4, 11);
UPDATE dbo.Rooms SET Status = 'Reserved'  WHERE RoomID IN (14, 17, 2, 18, 6);
UPDATE dbo.Rooms SET Status = 'UnderMaintenance' WHERE RoomID = 13;
GO

-- Update actual check-in times
UPDATE dbo.Reservations SET ActualCheckIn = '2025-07-01 14:30:00' WHERE ReservationID = 7;
UPDATE dbo.Reservations SET ActualCheckIn = '2025-07-02 15:00:00' WHERE ReservationID = 8;
GO

-- Update loyalty points for completed reservations
UPDATE dbo.Customers SET LoyaltyPoints = LoyaltyPoints + 135  WHERE CustomerID = 1;
UPDATE dbo.Customers SET LoyaltyPoints = LoyaltyPoints + 320  WHERE CustomerID = 2;
UPDATE dbo.Customers SET LoyaltyPoints = LoyaltyPoints + 50   WHERE CustomerID = 3;
UPDATE dbo.Customers SET LoyaltyPoints = LoyaltyPoints + 540  WHERE CustomerID = 4;
UPDATE dbo.Customers SET LoyaltyPoints = LoyaltyPoints + 90   WHERE CustomerID = 5;
GO

-- Update membership tier based on loyalty points
UPDATE dbo.Customers SET MembershipTier = 'Silver'   WHERE LoyaltyPoints BETWEEN 500  AND 999;
UPDATE dbo.Customers SET MembershipTier = 'Gold'     WHERE LoyaltyPoints BETWEEN 1000 AND 2499;
UPDATE dbo.Customers SET MembershipTier = 'Platinum' WHERE LoyaltyPoints >= 2500;
GO

-- ============================================================
-- DELETE: Remove a cancelled reservation (soft approach: status already 'Cancelled')
-- Hard delete a test/dummy payment record (for demo purposes)
-- ============================================================
-- Delete orphaned/dummy data only (no real cascades broken)
DELETE FROM dbo.Reservations
WHERE Status = 'Cancelled'
  AND CustomerID = 15
  AND ReservationID = 15;
GO

-- ============================================================
-- TRUNCATE demo (safe on a staging copy — shown for Sprint 2 req)
-- TRUNCATE TABLE dbo.AuditLog;  -- Clears audit log (run only if intentional)
-- ============================================================

PRINT 'All DML operations completed successfully.';
GO