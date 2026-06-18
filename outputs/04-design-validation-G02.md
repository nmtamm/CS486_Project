# Database Design Validation — School Shared Space Booking System

> Based on: [Conceptual Design / ERD](02-erd-design-G02.md), [Logical Design](03-logical-design-G02.md), and [Business Requirement Analysis](01-business-req-analysis-G02.md)

---

## 1. Schema vs. ERD Validation

### 1.1 Entity-to-Table Mapping

| ERD Entity | Schema Table | Status |
| ---------- | ------------ | ------ |
| User | User | ✅ Present as independent table |
| Space | Space | ✅ Present as independent table |
| Facility | Facility | ✅ Present as independent table |
| SpaceFacility | SpaceFacility | ✅ Present as junction table |
| BookingRequest | BookingRequest | ✅ Present as independent table |
| MaintenanceRecord | MaintenanceRecord | ✅ Present as independent table |

**Weak Entity Check:** No weak entities exist in the ERD. The only composite PK is in SpaceFacility (junction table), correctly referencing parent tables Space and Facility. ✅

### 1.2 Attribute Translation

| Entity | Attribute | ERD Type | Schema Type | Status |
| ------ | --------- | -------- | ----------- | ------ |
| User | user_id | varchar PK | varchar PK | ✅ |
| User | full_name | nvarchar | nvarchar | ✅ |
| User | email | varchar UK | varchar | ✅ |
| User | phone_number | varchar | varchar | ✅ |
| User | role | varchar | varchar | ✅ |
| User | department | nvarchar | nvarchar | ✅ |
| User | account_status | varchar | varchar | ✅ |
| Space | space_code | varchar PK | varchar PK | ✅ |
| Space | space_name | nvarchar | nvarchar | ✅ |
| Space | space_type | varchar | varchar | ✅ |
| Space | building | nvarchar | nvarchar | ✅ |
| Space | floor | int | int | ✅ |
| Space | room_number | varchar | varchar | ✅ |
| Space | capacity | int | int | ✅ |
| Space | current_status | varchar | varchar | ✅ |
| Space | usage_policy | nvarchar | nvarchar | ✅ |
| Facility | facility_id | varchar PK | varchar PK | ✅ |
| Facility | facility_name | varchar | varchar | ✅ |
| Facility | description | nvarchar | nvarchar | ✅ |
| SpaceFacility | space_code | varchar PK,FK | varchar PK,FK | ✅ |
| SpaceFacility | facility_id | varchar PK,FK | varchar PK,FK | ✅ |
| SpaceFacility | quantity | int | int | ✅ |
| BookingRequest | booking_id | varchar PK | varchar PK | ✅ |
| BookingRequest | space_code | varchar FK | varchar FK | ✅ |
| BookingRequest | requester_id | varchar FK | varchar FK | ✅ |
| BookingRequest | requested_start_time | datetime | datetime | ✅ |
| BookingRequest | requested_end_time | datetime | datetime | ✅ |
| BookingRequest | purpose | varchar | varchar | ✅ |
| BookingRequest | expected_participants | int | int | ✅ |
| BookingRequest | booking_status | varchar | varchar | ✅ |
| BookingRequest | approver_id | varchar FK | varchar FK | ✅ |
| BookingRequest | decision_time | datetime | datetime | ✅ |
| BookingRequest | decision_note | nvarchar | nvarchar | ✅ |
| BookingRequest | rejection_reason | nvarchar | nvarchar | ✅ |
| BookingRequest | actual_start_time | datetime | datetime | ✅ |
| BookingRequest | checked_in_by | varchar FK | varchar FK | ✅ |
| BookingRequest | initial_condition | nvarchar | nvarchar | ✅ |
| BookingRequest | actual_end_time | datetime | datetime | ✅ |
| BookingRequest | completed_by | varchar FK | varchar FK | ✅ |
| BookingRequest | final_condition | nvarchar | nvarchar | ✅ |
| BookingRequest | usage_notes | nvarchar | nvarchar | ✅ |
| MaintenanceRecord | maintenance_id | varchar PK | varchar PK | ✅ |
| MaintenanceRecord | space_code | varchar FK | varchar FK | ✅ |
| MaintenanceRecord | reporter_id | varchar FK | varchar FK | ✅ |
| MaintenanceRecord | assigned_staff_id | varchar FK | varchar FK | ✅ |
| MaintenanceRecord | problem_description | nvarchar | nvarchar | ✅ |
| MaintenanceRecord | problem_type | varchar | varchar | ✅ |
| MaintenanceRecord | start_time | datetime | datetime | ✅ |
| MaintenanceRecord | completion_time | datetime | datetime | ✅ |
| MaintenanceRecord | status | varchar | varchar | ✅ |
| MaintenanceRecord | result_note | nvarchar | nvarchar | ✅ |

All attributes from the ERD are present in the logical schema with matching names and data types. ✅

### 1.3 Relationship & Cardinality

