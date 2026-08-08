# Student Work Report

**Name:** Trịnh Võ Nam Kiệt

**Student ID:** 24125013

**Task:** Step 1 — Business Requirement Analysis

---

## 1. Structure

The [output document](outputs/01-business-req-analysis-G02.md) consists of 4 sections:

| Section                                    | Description                                                                                        |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| **1. Business Purpose**                    | Identifies the core problem, main objectives, and scope of the system.                             |
| **2. Actors**                              | Lists user roles, responsibilities, and interactions with the system.                              |
| **3. Business Data Entities & Attributes** | Identifies main entities, identifiers, required/optional attributes, and predefined values (enum). |
| **4. Business Rules**                      | Extracts constraints, policies, business rules, lifecycle, and state transitions.                  |

## 2. Iterative clarification loop
Ambiguous points were resolved via the `question` tool before finalizing business rules.

## 3. Workflow execution
Pipeline follows a strict 3-step process:
1. **Internal deep scan** — identify ambiguities and gaps.
2. **Interactive clarification** — discuss with user to resolve ambiguities.
3. **Compile & export** — produce the 4-section document.

## 4. References
- **Prompt:** [INSTRUCTION.md](.opencode/skills/db-design-pipeline/step-01-business-requirement-analysis/INSTRUCTION.md)
- **Output:** [01-business-requirement-analysis.md](outputs/01-business-req-analysis-G02.md)

---

# Student Work Report

**Name:** Võ Huy Dâng  
**Student ID:** 20125022  
**Task:** Step 2 — Conceptual Database Design (ERD)  

---

## 1. Config Restructuring
- Removed `template.md` and `example.md` from the step config folder because they were redundant and not useful.
- Kept only `INSTRUCTION.md` as the centralized and sufficient source of instructions for the agent.

## 2. Pipeline Workflow
Followed an iterative 3-step pipeline:
1. Generate the initial `INSTRUCTION.md`.
2. Generate the step output (`02-erd-design-G02.md`).
3. Refine `INSTRUCTION.md` based on imperfections found in the output, then repeat step 2 until the output is correct.

## 3. Generating and Refining INSTRUCTION.md
Refining `INSTRUCTION.md` was the main focus of this task. Examples for rules added:
- **Mermaid Diagram Rules:** Explicitly defined syntax rules for the Mermaid `erDiagram`, including key markers (`PK`, `FK`, `UK`), correct data types, and Crow's Foot cardinality notations.
- **Consistency with Step 1:** Ensured the conceptual design strictly matches the entities, relationships, attributes, and enums defined in the Business Requirement Analysis (`01-business-req-analysis-G02.md`).
- **Document Requirements:** Ensured the final output document strictly adheres to the requested four-section structure (ERD, Entity Descriptions, Relationship Summary, Traceability).
- **Prohibiting Non-existing Rules:** Added an explicit instruction forbidding the agent from referencing non-existing rules or inventing rule IDs, as simple "consistency" guidelines were not enough to prevent hallucinations.
- **Visual vs. Textual Constraints:** Mandated that constraints like Key, Referential Integrity, Domain, and Participation must be shown in the diagram, and any undisplayable constraints (such as conditional checks) must be documented textually under a "Constraints (from Business Rules)" subheading.

## 4. Responding to PR #2 Feedback
Successfully addressed feedback from Pull Request #2 (https://github.com/nmtamm/CS486_Project/pull/2):
- Replaced generic `string` data types in the Mermaid diagram with appropriate SQL Server data types (`varchar` for non-Unicode/IDs, `nvarchar` for Unicode text/names).
- Fixed the markdown rendering issue where lifecycle state transitions ran together on the same line by appending `<br>` HTML tags.
- Added explicit references to basic enum restrictions (`BR-01`, `BR-02`, `BR-04`, `BR-05`) in the entity descriptions constraints.

