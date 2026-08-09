# Requirement Change Analysis

**Group:** G02

**Date:** 2026-07-31

---

## 1. Business Purpose

**Status:** Modified

**Previous Requirement:**
The system aims to automate space booking, approval, usage tracking, maintenance management, incident reporting, and facility utilization tracking. The core goals are:
- Prevent overlapping bookings.
- Prevent booking of unavailable spaces (under maintenance, closed, retired).
- Preserve historical records of bookings and maintenance.
- Support fair and transparent space allocation.

**Updated Requirement:**
The core business objectives remain the same, with two refinements:
1. Maintenance management is refined: a space under maintenance may be either fully unavailable (out-of-service) or still bookable with an advisory notice (advisory), depending on the maintenance impact level.
2. The system must support concurrency control to guarantee that no two approved bookings overlap for the same space, even under concurrent submission and approval operations.
3. New reporting requirements are added for usage analytics and maintenance impact analysis.

**Impact:**
The business purpose is extended, not replaced. The original goals are preserved and augmented. All existing design artifacts (entities, relationships, business rules) remain valid but require modification to support the impact level distinction and concurrency guarantees.

**Reason:**
The Facility Manager identified that not all maintenance makes a space unusable. The refined rule allows the school to maximise space utilisation while ensuring requesters are informed of known issues. Concurrency control is needed because manual sequential processing is infeasible at peak times (e.g., start of semester).

---

## 2. Business Data Entities & Attributes

### Entity: SpaceMaintenance

- **Change Type:** Modified
- **What changed:**
  Added column `impact_level` to distinguish maintenance that renders a space unusable from maintenance that is merely advisory.
- **Why it changed:**
  The new requirement (maintenance impact levels) introduces two categories of maintenance — out-of-service and advisory — that affect booking rules differently.
- **Affected attributes:**
  | Attribute | Change | Description |
  |---|---|---|
  | impact_level | **New** | NVARCHAR(20), NOT NULL, DEFAULT 'out_of_service'. Values: 'out_of_service', 'advisory'. Indicates whether the maintenance makes the space unavailable or is only advisory. |
- **Impact on the data model:**
  - `SpaceMaintenance` gains one new column.
  - The existing trigger `trg_SpaceMaintenance_UpdateSpaceStatus` must be modified: only out-of-service maintenance should set `CampusSpace.current_status = 'under_maintenance'`.
  - Backward compatibility preserved: default is 'out_of_service', so existing data implicitly behaves as in Phase 1.

### Entity: SpaceBooking

- **Change Type:** Modified
- **What changed:**
  Added column `advisory_acknowledged` to record that the requester was informed of active advisory maintenance at booking time. Added column `is_instant_booking` to distinguish auto-approved bookings from staff-approved ones.
- **Why it changed:**
  The new requirement mandates that requesters must acknowledge active advisories before booking. Instant booking for selected space types needs a way to distinguish auto-approved bookings.
- **Affected attributes:**
  | Attribute | Change | Description |
  |---|---|---|
  | advisory_acknowledged | **New** | BIT, NOT NULL, DEFAULT 0. Set to 1 when the requester acknowledges active advisory maintenance on the space at submission time. |
  | is_instant_booking | **New** | BIT, NOT NULL, DEFAULT 0. Set to 1 when the booking was auto-approved via instant booking (for classrooms and auditoriums satisfying usage policy). |
- **Impact on the data model:**
  - `SpaceBooking` gains two new columns.
  - The booking submission logic must check for advisory maintenance records and require acknowledgement when present.
  - The instant booking logic must check space type (classroom or auditorium) and usage policy compliance.

---

## 3. Relationships & Cardinalities

One new structural relationship is added (R12: `CampusFacility` ↔ `FacilityMaintenance`), plus one derived relationship (R15: out-of-service facility maintenance makes its containing space unavailable). The existing structural relationships (R1–R10) remain unchanged in cardinality and participation.

The following relationships have **refined operational behaviour** based on the new requirement:

