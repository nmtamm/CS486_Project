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

**Name:** Trịnh Võ Nam Kiệt

**Student ID:** 24125013

**Task:** Add 5 queries

## Tasks have been done
1. Find the current distribution of bookings across all statuses
2. Find which spaces have the most pending booking requests waiting for approval
3. Find which spaces generate the most maintenance requests and what problem types recur per space
4. Find the distribution of bookings by purpose
5. Find which users have the most bookings overall