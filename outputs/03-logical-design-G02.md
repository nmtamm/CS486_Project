# Logical Database Design — Relational Schema

**Group:** G02

**Date:** 2026-06-27

---

## 1. Relational Schema Diagram & Notation

**Key Notation:**
- `🔑` = Primary Key (PK)
- `🔗` = Foreign Key (FK)
- `⭐` = Candidate Key / Unique Key (UK)

**Text Formatting:**
- **Bold** text = Primary Key attribute
- *Italic* text = Foreign Key attribute
- ***Bold italic*** text = Attribute that is both PK and FK

```mermaid
flowchart LR

subgraph USR ["`**CampusUser**`"]
direction LR
USR1["`**🔑 campus_user_id**`"] ~~~
USR2["full_name"] ~~~
USR3["`⭐ email`"] ~~~
USR4["phone"] ~~~
USR5["role"] ~~~
USR6["department"] ~~~
USR7["account_status"]
end

subgraph SPC ["`**CampusSpace**`"]
direction LR
SPC1["`**🔑 campus_space_code**`"] ~~~
SPC2["space_name"] ~~~
SPC3["space_type"] ~~~
SPC4["building"] ~~~
SPC5["floor"] ~~~
SPC6["room_number"] ~~~
SPC7["capacity"] ~~~
SPC8["current_status"] ~~~
SPC9["usage_policy"]
end

subgraph FAC ["`**CampusFacility**`"]
direction LR
FAC1["`**🔑 campus_facility_id**`"] ~~~
FAC2["`⭐ facility_name`"] ~~~
FAC3["description"]
end

subgraph CSF ["`**CampusSpaceFacility**`"]
direction LR
CSF1["`**🔑 campus_space_facility_id**`"] ~~~
CSF2["`*🔗 campus_space_code*`"] ~~~
CSF3["`*🔗 campus_facility_id*`"] ~~~
CSF4["quantity"]
end

subgraph BKG ["`**SpaceBooking**`"]
direction LR
BKG1["`**🔑 space_booking_id**`"] ~~~
BKG2["`*🔗 requester_id*`"] ~~~
BKG3["`*🔗 campus_space_code*`"] ~~~
BKG4["requested_start_time"] ~~~
BKG5["requested_end_time"] ~~~
BKG6["purpose_type"] ~~~
BKG7["expected_participants"] ~~~
BKG8["status"] ~~~
BKG9["submitted_at"]
end

subgraph APR ["`**BookingApproval**`"]
direction LR
APR1["`**🔑 booking_approval_id**`"] ~~~
APR2["`*🔗 space_booking_id*`"] ~~~
APR3["`*🔗 staff_id*`"] ~~~
APR4["decision"] ~~~
APR5["decision_time"] ~~~
APR6["decision_note"] ~~~
APR7["rejection_reason"]
end

subgraph SES ["`**SpaceUsageSession**`"]
direction LR
SES1["`**🔑 space_usage_session_id**`"] ~~~
SES2["`*🔗 space_booking_id*`"] ~~~
SES3["`*🔗 checked_in_by*`"] ~~~
SES4["actual_start_time"] ~~~
SES5["initial_condition"] ~~~
SES6["actual_end_time"] ~~~
SES7["final_condition"] ~~~
SES8["usage_notes"]
end

subgraph MNT ["`**SpaceMaintenance**`"]
direction LR
MNT1["`**🔑 space_maintenance_id**`"] ~~~
MNT2["`*🔗 campus_space_code*`"] ~~~
MNT3["`*🔗 reporter_id*`"] ~~~
MNT4["`*🔗 assigned_staff_id*`"] ~~~
MNT5["problem_description"] ~~~
MNT6["problem_type"] ~~~
MNT7["start_time"] ~~~
MNT8["completion_time"] ~~~
MNT9["status"] ~~~
MNT10["result_note"]
end

BKG2 --> USR1
BKG3 --> SPC1
CSF2 --> SPC1
CSF3 --> FAC1
APR2 --> BKG1
APR3 --> USR1
SES2 --> BKG1
SES3 --> USR1
MNT2 --> SPC1
MNT3 --> USR1
MNT4 --> USR1
```

---

## 2. Business Rule Enforcement Map

| Business Rule ID | Business Rule Description | Enforcement Mechanism | Related Relation(s) | Related Attribute(s) |
| ---------------- | ------------------------- | --------------------- | ------------------- | -------------------- |
| BR-01 | A space cannot have two approved bookings with overlapping time periods. | Trigger / Stored Procedure | SpaceBooking | requested_start_time, requested_end_time, status |
| BR-02 | A space under maintenance, temporarily closed, or retired cannot be booked. | Application Logic | CampusSpace, SpaceBooking | current_status |
| BR-03 | A booking status flows: pending → approved/rejected/cancelled → checked_in → completed/no-show. | CHECK, Trigger / Stored Procedure | SpaceBooking | status |
| BR-04 | Rejection reason is required when a booking is rejected. | CHECK | BookingApproval | decision, rejection_reason |
| BR-05 | An approval decision must be made by a facility staff member or facility manager. | Application Logic | BookingApproval, CampusUser | staff_id, role |
| BR-06 | Check-in must be performed by facility staff. | Application Logic | SpaceUsageSession, CampusUser | checked_in_by, role |
| BR-07 | Expected participants must not exceed space capacity. | CHECK, Application Logic | SpaceBooking, CampusSpace | expected_participants, capacity |
| BR-08 | A booking's start time must be before its end time. | CHECK | SpaceBooking | requested_start_time, requested_end_time |
| BR-09 | Maintenance status "in_progress" should prevent new bookings for the space. | Application Logic | SpaceMaintenance, SpaceBooking | status, campus_space_code |
| BR-10 | Historical records must be preserved (no hard deletes of completed bookings or maintenance). | Application Logic | All tables | N/A |
