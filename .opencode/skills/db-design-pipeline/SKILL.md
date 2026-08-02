---
name: db-design-pipeline
description: Analyze business requirements and produce conceptual ERD, logical database design, DDL, schema migration, and concurrency design documents step by step.
compatibility: opencode
---

# Database Design Pipeline Skill

Use this skill when the user asks to transform business requirements into a database design or execute Phase 2 pipeline updates.

## Important behavior

Before assuming anything, inspect the project:

1. Run `ls -la`.
2. Locate requirement files under `outputs/` or files passed by the user.
3. Read the relevant requirement files fully before designing.
4. If the requirement is incomplete, continue with explicit assumptions, but also create an unresolved questions section.
5. Do not touch any files that are not in `outputs/`.

## Required output files

Create or update the following files:

1. `outputs/01-business-req-analysis-G02.md`
2. `outputs/02-erd-design-G02.md`
3. `outputs/03-logical-design-G02.md`
4. `outputs/04-design-validation-G02.md`
5. `outputs/05-db-definition-G02.sql`
6. `outputs/06-sample-data-G02.sql`
7. `outputs/08-requirement-change-analysis-G02.md`
8. `outputs/09-updated-erd-and-logical-design-G02.md`
9. `outputs/10-schema-migration-G02.sql`
10. `outputs/11-concurrency-design-G02.md`

Do not skip any Markdown or SQL file.

---

## Steps

| # | Step |
|---|------|
| 1 | [Business Requirement Analysis](step-01-business-requirement-analysis/INSTRUCTION.md) |
| 2 | [Conceptual Design / ERD](step-02-conceptual-design-erd/INSTRUCTION.md) |
| 3 | [Logical Database Design](step-03-logical-database-design/INSTRUCTION.md) |
| 4 | [Database Design Validation](step-04-database-design-validation/INSTRUCTION.md) |
| 5 | [Database Implementation](step-05-database-implementation/INSTRUCTION.md) |
| 6 | [Sample Data Preparation](step-06-sample-data/INSTRUCTION.md) |
| 8 | [Requirement Change Analysis](step-08-requirement-change-analysis/INSTRUCTION.md) |
| 9 | [Updated ERD and Logical Design](step-09-updated-erd-and-logical-design/INSTRUCTION.md) |
| 10 | [Schema Migration](step-10-schema-migration/INSTRUCTION.md) |
| 11 | [Concurrency Design](step-11-concurrency-design/INSTRUCTION.md) |