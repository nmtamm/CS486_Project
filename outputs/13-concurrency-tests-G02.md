# Step 13 — Concurrency Tests (Test Plan and Analytical Process)

**Group:** G02

**Phase:** Phase 2 — Concurrency Testing (Step 13)

**Task:** Verify that the concurrency implementation from Step 12 prevents each concurrency error identified and reproduced in Step 11

**Target Database:** `SpaceBookingDB_Phase2`

**DBMS:** Microsoft SQL Server 2022

**Generation Date:** 2026-08-03

---

## 1. Objective

This artifact verifies that the pessimistic-locking concurrency implementation produced in Step 12 (`outputs/12-concurrency-implementation-G02.sql`) actually prevents the two concurrency errors that Step 11 identified and reproduced against the un-isolated database. The verification re-runs the Step 11 race interleavings through the Step 12 stored procedures instead of through raw interleaved statements, and asserts that the guard converts the nondeterministic race into a deterministic, correct outcome.

**What is verified:**

| # | Step 11 error | Guard under test (Step 12 procedures) | Invariant that must hold |
|---|---|---|---|
| E1 | Concurrent instant-booking double allocation (§2.1) | `dbo.sp_SubmitSpaceBooking` (§4.1) | BR-01 / BR-12 — at most one active booking per space per overlapping window |
| E2 | Staff approval racing maintenance escalation (§2.2) | `dbo.sp_ApproveSpaceBooking` (§4.2) + `dbo.sp_EscalateSpaceMaintenance` (§4.3) | BR-02 / BR-09 — a booking may not be approved for a window overlapping active `out_of_service` maintenance |

The tests execute against the migrated database created by `outputs/10-schema-migration-G02.sql` with the three procedures installed from `outputs/12-concurrency-implementation-G02.sql`. The target database is exactly the one the procedures were designed for (`SpaceBookingDB_Phase2`).

---

## 2. Reference Files

Consumed in precedence order (later overrides earlier on conflict, per the Step 13 instructions):

| Precedence | File | Role in this artifact |
|---|---|---|
| 1 | `outputs/12-concurrency-implementation-G02.sql` | The stored procedures **under test**. Every test invokes exactly these objects with their exact signatures, error numbers, and lock resources. |
| 2 | `outputs/11-concurrency-design-G02.md` | The two concurrency errors (Step 11 §2.1, §2.2), the invariants they violate, and the transaction specifications (§4.1, §4.2, §4.3) the procedures translate. |
| 3 | `outputs/10-schema-migration-G02.sql` | The target schema: table names, columns, `CHECK`/enum literals, and the trigger set the procedures run on top of. |
| 4 | `outputs/06-sample-data-G02.sql` | The real entity IDs, space codes, capacity values, and enum literals used by the test scenarios (migrated into `SpaceBookingDB_Phase2` by Step 10). |
| — | `outputs/11-reproduce-concurrency-error1-G02.sql` / `...-error2-G02.sql` | The exact race interleavings that this artifact re-runs through the procedures. |

No identifier in this document or in the test script was invented: every user id, space code, capacity, purpose type, status literal, and error number is sourced from the files above.

**Why the escalation test uses space `C301` and not `A101`:** Step 11 §2.2 reproduced Error 2 on `A101`. However, the *migrated* Phase 2 data (Step 10 §3.9) already contains an open-ended active `out_of_service` maintenance record on `A101` (`space_maintenance_id = 6`, `start_time = 2026-06-28 09:00`, `completion_time = NULL`, `status = 'reported'`). Any approval on `A101` would therefore be rejected by the blocking-state check *independently of the escalation race*, which would mask the guard behaviour under test. The test therefore exercises the same escalation-vs-approval race on `C301` (Computer Lab Alpha), which is clean in the migrated data (no active maintenance) but is otherwise identical in procedure behaviour. The scenario geometry (pending booking 14:00–16:00, advisory maintenance 13:00–∞) is preserved from the Step 11 reproduction.

---

## 3. Test Matrix

For each Step 11 error: the invariant violated, the procedures involved, and the expected (correct) outcome when the guard is in place.

