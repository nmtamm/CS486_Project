# Step 10 — Schema Migration (Analytical Process)

**Group:** G02

**Artifact:** `10-schema-migration-G02.sql`

**DBMS:** Microsoft SQL Server

**Generation date:** 2026-08-02

---

## 1. Objective

Create a **new database implementation** of the Campus Space Management System based on the updated logical design and ERD (`outputs/09-updated-erd-and-logical-design-G02.md`), then migrate **all applicable data** from the Phase 1 database into the new schema.

The Phase 1 database (`SpaceBookingDB`) is **read-only source data** in this step. It is never modified. The Phase 2 schema is built in a new database, `SpaceBookingDB_Phase2`, so both databases can coexist on the same server while the migration runs. All subsequent Phase 2 artifacts (Steps 11–16) must run against `SpaceBookingDB_Phase2`.

---

## 2. Reference Files

| Purpose | File |
|---|---|
| Current (Phase 1) database definition | `outputs/05-db-definition-G02.sql` |
| Current (Phase 1) sample data | `outputs/06-sample-data-G02.sql` |
| Database implementation instruction | `.opencode/skills/db-design-pipeline/step-05-database-implementation/INSTRUCTION.md` |
| Sample data generation instruction | `.opencode/skills/db-design-pipeline/step-06-sample-data/INSTRUCTION.md` |
| Updated ERD and logical design | `outputs/09-updated-erd-and-logical-design-G02.md` |

---

## 3. Analysis of the Existing (Phase 1) Database

### 3.1. Existing tables, keys, and relationships

The Phase 1 schema (`05-db-definition-G02.sql`) contains 7 tables:

| Table | PK | FKs | Uniqueness / Checks (summary) |
|---|---|---|---|
| `CampusUser` | `campus_user_id` | — | `UNIQUE (email)`; role / account_status CHECKs |
| `CampusSpace` | `campus_space_code` | — | `UNIQUE (building, floor, room_number)`; space_type / current_status / capacity CHECKs |
| `CampusFacility` | `campus_facility_id` | → `CampusSpace` | `UNIQUE (facility_name)`; status CHECK |
| `SpaceBooking` | `space_booking_id` | → `CampusUser`, `CampusSpace` | purpose_type / status / expected_participants / time-interval CHECKs |
| `BookingApproval` | `booking_approval_id` | → `SpaceBooking`, `CampusUser` | `UNIQUE (space_booking_id)`; decision / rejection_reason CHECKs |
| `SpaceUsageSession` | `space_usage_session_id` | → `SpaceBooking`, `CampusUser` | `UNIQUE (space_booking_id)` |
| `SpaceMaintenance` | `space_maintenance_id` | → `CampusSpace`, `CampusUser` (×2) | problem_type / status CHECKs |

### 3.2. Existing triggers (Phase 1)

| Trigger | Enforces | Notes |
|---|---|---|
| `trg_SpaceBooking_NoOverlap` | BR-01 overlap | Phase 1 trigger on `SpaceBooking` |
| `trg_SpaceBooking_StatusTransition` | BR-03 | `pending → approved/rejected/cancelled → checked_in → completed/no-show` |
| `trg_SpaceBooking_CapacityCheck` | BR-07 | capacity cross-table check |
| `trg_SpaceMaintenance_UpdateSpaceStatus` | Issue 3 | maintains `CampusSpace.current_status` |

### 3.3. Existing sample data (`06-sample-data-G02.sql`)

| Table | Rows | Notable content |
|---|---|---|
| `CampusUser` | 8 | 2 facility staff, 1 facility manager, 1 lecturer, 2 students, 1 TA, 1 department admin |
| `CampusSpace` | 8 | 4 space types across buildings A–E; statuses include `available`, `in_use`, `temporarily_closed`, `under_maintenance`, `retired` |
| `CampusFacility` | 6 | `facility_name` values: Projector, Whiteboard, Microphone, Computer, Air Conditioner, Speaker System; all rows inserted without `campus_space_code` (NULL) |
| `SpaceBooking` | 10 | Final statuses: 1 `completed`, 2 & 3 `checked_in`, 4 `pending`, 5 `rejected`, 6 `cancelled`, 7 `no-show`, 8 `pending`, 9 `approved`, 10 `pending` |
| `BookingApproval` | 6 | 5 approved, 1 rejected (with `rejection_reason`) |
| `SpaceUsageSession` | 4 | sessions for bookings 1, 2, 3, 7 |
| `SpaceMaintenance` | 6 | problem types include `broken_projector` (2 rows), `ac_failure`, `network`, `cleaning`, `damaged_furniture`, `other`; statuses `in_progress`, `completed`, `reported` |

---

## 4. Analysis of the Updated Schema

Source: `outputs/09-updated-erd-and-logical-design-G02.md`, Sections 2 (Design Decisions and Change Summary), 3.2 (Entity Change Descriptions), 4.2 (Relation Definitions), 4.3 (Key and Integrity Constraint Summary).

### 4.1. Newly introduced entities

| Entity | Purpose | Key attributes |
|---|---|---|
| `SpaceTypeBookingPolicy` | Configures, per space type, whether instant booking is eligible (BR-11) | `space_type` PK, `instant_booking_eligible BIT DEFAULT 0`, `policy_note` |
| `Semester` | Reference relation for semester-based reports (Phase 2 §1.3) | `semester_id` PK, `academic_year`, `semester_no`, `semester_name`, `start_date`, `end_date`, `UK (academic_year, semester_no)` |
| `FacilityMaintenance` | Facility-level maintenance with impact level and notification status (BR-13) | `facility_maintenance_id` PK, FKs to `CampusFacility`/`CampusUser`, `impact_level DEFAULT 'advisory'`, `notify_status DEFAULT 'nothing_to_notify'` |

