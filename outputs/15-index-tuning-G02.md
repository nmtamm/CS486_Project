# Step 15 — Index Tuning (Analytical Process)

**Group:** G02

**Phase:** Phase 2 — Index Tuning (Step 15)

**Task:** Tune the booking conflict check, the room finder, and four analytical queries for the Campus Space Management System

**Target Database:** `SpaceBookingDB_Phase2`

**DBMS:** Microsoft SQL Server

**Generation Date:** 2026-08-06

---

## 1. Objective

This artifact tunes the index set of the Phase 2 database created by `outputs/10-schema-migration-G02.sql` (`SpaceBookingDB_Phase2`) so that the hot-path transactional statements and the analytical queries run without full table scans.

Per `step-15-index-tuning/INSTRUCTION.md`, the tuning targets are:

1. The **booking conflict check** — the overlap and blocking-maintenance predicates executed inside the Step 12 procedures (`sp_SubmitSpaceBooking`, `sp_ApproveSpaceBooking`).
2. The **room finder** — the query that finds available spaces satisfying a required capacity and a required facility list within a given time period.
3. Four analytical queries:
   - **Q1** — Total approved booking hours of each space for a given semester.
   - **Q2** — Number of approved bookings by weekday and hour for a given semester.
   - **Q3** — Available spaces that satisfy a required capacity and a required facility list within a given time period (this is the room finder; listed here for completeness).
   - **Q4** — Approved bookings affected when a maintenance record is escalated to `out_of_service`.

The executable artifact is `outputs/15-index-tuning-G02.sql`. Per the instruction, the script **must not be run** after implementation; it only declares the index set.

---

## 2. Reference Files

| Purpose | File |
|---|---|
| Step 15 instruction (save target, requirements, workflow) | `.opencode/skills/db-design-pipeline/step-15-index-tuning/INSTRUCTION.md` |
| Target schema — table names, column names, types, PK/UNIQUE/FK/CHECK constraints | `outputs/10-schema-migration-G02.sql` (Step 10) |
| Updated logical design — entities, attributes, business-rule identifiers | `outputs/09-updated-erd-and-logical-design-G02.md` (Step 09, §4.2 Relation Definitions) |
| Booking conflict check predicates (overlap, blocking maintenance, advisory notification) | `outputs/12-concurrency-implementation-G02.sql` → `outputs/11-concurrency-design-G02.md` (§4.1.3, §4.2.2, §4.3.2) |
| Escalation impact query (Q4) source | `outputs/12-concurrency-implementation-G02.sql` (§3.3 `sp_EscalateSpaceMaintenance`) |

Precedence on conflict: Step 10 schema → Step 09 logical design → Step 11 concurrency design → Step 12 implementation. Column names and enum literals were cross-checked against the actual schema in `10-schema-migration-G02.sql`.

---

## 3. Workflow

The Step 15 workflow was executed in the order required by the instruction:

1. Identify which schema is related to the given queries — see Section 4.
2. Identify which attributes in those schema need indexing — see Section 5.
3. Implement indexes on those attributes — see Section 6.

---

## 4. Step 1 — Schema Identification

The tables involved in the booking conflict check, the room finder, and the four tuning targets are:

| Table | Used by |
|---|---|
| `SpaceBooking` | booking conflict check overlap (11 §4.1.3, §4.2.2); room finder overlap (Q3); approved-booking semester queries (Q1, Q2); escalation impact query (Q4) |
| `CampusSpace` | room finder capacity/availability filter (Q3); space-name join (Q1) |
| `CampusFacility` | room finder required-facility list (Q3); booking conflict check advisory lookup (BR-13) |
| `SpaceMaintenance` | booking conflict check blocking-maintenance predicate (BR-02/BR-09); escalation context (Q4); AQ-04 escalated-spaces lookup (BR-14) |
| `FacilityMaintenance` | booking conflict check advisory-notification predicate (BR-13); AQ-04 escalated-facilities lookup (BR-14) |
| `CampusUser` | booking conflict check requester/staff existence (PK lookup only — no new index) |
| `SpaceTypeBookingPolicy` | booking conflict check instant-booking policy lookup (PK lookup only — no new index) |
| `Semester` | Q1 / Q2 given-semester date-range lookup (PK / UNIQUE lookup only — no new index) |

---

## 5. Step 2 — Indexable Attribute Identification

For each tuning target, the driving predicates are listed below together with the attributes that must be keyed or included so the optimizer can seek instead of scanning.

### 5.1. Booking conflict check — overlap scan (`11-concurrency-design-G02.md` §4.1.3, §4.2.2)

```sql
SELECT ... FROM SpaceBooking sb
WHERE sb.campus_space_code = @campus_space_code
  AND sb.status IN (N'approved', N'checked_in', N'completed', N'no-show')
  AND sb.requested_start_time < @requested_end_time
  AND sb.requested_end_time > @requested_start_time;
```