### 3.1. Test 1 — Concurrent instant booking double allocation (Error 1)

- **Step 11 reference:** §2.1 (error), §4.1 (`sp_SubmitSpaceBooking` specification).
- **Invariant verified:** BR-01 / BR-12 (overlap prevention). Re-stated in Step 11 §1.2 rule 1.
- **Procedure under test:** `dbo.sp_SubmitSpaceBooking` only.
- **Scenario (real sample values):** space `B201` (Lecture Room 201, classroom, capacity 60, `current_status = 'available'`), requester user 4 (Hoàng Thị Mai, lecturer) and user 5 (Trương Minh Tâm, student), target window `2026-09-10 10:00–12:00`.
- **Precondition:** `SpaceTypeBookingPolicy.instant_booking_eligible = 1` for `classroom` (BR-11 instant eligibility; mirrors the Step 11 reproduction setup).
- **Interleaving re-run (Step 11 §2.1):** in the un-isolated reproduction, Session A and Session B both read `OverlapCount = 0` and both commit an `approved` instant booking. Through the procedure, Session 1's submission acquires `Lock_Space_B201`, commits its `approved` booking, and releases the lock; Session 2's submission then acquires the same lock, re-runs the overlap check, sees Session 1's committed booking, and throws.
- **Expected outcome (guard in place):** Session 1 returns `status = 'approved'` with a valid `space_booking_id`; Session 2 is rejected with error **50008** (`BR-01/BR-12 violation: an approved booking already overlaps the requested period for this space`); exactly **one** approved-lifecycle booking overlaps the window.

### 3.2. Test 2 — Staff approval racing maintenance escalation (Error 2)

- **Step 11 reference:** §2.2 (error), §4.2 (`sp_ApproveSpaceBooking`), §4.3 (`sp_EscalateSpaceMaintenance`).
- **Invariant verified:** BR-02 / BR-09 (maintenance blocking). Re-stated in Step 11 §1.2 rule 2.
- **Procedures under test:** `dbo.sp_ApproveSpaceBooking` + `dbo.sp_EscalateSpaceMaintenance`.
- **Scenario (real sample values):** space `C301` (Computer Lab Alpha, computer_lab, capacity 40, `current_status = 'available'`), pending booking for user 5 (`seminar`, 30 participants) `2026-09-15 14:00–16:00`; advisory `SpaceMaintenance` on `C301` (reporter user 4, assigned staff user 3, `start_time 2026-09-15 13:00`, open-ended, `status = 'in_progress'`).
- **Interleaving re-run (Step 11 §2.2):** in the un-isolated reproduction, Session A (approval) reads `OutOfServiceMaintCount = 0`, Session B escalates the advisory record to `out_of_service` and commits, then Session A approves the booking anyway. Through the procedures, the escalation operation (Session B) and the approval operation (Session A) contend on the **same** application lock `Lock_Space_C301`; whichever commits first determines the outcome. This test drives the order in which the escalation commits first and the approval runs second.
- **Expected outcome (guard in place):** the escalation succeeds (`C301` becomes `under_maintenance`, `impact_level = 'out_of_service'`, `affected_count = 0` because the booking is still pending); the approval is rejected with error **50017** (`BR-02/BR-09 violation: space is under out-of-service maintenance overlapping the booking period`); the booking remains `pending`.

### 3.3. Test 2b — Reverse ordering: approval commits before escalation (supplementary, BR-14)

- **Step 11 reference:** §4.3 step 6 (escalation identifies affected approved/checked-in bookings for staff outreach).
- **Invariant verified:** BR-14 (escalation impact analysis) plus the complementary lock-ordering behaviour of §3.3.
- **Procedures under test:** `dbo.sp_ApproveSpaceBooking` + `dbo.sp_EscalateSpaceMaintenance` (same two as Test 2).
- **Scenario:** continuation of Test 2 after the maintenance has been downgraded back to `advisory` (restoring `C301` to `available`). The approval runs **first** and commits; the escalation runs **second**.
- **Expected outcome (guard in place):** the approval succeeds (booking `approved`, `BookingApproval` row created — there is no `out_of_service` maintenance yet); the escalation then succeeds, fires `trg_SpaceMaintenance_UpdateSpaceStatus` (set `C301` to `under_maintenance`), and returns `affected_count = 1` with the approved booking in the result set, so staff receive the correct BR-14 outreach list. This demonstrates that the guard does not merely reject one side of the race but yields the correct outcome for *both* orderings.

