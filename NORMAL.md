# Normalization Validation

The maximum evaluated level is BCNF. A normal form is claimed only when the current schema supports it without an additional business assumption.

## Overall verdict

All ten tables satisfy **BCNF** under the functional dependencies supported by the SQL schema. Every supported non-trivial determinant is a declared candidate key.

- **1NF:** Each column contains one atomic value, with no repeating groups.
- **2NF:** The table is in 1NF, and every non-key attribute depends on the whole candidate key.
- **3NF:** The table is in 2NF, and no non-key attribute depends transitively on a candidate key.
- **BCNF:** Every determinant in a non-trivial functional dependency is a candidate key.

## 1. `SpaceTypeBookingPolicy` (BCNF)

### Functional dependencies

```text
space_type → instant_booking_eligible, policy_note
```

- **1NF:** Yes. Each column contains one atomic value, with no repeating groups.

- **2NF:** Yes. The key is the single column `space_type`, so partial dependency is impossible.

- **3NF:** Yes. No non-key attribute determines another non-key attribute.

- **BCNF:** Yes. The only determinant, `space_type`, is a candidate key.

## 2. `CampusUser` (BCNF)

### Functional dependencies

```text
campus_user_id → full_name, email, phone, role, department, account_status
email → campus_user_id, full_name, phone, role, department, account_status
```

- **1NF:** Yes. User attributes are stored as atomic values.

- **2NF:** Yes. Both candidate keys, `campus_user_id` and `email`, contain one column, so partial dependency is impossible.

- **3NF:** Yes. No supported FD shows a non-key attribute determining another non-key attribute.

- **BCNF:** Yes. Both determinants are candidate keys; `email` is `NOT NULL UNIQUE`.

## 3. `CampusSpace` (BCNF)

### Functional dependencies

```text
campus_space_code → building, floor, room_number, space_name,
                    capacity, space_type, current_status, usage_policy

(building, floor, room_number) → campus_space_code, space_name,
                                  capacity, space_type, current_status,
                                  usage_policy
```

- **1NF:** Yes. Every column stores one value, with no repeating groups.

- **2NF:** Yes. No non-key attribute depends on only `building`, `floor`, or `room_number` from the composite candidate key.

- **3NF:** Yes. Booking-policy details are stored in `SpaceTypeBookingPolicy`, so they are not transitively repeated here.

- **BCNF:** Yes. Both determinants are candidate keys. The maintenance trigger partly maintains `current_status`, but cross-table derivation does not introduce an internal functional dependency with a non-key determinant.

## 4. `CampusFacility` (BCNF)

### Functional dependencies

```text
campus_facility_id → facility_type, description, campus_space_code, status
```

The only candidate key is `campus_facility_id`.

- **1NF:** Yes. Each facility attribute is atomic.

- **2NF:** Yes. The primary key contains one column, so partial dependency is impossible.

- **3NF:** Yes. No non-key determinant creates a transitive dependency.

- **BCNF:** Yes. The only supported determinant, `campus_facility_id`, is the primary key (the sole candidate key).

## 5. `Semester` (BCNF)

### Functional dependencies

```text
semester_id → academic_year, semester_no, semester_name, start_date, end_date

(academic_year, semester_no) → semester_id, semester_name,
                               start_date, end_date
```

- **1NF:** Yes. Every semester attribute contains one atomic value.

- **2NF:** Yes. No non-key attribute depends on only `academic_year` or only `semester_no`.

- **3NF:** Yes. No non-key attribute determines another non-key attribute.

- **BCNF:** Yes. `semester_id` and `(academic_year, semester_no)` are candidate keys, and every determinant is one of these keys.

## 6. `SpaceBooking` (BCNF)

### Functional dependencies

```text
space_booking_id → requester_id, campus_space_code,
                   requested_start_time, requested_end_time,
                   purpose_type, expected_participants, status,
                   is_instant_booking, submitted_at
```

- **1NF:** Yes. Each booking attribute stores one atomic value.

