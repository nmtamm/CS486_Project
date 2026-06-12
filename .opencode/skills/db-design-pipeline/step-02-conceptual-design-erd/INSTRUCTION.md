# Step 2: Conceptual Design / ERD

Based on the output from [Step 1: Business Requirement Analysis](../../../outputs/01-business-req-analysis-G02.md) and the original requirements in [`CS486_Project.md`](../../../CS486_Project.md) / [`req/business-requirement.md`](../../../req/business-requirement.md).

Save to:

`outputs/02-erd-design-G02.md`


## Output document structure

The document must contain exactly the following sections:

### 1. Entity-Relationship Diagram (Crow's Foot Notation)

- Use Mermaid `erDiagram` syntax.
- Every entity identified in Step 1 (Section 3) must appear.
- Include all attributes. You must visibly display the following constraints in the ERD diagram:
  - **Key Constraints:** Ensure that a tuple is uniquely identified. Mark primary keys as `PK` and unique attributes/candidate keys as `UK`.
  - **Referential Integrity Constraints:** Ensure that relationships between entities are valid. Mark foreign keys as `FK` and connect them with appropriate relationship lines.
  - **Domain Constraints:** Restrict the possible values of an attribute. Display the appropriate SQL Server specific data type (e.g., `varchar`, `nvarchar`, `char`, `int`, `float`, `datetime`, `bit`, `text`) next to every attribute rather than using a generic `string`. Choose varchar, nvarchar, or char appropriately based on whether the data is variable-length non-Unicode, variable-length Unicode (like names, descriptions, or notes), or fixed-length. For any attributes representing predefined options (enums), you must append the allowed options as a double-quoted string comment using semicolons as separators (do NOT use commas inside the double quotes as they break the Mermaid erDiagram parser), e.g. `varchar role "Values: student; lecturer; teaching_assistant"` or `varchar account_status "Values: active; inactive; suspended"`.
  - **Participation Constraints:** Define whether an entity's participation in a relationship is mandatory (total) or optional (partial). Represent these using the appropriate Crow's Foot cardinality notations:
    - `||` — mandatory one (exactly 1)
    - `|o` — optional one (0 or 1)
    - `}o` — optional many (0 or more)
    - `}|` — mandatory many (1 or more)
- Multiple key markers on one attribute are allowed via comma separation: `PK, FK`. Do not use space-separated markers (`PK FK` causes a parse error). For composite primary keys where each part is also a foreign key, use `PK, FK`.
- Use descriptive relationship verb phrases (e.g., `"submits"`, `"approves"`).

### 2. Entity Descriptions

For each entity, provide:
- **Purpose:** Plain-language description of what the entity represents.
- **Predefined Options:** Enum values for type, status, category, etc. — exactly as specified in the requirements.
- **Lifecycle / State Transitions:** For entities with a status (e.g., BookingRequest, MaintenanceRecord), describe the allowed transitions between statuses. If there are multiple lines/transitions listed in plain text, you must explicitly append line breaks (`<br>`) at the end of each line to ensure they render properly on separate lines.
- **Constraints (from Business Rules):** For any constraints that cannot be visually represented in the ERD diagram (such as complex conditional logic like BR-06, or cross-entity status synchronization rules like BR-21), you must explicitly note them under a **Constraints (from Business Rules)** subheading for the corresponding entity description.

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

2. **Interactive Clarification Loop (if needed):**
   - Use the `question` tool for any ambiguity not already resolved in Step 1.
   - Do not re-ask questions already answered during Step 1.

3. **Final Review & Export:**
   - Verify that every entity, attribute, and relationship from Step 1 appears in the diagram and description sections.
   - Verify that all business rules (especially overlap prevention and status lifecycles) are either represented in the diagram or explicitly noted in the entity descriptions.
   - Remove all `{{placeholder}}` markers.
   - Save the completed document to `outputs/02-erd-design-G02.md`. 