| Attribute | Role | Action |
|---|---|---|
| `campus_space_code` | equality filter | index key (leading) |
| `status` | `IN (...)` filter | index key |
| `requested_start_time` | range predicate | index key |
| `requested_end_time` | residual predicate | INCLUDE |

**Index:** `SpaceBooking (campus_space_code, status, requested_start_time) INCLUDE (requested_end_time)` — **[IDX-01]**.

### 5.2. Booking conflict check — blocking maintenance (BR-02 / BR-09)

```sql
WHERE sm.campus_space_code = @campus_space_code
  AND sm.status IN (N'reported', N'in_progress')
  AND sm.impact_level = N'out_of_service'
  AND sm.start_time < @requested_end_time
  AND (sm.completion_time IS NULL OR sm.completion_time > @requested_start_time);
```

| Attribute | Role | Action |
|---|---|---|
| `campus_space_code` | equality filter | index key (leading) |
| `status` | `IN (...)` filter | index key |
| `impact_level` | equality filter | index key |
| `start_time`, `completion_time` | interval predicates | INCLUDE |

**Index:** `SpaceMaintenance (campus_space_code, status, impact_level) INCLUDE (start_time, completion_time)` — **[IDX-03]**. This also accelerates `trg_SpaceMaintenance_UpdateSpaceStatus` lookups.

### 5.3. Booking conflict check — advisory notification (BR-13)

```sql
UPDATE fm ... FROM FacilityMaintenance fm JOIN CampusFacility cf
   ON fm.campus_facility_id = cf.campus_facility_id
WHERE cf.campus_space_code = @campus_space_code
  AND fm.status IN (N'reported', N'in_progress')
  AND fm.impact_level = N'advisory'
  AND fm.start_time < @requested_end_time
  AND (fm.completion_time IS NULL OR fm.completion_time > @requested_start_time);
```

| Attribute | Role | Action |
|---|---|---|
| `CampusFacility.campus_space_code` | equality filter (drives the join) | index key |
| `CampusFacility.campus_facility_id`, `facility_type` | join key / output | INCLUDE |
| `FacilityMaintenance.campus_facility_id` | join equality | index key (leading) |
| `FacilityMaintenance.status`, `impact_level` | filters | index key |
| `FacilityMaintenance.start_time`, `completion_time` | interval predicates | INCLUDE |

**Indexes:**
- `CampusFacility (campus_space_code) INCLUDE (campus_facility_id, facility_type)` — **[IDX-05]**.
- `FacilityMaintenance (campus_facility_id, status, impact_level) INCLUDE (start_time, completion_time)` — **[IDX-04]**.

### 5.4. Q1 — Total approved booking hours per space for a given semester

```sql
SELECT sb.campus_space_code, s.space_name,
       SUM(DATEDIFF(MINUTE, sb.requested_start_time, sb.requested_end_time)) / 60.0 AS total_hours
FROM SpaceBooking sb JOIN CampusSpace s
     ON sb.campus_space_code = s.campus_space_code
WHERE sb.status = N'approved'
  AND sb.requested_start_time >= @semester_start
  AND sb.requested_start_time <  @semester_end
GROUP BY sb.campus_space_code, s.space_name;
```

| Attribute | Role | Action |
|---|---|---|
| `status` | equality filter | index key (leading) |
| `requested_start_time` | semester range | index key |
| `campus_space_code` | group-by key | INCLUDE |
| `requested_end_time` | hour computation | INCLUDE |

**Index:** `SpaceBooking (status, requested_start_time) INCLUDE (campus_space_code, requested_end_time)` — **[IDX-02]**.

### 5.5. Q2 — Approved bookings by weekday and hour for a given semester

```sql
SELECT DATEPART(WEEKDAY, requested_start_time) AS weekday,
       DATEPART(HOUR, requested_start_time)    AS hour,
       COUNT(*)
FROM SpaceBooking
WHERE status = N'approved'
  AND requested_start_time >= @semester_start
  AND requested_start_time <  @semester_end
GROUP BY DATEPART(WEEKDAY, requested_start_time), DATEPART(HOUR, requested_start_time);
```

The predicate is identical to Q1 (equality on `status`, range on `requested_start_time`); weekday and hour are computed from `requested_start_time`. The same covering index **[IDX-02]** serves Q1 and Q2 — no additional index is required.

### 5.6. Q3 (room finder) — Available spaces with required capacity and facility list

