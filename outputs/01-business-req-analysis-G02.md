# Business Requirement Analysis

**Group:** G02

**Date:** 2026-06-27

---

## 1. Business Purpose

The School of Computer Science manages shared physical spaces (auditoriums, classrooms, computer laboratories, meeting rooms). The manual booking process (email, phone, spreadsheets) has become unsustainable due to increasing volume. The system aims to automate space booking, approval, usage tracking, maintenance management, incident reporting, and facility utilization tracking. The core goals are:

- Prevent overlapping bookings.
- Prevent booking of unavailable spaces (under maintenance, closed, retired).
- Preserve historical records of bookings and maintenance.
- Support fair and transparent space allocation.

---

## 2. Actors and Roles

| Actor | Description |
|---|---|
| Student | Can submit booking requests for student activities. |
| Lecturer | Can submit booking requests for lectures, seminars, etc. |
| Teaching Assistant | Can submit booking requests. |
| Facility Staff | Approves/rejects bookings, checks in/out sessions, manages maintenance. |
| Department Administrator | Likely has oversight/reporting capabilities. |
| Facility Manager | Full oversight; may approve bookings and manage maintenance. |

---

## 3. Entity Identification

| # | Entity | Description | Source (Req §) |
|---|---|---|---|
| E1 | CampusUser | University account holder who interacts with the system. | Req: user info, roles |
| E2 | CampusSpace | A bookable physical room or area. | Req: space info, types |
| E3 | CampusFacility | Equipment or amenity available within a space. | Req: facilities list |
| E4 | SpaceBooking | A request to use a space for a specific time period. | Req: booking submission |
| E5 | BookingApproval | Approval or rejection decision for a booking request. | Req: approval process |
| E6 | SpaceUsageSession | Check-in/check-out record of an actual booking usage. | Req: session tracking |
| E7 | SpaceMaintenance | A repair or maintenance task for a space. | Req: maintenance management |

---

## 4. Attribute Analysis

### E1 — CampusUser

| Attribute | Description | Notes |
|---|---|---|
| campus_user_id | Unique identifier | PK |
| full_name | User's full name | |
| email | Email address | Should be unique |
| phone | Phone number | Optional? |
| role | User role (student, lecturer, TA, facility staff, dept admin, facility manager) | Enum |
| department | Department name | |
| account_status | Active, inactive, suspended | |

### E2 — CampusSpace

| Attribute | Description | Notes |
|---|---|---|
| campus_space_code | Unique code for the space | PK |
| space_name | Descriptive name | |
| space_type | auditorium, classroom, computer_lab, meeting_room | Enum |
| building | Building name/location | |
| floor | Floor number | |
| room_number | Room number within building | |
| capacity | Maximum occupancy | |
| current_status | available, in_use, under_maintenance, temporarily_closed, retired | Enum |
| usage_policy | Text describing rules for usage | |

### E3 — CampusFacility

| Attribute | Description | Notes |
|---|---|---|
| campus_facility_id | Unique identifier | PK |
| facility_type | e.g., projector, whiteboard, microphone, computer, livestreaming equipment, air conditioner | |
| description | Optional description | |
| campus_space_code | Campus space where the facility is installed | FK → CampusSpace |
| status | available, in_use, under_maintenance | |

### E4 — SpaceBooking

| Attribute | Description | Notes |
|---|---|---|
| space_booking_id | Unique identifier | PK |
| requester_id | Who submitted the request | FK → CampusUser |
| campus_space_code | Which space is requested | FK → CampusSpace |
| requested_start_time | Desired start date/time | |
| requested_end_time | Desired end date/time | |
| purpose_type | lecture, examination, seminar, workshop, meeting, student_activity, administrative_event | Enum |
| expected_participants | Number of participants | |
| status | pending, approved, rejected, cancelled, checked_in, completed, no-show | Enum |
| submitted_at | Timestamp of submission | |

### E5 — BookingApproval

| Attribute | Description | Notes |
|---|---|---|
| booking_approval_id | Unique identifier | PK |
| space_booking_id | The booking being decided | FK → SpaceBooking |
| staff_id | Facility staff/manager who decided | FK → CampusUser |
| decision | approved or rejected | |
| decision_time | When the decision was made | |
| decision_note | Note from the approver | |
| rejection_reason | Required if rejected | |

