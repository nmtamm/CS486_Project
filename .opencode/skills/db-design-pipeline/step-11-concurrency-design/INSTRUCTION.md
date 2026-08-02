# Step 11: Concurrency Design

Save to:

`outputs/11-concurrency-design-G02.md`

## Task Identity

Perform **Phase 2 — Concurrency Design** for the Campus Space Management System.

Produce the required technical design document:

```text
outputs/11-concurrency-design-G02.md
```

This document defines the concurrency control design, transaction boundaries, isolation levels, and locking strategies to prevent race conditions and preserve database invariants under concurrent execution.

The document must identify **at least 2 concurrency errors** in the system, provide SQL reproduction scripts and step-by-step instructions for reproducing each error, and present the complete concurrency control design to prevent them.

---

## Mandatory Input Documents & Precedence Rules

When analyzing requirements and existing design artifacts, apply the following hierarchy:

1. **Requirements Precedence**:
   - Read all requirement documents (original Phase 1 requirement files and new Phase 2 requirement files).
   - **New requirements take higher precedence** over older requirements whenever there is a conflict or refinement.

2. **Outputs Precedence**:
   - Read all prior output artifacts in `outputs/` (from `01` through `10`).
   - **Later output documents take higher precedence** over earlier output documents. For example, `10-schema-migration-G02.sql` and `09-updated-erd-and-logical-design-G02.md` supersede earlier Phase 1 baseline documents (`05`, `03`, `02`, `01`) for any schema definitions or rules modified in Phase 2.

---

## Output Document Structure & Requirements

The markdown document `outputs/11-concurrency-design-G02.md` must contain the following formal sections:

### 1. Concurrency Objectives & System Invariants
- Identify core database business invariants that must hold true under concurrent execution (e.g., no overlapping active bookings for the same space, no booking during active `out_of_service` maintenance).
- Define concurrency control goals: data consistency, transactional isolation, deadlock avoidance, and system correctness during peak concurrency.

### 2. Concurrency Errors Identification & Reproduction
Identify **at least 2 specific concurrency errors** (race conditions / invariant violations) that can occur in the system under un-isolated concurrent execution (e.g., double booking under concurrent instant submissions, booking approval during concurrent maintenance escalation).

For **each identified concurrency error**, provide:
1. **Error Analysis**: Detailed description of the race condition, affected entities, involved business rules (e.g., BR-01, BR-02, BR-12), and business impact.
2. **SQL Reproduction Scripts**: Complete, runnable T-SQL scripts separated into **Session A** and **Session B** showing the un-isolated interleaved SQL execution steps that trigger the error.
3. **Step-by-Step Reproduction Instructions**: Clear guidance on how to open two parallel SQL connections in SSMS / sqlcmd, set up initial test data, and execute the interleaved statements in step-by-step order to observe the concurrency failure.

### 3. Isolation Levels & Locking Strategy Design
Design the database concurrency control model:
- Evaluate candidate transaction isolation levels (`READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`, `SNAPSHOT`) and select appropriate levels for each operation type.
- Design locking strategies (e.g., key-range locks, update locks `UPDLOCK`/`HOLDLOCK`, application-level locks `sp_getapplock`) to protect critical sections and prevent the identified concurrency errors.
- Specify lock acquisition ordering and deadlock prevention guidelines.

### 4. Concurrency Control Transaction Specifications
Provide high-level concurrency design specifications for core system operations (e.g., booking submission, booking approval, maintenance escalation):
- Define transaction boundaries (start, validation phase, lock acquisition, modification, commit/rollback).
- Specify required isolation levels and explicit locking hints/mechanisms for each operation.
- Detail how the proposed design guarantees invariant safety and prevents each of the identified concurrency errors.

---

## Technical & Scope Constraints
1. **At Least 2 Concurrency Errors Required**: The document must explicitly identify, document, and provide SQL reproduction scripts and step-by-step instructions for at least 2 distinct concurrency errors.
2. **Traceability**: Maintain strict alignment with Phase 2 business rules, updated logical schema (`09`), and schema migration (`10`).
