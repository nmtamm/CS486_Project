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

Do not jump directly to DDL. The documents from the prior steps should be followed in the later steps.

## Required Outputs

- `outputs/01-business-requirement-analysis-G02.md`
- `outputs/02-conceptual-design-erd-G02.md`

## DBMS

Use Microsoft SQL Server unless the user specifies another DBMS.

## Design Rules

- Record assumptions explicitly.
- Record open questions explicitly.
- Preserve traceability from requirement → entity → relationship → table → constraint.
- Use Mermaid `erDiagram` for ERD.
- Do not silently invent business rules.
- Cross-document consistency: every reference in a later document to a prior document must use that prior document's actual section numbers, headings, and content. Before finalizing any output, verify that all cross-references (e.g., traceability tables, "derived from" annotations) exist in the referenced document. Never invent section numbers like §10, §11, etc. — use the real section structure (e.g., "Section 3 (Entities)").
