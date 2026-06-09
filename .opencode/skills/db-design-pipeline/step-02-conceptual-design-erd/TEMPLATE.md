# Conceptual Design / ERD — {{Project Name}}

> **Template**: Fill in each section below. Replace `{{placeholders}}` with actual content based on the Step 1 output.

---

## 1. Entity-Relationship Diagram (Crow's Foot Notation)

```mermaid
erDiagram
    {{Entity1}} {
        {{datatype}} {{attribute}} PK
        {{datatype}} {{attribute}}
        {{datatype}} {{attribute}} FK
        {{datatype}} {{attribute}} UK
    }

    {{Entity2}} {
        {{datatype}} {{attribute}} PK
        {{datatype}} {{attribute}} FK
        {{datatype}} {{attribute}}
    }

    {{Entity1}} {{Crow's Foot relationship}} {{Entity2}} : "{{verb}}"

    {{- Example: User ||--o{ BookingRequest : "submits" }}}
    {{-   || = mandatory one, |o = optional one, }o = optional many, }| = mandatory many}}
```

---

## 2. Entity Descriptions

### {{Entity 1 Name}}
{{Plain-language description of what this entity represents.}}

**Predefined Options:**
- {{Attribute}}: `{{value1}}`, `{{value2}}`, `{{value3}}`

**Lifecycle (if applicable):**
`{{status1}}` → `{{status2}}` | `{{status3}}`

### {{Entity 2 Name}}
{{Plain-language description of what this entity represents.}}

**Predefined Options:**
- {{Attribute}}: `{{value1}}`, `{{value2}}`, `{{value3}}`

---

## 3. Relationship Summary

| Left Entity | Relationship | Right Entity | Left Participation | Right Participation | Cardinality | Description |
| ----------- | ------------ | ------------ | ------------------ | ------------------- | ----------- | ----------- |
| {{Entity A}} | {{verb}} | {{Entity B}} | {{mandatory / optional}} | {{mandatory / optional}} | {{1 → N / 0..1 → N / M → N}} | {{Business meaning in one sentence.}} |
| {{Entity C}} | {{verb}} | {{Entity D}} | {{mandatory / optional}} | {{mandatory / optional}} | {{cardinality}} | {{Business meaning in one sentence.}} |

---

## 4. Traceability

| Entity | Derived From Requirement |
| ------ | ------------------------ |
| {{Entity}} | {{§Paragraph: short description}} |
| {{Entity}} | {{§Paragraph: short description}} |
