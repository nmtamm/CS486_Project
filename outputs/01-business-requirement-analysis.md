# Business Requirement Analysis — School Space Booking System

---

## 1. Business Purpose

**Core problem:** The School of Computer Science manages shared physical spaces (auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, student workspaces) through a manual process using email, phone, spreadsheets, and shared calendars. As demand grows, this manual approach has become unmanageable, leading to double-booking risks, inability to prevent use of unavailable spaces, and poor historical visibility.

**Primary objectives:**
- Automate submission, approval, and tracking of space booking requests.
- Prevent overlapping bookings and prevent booking of unavailable spaces.
- Provide structured check-in and session-completion workflows.
- Track maintenance issues and link them to space availability.
- Maintain searchable historical records of all bookings and maintenance activities.

**Scope:**
- **In scope:** User management, space catalog with facilities, booking submission & approval, check-in & session completion, maintenance management, booking history & reporting.
- **Out of scope:** Financial transactions (payments, deposits, fines), integration with university-wide calendar systems, automated email/SMS notifications, real-time occupancy sensors.

---

## 2. Actors

| ID | Role | Responsibilities | Interactions |
|----|------|-----------------|--------------|
| A-01 | Student | Books spaces for student activities, workshops, and project work; attends scheduled sessions. | Submits booking requests; views own booking history; cancels own pending/approved bookings. |
| A-02 | Lecturer | Books spaces for lectures, seminars, and examinations; conducts teaching sessions. | Submits booking requests; views own bookings and space availability. |
| A-03 | Teaching Assistant | May book spaces on behalf of lecturers for tutorials or lab sessions. | Submits booking requests on behalf of academic staff; views assigned bookings. |
| A-04 | Facility Staff | Manages day-to-day operations: reviews and approves/rejects bookings, performs check-in and session completion, records maintenance issues. | Reviews pending bookings; approves/rejects requests; checks in and completes bookings; reports and resolves maintenance issues. |
| A-05 | Facility Manager | Oversees facility operations; manages space catalog, usage policies, and maintenance; views reports and historical data. | Manages space records (add, update, retire spaces); assigns maintenance staff; views utilization reports and booking history. |
| A-06 | Department Administrator | Oversees administrative aspects of space usage across the department. | Views booking and maintenance reports; may manage user account statuses. |

---

## 3. Business Data Entities & Attributes

| Entity | Core Identity | Key Attributes | Enums (Predefined Options) |
|--------|---------------|----------------|---------------------------|
| User | User ID (university account) | Full Name, Email, Phone, Role, Department, Account Status | Role: `student`, `lecturer`, `teaching_assistant`, `facility_staff`, `department_administrator`, `facility_manager` — Account Status: `active`, `inactive`, `suspended` |
| Space | Space Code | Name, Type, Building, Floor, Room Number, Capacity, Status, Usage Policy | Type: `auditorium`, `classroom`, `computer_laboratory`, `project_laboratory`, `meeting_room`, `student_workspace` — Status: `available`, `in_use`, `under_maintenance`, `temporarily_closed`, `retired` |
| Facility | Facility ID | Name, Quantity | Name (open list, suggested): `projector`, `whiteboard`, `microphone`, `computer`, `livestreaming_equipment`, `air_conditioner` |
| Booking | Booking ID | Requester (FK→User), Space (FK→Space), Requested Start Time, Requested End Time, Purpose, Expected Participants, Status, Approver (FK→User), Decision Time, Decision Note, Rejection Reason, Check-in Staff (FK→User), Actual Start Time, Initial Condition, Completion Staff (FK→User), Actual End Time, Final Condition, Usage Notes | Purpose: `lecture`, `examination`, `seminar`, `workshop`, `meeting`, `student_activity`, `administrative_event` — Status: `pending`, `approved`, `rejected`, `cancelled`, `checked_in`, `completed`, `no_show` |
| Maintenance Record | Record ID | Space (FK→Space), Reporter (FK→User), Assigned Staff (FK→User), Problem Description, Problem Type, Start Time, Completion Time, Status, Result Note | Problem Type: `broken_projector`, `air_conditioning_failure`, `damaged_furniture`, `cleaning_issue`, `network_problem` — Status: `reported`, `in_progress`, `completed`, `cancelled` |

---

## 4. Relationships & Cardinalities

A user submits many bookings.
A user (facility staff) approves many bookings.
A user (facility staff) checks in many bookings.
A user (facility staff) completes many bookings.
Many bookings reference one space.
A space has many facilities.
A space is the subject of many maintenance records.
A user reports many maintenance records.
A user (facility staff) is assigned to many maintenance records.

---

## 5. Business Rules

| ID | Rule |
|----|------|
| BR-01 | User roles are limited to: `student`, `lecturer`, `teaching_assistant`, `facility_staff`, `department_administrator`, `facility_manager`. |
| BR-02 | User account statuses: `active`, `inactive`, `suspended`. |
| BR-03 | Space types: `auditorium`, `classroom`, `computer_laboratory`, `project_laboratory`, `meeting_room`, `student_workspace`. |
| BR-04 | Space statuses: `available`, `in_use`, `under_maintenance`, `temporarily_closed`, `retired`. |
| BR-05 | Booking purposes: `lecture`, `examination`, `seminar`, `workshop`, `meeting`, `student_activity`, `administrative_event`. |
| BR-06 | Booking statuses: `pending`, `approved`, `rejected`, `cancelled`, `checked_in`, `completed`, `no_show`. |
| BR-07 | Booking status transitions allowed: `pending` → `approved` | `rejected` | `cancelled`; `approved` → `checked_in` | `cancelled` | `no_show`; `checked_in` → `completed`. |
| BR-08 | The same space cannot have two approved bookings with overlapping time periods. |
| BR-09 | A space whose status is `under_maintenance`, `temporarily_closed`, or `retired` cannot be booked. |
| BR-10 | Every booking request requires approval by a facility staff member or facility manager. |
| BR-11 | When a booking is approved or rejected, the system records the approving staff member (FK to User), decision time, and decision note. If rejected, the rejection reason must be stored. |
| BR-12 | The system must reject or warn when the expected number of participants exceeds the space's capacity. |
| BR-13 | Facilities tracked per space include (but are not limited to): `projector`, `whiteboard`, `microphone`, `computer`, `livestreaming_equipment`, `air_conditioner`. The system records the quantity of each facility type present in a space. |
| BR-14 | Maintenance problem types: `broken_projector`, `air_conditioning_failure`, `damaged_furniture`, `cleaning_issue`, `network_problem`. |
| BR-15 | Maintenance record statuses: `reported`, `in_progress`, `completed`, `cancelled`. |
| BR-16 | Maintenance status transitions allowed: `reported` → `in_progress`; `in_progress` → `completed` | `cancelled`. |
| BR-17 | When a booking is checked in, the system records the actual start time, the staff member who performed check-in, and the initial condition of the space. |
| BR-18 | When a booking is completed, the system records the actual end time, the final condition of the space, and any usage notes. |
| BR-19 | A space under maintenance cannot be booked (see BR-09). |
| BR-20 | The system must maintain historical records of all bookings and maintenance activities indefinitely for reporting and audit purposes. |
| BR-21 | Staff must be able to view booking history, upcoming bookings, spaces under maintenance, and no-show bookings. |
