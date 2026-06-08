---
name: db-design-pipeline
description: Analyze business requirements and produce conceptual ERD, logical database design, and DDL documents step by step.
compatibility: opencode
---

# Database Design Pipeline Skill

Use this skill when the user asks to transform business requirements into a database design.

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

Do not skip any Markdown file.

---

## Steps

| # | Step |
|---|------|
| 1 | [Business Requirement Analysis](step-01-business-requirement-analysis/INSTRUCTION.md)
| 2 | [Conceptual Design / ERD](step-02-conceptual-design-erd/INSTRUCTION.md)
