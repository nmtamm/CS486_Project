# Step 10: Schema Migration

Save to:

`outputs/10-schema-migration-G02.sql`

---

# Objective

Create a **new database implementation** based on the updated logical design and ERD, then migrate all applicable data from the previous database into the new schema.

**Important**
The updated schema is **significantly different** from the previous version. The migration should **not** assume that tables, columns, primary keys, or relationships remain the same.

---

# Reference Files

1. Current database definition:
   `outputs/05-db-definition-G02.sql`

2. Current sample data:
   `outputs/06-sample-data-G02.sql`

3. Database implementation instruction:
   `.opencode/skills/db-design-pipeline/step-05-database-implementation/INSTRUCTION.md`

4. Sample data generation instruction:
   `.opencode/skills/db-design-pipeline/step-06-sample-data/INSTRUCTION.md`

5. Updated ERD and Logical Design:
   `outputs/09-updated-erd-and-logical-design-G02.md`

---

# Expected Output

Generate a Markdown file for the analytical process and save to: `outputs/10-schema-migration-G02.md`
Generate a single SQL file:

`outputs/10-schema-migration-G02.sql`

The script should contain, in order:

1. New database schema creation.
2. Constraint creation (both **CHECK** and **TRIGGER**)
3. Data migration statements.
4. Data transformation statements (when required).
5. Default value insertion for newly introduced mandatory attributes.

---

# Workflow

## Step 1: Analyze Existing Database

Read:

- `outputs/05-db-definition-G02.sql`
- `outputs/06-sample-data-G02.sql`

Understand:

- Existing tables
- Primary keys
- Foreign keys
- Constraints
- Existing sample data
- Current relationships

---

## Step 2: Analyze Updated Schema

Read:

`outputs/09-updated-erd-and-logical-design-G02.md`

Determine:

- Newly introduced entities
- Removed entities
- Renamed entities
- Added attributes
- Removed attributes
- Renamed attributes
- Modified data types
- Modified keys
- Modified relationships
- Modified cardinalities
- New constraints
- Removed constraints

Produce an internal mapping between the old schema and the new schema before generating SQL.

---

## Step 3: Design Migration Strategy

For every table in the old schema, determine one of the following actions:

- **Keep** (structure unchanged)
- **Rename**
- **Split into multiple tables**
- **Merge into another table**
- **Replace**
- **Remove**

For every column:

- Keep
- Rename
- Convert datatype
- Split
- Merge
- Remove
- Generate default value
- Derive from existing data

When data cannot be migrated without ambiguity, insert sensible placeholder values while preserving referential integrity.

Never discard existing data unless it no longer has a valid representation in the updated schema.

---

## Step 4: Implement the New Schema

Using the implementation instruction provided:

- Create all tables.
- Create all primary keys.
- Create all foreign keys.
- Create CHECK constraints.
- Create UNIQUE constraints.
- Create TRIGGER constraints
Do **not** modify the old schema.

Implement the updated schema exactly as defined in the new logical design.

---

## Step 5: Migrate Existing Data

Generate SQL statements that migrate data from the old schema into the new schema.

Migration should:

- Preserve existing records whenever possible.
- Preserve business meaning.
- Preserve relationships.
- Preserve primary key references when appropriate.
- Rebuild relationships when keys have changed.
- Populate new mandatory fields using:
  - Existing values
  - Derived values
  - Business defaults
  - NULL only when allowed

If an old entity maps to multiple new entities, correctly distribute the data.

If multiple old entities merge into one new entity, consolidate the records appropriately.

---

## Step 6: Handle Removed Objects

If an old table or attribute no longer exists:

- Do not recreate it.
- Migrate any reusable information into the new structure.
- Ignore obsolete data that has no valid destination.

Avoid generating unused tables solely for backward compatibility.

---

## Step 7: Validate Data Integrity

Ensure the migrated database satisfies:

- Primary key constraints
- Foreign key constraints
- UNIQUE constraints
- CHECK constraints
- NOT NULL constraints
- TRIGGER constraints

The migration script should not violate referential integrity at any stage.

Order INSERT statements appropriately to satisfy dependency relationships.

---

## Step 8: Final Verification

Before completing the SQL script, internally verify that:

- Every new entity has been created.
- Every required relationship exists.
- Every mandatory attribute has been populated.
- No foreign keys are broken.
- No duplicate primary keys are introduced.
- Existing data has been migrated wherever a valid mapping exists.