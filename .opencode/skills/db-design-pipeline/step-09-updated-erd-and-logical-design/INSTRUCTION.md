# Step 9: Design Update

## 1. Task Identity

Perform **Phase 2 — Design Update** for the Campus Space Management System.

Create the required artifact:

```text
outputs/09-updated-erd-and-logical-design-G02.md
```

The artifact must update the Phase 1 conceptual ERD and relational schema so that the database design supports:

1. maintenance impact levels;
2. advisory notification and acknowledgement records;
3. instant and staff-approved booking paths;
4. prevention of conflicting approved bookings under concurrent operations; and
5. the new reporting needs, especially identifying bookings affected by maintenance escalation.

This task is a **design artifact**, not a SQL migration, concurrency implementation, data-generation script, or query implementation. Include implementation-oriented notes only when they explain how the design supports later Phase 2 steps.

---

## 2. Mandatory Input Files

Read the following files completely before generating the artifact.

### 2.1. Authoritative Phase 2 requirements

1. `CS486_Project_Phase02(2).md`
2. `new_requirement.md`

These files are the highest-priority sources for the changed requirements.

### 2.2. Phase 1 baseline artifacts

Read all previous artifacts in `outputs/`, especially:

1. `outputs/01-business-req-analysis-G02.md`
2. `outputs/02-erd-design-G02.md`
3. `outputs/03-logical-design-G02.md`
4. `outputs/04-design-validation-G02.md`
5. `outputs/05-db-definition-G02.sql`

Use the Phase 1 artifacts as the baseline. Preserve unchanged entities, attributes, keys, relationships, terminology, and naming wherever possible.

### 2.3. Phase 2 predecessor artifact

Read:

```text
outputs/08-requirement-change-analysis-G02.md
```

Treat Step 08 as an analysis input, not as unquestionable truth. Validate every proposed change against the authoritative Phase 2 requirement. Correct unsupported assumptions, incomplete modelling, cardinality problems, or normalization problems in Step 09 and clearly document any correction.

### 2.4. Supporting project context

Read:

1. `business-requirement.md`
2. `CS486_Project(2).md`

Use these files to understand the original business context and Phase 1 deliverable conventions.

---

## 3. Source-Priority Rules

When sources conflict, apply this order:

1. Phase 2 project specification and `new_requirement.md`;
2. Phase 2 Step 08 requirement-change analysis, after validation;
3. Phase 1 implemented schema in `05-db-definition-G02.sql`;
4. Phase 1 logical design in `03-logical-design-G02.md`;
5. Phase 1 conceptual ERD and earlier analysis artifacts.

Do not silently invent missing policy details.

For example, the Phase 2 requirement says that instant approval applies to **selected space types**, but it does not identify those types. Do not assume that they are classrooms and auditoriums unless another authoritative project file explicitly states this. Model the eligibility mechanism generically or state the unresolved policy assumption clearly.

---

## 4. Required Design Reasoning

Before writing the output, determine the minimum correct changes to the Phase 1 model.

### 4.1. Maintenance impact levels

The updated design must distinguish at least:

- `out_of_service`: overlapping booking or approval is prohibited;
- `advisory`: the space remains bookable, but the requester must be informed and acknowledgement must be recorded.

The design must support:

- several active maintenance records for one space at the same time;
- different impact levels among those active records;
- escalation and downgrade while maintenance remains open;
- temporal overlap between a maintenance period and a booking period;
- finding approved bookings affected by escalation to `out_of_service`.

Review whether the existing `SpaceMaintenance.start_time`, `completion_time`, and `status` are sufficient to represent an open maintenance interval. State how an open-ended interval is interpreted when `completion_time` is null.

### 4.2. Advisory acknowledgements

Do not model acknowledgement only as an undifferentiated Boolean on `SpaceBooking` when multiple active advisories may exist.

The design must preserve which advisory maintenance records were disclosed for which booking. Prefer a normalized associative entity/relation such as:

```text
BookingAdvisoryAcknowledgement
```