### 4.2. Modified entities

| Entity | Change | New / changed constraints |
|---|---|---|
| `CampusSpace` | `space_type` becomes FK → `SpaceTypeBookingPolicy.space_type` | FK (R11); same space_type domain CHECK |
| `CampusFacility` | `facility_name` renamed → `facility_type`; `description` widened to `NVARCHAR(MAX)`; `status` widened to `NVARCHAR(30)` | `UNIQUE (facility_type)`; same status CHECK |
| `SpaceBooking` | New attributes `is_instant_booking BIT NOT NULL DEFAULT 0` and `advisory_acknowledged BIT NOT NULL DEFAULT 1` | `CHECK (is_instant_booking IN (0,1))`; `CHECK (advisory_acknowledged IN (0,1))`; `purpose_type` widened to `NVARCHAR(40)` |
| `SpaceMaintenance` | New attribute `impact_level`; new `notify_status` (Step 10 addition, see §7); `problem_type` domain reduced (removed `broken_projector`); interval consistency rules | `impact_level CHECK IN ('out_of_service','advisory')` default `out_of_service`; `notify_status CHECK IN ('nothing_to_notify','updated_to_advisory','updated_to_out_of_service')` default `nothing_to_notify`; `problem_type CHECK IN ('ac_failure','damaged_furniture','cleaning','network','other')`; `completion_time IS NULL OR completion_time > start_time`; `status='completed' ⇒ completion_time IS NOT NULL`; `status IN ('reported','in_progress') ⇒ completion_time IS NULL` |

### 4.3. Unchanged entities

`CampusUser`, `BookingApproval`, `SpaceUsageSession` are unchanged (09 §4.2: "Unchanged relations retain their Phase 1 definitions exactly as implemented in 05-db-definition-G02.sql").

### 4.4. Removed objects

- No entity is removed.
- One attribute domain value is removed: `SpaceMaintenance.problem_type = 'broken_projector'`.
- Phase 1 trigger `trg_SpaceBooking_NoOverlap` (BR-01) is **not** recreated: 09 §4.3 and §6 explicitly defer the **overlap invariant** (BR-01/BR-12) to the transactional concurrency implementation (Steps 11–13). Recreating a plain trigger here would duplicate — and partially conflict with — that protected implementation. The **space-availability check** (BR-02/BR-09) is enforced here inside TRG-02's insert logic via `fn_IsSpaceAvailable` (see §7) so that an unavailable space rejects a new booking at insertion; the approval-time availability check is performed by the protected procedure `sp_ApproveSpaceBooking` (11 §4.2, 12 §3.2) and the `BookingApproval` trigger (§7), and is **not** re-implemented as a separate approval trigger.

---

## 5. Old-to-New Mapping Table

Per-table decision and rationale (each maps back to 09 §3.2 / §4.2):

| Old (Phase 1) | New (Phase 2) | Action | Rationale / traceability |
|---|---|---|---|
| `CampusUser` | `CampusUser` | **Keep** (copy data) | Unchanged relation (09 §4.2) |
| `CampusSpace` | `CampusSpace` | **Keep + modify** | New FK to `SpaceTypeBookingPolicy` (09 §3.2 CampusSpace); data copied unchanged |
| `CampusFacility` | `CampusFacility` | **Keep + rename attribute** | `facility_name → facility_type` (09 §4.2 CampusFacility) |
| `SpaceBooking` | `SpaceBooking` | **Keep + modify** | New `is_instant_booking` and `advisory_acknowledged` (09 §3.2 SpaceBooking) |
| `BookingApproval` | `BookingApproval` | **Keep** (copy data) | Unchanged (09 §4.2) |
| `SpaceUsageSession` | `SpaceUsageSession` | **Keep** (copy data) | Unchanged (09 §4.2) |
| `SpaceMaintenance` | `SpaceMaintenance` | **Keep + modify** | New `impact_level`; new `notify_status` (Step 10 addition, §7); `problem_type` domain reduced (09 §3.2 SpaceMaintenance) |
| — | `SpaceTypeBookingPolicy` | **New (seed config)** | 09 §3.2 SpaceTypeBookingPolicy |
| — | `Semester` | **New (seed reference)** | 09 §3.2 Semester |
| — | `FacilityMaintenance` | **New (empty)** | No Phase 1 facility-maintenance data (09 §3.2 FacilityMaintenance) |

---

## 6. Migration Strategy

### 6.1. Column-level decisions

