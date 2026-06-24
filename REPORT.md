# Student Work Report

**Name:** Trịnh Võ Nam Kiệt

**Student ID:** 24125013

**Task:** Step 1 — Business Requirement Analysis

---

## 1. Structure

The [output document](outputs/01-business-req-analysis-G02.md) consists of 4 sections:

| Section                                    | Description                                                                                               |
| ------------------------------------------ | --------------------------------------------------------------------------------------------------------- |
| **1. Business Purpose**                    | Identifies the core problem, main objectives, and scope of the system.                                    |
| **2. Actors**                              | Lists user roles, responsibilities, and interactions with the system.                                     |
| **3. Business Data Entities & Attributes** | Identifies main entities, identifiers, required/optional attributes, and predefined values (enum).        |
| **4. Business Rules**                      | Extracts constraints, policies, business rules, lifecycle, and state transitions.                         |

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

| File | Purpose |
|------|---------|
| `06-sample-data-G02.sql` | Realistic sample data covering all valid tables, roles, types, and statuses |
| `06-normal-testcases-G02.sql` | SELECT queries to verify data integrity and constraint acceptance (expected: OK) |
| `06-exceptional-testcases-G02.sql` | INSERT statements that violate constraints (expected: FAIL) |

## Normal Test Cases

These SELECT queries verify that the database **accepts** valid data. Categories:

| Category | Description |
|----------|-------------|
| Record counts | Verify each table has the expected number of rows |
| FK integrity (no orphans) | Check that all foreign key values reference existing parent records |
| CHECK constraint acceptance | Verify valid enum values, positive numbers, and data ranges are accepted |
| UNIQUE constraint | Verify unique columns (e.g., email) have no duplicates |
| Business logic | Verify status coverage, time ordering, and lifecycle completeness |

## Exceptional Test Cases

These INSERT statements verify the database **rejects** invalid data. Categories:

| Constraint Type | Description |
|----------------|-------------|
| CHECK — invalid enum values | Out-of-range roles, statuses, types, and purpose values |
| CHECK — numeric/business rules | Zero/negative capacity, quantity, participants; backward time ranges |
| CHECK — conditional logic | Rejected booking without rejection reason; completed maintenance without completion info |
| UNIQUE — duplicate email | Attempted insert with an existing email address |
| FOREIGN KEY — non-existent reference | Reference to non-existent primary keys across all FK relationships |

## Constraint Coverage Summary

| Implemented Constraint | Normal Test | Exception Test |
|------------------------|-------------|----------------|
| CHECK role in (...) | TC-N13 | TC-01 |
| CHECK account_status in (...) | TC-N14 | TC-02 |
| UNIQUE email | TC-N15 | TC-03 |
| CHECK space_type in (...) | TC-N16 | TC-04 |
| CHECK current_status in (...) | TC-N17 | TC-05 |
| CHECK capacity > 0 | TC-N18 | TC-06 |
| CHECK facility_name in (...) | — | TC-07 |
| CHECK quantity > 0 | TC-N19 | TC-08 |
| CHECK purpose in (...) | TC-N20 | TC-11 |
| CHECK booking_status in (...) | TC-N21 | TC-12 |
| CHECK end_time > start_time | TC-N22 | TC-13 |
| CHECK expected_participants > 0 | TC-N23 | TC-14 |
| CHECK rejected → reason NOT NULL | TC-N24, N25 | TC-15 |
| CHECK problem_type in (...) | TC-N26 | TC-16 |
| CHECK status in (...) | TC-N27 | TC-17 |
| CHECK completed → info NOT NULL | TC-N28 | TC-18 |
| FK Space → BookingRequest | TC-N07 | TC-19 |
| FK Users → BookingRequest (requester) | TC-N08 | TC-20 |
| FK Space → MaintenanceRecord | TC-N11 | TC-21 |
| FK Users → MaintenanceRecord (reporter) | TC-N12 | TC-22 |
| FK Users → BookingRequest (approver) | — | TC-23 |
| FK Users → BookingRequest (check-in) | — | TC-24 |
| FK Users → BookingRequest (completion) | — | TC-25 |
| FK Users → MaintenanceRecord (assigned) | — | TC-26 |
| FK Space → SpaceFacility | TC-N09 | TC-09 |
| FK Facility → SpaceFacility | TC-N10 | TC-10 |

## Business Rules Enforced by the Database

| BR | Description | Verification |
|----|-------------|-------------|
| BR-01 | User roles limited to predefined values | TC-N13, TC-01 |
| BR-02 | Account statuses limited to predefined values | TC-N14, TC-02 |
| BR-03 | Space types limited to predefined values | TC-N16, TC-04 |
| BR-04 | Space statuses limited to predefined values | TC-N17, TC-05 |
| BR-05 | Booking purposes limited to predefined values | TC-N20, TC-11 |
| BR-06 | Booking statuses limited to predefined values | TC-N21, TC-12 |
| BR-13 | Maintenance statuses limited to predefined values | TC-N27, TC-17 |
| BR-19 | Rejected booking must store rejection reason | TC-N24, TC-N25, TC-15 |
| BR-21 | M:N Space–Facility via junction table with quantity | TC-N09, TC-N10, TC-09, TC-10 |

## Business Rules Not Enforced by the Database

These BRs require **application-layer logic or triggers** that are not implemented in the current DDL:

| BR | Description | Reason Not Enforceable |
|----|-------------|----------------------|
| BR-07 | Approval by facility staff or manager | FK only validates user existence, not role |
| BR-08 | Pending → approved/rejected only | No status-transition trigger |
| BR-09 | Allowed booking status transitions | No status-transition trigger |
| BR-10 | No overlapping approved bookings | No overlap-detection trigger |
| BR-11 | Unavailable spaces cannot be booked | No cross-table validation trigger |
| BR-12 | Any role may book any space type | Permission logic, not DB-enforceable |
| BR-14 | Prevent booking when space under maintenance | No synchronization trigger |
| BR-15 | Check-in records actual start, staff, condition | Workflow logic, no trigger |
| BR-16 | Check-out records actual end, condition, notes | Workflow logic, no trigger |
| BR-17 | No-show from approved | Requires scheduled job |
| BR-18 | Historical records retained indefinitely | Requires retention policy |
| BR-20 | Facility manager manages space catalog | Authorization logic |

## Model Usage

**Big Pickle (from the default provider):** Primary model for all three files.