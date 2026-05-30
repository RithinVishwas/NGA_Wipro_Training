-- ============================================================
-- Hotel Reservation System - DDL Scripts
-- Sprint 2: Table Creation with Constraints
-- Database: Microsoft SQL Server (T-SQL)
-- ============================================================

-- Create and use database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'HotelReservationDB')
    CREATE DATABASE Demo2_HotelReservationDB;
GO

USE Demo2_HotelReservationDB;
GO

-- ============================================================
-- DROP TABLES (in FK-safe order)
-- ============================================================
IF OBJECT_ID('dbo.Payments',          'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID('dbo.Reservations',      'U') IS NOT NULL DROP TABLE dbo.Reservations;
IF OBJECT_ID('dbo.RoomAmenities',     'U') IS NOT NULL DROP TABLE dbo.RoomAmenities;
IF OBJECT_ID('dbo.Amenities',         'U') IS NOT NULL DROP TABLE dbo.Amenities;
IF OBJECT_ID('dbo.Rooms',             'U') IS NOT NULL DROP TABLE dbo.Rooms;
IF OBJECT_ID('dbo.RoomCategories',    'U') IS NOT NULL DROP TABLE dbo.RoomCategories;
IF OBJECT_ID('dbo.Customers',         'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Staff',             'U') IS NOT NULL DROP TABLE dbo.Staff;
IF OBJECT_ID('dbo.Departments',       'U') IS NOT NULL DROP TABLE dbo.Departments;
IF OBJECT_ID('dbo.Hotels',            'U') IS NOT NULL DROP TABLE dbo.Hotels;
GO

-- ============================================================
-- TABLE 1: Hotels
-- ============================================================
CREATE TABLE dbo.Hotels (
    HotelID      INT           IDENTITY(1,1) PRIMARY KEY,
    HotelName    NVARCHAR(100) NOT NULL,
    Address      NVARCHAR(200) NOT NULL,
    City         NVARCHAR(50)  NOT NULL,
    State        NVARCHAR(50)  NOT NULL,
    Country      NVARCHAR(50)  NOT NULL DEFAULT 'India',
    Phone        VARCHAR(20)   NOT NULL,
    Email        VARCHAR(100)  NOT NULL,
    StarRating   TINYINT       NOT NULL CHECK (StarRating BETWEEN 1 AND 5),
    TotalRooms   INT           NOT NULL CHECK (TotalRooms > 0),
    CreatedAt    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Hotel_Email UNIQUE (Email)
);
GO

-- ============================================================
-- TABLE 2: Departments
-- ============================================================
CREATE TABLE dbo.Departments (
    DepartmentID   INT           IDENTITY(1,1) PRIMARY KEY,
    HotelID        INT           NOT NULL,
    DepartmentName NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Dept_Hotel FOREIGN KEY (HotelID) REFERENCES dbo.Hotels(HotelID)
);
GO

-- ============================================================
-- TABLE 3: Staff
-- ============================================================
CREATE TABLE dbo.Staff (
    StaffID      INT           IDENTITY(1,1) PRIMARY KEY,
    HotelID      INT           NOT NULL,
    DepartmentID INT           NOT NULL,
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    Role         NVARCHAR(50)  NOT NULL,
    Phone        VARCHAR(20)   NOT NULL,
    Email        VARCHAR(100)  NOT NULL,
    HireDate     DATE          NOT NULL,
    Salary       DECIMAL(10,2) NOT NULL CHECK (Salary >= 0),
    IsActive     BIT           NOT NULL DEFAULT 1,
    CONSTRAINT FK_Staff_Hotel  FOREIGN KEY (HotelID)      REFERENCES dbo.Hotels(HotelID),
    CONSTRAINT FK_Staff_Dept   FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID),
    CONSTRAINT UQ_Staff_Email  UNIQUE (Email)
);
GO