| Old column | New column | Decision |
|---|---|---|
| `CampusFacility.facility_name` | `CampusFacility.facility_type` | **Rename** (same values, same UK) |
| — | `SpaceBooking.is_instant_booking` | **Generate default value** `0` (Phase 1 had no instant-booking path; every migrated booking used the staff workflow) |
| — | `SpaceBooking.advisory_acknowledged` | **Generate default value** `1` (T6, §6.2) — `sp_SubmitSpaceBooking` always informs the requester of facility availability before finalizing a booking, so every booking records the acknowledgement (BR-13) |
| — | `SpaceMaintenance.impact_level` | **Generate default value** `'out_of_service'` (09 §10: existing maintenance blocked booking, which equals Phase 2 `out_of_service`) |
| — | `SpaceMaintenance.notify_status` | **New mandatory column (Step 10 addition, see §7)** — generated during migration by transform T5 (§6.2) so that migrated rows already match the `trg_SpaceMaintenance_UpdateSpaceStatus` mapping; maintained thereafter by that trigger |
| — | `FacilityMaintenance.*` | **No migration** — new entity, empty |
| `SpaceMaintenance.problem_type = 'broken_projector'` | `'other'` | **Derive from existing data / remap** — `broken_projector` was removed from the Phase 2 domain (09 §4.2) |
| `SpaceBooking.purpose_type NVARCHAR(30)` | `NVARCHAR(40)` | **Convert datatype** (widening, no data change) |
| `CampusFacility.description NVARCHAR(255)` | `NVARCHAR(MAX)` | **Convert datatype** (widening, no data change) |
| `CampusFacility.status NVARCHAR(20)` | `NVARCHAR(30)` | **Convert datatype** (widening, no data change) |

All other columns are copied as-is with their original values.

### 6.2. Data transformations applied during migration

| # | Transformation | SQL implementation | Verifiable in old data |
|---|---|---|---|
| T1 | Rename `facility_name → facility_type` | SELECT column alias in insert | 6 facility rows |
| T2 | Set `is_instant_booking = 0` for all bookings | `CAST(0 AS BIT)` constant | 10 booking rows |
| T3 | Set `impact_level = 'out_of_service'` for all space-maintenance records | constant `N'out_of_service'` | 6 maintenance rows |
| T4 | Remap `problem_type` `'broken_projector' → 'other'` | `CASE WHEN ... THEN 'other' ELSE ... END` | 2 affected rows |
| T5 | Set `SpaceMaintenance.notify_status` to the `trg_SpaceMaintenance_UpdateSpaceStatus` mapping | `CASE WHEN status IN ('reported','in_progress') THEN 'updated_to_out_of_service' ELSE 'nothing_to_notify' END` (all migrated rows are `out_of_service` per T3) | 6 maintenance rows |
| T6 | Set `advisory_acknowledged = 1` for all migrated bookings | `CAST(1 AS BIT)` constant (every migrated booking records that the requester was informed — the acknowledgement required by BR-13) | 10 booking rows |

### 6.3. Default value insertion for newly introduced mandatory attributes

| Table | Attribute | Default used in migration | Source of decision |
|---|---|---|---|
| `SpaceBooking` | `is_instant_booking` | `0` | 09 §3.2 SpaceBooking; Phase 1 had only staff approval |
| `SpaceBooking` | `advisory_acknowledged` | `1` | 09 §3.2 SpaceBooking; BR-13 — the requester is always informed at submission, so the acknowledgement is recorded for every booking |
| `SpaceMaintenance` | `impact_level` | `'out_of_service'` | 09 §10 — Phase 1 behaviour (maintenance blocks booking) |
| `SpaceMaintenance` | `notify_status` | `'nothing_to_notify'`; active rows overwritten to `'updated_to_out_of_service'` by T5 | §7 — trigger-maintained attribute mirroring `FacilityMaintenance.notify_status`; column default covers the mandatory attribute, T5 aligns migrated rows with the trigger mapping |
| `FacilityMaintenance` | `impact_level` / `status` / `notify_status` | table defaults (`'advisory'` / `'reported'` / `'nothing_to_notify'`) | 09 §4.2 FacilityMaintenance — table empty, defaults cover the mandatory attributes |
| `SpaceTypeBookingPolicy` | `instant_booking_eligible` | seeded `0` for all 4 space types | 09 §3.2 / §10 — manager opts in later |
| `Semester` | (all attributes) | seeded reference rows | 09 §3.2 Semester — 3 academic years |

### 6.4. Removed objects handling

- `SpaceMaintenance.problem_type = 'broken_projector'`: not recreated; affected rows remapped to `'other'` (reusable information is preserved, T4).
- No old table or column is left behind or recreated for backward compatibility.

---

## 7. Implementation of the New Schema

The new schema is built from scratch in `SpaceBookingDB_Phase2`, exactly as defined in 09 §4.2, using the Step 5 implementation conventions (inline `PRIMARY KEY`, `CHECK`, `UNIQUE`, and `FOREIGN KEY` declarations; `GO` batch separators).

Creation order (dependency order, referenced tables first):

1. `SpaceTypeBookingPolicy` — no FKs
2. `CampusUser` — no FKs
3. `CampusSpace` — FK → `SpaceTypeBookingPolicy`
4. `CampusFacility` — FK → `CampusSpace`
5. `Semester` — no FKs
6. `SpaceBooking` — FKs → `CampusUser`, `CampusSpace`
7. `BookingApproval` — FKs → `SpaceBooking`, `CampusUser`
8. `SpaceUsageSession` — FKs → `SpaceBooking`, `CampusUser`
9. `SpaceMaintenance` — FKs → `CampusSpace`, `CampusUser`
10. `FacilityMaintenance` — FKs → `CampusFacility`, `CampusUser`

Triggers created on the new schema (Step 10 scope — see §4.4 for what is intentionally deferred):

