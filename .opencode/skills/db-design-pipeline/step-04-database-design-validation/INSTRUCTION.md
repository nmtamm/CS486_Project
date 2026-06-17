# Step 4: Database Design Validation

Based strictly on the outputs from previous steps in the [output folder](../../../../outputs/)

Save to:
`outputs/04-design-validation-G02.md`

## Output document structure
The document must contain exactly the following sections:

### 1. Schema vs. ERD Validation
Ensure the logical relational schema is an exact, technically sound translation of the conceptual ERD

Step 1: Entity-to-Table Mapping
- Every standard box in the ERD must exist as an independent table in the schema
- Verify that weak entity tables include the identifying parent table’s Primary Key (PK) as part of their own composite PK

Step 1.2: Attribute Translation
- Verify standard attributes became single columns with appropriate data types.

Step 1.3: Relationship & Cardinality
- For one-to-many, identify the "Many" side table. Confirm it contains a Foreign Key pointing back to the Primary Key of the "One" side table.
- For Many-to-Many, verify that a dedicated associative/junction table was created. This bridge table must contain a composite PK formed by the FKs of both parent tables.
- For One-to-One: Ensure the FK is placed in the table representing the entity with total participation (the mandatory side), or choose one table to hold the FK if participation is symmetric.

### 2. Schema vs. Business Requirements
Verify that the technical constraints written into the schema code actually police and enforce the real-world business constraints.

Step 1: Uniqueness and Identity RulesNatural Constraints
- Look for rules stating fields must be globally unique. Verify these columns are marked with a UNIQUE constraint.

Step 2: Domain and Business Logic Constraints
- Check for rules restricting numeric or date values.
- If a rule restricts a field to specific options, verify if the ERD in [Step 2: Conceptual Design / ERD](../../../../outputs/02-erd-design-G02.md) shows this clearly.

### 3. Issues
Write down any issue that still remained here.