- **2NF:** Yes. The primary key contains one column, so partial dependency is impossible.

- **3NF:** Yes. No proven non-key attribute determines another non-key attribute.

- **BCNF:** Yes. The only supported determinant, `space_booking_id`, is a candidate key. `is_instant_booking` is stored booking state; the policy table does not introduce an internal functional dependency.

## 7. `BookingApproval` (BCNF)

### Functional dependencies

```text
booking_approval_id → space_booking_id, staff_id, decision,
                      decision_time, decision_note, rejection_reason

space_booking_id → booking_approval_id, staff_id, decision,
                   decision_time, decision_note, rejection_reason
```

- **1NF:** Yes. Every approval attribute is atomic.

- **2NF:** Yes. Both candidate keys contain one column, so partial dependency is impossible.

- **3NF:** Yes. No non-key attribute transitively determines another non-key attribute.

- **BCNF:** Yes. `booking_approval_id` is the primary key, and unique `space_booking_id` is another candidate key. Every determinant is a candidate key.

## 8. `SpaceUsageSession` (BCNF)

### Functional dependencies

```text
space_usage_session_id → space_booking_id, checked_in_by,
                         actual_start_time, initial_condition,
                         actual_end_time, final_condition, usage_notes

space_booking_id → space_usage_session_id, checked_in_by,
                   actual_start_time, initial_condition,
                   actual_end_time, final_condition, usage_notes
```

- **1NF:** Yes. Session attributes contain atomic values.

- **2NF:** Yes. Both candidate keys contain one column, so partial dependency is impossible.

- **3NF:** Yes. No non-key attribute determines another non-key attribute.

- **BCNF:** Yes. `space_usage_session_id` and unique `space_booking_id` are candidate keys. Every determinant is a candidate key.

## 9. `SpaceMaintenance` (BCNF)

### Functional dependencies

```text
space_maintenance_id → campus_space_code, reporter_id,
                       assigned_staff_id, impact_level,
                       problem_description, problem_type, start_time,
                       completion_time, status, result_note
```

- **1NF:** Yes. Each maintenance attribute stores one atomic value.

- **2NF:** Yes. The primary key contains one column, so partial dependency is impossible.

- **3NF:** Yes. No supported non-key determinant creates a transitive dependency. Status-dependent completion rules are constraints, not FDs.

- **BCNF:** Yes. `space_maintenance_id` is the only supported determinant and is a candidate key.

## 10. `FacilityMaintenance` (BCNF)

### Functional dependencies

```text
facility_maintenance_id → campus_facility_id, reporter_id,
                          assigned_staff_id, impact_level,
                          problem_description, start_time,
                          completion_time, status, notify_status,
                          result_note
```

- **1NF:** Yes. Each stored maintenance attribute is atomic.

- **2NF:** Yes. The primary key contains one column, so partial dependency is impossible.

- **3NF:** Yes. No proven non-key determinant creates a transitive dependency.

- **BCNF:** Yes. The only supported determinant, `facility_maintenance_id`, is a candidate key. `notify_status` is one scalar maintenance-level state and introduces no additional functional dependency.

## 11. Schema Check (DDL Cross-Validation against `10-schema-migration-G02.sql`)

This section re-validates every normal-form claim above against the **actual Phase 2 DDL** in `outputs/10-schema-migration-G02.sql`. The check confirms (a) that each of the ten tables exists with the column set assumed above, and (b) that the candidate keys claimed in Sections 1–10 are exactly the keys declared in the schema. The verdict is re-stated per table.

### 11.1 Declared candidate keys per table

The DDL (Step 10, Section 1) declares the following primary and unique keys; every one of them matches a candidate key asserted in the corresponding section above.

