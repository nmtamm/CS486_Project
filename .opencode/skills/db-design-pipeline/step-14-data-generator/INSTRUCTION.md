# Step 14: Sample Data Generation (`step-14-data-generator`)

Save to:
`outputs/14-data-generator-G02/`

## Task Identity

Perform **Phase 2 — Bulk Sample Data Generation**.

Design, specify, and execute data generation scripts to create a realistic database dataset containing at least **100,000 `SpaceBooking` records**, **~50,000 `BookingApproval` records**, and **~50,000 `SpaceUsageSession` records**, alongside all prerequisite master data across **3+ academic years** (2023–2026).

Deliverable files under `outputs/14-data-generator-G02/`:
1. `reset_database_data.sql` — T-SQL script to clean all data from database tables in strict reverse FK dependency order.
2. `test_db_connection.py` — Python diagnostic script for testing database connectivity and schema readiness.
3. `generate_bulk_data.py` — Core bulk generator script (conceptual specification provided below; no explicit Python code inline).
4. `verify_data_integrity.sql` — T-SQL verification script to validate row counts, FK integrity, and zero schedule overlaps.
5. `README.md` — Complete execution instructions.

---

## Mandatory Input Documents & Precedence Rules

Read, in precedence order:
1. `outputs/10-schema-migration-G02.sql` — Target database schema definition.
2. `outputs/09-updated-erd-and-logical-design-G02.md` — Entity relationships and attribute constraints.
3. `outputs/06-sample-data-G02.sql` — Baseline seed data and status transition rules.

---

## Section 1: Database Cleanup Script (`reset_database_data.sql`)

To re-run data generation cleanly, tables must be emptied in **strict reverse Foreign Key dependency order** so that delete operations do not violate foreign key constraints.

### FK-Safe Deletion Order:
1. `FacilityMaintenance` (References `CampusFacility`, `CampusUser`)
2. `SpaceMaintenance` (References `CampusSpace`, `CampusUser`)
3. `SpaceUsageSession` (References `SpaceBooking`, `CampusUser`)
4. `BookingApproval` (References `SpaceBooking`, `CampusUser`)
5. `SpaceBooking` (References `CampusUser`, `CampusSpace`)
6. `CampusFacility` (References `CampusSpace`)
7. `CampusSpace` (References `SpaceTypeBookingPolicy`)
8. `SpaceTypeBookingPolicy` (Master lookup table)
9. `CampusUser` (Master lookup table)
10. `Semester` (Master reference table)

### `reset_database_data.sql` Specification:
```sql
USE SpaceBookingDB_Phase2;
GO

SET NOCOUNT ON;
PRINT 'Starting full data reset in reverse FK dependency order...';

-- Disable constraints temporarily to speed up deletion
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
GO

-- Delete rows in reverse dependency order
DELETE FROM FacilityMaintenance;
DELETE FROM SpaceMaintenance;
DELETE FROM SpaceUsageSession;
DELETE FROM BookingApproval;
DELETE FROM SpaceBooking;
DELETE FROM CampusFacility;
DELETE FROM CampusSpace;
DELETE FROM SpaceTypeBookingPolicy;
DELETE FROM CampusUser;
DELETE FROM Semester;
GO

-- Reseed IDENTITY counters
DBCC CHECKIDENT ('SpaceBooking', RESEED, 0);
DBCC CHECKIDENT ('BookingApproval', RESEED, 0);
DBCC CHECKIDENT ('SpaceUsageSession', RESEED, 0);
DBCC CHECKIDENT ('SpaceMaintenance', RESEED, 0);
DBCC CHECKIDENT ('FacilityMaintenance', RESEED, 0);
DBCC CHECKIDENT ('CampusUser', RESEED, 0);
DBCC CHECKIDENT ('CampusFacility', RESEED, 0);
DBCC CHECKIDENT ('Semester', RESEED, 0);
GO

-- Re-enable constraints
EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";
GO

PRINT 'Database reset complete. All table schemas preserved with 0 rows.';
GO
```

---

