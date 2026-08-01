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
| `SpaceBooking` | New attribute `is_instant_booking BIT NOT NULL DEFAULT 0` | `CHECK (is_instant_booking IN (0,1))`; `purpose_type` widened to `NVARCHAR(40)` |
| `SpaceMaintenance` | New attribute `impact_level`; `problem_type` domain reduced (removed `broken_projector`); interval consistency rules | `impact_level CHECK IN ('out_of_service','advisory')` default `out_of_service`; `problem_type CHECK IN ('ac_failure','damaged_furniture','cleaning','network','other')`; `completion_time IS NULL OR completion_time > start_time`; `status='completed' ⇒ completion_time IS NOT NULL`; `status IN ('reported','in_progress') ⇒ completion_time IS NULL` |

### 4.3. Unchanged entities

`CampusUser`, `BookingApproval`, `SpaceUsageSession` are unchanged (09 §4.2: "Unchanged relations retain their Phase 1 definitions exactly as implemented in 05-db-definition-G02.sql").

### 4.4. Removed objects

- No entity is removed.
- One attribute domain value is removed: `SpaceMaintenance.problem_type = 'broken_projector'`.
- Phase 1 trigger `trg_SpaceBooking_NoOverlap` (BR-01) is **not** recreated: 09 §4.3 and §6 explicitly defer the overlap invariant and the maintenance-blocking rule (BR-01/BR-12, BR-02/BR-09) to the transactional concurrency implementation (Steps 11–13). Recreating a plain trigger here would duplicate — and partially conflict with — that protected implementation.

---

## 5. Old-to-New Mapping Table

Per-table decision and rationale (each maps back to 09 §3.2 / §4.2):

| Old (Phase 1) | New (Phase 2) | Action | Rationale / traceability |
|---|---|---|---|
| `CampusUser` | `CampusUser` | **Keep** (copy data) | Unchanged relation (09 §4.2) |
| `CampusSpace` | `CampusSpace` | **Keep + modify** | New FK to `SpaceTypeBookingPolicy` (09 §3.2 CampusSpace); data copied unchanged |
| `CampusFacility` | `CampusFacility` | **Keep + rename attribute** | `facility_name → facility_type` (09 §4.2 CampusFacility) |
| `SpaceBooking` | `SpaceBooking` | **Keep + modify** | New `is_instant_booking` (09 §3.2 SpaceBooking) |
| `BookingApproval` | `BookingApproval` | **Keep** (copy data) | Unchanged (09 §4.2) |
| `SpaceUsageSession` | `SpaceUsageSession` | **Keep** (copy data) | Unchanged (09 §4.2) |
| `SpaceMaintenance` | `SpaceMaintenance` | **Keep + modify** | New `impact_level`; `problem_type` domain reduced (09 §3.2 SpaceMaintenance) |
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
| — | `SpaceMaintenance.impact_level` | **Generate default value** `'out_of_service'` (09 §10: existing maintenance blocked booking, which equals Phase 2 `out_of_service`) |
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

### 6.3. Default value insertion for newly introduced mandatory attributes

| Table | Attribute | Default used in migration | Source of decision |
|---|---|---|---|
| `SpaceBooking` | `is_instant_booking` | `0` | 09 §3.2 SpaceBooking; Phase 1 had only staff approval |
| `SpaceMaintenance` | `impact_level` | `'out_of_service'` | 09 §10 — Phase 1 behaviour (maintenance blocks booking) |
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
| `trg_SpaceBooking_StatusTransition` | BR-03 | INSERT rule extended: staff booking must be `pending`, instant booking (`is_instant_booking = 1`) must be `approved` at submission (BR-11, 09 §5) |
| `trg_SpaceBooking_CapacityCheck` | BR-07 | unchanged |
| `trg_SpaceMaintenance_UpdateSpaceStatus` | Phase 1 Issue 3 (convenience) | refined: only **active** maintenance with `impact_level = 'out_of_service'` sets `CampusSpace.current_status = 'under_maintenance'`; advisory maintenance does not |

**Migration-time trigger handling:** the three triggers are `DISABLE`d before data migration and `ENABLE`d afterwards. Historical bookings are inserted with their original final statuses (the Phase 1 sample data reached the same states via explicit `UPDATE` transitions). Disabling triggers during bulk migration is standard practice and is documented here rather than implied.

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
| 6 | `SpaceBooking` | `SpaceBookingDB.dbo.SpaceBooking` | T2 default |
| 7 | `BookingApproval` | `SpaceBookingDB.dbo.BookingApproval` | IDs preserved |
| 8 | `SpaceUsageSession` | `SpaceBookingDB.dbo.SpaceUsageSession` | IDs preserved |
| 9 | `SpaceMaintenance` | `SpaceBookingDB.dbo.SpaceMaintenance` | T3, T4 |
| 10 | `FacilityMaintenance` | — | empty (no Phase 1 data) |

