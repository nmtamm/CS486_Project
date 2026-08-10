# AGENTS.md — cs486-demo

CS486 database systems teaching demo. Repository is empty; expect code to be added during sessions.

## Recurring context

- Root directory: <!-- YOUR ROOT DIRECTORY -->
- This is a demo project, not production.
- Run `ls -la` to detect new files before assuming anything exists.

# Database Design Agent Rules

This project transforms business requirements into database design artifacts.

<!---YOU COULD CHANGE THE FOLLOW SECTIONS --->
## Workflow Order
Always follow this order:

1. Analyze business requirements.
2. Produce conceptual ERD using Crow's Foot notation.
3. Convert the ERD into a relational schema with logical table definitions.
4. Validate the above relational schema

Do not jump directly to DDL. The documents from the prior steps should be followed in the later steps.

## Required Outputs

- `outputs/01-business-req-analysis-G02.md`
- `outputs/02-erd-design-G02.md`
- `outputs/03-logical-design-G02.md`
- `outputs/04-design-validation-G02.md`
- `outputs/05-db-definition-G02.sql`
- `outputs/08-requirement-change-analysis-G02.md`
- `outputs/09-update-erd-and-logical-design-G02.md`
- `outputs/10-schema-migration-G02.md`
- `outputs/11-concurrency-design-G02.md`
- `outputs/12-concurrency-implementation-G02.sql`
- `outputs/12-concurrency-implementation-G02.md`
- `outputs/13-concurrency-tests-G02.md`
- `outputs/13-concurrency-tests-G02.sql`
- `outputs/15-index-tuning-G02.sql`
- `outputs/15-index-tuning-G02.md`

## DBMS

Use Microsoft SQL Server unless the user specifies another DBMS.

## Design Rules

- Record assumptions explicitly.
- Record open questions explicitly.
- Preserve traceability from requirement → entity → relationship → table → constraint.
- Use Mermaid `erDiagram` for ERD.
- Do not silently invent business rules.
- Cross-document consistency: every reference in a later document to a prior document must use that prior document's actual section numbers, headings, and content. Before finalizing any output, verify that all cross-references (e.g., traceability tables, "derived from" annotations) exist in the referenced document. Never invent section numbers like §10, §11, etc. — use the real section structure (e.g., "Section 3 (Entities)").