## Section 2: Database Connection Testing Script (`test_db_connection.py`)

Verify Python environment, ODBC driver, database availability, and table schema readiness before running data generation.

### Connection Requirements & Verification Logic:
- **Python Version:** Python 3.8 or higher.
- **Database Driver:** `pyodbc` with `{ODBC Driver 17 for SQL Server}` or `{SQL Server}`.
- **Diagnostics Performed:**
  1. Execute `SELECT @@VERSION, DB_NAME()` to confirm connection to `SpaceBookingDB_Phase2`.
  2. Query `INFORMATION_SCHEMA.TABLES` to verify existence of all required tables: `Semester`, `SpaceTypeBookingPolicy`, `CampusUser`, `CampusSpace`, `CampusFacility`, `SpaceBooking`, `BookingApproval`, `SpaceUsageSession`, `SpaceMaintenance`, `FacilityMaintenance`.

---

## Section 3: Bulk Sample Data Generator Specifications (`generate_bulk_data.py`)

*(Note: Implementation specifications and logic rules are defined below. No explicit Python code is included in this instruction file).*

### 3.1 Python Environment & Libraries
- **Runtime:** Python 3.8+
- **Required Libraries:**
  - `pyodbc`: SQL Server database connectivity with `cursor.fast_executemany = True` for high-throughput bulk inserts.
  - `faker`: Realistic name, email, phone number, and description generation.
  - `random` / `datetime` / `timedelta`: In-memory date sampling, probability distribution, and schedule interval math.

---

### 3.2 Reference Selection & Assignment Rules

#### A. Master Data Selection Rules:
1. **Requester Selection (`requester_id`):**
   - Sampled from `CampusUser` where `role IN ('student', 'lecturer', 'teaching_assistant', 'department_admin')`.
   - **Role Weighting:**
     - Auditoriums (`auditorium`): 70% Lecturers, 20% Dept Admins, 10% TAs.
     - Classrooms (`classroom`): 80% Lecturers, 15% TAs, 5% Dept Admins.
     - Computer Labs (`computer_lab`): 50% TAs, 35% Students, 15% Lecturers.
     - Meeting Rooms (`meeting_room`): 40% Students, 30% Lecturers, 30% Admins/TAs.
2. **Space & Policy Selection (`campus_space_code`, `is_instant_booking`):**
   - Space code randomly picked from active `CampusSpace` rows.
   - `is_instant_booking` is set strictly by looking up `SpaceTypeBookingPolicy.instant_booking_eligible` for the space's `space_type`:
     - `computer_lab` & `meeting_room` $\rightarrow$ `is_instant_booking = 1` (~50% of total bookings).
     - `auditorium` & `classroom` $\rightarrow$ `is_instant_booking = 0` (~50% of total bookings).
3. **Purpose & Participant Rules:**
   - Purpose chosen according to space type (e.g. `lecture`/`examination` for classrooms; `workshop` for labs; `meeting` for meeting rooms).
   - `expected_participants`: Uniform integer between 5 and `CampusSpace.capacity`.

#### B. Dependent Reference Assignment Rules:
1. **`BookingApproval` Generation Rule (~50,000 Records):**
   - **Trigger Condition:** Generated for non-instant bookings (`is_instant_booking == 0`) that transition to `approved`, `completed`, `checked_in`, `no-show`, or `rejected`.
   - **Staff Assignment (`staff_id`):** Randomly sampled from `CampusUser` where `role IN ('facility_staff', 'facility_manager')`.
   - **Decision Matching:**
     - If booking status is `approved`, `completed`, `checked_in`, or `no-show` $\rightarrow$ `decision = 'approved'`.
     - If booking status is `rejected` $\rightarrow$ `decision = 'rejected'`, with a valid `rejection_reason`.
   - **Timestamp Constraint:** `submitted_at` $\le$ `decision_time` $\le$ `requested_start_time`.