| Table | Declared key(s) in DDL | Section above |
|---|---|---|
| `SpaceTypeBookingPolicy` | `PRIMARY KEY (space_type)` | 1 |
| `CampusUser` | `PRIMARY KEY (campus_user_id)`, `UNIQUE (email)` | 2 |
| `CampusSpace` | `PRIMARY KEY (campus_space_code)`, `UNIQUE (building, floor, room_number)` | 3 |
| `CampusFacility` | `PRIMARY KEY (campus_facility_id)` | 4 |
| `Semester` | `PRIMARY KEY (semester_id)`, `UNIQUE (academic_year, semester_no)` | 5 |
| `SpaceBooking` | `PRIMARY KEY (space_booking_id)` | 6 |
| `BookingApproval` | `PRIMARY KEY (booking_approval_id)`, `UNIQUE (space_booking_id)` | 7 |
| `SpaceUsageSession` | `PRIMARY KEY (space_usage_session_id)`, `UNIQUE (space_booking_id)` | 8 |
| `SpaceMaintenance` | `PRIMARY KEY (space_maintenance_id)` | 9 |
| `FacilityMaintenance` | `PRIMARY KEY (facility_maintenance_id)` | 10 |

All keys are single-column or declared composite `UNIQUE` constraints in the DDL; no hidden unique indexes exist. No table declares a `UNIQUE` column that Section 11.1 treats as a non-key, and no section claims a candidate key that the DDL does not enforce. (Note: `CampusFacility.campus_space_code` is a nullable FK, not a key, so the only candidate key of `CampusFacility` is `campus_facility_id`, as stated in Section 4.)

### 11.2 Column-set gaps found during the cross-check

Two columns added during Phase 2 were absent from the original FD lists; both are single-column atomic attributes functionally determined by the primary key and do **not** change any normal-form verdict.

1. **`SpaceBooking.advisory_acknowledged`** (`BIT NOT NULL DEFAULT 1`, DDL line 180) is missing from the Section 6 FD list. It is determined by `space_booking_id` alone, so the Section 6 BCNF verdict is unchanged.
2. **`SpaceMaintenance.notify_status`** (`NVARCHAR(40) NOT NULL DEFAULT 'nothing_to_notify'`, DDL line 266) is missing from the Section 9 FD list. As with `FacilityMaintenance.notify_status` (Section 10), it is one scalar maintenance-level state determined by `space_maintenance_id` and introduces no additional functional dependency.

The remaining eight tables' FD lists match the DDL column sets exactly.

### 11.3 Reproducible T-SQL check

The following script (run against `SpaceBookingDB_Phase2` after Step 10) reproduces the Section 11.1 table, and the Section 11.2 column gap, directly from the SQL Server catalog:

```sql
USE SpaceBookingDB_Phase2;
GO

-- Candidate keys (PK and UNIQUE) per table
SELECT t.name               AS table_name,
       i.name               AS index_name,
       i.is_primary_key     AS is_pk,
       i.is_unique          AS is_unique,
       STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS key_columns
FROM sys.indexes i
JOIN sys.tables t  ON i.object_id = t.object_id
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.is_unique = 1
  AND t.name IN (
      'SpaceTypeBookingPolicy', 'CampusUser', 'CampusSpace',
      'CampusFacility', 'Semester', 'SpaceBooking', 'BookingApproval',
      'SpaceUsageSession', 'SpaceMaintenance', 'FacilityMaintenance')
GROUP BY t.name, i.name, i.is_primary_key, i.is_unique
ORDER BY t.name, i.is_primary_key DESC, i.name;
GO

-- Phase 2 columns that must appear in the FD lists of Section 6 / Section 9
SELECT t.name AS table_name, c.name AS column_name
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
WHERE (t.name = 'SpaceBooking'      AND c.name = 'advisory_acknowledged')
   OR (t.name = 'SpaceMaintenance'  AND c.name = 'notify_status');
GO
```

### 11.4 Re-stated overall verdict

The cross-check confirms the original verdict without modification: **all ten tables satisfy BCNF** under the functional dependencies supported by the actual Phase 2 schema. The two Phase 2 additions (`SpaceBooking.advisory_acknowledged`, `SpaceMaintenance.notify_status`) are key-determined atomic attributes and do not introduce any non-trivial functional dependency with a non-key determinant.