---

## 4. Test Results (Observed)

The table below records the **observed** outcome of executing `outputs/13-concurrency-tests-G02.sql` against a freshly migrated and freshly provisioned `SpaceBookingDB_Phase2` (DBMS: Microsoft SQL Server 2022, build 16.0.4255.1). "Observed" results are the literal console output of the executed test script on **2026-08-03**; they are not assumed.

| Test | Procedure calls executed | Guard result observed | Invariant outcome observed |
|---|---|---|---|
| Test 1 (E1) | `sp_SubmitSpaceBooking` (user 4) then `sp_SubmitSpaceBooking` (user 5) on `B201` 2026-09-10 10:00–12:00 | First call succeeded → `approved`, booking id returned. Second call rejected with error **50008** (BR-01/BR-12). | Exactly **1** approved-lifecycle booking overlaps the window; no double allocation. |
| Test 2 (E2) | `sp_EscalateSpaceMaintenance` (staff 3) then `sp_ApproveSpaceBooking` (staff 2) on `C301` 2026-09-15 14:00–16:00 | Escalation succeeded → `impact_level = out_of_service`, `C301 = under_maintenance`, `affected_count = 0`. Approval rejected with error **50017** (BR-02/BR-09). | Booking remains `pending`; **no** approved booking overlaps `out_of_service` maintenance. |
| Test 2b | `sp_ApproveSpaceBooking` (staff 2) then `sp_EscalateSpaceMaintenance` (staff 2) on the same `C301` booking | Approval succeeded → booking `approved`. Escalation succeeded → `affected_count = 1`, result set contained the approved booking. | BR-14 outreach list returned the approved booking; `C301 = under_maintenance`. |

Supporting evidence captured from the test run:

```
TEST 1 PASSED: conflicting instant submission rejected (error 50008) and only 1 active booking overlaps B201 window.
TEST 2 PASSED: approval rejected (error 50017); booking still pending; C301 under out_of_service maintenance.
TEST 2B PASSED: reverse ordering — approval committed, escalation flagged 1 affected booking (BR-14).
```

### 4.1. Evidence of the guard's serialization under genuine concurrency

As a supplementary check, the two conflicting operations of Test 1 were also executed from two **simultaneous** SQL Server sessions (two `sqlcmd` connections started concurrently, no `WAITFOR`). The observed output was:

```
SESSION A -> booking_id=13, status=approved
SESSION B -> REJECTED error 50008: BR-01/BR-12 violation: an approved booking already overlaps the requested period for this space.
```

and the follow-up invariant query returned `overlapping_active_bookings = 1`. The outcome was deterministic and identical to the scripted run: exactly one session returned `approved`; the other session was rejected with error **50008** and its transaction rolled back. This confirms that the rejection is caused by the guard (application lock serialization + re-check) and not merely by the sequential order of the script.

---

## 5. Run Instructions

The run instructions live **in this document only**; the test script does not duplicate them.

### 5.1. Prerequisites

Run the following in order to obtain the exact target state the tests assume:

1. `outputs/05-db-definition-G02.sql` — creates the Phase 1 source database `SpaceBookingDB`.
2. `outputs/06-sample-data-G02.sql` — populates `SpaceBookingDB` with the sample data.
3. `outputs/10-schema-migration-G02.sql` — creates and populates the Phase 2 target `SpaceBookingDB_Phase2`.
4. `outputs/12-concurrency-implementation-G02.sql` — creates `dbo.sp_SubmitSpaceBooking`, `dbo.sp_ApproveSpaceBooking`, and `dbo.sp_EscalateSpaceMaintenance` in `SpaceBookingDB_Phase2`.

### 5.2. Executing the test script

Run the single file `outputs/13-concurrency-tests-G02.sql` against `SpaceBookingDB_Phase2`. It is self-contained and re-runnable:

