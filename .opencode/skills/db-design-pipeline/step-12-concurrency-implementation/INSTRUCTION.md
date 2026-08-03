# Step 12: Concurrency Implementation

Save to:

`outputs/12-concurrency-implementation-G02.sql`
`outputs/12-concurrency-implementation-G02.md`

## Task Identity

Perform **Phase 2 — Concurrency Implementation**.

Implement the concurrency control design defined in the prior step's design document (`11-concurrency-design-G02.md`) as runnable T-SQL, and document the analytical process. Two outputs, mirroring the Step 10 convention (an executive `.sql` plus a traceable `.md`):

```text
outputs/12-concurrency-implementation-G02.sql  -- the implemented stored procedures
outputs/12-concurrency-implementation-G02.md   -- the analytical process
```

The `.sql` must be **executable against the target database** defined by the schema-migration step (`10-*`). It implements the design document's transaction specifications and its mitigation actions.

**Generation order:** produce `12-concurrency-implementation-G02.md` **first** (decide the design and document the analytical process), then generate the `.sql` on top of that document — the `.md` is the reference the executable script must exactly agree with.

> Note: Step 11 produced a `.md` design document plus separate `.sql` reproduction scripts that *demonstrate* each race condition. Step 12 is the **implementation**: the `.sql` procedures that *prevent* those reproduced errors. When run against a clean target database, the recorded race interleavings must no longer produce the invariant violations.

---

## Mandatory Input Documents & Precedence Rules

Read, in precedence order (later overrides earlier on conflict):

1. `outputs/11-concurrency-design-G02.md` — **the authoritative specification for the procedures.** The transaction boundaries, lock acquisition, validation queries, and each procedure specification in the design document MUST be translated literally into working code.
2. `outputs/10-schema-migration-G02.sql` — the target schema. **Every table name, column name, type, foreign key, and CHECK/enum literal in the implementation MUST match this file exactly.**
3. `outputs/09-updated-erd-and-logical-design-G02.md` — the updated logical design (entities, relationships, and the refined business-rule identifiers referenced by the design document).
4. Any sample-data file (`06-*`) — source of **real** values for any inline demo/verification SQL; never invent entity IDs, codes, or enum literals.

New requirements supersede older ones whenever they conflict.

---

## Output File Structure & Requirements

Generate the two artifacts in this order: the Markdown document **first**, then the executable SQL on top of it.

### 1. Analytical Process (`outputs/12-concurrency-implementation-G02.md`)
Produce a Markdown document with the same document-and-verify spirit as Step 10's `.md`, covering:

1. **Objective** — what the implementation delivers and the target database it runs against.
2. **Reference files** — which prior artifacts were consumed (`11-*`, `10-*`, `09-*`) and how.
3. **Implemented procedures** — one subsection per procedure: its exact SQL/object behavior, the invariants it upholds, and the design-doc section it translates.
4. **How each concurrency error is prevented** — map each error identified in Step 11 to the enforcement this implementation provides, with an explanation of the locking/isolation mechanism (not merely a one-line claim).
5. **Run instructions** — how to create the procedures against the target DB and how to `EXEC` each.

The run instructions live **in this `.md` only**. The `.sql` must not duplicate them — it only refers back here.

The effectiveness of the implementation is **not** verified in this step. Testing and verification (re-running the identified race sequences and confirming the guards prevent them) is the responsibility of **Step 13** (`13-concurrency-tests-*`). Step 12 only produces the procedures and documents how they are designed to prevent each concurrency error; execution/verification happens later.

Keep the `.md` analytical and race-traceable; all runnable logic lives in the `.sql`. This document is the reference the SQL must exactly agree with.

### 2. Implementation (`outputs/12-concurrency-implementation-G02.sql`)
Build the executable script to match the `.md` exactly. It contains, in order:

#### 2.1 Header & Context
- `USE [<target database>]; GO`
- A header comment block: file name, target database, and the design doc it implements.

#### 2.2 One stored procedure per designed transaction
Write a stored procedure for each transaction specification defined in the design document, translating every spec literally. Each follows the pattern:

- **Input parameters** for the business key(s) and attributes the operation needs; **output parameters** for any value it returns (created key, resulting status). Derive names and types from the target schema.
- `BEGIN TRANSACTION`, then acquire the application-level resource lock for the parent entity as specified by the design (`sp_getapplock` in this environment: `EXEC sp_getapplock @Resource = N'<resource>', @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = <timeout>;`). On result < 0, roll back + raise a clean "system busy, retry" error.
- On lock success, in the order the design specifies:
  1. **Upper-bound / capacity validation** → roll back on violation.
  2. **Blocking-state check** against the sibling entity that must not coexist (e.g. a resource out of service), under the range-lock hint `WITH (UPDLOCK, HOLDLOCK)` → roll back on violation.
  3. **Conditional notification / acknowledgement** side effect that must be atomic with the operation.
  4. **Overlap / conflict check** against competing rows, under the same range-lock hint → roll back on violation.
  5. **Policy / configuration lookup** that decides the resulting state.
  6. The `INSERT` / `UPDATE` recording the operation, with values that satisfy the schema's own `CHECK` constraints and auto-fired triggers.
- `COMMIT TRANSACTION` (a `@LockOwner = 'Transaction'` lock releases at commit); assign outputs.

Implement exactly the procedures and behaviors the design specifies — nothing more, nothing less.


---

## T-SQL Scripting Rules

Follow the master rules in `SKILL.md` **strictly**:

1. **`GO` before schema-object definitions:** `CREATE PROCEDURE` / `CREATE OR ALTER PROCEDURE` must be the first statement in a batch — put `GO` on its own line immediately before and after each procedure block.
2. `USE [<target database>];` at the very top, followed by `GO`.
3. `SET NOCOUNT ON;` as the first statement inside every procedure body.
4. Use the standard SQL Server types and the exact column / enum / `CHECK` literals defined in the schema-migration file. Never invent columns, keys, or enum values.
5. If a prior document references a column or table that does not exist in the actual schema, prefer the schema — surface the mismatch rather than emit non-executable SQL.

---

## Guarantees & Scope Constraints

1. Do not modify the migrated base tables or drop existing objects from `10-*` — the implementation layer sits on top of the migrated schema.
2. Lock ordering: always acquire the parent entity's application lock before touching child rows; never nest application locks on different parents (deadlock avoidance).
3. The procedures must **prevent, not merely detect**, the concurrency errors identified in the design doc. Re-running each recorded race interleaving against a clean target database must no longer produce the invariant violation.
4. Cooperate with any triggers and constraints already in the migrated schema — choose insert/update values that pass them rather than bypass them.
5. Run instructions live in the analytical `.md`, not in the `.sql` — the SQL header comments may only point back to them (e.g. "See run instructions in `12-concurrency-implementation-G02.md`").

---

## Traceability

End with a comment matrix mapping each procedure to the business rule(s)/invariant(s) it upholds and the design-doc section it implements. **Do not invent numbers or rule IDs** — source every entry from the documents in scope:

- Procedure names and their design-doc sections come from the design document's own transaction-spec headings.
- Business-rule / invariant identifiers come from the updated logical design (or requirement-change analysis). If a prior document cites a rule the implementation cannot guarantee, note that explicitly instead of copying it.

Example shape (values illustrative, not authoritative):

| Procedure | Business rule / invariant | Design-doc section |
|---|---|---|
| `<procedure from design>` | `<rule identifiers from logical design>` | `<section the design gives it>` |
| … | … | … |