| Trigger | Enforces | Adaptation for Phase 2 |
|---|---|---|
| `trg_SpaceBooking_StatusTransition` | BR-03 (+ BR-02/BR-09, BR-11) | INSERT rule: staff booking must be `pending`, instant booking (`is_instant_booking = 1`) must be `approved` at submission **and** its space type must be instant-booking eligible in `SpaceTypeBookingPolicy` (BR-11); in addition the space must be available — `fn_IsSpaceAvailable` rejects any insert whose space is `temporarily_closed`/`retired` or under an active `out_of_service` maintenance interval (from `SpaceMaintenance` or `FacilityMaintenance`) overlapping the window (BR-02/BR-09, the former separate `trg_SpaceBooking_AvailabilityCheck_Insert` role, see §7 notes). UPDATE rule extended: a booking may only become `approved` while its space is bookable — not `temporarily_closed`/`retired`, and not under an active `out_of_service` `FacilityMaintenance` interval overlapping the booking window (BR-02/BR-09, Step 10 additions, see §7 notes) |
| `trg_SpaceBooking_CapacityCheck` | BR-07 | unchanged |
| `trg_SpaceMaintenance_UpdateSpaceStatus` | Phase 1 Issue 3 (convenience) + Step 10 addition (notify) | refined: the space status is derived from **both** maintenance sources — only **active** maintenance with `impact_level = 'out_of_service'` sets `CampusSpace.current_status = 'under_maintenance'`; advisory maintenance does not. An affected space is restored to `available` only when **neither** `SpaceMaintenance` nor `FacilityMaintenance` has an active `out_of_service` record (see `trg_FacilityMaintenance_UpdateSpaceStatus`). **Additionally** keeps `SpaceMaintenance.notify_status` in sync with the record's own `status` / `impact_level`: active + `out_of_service` → `updated_to_out_of_service`, active + `advisory` → `updated_to_advisory`, `completed`/`cancelled` → `nothing_to_notify` |
| `trg_FacilityMaintenance_UpdateSpaceStatus` | Phase 1 Issue 3 (convenience) applied to facilities + Step 10 addition (notify) | **new (AFTER INSERT, UPDATE)** — mirrors `trg_SpaceMaintenance_UpdateSpaceStatus` for facility maintenance: on insert/update it traverses the **whole** `FacilityMaintenance` table for the affected space(s); if any active `out_of_service` record exists for a facility owned by the space, the space is set to `under_maintenance` (preserving `temporarily_closed`/`retired`), otherwise it is restored to `available` only when **neither** `FacilityMaintenance` nor `SpaceMaintenance` has an active `out_of_service` record. Also keeps `FacilityMaintenance.notify_status` in sync with the record's own `status`/`impact_level` (same mapping as `trg_SpaceMaintenance_UpdateSpaceStatus`). Advisory maintenance never makes the space unavailable |
| `trg_BookingApproval_UpdateBookingStatus` | BR-03 (decision ↔ status consistency) | **new (AFTER INSERT, UPDATE)** — on a staff decision recorded in `BookingApproval`, sets the referenced booking's status to match `decision` (`approved` → `approved`, `rejected` → `rejected`). This trigger is the **single** point that syncs `SpaceBooking.status`: `sp_ApproveSpaceBooking` (12 §3.2) records only the `BookingApproval` row, so the sync runs inside the procedure's app-locked transaction. For `approved` it first re-validates availability with the shared function `fn_IsSpaceAvailable` (the same guard the procedure uses under the lock, §7). The status `UPDATE` re-fires `trg_SpaceBooking_StatusTransition` (TRG-02), which validates the transition and rejects an approval recorded against a booking that is no longer `pending` (BR-03 rollback) |

**`trg_FacilityMaintenance_UpdateSpaceStatus` design note (new):** no third trigger is needed. Both maintenance triggers — `trg_SpaceMaintenance_UpdateSpaceStatus` (TRG-04) on `SpaceMaintenance` and this trigger (TRG-06) on `FacilityMaintenance` — derive the affected space's `current_status` from **both** sources, so a change on either maintenance table re-derives the space status. Each trigger's space-status `UPDATE`s target `CampusSpace` (never its own table) and only write when the derived status differs. `FacilityMaintenance.notify_status` is maintained by this trigger with the same derivation mapping as TRG-04 (active + `out_of_service` → `updated_to_out_of_service`, active + `advisory` → `updated_to_advisory`, closed → `nothing_to_notify`); that `UPDATE` is a no-op when the value already matches, so it does not re-fire the trigger.

**`trg_SpaceMaintenance_UpdateSpaceStatus` notify design note:** `SpaceMaintenance.notify_status` mirrors `FacilityMaintenance.notify_status` (09 §4.2) with the same domain (`nothing_to_notify`, `updated_to_advisory`, `updated_to_out_of_service`). For space maintenance the attribute is maintained exclusively by this trigger, which derives it from the record's own `status` / `impact_level` (active + `out_of_service` → `updated_to_out_of_service`, active + `advisory` → `updated_to_advisory`, closed → `nothing_to_notify`). The trigger only writes the row when the derived value differs, so its own `UPDATE` is a no-op — and therefore does not re-fire — once `notify_status` is already consistent.