## 5. Other Tasks Completed
- Set up proper formatting for composite keys (comma-separated `PK, FK` markers to prevent Mermaid parsing errors).
- Standardized relationship cardinalities and participation constraints in both the ERD diagram and the Relationship Summary table for strict consistency.
- Added predefined values (enums/options) mapping to the pipeline to ensure status, type, and purpose options are explicitly documented in the ERD design.


## 6. Model Usage
Used and evaluated two models for the task:
- **Gemini Flash (with Google as provider) in opencode:** This option took too long (more than 15 minutes for a single prompt) and cost too many tokens.
- **Big Pickle (from the default provider):** Used as the primary model.

---

# Student Work Report

**Name:** Trần Trung Hậu

**Student ID:** 24125055

**Task:** Step 3 — Logical Database Design

---

## Workflow
1. Explore existing project artifacts and current task
2. Define initial Output document structure
3. Define Workflow execution order
4. Generate `INSTRUCTION.md` and required artifact
5. Redefine the Output document structure
6. Refine `INSTRUCTION.md` based on output artifact until the output looks "good"

## Model Usage
**Big Pickle (from the default provider):** Used as the primary model.

## Response to PR #8 feedback
1. **Improve the readability of Relational Schema**
    - Changed the Mermaid diagram type from `classDiagram` to `flowchart LR` to produce better resemblance a physical relational schema representation
    - Add visual key indicators and Text Formatting Rules for easier identify keys
2. **Remove unnecessary section 2. Detail table schema**

---

# Student Work Report

**Name:** Nguyễn Minh Tâm
**Student ID:** 24125042
**Task:** Step 4 — Validate database design

## Workflow
1. Check if all entities are included or not
2. Check if all relationship are clearly explained in the relational schema
3. Check if all cardinalities are clearly included in the ERD
4. Check if the constraints are mentioned in relational schema or not

## Model Usage
**Big Pickle (from the default provider):** Used as the primary model.

## Response to Issue #10
Rewrite instruction for step 01 and use Big Pickle to regenerate the output for this step

---

# Student Work Report

**Name:** Nguyễn Minh Tâm

**Student ID:** 24125042

**Task:** Step 5 - Database Implementation

## Workflow
1. Create database
2. Create tables
3. Add constraints and relationships between tables

## Model Usage
**Big Pickle (from the default provider):** Used as the primary model.

---

# Student Work Report

**Name:** Võ Huy Dâng

**Student ID:** 20125022

**Task:** Step 5 - Database Implementation & ERD Refinement

## Tasks
1. Identify and resolve inconsistencies/hallucinations in conceptual design constraints.
2. Validate database initialization and schema creation in SQL Server.
3. Change table Users from User in the database definition file to avoid SQL Server reserved keyword.

## Model Usage
**Big Pickle (from the default provider):** Used as the primary model.

---

# Student Work Report

**Name:** Trần Trung Hậu & Trịnh Võ Nam Kiệt

**Student ID:** 24125055 & 24125013

**Task:** Step 6 — Sample Data & Test Cases

## Deliverables

Step 6 produces **3 separate SQL files** built from the DDL in Step 5:

| File                               | Purpose                                                                          |
| ---------------------------------- | -------------------------------------------------------------------------------- |
| `06-sample-data-G02.sql`           | Realistic sample data covering all valid tables, roles, types, and statuses      |
| `06-normal-testcases-G02.sql`      | SELECT queries to verify data integrity and constraint acceptance (expected: OK) |
| `06-exceptional-testcases-G02.sql` | INSERT statements that violate constraints (expected: FAIL)                      |

## Normal Test Cases

These SELECT-based test cases verify that the database contains valid data and satisfies all implemented constraints.

### Categories

| Category                    | Description                                                    |
| --------------------------- | -------------------------------------------------------------- |
| Record counts               | Verify expected number of rows for each table                  |
| Primary key uniqueness      | Verify no duplicate primary key values exist                   |
| Unique constraints          | Verify unique attributes and candidate keys remain unique      |
| Foreign key integrity       | Verify no orphaned references exist                            |
| Check constraint validation | Verify all stored values satisfy implemented CHECK constraints |
| Not-null validation         | Verify required attributes contain values                      |
| Status coverage             | Verify all expected statuses are represented                   |
| Business scenarios          | Verify realistic operational scenarios exist in the dataset    |

