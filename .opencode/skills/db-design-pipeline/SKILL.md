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

## T-SQL Scripting Rules (Microsoft SQL Server)

Whenever generating or modifying `.sql` files (`05-db-definition-G02.sql`, `10-schema-migration-G02.sql`, procedure scripts, etc.), strictly enforce the following T-SQL rules:

1. **`GO` Batch Separators Before Schema Objects**:
   - In T-SQL, statements such as `CREATE TRIGGER`, `CREATE PROCEDURE`, `CREATE FUNCTION`, `CREATE VIEW`, `CREATE SCHEMA`, `ALTER TRIGGER`, and `ALTER PROCEDURE` **must be the first statement in a query batch**.
   - You **MUST** add a `GO` statement on a separate line immediately before creating or altering any trigger, procedure, function, view, or schema (and after `CREATE DATABASE` / `USE [db]`).
   - Example:
     ```sql
     GO
     CREATE TRIGGER trg_SpaceBooking_NoOverlap
     ON SpaceBooking
     AFTER INSERT, UPDATE
     AS
     BEGIN
         SET NOCOUNT ON;
         ...
     END;
     GO
     ```

2. **Database Context & Batch Separation**:
   - Always include `USE [DatabaseName]; GO` at the top of SQL scripts.
   - Separate distinct DDL sections, table creation statements, data migration blocks, and trigger definitions with explicit `GO` statements to avoid batch compilation errors in SSMS and `sqlcmd`.

3. **Trigger & Procedure Best Practices**:
   - Always include `SET NOCOUNT ON;` at the top of triggers and stored procedures to prevent row-count messages from interfering with database client operations.
   - Re-enable any triggers disabled during bulk data migration (`ALTER TABLE ... ENABLE TRIGGER ...; GO`).

4. **T-SQL Idioms & Data Integrity**:
   - Use standard MS SQL Server data types (`NVARCHAR`, `DATETIME2`, `BIT`, `INT IDENTITY(1,1)`).
   - Maintain strict alignment with primary keys, foreign keys, and check constraints defined in the logical design artifacts.

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
11. `outputs/12-concurrency-implementation-G02.sql`
12. `outputs/12-concurrency-implementation-G02.md`
13. `outputs/13-concurrency-tests-G02.md`
14. `outputs/13-concurrency-tests-G02.sql`
15. `outputs/14-data-generator-G02/`
15. `outputs/15-index-tuning-G02.sql`
16. `outputs/15-index-tuning-G02.md`

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
| 12 | [Concurrency Implementation](step-12-concurrency-implementation/INSTRUCTION.md) |
| 13 | [Concurrency Tests](step-13-concurrency-tests/INSTRUCTION.md) |
| 14 | [Sample Data Generation](step-14-data-generator/INSTRUCTION.md) |
| 15 | [Index Tuning](step-15-index-tuning/INSTRUCTION.md) |