```sql
SELECT cs.campus_space_code, cs.space_name
FROM CampusSpace cs
WHERE cs.capacity >= @required_capacity
  AND cs.current_status = N'available'
  AND NOT EXISTS (SELECT 1 FROM SpaceBooking sb
                  WHERE sb.campus_space_code = cs.campus_space_code
                    AND sb.status IN (N'approved', N'checked_in', N'completed', N'no-show')
                    AND sb.requested_start_time < @requested_end_time
                    AND sb.requested_end_time > @requested_start_time)
  AND EXISTS (SELECT 1 FROM CampusFacility f
              WHERE f.campus_space_code = cs.campus_space_code
                AND f.facility_type IN (@facility_list));
```

| Attribute | Role | Action |
|---|---|---|
| `CampusSpace.capacity` | inequality (`>=`) driving filter | index key |
| `CampusSpace.current_status` | equality filter | INCLUDE |
| `CampusSpace.space_name`, `space_type`, `building`, `floor`, `room_number` | output columns | INCLUDE |
| `CampusFacility.facility_type` | `IN (…)` facility list | index key (leading) |
| `CampusFacility.campus_space_code` | join to space | index key |
| `SpaceBooking` overlap predicates | same shape as 5.1 | reuses **[IDX-01]** |

**Indexes:**
- `CampusSpace (capacity) INCLUDE (current_status, space_type, space_name, building, floor, room_number)` — **[IDX-07]**.
- `CampusFacility (facility_type, campus_space_code) INCLUDE (status)` — **[IDX-06]**.
- `SpaceBooking` overlap sub-query reuses **[IDX-01]**.

### 5.7. Q4 — Approved bookings affected by escalation to `out_of_service`

```sql
SELECT * FROM SpaceBooking
WHERE status IN (N'approved', N'checked_in')
  AND campus_space_code IN (
      SELECT DISTINCT campus_space_code
      FROM SpaceMaintenance
      WHERE notify_status = N'updated_to_out_of_service'
    UNION
      SELECT DISTINCT cf.campus_space_code
      FROM FacilityMaintenance fm
      JOIN CampusFacility cf ON fm.campus_facility_id = cf.campus_facility_id
      WHERE fm.notify_status = N'updated_to_out_of_service');
```

| Attribute | Role | Action |
|---|---|---|
| `SpaceMaintenance.notify_status` | equality filter (BR-14 outreach state) | index key (leading) |
| `SpaceMaintenance.campus_space_code` | output (space key) | index key |
| `FacilityMaintenance.notify_status` | equality filter (BR-14 outreach state) | index key (leading) |
| `FacilityMaintenance.campus_facility_id` | join key to `CampusFacility` PK | index key |

The `CampusFacility` side of the join is a clustered PK lookup on `campus_facility_id` (returns `campus_space_code`) — no additional index needed. The outer `SpaceBooking` predicate is the same overlap-shaped filter as Q4 and is served by **[IDX-01]**.

**Indexes:**
- `SpaceMaintenance (notify_status, campus_space_code)` — **[IDX-08]**.
- `FacilityMaintenance (notify_status, campus_facility_id)` — **[IDX-09]**.

### 5.9. Attributes that need no additional index

The following are already covered by existing clustered PK / UNIQUE indexes created inline in `10-schema-migration-G02.sql` §1, and are accessed by primary-key lookups only:

| Attribute | Existing index |
|---|---|
| `CampusUser.campus_user_id` | PK (requester / staff existence check) |
| `SpaceTypeBookingPolicy.space_type` | PK (instant-booking policy lookup) |
| `Semester.semester_id`, `Semester (academic_year, semester_no)` | PK, UNIQUE |
| `SpaceBooking.space_booking_id` | PK (by-id updates) |
| `SpaceMaintenance.space_maintenance_id` | PK (escalation target lookup) |

---

## 6. Step 3 — Index Implementation

All nine indexes are **nonclustered** and are implemented in `outputs/15-index-tuning-G02.sql`; the clustered PK / UNIQUE indexes remain unchanged.

| ID | Index | Table | Key columns | Included columns | Serves |
|---|---|---|---|---|---|
| IDX-01 | `IX_SpaceBooking_Space_Status_Start` | `SpaceBooking` | `campus_space_code`, `status`, `requested_start_time` | `requested_end_time` | conflict check overlap, Q3 overlap|
| IDX-02 | `IX_SpaceBooking_Status_StartTime` | `SpaceBooking` | `status`, `requested_start_time` | `campus_space_code`, `requested_end_time` | Q1, Q2 |
| IDX-03 | `IX_SpaceMaintenance_Space_Status_Impact` | `SpaceMaintenance` | `campus_space_code`, `status`, `impact_level` | `start_time`, `completion_time` | conflict check blocking (BR-02/BR-09), maintenance trigger |
| IDX-04 | `IX_FacilityMaintenance_Facility_Status_Impact` | `FacilityMaintenance` | `campus_facility_id`, `status`, `impact_level` | `start_time`, `completion_time` | conflict check advisory (BR-13) |
| IDX-05 | `IX_CampusFacility_SpaceCode` | `CampusFacility` | `campus_space_code` | `campus_facility_id`, `facility_type` | conflict check advisory (BR-13) |
| IDX-06 | `IX_CampusFacility_Type_Space` | `CampusFacility` | `facility_type`, `campus_space_code` | `status` | Q3 facility list |
| IDX-07 | `IX_CampusSpace_Capacity_Status` | `CampusSpace` | `capacity` | `current_status`, `space_type`, `space_name`, `building`, `floor`, `room_number` | Q3 room finder |
| IDX-08 | `IX_SpaceMaintenance_NotifyStatus_Space` | `SpaceMaintenance` | `notify_status`, `campus_space_code` | — | Q4 |
| IDX-09 | `IX_FacilityMaintenance_NotifyStatus_Facility` | `FacilityMaintenance` | `notify_status`, `campus_facility_id` | — | Q4 |

