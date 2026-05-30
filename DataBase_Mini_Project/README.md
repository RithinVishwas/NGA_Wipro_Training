# Hotel Reservation Database Management System

**Domain:** Hospitality — Hotel Reservation (P4)  
**Technology:** Microsoft SQL Server · T-SQL · SSMS  
**Project Type:** Great Learning Capstone — Database Management System

---

## Project Description

A fully normalized relational database system for managing hotel operations including room bookings, customer management, staff, billing, and reporting. Designed to prevent double booking, automate room status updates, enforce data integrity, and support complex reporting queries.

**Covers 5 hotels, 20 rooms, 15 customers, 14 reservations, and 11 payment records** with complete end-to-end data flow.

---

## Features Implemented

### Sprint 1 — Design & Normalization
- 11-table schema normalized to **3NF / BCNF**
- Relationships: 1:1, 1:M, and M:M (RoomAmenities junction table)
- Full ER Diagram in `/ERD/`
- Normalization report with 1NF → 2NF → 3NF → BCNF analysis

### Sprint 2 — Implementation
- **DDL:** CREATE, ALTER, DROP with all constraints (PK, FK, CHECK, UNIQUE, NOT NULL, DEFAULT)
- **DML:** INSERT (150+ rows), UPDATE, DELETE
- **13 complex queries** covering INNER/LEFT/RIGHT/FULL JOINs, subqueries, correlated subqueries, GROUP BY, HAVING, STRING_AGG
- **6 Views:** ActiveReservations, RoomAvailability, RevenueByHotel, CustomerHistory, OccupancyRate, PaymentSummary
- **11 Indexes:** Clustered and Non-Clustered for performance optimization

### Sprint 3 — Advanced SQL
- **5 Triggers:** AfterInsert/Update/Delete on Reservations, AfterInsert on Payments, InsteadOf for double-booking prevention
- **7 Functions:** 4 scalar (charge calculator, availability check, occupancy rate, membership tier) + 3 table-valued (available rooms, customer history, revenue report)
- **4 Transactions:** Complete COMMIT and ROLLBACK scenarios with error handling
- **DCL:** GRANT/REVOKE for 4 roles (Receptionist, Manager, Auditor, Reports)

---

## Repository Structure

```
Hotel-Reservation-DBMS/
│── README.md
│── ERD/
│   └── er_diagram.png
│── SQL/
│   ├── ddl_scripts.sql         ← Table creation, constraints, ALTER
│   ├── dml_scripts.sql         ← INSERT, UPDATE, DELETE data
│   ├── queries.sql             ← 13 complex SELECT queries
│   ├── views.sql               ← 6 views
│   ├── indexes.sql             ← 11 indexes
│   ├── triggers.sql            ← 5 triggers
│   ├── functions.sql           ← 4 scalar + 3 TVF functions
│   └── transactions_dcl.sql    ← COMMIT/ROLLBACK + GRANT/REVOKE
│── Documentation/
│   └── normalization_report.md
│── Output/
│   └── sample_results.xlsx
```

---

## How to Execute Scripts

**Run scripts in this order in SSMS:**

```
1. ddl_scripts.sql          → Creates DB + all 11 tables
2. dml_scripts.sql          → Populates all tables with sample data
3. views.sql                → Creates 6 views
4. indexes.sql              → Creates 11 indexes
5. triggers.sql             → Creates 5 triggers
6. functions.sql            → Creates 7 functions
7. transactions_dcl.sql     → Runs TCL demos + DCL setup
8. queries.sql              → Run individual queries for output
```

> **Prerequisite:** SQL Server 2016+ or SQL Server Express. Enable execution in SSMS with `USE HotelReservationDB;` at the top of each session.

---

## Sample Queries

```sql
-- Available rooms for a date range
SELECT * FROM dbo.fn_GetAvailableRooms(1, '2025-08-01', '2025-08-05', NULL);

-- Occupancy rate per hotel
SELECT * FROM dbo.vw_OccupancyRate ORDER BY OccupancyRatePercent DESC;

-- Revenue by hotel
SELECT * FROM dbo.vw_RevenueByHotel ORDER BY TotalRevenue DESC;

-- Check if a room is available
SELECT dbo.fn_IsRoomAvailable(3, '2025-08-01', '2025-08-05') AS Available;

-- Calculate room charge with discount
SELECT dbo.fn_CalculateRoomCharge(5, '2025-08-01', '2025-08-04', 10.00) AS TotalCharge;

-- Customer full history
SELECT * FROM dbo.fn_GetCustomerReservationHistory(2);
```

---

## Database Schema

| Table            | Rows (Sample) | Purpose                          |
|------------------|---------------|----------------------------------|
| Hotels           | 5             | Master hotel data                |
| Departments      | 15            | Hotel departments                |
| Staff            | 10            | Employee records                 |
| RoomCategories   | 5             | Room types & pricing             |
| Rooms            | 20            | Individual rooms                 |
| Amenities        | 10            | Room features                    |
| RoomAmenities    | 50+           | Room-Amenity M:M mapping         |
| Customers        | 15            | Guest profiles                   |
| Reservations     | 14            | Booking records                  |
| Payments         | 11            | Payment transactions             |
| AuditLog         | Auto-generated| Trigger-based change log         |

---

## Role-Based Access (DCL)

| Role               | Permissions                                      |
|--------------------|--------------------------------------------------|
| HotelReceptionist  | SELECT/INSERT on Reservations, Payments, Rooms   |
| HotelManager       | Full DML on all operational tables               |
| HotelAuditor       | SELECT only on AuditLog, Payments, Reservations  |
| HotelReports       | SELECT on all Views only                         |

-----------------------------------------------------------------------------

                                                  Capstone Project | P4 – Hotel Reservation System