**Availability-check design note (in TRG-02):** the insert-time availability check enforces the rule defined in 09 §6 (BR-02/BR-09): a space is unavailable if it is `temporarily_closed`/`retired`, or an active `out_of_service` maintenance interval — from **either** `SpaceMaintenance` or `FacilityMaintenance` (a facility owned by the space) — overlaps the requested booking window (half-open interval `[start, end)`). The `FacilityMaintenance` clause is a Step 10 addition: previously an out-of-service facility maintenance set the space's `current_status` to `under_maintenance` (TRG-06) but was never consulted by the booking-availability logic, so a space whose facility was out of service remained bookable. Advisory maintenance never blocks booking. The check is implemented inside TRG-02's `AFTER INSERT` logic (calling `fn_IsSpaceAvailable`, which also powers `sp_SubmitSpaceBooking` and the `BookingApproval` trigger) so that `SCOPE_IDENTITY()` keeps working for callers such as `sp_SubmitSpaceBooking` (Step 12); it replaces the standalone `trg_SpaceBooking_AvailabilityCheck_Insert` originally drafted for this role. The booking-overlap invariant (BR-01/BR-12) remains deferred to the concurrency implementation (Steps 11–13) per 09 §4.3.

**Approval-precondition design note (Step 10 additions, in TRG-02):** two data-level guards close gaps that existed when a booking moves to `approved`. (1) *Space state (BR-02):* a booking may not become `approved` while the space is `temporarily_closed`/`retired` — previously only submission-time (`sp_SubmitSpaceBooking`, 12 §3.1) and insert-time checked this, so a space closed between submission and approval could still be approved. (2) *Facility maintenance (BR-02/BR-09):* a booking may not become `approved` while an active `out_of_service` `FacilityMaintenance` interval overlaps the booking window — the approval path previously never consulted `FacilityMaintenance`. Both checks fire inside TRG-02's `UPDATE` logic only when the status actually changes to `approved`. They are consistent with — not complementary to — `sp_ApproveSpaceBooking`: the procedure now re-checks availability with the same shared function `fn_IsSpaceAvailable` (covering closed/retired, either maintenance source, and overlap; error 50017, 12 §3.2), and `trg_BookingApproval_UpdateBookingStatus` re-validates availability before syncing the status. TRG-02's precondition remains the data-level guard for any path that moves a booking to `approved`, including the `BookingApproval`-driven status `UPDATE` (TRG-07).

**Instant-eligibility design note (Step 10 addition, in TRG-02):** BR-11 (09 §5) makes `SpaceTypeBookingPolicy.instant_booking_eligible` the sole authority for whether a booking may be auto-approved. `sp_SubmitSpaceBooking` consults the policy, but a direct `INSERT` of an instant booking (`is_instant_booking = 1`) previously bypassed that lookup. TRG-02's INSERT check now rejects any instant booking whose space type is not configured eligible (or whose policy row is missing). This is a point lookup of configuration data, so it does not re-introduce the deferred overlap invariant (BR-01/BR-12): a direct insert of an *eligible* instant booking still relies on `sp_SubmitSpaceBooking` for overlap protection, exactly as documented in §4.4.

**Concurrency impact of the Step 10 additions (items 4–6):** none of the three additions alters the concurrency architecture. They add only point/range *reads* of `CampusSpace`, `SpaceTypeBookingPolicy`, and `FacilityMaintenance` inside triggers that fire within the already app-locked transactions (`sp_SubmitSpaceBooking`, `sp_ApproveSpaceBooking`), respecting the 11 §3.3 lock hierarchy (space lock acquired before child-row reads). They do not re-implement the overlap invariant (BR-01/BR-12) and do not take new lock types. Availability at approval is checked by the procedure and by the `BookingApproval` trigger through the **same shared function** `fn_IsSpaceAvailable` (12 §3.2, §7), so no new logic is introduced. The one residual caveat is unchanged from the existing design: writes to `FacilityMaintenance` are not routed through a protected procedure and therefore do not take the per-space application lock, so the new trigger checks are as strong as the transaction they fire inside and inherit the same phantom-race window as the existing `SpaceMaintenance` checks for operations that bypass the procedures. No deadlock ordering or lock-type change is introduced.

**`trg_BookingApproval_UpdateBookingStatus` design note (new):** 09 §5 (BR-03) requires `BookingApproval.decision` to remain consistent with `SpaceBooking.status`. `sp_ApproveSpaceBooking` (12 §3.2) records **only** the staff decision row and never updates `SpaceBooking.status` itself, so this trigger is the single point that syncs the booking status to the recorded `decision` on `INSERT`/`UPDATE` of `BookingApproval`. The procedure path and a direct `INSERT` (which would otherwise leave the booking stuck at `pending`) therefore behave identically. For the procedure path the sync runs inside the app-locked transaction, so it is protected by the same per-space lock as the procedure's availability guard. For an `approved` decision the trigger first re-validates availability with the shared function `fn_IsSpaceAvailable` — the same guard the procedure calls under the lock — so an approval cannot surface a booking into an unavailable space through either path. The status `UPDATE` re-fires TRG-02, which enforces the BR-03 transition rule: a `pending` booking may move to `approved`/`rejected` (valid), whereas an approval recorded against a booking that has already moved past `pending` (e.g. `checked_in`, `completed`, `cancelled`) is rolled back, preventing a stray approval from corrupting the booking lifecycle.

**Migration-time trigger handling:** the five triggers are `DISABLE`d before data migration and `ENABLE`d afterwards (including `trg_FacilityMaintenance_UpdateSpaceStatus`, which is inert during migration because `FacilityMaintenance` is empty, and is disabled for consistency with the other maintenance trigger). Historical bookings are inserted with their original final statuses (the Phase 1 sample data reached the same states via explicit `UPDATE` transitions). TRG-02's availability check is disabled because some migrated bookings overlap active out-of-service maintenance on their space. `trg_BookingApproval_UpdateBookingStatus` is disabled because the migrated approval rows reference bookings whose statuses have already advanced past the point of approval (e.g. `completed`, `checked_in`, `no-show`); an enabled trigger would attempt the invalid `completed → approved` transition and fail. Disabling triggers during bulk migration is standard practice and is documented here rather than implied.