```sql
CREATE NONCLUSTERED INDEX IX_SpaceBooking_Space_Status_Start
    ON dbo.SpaceBooking (campus_space_code, status, requested_start_time)
    INCLUDE (requested_end_time);
GO

CREATE NONCLUSTERED INDEX IX_SpaceBooking_Status_StartTime
    ON dbo.SpaceBooking (status, requested_start_time)
    INCLUDE (campus_space_code, requested_end_time);
GO

CREATE NONCLUSTERED INDEX IX_SpaceMaintenance_Space_Status_Impact
    ON dbo.SpaceMaintenance (campus_space_code, status, impact_level)
    INCLUDE (start_time, completion_time);
GO

CREATE NONCLUSTERED INDEX IX_FacilityMaintenance_Facility_Status_Impact
    ON dbo.FacilityMaintenance (campus_facility_id, status, impact_level)
    INCLUDE (start_time, completion_time);
GO

CREATE NONCLUSTERED INDEX IX_CampusFacility_SpaceCode
    ON dbo.CampusFacility (campus_space_code)
    INCLUDE (campus_facility_id, facility_type);
GO

CREATE NONCLUSTERED INDEX IX_CampusFacility_Type_Space
    ON dbo.CampusFacility (facility_type, campus_space_code)
    INCLUDE (status);
GO

CREATE NONCLUSTERED INDEX IX_CampusSpace_Capacity_Status
    ON dbo.CampusSpace (capacity)
    INCLUDE (current_status, space_type, space_name, building, floor, room_number);
GO

CREATE NONCLUSTERED INDEX IX_SpaceMaintenance_NotifyStatus_Space
    ON dbo.SpaceMaintenance (notify_status, campus_space_code);
GO

CREATE NONCLUSTERED INDEX IX_FacilityMaintenance_NotifyStatus_Facility
    ON dbo.FacilityMaintenance (notify_status, campus_facility_id);
GO
```

### 6.1. T-SQL conformance

- The script opens with `USE [SpaceBookingDB_Phase2]; GO`.
- Each `CREATE INDEX` statement is followed by a `GO` batch separator per the pipeline T-SQL scripting rules.
- Index names follow the `IX_<Table>_<KeyColumns>` convention; none conflict with the auto-named PK / UNIQUE indexes from Step 10.

---

## 7. Execution Restriction

Per `step-15-index-tuning/INSTRUCTION.md` — **DO NOT RUN AFTER IMPLEMENTATION**. The SQL artifact is generated for review only and is not executed against `SpaceBookingDB_Phase2`. Optional (commented-out) post-implementation verification against `sys.indexes` is included at the end of the SQL file for later use.

---

## 8. Traceability Summary

| Tuning target | Source statement | Index(es) |
|---|---|---|
| Booking conflict check — overlap | `12-concurrency-implementation-G02.sql` `sp_SubmitSpaceBooking` / `sp_ApproveSpaceBooking` → 11 §4.1.3 / §4.2.2 | IDX-01 |
| Booking conflict check — blocking maintenance | same → BR-02 / BR-09 | IDX-03 |
| Booking conflict check — advisory notification | `sp_SubmitSpaceBooking` step 3 → BR-13 | IDX-04, IDX-05 |
| Q1 — approved booking hours per space / semester | Step 15 requirement 1 | IDX-02 |
| Q2 — approved bookings by weekday & hour / semester | Step 15 requirement 2 | IDX-02 |
| Q3 — room finder (capacity + facility list + period) | Step 15 requirement 3 | IDX-06, IDX-07, IDX-01 |
| 04 — escalated-spaces lookup (BR-14) | Step 15 requirement 4 | IDX-08 |
| 04 — escalated-facilities lookup (BR-14) | Step 15 requirement 4 | IDX-09 |

All table and column identifiers are sourced from `10-schema-migration-G02.sql` (09 §4.2); no identifiers were invented.
