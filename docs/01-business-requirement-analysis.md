# Business Requirement Analysis — Group 02

## 1. Introduction

This document analyzes the business requirements for the School of Computer Science Shared Space Booking System. The system will manage booking, approval, usage tracking, maintenance, and incident reporting for shared campus spaces including auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, and student workspaces.

---

## 2. Entities Identified

### 2.1 User

A person who interacts with the booking system.

**Attributes:**
- `user_id` — unique identifier
- `full_name`
- `email`
- `phone_number`
- `role` — one of: student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager
- `department`
- `account_status` — active, suspended, disabled

**Traceability:** Requirement paragraph 10 — "Each user must have a university account."

---

### 2.2 Space

A bookable physical space managed by the School.

**Attributes:**
- `space_code` — unique identifier
- `space_name`
- `space_type` — auditorium, classroom, computer_laboratory, project_laboratory, meeting_room, student_workspace
- `building`
- `floor`
- `room_number`
- `capacity`
- `status` — available, in_use, under_maintenance, temporarily_closed, retired
- `usage_policy` — free text

**Traceability:** Requirement paragraph 11 — "The School manages many bookable spaces."

---

### 2.3 Facility

A piece of equipment or amenity available in a space.

**Attributes:**
- `facility_id` — unique identifier
- `facility_name` — e.g., projector, whiteboard, microphone, computer, livestreaming_equipment, air_conditioner
- `description`

**Traceability:** Requirement paragraph 12 — "Each space may have several facilities."

---

### 2.4 SpaceFacility

Associates facilities with spaces (many-to-many relationship).

**Attributes:**
- `space_code` (FK to Space)
- `facility_id` (FK to Facility)

**Traceability:** Derived from paragraph 12 — a space can have many facilities, and a facility can exist in many spaces.

---

### 2.5 Booking

A request to reserve a space for a specific purpose and time period.

**Attributes:**
- `booking_id` — unique identifier
- `user_id` (FK to User) — the requester
- `space_code` (FK to Space)
- `requested_start_time`
- `requested_end_time`
- `purpose` — lecture, examination, seminar, workshop, meeting, student_activity, administrative_event
- `expected_participants`
- `status` — pending, approved, rejected, cancelled, checked_in, completed, no_show
- `approved_by` (FK to User, nullable) — staff who made the decision
- `decision_time` (nullable)
- `decision_note` (nullable)
- `rejection_reason` (nullable)
- `created_at`

**Traceability:** Requirement paragraphs 13–15 — "Users can submit booking requests," "Each booking request has a status," "A booking request may require approval."

---

### 2.6 CheckIn

Records the actual start of a booked session when the requester arrives.

**Attributes:**
- `booking_id` (PK, FK to Booking)
- `checked_in_by` (FK to User) — facility staff who performed the check-in
- `actual_start_time`
- `initial_condition` — free text description of space condition at check-in

**Traceability:** Requirement paragraph 16 — "When the requester arrives, facility staff can check in the booking."

---

### 2.7 Completion

Records the end of a booked session.

**Attributes:**
- `booking_id` (PK, FK to Booking)
- `completed_by` (FK to User) — facility staff who completed the booking
- `actual_end_time`
- `final_condition` — free text description of space condition at completion
- `usage_notes` — free text

**Traceability:** Requirement paragraph 16 — "When the session ends, facility staff can complete the booking."

---

### 2.8 MaintenanceRecord

A record of maintenance work performed on a space.

**Attributes:**
- `record_id` — unique identifier
- `space_code` (FK to Space)
- `reporter_id` (FK to User) — the person who reported the issue
- `assigned_staff_id` (FK to User, nullable) — staff assigned to fix the issue
- `problem_description` — free text
- `problem_type` — broken_projector, air_conditioning_failure, damaged_furniture, cleaning_issue, network_problem
- `start_time`
- `completion_time` (nullable)
- `status` — reported, in_progress, completed
- `result_note` (nullable)

**Traceability:** Requirement paragraph 17 — "A space may have maintenance records."

---

## 3. Business Rules

1. **No overlapping bookings:** The same space cannot have two approved bookings with overlapping time periods. (Paragraph 14)
2. **Unavailable spaces cannot be booked:** A space that is under maintenance, closed, or retired cannot be booked. (Paragraph 14)
3. **Approval authority:** Only facility staff or facility managers can approve or reject bookings. (Paragraph 15)
4. **Rejection reason required:** If a booking is rejected, the rejection reason must be stored. (Paragraph 15)
5. **Maintenance blocks booking:** A space under maintenance cannot be booked. (Paragraph 17)
6. **Historical preservation:** The system must keep historical records of bookings and maintenance activities. (Paragraph 18)

---

## 4. Booking Lifecycle

```
pending -> approved -> checked_in -> completed
pending -> rejected
pending -> cancelled
approved -> cancelled
checked_in -> no_show  (if session ends without proper completion)
```

---

## 5. Assumptions

1. Each user has exactly one role (no composite roles).
2. Each booking has at most one approval decision (approved_by, decision_time, etc. are stored directly on the Booking entity).
3. A maintenance record is assigned to at most one staff member.
4. A checked-in booking must eventually be completed.
5. Facility types are predefined but can be extended.
6. Time values include both date and time components.
7. A booking can only be checked in once and completed once.
8. The `in_use` status of a space is derived from active (checked-in, not yet completed) bookings, not stored separately.
9. No-show means the booking was checked in but the session was not properly completed.

---

## 6. Unresolved Questions

1. Should recurring bookings (e.g., weekly lectures) be supported?
2. What is the maximum allowed duration or advance notice for a booking?
3. Can a requester cancel their own booking after it has been approved?
4. Who is allowed to check in a booking — only facility staff, or also the requester?
5. What priority rules apply when multiple requests conflict for the same space?
6. What is the grace period before a booking is marked as no-show?
7. Should the system send notifications (email, SMS) for approvals, rejections, or reminders?
8. How are public holidays and non-operational hours handled?
9. Should the system support waitlisting for spaces that are already booked?