### Normal Test Coverage

| Coverage Area          | Test Cases      |
| ---------------------- | --------------- |
| Record counts          | TC-N01 – TC-N08 |
| Primary key uniqueness | TC-N09 – TC-N16 |
| Unique constraints     | TC-N17 – TC-N22 |
| Foreign key integrity  | TC-N23 – TC-N33 |
| CHECK constraints      | TC-N34 – TC-N47 |
| NOT NULL constraints   | TC-N48 – TC-N52 |
| Status coverage        | TC-N53 – TC-N56 |
| Business scenarios     | TC-N57 – TC-N60 |


## Exceptional Test Cases

These INSERT statements intentionally violate database constraints.

Every exceptional test case is expected to fail.

### Categories

| Constraint Type     | Description                                     |
| ------------------- | ----------------------------------------------- |
| Primary Key         | Duplicate primary key values                    |
| Unique Constraint   | Duplicate unique values                         |
| Foreign Key         | References to non-existent parent records       |
| CHECK Constraint    | Invalid enum values and invalid business values |
| NOT NULL Constraint | Missing mandatory attributes                    |

### Exceptional Test Coverage

| Coverage Area                | Test Cases    |
| ---------------------------- | ------------- |
| Primary Key violations       | TC-01 – TC-07 |
| Unique constraint violations | TC-08 – TC-13 |
| Foreign key violations       | TC-14 – TC-24 |
| CHECK constraint violations  | TC-25 – TC-38 |
| NOT NULL violations          | TC-39 – TC-45 |


## Constraint Coverage Summary

| Implemented Constraint                            | Normal Test   | Exception Test |
| ------------------------------------------------- | ------------- | -------------- |
| PRIMARY KEY constraints                           | TC-N09–TC-N16 | TC-01–TC-07    |
| UNIQUE email                                      | TC-N17        | TC-08          |
| UNIQUE facility_name                              | TC-N19        | TC-09          |
| UNIQUE (building, floor, room_number)             | TC-N18        | TC-10          |
| UNIQUE (campus_space_code, campus_facility_id)    | TC-N20        | TC-11          |
| UNIQUE BookingApproval.space_booking_id           | TC-N21        | TC-12          |
| UNIQUE SpaceUsageSession.space_booking_id         | TC-N22        | TC-13          |
| FK SpaceBooking → CampusUser                      | TC-N23        | TC-14          |
| FK SpaceBooking → CampusSpace                     | TC-N24        | TC-15          |
| FK CampusSpaceFacility → CampusSpace              | TC-N25        | TC-16          |
| FK CampusSpaceFacility → CampusFacility           | TC-N26        | TC-17          |
| FK BookingApproval → SpaceBooking                 | TC-N27        | TC-18          |
| FK BookingApproval → CampusUser                   | TC-N28        | TC-19          |
| FK SpaceUsageSession → SpaceBooking               | TC-N29        | TC-20          |
| FK SpaceUsageSession → CampusUser                 | TC-N30        | TC-21          |
| FK SpaceMaintenance → CampusSpace                 | TC-N31        | TC-22          |
| FK SpaceMaintenance → CampusUser (reporter)       | TC-N32        | TC-23          |
| FK SpaceMaintenance → CampusUser (assigned staff) | TC-N33        | TC-24          |
| CHECK role values                                 | TC-N34        | TC-25          |
| CHECK account_status values                       | TC-N35        | TC-26          |
| CHECK space_type values                           | TC-N36        | TC-27          |
| CHECK current_status values                       | TC-N37        | TC-28          |
| CHECK capacity > 0                                | TC-N38        | TC-29          |
| CHECK purpose_type values                         | TC-N39        | TC-30          |
| CHECK booking status values                       | TC-N40        | TC-31          |
| CHECK expected_participants > 0                   | TC-N41        | TC-32          |
| CHECK requested_end_time > requested_start_time   | TC-N42        | TC-33          |
| CHECK approval decision values                    | TC-N43        | TC-34          |
| CHECK rejected booking requires rejection reason  | TC-N44        | TC-35          |
| CHECK quantity > 0                                | TC-N45        | TC-36          |
| CHECK maintenance problem_type values             | TC-N46        | TC-37          |
| CHECK maintenance status values                   | TC-N47        | TC-38          |
| NOT NULL constraints                              | TC-N48–TC-N52 | TC-39–TC-45    |


