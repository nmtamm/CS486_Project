# Step 1: Business Requirement Analysis

Save to:

`outputs/01-business-req-analysis-G02.md`

## Output document structure

Save the final document to `outputs/01-business-req-analysis-G02.md`. It must contain **exactly five sections** (no Assumptions or Open Questions sections).

### 1. Business Purpose
- Identify the core problem the system aims to solve.
- Describe the primary objectives and scope of the system.

### 2. Actors
- Identify all distinct user types mentioned in the requirement.
- For each role, note their responsibilities and interactions with the system.
- Present actors as a table with the following columns:

| ID   | Role | Responsibilities | Interactions |
| ---- | ---- | ---------------- | ------------ |
| A-01 | ...  | ...              | ...          |

- Assign each actor a unique ID (A-01, A-02, ...).

### 3. Business Data Entities & Attributes
- Identify all core objects/entities that the system must track or store data for.
- For each entity, specify:
  - **Core Identity:** What uniquely identifies the object from a business standpoint (e.g., Unique Code, Unique Email).
  - **Key Attributes:** A list of mandatory and optional business fields that must be captured.
  - **Predefined Options (Enums):** Closed-loop list of valid choices for types, categories, or statuses related to this entity.
   -**No hallucination:** Follow the business requirement strictly, do not create any unnecessary or unrelated entities for any reason.

### 4. Relationships & Cardinalities
- Identify all business-level relationships between the entities listed in Section 3.
- Present each relationship as a short, concise natural-language sentence.
- For example, a customer can order as many cups of coffee as he/she wants

### 5. Business Rules
- Extract all constraints, policies, logic rules, and workflow rules from the requirement and the clarifications.
- Present rules as a table with the following columns:

| ID    | Rule |
| ----- | ---- |
| BR-01 | ...  |

- Assign each rule a unique ID (BR-01, BR-02, ...).

- **CRITICAL FOR DB DESIGN:** To ensure readiness for database modeling, the rules MUST explicitly capture:
   - **State Transitions & Lifecycles:** For any object that changes status over time (e.g., orders, requests, accounts), explicitly define the allowed and forbidden movements between statuses.
   - **Data Validation & Constraints:** Define operational boundaries, business limits (e.g., maximum thresholds, quantities, allowed configurations), operational time windows, and auto-expiry behaviors.

## Requirements
1. Name for entities or attributes must be specifically related to the business requirement instead of using general descriptive words. For example, instead of User, use Library_User
2. 

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