Primary-key values are preserved wherever an `IDENTITY` column is migrated (`SET IDENTITY_INSERT ... ON`), keeping cross-table references valid without rebuilding relationships. After the final identity insert, SQL Server automatically seeds the next identity value to `max + 1`.

---

## 9. Constraint and Trigger Creation Summary

- **Primary keys:** created for all 10 tables (9 §4.3).
- **Foreign keys:** `CampusSpace.space_type → SpaceTypeBookingPolicy.space_type` (R11); `FacilityMaintenance.campus_facility_id / reporter_id / assigned_staff_id` (R12–R14); all Phase 1 FKs retained unchanged.
- **Unique keys:** `CampusUser.email`, `CampusSpace(building, floor, room_number)`, `CampusFacility.facility_type`, `BookingApproval.space_booking_id`, `SpaceUsageSession.space_booking_id`, `Semester(academic_year, semester_no)`.
- **CHECK constraints:** all declared inline per table (see §4 and the SQL file), including the new `impact_level`, `notify_status`, `is_instant_booking` checks and the maintenance interval-consistency checks.
- **TRIGGER constraints:** 3 triggers (see §7).
- **Deferred (Steps 11–13):** BR-01/BR-12 overlap invariant and BR-02/BR-09 maintenance blocking — enforced transactionally per 09 §4.3, §6.

---

## 10. Data Integrity Validation

The migration is validated against every constraint class listed in the step-10 instruction:

| Constraint class | Validation performed |
|---|---|
| Primary keys | grouped `COUNT(*) > 1` check per PK column → must return 0 rows |
| Foreign keys | anti-join / `NOT EXISTS` queries per FK column → must return 0 rows |
| UNIQUE keys | grouped checks on `email`, `facility_type`, `(academic_year, semester_no)` → must return 0 rows |
| CHECK constraints | insert-time enforcement + post-check that no `problem_type` value lies outside the new domain |
| NOT NULL | all migrated mandatory columns are populated (mandatory attributes handled by §6.3) |
| Triggers | disabled during migration, re-enabled after; integrity re-verified by the above queries |

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
| 8 | Data transformation applied and verified | **PASS** — T1–T4 (§6.2) with post-migration checks |

---

## 12. Assumptions and Decisions

- **Target database name:** `SpaceBookingDB_Phase2` — required because the migration needs both databases present on one server. All Phase 2 artifacts (Steps 11–16) must target this database.
- **Migrated maintenance impact level:** all Phase 1 `SpaceMaintenance` rows migrate with `impact_level = 'out_of_service'`, matching Phase 1 behaviour ("maintenance blocks booking") as recorded in 09 §10.
- **Migrated bookings are staff-processed:** `is_instant_booking = 0` for all Phase 1 bookings; no instant-booking path existed in Phase 1.
- **`broken_projector` remap:** mapped to `'other'` because it was removed from the `problem_type` domain in Phase 2 (09 §4.2); the record's business meaning (a projector fault) is preserved in `problem_description`.
- **`FacilityMaintenance` starts empty:** Phase 1 had no facility-level maintenance data; the table is created with its defaults so later steps can populate it.
- **Config seeding:** `SpaceTypeBookingPolicy` seeded with all 4 space types with instant booking disabled (`0`) per 09 §10; `Semester` seeded with 3 academic years (2024/2025, 2025/2026, 2026/2027) so the sample booking window (June–July 2026) falls inside 2025-2026 semester 3.
- **Triggers disabled during migration:** avoids the BR-03 INSERT restriction on historical final statuses; re-enabled afterwards. This does not alter business rules, only how bulk historical data is loaded.
- **Deferred to Steps 11–13:** the overlap invariant (BR-01/BR-12) and maintenance-blocking validation (BR-02/BR-09) are not implemented in this migration; they belong to the transactional concurrency implementation per 09 §4.3 and §6.

## 13. Open Questions

- Whether later artifacts (11–16) should operate on `SpaceBookingDB_Phase2` or a renamed production database — assumed to be `SpaceBookingDB_Phase2` here.
- The specific space types that should be instant-booking eligible — left disabled (all `0`) pending Facility Manager input, consistent with 09 §10.
- Whether report 1 prorates booking hours at semester boundaries — report-logic decision, not a migration concern (09 §10).