# Business Rules Enforced by the Database

The following business rules are directly enforced by the database implementation through PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, and NOT NULL constraints.

| BR  | Description                                             | Enforcement Mechanism                 | Verification  |
| --- | ------------------------------------------------------- | ------------------------------------- | ------------- |
| BR4 | Rejection reason is required when a booking is rejected | CHECK Constraint on `BookingApproval` | TC-N44, TC-35 |
| BR8 | A booking's start time must be before its end time      | CHECK Constraint on `SpaceBooking`    | TC-N42, TC-33 |



# Business Rules Not Enforced by the Database

The following business rules are defined in the business requirements but are not fully enforced by the current database implementation. They would require additional triggers, stored procedures, scheduled jobs, or application-layer logic.

| BR   | Description                                                                                                     | Reason Not Enforced                                                                        |
| ---- | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| BR1  | A space cannot have two approved bookings with overlapping time periods                                         | Requires overlap-detection trigger or stored procedure                                     |
| BR2  | A space under maintenance, temporarily closed, or retired cannot be booked                                      | Requires cross-table validation against `CampusSpace.current_status`                       |
| BR3  | Booking status must follow the workflow: pending → approved/rejected/cancelled → checked_in → completed/no-show | Requires status transition trigger or workflow logic                                       |
| BR5  | Approval decisions must be made by facility staff or facility manager                                           | Database validates user existence only, not user role                                      |
| BR6  | Check-in must be performed by facility staff                                                                    | Database validates user existence only, not user role                                      |
| BR7  | Expected participants must not exceed space capacity                                                            | Requires cross-table validation between `SpaceBooking` and `CampusSpace`                   |
| BR9  | Maintenance status `in_progress` should prevent new bookings for the space                                      | Requires trigger checking active maintenance records before booking creation               |
| BR10 | Historical records must be preserved (no hard deletes of completed bookings or maintenance)                     | Requires delete restrictions, auditing policy, soft-delete mechanism, or application logic |


## Model Usage

**Big Pickle (from the default provider):** Primary model for all three files.

---

# Student Work Report

**Name:** Nguyễn Minh Tâm
**Student ID:** 24125042
**Task:** Remove reserved word

## Tasks have been done
1. Remove reserved words when naming entity and table name
2. Add some additional guideline and notes for some instruction files
3. Rename the output files' names in AGENT.md
4. Regenerate output with the updated guidelines

---

# Student Work Report

**Name:** Nguyễn Minh Tâm

**Student ID:** 24125042

**Task:** Add 5 queries

## Tasks have been done
1. Find lists of booking that a specific staff accepted
2. Find users who always appear later after the requested start time
3. Find spaces that are booked most
4. Find spaces that are under maintenance
5. Find spaces with the highest booking cancellation rate

---

# Student Work Report

**Name:** Trần Trung Hậu
**Student ID:** 24125055
**Task:** Add 5 queries for Step 7

## Tasks have been done
1. Which approved bookings do not have any recorded check-in session yet?
2. Which completed bookings ended later than their requested end time?
3. Which spaces have never been booked?
4. Find spaces with the number of booking request where expected participants exceed the space capacity
5. How many unresolved maintenance records does each space currently have?

---

# Student Work Report

**Name:** Trịnh Võ Nam Kiệt

**Student ID:** 24125013

**Task:** Add 5 queries

## Tasks have been done
1. Find the current distribution of bookings across all statuses
2. Find the 5 spaces with the most pending booking requests
3. Find the 5 most common maintenance request problem types per space
4. Find the distribution of bookings by purpose
5. Find the 5 users with the most bookings

