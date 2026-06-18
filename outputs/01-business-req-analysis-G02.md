# Business Requirement Analysis — School Shared Space Booking System

---

## 1. Business Purpose

**Core problem:** The School of Computer Science manages shared physical spaces (auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, and student workspaces) using a manual process of emails, phone calls, spreadsheets, and shared calendars. As the volume of classes, student projects, workshops, seminars, and academic events grows, this manual approach causes scheduling conflicts, inability to prevent booking of unavailable spaces, lack of centralized historical records, and difficulty managing maintenance and incident reporting.

**Primary objectives:**
- Automate space booking requests, approvals, check-in, and check-out workflows.
- Prevent overlapping bookings for the same space through automated conflict detection.
- Prevent booking of spaces that are under maintenance, closed, or retired.
- Track maintenance activities and link them to specific spaces and reporters.
- Preserve full historical records of bookings, usage sessions, and maintenance for reporting and auditing.

**Scope:**
- **In scope:** User management, space and facility catalog management, booking request submission & approval workflow, check-in/check-out process, maintenance record management, booking conflict prevention, booking and maintenance history viewing.
- **Out of scope:** Financial transactions (payments/ billing for space usage), integration with university-wide calendar systems, automated notifications (email/SMS), real-time space availability dashboards, room scheduling optimization algorithms.

---

## 2. Actors

| ID | Role | Responsibilities | Interactions |
|----|------|-----------------|--------------|
| A-01 | Student | May book spaces (any type) for student projects, activities, or events. | Submits booking requests; views own booking history and upcoming bookings. |
| A-02 | Lecturer | May book spaces for lectures, seminars, workshops, examinations, research. | Submits booking requests; views own bookings. |
| A-03 | Teaching Assistant | May book spaces for tutorials, lab sessions, student support. | Submits booking requests; views own bookings. |
| A-04 | Facility Staff | Checks bookings, processes check-in/check-out, reports maintenance issues, manages day-to-day operations. | Approves/rejects bookings; performs check-in and check-out; views upcoming bookings and spaces under maintenance; reports maintenance problems. |
| A-05 | Facility Manager | Oversees facility operations, manages space catalog, handles escalated decisions. | Manages space catalog (add/update spaces and facilities); views all bookings and maintenance records; performs approvals. |
| A-06 | Department Administrator | May book spaces for administrative events and departmental activities. | Submits booking requests; views bookings. |

---

## 3. Business Data Entities & Attributes

| Entity | Core Identity | Key Attributes | Enums (Predefined Options) |
|--------|---------------|----------------|---------------------------|
| User | User ID | Full Name, Email, Phone Number, Role, Department, Account Status | Role: student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager. Account Status: active, inactive, suspended |
| Space | Space Code | Space Name, Space Type, Building, Floor, Room Number, Capacity, Current Status, Usage Policy | Space Type: auditorium, classroom, computer_laboratory, project_laboratory, meeting_room, student_workspace. Status: available, in_use, under_maintenance, temporarily_closed, retired |
| Facility | Facility ID | Facility Name, Description | Facily Type: projector, whiteboard, microphone, computer, livestreaming equipment, air_conditioner |
| SpaceFacility | (Space Code + Facility ID) | Quantity | — |
| BookingRequest | Booking ID | Space (FK), Requester (FK), Requested Start Time, Requested End Time, Purpose, Expected Participants, Booking Status, Approver (FK), Decision Time, Decision Note, Rejection Reason, Actual Start Time, Checked In By (FK), Initial Condition, Actual End Time, Completed By (FK), Final Condition, Usage Notes | Purpose: lecture, examination, seminar, workshop, meeting, student_activity, administrative_event. Booking Status: pending, approved, rejected, cancelled, checked_in, completed, no_show |
| MaintenanceRecord | Maintenance ID | Space (FK), Reporter (FK), Assigned Staff (FK), Problem Description, Problem Type, Start Time, Completion Time, Status, Result Note | Status: reported, in_progress, completed, cancelled. Problem type: broken projectors, air-conditioning failure, damaged furniture, cleaning issues, or network problems |

---

## 4. Relationships & Cardinalities

A user submits many booking requests.
A booking request is made by one user.
A space receives many booking requests.
A booking request is for exactly one space.
A space has many facilities (via SpaceFacility).
A facility is present in many spaces (via SpaceFacility).
A booking request may be reviewed by many approval decisions (at most one approval decision recorded per booking).
An approval decision is made by one facility staff or manager.
A booking request may be checked in (0 or 1 check-in record).
A check-in is performed by one facility staff member.
A booking request may be checked out (0 or 1 check-out record, requires check-in to exist).
A check-out is performed by one facility staff member.
A space has many maintenance records.
A maintenance record is for exactly one space.
A user reports many maintenance records.
A user is assigned to many maintenance records (as assigned staff).

---

## 5. Business Rules

| ID | Rule |
|----|------|
| BR-01 | User roles are limited to: student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager. |
| BR-02 | Account statuses: active, inactive, suspended. |
| BR-03 | Space types: auditorium, classroom, computer_laboratory, project_laboratory, meeting_room, student_workspace. |
| BR-04 | Space statuses: available, in_use, under_maintenance, temporarily_closed, retired. |
| BR-05 | Booking types: lecture, examination, seminar, workshop, meeting, student_activity, administrative_event. |
| BR-06 | Booking request statuses: pending, approved, rejected, cancelled, checked_in, completed, no_show. |
| BR-07 | All booking requests require approval by a facility staff member or facility manager before the space can be used. |
| BR-08 | A booking request in pending status can be approved or rejected by a facility staff member or manager. |
| BR-09 | Allowed booking status transitions: pending → approved | rejected | cancelled; approved → checked_in | cancelled; checked_in → completed | no_show; pending → cancelled; approved → cancelled. |
| BR-10 | The same space cannot have two approved bookings with overlapping time periods (conflict detection: approved bookings for the same space must not have overlapping [start_time, end_time] intervals). |
| BR-11 | A space that is under maintenance, temporarily closed, or retired cannot be booked. |
| BR-12 | Any user role may book any space type (no role-based eligibility restrictions). |
| BR-13 | Maintenance record statuses: reported, in_progress, completed, cancelled. |
| BR-14 | When a space's status is set to under_maintenance via a maintenance record, the system must prevent new approved bookings for that space until the maintenance is completed. |
| BR-15 | Check-in records the actual start time, the identity of the staff member performing the check-in, and the initial condition of the space. |
| BR-16 | Check-out records the actual end time, final condition of the space, and usage notes. It is performed by facility staff. |
| BR-17 | If the requester does not check in, the booking status moves to no_show. (Transition from approved → no_show.) |
| BR-18 | The system must maintain full historical records of all bookings, approval decisions, check-in/check-out records, and maintenance activities indefinitely for reporting. |
| BR-19 | A rejected booking must store the rejection reason. |
| BR-20 | The facility manager can manage the space catalog (add, update, or retire spaces and their facilities). |
| BR-21 | Each space may have multiple facilities; each facility type may be installed in multiple spaces (M:N relationship via SpaceFacility with quantity). |