| Relationship (ERD) | Cardinality | Schema Implementation | Status |
| ------------------ | ----------- | -------------------- | ------ |
| User submits BookingRequest | 1 → N | `BookingRequest.requester_id` FK → `User.user_id` (FK on many side) | ✅ |
| Space is booked in BookingRequest | 1 → N | `BookingRequest.space_code` FK → `Space.space_code` (FK on many side) | ✅ |
| User (approver) approves BookingRequest | 0..1 → N | `BookingRequest.approver_id` FK → `User.user_id` (nullable, on many side) | ✅ |
| User (check-in) checks in BookingRequest | 0..1 → N | `BookingRequest.checked_in_by` FK → `User.user_id` (nullable, on many side) | ✅ |
| User (completes) completes BookingRequest | 0..1 → N | `BookingRequest.completed_by` FK → `User.user_id` (nullable, on many side) | ✅ |
| Space equipped with SpaceFacility | 1 → N | `SpaceFacility.space_code` FK → `Space.space_code` (FK on many side) | ✅ |
| Facility installed in SpaceFacility | 1 → N | `SpaceFacility.facility_id` FK → `Facility.facility_id` (FK on many side) | ✅ |
| User reports MaintenanceRecord | 1 → N | `MaintenanceRecord.reporter_id` FK → `User.user_id` (FK on many side) | ✅ |
| User assigned to MaintenanceRecord | 0..1 → N | `MaintenanceRecord.assigned_staff_id` FK → `User.user_id` (nullable, on many side) | ✅ |
| Space undergoes MaintenanceRecord | 1 → N | `MaintenanceRecord.space_code` FK → `Space.space_code` (FK on many side) | ✅ |

**Many-to-Many (Space ↔ Facility):** Resolved via `SpaceFacility` junction table with composite PK `(space_code, facility_id)`, each being FK to parent tables. ✅

**One-to-One:** No explicit 1:1 relationships in the ERD. Check-in and check-out are handled as roles with nullable FKs in BookingRequest, correct for optional 0..1 participation. ✅

---

## 2. Schema vs. Business Requirements

### 2.1 Uniqueness and Identity Rules

| Rule Source | Requirement | Schema Enforcement | Status |
| ----------- | ----------- | ----------------- | ------ |
| Business Requirements §3 (User row) | User email must be globally unique | Logical schema diagram marks `email` with ⭐ (Unique Key) (03-logical-design-G02.md §1, User table); ERD also marks it as UK | ✅ Present as Unique Key |

### 2.2 Domain and Business Logic Constraints

| Business Rule | Requirement | Schema Enforcement | Status |
| ------------- | ----------- | ----------------- | ------ |
| BR-01 | Roles: student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager | CHECK constraint on `role` (03-logical-design-G02.md §2) | ✅ |
| BR-02 | Account statuses: active, inactive, suspended | CHECK constraint on `account_status` | ✅ |
| BR-03 | Space types: auditorium, classroom, computer_laboratory, project_laboratory, meeting_room, student_workspace | CHECK constraint on `space_type` | ✅ |
| BR-04 | Space statuses: available, in_use, under_maintenance, temporarily_closed, retired | CHECK constraint on `current_status` | ✅ |
| BR-05 | Booking purposes: lecture, examination, seminar, workshop, meeting, student_activity, administrative_event | CHECK constraint on `purpose` | ✅ |
| BR-06 | Booking statuses: pending, approved, rejected, cancelled, checked_in, completed, no_show | CHECK constraint on `booking_status` | ✅ |
| BR-07 | All booking requests require approval by facility staff/manager | Application Logic (approver_id + role check) | ✅ |
| BR-08 | Pending booking can be approved or rejected | Application Logic | ✅ |
| BR-09 | Allowed booking status transitions | Trigger / Stored Procedure | ✅ |
| BR-10 | No overlapping approved bookings for same space | Trigger / Stored Procedure | ✅ |
| BR-11 | Space under maintenance/closed/retired cannot be booked | Application Logic | ✅ |
| BR-12 | Any user role may book any space type | Application Logic | ✅ |
| BR-13 | Maintenance statuses: reported, in_progress, completed, cancelled | CHECK constraint on `status` | ✅ |
| BR-14 | Space set to under_maintenance prevents new bookings | Application Logic | ✅ |
| BR-15 | Check-in records actual start time, staff ID, initial condition | Application Logic | ✅ |
| BR-16 | Check-out records actual end time, final condition, usage notes | Application Logic | ✅ |
| BR-17 | No-show transition from approved | Trigger / Stored Procedure | ✅ |
| BR-18 | Full historical records maintained indefinitely | Application Logic | ✅ |
| BR-19 | Rejected booking must store rejection reason | CHECK + Application Logic | ✅ |
| BR-20 | Facility manager manages space catalog | Application Logic | ✅ |
| BR-21 | M:N Space-Facility via SpaceFacility | Composite PK + FOREIGN KEY | ✅ |

---

## 3. Issues

No issues identified.

---

## 4. Notes

Since these steps are unrelated to SQL yet, do not try to check for any requirements that are SQL-specific (such as using CHECK for predefined values). All CHECK-based domain constraints noted above are documented here for traceability but are noted as application-logic-level concerns where SQL CHECK is not yet implemented.
