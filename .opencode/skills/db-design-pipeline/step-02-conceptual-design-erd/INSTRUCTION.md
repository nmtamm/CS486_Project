# Step 2: Conceptual Design / ERD

Based on the output from [Step 1: Business Requirement Analysis](../../../outputs/01-business-req-analysis-G02.md) and the original requirements in [`CS486_Project.md`](../../../CS486_Project.md) / [`req/business-requirement.md`](../../../req/business-requirement.md).

Save to:

`outputs/02-erd-design-G02.md`

> **Template:** `TEMPLATE.md`
> 
> **Example:** `EXAMPLE.md` (in this directory)

## Output document structure

The document must contain exactly the following sections:

### 1. Entity-Relationship Diagram (Crow's Foot Notation)

- Use Mermaid `erDiagram` syntax.
- Every entity identified in Step 1 (Section 3) must appear.
- Include all attributes. Mark primary keys as `PK`, foreign keys as `FK`, and unique attributes as `UK`. Mermaid's `erDiagram` does not support a `(required)` marker for not-null constraints; do not add one.
- Use appropriate data types (`string`, `int`, `float`, `datetime`, `boolean`, `text`).
- Multiple key markers on one attribute are allowed via comma separation: `PK, FK`. Do not use space-separated markers (`PK FK` causes a parse error). For composite primary keys where each part is also a foreign key, use `PK, FK`.
- Show all relationships with Crow's Foot cardinality notation:
  - `||` — mandatory one (exactly 1)
  - `|o` — optional one (0 or 1)
  - `}o` — optional many (0 or more)
  - `}|` — mandatory many (1 or more)
- Use descriptive relationship verb phrases (e.g., `"submits"`, `"approves"`).

### 2. Entity Descriptions

For each entity, provide:
- **Purpose:** Plain-language description of what the entity represents.
- **Predefined Options:** Enum values for type, status, category, etc. — exactly as specified in the requirements.
- **Lifecycle / State Transitions:** For entities with a status (e.g., BookingRequest, MaintenanceRecord), include a lifecycle diagram showing allowed transitions between statuses. Use the state transitions documented in Step 1 (Section 5, Business Rules).

Entities to describe:
1. **User**
2. **Space**
3. **Facility**
4. **SpaceFacility** (junction)
5. **BookingRequest**
6. **MaintenanceRecord**

### 3. Relationship Summary

Present all relationships as a table with columns:

| Left Entity | Relationship | Right Entity | Left Participation | Right Participation | Cardinality | Description |
| ----------- | ------------ | ------------ | ------------------ | ------------------- | ----------- | ----------- |

- **Left/Right Participation:** Specify whether participation is `mandatory` (total) or `optional` (partial) for each entity.
- **Cardinality:** Use standard notation (e.g., `1 → N`, `0..1 → N`, `M → N`).
- **Description:** Explain the business meaning in one sentence.
- Cross-reference with Step 1 (Section 4: Relationships & Cardinalities).
- Ensure the participation constraints in the table match the Crow's Foot symbols used in the Mermaid diagram (e.g., `||` = mandatory, `|o` = optional).

### 4. Traceability

Present a traceability table mapping each entity back to the original requirement sections in `01-business-req-analysis-G02.md`. Reference section numbers from that document (Section 3: Entities, Section 4: Relationships, Section 5: Rules) rather than external paragraph numbers.

| Entity | Derived From Requirement |
| ------ | ------------------------ |
| User   | Section 3, User row: user information, roles, account status |

---

## Workflow Execution Order (Strict)

1. **Internal Scan:**
   - Read the Step 1 output (`outputs/01-business-req-analysis-G02.md`) completely.
   - Identify all entities, attributes, relationships, and business rules.

2. **Template Population:**
   - Copy `TEMPLATE.md` as the starting document.
   - Populate the Mermaid `erDiagram` block with entities, attributes, keys, and relationships using Crow's Foot notation.
   - Fill in entity descriptions, predefined options, and lifecycle diagrams.
   - Complete the relationship summary table.
   - Complete the traceability table.

3. **Interactive Clarification Loop (if needed):**
   - Use the `question` tool for any ambiguity not already resolved in Step 1.
   - Do not re-ask questions already answered during Step 1.

4. **Final Review & Export:**
   - Verify that every entity, attribute, and relationship from Step 1 appears in the diagram and description sections.
   - Verify that all business rules (especially overlap prevention and status lifecycles) are either represented in the diagram or explicitly noted in the entity descriptions.
   - Remove all `{{placeholder}}` markers.
   - Save the completed document to `outputs/02-erd-design-G02.md`. Do not keep `TEMPLATE.md` markers in the output.