-- ============================================================
-- TABLE 4: RoomCategories
-- ============================================================
CREATE TABLE dbo.RoomCategories (
    CategoryID          INT            IDENTITY(1,1) PRIMARY KEY,
    CategoryName        NVARCHAR(50)   NOT NULL,  -- Standard, Deluxe, Suite, Presidential
    Description         NVARCHAR(200)  NULL,
    BasePrice           DECIMAL(10,2)  NOT NULL CHECK (BasePrice > 0),
    MaxOccupancy        TINYINT        NOT NULL CHECK (MaxOccupancy BETWEEN 1 AND 10),
    CONSTRAINT UQ_RoomCat_Name UNIQUE (CategoryName)
);
GO

-- ============================================================
-- TABLE 5: Rooms
-- ============================================================
CREATE TABLE dbo.Rooms (
    RoomID       INT           IDENTITY(1,1) PRIMARY KEY,
    HotelID      INT           NOT NULL,
    CategoryID   INT           NOT NULL,
    RoomNumber   VARCHAR(10)   NOT NULL,
    Floor        TINYINT       NOT NULL CHECK (Floor >= 0),
    Status       NVARCHAR(20)  NOT NULL DEFAULT 'Available'
                     CHECK (Status IN ('Available','Occupied','UnderMaintenance','Reserved')),
    BedType      NVARCHAR(20)  NOT NULL CHECK (BedType IN ('Single','Double','Queen','King','Twin')),
    HasBalcony   BIT           NOT NULL DEFAULT 0,
    HasSeaView   BIT           NOT NULL DEFAULT 0,
    CONSTRAINT FK_Room_Hotel    FOREIGN KEY (HotelID)    REFERENCES dbo.Hotels(HotelID),
    CONSTRAINT FK_Room_Category FOREIGN KEY (CategoryID) REFERENCES dbo.RoomCategories(CategoryID),
    CONSTRAINT UQ_Room_Number   UNIQUE (HotelID, RoomNumber)
);
GO

-- ============================================================
-- TABLE 6: Amenities
-- ============================================================
CREATE TABLE dbo.Amenities (
    AmenityID   INT           IDENTITY(1,1) PRIMARY KEY,
    AmenityName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(200) NULL,
    CONSTRAINT UQ_Amenity_Name UNIQUE (AmenityName)
);
GO

-- ============================================================
-- TABLE 7: RoomAmenities (M-M bridge between Rooms & Amenities)
-- ============================================================
CREATE TABLE dbo.RoomAmenities (
    RoomID    INT NOT NULL,
    AmenityID INT NOT NULL,
    CONSTRAINT PK_RoomAmenities   PRIMARY KEY (RoomID, AmenityID),
    CONSTRAINT FK_RA_Room         FOREIGN KEY (RoomID)    REFERENCES dbo.Rooms(RoomID),
    CONSTRAINT FK_RA_Amenity      FOREIGN KEY (AmenityID) REFERENCES dbo.Amenities(AmenityID)
);
GO

-- ============================================================
-- TABLE 8: Customers
-- ============================================================
CREATE TABLE dbo.Customers (
    CustomerID    INT           IDENTITY(1,1) PRIMARY KEY,
    FirstName     NVARCHAR(50)  NOT NULL,
    LastName      NVARCHAR(50)  NOT NULL,
    Email         VARCHAR(100)  NOT NULL,
    Phone         VARCHAR(20)   NOT NULL,
    DateOfBirth   DATE          NULL,
    IDType        NVARCHAR(30)  NOT NULL CHECK (IDType IN ('Passport','Aadhaar','PAN','DrivingLicense','VoterID')),
    IDNumber      VARCHAR(50)   NOT NULL,
    Nationality   NVARCHAR(50)  NOT NULL DEFAULT 'Indian',
    Address       NVARCHAR(200) NULL,
    City          NVARCHAR(50)  NULL,
    LoyaltyPoints INT           NOT NULL DEFAULT 0 CHECK (LoyaltyPoints >= 0),
    CreatedAt     DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Customer_Email    UNIQUE (Email),
    CONSTRAINT UQ_Customer_IDNumber UNIQUE (IDNumber)
);
GO

