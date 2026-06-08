# Business Requirement Analysis — CS486 Space Booking System

---

## 1. Business Purpose

**Core problem:** The School of Computer Science manages shared physical spaces manually via email, phone, spreadsheets, and shared calendars, which has become difficult to manage as the number of classes, projects, workshops, seminars, and academic events increases.

**Primary objectives:**
- Automate space booking requests, approvals, check-ins, and check-outs.
- Prevent overlapping bookings and prevent booking of unavailable spaces.
- Track maintenance activities and block bookings on spaces under maintenance.
- Preserve historical records of all bookings and maintenance for reporting.

**Scope:**
- **In scope:** User management, space catalog, facility inventory, booking submission & approval workflow, booking check-in/check-out, maintenance management, booking and maintenance history.
- **Out of scope:** Financial transactions, payroll, HR management, curriculum scheduling, student enrollment.

---

## 2. Actors

| ID | Role | Responsibilities | Interactions |
|----|------|-----------------|--------------|
| A-01 | Student | Attends lectures, uses workspaces, participates in student activities | Submits booking requests; views own bookings |
| A-02 | Lecturer | Teaches classes, conducts examinations, supervises seminars | Submits booking requests; views own bookings |
| A-03 | Teaching Assistant | Assists in teaching, supervises labs and workshops | Submits booking requests; views own bookings |
| A-04 | Facility Staff | Manages daily facility operations; checks in/out bookings; handles maintenance reporting | Approves/rejects bookings; checks in and completes bookings; reports maintenance; views all bookings and maintenance records |
| A-05 | Department Administrator | Oversees department space allocation | Views bookings and reports; may assist with approvals |
| A-06 | Facility Manager | Oversees all facility operations, resolves escalations | Approves/rejects bookings; assigns and manages maintenance; views all system data and reports |

---

## 3. Business Data Entities & Attributes

| Entity | Core Identity | Key Attributes | Enums (Predefined Options) |
|--------|---------------|----------------|---------------------------|
| User | User ID | Full Name, Email, Phone Number, Role, Department, Account Status | Role: student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager. Account Status: active, inactive, suspended |
| Space | Space Code | Space Name, Space Type, Building, Floor, Room Number, Capacity, Current Status, Usage Policy | Space Type: auditorium, classroom, computer_laboratory, project_laboratory, meeting_room, student_workspace. Current Status: available, in_use, under_maintenance, temporarily_closed, retired |
| Facility | Facility ID | Facility Name, Description | Facility Name: projector, whiteboard, microphone, computer, livestreaming_equipment, air_conditioner |
| SpaceFacility | (Space Code + Facility ID) | Quantity | — |
| BookingRequest | Booking ID | Space (FK), Requester (FK), Requested Start Time, Requested End Time, Purpose, Expected Participants, Booking Status, Approver (FK), Decision Time, Decision Note, Rejection Reason, Actual Start Time, Checked In By (FK), Initial Condition, Actual End Time, Completed By (FK), Final Condition, Usage Notes | Purpose: lecture, examination, seminar, workshop, meeting, student_activity, administrative_event. Booking Status: pending, approved, rejected, cancelled, checked_in, completed, no-show |
| MaintenanceRecord | Maintenance ID | Space (FK), Reporter (FK), Assigned Staff (FK), Problem Description, Start Time, Completion Time, Status, Result Note | Problem Type: broken_projector, air_conditioning_failure, damaged_furniture, cleaning_issue, network_problem. Status: reported, in_progress, completed, cancelled |

---

## 4. Relationships & Cardinalities

| Left Entity | Relationship | Right Entity | Cardinality | Business Meaning |
|-------------|--------------|--------------|-------------|------------------|
| User | submits | BookingRequest | 1 → N | A user can submit many booking requests. |
| Space | is booked by | BookingRequest | 1 → N | A space can be the subject of many booking requests. |
| User (approver) | approves | BookingRequest | 1 → N | A facility staff member or manager can approve/reject many booking requests. |
| User (check-in) | checks in | BookingRequest | 1 → N | A facility staff member can check in many bookings. |
| User (check-out) | completes | BookingRequest | 1 → N | A facility staff member can complete many bookings. |
| Space | has | Facility | M → N | A space can have many facilities; a facility can be present in many spaces. |
| User (reporter) | reports | MaintenanceRecord | 1 → N | A user can report many maintenance issues. |
| User (assigned) | is assigned to | MaintenanceRecord | 1 → N | A facility staff member or manager can be assigned to many maintenance records. |
| Space | undergoes | MaintenanceRecord | 1 → N | A space can have many maintenance records. |

---

## 5. Business Rules

| ID | Rule |
|----|------|
| BR-01 | User roles are limited to: student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager. |
| BR-02 | Account statuses are: active, inactive, suspended. |
| BR-03 | Each user must have a unique email address. |
| BR-04 | Space types are: auditorium, classroom, computer_laboratory, project_laboratory, meeting_room, student_workspace. |
| BR-05 | Space statuses are: available, in_use, under_maintenance, temporarily_closed, retired. |
| BR-06 | A space that is under maintenance, temporarily closed, or retired cannot be booked. Its current_status prevents new approved bookings. |
| BR-07 | Booking purposes are: lecture, examination, seminar, workshop, meeting, student_activity, administrative_event. |
| BR-08 | Booking statuses and lifecycle: pending → approved | rejected | cancelled; approved → checked_in | cancelled; checked_in → completed | no-show; a booking is rejected when an approver denies it; a booking is cancelled when the requester or staff cancels it; a booking becomes no-show when the requester never checks in. |
| BR-09 | All booking requests require approval from a facility staff member or facility manager before they can be used. |
| BR-10 | The same space cannot have two approved bookings with overlapping time periods. |
| BR-11 | Expected number of participants must not exceed the space's capacity. The system enforces this as a hard rule at submission time. |
| BR-12 | Maximum booking duration is 4 hours per single booking request. |
| BR-13 | Bookings can be made up to 6 months in advance of the requested start time. |
| BR-14 | When a booking is approved or rejected, the system records the approver's identity, the decision time, and a decision note. If rejected, a rejection reason is required. |
| BR-15 | Only facility staff can check in a booking. The check-in records the actual start time, the staff member who performed check-in, and the initial condition of the space. |
| BR-16 | Only facility staff can complete (check out) a booking. The completion records the actual end time, the staff member, the final condition of the space, and any usage notes. |
| BR-17 | A booking that reaches its requested end time without being checked in is marked as no-show. |
| BR-18 | Facility names are predefined: projector, whiteboard, microphone, computer, livestreaming_equipment, air_conditioner. |
| BR-19 | Maintenance problem types include: broken_projector, air_conditioning_failure, damaged_furniture, cleaning_issue, network_problem. |
| BR-20 | Maintenance statuses and lifecycle: reported → in_progress → completed | cancelled; reported → cancelled (allowed if issue is no longer relevant); in_progress → completed. |
| BR-21 | A space with an active maintenance record (status reported or in_progress) must have its current_status set to under_maintenance and cannot be booked. |
| BR-22 | The system must maintain historical records of all bookings and maintenance activities indefinitely for reporting purposes. |
| BR-23 | Staff should be able to view booking history, upcoming bookings, spaces under maintenance, and no-show bookings. |