---

## 8. Data Migration Execution Order

Inserts are ordered to satisfy dependency requirements so referential integrity is never violated at any stage:

| Step | Table | Source | Notes |
|---|---|---|---|
| 1 | `SpaceTypeBookingPolicy` | seed | 4 rows, all `instant_booking_eligible = 0` |
| 2 | `Semester` | seed | 9 rows (3 academic years) |
| 3 | `CampusUser` | `SpaceBookingDB.dbo.CampusUser` | `IDENTITY_INSERT` preserves IDs |
| 4 | `CampusSpace` | `SpaceBookingDB.dbo.CampusSpace` | natural PK preserved |
| 5 | `CampusFacility` | `SpaceBookingDB.dbo.CampusFacility` | T1 rename |
| 6 | `SpaceBooking` | `SpaceBookingDB.dbo.SpaceBooking` | T2, T6 defaults |
| 7 | `BookingApproval` | `SpaceBookingDB.dbo.BookingApproval` | IDs preserved |
| 8 | `SpaceUsageSession` | `SpaceBookingDB.dbo.SpaceUsageSession` | IDs preserved |
| 9 | `SpaceMaintenance` | `SpaceBookingDB.dbo.SpaceMaintenance` | T3, T4, T5 |
| 10 | `FacilityMaintenance` | — | empty (no Phase 1 data) |

Primary-key values are preserved wherever an `IDENTITY` column is migrated (`SET IDENTITY_INSERT ... ON`), keeping cross-table references valid without rebuilding relationships. After the final identity insert, SQL Server automatically seeds the next identity value to `max + 1`.

---

## 9. Constraint and Trigger Creation Summary

- **Primary keys:** created for all 10 tables (9 §4.3).
- **Foreign keys:** `CampusSpace.space_type → SpaceTypeBookingPolicy.space_type` (R11); `FacilityMaintenance.campus_facility_id / reporter_id / assigned_staff_id` (R12–R14); all Phase 1 FKs retained unchanged.
- **Unique keys:** `CampusUser.email`, `CampusSpace(building, floor, room_number)`, `CampusFacility.facility_type`, `BookingApproval.space_booking_id`, `SpaceUsageSession.space_booking_id`, `Semester(academic_year, semester_no)`.
- **CHECK constraints:** all declared inline per table (see §4 and the SQL file), including the new `impact_level`, `notify_status` (on both `SpaceMaintenance` and `FacilityMaintenance`), `is_instant_booking`, `advisory_acknowledged` checks and the maintenance interval-consistency checks.
- **TRIGGER constraints:** 5 triggers (see §7). TRG-02 additionally enforces the BR-11 instant-eligibility rule, the BR-02/BR-09 insert-time availability check via `fn_IsSpaceAvailable` (space not `temporarily_closed`/`retired`, no overlapping active `out_of_service` maintenance from either source), and the BR-02/BR-09 approval precondition (space not `temporarily_closed`/`retired`, no overlapping active out-of-service `FacilityMaintenance`) (Step 10 additions, §7).
- **Deferred (Steps 11–13):** BR-01/BR-12 overlap invariant only — enforced transactionally per 09 §4.3, §6. BR-02/BR-09 space availability is enforced at insertion by TRG-02 via `fn_IsSpaceAvailable` (§7) and at approval by `sp_ApproveSpaceBooking` and `trg_BookingApproval_UpdateBookingStatus` (11 §4.2, 12 §3.2, §7) through the same shared function, complemented by TRG-02's approval precondition (§7). The Step 10 additions do not re-implement the overlap invariant.

---

## 10. Data Integrity Validation

The migration is validated against every constraint class listed in the step-10 instruction:

| Constraint class | Validation performed |
|---|---|
| Primary keys | grouped `COUNT(*) > 1` check per PK column → must return 0 rows |
| Foreign keys | anti-join / `NOT EXISTS` queries per FK column → must return 0 rows |
| UNIQUE keys | grouped checks on `email`, `facility_type`, `(academic_year, semester_no)` → must return 0 rows |
| CHECK constraints | insert-time enforcement + post-check that no `problem_type` value lies outside the new domain; post-check that every `notify_status` matches the `trg_SpaceMaintenance_UpdateSpaceStatus` mapping (§7) — expect 0 rows; post-check that every migrated `SpaceBooking.advisory_acknowledged = 1` (T6) — expect 0 rows |
| NOT NULL | all migrated mandatory columns are populated (mandatory attributes handled by §6.3) |
| Triggers | disabled during migration, re-enabled after; integrity re-verified by the above queries |
| Decision ↔ status consistency | post-check that every `BookingApproval.decision` is consistent with the booking status maintained by `trg_BookingApproval_UpdateBookingStatus` (§7): `decision='approved'` ⇒ booking in the approved lifecycle (`approved`/`checked_in`/`completed`/`no-show`); `decision='rejected'` ⇒ booking `rejected` — expect 0 rows |

Expected row counts after migration:

