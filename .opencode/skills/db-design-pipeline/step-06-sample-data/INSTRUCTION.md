# Step 6 - Sample Data Preparation

Based strictly on the outputs from previous steps in the [output folder](../../../../outputs/)

This step produces **3 separate output files**:

| # | File | Content |
|---|------|---------|
| 1 | `outputs/06-sample-data-G02.sql` | INSERT statements for valid sample data |
| 2 | `outputs/06-normal-testcases-G02.sql` | SELECT queries verifying valid data and constraints (expected: OK) |
| 3 | `outputs/06-exceptional-testcases-G02.sql` | INSERT statements violating constraints (expected: FAIL) |

All 3 files must be executable against the database created in Step 5. Execute in order: 1 → 2 → 3.

---

## File 1: 06-sample-data-G02.sql — Valid Sample Data

### 1.1 Insert sample data for primary tables

Primary tables are those that do not depend on foreign keys.

Identify all primary tables from the Step 5 DDL. Generate realistic data for each.

Recommended minimum of 5-6 records per primary table.

Use the following command:
```sql
INSERT INTO [table_name]
(
    [attribute_1],
    [attribute_2],
    ...
)
VALUES
(
    [value_1],
    [value_2],
    ...
)
```

**NOTES**
1. Generate realistic data that matches the business domain described in Step 1.
2. Use only values allowed by CHECK constraints defined in the Step 5 DDL.
3. Primary keys must be unique.
4. Do not violate any implemented constraints.

### 1.2. Insert sample data for dependent tables

Dependent tables are those that contain foreign keys.

Identify all dependent tables from the Step 5 DDL. Generate realistic data for each.

Recommended minimum of 4-8 records per dependent table (more for junction tables).

Use the following command:
```sql
INSERT INTO [table_name]
(
    [attribute_1],
    [attribute_2],
    ...
)
VALUES
(
    [value_1],
    [value_2],
    ...
)
```

**NOTES**
1. Parent records must already exist.
2. All foreign key values must reference existing records.
3. Generate realistic dates and values appropriate to the business domain.
4. For entities with status/lifecycle fields, include records covering every valid status value defined in the Step 5 DDL.

---

## File 2: 06-normal-testcases-G02.sql — Normal Test Cases

Verify that the inserted sample data is correct and all implemented constraints accept valid values.

Each test case is a SELECT query that confirms expected data or constraint behavior.

Format:
```sql
-- TC-N01: Test description
-- Expected: <expected result or row count>

SELECT ...
```

Examples of what to test (use actual table and column names from your project):

- **Record counts**: Verify each table has the expected number of rows after insertion.
  ```sql
  -- TC-N01: Verify [table] record count
  -- Expected: <expected row count>

  SELECT COUNT(*) AS record_count FROM [table_name];
  ```

- **FK integrity**: Verify that dependent table records reference valid parent records.
  ```sql
  -- TC-N02: All [fk_column] values reference existing [parent_table] records
  -- Expected: 0 rows (no orphaned references)

  SELECT COUNT(*) AS orphaned_records
  FROM [dependent_table]
  WHERE [fk_column] NOT IN (SELECT [pk_column] FROM [parent_table]);
  ```

- **CHECK constraint acceptance**: Verify that valid predefined values are accepted.
  ```sql
  -- TC-N03: All [column] values are valid
  -- Expected: 0 rows (no invalid values)

  SELECT COUNT(*) AS invalid_values
  FROM [table_name]
  WHERE [column] NOT IN ('value1', 'value2', 'value3');
  ```

- **UNIQUE constraint acceptance**: Verify that unique columns have no duplicates.
  ```sql
  -- TC-N04: No duplicate [column] values exist
  -- Expected: 0 rows

  SELECT [column], COUNT(*) AS duplicate_count
  FROM [table_name]
  GROUP BY [column]
  HAVING COUNT(*) > 1;
  ```

- **Business logic verification**: Verify data matches expected business scenarios (e.g., status coverage).
  ```sql
  -- TC-N05: Verify [status_column] coverage
  -- Expected: at least 1 row per status

  SELECT [status_column], COUNT(*) AS count
  FROM [table_name]
  GROUP BY [status_column];
  ```

Requirements:

- Every implemented CHECK, UNIQUE, NOT NULL, PRIMARY KEY, and FOREIGN KEY constraint should have at least one normal test case confirming it accepts valid data.
- All normal test cases must pass (return the expected result) when executed against the database loaded with the sample data from File 1.
- Use realistic expected values based on the actual data inserted in File 1.
- This file must `USE` the database created in Step 5 as its first statement, and include `GO` statements as needed for batch execution.
- Do **not** include any INSERT statements in this file.

---

## File 3: 06-exceptional-testcases-G02.sql — Exceptional Test Cases

Generate invalid data to verify constraint enforcement.

Each test case must target exactly one constraint or business rule.

Create a separate SQL block for every test case.

Format:
```sql
-- TC-XX: Test description
-- Expected Result: FAIL

INSERT INTO [table_name]
(
    [attribute_1],
    [attribute_2],
    ...
)
VALUES
(
    [value_1],
    [value_2],
    ...
)
```

Requirements:

- Keep test cases independent.
- Do not reuse failed records in subsequent tests.
- Clearly indicate the expected failure.
- This file must `USE` the database created in Step 5 as its first statement, and include `GO` statements as needed for batch execution.
- Do **not** include any valid INSERT statements or SELECT queries in this file.

---

## SQL Generation Requirements (All Files)

1. Use Microsoft SQL Server syntax only.
2. Use explicit column names for every INSERT statement.
3. Do not use `SELECT *`
4. Do not use autogenerated IDs
5. Do not use placeholder values
6. Do not use random meaningless values

---

## Validation Rules

1. File 1 must insert valid data for every table.
2. File 1 must execute without errors.
3. File 2 must be executed **after** File 1; every test case must pass (return expected result).
4. File 3 must be executed **after** File 1; every test case must fail (return constraint violation error).
5. Every implemented constraint must have both a normal test case (File 2) and an exceptional test case (File 3).
6. Every implemented trigger must be tested.
7. Every implemented business rule must be tested.
8. Every exceptional case must be independent.
9. All 3 files must be executable without modification.
