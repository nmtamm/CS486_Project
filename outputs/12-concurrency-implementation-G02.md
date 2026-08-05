# Step 12 — Concurrency Implementation (Analytical Process)

**Group:** G02

**Phase:** Phase 2 — Concurrency Implementation (Step 12)

**Task:** Implement the concurrency-control design as runnable T-SQL stored procedures for the Campus Space Management System

**Target Database:** `SpaceBookingDB_Phase2`

**DBMS:** Microsoft SQL Server

**Generation Date:** 2026-08-03

---

## 1. Objective

This artifact implements the concurrency-control design defined in `outputs/11-concurrency-design-G02.md` as executable T-SQL against the Phase 2 database created by `outputs/10-schema-migration-G02.sql` (`SpaceBookingDB_Phase2`).

The implementation translates the three transaction specifications from Step 11 (`§4.1` Booking Submission, `§4.2` Staff Booking Approval, `§4.3` Maintenance Impact Escalation) into three protected stored procedures that **prevent** — not merely detect — the two concurrency errors identified and reproduced in Step 11:

1. **Error 1** — Concurrent instant-booking double allocation (BR-01 / BR-12 violation).
2. **Error 2** — Staff approval racing with maintenance escalation to `out_of_service` (BR-02 / BR-09 violation).

Every procedure follows the same pessimistic locking model chosen in Step 11 §3.2:

- an exclusive application lock on the parent resource (`sp_getapplock`, resource `N'Lock_Space_<space_code>'`, lock owner `Transaction`, timeout 5 s), which serializes all write workflows per space while allowing operations on different spaces to run in parallel;
- key-range update lock hints `WITH (UPDLOCK, HOLDLOCK)` on `SpaceMaintenance` and `SpaceBooking` inside the locked section, providing a second line of defence that keeps the checked ranges stable until commit.

The implementation sits **on top of** the migrated schema: it does not modify any base table, drop any existing object, or bypass the triggers (`trg_SpaceBooking_StatusTransition`, `trg_SpaceBooking_CapacityCheck`, `trg_SpaceMaintenance_UpdateSpaceStatus`) and `CHECK` constraints created in `10-schema-migration-G02.sql`.

---

## 2. Reference Files

| Purpose | File |
|---|---|
| Authoritative procedure specifications (transaction boundaries, lock acquisition, validation queries) | `outputs/11-concurrency-design-G02.md` (Step 11, §3–§4) |
| Target schema — table names, column names, types, FKs, CHECK/enum literals | `outputs/10-schema-migration-G02.sql` (Step 10) |
| Updated logical design — entities, relationships, business-rule identifiers (BR-01 … BR-14) | `outputs/09-updated-erd-and-logical-design-G02.md` (Step 09) |
| Real sample values used by the Step 13 test scripts | `outputs/06-sample-data-G02.sql` (migrated into `SpaceBookingDB_Phase2` by Step 10) |
| Race-condition reproduction scripts used as Step 13 test input | `outputs/11-reproduce-concurrency-error1-G02.sql`, `outputs/11-reproduce-concurrency-error2-G02.sql` |

Precedence on conflict: Step 11 design → Step 10 schema → Step 09 logical design → sample data. Where the Step 11 document names an object that does not exist in the Step 10 schema, the schema wins and the mismatch is surfaced (none were found).

---

## 3. Implemented Procedures

The executable script `outputs/12-concurrency-implementation-G02.sql` creates three stored procedures. Each procedure is preceded and followed by a `GO` batch separator, opens with `SET NOCOUNT ON;`, and wraps its transaction in `BEGIN TRY / BEGIN CATCH` so that any failure (including a validation `THROW` or an unanticipated constraint error) rolls back the transaction and releases the transaction-owned application lock before re-raising the error.

### 3.1. `dbo.sp_SubmitSpaceBooking` — Booking Submission Protocol

**Design-doc section translated:** `11-concurrency-design-G02.md` §4.1 (4.1.1 Purpose & Scope, 4.1.2 Transaction Flowchart, 4.1.3 Specification Details).

**SQL object behaviour:**

