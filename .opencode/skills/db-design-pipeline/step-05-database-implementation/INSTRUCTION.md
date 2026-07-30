# Step 5: Database Implementation

Based strictly on the outputs from previous steps in the [output folder](../../../../outputs/)

Save to:
`outputs\05-db-definition-G02.sql`

## Output document structure
The document must contain exactly the following sections:

### 1. Create database using
```bash
create database [database_name]
```

### 2. Go to the newly created database
```bash
go
use [database_name]
```

### 3. Create primary table
Primary tables are those who need to firstly created before others. These tables normally do not hold any foreign keys

Use the following command
```bash
create table [table_name]
```

**NOTES**
1. While creating table, add constraints for an attribute using ```check()```
2. After define all attributes, add primary key using 
```bash
primary key (attribute_name)
```

### 4. Add foreign key
```bash
alter table [table_name] add foreign key (current_attribute) references [referenced_table_name] (referenced_attribute_name)
```

### 5. If you missed adding constraints for attribute, or there is a circular relationship between two or more tables, try this
1. Use the following command to alter the existed table
```bash
alter table [table_name]
```

2. Here are some ```alter``` commands:
```bash
ALTER TABLE [table-name] ADD [attribute-name] [data type] [constraint 1]... 
ALTER TABLE [table-name] DROP COLUMN [attribute] [constraint 1]... 
ALTER TABLE [table-name] ALTER COLUMN [attribute] [constraint 1]... 
ALTER TABLE [table-name] ADD CONSTRAINT... 
ALTER TABLE [table-name] DROP CONSTRAINT... 
```

### NOTES
1. No need to name constraints
2. If table name is a keyword or a built-in function in MySQL, raise that as an error. **DO NOT TRY TO USE SQUARE BRACKET [...] TO TRIGGER THE DATABASE TO USE AS AN OBJECT NAME**
3. **INDEXES ARE NOT YET ASKED FOR IN THIS STEP**. The constraint (if exists) should only be checked using **CHECK** only. Other constraints that needs triggering or procedure are not asked to be included when defining the database yet.