### E6 — SpaceUsageSession

| Attribute | Description | Notes |
|---|---|---|
| space_usage_session_id | Unique identifier | PK |
| space_booking_id | The associated booking | FK → SpaceBooking |
| checked_in_by | Staff who performed check-in | FK → CampusUser |
| actual_start_time | When the user actually started using the space | |
| initial_condition | Condition of space at check-in | |
| actual_end_time | When usage ended | |
| final_condition | Condition of space at check-out | |
| usage_notes | Any notes about the session | |

### E7 — SpaceMaintenance

| Attribute | Description | Notes |
|---|---|---|
| space_maintenance_id | Unique identifier | PK |
| campus_space_code | The space being maintained | FK → CampusSpace |
| reporter_id | Who reported the problem | FK → CampusUser |
| assigned_staff_id | Staff assigned to fix it | FK → CampusUser |
| problem_description | Description of the issue | |
| problem_type | broken_projector, ac_failure, damaged_furniture, cleaning, network, other | |
| start_time | When maintenance began | |
| completion_time | When maintenance was completed | |
| status | reported, in_progress, completed, cancelled | |
| result_note | Outcome or notes | |

---

## 5. Relationship Analysis

- R1 — A campus user can submit as many space bookings as they want.
- R2 — A campus space can be booked in many space bookings over time.
- R3 — A campus space can contain many campus facilities, while each campus facility is installed in exactly one campus space at a time
- R4 — A space booking may receive at most one approval decision.
- R5 — A facility staff member or manager can approve as many booking requests as needed.
- R6 — A space booking may result in at most one usage session when checked in.
- R7 — A facility staff member can check in as many usage sessions as needed.
- R8 — A campus space can undergo many maintenance activities over its lifetime.
- R9 — A campus user can report as many maintenance issues as they encounter.
- R10 — A staff member can be assigned to work on many maintenance tasks.

---

## 6. Business Rules

| # | Rule |
|---|---|
| BR1 | A space cannot have two approved bookings with overlapping time periods. |
| BR2 | A space under maintenance, temporarily closed, or retired cannot be booked. |
| BR3 | A booking status flows: pending → approved/rejected/cancelled → checked_in → completed/no-show. |
| BR4 | Rejection reason is required when a booking is rejected. |
| BR5 | An approval decision must be made by a facility staff member or facility manager. |
| BR6 | Check-in must be performed by facility staff. |
| BR7 | Expected participants must not exceed space capacity. |
| BR8 | A booking's start time must be before its end time. |
| BR9 | Maintenance status "in_progress" should prevent new bookings for the space. |
| BR10 | Historical records must be preserved (no hard deletes of completed bookings or maintenance). |

---

## 7. Assumptions

| # | Assumption |
|---|---|
| A1 | Each campus user has exactly one role. If a person has multiple roles, they are represented by separate accounts. |
| A2 | Phone number is optional for users. |
| A3 | A space booking always goes through at most one approval (no multi-level approval chain). |
| A4 | Check-in and check-out are always performed by facility staff, not by the requester. |
| A5 | A space can be used without a prior booking for walk-in usage, but the system requires at least a booking record. |
| A6 | Maintenance records can exist without a linked booking. |
| A7 | Each campus facility represents a unique physical asset assigned to exactly one campus space. Facility types (e.g., projector, computer, whiteboard) are predefined and managed through a lookup table or enumeration. |

---

## 8. Open Questions

| # | Question |
|---|---|
| Q1 | Should a single campus user be allowed to have multiple roles (e.g., both student and teaching assistant)? |
| Q2 | Should there be a notification system for booking approval/rejection? |
| Q3 | How are recurring bookings handled (e.g., weekly lectures for a full semester)? |
| Q4 | Is there a maximum booking duration or advance booking window? |
| Q5 | Should the system support waitlisting when a space is unavailable? |
| Q6 | Should there be different approval workflows based on space type or requester role? |
| Q7 | Are there charges/fees associated with booking certain spaces? |