---

# Student Work Report

**Name:** Võ Huy Dâng

**Student ID:** 20125022

**Task:** Add 5 queries

## Tasks have been done
1. Find the total number of bookings and average expected participants for each space type
2. Find which departments have the highest number of "no-show" bookings
3. Find the most common rejection reasons provided by staff
4. Find which campus amenities/facilities are equipped in the spaces that receive the highest volume of booking requests
5. Find which classrooms or meeting rooms with a capacity of at least 5 people are currently available and equipped with a projector for upcoming group study sessions

## SQL Functions Explanation
- **`CAST` (in Query 1):** The `expected_participants` column is stored as an integer. In SQL Server, taking the average (`AVG`) of integers performs integer division and discards decimal values (e.g., averaging `1` and `2` returns `1`). Casting it to `DECIMAL` preserves the decimal points in the result.
- **`LOWER` (in Query 5):** Converts the facility names to lowercase before checking. This makes the search case-insensitive, ensuring that "Projector", "projector", and "PROJECTOR" are all matched correctly.

---

# Student Work Report

**Name:** Nguyễn Minh Tâm

**Student ID:** 24125042

**Task:** Step 8 — Requirement Change Analysis

# Task have been done
1. **Internal deep scan** — Analyzed the new requirement (maintenance impact levels, concurrent booking/approval, new reporting needs) against the existing 7 output artifacts.
2. **Interactive clarification** — Resolved 4 ambiguities via the `question` tool: instant booking space types (classroom & auditorium), advisory acknowledgement storage (boolean on SpaceBooking), impact level history (current level only), escalation handling (identify & report only).
3. **Final compilation** — Produced the 5-section document covering Business Purpose (modified), Business Data Entities (SpaceMaintenance + impact_level, SpaceBooking + advisory_acknowledged + is_instant_booking), Relationships (refined R2, R8), Business Rules (BR-02/BR-09 modified; BR-11 through BR-14 new), and Conflicts (3 concurrency conflicts with mitigations).

## Model Usage

**Big Pickle (from the default provider):** Used as the primary model.

---

# Student Work Report

**Name:** Trần Trung Hậu

**Student ID:** 24125055

**Task:** Step 9 — Updated ERD and Logical Database Design

# Task have been done

1. **Internal deep scan** 

    - Reviewed all Phase 1 artifacts (Steps 01–08)
    - Identified the existing ERD and relational schema
    - Analyzed the design changes required to support maintenance impact levels, advisory acknowledgements, concurrent booking, and the new reporting requirements

2. **Design update** 

    Updated the conceptual ERD and logical relational schema by extending: 
    - the maintenance and booking models, 
    - refining entities, 
    - attributes, 
    - relationships, 
    - keys, and 
    - constraints 

    while maintaining consistency with the original Phase 1 database design and preserving backward compatibility where appropriate.

3. **Design validation** 

    Verified that the updated design satisfies:
    - the revised business rules
    - supports advisory acknowledgement tracking
    - enables identification of bookings affected by maintenance escalation
    - preserves the booking conflict rule under concurrent operations
    - provides sufficient data structures for all required analytical reports

## Model Usage

**Big Pickle (from the default provider):** Used as the primary model.

---

# Student Work Report

**Name:** Nguyễn Minh Tâm

**Student ID:** 24125042

**Task:** Step 10 - Schema migration

# Task have been done

1. **Analyzed old vs. new schema** — produced a per-table and per-column mapping (keep / rename / modify / new) between the 7 Phase 1 tables and the 10 Phase 2 tables.
2. **Created the migration SQL** (`outputs/10-schema-migration-G02.sql`):
   - New database `SpaceBookingDB_Phase2` (Phase 1 `SpaceBookingDB` is only read, never modified)
   - New schema with all 10 tables, PK/FK/UNIQUE/CHECK constraints, and 3 triggers (BR-03 status transitions, BR-07 capacity, refined maintenance status)
   - Data migration preserving all IDs and relationships (8 users, 8 spaces, 6 facilities, 10 bookings, 6 approvals, 4 sessions, 6 maintenance records)
   - Data transformations: `facility_name → facility_type`, `is_instant_booking = 0`, `impact_level = 'out_of_service'`, `broken_projector → other`
   - Default value insertion: seeded `SpaceTypeBookingPolicy` (4 types) and `Semester` (9 rows), new mandatory attributes defaulted
   - Post-migration integrity validation queries (row counts, orphan FK, duplicate key checks)