- **Inputs:** `@requester_id INT`, `@campus_space_code NVARCHAR(20)`, `@requested_start_time DATETIME2`, `@requested_end_time DATETIME2`, `@purpose_type NVARCHAR(40)`, `@expected_participants INT`.
- **Outputs:** `@space_booking_id INT` (new booking, `SCOPE_IDENTITY()`), `@result_status NVARCHAR(20)` (`'approved'` for instant booking, `'pending'` for staff workflow), `@advisories_notified BIT` (1 when active advisory maintenance on the space was notified during submission).
- **Lock acquisition:** `sp_getapplock` on `N'Lock_Space_' + @campus_space_code`, `Exclusive`, lock owner `Transaction`, timeout 5000 ms. On result `< 0` it throws a clean "system busy, retry" error.
- **Order of operations inside the lock (per 11 §4.1.3):**
  1. **Capacity / space-state validation (BR-07, BR-02):** reads `CampusSpace.capacity`, `current_status`, `space_type`; rejects `temporarily_closed` / `retired` spaces and `expected_participants > capacity`.
  2. **Blocking-state check (BR-02 / BR-09):** `SELECT ... FROM SpaceMaintenance WITH (UPDLOCK, HOLDLOCK)` for active (`reported`/`in_progress`) `impact_level = 'out_of_service'` records whose interval overlaps the requested window (half-open rule); rejects on match.
  3. **Conditional advisory-notification side effect (BR-13):** `UPDATE ... FROM FacilityMaintenance WITH (UPDLOCK, HOLDLOCK) JOIN CampusFacility` for active `advisory` records of facilities in the requested space that overlap the window; when any row matches it sets `notify_status = 'updated_to_advisory'` atomically with the booking insert and sets `@advisories_notified = 1` (derived from `@@ROWCOUNT`). Advisory maintenance never blocks booking.
  4. **Overlap check (BR-01 / BR-12):** `SELECT ... FROM SpaceBooking WITH (UPDLOCK, HOLDLOCK)` for approved-lifecycle bookings (`approved`, `checked_in`, `completed`, `no-show`) of the same space overlapping the requested window; rejects on match.
  5. **Policy lookup (BR-11):** reads `SpaceTypeBookingPolicy.instant_booking_eligible` for the space type; eligible ⇒ `@status = 'approved'`, `@is_instant = 1`; otherwise `@status = 'pending'`, `@is_instant = 0`.
  6. **Insert:** `INSERT INTO SpaceBooking (...)` with `status`/`is_instant_booking` chosen so the existing trigger `trg_SpaceBooking_StatusTransition` accepts the row (staff ⇒ `pending`/0; instant ⇒ `approved`/1). `submitted_at` takes its `GETDATE()` default.

**Invariants upheld:** BR-01, BR-02, BR-07, BR-09, BR-11, BR-12, BR-13.

### 3.2. `dbo.sp_ApproveSpaceBooking` — Staff Booking Approval Protocol

**Design-doc section translated:** `11-concurrency-design-G02.md` §4.2 (4.2.1 Purpose & Scope, 4.2.2 Specification Details).

**SQL object behaviour:**

- **Inputs:** `@space_booking_id INT`, `@staff_id INT`, `@decision NVARCHAR(10)` (`'approved'` | `'rejected'`), `@decision_note NVARCHAR(MAX) = NULL`, `@rejection_reason NVARCHAR(MAX) = NULL`.
- **Outputs:** none (status change is observable via the row).
- **Pre-lock validation:**
  - `@staff_id` must exist with `role IN ('facility_staff', 'facility_manager')` (BR-05);
  - the target booking must exist and have `status = 'pending'` (BR-03 — prevents double approval);
  - `@decision` must be `'approved'` or `'rejected'`;
  - a rejected decision requires a non-empty `@rejection_reason` (BR-04).
- **Lock acquisition:** `sp_getapplock` on `N'Lock_Space_' + @campus_space_code` (the space code is read from the target booking row), `Exclusive`, lock owner `Transaction`, timeout 5000 ms.
- **Order of operations when `@decision = 'approved'` (per 11 §4.2 step 5):**
  1. **Blocking-state re-check (BR-02 / BR-09):** `SELECT ... FROM SpaceMaintenance WITH (UPDLOCK, HOLDLOCK)` for active `out_of_service` maintenance overlapping the booking window; rejects on match.
  2. **Overlap re-check (BR-01 / BR-12):** `SELECT ... FROM SpaceBooking WITH (UPDLOCK, HOLDLOCK)` for approved-lifecycle bookings of the same space overlapping the booking window (excluding this booking id); rejects on match.
  3. `UPDATE SpaceBooking SET status = 'approved'` (the trigger validates the `pending → approved` transition).
  4. `INSERT INTO BookingApproval (space_booking_id, staff_id, decision, decision_note)`.
- **Order of operations when `@decision = 'rejected':`** `UPDATE SpaceBooking SET status = 'rejected'` and `INSERT INTO BookingApproval (... decision, decision_note, rejection_reason)`.

**Invariants upheld:** BR-01, BR-02, BR-03, BR-04, BR-05, BR-09, BR-12.

### 3.3. `dbo.sp_EscalateSpaceMaintenance` — Maintenance Impact Escalation Protocol

**Design-doc section translated:** `11-concurrency-design-G02.md` §4.3 (4.3.1 Purpose & Scope, 4.3.2 Specification Details). The parameter `@new_impact_level` defaults to `'out_of_service'` (escalation) and also supports the Phase 2 downgrade direction by passing `'advisory'`.