or an equally traceable design.

At minimum, the acknowledgement design must identify:

- the booking;
- the advisory maintenance record;
- when acknowledgement occurred;
- the acknowledging requester, if not safely derivable from the booking;
- any necessary uniqueness rule preventing duplicate acknowledgement of the same advisory for the same booking.

Explain whether acknowledgements are a snapshot of advisories active at submission time. Historical acknowledgements must remain valid even if the maintenance record is later completed, escalated, downgraded, or edited.

### 4.3. Instant booking and staff approval

The design must support both approval paths:

1. automatic approval at submission time for policy-eligible requests;
2. the existing staff approval workflow for other requests.

Review whether Phase 1 `BookingApproval` can represent both paths without losing auditability.

The updated design must make it possible to determine:

- whether approval was automatic or decided by staff;
- when approval occurred;
- the staff member when staff approval was used;
- the absence of a staff member for automatic approval without violating referential integrity;
- the decision or booking status consistently.

Do not create contradictory sources of truth between `SpaceBooking.status` and `BookingApproval.decision`. State the consistency rule.

A generic eligibility design may be placed on `CampusSpace`, `space_type`, or a separate policy/configuration relation. Choose and justify the design based on normalization, flexibility, and the actual requirements.

### 4.4. Concurrent booking and approval

Concurrency control is primarily implemented in later artifacts, but Step 09 must expose all data needed to enforce the invariant:

```text
For the same campus space, no two approved bookings may overlap.
```

Use the half-open interval overlap rule unless the project defines another rule:

```text
existing_start < requested_end
AND requested_start < existing_end
```

The invariant must apply to both instant approval and staff approval.

In the design artifact:

- identify the invariant and its participating attributes;
- state that ordinary `CHECK` and `UNIQUE` constraints cannot enforce general time-range overlap in SQL Server;
- classify it for transactional enforcement by a stored procedure/transaction/locking solution in Steps 11–13;
- do not present a normal index alone as a complete concurrency guarantee;
- ensure every approval path uses the same protected operation or invariant.

Do not turn detailed transaction scripts into part of this artifact.

### 4.5. Reporting support

Verify that the updated schema contains sufficient data for all four required reports:

1. total approved booking hours of each space for a semester;
2. approved booking count by weekday and hour for a semester;
3. available spaces satisfying capacity and a required facility list during a requested period;
4. approved bookings affected by escalation of maintenance to `out_of_service`.

For each report, identify the required relations and attributes. Do not write the final analytical SQL here.

For report 4, explain whether affected bookings are derived dynamically from maintenance and booking intervals or persisted in a separate relation. Avoid storing redundant derived data unless there is a justified business need for an immutable contact/action record.

---

## 5. Required Output Structure

Generate `outputs/09-updated-erd-and-logical-design-G02.md` with the following sections in this exact order.

# Updated ERD and Logical Database Design

Include group number, phase, task name, and generation date.

### 1. Design Scope and Source Baseline

Briefly state:

- what this artifact updates;
- which Phase 1 artifacts form the baseline;
- which Phase 2 requirements drive the changes;
- what is intentionally deferred to later migration and concurrency artifacts.

### 2. Design Decisions and Change Summary

Provide a concise table with columns:

| Design Item | Change Type | Phase 1 Design | Updated Design | Requirement Rationale |

Include every added, modified, and unchanged-but-affected entity/relation.

Explicitly record any correction or refinement made to Step 08.

### 3. Updated Conceptual ERD

#### 3.1. Mermaid ER Diagram

Use Mermaid `erDiagram`, consistent with the style of `02-erd-design-G02.md`.

Requirements:

- include all Phase 1 entities, not only changed entities;
- show all newly added entities and relationships;
- show PK, FK, and UK markers;
- show important domain values in attribute comments where readable;
- use SQL Server-compatible logical data type names consistently with the existing design;
- show accurate Crow's Foot cardinalities and optionality;
- ensure every FK shown in an entity has a corresponding relationship;
- ensure every relationship is supported by an FK in the logical schema.