2. **`SpaceUsageSession` Generation Rule (~50,000 Records):**
   - **Trigger Condition:** Generated for all bookings with status `completed` or `checked_in`.
   - **Staff Assignment (`checked_in_by`):** Sampled from `CampusUser` (`facility_staff` or `requester_id`).
   - **Timestamp Constraints:**
     - `actual_start_time`: `requested_start_time` $\pm$ 10 minutes.
     - `actual_end_time`: `requested_end_time` $\pm$ 15 minutes for `completed` status; `NULL` for `checked_in`.

---

### 3.3 Target Volume & Scale Breakdown

To support indexing performance analysis on 3+ academic years (2023–2026):

| Entity Name | Target Record Count | Generation & Workflow Rule |
| :--- | :--- | :--- |
| **`Semester`** | **9** | 3 academic years (Fall, Spring, Summer semesters). |
| **`CampusUser`** | **2,500** | 2,000 Students, 350 Lecturers, 100 TAs, 50 Staff/Admins. |
| **`CampusSpace`** | **60** | 4 Auditoriums, 30 Classrooms, 16 Computer Labs, 10 Meeting Rooms. |
| **`CampusFacility`** | **180** | Equipment items assigned to spaces. |
| **`SpaceMaintenance`** | **1,500** | 80% `advisory`, 20% `out_of_service`. |
| **`SpaceBooking`** | **100,000** | Main booking dataset (50% instant, 50% non-instant). |
| **`BookingApproval`** | **~50,000** | Approval/rejection decisions for all non-instant bookings. |
| **`SpaceUsageSession`** | **~50,000** | Check-in/out session logs for all completed bookings. |

#### Booking Status Breakdown (100,000 Total):
* **`completed` (50,000 rows / 50%):** Attended events with matching `SpaceUsageSession` logs.
* **`approved` (15,000 rows / 15%):** Upcoming/valid approved bookings.
* **`cancelled` (15,000 rows / 15%):** Requesters cancelled before start.
* **`rejected` (10,000 rows / 10%):** Non-instant requests rejected by staff due to conflict.
* **`no-show` (5,000 rows / 5%):** Approved bookings where requester failed to check in.
* **`pending` (5,000 rows / 5%):** Unresolved pending requests.

---

### 3.4 Generation Algorithm & Bulk Performance Strategy

1. **In-Memory Schedule Matrix:**
   - Maintain an in-memory space occupancy grid per space per day (30-minute interval slots from 07:00 to 21:00).
   - Pre-populate maintenance intervals (`out_of_service`) into the schedule grid.
2. **Date Sampling Loop (3 Academic Years):**
   - Iterate day-by-day across 1,095 days (Sept 2023 – Aug 2026).
   - Apply daily demand multipliers (Weekdays high, Weekends low, Semester breaks light).
   - For each booking request, sample requester, space, purpose, duration (1–3h), and start time (07:00–19:00).
   - If slot is clear of `out_of_service` maintenance and prior approved bookings:
     - Mark slot occupied in memory and assign status (`completed`, `approved`, `cancelled`, `no-show`).
   - If slot overlaps an existing approved booking or `out_of_service` maintenance:
     - Assign status = `'rejected'`.
3. **Bulk Insertion Engine (`fast_executemany`):**
   - Insert records in batches of 10,000 using PyODBC `fast_executemany = True`.
   - Batch insert `SpaceBooking`, followed by `BookingApproval` (~50k rows), followed by `SpaceUsageSession` (~50k rows).

---

## Section 4: Data Verification Step (`verify_data_integrity.sql`)

After data generation completes, execute `verify_data_integrity.sql` to validate that data volume, foreign key integrity, and business rules are fully satisfied.