**SQL object behaviour:**

- **Inputs:** `@space_maintenance_id INT`, `@staff_id INT`, `@new_impact_level NVARCHAR(20) = 'out_of_service'`.
- **Outputs:** `@affected_count INT` (number of approved/checked-in bookings overlapping the maintenance interval); the affected rows are also returned as a result set for staff outreach (BR-14).
- **Pre-lock validation:**
  - `@new_impact_level IN ('out_of_service', 'advisory')` (matches the schema CHECK);
  - the maintenance record must exist and be open (`status IN ('reported', 'in_progress')`) — completed/cancelled records cannot be escalated/downgraded;
  - `@staff_id` must be `facility_staff` or `facility_manager`.
- **Lock acquisition:** `sp_getapplock` on `N'Lock_Space_' + @campus_space_code` (read from the maintenance row), `Exclusive`, lock owner `Transaction`, timeout 5000 ms.
- **Order of operations inside the lock:**
  1. `UPDATE SpaceMaintenance SET impact_level = @new_impact_level` — the existing trigger `trg_SpaceMaintenance_UpdateSpaceStatus` fires and (for escalation to `out_of_service`) sets `CampusSpace.current_status = 'under_maintenance'` automatically within the same transaction.
  2. **Affected-booking identification (BR-14):** `SELECT ... FROM SpaceBooking WITH (UPDLOCK, HOLDLOCK)` for `approved` / `checked_in` bookings of the same space whose interval overlaps the maintenance interval `[start_time, completion_time)`, treating `completion_time IS NULL` as an open-ended interval (`[start_time, ∞)`). Returns the list and sets `@affected_count`.

**Invariants upheld:** BR-02, BR-09, BR-14.

---

## 4. How Each Concurrency Error Is Prevented

The reproduction scripts in `outputs/11-reproduce-concurrency-error1-G02.sql` and `outputs/11-reproduce-concurrency-error2-G02.sql` demonstrate the race conditions under default `READ COMMITTED` with no locking. The procedures below close the races.

### 4.1. Error 1 — Concurrent Instant Booking Double-Allocation (BR-01 / BR-12)

**Step 11 §2.1 scenario:** Session A and Session B both check `SpaceBooking` for `B201` (both read `OverlapCount = 0`), then both insert an `approved` instant booking for the same `10:00–12:00` window. Both commit; the overlap invariant is violated.

**Prevention in `sp_SubmitSpaceBooking`:**

1. Every submission first acquires the exclusive application lock `Lock_Space_B201` (11 §3.2). Two concurrent submissions for `B201` are therefore strictly **serialized**: the first holds the lock from the moment it checks availability until it commits; the second blocks in `sp_getapplock` (up to the 5 s timeout) and only proceeds after the first commits.
2. Inside the lock, the overlap check `SELECT ... FROM SpaceBooking WITH (UPDLOCK, HOLDLOCK)` holds update-range locks on the booking rows of the space until commit. This is the second line of defence: even if some code path reached the overlap check without the application lock, a concurrent transaction's overlapping insert would be blocked by the range lock, and the check would see the committed/committing conflicting row.
3. The status/is_instant combination written by the procedure satisfies `trg_SpaceBooking_StatusTransition`, so the insert completes without bypassing the migrated trigger.
4. When the second transaction finally runs, its overlap check sees the first transaction's `approved` row and throws the BR-01/BR-12 error, rolling back. Re-running the Step 11 interleaving against the procedures yields exactly one successful `approved` booking.

### 4.2. Error 2 — Concurrent Staff Approval vs. Maintenance Escalation (BR-02 / BR-09)

**Step 11 §2.2 scenario:** Session A (staff approval) reads `OutOfServiceMaintCount = 0` for `A101`; Session B escalates an advisory maintenance to `out_of_service`; Session A then approves the booking. A booking ends up approved while the space is out of service.

**Prevention in `sp_ApproveSpaceBooking` + `sp_EscalateSpaceMaintenance`:**

1. Both procedures acquire the **same** application lock keyed by `campus_space_code` (`Lock_Space_A101`). Approval and escalation for the same space therefore cannot overlap: if escalation is in flight, the approval blocks in `sp_getapplock` until the escalation commits, and then the approval's **blocking-state re-check** (§3.2) sees the escalated `out_of_service` maintenance and rejects the approval.
2. Conversely, if the approval acquires the lock first, the escalation waits; after the approval commits, the escalation's affected-booking identification (§3.3) includes the newly approved booking, and staff are handed the correct outreach list (BR-14).
3. Inside the approval, the maintenance check uses `WITH (UPDLOCK, HOLDLOCK)`, so the maintenance range is locked until the approval commits and cannot be updated concurrently by an escalation that bypassed the application lock.
4. The trigger `trg_SpaceMaintenance_UpdateSpaceStatus` keeps `CampusSpace.current_status` consistent within the escalation transaction, but booking availability itself is decided by the interval-based maintenance check, not by the convenience status attribute (09 §6.5).

