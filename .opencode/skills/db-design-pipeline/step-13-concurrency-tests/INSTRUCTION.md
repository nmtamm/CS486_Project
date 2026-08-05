# Step 13: Concurrency Tests

Save to:

`outputs/13-concurrency-tests-G02.md`
`outputs/13-concurrency-tests-G02.sql`

## Task Identity

Perform **Phase 2 — Concurrency Testing**.

Verify that the concurrency implementation produced in Step 12 (`12-concurrency-implementation-G02.sql`) actually prevents each concurrency error identified and reproduced in Step 11. Produce runnable test scripts that re-run the recorded race interleavings through the implemented procedures and demonstrate that the invariants hold.

Two outputs, mirroring the Step 12 convention (a traceable `.md` test plan plus executable test scripts):

```text
outputs/13-concurrency-tests-G02.md   -- the test plan and analytical process
outputs/13-concurrency-tests-G02.sql  -- a single script containing all concurrency tests
```

**Generation order:** produce `13-concurrency-tests-G02.md` **first** (decide the test plan and document the analytical process), then generate the test scripts on top of that document — the `.md` is the reference the scripts must exactly agree with.

> Note: Step 11 reproduced each concurrency error by interleaving raw SQL across two sessions, demonstrating the invariant violation when no control exists. Step 12 implemented procedures designed to prevent those errors. Step 13 is the **verification**: re-running the same race sequences through the Step 12 procedures and showing the guards hold. This is the step where the concurrency implementation is actually tested.

---

## Mandatory Input Documents & Precedence Rules

Read, in precedence order (later overrides earlier on conflict):

1. `outputs/12-concurrency-implementation-G02.sql` — the stored procedures **under test**. Every test targets these objects exactly as defined.
2. `outputs/11-concurrency-design-G02.md` — the concurrency errors identified, their reproduction scripts, and the invariants they violate.
3. `outputs/10-schema-migration-G02.sql` — the target schema the procedures run against.
4. Any sample-data file (`06-*`) — source of **real** values for the test scenarios; never invent entity IDs, codes, or enum literals.

New requirements supersede older ones whenever they conflict.

---

## Output File Structure & Requirements

Generate the two artifacts in this order: the test-plan Markdown document **first**, then the test scripts on top of it.

### 1. Test Plan (`outputs/13-concurrency-tests-G02.md`)
A Markdown document covering:

1. **Objective** — what is being verified and the target database it runs against.
2. **Reference files** — which prior artifacts were consumed (`12-*`, `11-*`, `10-*`, `09-*`) and how.
3. **Test matrix** — for each concurrency error identified in Step 11: the invariant violated, the procedures involved, and the expected (correct) outcome when the guard is in place.
4. **Test results** — the outcome of executing each test script: whether the second (conflicting) operation was rejected, and whether the invariant held. Record **observed** results, not assumed ones.
5. **Run instructions** — how to load the procedures from `12-*` into the target database and how to execute each test script.

The run instructions live **in this `.md` only**. The test scripts must not duplicate them — they only refer back here.

### 2. Test Script (`outputs/13-concurrency-tests-G02.sql`)
A **single** executable SQL file containing **one test section per concurrency error** identified in Step 11. Each section:

- Re-runs the same race interleaving from the Step 11 reproduction, but the conflicting operations are performed by **calling the Step 12 procedures** instead of raw interleaved statements.
- Demonstrates that the first operation succeeds and the second (conflicting) operation is rejected or rolled back by the guard.
- Ends with an assertion/verification statement that confirms the invariant holds (e.g. no conflicting rows exist, or the expected error was raised).
- Uses only real values present in the sample data.
- Must be executable against the target database after the Step 12 procedures have been created.

---

## T-SQL Scripting Rules

Follow the master rules in `SKILL.md` **strictly**:

1. `USE [<target database>];` at the very top of each script, followed by `GO`.
2. `SET NOCOUNT ON;` at the top of any statement block, where applicable.
3. Use the standard SQL Server types and the exact column / enum / `CHECK` literals defined in the schema-migration file. Never invent columns, keys, or enum values.
4. Test scripts must be executable as-is against a freshly migrated database — no hidden manual setup steps left in comments.
5. Use transactions and two-session interleaving only to reproduce the Step 11 race faithfully; the assertion of the invariant is the deliverable.

---

## Guarantees & Scope Constraints

1. Test only the objects produced in Step 12 — do not add new procedures, triggers, or constraints as part of testing.
2. Test scripts must be **deterministic**: a pass must mean the guard prevented the violation, not that the race happened not to occur.
3. Do not modify base tables or drop existing objects from `10-*`.
4. If a test cannot pass (the guard does not prevent the error), report it as a failure in the test plan — do **not** weaken the assertion to make it pass.
5. Use real sample-data values; never invent entities, codes, or enum literals.

---

## Traceability

End with a comment matrix mapping each test section to the concurrency error it covers, the invariant it verifies, and the design-doc section that identifies the error. **Do not invent numbers or rule IDs** — source every entry from the documents in scope.

Example shape (values illustrative, not authoritative):

| Test section | Concurrency error | Invariant verified | Design-doc section |
|---|---|---|---|
| `<script for error N>` | `<error description from Step 11>` | `<invariant from Step 11>` | `<section the design gives it>` |
| … | … | … | … |