| Table | Expected rows |
|---|---|
| `SpaceTypeBookingPolicy` | 4 |
| `CampusUser` | 8 |
| `CampusSpace` | 8 |
| `CampusFacility` | 6 |
| `Semester` | 9 |
| `SpaceBooking` | 10 |
| `BookingApproval` | 6 |
| `SpaceUsageSession` | 4 |
| `SpaceMaintenance` | 6 |
| `FacilityMaintenance` | 0 |

---

## 11. Final Verification Checklist (Step 8 of the instruction)

| # | Check | Result |
|---|---|---|
| 1 | Every new entity created | **PASS** — 10 tables, including `SpaceTypeBookingPolicy`, `Semester`, `FacilityMaintenance` |
| 2 | Every required relationship exists | **PASS** — R1–R14 FKs implemented (§9) |
| 3 | Every mandatory attribute populated | **PASS** — new mandatory attributes defaulted/seeded (§6.3) |
| 4 | No broken foreign keys | **PASS** — dependency-ordered inserts + anti-join checks (§10) |
| 5 | No duplicate primary keys introduced | **PASS** — IDENTITY_INSERT preserves source PKs; uniqueness checks pass |
| 6 | Existing data migrated wherever a valid mapping exists | **PASS** — 8/8 users, 8/8 spaces, 6/6 facilities, 10/10 bookings, 6/6 approvals, 4/4 sessions, 6/6 maintenance records; only `FacilityMaintenance` has no source data |
| 7 | Old schema untouched | **PASS** — source `SpaceBookingDB` is only read |
| 8 | Data transformation applied and verified | **PASS** — T1–T6 (§6.2) with post-migration checks |
| 9 | Space availability enforced before insert and before approval | **PASS** — TRG-02 rejects inserts for unavailable spaces via `fn_IsSpaceAvailable` (closed/retired, `SpaceMaintenance` or `FacilityMaintenance` out-of-service overlap, §7); at approval, `sp_ApproveSpaceBooking` re-validates availability with the same function (error 50017, 11 §4.2, 12 §3.2), `trg_BookingApproval_UpdateBookingStatus` repeats the check before syncing the status, and TRG-02's approval precondition rejects `pending → approved` when the space is closed/retired or under overlapping out-of-service `FacilityMaintenance` (§7) |
| 10 | `SpaceMaintenance.notify_status` maintained in sync | **PASS** — `trg_SpaceMaintenance_UpdateSpaceStatus` derives `notify_status` from `status`/`impact_level` (§7); migrated rows pre-aligned by T5 and verified by the §10 post-check |
| 11 | `FacilityMaintenance` maintenance propagation + notify_status | **PASS** — `trg_FacilityMaintenance_UpdateSpaceStatus` traverses the whole `FacilityMaintenance` table on insert/update, sets the owning space to `under_maintenance` when any active `out_of_service` record exists, restores it only when neither source has an active `out_of_service` record, and derives `FacilityMaintenance.notify_status` from `status`/`impact_level` (§7) |
| 12 | `BookingApproval.decision` consistent with `SpaceBooking.status` | **PASS** — `trg_BookingApproval_UpdateBookingStatus` is the single point that sets the booking status to match the recorded decision on `BookingApproval` insert/update (`sp_ApproveSpaceBooking` records only the decision row); the transition is validated by `trg_SpaceBooking_StatusTransition`; post-migration consistency verified (§10) |
| 13 | Instant booking only for eligible space types | **PASS** — TRG-02 rejects any `INSERT` with `is_instant_booking = 1` whose space type is not `instant_booking_eligible` in `SpaceTypeBookingPolicy` (BR-11, §7) |
| 14 | Out-of-service `FacilityMaintenance` blocks booking | **PASS** — TRG-02's insert-time availability check rejects inserts whose window overlaps an active out-of-service `FacilityMaintenance` interval, and TRG-02's approval precondition blocks the same at approval time (BR-02/BR-09, §7) |
| 15 | Acknowledgement recorded on every booking | **PASS** — every migrated `SpaceBooking.advisory_acknowledged = 1` (T6, §6.2), the column default is `1`, and `sp_SubmitSpaceBooking` stores `1` at submission (BR-13) |

---

## 12. Assumptions and Decisions