| Relationship | Change Type | What changed | Why it changed | Updated cardinality | Participation changes |
|---|---|---|---|---|---|
| R2: CampusSpace ↔ SpaceBooking (is booked in) | **Modified** | Booking a space now depends on maintenance impact level (out-of-service blocks, advisory does not). Instant booking is added for classrooms and auditoriums. | New maintenance impact levels and instant booking rules refined when a space may be booked. | 1:N (unchanged) | Unchanged |
| R8: CampusSpace ↔ SpaceMaintenance (undergoes) | **Modified** | Only out-of-service maintenance blocks new bookings. Advisory maintenance allows bookings with acknowledgement. | The blanket "under maintenance = unavailable" rule is replaced with the impact level distinction. | 1:N (unchanged) | Unchanged |
| R12 (new): CampusFacility ↔ FacilityMaintenance (undergoes) | **New** | An active `FacilityMaintenance` record with `impact_level = 'out_of_service'` makes its `CampusFacility` under maintenance (status = `under_maintenance`). | Out-of-service maintenance affects the availability of the facility itself, which in turn affects the containing space (see R15). | 1:N | New |
| R15 (new, derived): CampusSpace ↔ FacilityMaintenance (indirect via R3: CampusSpace contains CampusFacility) | **New** | An active `FacilityMaintenance` record with `impact_level = 'out_of_service'` for a `CampusFacility` located in a `CampusSpace` makes that space under maintenance, so the space cannot be booked during the maintenance interval. | Out-of-service facilities can render their containing space unavailable even when no `SpaceMaintenance` record exists; `CampusSpace.current_status` and booking availability must reflect facility maintenance. | 1:N (derived through R3 + FacilityMaintenance → CampusFacility) | New |

---

## 4. Business Rules

### BR-02 (Section 6, Rule 2 of Business Requirement Analysis) — Modified

| Field | Value |
|---|---|
| **Change Type** | Modified |
| **What changed** | Replaced the blanket rule "A space under maintenance, temporarily closed, or retired cannot be booked" with two rules: out-of-service maintenance blocks booking; advisory maintenance requires acknowledgement. |
| **Why it changed** | The Facility Manager introduced impact levels for maintenance (new requirement: maintenance impact levels). |
| **Business impact** | Maximises space utilisation: spaces with minor issues (e.g., broken projector) can still be booked while requesters are informed. |

### BR-09 (Section 6, Rule 9 of Business Requirement Analysis) — Modified

| Field | Value |
|---|---|
| **Change Type** | Modified |
| **What changed** | Changed from "Maintenance status 'in_progress' should prevent new bookings for the space" to "Only out-of-service maintenance (impact_level = 'out_of_service') should prevent new bookings for the space; advisory maintenance (impact_level = 'advisory') must not block booking." |
| **Why it changed** | Aligns with the impact level distinction. A maintenance record with status 'in_progress' may be advisory, so the space should remain bookable. |
| **Business impact** | Prevents unnecessary blocking of space usage when the maintenance is minor or does not affect usability. |

### BR-11 (New) — Instant Booking

| Field | Value |
|---|---|
| **Change Type** | New |
| **What changed** | New rule: For classrooms and auditoriums, if a booking request satisfies the space's usage policy, it may be approved automatically at submission time (instant booking) without staff intervention. Other space types and requests that do not satisfy the usage policy continue through the staff approval workflow. |
| **Why it changed** | The new requirement introduces instant booking for selected space types to handle peak-time demand (start of semester). |
| **Business impact** | Reduces staff workload during peak periods. Faster booking turnaround for standard requests. |

### BR-12 (New) — Concurrency Control

| Field | Value |
|---|---|
| **Change Type** | New |
| **What changed** | New rule: The system must guarantee that no two approved bookings exist for the same space with overlapping time periods, regardless of whether the bookings are created through instant booking or staff approval, and regardless of concurrent operations by multiple users or staff members. |
| **Why it changed** | The new requirement (concurrent booking and approval operating conditions) mandates this guarantee. Phase 1 assumed sequential processing; this was not explicitly addressed. |
| **Business impact** | Prevents data integrity violations under load. Requires serializable isolation level or equivalent application-level locking. |

