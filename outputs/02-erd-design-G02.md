# Conceptual ERD Design — Crow's Foot Notation

**Group:** G02

**Date:** 2026-06-27

---

## 1. Mermaid ER Diagram

```mermaid
erDiagram
    CampusUser {
        int campus_user_id PK
        nvarchar full_name
        nvarchar email UK
        nvarchar phone
        nvarchar role "Values: student; lecturer; teaching_assistant; facility_staff; department_admin; facility_manager"
        nvarchar department
        nvarchar account_status "Values: active; inactive; suspended"
    }

    CampusSpace {
        nvarchar campus_space_code PK
        nvarchar space_name
        nvarchar space_type "Values: auditorium; classroom; computer_lab; meeting_room"
        nvarchar building
        int floor
        nvarchar room_number
        int capacity
        nvarchar current_status "Values: available; in_use; under_maintenance; temporarily_closed; retired"
        nvarchar usage_policy
    }

    CampusFacility {
        int campus_facility_id PK
        nvarchar facility_type UK
        nvarchar description
        int campus_space_code FK
        nvarchar status "Values: available, in_use, under_maintenance"
    }

    SpaceBooking {
        int space_booking_id PK
        int requester_id FK
        nvarchar campus_space_code FK
        datetime requested_start_time
        datetime requested_end_time
        nvarchar purpose_type "Values: lecture; examination; seminar; workshop; meeting; student_activity; administrative_event"
        int expected_participants
        nvarchar status "Values: pending; approved; rejected; cancelled; checked_in; completed; no-show"
        datetime submitted_at
    }

    BookingApproval {
        int booking_approval_id PK
        int space_booking_id FK
        int staff_id FK
        nvarchar decision "Values: approved; rejected"
        datetime decision_time
        nvarchar decision_note
        nvarchar rejection_reason
    }

    SpaceUsageSession {
        int space_usage_session_id PK
        int space_booking_id FK
        int checked_in_by FK
        datetime actual_start_time
        nvarchar initial_condition
        datetime actual_end_time
        nvarchar final_condition
        nvarchar usage_notes
    }

    SpaceMaintenance {
        int space_maintenance_id PK
        nvarchar campus_space_code FK
        int reporter_id FK
        int assigned_staff_id FK
        nvarchar problem_description
        nvarchar problem_type "Values: broken_projector; ac_failure; damaged_furniture; cleaning; network; other"
        datetime start_time
        datetime completion_time
        nvarchar status "Values: reported; in_progress; completed; cancelled"
        nvarchar result_note
    }

    %% Relationships

    %% R1: CampusUser submits SpaceBooking (1:N)
    CampusUser ||--o{ SpaceBooking : "submits"

    %% R2: CampusSpace is booked in SpaceBooking (1:N)
    CampusSpace ||--o{ SpaceBooking : "is booked in"

    %% R3: CampusSpace has CampusFacilities (1:N)
    CampusSpace ||--o{ CampusFacility : "contains"

    %% R4: SpaceBooking has BookingApproval (1:0..1)
    SpaceBooking ||--o| BookingApproval : "has"

    %% R5: CampusUser (staff) approves BookingApproval (1:N)
    CampusUser ||--o{ BookingApproval : "approves"

    %% R6: SpaceBooking results in SpaceUsageSession (1:0..1)
    SpaceBooking ||--o| SpaceUsageSession : "results in"

    %% R7: CampusUser (staff) checks in SpaceUsageSession (1:N)
    CampusUser ||--o{ SpaceUsageSession : "checks in"

    %% R8: CampusSpace undergoes SpaceMaintenance (1:N)
    CampusSpace ||--o{ SpaceMaintenance : "undergoes"

    %% R9: CampusUser reports SpaceMaintenance (1:N)
    CampusUser ||--o{ SpaceMaintenance : "reports"

    %% R10: CampusUser (staff) assigned to SpaceMaintenance (1:N)
    CampusUser ||--o{ SpaceMaintenance : "is assigned"
```

---

## 2. Entity Descriptions

### 2.1. CampusUser
Represents any person who interacts with the system using a university account. Has a role that determines permissions (student, lecturer, TA, facility staff, department admin, facility manager).

### 2.2. CampusSpace
A bookable physical room or area on campus managed by the School of Computer Science.

### 2.3. CampusFacility
A piece of equipment or amenity that may be installed in a campus space (e.g., projector, whiteboard, air conditioner).

### 2.4. SpaceBooking
A booking request submitted by a campus user to reserve a specific campus space for a specific time period and purpose.

### 2.5. BookingApproval
The decision record for a space booking. Linked to exactly one booking. Captures who decided, when, and any notes.

### 2.6. SpaceUsageSession
The actual usage record when a booking is checked in and later checked out. Tracks real start/end times and space condition.

### 2.7. SpaceMaintenance
A log of a maintenance issue reported for a campus space. Tracks problem description, assignment, status, and resolution.

---

## 3. Relationship Summary

| ID | Entity A | Entity B | Cardinality | Participation |
|---|---|---|---|---|
| R1 | CampusUser | SpaceBooking | 1:N | CampusUser: optional, SpaceBooking: mandatory |
| R2 | CampusSpace | SpaceBooking | 1:N | CampusSpace: optional, SpaceBooking: mandatory |
| R3 | CampusSpace | CampusFacility | 1:N | Both optional |
| R4 | SpaceBooking | BookingApproval | 1:0..1 | SpaceBooking: optional, BookingApproval: mandatory |
| R5 | CampusUser (staff) | BookingApproval | 1:N | CampusUser: optional, BookingApproval: mandatory |
| R6 | SpaceBooking | SpaceUsageSession | 1:0..1 | SpaceBooking: optional, SpaceUsageSession: mandatory |
| R7 | CampusUser (staff) | SpaceUsageSession | 1:N | CampusUser: optional, SpaceUsageSession: mandatory |
| R8 | CampusSpace | SpaceMaintenance | 1:N | CampusSpace: optional, SpaceMaintenance: mandatory |
| R9 | CampusUser (reporter) | SpaceMaintenance | 1:N | CampusUser: optional, SpaceMaintenance: mandatory |
| R10 | CampusUser (assignee) | SpaceMaintenance | 1:N | CampusUser: optional, SpaceMaintenance: mandatory |

---

## 4. Traceability to Business Requirement Analysis

| Entity | Derived From (Section 3 of Business Requirement Analysis) |
|---|---|
| CampusUser | E1 |
| CampusSpace | E2 |
| CampusFacility | E3 |
| SpaceBooking | E4 |
| BookingApproval | E5 |
| SpaceUsageSession | E6 |
| SpaceMaintenance | E7 |

All relationships (R1–R10) map directly to the relationship analysis in Section 5 of the Business Requirement Analysis.