- **Target database name:** `SpaceBookingDB_Phase2` — required because the migration needs both databases present on one server. All Phase 2 artifacts (Steps 11–16) must target this database.
- **Migrated maintenance impact level:** all Phase 1 `SpaceMaintenance` rows migrate with `impact_level = 'out_of_service'`, matching Phase 1 behaviour ("maintenance blocks booking") as recorded in 09 §10.
- **`SpaceMaintenance.notify_status` (Step 10 addition):** mirrors `FacilityMaintenance.notify_status` (09 §4.2) with the same domain. It is maintained solely by `trg_SpaceMaintenance_UpdateSpaceStatus` (derived from the record's `status` / `impact_level`, see §7); migrated rows are pre-aligned by transform T5 so the post-migration data already matches the trigger mapping.
- **`trg_FacilityMaintenance_UpdateSpaceStatus` (new, Step 10; user decision 2026-08-07):** mirrors `trg_SpaceMaintenance_UpdateSpaceStatus` for facility maintenance. On `INSERT`/`UPDATE` it traverses the whole `FacilityMaintenance` table and re-derives the owning space's `current_status` from **both** maintenance sources (`FacilityMaintenance` and `SpaceMaintenance`): the space is `under_maintenance` while either source has an active `out_of_service` record and is restored to `available` only when neither does. It also maintains `FacilityMaintenance.notify_status` from the record's own `status`/`impact_level` with the same mapping as TRG-04. No third trigger is required — a change on either maintenance table re-evaluates the affected space, so approval-time availability remains enforced by `sp_ApproveSpaceBooking` (11 §4.2, 12 §3.2) and the `BookingApproval` trigger through the shared `fn_IsSpaceAvailable`.
- **BR-13 interaction with the new facility trigger:** `sp_SubmitSpaceBooking` (Step 12) still updates `FacilityMaintenance.notify_status = 'updated_to_advisory'` atomically for active advisory records; the trigger derives the same value from the record's `status`/`impact_level`, so the stored procedure's update is idempotent with the trigger mapping and the two cannot conflict.
- **Migrated bookings are staff-processed:** `is_instant_booking = 0` for all Phase 1 bookings; no instant-booking path existed in Phase 1.
- **Migrated bookings record the acknowledgement:** every Phase 1 booking migrates with `advisory_acknowledged = 1` (T6) — the requester is always informed of facility availability at submission (BR-13), so the acknowledgement is stored on every booking. `sp_SubmitSpaceBooking` (Step 12) stores `1` on newly submitted bookings; the data generator (Step 14) stores `1` on generated bookings.
- **`broken_projector` remap:** mapped to `'other'` because it was removed from the `problem_type` domain in Phase 2 (09 §4.2); the record's business meaning (a projector fault) is preserved in `problem_description`.
- **`FacilityMaintenance` starts empty:** Phase 1 had no facility-level maintenance data; the table is created with its defaults so later steps can populate it.
- **Config seeding:** `SpaceTypeBookingPolicy` seeded with all 4 space types with instant booking disabled (`0`) per 09 §10; `Semester` seeded with 3 academic years (2024/2025, 2025/2026, 2026/2027) so the sample booking window (June–July 2026) falls inside 2025-2026 semester 3.
- **Triggers disabled during migration:** avoids the BR-03 INSERT restriction on historical final statuses; re-enabled afterwards. This does not alter business rules, only how bulk historical data is loaded.
- **Availability check at booking time (Step 10 addition):** the insert-time availability check (BR-02/BR-09) is implemented inside TRG-02 via `fn_IsSpaceAvailable` (rejects inserts for unavailable spaces), replacing the standalone `trg_SpaceBooking_AvailabilityCheck_Insert` originally drafted for this role. At approval time availability is re-checked by `sp_ApproveSpaceBooking` (11 §4.2, 12 §3.2) under the per-space lock via the same shared function (error 50017) and again by `trg_BookingApproval_UpdateBookingStatus` before it syncs the status, so an unavailable space cannot be approved through the procedure or a direct `BookingApproval` insert. TRG-02's approval precondition additionally rejects a `pending → approved` move when the space is closed/retired or under overlapping active out-of-service `FacilityMaintenance` (§7).
- **`trg_BookingApproval_UpdateBookingStatus` (new, Step 10):** added to enforce 09 §5 BR-03 ("`BookingApproval.decision` must remain consistent with `SpaceBooking.status`") at the data level. `sp_ApproveSpaceBooking` (12 §3.2) records only the `BookingApproval` row and never updates `SpaceBooking.status`, so this trigger is the single sync point for both the procedure path and a direct `BookingApproval` insert (which would otherwise leave the booking `pending`). The sync runs inside the caller's transaction — for the procedure, the app-locked transaction — so it cannot conflict with the concurrency implementation. Its status `UPDATE` re-fires TRG-02, so a direct approval is also subject to the TRG-02 approval precondition (§7).
- **Instant-eligibility check (Step 10 addition):** TRG-02 rejects an `INSERT` with `is_instant_booking = 1` when the space's type is not `instant_booking_eligible` (BR-11). This closes the direct-insert bypass of `sp_SubmitSpaceBooking`'s policy lookup. It is a point read of configuration data and does not re-introduce the deferred overlap invariant (§7).
- **Out-of-service `FacilityMaintenance` blocking (Step 10 addition):** TRG-02's insert-time availability check and its approval precondition now treat an active out-of-service `FacilityMaintenance` interval overlapping the booking window as blocking (BR-02/BR-09). Previously only the space's `current_status` was affected (TRG-06) while booking remained possible. Advisory `FacilityMaintenance` never blocks (§7).
- **Concurrency impact of the Step 10 additions (items 4–6):** assessed as **no impact** on the Step 11–13 concurrency architecture — the additions are read-only checks inside triggers that fire within the already app-locked transactions, follow the 11 §3.3 lock hierarchy, reuse the same shared `fn_IsSpaceAvailable` guard as the procedures rather than introducing new logic, re-implement neither the overlap invariant (BR-01/BR-12) nor the procedure's availability check (error 50017), and introduce no new lock types or ordering. Residual phantom-race exposure for `FacilityMaintenance` writes (no protected procedure) is unchanged from the existing design (§7).
- **Deferred to Steps 11–13:** the overlap invariant (BR-01/BR-12) is not implemented in this migration; it belongs to the transactional concurrency implementation per 09 §4.3 and §6.

## 13. Open Questions

- Whether later artifacts (11–16) should operate on `SpaceBookingDB_Phase2` or a renamed production database — assumed to be `SpaceBookingDB_Phase2` here.
- The specific space types that should be instant-booking eligible — left disabled (all `0`) pending Facility Manager input, consistent with 09 §10.
- Whether report 1 prorates booking hours at semester boundaries — report-logic decision, not a migration concern (09 §10).