-- ============================================================
-- TABLE 9: Reservations
-- ============================================================
CREATE TABLE dbo.Reservations (
    ReservationID     INT            IDENTITY(1,1) PRIMARY KEY,
    CustomerID        INT            NOT NULL,
    RoomID            INT            NOT NULL,
    StaffID           INT            NULL,       -- staff who handled booking
    CheckInDate       DATE           NOT NULL,
    CheckOutDate      DATE           NOT NULL,
    ActualCheckIn     DATETIME       NULL,
    ActualCheckOut    DATETIME       NULL,
    Adults            TINYINT        NOT NULL DEFAULT 1 CHECK (Adults >= 1),
    Children          TINYINT        NOT NULL DEFAULT 0 CHECK (Children >= 0),
    Status            NVARCHAR(20)   NOT NULL DEFAULT 'Confirmed'
                           CHECK (Status IN ('Confirmed','CheckedIn','CheckedOut','Cancelled','NoShow')),
    SpecialRequests   NVARCHAR(500)  NULL,
    TotalAmount       DECIMAL(10,2)  NOT NULL CHECK (TotalAmount >= 0),
    DiscountPercent   DECIMAL(5,2)   NOT NULL DEFAULT 0 CHECK (DiscountPercent BETWEEN 0 AND 100),
    CreatedAt         DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Res_Customer  FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID),
    CONSTRAINT FK_Res_Room      FOREIGN KEY (RoomID)     REFERENCES dbo.Rooms(RoomID),
    CONSTRAINT FK_Res_Staff     FOREIGN KEY (StaffID)    REFERENCES dbo.Staff(StaffID),
    CONSTRAINT CHK_Dates        CHECK (CheckOutDate > CheckInDate)
);
GO

-- ============================================================
-- TABLE 10: Payments
-- ============================================================
CREATE TABLE dbo.Payments (
    PaymentID     INT            IDENTITY(1,1) PRIMARY KEY,
    ReservationID INT            NOT NULL,
    Amount        DECIMAL(10,2)  NOT NULL CHECK (Amount > 0),
    PaymentDate   DATETIME       NOT NULL DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(30)   NOT NULL CHECK (PaymentMethod IN ('Cash','CreditCard','DebitCard','UPI','NetBanking','Wallet')),
    TransactionRef VARCHAR(100)  NULL,
    Status        NVARCHAR(20)   NOT NULL DEFAULT 'Completed'
                      CHECK (Status IN ('Pending','Completed','Failed','Refunded')),
    Notes         NVARCHAR(200)  NULL,
    CONSTRAINT FK_Pay_Reservation FOREIGN KEY (ReservationID) REFERENCES dbo.Reservations(ReservationID)
);
GO

-- ============================================================
-- AUDIT LOG TABLE (used by triggers)
-- ============================================================
IF OBJECT_ID('dbo.AuditLog', 'U') IS NOT NULL DROP TABLE dbo.AuditLog;
GO

CREATE TABLE dbo.AuditLog (
    LogID       INT            IDENTITY(1,1) PRIMARY KEY,
    TableName   NVARCHAR(100)  NOT NULL,
    Operation   NVARCHAR(10)   NOT NULL CHECK (Operation IN ('INSERT','UPDATE','DELETE')),
    RecordID    INT            NOT NULL,
    ChangedBy   NVARCHAR(100)  NOT NULL DEFAULT SYSTEM_USER,
    ChangedAt   DATETIME       NOT NULL DEFAULT GETDATE(),
    OldValue    NVARCHAR(MAX)  NULL,
    NewValue    NVARCHAR(MAX)  NULL
);
GO

PRINT 'All tables created successfully.';
GO

-- ============================================================
-- ALTER TABLE examples (Sprint 2 DDL requirement)
-- ============================================================
ALTER TABLE dbo.Customers
    ADD MembershipTier NVARCHAR(20) NOT NULL DEFAULT 'Bronze'
        CONSTRAINT CHK_MemberTier CHECK (MembershipTier IN ('Bronze','Silver','Gold','Platinum'));
GO

PRINT 'ALTER TABLE completed.';
GO