3. **Documented the analytical process** (`outputs/10-schema-migration-G02.md`) covering the migration strategy, transformations, execution order, integrity validation, and assumptions (cross-referenced to `09` section numbers).

## Model Usage

**Big Pickle (from the default provider):** Used as the primary model.

---

# Student Work Report

**Name:** Võ Huy Dâng

**Student ID:** 20125022

**Task:** Schema Migration SQL Testing & T-SQL Pipeline Rules

# Task have been done

1. **Executed and Tested SQL Migration Scripts** — Ran and verified `outputs/05-db-definition-G02.sql` and `outputs/10-schema-migration-G02.sql` against MS SQL Server to validate DDL execution and data migration statements.
2. **Fixed T-SQL Batch Compilation Issues** — Identified query batching errors caused by missing `GO` statements. Refined `outputs/05-db-definition-G02.sql` and `outputs/10-schema-migration-G02.sql` by adding mandatory `GO` batch separators after all `CREATE TABLE` blocks and immediately preceding `CREATE TRIGGER` definitions.
3. **Updated Master Skill Guidelines (`.opencode/skills/db-design-pipeline/SKILL.md`)** — Added explicit T-SQL Scripting Rules for Microsoft SQL Server, enforcing `GO` batch separators before `CREATE TRIGGER`/`CREATE PROCEDURE` blocks and after `CREATE TABLE` definitions across all pipeline steps.
4. **Verified Post-Migration Data Integrity** — Confirmed clean execution of schema migration (`SpaceBookingDB_Phase2`) and post-migration validation queries (row counts, foreign key integrity, duplicate key checks).

## Model Usage

**Big Pickle (from the default provider):** Used as the primary model.

---

# Student Work Report

**Name:** Võ Huy Dâng

**Student ID:** 20125022

**Task:** Step 11 — Concurrency Design

# Tasks have been done

1. **Updated Step 11 Instruction** — Added constraint requiring all SQL reproduction scripts to use actual sample data from `outputs/06-sample-data-G02.sql` (real space codes, user IDs, and valid enum values). Explicitly prohibited inventing non-existent column names or space codes. Added requirement to cross-check INSERT column lists against the Phase 2 schema in `outputs/10-schema-migration-G02.sql`.
2. **Produced Concurrency Design Document** (`outputs/11-concurrency-design-G02.md`) — Covers system invariants (BR-01/BR-12 overlap prevention, BR-02/BR-09 maintenance blocking, BR-13 advisory notification, BR-03/BR-07 lifecycle/capacity), isolation level evaluation (`READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`, `SNAPSHOT`), chosen hybrid pessimistic locking model (`sp_getapplock` + `UPDLOCK, HOLDLOCK`), lock acquisition hierarchy, and transaction specifications for three core procedures (`sp_SubmitSpaceBooking`, `sp_ApproveSpaceBooking`, `sp_EscalateSpaceMaintenance`).
3. **Produced Concurrency Error 1 Reproduction Script** (`outputs/11-reproduce-concurrency-error1-G02.sql`) — Demonstrates double-allocation race condition on classroom `B201` (Lecture Room 201, capacity 60) using User 4 (lecturer) and User 5 (student) from the sample data.
4. **Produced Concurrency Error 2 Reproduction Script** (`outputs/11-reproduce-concurrency-error2-G02.sql`) — Demonstrates staff approval vs. maintenance escalation race condition on auditorium `A101` (Main Auditorium, capacity 200) using User 2, User 3 (facility_staff), User 4 (lecturer), and User 5 (student) from the sample data.
5. **Schema Alignment Validation** — Verified all INSERT column lists in the reproduction scripts match the actual Phase 2 `SpaceBooking` and `SpaceMaintenance` table definitions. Confirmed that `advisory_acknowledged` column (proposed in Step 08 but not implemented in Step 09/10 schema) is not referenced anywhere. Confirmed BR-13 advisory notification uses `FacilityMaintenance.notify_status` per the Step 09 logical design.

