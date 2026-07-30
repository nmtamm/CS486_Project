# Step 8: Requirement Change Analysis

Save to:

`outputs/08-requirement-change-analysis-G02.md`

## Output document structure

Save the final document to `outputs/08-requirement-change-analysis-G02.md`. It must contain **exactly five sections** (no Assumptions or Open Questions sections).

## Objective

Read the updated requirement document located at:

`req/new_requirement.md`

Compare it against the **existing approved requirements and design artifacts** (Business Purpose, Business Data Entities & Attributes, Relationships & Cardinalities, Business Rules, and ERD-related outputs) to determine the impact of the requirement change.

Only analyze **new, modified, or removed** requirements. Do **not** restate unchanged information.

### 1. Business Purpose
Determine whether the updated requirement changes the overall business objective.

For every affected business objective, specify:

- **Status:** New / Modified / Removed / Unchanged
- **Previous Requirement:**
- **Updated Requirement:**
- **Impact:**
- **Reason:**

### 2. Business Data Entities & Attributes
Identify every affected business entity.

For each entity, specify:

- **Entity:**
- **Change Type:** New / Modified / Removed
- **What changed:**
- **Why it changed:**
- **Affected attributes:**
- **Impact on the data model:**

If new entities or attributes are introduced, explain why they are required.

If existing entities become obsolete, explain why they should be removed.

### 3. Relationships & Cardinalities
Identify all relationship changes caused by the updated requirement.

For each affected relationship, specify:

- **Relationship:**
- **Change Type:** New / Modified / Removed
- **What changed:**
- **Why it changed:**
- **Updated cardinality (if applicable):**
- **Participation changes (if applicable):**

### 4. Business Rules
Identify every business rule affected by the new requirement.

For each rule, specify:

- **Change Type:** New / Modified / Removed
- **What changed:**
- **Why it changed:**
- **Business impact:**

### 5. Conflicts
Analyze conflicts introduced by the updated requirement in concurrent booking requests and approval operations.

For each conflict, specify:

- **Conflict:**
- **Cause:**
- **Potential impact:**
- **Recommended mitigation:**

## Workflow Execution Order (Strict)

1. **Internal Deep Scan (Background Only):**
   - Internally analyze the provided raw business requirements against ALL 5 output sections.
   - Intentionally scan for logical gaps, missing constraints, unclear edge-case state transitions, or ambiguous authorization rules. Discard trivial questions or those already addressed in the input requirements.

2. **Interactive Clarification Loop (Human-in-the-loop):**
   - For each critical ambiguity found, you MUST use the `question` tool to prompt the user before moving forward.
   - Formats to use:
     - For Assumptions: Offer exactly `["True", "False"]`.
     - For Open Decisions: Offer 2–3 concrete, actionable business options.

3. **Final Compilation & Export:**
   - Once the user answers all clarification questions, synthesize the answers into the final ruleset.
   - Generate the complete 5-section document.