#### 3.2. Entity Change Descriptions

For every changed or new entity, describe:

- purpose;
- added/modified attributes;
- why the entity or attribute is required;
- participation and cardinality;
- historical/audit behaviour.

#### 3.3. Relationship Summary

Provide a relationship table with:

| ID | Entity A | Relationship | Entity B | Cardinality | Participation | Change Status | Rationale |

Retain existing relationship IDs where the relationship is unchanged. Assign new sequential IDs to new relationships.

### 4. Updated Relational Schema

#### 4.1. Relational Schema Diagram

Use Mermaid `flowchart LR`, matching the established style of `03-logical-design-G02.md`.

Use this notation:

- `🔑` = Primary Key;
- `🔗` = Foreign Key;
- `⭐` = Candidate/Unique Key;
- **bold** attribute name = PK;
- *italic* attribute name = FK;
- ***bold italic*** = both PK and FK.

Each relation must be a separate subgraph. Connect each FK attribute node directly to its referenced candidate/primary key attribute node.

Include every Phase 1 relation and every new relation.

#### 4.2. Relation Definitions

For each changed or new relation, provide compact relational notation and a schema table containing:

| Attribute | SQL Server Data Type | Nullability | Key/Constraint | Default | References / Rule |

Requirements:

- retain Phase 1 names and types unless a change is necessary;
- make FK targets explicit as `Relation.attribute references Relation.attribute`;
- define composite PKs or UKs for associative relations;
- define valid domains with `CHECK` constraints;
- distinguish database-enforceable constraints from transactional or application rules;
- do not add physical indexes in this section except as clearly labelled recommendations for later analysis.

#### 4.3. Key and Integrity Constraint Summary

List:

- all new primary keys;
- all new foreign keys;
- all new candidate/unique keys;
- relevant `CHECK`, `NOT NULL`, and default constraints;
- cross-row or cross-table rules that require transaction logic, trigger, or stored procedure.

### 5. Updated Business Rule Enforcement Map

Use the business-rule identifiers from Phase 1 and Step 08 consistently.

Include:

- all Phase 1 rules BR-01 through BR-10;
- all valid modified/new Phase 2 rules identified in Step 08;
- corrections where Step 08 used unsupported assumptions.

Use columns:

| Business Rule ID | Updated Rule | Status | Enforcement Mechanism | Relations | Attributes | Design Notes / Deferred Artifact |

Allowed enforcement classifications include:

- PRIMARY KEY;
- FOREIGN KEY;
- UNIQUE;
- CHECK;
- NOT NULL;
- DEFAULT;
- Composite Key;
- Transactional Stored Procedure;
- Trigger;
- Application/Policy Logic;
- Derived Query.

Every rule must appear exactly once. Do not claim that a `CHECK` constraint can query another row or table in SQL Server.

### 6. Concurrency-Sensitive Integrity Requirements

Document, without implementing SQL:

- the booking overlap race condition;
- concurrent instant booking versus instant booking;
- instant booking versus staff approval;
- approval versus maintenance escalation;
- the shared invariant that all approval paths must enforce;
- the data access boundaries that later concurrency design must lock or serialize.

Add a traceability table:

| Concurrency Scenario | Relations/Rows Involved | Integrity Risk | Required Atomic Operation | Deferred To |

Refer detailed solutions to artifacts 11–13.

### 7. Reporting Support Matrix

Use columns:

| Report | Relations | Required Attributes | Join/Filter Basis | Supported? | Design Note |

Cover all four Phase 2 reports.

### 8. Phase 1 to Phase 2 Traceability Matrix

Use columns:

| Requirement / BR | Phase 1 Element | Phase 2 Change | ERD Element | Relation/Constraint | Downstream Artifact |

Trace every Phase 2 design requirement to a visible ERD and relational-schema element.

### 9. Design Validation Checklist

Provide explicit pass/fail checks for:

- all Phase 1 entities preserved unless justified;
- all new requirements represented;
- multiple simultaneous advisories supported;
- per-advisory acknowledgement traceability supported;
- maintenance escalation and affected-booking discovery supported;
- automatic and staff approval distinguishable and auditable;
- overlap invariant defined for both approval paths;
- no unsupported selected-space-type assumption;
- ERD cardinalities match FKs;
- relation definitions match both diagrams;
- all relations satisfy at least 3NF at design level;
- report data requirements are supported;
- no placeholders or unresolved diagram errors remain.

### 10. Assumptions and Deferred Decisions

List only genuine unresolved items. Clearly distinguish:

- assumptions supported by the project files;
- policy details not provided by the requirements;
- implementation choices deferred to artifacts 10–16.

Do not conceal uncertainty by inventing values.

---

## 6. Important Modelling Constraints

1. Preserve the Phase 1 schema as the base; this is an update, not a redesign from scratch.
2. Keep names consistent across the ERD, relational diagram, schema definitions, enforcement map, and traceability matrix.
3. Use `campus_space_code` consistently as `NVARCHAR`, correcting any accidental `INT` declaration in earlier diagrams.
4. Do not make `facility_type` globally unique if the implementation allows the same facility type in different spaces. Validate the actual Phase 1 DDL and preserve its real key semantics.
5. Do not rely only on `CampusSpace.current_status` to determine temporal maintenance availability. Booking conflict with maintenance must be based on active maintenance records and overlapping periods; `current_status` may remain a convenience/current-state attribute.
6. An advisory acknowledgement must be tied to the specific advisory or advisories disclosed, not merely to the existence of some advisory.
7. Historical acknowledgement records must not disappear when maintenance status changes.
8. Do not assume escalation automatically cancels bookings. The requirement asks the system to identify affected approved bookings so staff can contact requesters.
9. Avoid storing report results as base data unless explicitly justified.
10. Do not include executable migration SQL in the Markdown artifact.

---

## 7. Workflow Execution Order

Follow this sequence strictly.

### Step 1 — Internal Scan

- Read all mandatory inputs completely.
- Extract the exact Phase 1 entities, attributes, PKs, FKs, UKs, checks, defaults, and implemented constraints.
- Extract all Phase 2 changed requirements.
- Compare Step 08 proposals with the source requirements.
- Identify unsupported assumptions and normalization gaps.

### Step 2 — Design Resolution

- Determine changed/new conceptual entities and relationships.
- Determine changed/new logical relations, attributes, and constraints.
- Resolve acknowledgement multiplicity.
- Resolve approval-path audit modelling.
- Define the overlap invariant and temporal rules.
- Confirm support for all four reports.

### Step 3 — Artifact Generation

Generate all ten required sections in order.

Keep the ERD and relational schema synchronized while writing. Do not generate one diagram independently of the other.

### Step 4 — Consistency Review

Verify:

- every ERD entity maps to a relation;
- every ERD relationship maps to an FK or justified associative relation;
- every FK references a declared PK/UK of the same compatible type;
- all business rules map to an enforcement mechanism;
- all Phase 2 requirements appear in the traceability matrix;
- all Mermaid node IDs and references are valid;
- terminology matches the actual project artifacts.

### Step 5 — Export

Save only the final reviewed artifact to:

```text
outputs/09-updated-erd-and-logical-design-G02.md
```

Do not overwrite Phase 1 artifacts.

---

## 8. Final Quality Standard

The final artifact must be self-contained and usable as the direct design basis for:

- `10-schema-migration-G02.sql`;
- `11-concurrency-design-G02.md`;
- `12-concurrency-implementation-G02.sql`;
- `13-concurrency-tests-G02/`;
- `14-data-generator-G02/`;
- `15-index-tuning-report-G02.md`; and
- `16-analytical-queries-G02.sql`.

A reader must be able to determine exactly what changed from Phase 1, why it changed, how it is represented in the ERD and relations, which rules are declaratively enforceable, and which rules require later transactional implementation.
