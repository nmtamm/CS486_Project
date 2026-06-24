# Báo cáo tiến độ

## Những gì đã làm

### 1. Cấu trúc lại pipeline skill
- Tổ chức lại `.opencode/skills/db-design-pipeline/` thành mỗi bước một thư mục con:
  - `step-01/INSTRUCTION.md`, `TEMPLATE.md`, `EXAMPLE.md`
  - `step-02/INSTRUCTION.md`
### 2. Bước 1 — Phân tích yêu cầu nghiệp vụ (hoàn thành, cần review)

Tài liệu gồm đúng 4 phần:

| Phần                                       | Mô tả                                                                                                      |
| ------------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| **1. Business Purpose**                    | Xác định vấn đề cốt lõi, mục tiêu chính và phạm vi của hệ thống.                                           |
| **2. Actors**                              | Liệt kê các vai trò người dùng, trách nhiệm và tương tác với hệ thống.                                     |
| **3. Business Data Entities & Attributes** | Xác định các thực thể chính, định danh, thuộc tính bắt buộc/không bắt buộc và các giá trị định sẵn (enum). |
| **4. Business Rules**                      | Trích xuất các ràng buộc, chính sách, quy tắc nghiệp vụ, lifecycle và state transition.                    |

### 3. Sử dụng vòng lặp tương tác
Trong quá trình sinh tài liệu, các điểm còn mơ hồ đã được giải quyết thông qua công cụ `question` trước khi hoàn thiện các quy tắc nghiệp vụ (business rules).

### 4. Thực thi workflow
Pipeline tuân theo quy trình 3 bước nghiêm ngặt:
1. **Quét sâu nội bộ** — xác định các điểm còn mơ hồ, thiếu sót.
2. **Làm rõ tương tác** — trao đổi với người dùng để giải quyết các điểm còn mơ hồ.
3. **Tổng hợp & xuất file** — tổng hợp và xuất tài liệu 4 phần.

### 5. Tham khảo
- **Prompt**: [INSTRUCTION.md](.opencode/skills/db-design-pipeline/step-01-business-requirement-analysis/INSTRUCTION.md)
- **Kết quả**: [01-business-requirement-analysis.md](outputs/01-business-req-analysis-G02.md)

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

**Name:** Trần Trung Hậu
**Student ID:** 24125055
**Task:** Step 6 - Sample Data Preparation

## Tasks
Generate sample data for exceptional cases testing

## Model Usage
**Big Pickle (from the default provider):** Used as the primary model.

## Tested Constraints

| Constraint                                                 | Test evidence |
| ---------------------------------------------------------- | -------- |
| User roles are limited to predefined values                | TC-01 |
| User account statuses are limited to predefined values     | TC-02 |
| User email uniqueness                                      | TC-03 |
| Space types are limited to predefined values               | TC-04 |
| Space statuses are limited to predefined values            | TC-05 |
| Space capacity must be positive                            | TC-06 |
| Facility names are limited to predefined values            | TC-07 |
| SpaceFacility quantity must be positive                    | TC-08 |
| SpaceFacility foreign key to Space                         | TC-09 |
| SpaceFacility foreign key to Facility                      | TC-10 |
| Booking purpose values                                     | TC-11 |
| Booking status values                                      | TC-12 |
| Requested end time must be after requested start time      | TC-13 |
| Expected participants must be positive                     | TC-14 |
| Rejected booking requires rejection reason                 | TC-15 |
| Maintenance problem types are limited to predefined values | TC-16 |
| Maintenance statuses are limited to predefined values      | TC-17 |
| Completed maintenance requires completion information      | TC-18 |
| BookingRequest foreign key to Space                        | TC-19 |
| BookingRequest foreign key to requester User               | TC-20 |
| MaintenanceRecord foreign key to Space                     | TC-21 |
| MaintenanceRecord foreign key to reporter User             | TC-22 |

---

## Constraints Not Tested

These constraints cannot be tested because they are **not implemented in the database**.

| Constraint                                                                 | Reason                                                 |
| -------------------------------------------------------------------------- | ------------------------------------------------------ |
| A space under maintenance, temporarily closed, or retired cannot be booked | No database trigger/procedure fully enforces this rule |
| Active maintenance forces `Space.current_status = under_maintenance`       | No synchronization trigger exists                      |
| No overlapping approved bookings                                           | No overlap-detection trigger exists                    |
| Expected participants must not exceed space capacity                       | Cross-table validation not implemented                 |
| Approval must be performed by facility staff or facility manager           | FK only validates existence, not user role             |
| Only facility staff can check in                                           | FK only validates existence, not user role             |
| Only facility staff can complete bookings                                  | FK only validates existence, not user role             |
| Booking automatically becomes `no_show`                                    | Requires scheduled job/application logic               |
| Historical records must be maintained indefinitely                         | Requires deletion policy/audit mechanism               |

---

## Tested BRs

| BR    | Description                                           | Status   |
| ----- | ----------------------------------------------------- | -------- |
| BR-01 | User roles are limited to predefined values           | TC-01 |
| BR-02 | Account statuses are limited to predefined values     | TC-02 |
| BR-03 | Space types are limited to predefined values          | TC-04 |
| BR-04 | Space statuses are limited to predefined values       | TC-05 |
| BR-05 | Booking purposes are limited to predefined values     | TC-11 |
| BR-06 | Booking statuses are limited to predefined values     | TC-12 |
| BR-13 | Maintenance statuses are limited to predefined values | TC-17 |
| BR-20 | Rejected booking must store rejection reason          | TC-15 |
| BR-22 | Space-Facility M:N relationship                       | TC-09, TC-10, valid SpaceFacility inserts |

---

## BRs Not Tested

These BRs cannot be tested because they are **not enforced by the database implementation**.

| BR    | Description                                                           | Reason                                     |
| ----- | --------------------------------------------------------------------- | ------------------------------------------ |
| BR-07 | Approval by facility staff or facility manager                        | Role validation not implemented            |
| BR-08 | Pending booking can only become approved or rejected                  | Workflow validation not implemented        |
| BR-09 | Allowed booking status transitions                                    | Status transition trigger not implemented  |
| BR-10 | No overlapping approved bookings                                      | Overlap trigger not implemented            |
| BR-11 | Unavailable spaces cannot be booked                                   | Booking prevention trigger not implemented |
| BR-12 | Any user role may book any space type                                 | Permission logic, not database-enforced    |
| BR-14 | Prevent bookings when space is under maintenance                      | Maintenance trigger not implemented        |
| BR-15 | Maintenance record may optionally link to a booking                   | Schema support not implemented             |
| BR-16 | Check-in records actual start time, staff identity, initial condition | Workflow logic not implemented             |
| BR-17 | Check-out records actual end time, final condition, usage notes       | Workflow logic not implemented             |
| BR-18 | Booking automatically becomes `no_show`                               | Requires scheduled job                     |
| BR-19 | Historical records retained indefinitely                              | Retention policy not implemented           |
| BR-21 | Facility manager manages space catalog                                | Authorization logic not implemented        |