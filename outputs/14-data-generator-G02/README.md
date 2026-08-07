# Step 14 — Bulk Sample Data Generator (`14-data-generator-G02`)

This directory contains the complete sample data generation suite for **Phase 2** of the School of Computer Science Space Booking System, targeting the **`SpaceBookingDB_Phase2`** MS SQL Server database.

## Output Deliverables

| File Name | Description |
| :--- | :--- |
| **`reset_database_data.sql`** | T-SQL script to clean all data from database tables in strict reverse Foreign Key dependency order and reseed IDENTITY counters to 0. |
| **`test_db_connection.py`** | Diagnostic Python script to test MS SQL Server connection parameters and confirm schema readiness of all 10 tables. |
| **`generate_bulk_data.py`** | Core Python generator producing **100,000 `SpaceBooking` records**, **~50,000 `BookingApproval` records**, **~50,000 `SpaceUsageSession` records**, and prerequisite master data across 3 academic years (2023–2026). |
| **`verify_data_integrity.sql`** | T-SQL verification report validating table counts, foreign key integrity (0 orphans), workflow consistency, and zero schedule overlaps. |
| **`README.md`** | Usage instructions and architecture documentation. |

---

## Target Volume & Distribution

* **`Semester`**: 9 records across 3 Academic Years (2023–2024, 2024–2025, 2025–2026).
* **`SpaceTypeBookingPolicy`**: 4 configuration rows (`auditorium`, `classroom`, `computer_lab`, `meeting_room`).
* **`CampusUser`**: 2,500 active users (2,000 students, 350 lecturers, 100 TAs, 30 staff, 15 admins, 5 managers).
* **`CampusSpace`**: 60 spaces (4 Auditoriums, 30 Classrooms, 16 Computer Labs, 10 Meeting Rooms).
* **`CampusFacility`**: 180 equipment items.
* **`SpaceMaintenance`**: 1,500 records (80% `advisory`, 20% `out_of_service`).
* **`SpaceBooking`**: **100,000 records** (50% instant booking, 50% staff approval).
* **`BookingApproval`**: **~50,000 records** for non-instant bookings.
* **`SpaceUsageSession`**: **~50,000 records** for all completed bookings.

---

## Setup & Execution Instructions

### Step 1: Environment Setup & Package Installation
Create virtual environment and install required dependencies:
```cmd
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install pyodbc faker
```

### Step 2: Ensure Target Database Schema Exists
Execute `10-schema-migration-G02.sql` to create `SpaceBookingDB_Phase2` and its schema objects:
```cmd
sqlcmd -S localhost -E -C -i outputs/10-schema-migration-G02.sql
```

### Step 3: Clear Database Data (Optional Reset)
Clean existing table data in reverse FK order and reseed IDENTITY counters:
```cmd
sqlcmd -S localhost -E -C -d SpaceBookingDB_Phase2 -i outputs/14-data-generator-G02/reset_database_data.sql
```

### Step 4: Run Diagnostic Connection Test
Confirm database connection and schema readiness of all 10 tables:
```cmd
.\.venv\Scripts\python.exe outputs/14-data-generator-G02/test_db_connection.py
```

### Step 5: Run High-Performance Bulk Data Generator
Populate 100,000 `SpaceBooking` records, ~50,000 `BookingApproval` records, and ~50,000 `SpaceUsageSession` records:
```cmd
.\.venv\Scripts\python.exe outputs/14-data-generator-G02/generate_bulk_data.py
```

### Step 6: Verify Data Volume and Integrity
Validate row counts, zero orphan records, workflow consistency, and zero schedule overlaps:
```cmd
sqlcmd -S localhost -E -C -d SpaceBookingDB_Phase2 -i outputs/14-data-generator-G02/verify_data_integrity.sql
```