## Model Usage

**Big Pickle (from the default provider):** Used as the primary model.

---

# Student Work Report

**Name:** Trịnh Võ Nam Kiệt

**Student ID:** 24125013

**Task:** Step 12 — Concurrency Implementation

# Tasks have been done

1. **Created the Step 12 Instruction** (`.opencode/skills/db-design-pipeline/step-12-concurrency-implementation/INSTRUCTION.md`) — Defines Concurrency Implementation as a generic step that turns the Step 11 design into runnable T-SQL. Registered the outputs in the master skill (`SKILL.md` — required-output list + steps table).
2. **Scoped verification out of Step 12** — Moved testing to **Step 13** (`13-concurrency-tests-*`): Step 12 only produces the procedures and documents how each concurrency error is designed to be prevented; confirming the guards actually prevent them is not done here.
3. **Analytical process** — Generates `outputs/12-concurrency-implementation-G02.md` first, documenting the objective, reference files, implemented procedures, how each concurrency error is prevented, and run instructions.
4. **Procedure implementation** — Generates `outputs/12-concurrency-implementation-G02.sql` on top of the md, translating each transaction specification in the design document into working stored procedures for the target database.

## Model Usage

**Big Pickle (from the default provider):** Used as the primary model.

---

# Student Work Report

**Name:** Trịnh Võ Nam Kiệt

**Student ID:** 24125013

**Task:** Step 13 — Concurrency Tests

# Tasks have been done

1. **Created the Step 13 Instruction** (`.opencode/skills/db-design-pipeline/step-13-concurrency-tests/INSTRUCTION.md`) — Defines Concurrency Testing as the step that verifies the Step 12 implementation by re-running the Step 11 race interleavings through the implemented procedures and confirming the guards prevent the violations. Registered the outputs in the master skill (`SKILL.md` — required-output list + steps table).
2. **Test plan** — Generates `outputs/13-concurrency-tests-G02.md` first, documenting the objective, reference files, a test matrix mapping each concurrency error to its invariant and expected outcome, test results, and run instructions.
3. **Test script** — Generates `outputs/13-concurrency-tests-G02.sql` on top of the md, a single executable file with one test section per concurrency error that calls the Step 12 procedures and asserts the invariant holds.
4. **Deterministic testing** — Requires each test to be deterministic: a pass must mean the guard prevented the violation, not that the race happened not to occur. Failures are reported honestly rather than weakening assertions.

## Model Usage

**Big Pickle (from the default provider):** Used as the primary model.

---

# Student Work Report

**Name:** Nguyễn Minh Tâm

**Student ID:** 24125042

**Task:** Update Schema migration

## Tasks have been done:
1. Add notify_status column to SpaceMaintenance to notify staff if there is any update
2. Create function to check if a space is under maintenance or not
   - If there is an out-of-service record in SpaceMaintenace
   - If there is an out-of-service record of any Facility belong to that place in Facility Maintenance
3. Create function to check if a space is available or not
   - Check if that space is retired or temporarily closed
   - Check if that space is under maintenance or not
4. Update trigger in SpaceMaintenance.
   - Base on the status of the place using the previous function, set the correspoding status
   - Synchronize the notify_status column to correctly announce staff there is an insert/ update in SpaceMaintenance. After that, staff will run query 4 to announce related requester.
5. Add trigger in FacilityMaintenance
   - The logic is the same as trigger for SpaceMaintenance
6. Add trigger to only allow booking on available spaces
7. Add trigger to synchronize BookingApproval with SpaceBooking