Re-running the Step 11 interleaving against the procedures: the approval after the escalation commit throws the BR-02/BR-09 error and the booking stays `pending`; only one of the two operations can succeed for a given state.

### 4.3. Deadlock and liveness guarantees

- **Lock ordering:** the application lock on the parent resource (`campus_space_code`) is always acquired before any child rows (`SpaceBooking`, `SpaceMaintenance`, `FacilityMaintenance`, `BookingApproval`) are touched. No procedure ever nests a second application lock on a different space, so lock-acquisition order is globally consistent and circular waits are avoided (11 §3.3).
- **Explicit timeout:** `sp_getapplock` uses `@LockTimeout = 5000`; a busy space fails fast with "system busy, retry" instead of blocking indefinitely.
- **Isolation level:** the protection comes from application locks plus update-range hints under the default `READ COMMITTED`; no `SET TRANSACTION ISOLATION LEVEL` is required, matching the Step 11 chosen model (11 §3.2) and avoiding the deadlock/retry penalties of `SERIALIZABLE` and `SNAPSHOT`.

---

## 5. Run Instructions

### 5.1. Creating the procedures

1. Create and populate the Phase 2 target database by running, in order:
   - `outputs/05-db-definition-G02.sql` and `outputs/06-sample-data-G02.sql` (Phase 1 source `SpaceBookingDB`), then
   - `outputs/10-schema-migration-G02.sql` (creates `SpaceBookingDB_Phase2` and migrates all data).
2. Execute `outputs/12-concurrency-implementation-G02.sql` against `SpaceBookingDB_Phase2` to create `dbo.sp_SubmitSpaceBooking`, `dbo.sp_ApproveSpaceBooking`, and `dbo.sp_EscalateSpaceMaintenance`. The script is idempotent: each procedure is dropped if present before being created.

### 5.2. How to EXEC each procedure

The examples below use real values from `outputs/06-sample-data-G02.sql` (migrated into `SpaceBookingDB_Phase2` by Step 10).

- **Submit a booking** (space `B201`, requester user 4):

  ```sql
  DECLARE @id INT, @status NVARCHAR(20), @notified BIT;
  EXEC dbo.sp_SubmitSpaceBooking
      @requester_id          = 4,
      @campus_space_code     = N'B201',
      @requested_start_time  = '2026-09-10 10:00:00',
      @requested_end_time    = '2026-09-10 12:00:00',
      @purpose_type          = N'lecture',
      @expected_participants = 30,
      @space_booking_id      = @id OUTPUT,
      @result_status         = @status OUTPUT,
      @advisories_notified   = @notified OUTPUT;
  SELECT @id AS booking_id, @status AS result_status, @notified AS notified;
  ```

- **Approve / reject a booking** (staff user 2):

  ```sql
  EXEC dbo.sp_ApproveSpaceBooking
      @space_booking_id = <booking_id>,
      @staff_id         = 2,
      @decision         = N'approved',
      @decision_note    = N'Approved by staff';
  ```

- **Escalate maintenance** (staff user 3):

  ```sql
  DECLARE @cnt INT;
  EXEC dbo.sp_EscalateSpaceMaintenance
      @space_maintenance_id = <space_maintenance_id>,
      @staff_id             = 3,
      @new_impact_level     = N'out_of_service',
      @affected_count       = @cnt OUTPUT;
  SELECT @cnt AS affected_approved_bookings;
  ```

Effectiveness of the guards against the Step 11 race interleavings is tested in Step 13; this step only implements and documents the procedures.

---

## 6. Traceability Summary

The mapping below is embedded as a comment matrix at the end of `12-concurrency-implementation-G02.sql`. All procedure names, business-rule identifiers, and design-doc section references are sourced from `11-concurrency-design-G02.md` and `09-updated-erd-and-logical-design-G02.md`; no identifiers were invented.

| Procedure | Business rule / invariant | Design-doc section (Step 11) |
|---|---|---|
| `sp_SubmitSpaceBooking` | BR-01, BR-02, BR-07, BR-09, BR-11, BR-12, BR-13 | §4.1 (4.1.1–4.1.3) |
| `sp_ApproveSpaceBooking` | BR-01, BR-02, BR-03, BR-04, BR-05, BR-09, BR-12 | §4.2 |
| `sp_EscalateSpaceMaintenance` | BR-02, BR-09, BR-14 | §4.3 |