- each test section re-establishes its own precondition (including enabling classroom instant booking for Test 1) and cleans up its own rows;
- expected failures are exercised through the real procedures inside `TRY/CATCH` so that the script itself terminates cleanly on a pass;
- every assertion that fails raises a `THROW` with a distinctive message, so a pass/fail is explicit in the output.

Example (sqlcmd):

```
sqlcmd -S localhost -U sa -P '<password>' -C -d SpaceBookingDB_Phase2 -i outputs/13-concurrency-tests-G02.sql
```

A **PASS** requires, per test:

- **Test 1:** `PRINT 'TEST 1 PASSED ...'` appears; error `50008` was captured from the second submission; the assertion query returns exactly one overlapping active booking.
- **Test 2:** `PRINT 'TEST 2 PASSED ...'` appears; error `50017` was captured from the approval; the booking is still `pending`; `C301.current_status = 'under_maintenance'`; no approved booking overlaps the maintenance interval.
- **Test 2b:** `PRINT 'TEST 2B PASSED ...'` appears; the escalation returned `affected_count = 1` and its result set contained the approved booking id.

### 5.3. Optional genuine two-session interleaving

To reproduce the Step 11 interleaving with real concurrent connections (two SSMS query windows or two `sqlcmd` processes), re-enable the Test 1 precondition, then start both sessions at the same time:

1. **Precondition (one session):** `UPDATE SpaceTypeBookingPolicy SET instant_booking_eligible = 1 WHERE space_type = 'classroom';` and delete any leftover `B201` test rows for `2026-09-10 10:00`.
2. **Session A:** `EXEC dbo.sp_SubmitSpaceBooking` for `B201` 2026-09-10 10:00–12:00 (user 4).
3. **Session B (started simultaneously):** `EXEC dbo.sp_SubmitSpaceBooking` for the same `B201` window (user 5).
4. **Observed (recorded in §4.1):** one session returns `approved`; the other is rejected with **50008** (the guard's own overlap error) because the two submissions serialize on `Lock_Space_B201`. If the second call arrives while the first still holds the lock for more than 5 s, it instead throws **50003** (system busy).
5. **Verify:** exactly one approved-lifecycle booking exists for the window; then clean up the test rows and restore the classroom policy to `0`.

Either rejection path yields the same invariant: at most one approved booking per overlapping window.

---

## 6. Traceability Matrix

Every entry below is sourced from the actual documents in scope (Step 11 §2.1, §2.2, §4.1, §4.2, §4.3; Step 12 traceability block; Step 09 rule identifiers). No rule IDs or section numbers were invented.

| Test section (script) | Concurrency error | Invariant verified | Design-doc section |
|---|---|---|---|
| Test 1 (section `TEST 1` in `13-concurrency-tests-G02.sql`) | Error 1 — concurrent instant-booking double allocation (Step 11 §2.1) | BR-01 / BR-12 (overlap prevention, Step 11 §1.2 rule 1) | 11 §2.1 (reproduction), 11 §4.1 (procedure spec) |
| Test 2 (section `TEST 2` in `13-concurrency-tests-G02.sql`) | Error 2 — staff approval racing maintenance escalation (Step 11 §2.2) | BR-02 / BR-09 (maintenance blocking, Step 11 §1.2 rule 2) | 11 §2.2 (reproduction), 11 §4.2 + §4.3 (procedure specs) |
| Test 2b (section `TEST 2B` in `13-concurrency-tests-G02.sql`) | Complementary ordering of Error 2 (approval commits before escalation) | BR-14 (escalation impact analysis, Step 11 §4.3 step 6) | 11 §4.3 (escalation spec), 11 §3.3 (lock-ordering rule) |

**Error-number provenance:** `50008` and `50017` are the literal `THROW` codes emitted by `dbo.sp_SubmitSpaceBooking` (12 `:155`) and `dbo.sp_ApproveSpaceBooking` (12 `:298`), respectively; `50003`/`50016`/`50024` are the applock-busy codes. The test assertions assert these exact numbers so that a pass means the guard's own error was raised — not a different failure.
