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