# Step 3: Logical Database Design

Based strictly on the output from [Step 2: Conceptual Design / ERD](../../../../outputs/02-erd-design-G02.md) and the output from [Step 1: Business Requirement Analysis](../../../../outputs/01-business-req-analysis-G02.md)

Save to:
`outputs/03-logical-design-G02.md`

## Output document structure
The document must contain exactly the following sections:

### 1. Relational Schema Diagram & Notation

Create a Mermaid diagram that visually represents the relational schema using horizontal table blocks and attribute-level foreign key connections.

**Guidelines:**

1. **Structure**
    - Use Mermaid `flowchart LR` syntax exclusively.
    - Represent every relation as an independent `subgraph`.
    - The subgraph title must be the relation name.

    ```mermaid
    flowchart LR
    subgraph RELATION_NAME [RelationName]
        direction LR
        attribute_1 ~~~ attribute_2 ~~~ attribute_3
    end
    ```

2. **Table Representation Rules**
    - Each relation must be represented as a single horizontal row.
    - Attributes must be displayed from left to right using `~~~`.
    - Every attribute must be displayed exactly once.
    - Do **not** display attribute data types in the diagram.
    - Use the exact attribute names from `outputs/02-erd-design-G02.md`.
    - Preserve the attribute ordering defined in the conceptual design whenever possible.

3. **Key Notation Rules**
    - Mark attributes using the following prefixes:
      - `🔑` → Primary Key (`PK`)
      - `🔗` → Foreign Key (`FK`)
      - `⭐` → Candidate Key / Unique Key (`UK`)
    - Multiple markers are allowed, use space character ` ` to seperate, foreign key always follows primary key.
    - Example: `🔑 user_id`, `🔗 requester_id`, `🔑 🔗 facility_id`

4. **Text Formatting Rules**
    - Use Markdown inline formatting by wrapping text with `` "` `" `` when applying text styles.
    - Use the following formatting rules:
        - `*text*` → italic text
        - `**text**` → bold text
        - `***text***` → bold italic text
    - Apply these formatting rules consistently throughout the Relational Schema Diagram:
        - Use **bold text** for the name of every relation.
        - Use **bold text** for primary key attributes.
        - Use *italic text* for foreign key attributes.
        - Use ***bold italic text*** for attributes that are both primary keys and foreign keys.
    - The text formatting rules are visual indicators only and do not replace the `🔑` and `🔗` key markers. Both systems must be used simultaneously.

5. **Attribute Node Naming Rules**
    - Every attribute node must have a unique Mermaid identifier.
    - Use the following naming convention: `RELATION_ABBREVIATION_ATTRIBUTE_NUMBER` (e.g., `USR1`, `USR2`, `SPC1`, `BKG3`, `FAC2`)
    - The visible label must contain only the attribute name and key markers and follow Text Formatting Rules.
    - Example: `USR1["`**🔑 user_id**`"]`

6. **Foreign Key Relationship Rules**
    - Do **not** connect entire relations.
    - Connect the foreign key attribute node directly to the referenced primary key attribute node.
    - Example: `BKG2 --> USR1`

7. **Example structure**
    ```mermaid
    flowchart LR

    subgraph USER ["`**User**`"]
    direction LR
    USR1["`**🔑 user_id**`"] ~~~
    USR2["email"] ~~~
    USR3["full_name"]
    end

    subgraph BOOKING_REQUEST ["`**BookingRequest**`"]
    direction LR
    BKG1["`**🔑 booking_id**`"] ~~~
    BKG2["`*🔗 requester_id*`"] ~~~
    BKG3["`*🔗 space_code*`"] ~~~
    BKG4["booking_status"]
    end

    BKG2 --> USR1
    ```

### 2. Business Rule Enforcement Map

Document how each business rule identified in Step 1 is enforced within the logical database design.

Present a Markdown table with the following columns:

| Business Rule ID | Business Rule Description | Enforcement Mechanism | Related Relation(s) | Related Attribute(s) |
| ---------------- | ------------------------- | --------------------- | ---------------- | ----------------- |

**Guidelines:**

1. **Business Rule Source**
   - Use only the original `BR-XX` identifiers defined in `outputs/01-business-req-analysis-G02.md`.
   - Do not create, rename, merge, split, or reorder business rules.
   - Preserve the original business rule descriptions whenever possible.

2. **Coverage Requirements**
   - Every business rule from Step 1 must appear exactly once in this section.
   - No business rule may be omitted.
   - No duplicate entries are allowed.

3. **Enforcement Mechanism Selection**
   - Assign the most appropriate enforcement mechanism to each business rule.
   - Only the following values are allowed:

     - `PRIMARY KEY`
     - `FOREIGN KEY`
     - `UNIQUE`
     - `CHECK`
     - `NOT NULL`
     - `DEFAULT`
     - `Composite Key`
     - `Application Logic`
     - `Trigger / Stored Procedure`

   - If multiple mechanisms are required, separate them using commas. (e.g., `CHECK, DEFAULT`)
   
4. **Mechanism Selection Priority**
    Use the following priority order whenever applicable:
    - Entity uniqueness → `PRIMARY KEY`
    - Relationship dependency → `FOREIGN KEY`
    - Attribute uniqueness → `UNIQUE`
    - Predefined values or ranges → `CHECK`
    - Mandatory values → `NOT NULL`
    - Automatically assigned values → `DEFAULT`
    - Multi-column identifiers → `Composite Key`
    - Cross-row or temporal validations → `Trigger / Stored Procedure`
    - Business processes that cannot be enforced at the database level → `Application Logic`

5. **Relation and Attribute Mapping**
    For every business rule:
    - Identify all related relations.
    - Identify all related attributes.
    - Use the exact names defined in outputs/02-erd-design-G02.md.
    - Do not invent new relations or attributes.

---

## Workflow Execution Order (Strict)

1. **Internal Scan:**
  - Read `outputs/02-erd-design-G02.md` and `outputs/01-business-req-analysis-G02.md` completely.
  - Identify all entities, attributes, relationships, keys, and constraints defined in the conceptual design.
  - Identify all business rule references.
  - Determine the logical relations required for the relational schema.

2. **Generation**
  - Generate the Relational Schema Diagram.
  - Generate the Business Rule Enforcement Map.

3. **Final Review & Export**
    - Verify that every entity from `outputs/02-erd-design-G02.md` appears exactly once as a logical relation.
    - Verify that every attribute from the conceptual design is preserved.
    - Verify that all primary keys (`PK`) and foreign keys (`FK`) are correctly represented.
    - Verify that every foreign key references an existing primary key.
    - Verify that every foreign key relationship in Section 1 is represented using attribute-level Mermaid connections.
    - Verify that all foreign key relationships documented in Section 1 are reflected in Section 2.
    - Verify that every `BR-XX` business rule from `outputs/01-business-req-analysis-G02.md` appears exactly once in the Business Rule Enforcement Map.
    - Ensure that foreign key attributes have the same data type as their referenced primary key attributes.
    - Ensure naming consistency between:
        - Section 1 (Relational Schema Diagram)
        - Section 2 (Business Rule Enforcement Map)
        - `outputs/02-erd-design-G02.md`
    - Verify consistency across all sections of the document.
    - Remove all placeholders, examples, and unresolved references.
    - Save the completed document to `outputs/03-logical-design-G02.md`.


