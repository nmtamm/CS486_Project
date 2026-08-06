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
facility_type → campus_facility_id, description, campus_space_code, status
```

The schema declares `facility_type` unique, making it another candidate key.

- **1NF:** Yes. Each facility attribute is atomic.

- **2NF:** Yes. The primary key contains one column, so partial dependency is impossible.

- **3NF:** Yes. No proven non-key determinant creates a transitive dependency.

- **BCNF:** Yes. `campus_facility_id` and unique `facility_type` are candidate keys. Every determinant is a candidate key.

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
