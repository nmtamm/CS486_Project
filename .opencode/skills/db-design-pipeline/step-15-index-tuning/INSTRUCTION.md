# Step 15: Index tuning

Save to:

`outputs/15-index-tuning-G02.sql`
`outputs/15-index-tuning-G02.md`
---

# Requirements
Tune the booking conflict check, room finder, and the following queries:

1. Total approved booking hours of each space for a given semester.
2. Number of approved bookings by weekday and hour for a given semester.
3. Available spaces that satisfy a required capacity and a required facility list within a given time period.
4. Approved bookings affected when a maintenance record is escalated to out-of-service.

# Workflow
1. Identify which schema is related to the given queries. List them out explicitly
2. Indentify which attribute in those schema needs indexing. List them out explicitly
3. Implement index on those attributes

**DO NOT RUN AFTER IMPLEMENTATION**