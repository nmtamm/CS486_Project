# Database Design Validation

**Group:** G02

**Date:** 2026-06-27

---

## 1. ERD-to-Relational Mapping Completeness

| ERD Entity (Document 02 §2) | Relational Table (Document 03 §1) | Status |
|---|---|---|
| CampusUser | CampusUser | ✓ |
| CampusSpace | CampusSpace | ✓ |
| CampusFacility | CampusFacility | ✓ |
| CampusSpaceFacility | CampusSpaceFacility | ✓ |
| SpaceBooking | SpaceBooking | ✓ |
| BookingApproval | BookingApproval | ✓ |
| SpaceUsageSession | SpaceUsageSession | ✓ |
| SpaceMaintenance | SpaceMaintenance | ✓ |

All 8 entities from the ERD are mapped to corresponding tables.

---

## 2. Attribute Coverage

| Entity | Required Attributes | Present | Missing |
|---|---|---|---|
| CampusUser | campus_user_id, full_name, email, role, department, account_status | ✓ All | None |
| CampusSpace | campus_space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy | ✓ All | None |
| CampusFacility | campus_facility_id, facility_name | ✓ All | None |
| CampusSpaceFacility | campus_space_code, campus_facility_id | ✓ Both | None; added quantity for completeness |
| SpaceBooking | space_booking_id, requester_id, campus_space_code, requested_start_time, requested_end_time, purpose_type, expected_participants, status | ✓ All | None; added submitted_at for audit |
| BookingApproval | booking_approval_id, space_booking_id, staff_id, decision, decision_time, decision_note | ✓ All | None; added rejection_reason per BR4 |
| SpaceUsageSession | space_usage_session_id, space_booking_id, checked_in_by, actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes | ✓ All | None |
| SpaceMaintenance | space_maintenance_id, campus_space_code, reporter_id, assigned_staff_id, problem_description, start_time, completion_time, status, result_note | ✓ All | None; added problem_type for categorization |

---

## 3. Key Validation

### 3.1. Primary Keys

| Table | PK | Justification |
|---|---|---|
| CampusUser | campus_user_id | Surrogate key; email is also a candidate key |
| CampusSpace | campus_space_code | Natural key from business |
| CampusFacility | campus_facility_id | Surrogate key |
| CampusSpaceFacility | campus_space_facility_id | Surrogate; (campus_space_code, campus_facility_id) is alternate key |
| SpaceBooking | space_booking_id | Surrogate key |
| BookingApproval | booking_approval_id | Surrogate; space_booking_id is also unique (1:1) |
| SpaceUsageSession | space_usage_session_id | Surrogate; space_booking_id is also unique (1:1) |
| SpaceMaintenance | space_maintenance_id | Surrogate key |

### 3.2. Foreign Keys

| FK | Source → Target | Validates |
|---|---|---|
| SpaceBooking.requester_id → CampusUser.campus_user_id | Every booking has a requester | ✓ |
| SpaceBooking.campus_space_code → CampusSpace.campus_space_code | Every booking references a valid space | ✓ |
| CampusSpaceFacility.campus_space_code → CampusSpace.campus_space_code | Facility assignment to valid space | ✓ |
| CampusSpaceFacility.campus_facility_id → CampusFacility.campus_facility_id | References valid facility | ✓ |
| BookingApproval.space_booking_id → SpaceBooking.space_booking_id | UNIQUE ensures 1:1 | ✓ |
| BookingApproval.staff_id → CampusUser.campus_user_id | Approver is a valid user | ✓ |
| SpaceUsageSession.space_booking_id → SpaceBooking.space_booking_id | UNIQUE ensures 1:1 | ✓ |
| SpaceUsageSession.checked_in_by → CampusUser.campus_user_id | Check-in staff is valid user | ✓ |
| SpaceMaintenance.campus_space_code → CampusSpace.campus_space_code | Maintenance belongs to valid space | ✓ |
| SpaceMaintenance.reporter_id → CampusUser.campus_user_id | Reporter is valid user | ✓ |
| SpaceMaintenance.assigned_staff_id → CampusUser.campus_user_id | Assignee is valid user (nullable) | ✓ |

### 3.3. Referential Integrity Actions

All FKs use `ON DELETE NO ACTION` (default) to prevent accidental deletion of referenced data, preserving historical records per BR10.

---

## 4. Business Rule Verification

| BR# | Rule | Satisfied? | Mechanism |
|---|---|---|---|
| BR1 | No overlapping approved bookings | ✓ | Trigger/application enforcement (see Document 03 §5 note) |
| BR2 | Unavailable spaces cannot be booked | ✓ | CampusSpace.current_status check before approval |
| BR3 | Status flow | ✓ | CHECK constraint on SpaceBooking.status |
| BR4 | Rejection reason required | ✓ | CHECK constraint: rejection_reason IS NOT NULL when decision = 'rejected' |
| BR5 | Approval by staff/manager | ✓ | Application logic (role check); DB stores staff_id |
| BR6 | Check-in by staff | ✓ | Application logic (role check) |
| BR7 | Capacity check | ✓ | CHECK (expected_participants > 0); app-level check against CampusSpace.capacity |
| BR8 | Start before end | ✓ | CHECK (requested_end_time > requested_start_time) |
| BR9 | Maintenance prevents booking | ✓ | Application checks CampusSpace.current_status and active maintenance records |
| BR10 | Historical preservation | ✓ | No hard deletes; soft statuses retained; ON DELETE NO ACTION |

---

## 5. Normalization Check

### 5.1. 1NF (First Normal Form)

All tables have atomic columns and a primary key. ✓

### 5.2. 2NF (Second Normal Form)

All non-key attributes are fully functionally dependent on the entire primary key. The CampusSpaceFacility bridge table has a surrogate PK, and the only non-key attribute (quantity) depends on the full (campus_space_code, campus_facility_id) pair. ✓

### 5.3. 3NF (Third Normal Form)

No transitive dependencies exist. All non-key attributes depend only on the primary key. ✓

### 5.4. BCNF (Boyce-Codd Normal Form)

Every determinant is a candidate key. ✓

**Conclusion:** The schema is in BCNF.

---

## 6. Completeness Against Business Requirements

| Requirement (from Document 01) | Coverage |
|---|---|
| User information & roles (E1) | CampusUser table with role enum |
| Space information & status (E2) | CampusSpace table with current_status |
| Facility tracking (E3) | CampusFacility + CampusSpaceFacility tables |
| Booking submission (E4) | SpaceBooking table |
| Conflict prevention (BR1, BR2) | Enforcement via trigger/application |
| Approval workflow (E5) | BookingApproval table |
| Check-in/out sessions (E6) | SpaceUsageSession table |
| Maintenance management (E7) | SpaceMaintenance table |
| Historical records (BR10) | Soft retention strategy |
| Reporting | Supported via querying all tables |

---

## 7. Issues and Recommendations

| # | Issue | Recommendation |
|---|---|---|
| 1 | BR1 overlap prevention not fully expressible in DDL | Implement as a `BEFORE INSERT/UPDATE` trigger on SpaceBooking (see Document 05) |
| 2 | No explicit role-permission table | Currently acceptable; roles are enum. If permissions grow, consider a separate permission model. |
| 3 | CampusSpace.current_status and SpaceMaintenance.status could become inconsistent | Consider a trigger that auto-updates CampusSpace.current_status when an active maintenance record exists. |
| 4 | No uniqueness constraint on (building, floor, room_number) in CampusSpace | Consider adding a UNIQUE constraint to prevent duplicate room entries. |