### Verification Queries Script:
```sql
USE SpaceBookingDB_Phase2;
GO

SET NOCOUNT ON;
PRINT '================================================================';
PRINT '  PHASE 2 DATA GENERATION INTEGRITY VERIFICATION REPORT';
PRINT '================================================================';

-- 1. Table Record Counts
PRINT '1. Table Record Counts:';
SELECT 'Semester' AS TableName, COUNT(*) AS TotalRows FROM Semester
UNION ALL SELECT 'CampusUser', COUNT(*) FROM CampusUser
UNION ALL SELECT 'CampusSpace', COUNT(*) FROM CampusSpace
UNION ALL SELECT 'SpaceMaintenance', COUNT(*) FROM SpaceMaintenance
UNION ALL SELECT 'SpaceBooking', COUNT(*) FROM SpaceBooking
UNION ALL SELECT 'BookingApproval', COUNT(*) FROM BookingApproval
UNION ALL SELECT 'SpaceUsageSession', COUNT(*) FROM SpaceUsageSession;
GO

-- 2. FK Integrity Check (Orphan Records)
PRINT '2. Foreign Key Integrity Check (Orphan Records):';
SELECT 'Orphan Bookings (Invalid User)' AS Issue, COUNT(*) AS FaultCount 
FROM SpaceBooking WHERE requester_id NOT IN (SELECT campus_user_id FROM CampusUser)
UNION ALL
SELECT 'Orphan Bookings (Invalid Space)', COUNT(*) 
FROM SpaceBooking WHERE campus_space_code NOT IN (SELECT campus_space_code FROM CampusSpace)
UNION ALL
SELECT 'Orphan Approvals', COUNT(*) 
FROM BookingApproval WHERE space_booking_id NOT IN (SELECT space_booking_id FROM SpaceBooking)
UNION ALL
SELECT 'Orphan Sessions', COUNT(*) 
FROM SpaceUsageSession WHERE space_booking_id NOT IN (SELECT space_booking_id FROM SpaceBooking);
GO

-- 3. Workflow Consistency Checks
PRINT '3. Workflow Consistency Checks:';
SELECT 
    'Completed Bookings without Usage Session' AS CheckDescription,
    COUNT(*) AS ViolationCount
FROM SpaceBooking b
LEFT JOIN SpaceUsageSession s ON b.space_booking_id = s.space_booking_id
WHERE b.status = 'completed' AND s.space_usage_session_id IS NULL

UNION ALL

SELECT 
    'Non-Instant Approved Bookings without Approval Decision',
    COUNT(*)
FROM SpaceBooking b
LEFT JOIN BookingApproval a ON b.space_booking_id = a.space_booking_id
WHERE b.is_instant_booking = 0 
  AND b.status IN ('approved', 'completed', 'checked_in', 'rejected', 'no-show') 
  AND a.booking_approval_id IS NULL;
GO

-- 4. Non-Overlapping Invariant Verification for Approved/Completed Bookings
PRINT '4. Checking for Overlapping Approved Bookings (Should be 0):';
SELECT COUNT(*) AS OverlapViolations
FROM SpaceBooking b1
JOIN SpaceBooking b2 
  ON b1.campus_space_code = b2.campus_space_code
 AND b1.space_booking_id < b2.space_booking_id
 AND b1.status IN ('approved', 'completed', 'checked_in')
 AND b2.status IN ('approved', 'completed', 'checked_in')
 AND b1.requested_start_time < b2.requested_end_time
 AND b1.requested_end_time > b2.requested_start_time;
GO
```

---

## Section 5: Execution Flow

To set up and execute the complete sample data generation pipeline:

1. **Environment Setup & Package Installation:**
   ```bash
   py -m venv .venv
   .\.venv\Scripts\python.exe -m pip install pyodbc faker
   ```
2. **Clear Existing Database Data (Optional/Reset):**
   ```bash
   sqlcmd -S localhost -E -C -d SpaceBookingDB_Phase2 -i outputs/14-data-generator-G02/reset_database_data.sql
   ```
3. **Run Connection Diagnostic:**
   ```bash
   .\.venv\Scripts\python.exe outputs/14-data-generator-G02/test_db_connection.py
   ```
4. **Run Bulk Generator Script:**
   ```bash
   .\.venv\Scripts\python.exe outputs/14-data-generator-G02/generate_bulk_data.py
   ```
5. **Verify Data Volume & Integrity:**
   ```bash
   sqlcmd -S localhost -E -C -d SpaceBookingDB_Phase2 -i outputs/14-data-generator-G02/verify_data_integrity.sql
   ```
