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

**Weak Entity Check:** No weak entities exist in the ERD; no composite PK involving a parent PK beyond the SpaceFacility junction table. ✅

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
| User submits BookingRequest | 1 → N | `BookingRequest.requester_id` FK → `User.user_id` | ✅ |
| Space is booked in BookingRequest | 1 → N | `BookingRequest.space_code` FK → `Space.space_code` | ✅ |
| User (approver) approves BookingRequest | 0..1 → N | `BookingRequest.approver_id` FK → `User.user_id` (nullable) | ✅ |
| User (check-in) checks in BookingRequest | 0..1 → N | `BookingRequest.checked_in_by` FK → `User.user_id` (nullable) | ✅ |
| User (completes) completes BookingRequest | 0..1 → N | `BookingRequest.completed_by` FK → `User.user_id` (nullable) | ✅ |
| Space equipped with SpaceFacility | 1 → N | `SpaceFacility.space_code` FK → `Space.space_code` | ✅ |
| Facility installed in SpaceFacility | 1 → N | `SpaceFacility.facility_id` FK → `Facility.facility_id` | ✅ |
| User reports MaintenanceRecord | 1 → N | `MaintenanceRecord.reporter_id` FK → `User.user_id` | ✅ |
| User assigned to MaintenanceRecord | 0..1 → N | `MaintenanceRecord.assigned_staff_id` FK → `User.user_id` (nullable) | ✅ |
| Space undergoes MaintenanceRecord | 1 → N | `MaintenanceRecord.space_code` FK → `Space.space_code` | ✅ |

**Many-to-Many:** Space ↔ Facility resolved via SpaceFacility junction table with composite PK `(space_code, facility_id)`. ✅

**One-to-One:** No explicit 1:1 relationships in the ERD. Check-in and check-out are represented as relationship roles (User checks in / completes BookingRequest) via nullable FKs in BookingRequest. ✅

---

## 2. Schema vs. Business Requirements

### 2.1 Uniqueness and Identity Rules

| Business Rule | Requirement | Schema Enforcement | Status |
| ------------- | ----------- | ----------------- | ------ |
| User email must be globally unique | Business Requirements §3 (User row) | Not enforced in schema enforcement map; ERD shows `email UK` but schema diagram does not explicitly indicate a UNIQUE constraint | ❌ **Missing UNIQUE constraint on `User.email`** |

### 2.2 Domain and Business Logic Constraints

| Business Rule | Requirement | Schema Enforcement | Status |
| ------------- | ----------- | ----------------- | ------ |
| BR-01 | Roles: student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager | CHECK constraint on `role` | ✅ |
| BR-02 | Account statuses: active, inactive, suspended | CHECK constraint on `account_status` | ✅ |
| BR-03 | Space types: auditorium, classroom, computer_laboratory, project_laboratory, meeting_room, student_workspace | CHECK constraint on `space_type` | ✅ |
| BR-04 | Space statuses: available, in_use, under_maintenance, temporarily_closed, retired | CHECK constraint on `current_status` | ✅ |
| BR-05 | Booking types: lecture, examination, seminar, workshop, meeting, student_activity, administrative_event | CHECK constraint on `purpose` | ✅ |
| BR-06 | Booking statuses: pending, approved, rejected, cancelled, checked_in, completed, no_show | CHECK constraint on `booking_status` | ⚠️ **Minor inconsistency: ERD uses `no-show` (hyphen) while BR/schema use `no_show` (underscore)** |
| BR-07 | All booking requests require approval | Application Logic | ✅ |
| BR-08 | Pending can be approved/rejected | Application Logic | ✅ |
| BR-09 | Allowed status transitions | Trigger / Stored Procedure | ✅ |
| BR-10 | No overlapping approved bookings | Trigger / Stored Procedure | ✅ |
| BR-11 | Unavailable space cannot be booked | Application Logic | ✅ |
| BR-12 | Any role may book any space type | Application Logic | ✅ |
| BR-13 | Maintenance statuses: reported, in_progress, completed, cancelled | CHECK constraint on `status` | ✅ |
| BR-14 | Space under maintenance prevents bookings | Application Logic | ✅ |
| BR-15 | Maintenance record may link to a booking | Application Logic | ❌ **Missing FK `related_booking_id` from MaintenanceRecord to BookingRequest** |
| BR-16 | Check-in records actual start, staff, condition | Application Logic | ✅ |
| BR-17 | Check-out records actual end, condition, notes | Application Logic | ✅ |
| BR-18 | No-show transition | Trigger / Stored Procedure | ✅ |
| BR-19 | Full historical records | Application Logic | ✅ |
| BR-20 | Rejected booking must store reason | CHECK + Application Logic | ✅ |
| BR-21 | Facility manager manages space catalog | Application Logic | ✅ |
| BR-22 | M:N Space-Facility via SpaceFacility | Composite PK, FK | ✅ |

---

## 3. Issues

| ID | Severity | Issue | Detail |
| --- | -------- | ----- | ------ |
| IS-01 | **High** | Missing UNIQUE constraint on `User.email` | The ERD (Step 2) marks `email` as UK (Unique Key), and the business requirements state each user must have a unique email. The logical schema (Step 3) does not include a UNIQUE constraint on `User.email` in its enforcement map. |
| IS-02 | **Medium** | Missing FK `related_booking_id` in `MaintenanceRecord` | BR-15 states a maintenance record may optionally be linked to a specific booking request. Neither the ERD nor the logical schema includes a `related_booking_id` FK column from `MaintenanceRecord` to `BookingRequest`. |
| IS-03 | **Low** | Inconsistent booking status value: `no-show` vs `no_show` | The ERD (Step 2) lists `no-show` (hyphen) as a booking status value. The business requirements (BR-06) and logical schema enforcement map (Step 3) use `no_show` (underscore). This must be resolved to a single consistent value. |
| IS-04 | **Low** | ApprovalDecision, CheckIn, CheckOut consolidated into BookingRequest | The business requirements (Section 3) define ApprovalDecision, CheckIn, and CheckOut as separate entities. The ERD and schema consolidate their attributes into the BookingRequest table. While technically valid (best suited for 1:1 relationships), this deviates from the business requirements document and reduces traceability. |
| IS-05 | **Low** | ERD participation inconsistency: User submits BookingRequest | The Mermaid diagram shows `User ||--o{ BookingRequest` (mandatory User participation), but the Relationship Summary (Step 2, §3) correctly states User participation is optional. The schema implements optional participation via nullable FK, which is correct. |
| IS-06 | **Low** | No explicit CHECK constraints documented for problem_type | The ERD lists `problem_type` with predefined values (`broken_projector`, `air_conditioning_failure`, `damaged_furniture`, `cleaning_issue`, `network_problem`), but the logical schema enforcement map does not include a CHECK constraint for this attribute. |

---

## 4. Overall Verdict

| Criteria | Result |
| -------- | ------ |
| All ERD entities mapped to schema tables | ✅ Pass |
| All attributes translated correctly | ✅ Pass (with minor caveat IS-03) |
| All relationships implemented with correct FKs | ✅ Pass |
| Many-to-Many resolved with junction table | ✅ Pass |
| Domain constraints enforced | ✅ Pass (with minor caveat IS-06) |
| Business rules addressed in enforcement map | ⚠️ **Conditional Pass** (IS-01, IS-02 need resolution) |

**Verdict: Conditionally Passed.** Two high/medium issues must be resolved before the schema is fully correct:
1. Add a UNIQUE constraint on `User.email` (IS-01).
2. Add an optional FK `related_booking_id` from `MaintenanceRecord` to `BookingRequest` to support BR-15 (IS-02).
