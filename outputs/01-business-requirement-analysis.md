# Business Requirement Analysis

## 1. Business Purpose

**Core Problem:** The School of Computer Science currently manages shared physical space bookings (auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, student workspaces) through a manual process involving emails, phone calls, spreadsheets, and shared calendars. As the volume of classes, student projects, workshops, seminars, and academic events grows, this manual approach has become difficult to manage.

**Primary Objectives:**
- Automate the booking and approval process for shared campus spaces.
- Prevent overlapping (conflicting) bookings for the same space.
- Prevent booking of unavailable spaces (under maintenance, closed, or retired).
- Track booking lifecycle from request through check-in and completion.
- Manage maintenance records and associate them with spaces.
- Maintain historical records of bookings and maintenance activities.

**Scope:** The system covers space booking, booking approval workflow, usage session check-in/check-out, maintenance management, and facility utilization tracking.

## 2. Actors

| ID | Role | Responsibilities | Interactions |
|----|------|-----------------|--------------|
| A-01 | Student | Requests space for student activities, projects, or events | Submits booking requests; views own booking history |
| A-02 | Lecturer | Requests space for lectures, examinations, seminars | Submits booking requests; views own booking history |
| A-03 | Teaching Assistant | Requests space for teaching-related activities | Submits booking requests; views own booking history |
| A-04 | Facility Staff | Manages daily facility operations; checks availability; handles check-in and check-out | Approves/rejects booking requests; checks in and completes bookings; records maintenance issues; views upcoming bookings and history |
| A-05 | Department Administrator | Provides administrative oversight of space usage | Views bookings, reports, and utilization data |
| A-06 | Facility Manager | Oversees facility strategy; manages space configurations and policies | Approves/rejects booking requests; manages space records; views utilization reports and maintenance history |

## 3. Business Data Entities & Attributes

| Entity | Core Identity | Key Attributes | Enums (Predefined Options) |
|--------|---------------|----------------|---------------------------|
| User | User ID | Full name, email, phone, role, department, account status | Role: student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager. Account Status: active, inactive, suspended |
| Space | Space Code | Name, type, building, floor, room number, capacity, current status, usage policy | Type: auditorium, classroom, computer_laboratory, project_laboratory, meeting_room, student_workspace. Status: available, in_use, under_maintenance, temporarily_closed, retired. Usage Policy: open_to_all, staff_only, restricted |
| Facility | Facility ID | Name, description, space (FK to Space) | Name: projector, whiteboard, microphone, computer, livestreaming_equipment, air_conditioner |
| Booking Request | Booking ID | Requester (FK to User), space (FK to Space), requested start time, requested end time, purpose, expected number of participants, status | Purpose: lecture, examination, seminar, workshop, meeting, student_activity, administrative_event. Status: pending, approved, rejected, cancelled, checked_in, completed, no_show |
| Booking Decision | Decision ID | Booking (FK to Booking Request), approver (FK to User), decision time, decision, decision note, rejection reason | Decision: approved, rejected |
| Check-in Record | Check-in ID | Booking (FK to Booking Request), actual start time, checked-in by (FK to User), initial condition of space | — |
| Completion Record | Completion ID | Booking (FK to Booking Request), actual end time, final condition of space, usage notes | — |
| Maintenance Record | Maintenance ID | Space (FK to Space), reporter (FK to User), assigned staff (FK to User), problem type, problem description, start time, completion time, status, result note | Problem Type: broken_projector, air_conditioning_failure, damaged_furniture, cleaning_issue, network_problem. Status: open, in_progress, resolved, closed |

## 4. Business Rules

| ID | Rule |
|----|------|
| BR-01 | Each user is assigned exactly one role. Valid roles: student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager. |
| BR-02 | A user must have an active account to submit booking requests or access the system. Valid account statuses: active, inactive, suspended. |
| BR-03 | A space has one of the following statuses: available, in_use, under_maintenance, temporarily_closed, retired. |
| BR-04 | A space that is under_maintenance, temporarily_closed, or retired cannot be booked. |
| BR-05 | Each space has a usage policy category: open_to_all, staff_only, restricted. |
| BR-06 | A booking request must specify: space, requested start time, requested end time, purpose of use, and expected number of participants. |
| BR-07 | The purpose of a booking must be one of: lecture, examination, seminar, workshop, meeting, student_activity, administrative_event. |
| BR-08 | A booking request transitions through the following statuses: pending → approved → checked_in → completed. Branches: pending → rejected, pending → cancelled, approved → cancelled, approved → no_show. |
| BR-09 | The same space cannot have two approved bookings with overlapping time periods. |
| BR-10 | Every booking request requires explicit approval from a facility staff member or facility manager. |
| BR-11 | Only facility staff or facility manager may approve or reject a booking request. |
| BR-12 | When a booking is approved or rejected, the system must record: the staff member who made the decision, the decision time, a decision note, and (if rejected) a rejection reason. |
| BR-13 | A requester may cancel their own booking when its status is pending or approved (before check-in). Facility staff or manager may cancel any booking in pending or approved status. |
| BR-14 | When checking in a booking, the system must record: the actual start time, the person who performed the check-in, and the initial condition of the space. |
| BR-15 | When completing a booking, the system must record: the actual end time, the final condition of the space, and any usage notes. |
| BR-16 | Only facility staff may perform check-in and check-out actions. |
| BR-17 | If a booking is not checked in by the scheduled start time, it may be marked as no_show by facility staff. |
| BR-18 | A maintenance record must capture: the related space, reporter, assigned staff member, problem type, problem description, start time, completion time, status, and result note. |
| BR-19 | Maintenance problem types include: broken_projector, air_conditioning_failure, damaged_furniture, cleaning_issue, network_problem. |
| BR-20 | A maintenance record transitions through statuses: open → in_progress → resolved → closed. |
| BR-21 | While a space has a maintenance record with status open or in_progress, its own status is set to under_maintenance and it cannot be booked. |
| BR-22 | The system must maintain historical records of all past bookings, check-ins, completions, and maintenance activities. |