### BR-13 (New) — Advisory Acknowledgement

| Field | Value |
|---|---|
| **Change Type** | New |
| **What changed** | New rule: When a booking is submitted for a space that has active advisory maintenance records, the system must notify the requester of all active advisories and record the requester's acknowledgement (advisory_acknowledged = 1) before the booking can be created. |
| **Why it changed** | The new requirement (maintenance impact levels) mandates that requesters be informed of advisories. |
| **Business impact** | Protects the school from disputes about space condition at time of booking. Ensures requesters make informed decisions. |

### BR-14 (New) — Escalation Impact Identification

| Field | Value |
|---|---|
| **Change Type** | New |
| **What changed** | New rule: When a maintenance record is escalated from advisory to out-of-service, the system must identify all approved bookings that overlap the maintenance period for that space, so staff can contact the affected requesters. This is a reporting/identification requirement only — bookings are not automatically cancelled. |
| **Why it changed** | The new requirement (maintenance impact levels) mandates escalation tracking with affected booking identification. |
| **Business impact** | Enables proactive staff action to resolve scheduling conflicts caused by escalation. |

---

## 5. Conflicts

### Conflict 1: Concurrent booking submission + instant approval

| Field | Value |
|---|---|
| **Conflict** | Two users submit instant-booking requests for the same classroom at overlapping times simultaneously. Both pass the availability check before either records its result. |
| **Cause** | The instant booking auto-approves at submission time. Without concurrency control, both transactions could read the same "no conflicting booking" state and proceed to insert. |
| **Potential impact** | Two approved bookings with overlapping time periods for the same space — violating BR-01. |
| **Recommended mitigation** | Use serializable isolation level or table-level locking (e.g., `WITH (UPDLOCK, HOLDLOCK)` on the `SpaceBooking` range check) for all booking and approval operations. Alternatively, use an application-level mutex or a database `sp_getapplock` on the space code for the duration of the booking transaction. |

### Conflict 2: Concurrent staff approval and maintenance escalation

| Field | Value |
|---|---|
| **Conflict** | A facility staff member approves a pending booking for a space while another staff member escalates an advisory maintenance on the same space to out-of-service (both operations happening at nearly the same time). |
| **Cause** | The approval transaction checks only active out-of-service maintenance at read time, but the escalation commit occurs after the approval check and before the approval write. |
| **Potential impact** | A booking is approved for a space that should now be unavailable, violating BR-02 (modified). |
| **Recommended mitigation** | Perform the out-of-service maintenance check inside the same serializable transaction that sets the booking status to 'approved'. Lock the space's maintenance records (e.g., `SELECT ... FROM SpaceMaintenance WITH (UPDLOCK)` where status IN ('reported', 'in_progress') AND impact_level = 'out_of_service') within the approval transaction. |

### Conflict 3: Multiple simultaneous escalation-impact queries

| Field | Value |
|---|---|
| **Conflict** | Two staff members escalate different advisory maintenance records on the same space at the same time. Both queries to identify affected approved bookings return stale results because each transaction does not see the other's uncommitted escalation. |
| **Cause** | Read committed isolation level allows dirty reads to be avoided but does not prevent phantom rows (other transactions' pending escalations are invisible). |
| **Potential impact** | Incomplete or overlapping lists of affected bookings are reported to staff, causing duplicate or missed outreach to requesters. |
| **Recommended mitigation** | Use serializable isolation level or range locks when querying affected bookings during escalation. Consider a queue-based approach where escalation requests are processed sequentially per space. |

---

*This analysis is derived from the updated requirement document (`req/new_requirement.md`) and compared against the existing artifacts: `01-business-req-analysis-G02.md`, `02-erd-design-G02.md`, `03-logical-design-G02.md`, `04-design-validation-G02.md`, and `05-db-definition-G02.sql`.*