---

**Name:** Võ Huy Dâng

**Student ID:** 20125022

**Task:** Step 14 — Sample Data Generation (`14-data-generator-G02`)

# Tasks have been done

1. **Created Data Generator Skill Instruction (`.opencode/skills/db-design-pipeline/step-14-data-generator/INSTRUCTION.md`)** — Defined step instructions, dependency graph, prerequisite reference selection rules, scale estimations, and execution flow. Updated master pipeline skill (`.opencode/skills/db-design-pipeline/SKILL.md`) to register `outputs/14-data-generator-G02/` and Step 14 in the steps table.
2. **Created Database Data Reset Script (`outputs/14-data-generator-G02/reset_database_data.sql`)** — T-SQL script to safely clear all rows in database tables in strict reverse Foreign Key dependency order (`FacilityMaintenance` -> `SpaceMaintenance` -> `SpaceUsageSession` -> `BookingApproval` -> `SpaceBooking` -> `CampusFacility` -> `CampusSpace` -> `SpaceTypeBookingPolicy` -> `CampusUser` -> `Semester`) and reseed IDENTITY counters to 0.
3. **Created Connection Diagnostic Script (`outputs/14-data-generator-G02/test_db_connection.py`)** — Python diagnostic script using `pyodbc` to verify connection parameters to MS SQL Server database `SpaceBookingDB_Phase2` and validate schema readiness across all 10 tables.
4. **Created Bulk Sample Data Generator Script (`outputs/14-data-generator-G02/generate_bulk_data.py`)** — Python generator script that populates prerequisite master data (9 semesters, 2,500 users, 60 spaces, 180 facilities, 1,500 maintenance records) and generates **100,000 `SpaceBooking` records**, **~50,000 `BookingApproval` records**, and **~50,000 `SpaceUsageSession` records** across 3 academic years (2023–2026). Temporarily disables status transition triggers during bulk ingestion (`ALTER TABLE SpaceBooking DISABLE TRIGGER ALL;`) and executes high-throughput bulk inserts (`fast_executemany`) in ~10 seconds.
5. **Created Verification Script (`outputs/14-data-generator-G02/verify_data_integrity.sql`)** — T-SQL script validating table row counts, foreign key integrity (0 orphans), workflow consistency, and zero schedule overlaps on approved/completed bookings.
6. **Created Step 14 Documentation (`outputs/14-data-generator-G02/README.md`)** — Comprehensive user documentation covering python virtual environment setup (`py -m venv .venv`), dependency installation (`pip install pyodbc faker`), `SpaceBookingDB_Phase2` connection settings, and step-by-step execution instructions.

## Model Usage

**Gemini 3.6 Flash (High):** Used as the primary model.

---

# Student Work Report

**Name:** Nguyễn Minh Tâm

**Student ID:** 24125042

**Task:** Fix data generation logic

## Current problem:
1. I have added column "notify_status" to SpaceMaintenance. Hence I need update the logic a bit
2. Triggers are violated with current approach

## What have been done:
1. Ensure that triggers are not violated
2. Divide into patches and commit right after generate

## New flow:

### Update phase 5: Maintenance Data
1. Currently, only marks maximum 10 spaces under maintenance. The rest 50 are available for booking.
2. Add maintenance consisting 3 status, with the following percentage: 10% reported, 15% in_progress, 75% completed
3. Update `impact_level` of `SpaceMaintenance`
4. Update `notify_status` according to `impact_level`
5. Do the same for `FacilityMaintenance`
6. 

### Update phase 6:
1. Insert `approved` or `pending` records to `SpaceMaintenance`
2. Use ID retrieved from database instead of manually count
3. Update status of `SpaceBooking` from pending -> cancelled
4. Generate `BookingApproval` records, 85% approved for non-instant and 15% reject
5. Update status of `SpaceBooking` from approved -> checked_in -> completed
6. Update status of remaining records in `SpaceBooking` from checked_in -> no-show
7. Generate sessions for completed booking and stored to `SpaceUsageSession`
8.  