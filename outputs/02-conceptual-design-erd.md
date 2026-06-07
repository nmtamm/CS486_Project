# Conceptual Design — ERD

> Based on [01-business-requirement-analysis.md](01-business-requirement-analysis.md)

## Entity-Relationship Diagram (Crow's Foot Notation)

```mermaid
erDiagram
    User {
        string UserID PK
        string FullName
        string Email
        string Phone
        string Role
        string Department
        string AccountStatus
    }

    Space {
        string SpaceCode PK
        string Name
        string Type
        string Building
        string Floor
        string RoomNumber
        int Capacity
        string CurrentStatus
        string UsagePolicy
    }

    Facility {
        int FacilityID PK
        string Name
        string Description
        string SpaceCode FK
    }

    BookingRequest {
        int BookingID PK
        string RequesterID FK
        string SpaceCode FK
        datetime RequestedStartTime
        datetime RequestedEndTime
        string Purpose
        int ExpectedParticipants
        string Status
    }

    BookingDecision {
        int DecisionID PK
        int BookingID FK
        string ApproverID FK
        datetime DecisionTime
        string Decision
        string DecisionNote
        string RejectionReason
    }

    CheckInRecord {
        int CheckInID PK
        int BookingID FK
        datetime ActualStartTime
        string CheckedInBy FK
        string InitialCondition
    }

    CompletionRecord {
        int CompletionID PK
        int BookingID FK
        datetime ActualEndTime
        string FinalCondition
        string UsageNotes
    }

    MaintenanceRecord {
        int MaintenanceID PK
        string SpaceCode FK
        string ReporterID FK
        string AssignedStaffID FK
        string ProblemType
        string ProblemDescription
        datetime StartTime
        datetime CompletionTime
        string Status
        string ResultNote
    }

    User ||--o{ BookingRequest : "submits"
    Space ||--o{ BookingRequest : "requested for"
    BookingRequest ||--o| BookingDecision : "has"
    User ||--o{ BookingDecision : "decides"
    BookingRequest ||--o| CheckInRecord : "checked in"
    User ||--o{ CheckInRecord : "performs check-in"
    BookingRequest ||--o| CompletionRecord : "completed by"
    Space ||--o{ Facility : "contains"
    Space ||--o{ MaintenanceRecord : "has maintenance"
    User ||--o{ MaintenanceRecord : "reports (as reporter)"
    User ||--o{ MaintenanceRecord : "assigned (as staff)"
```

## Entity Summary

| # | Entity | Description |
|---|--------|-------------|
| 1 | **User** | Individuals who interact with the system (students, lecturers, TAs, facility staff, admin, manager). |
| 2 | **Space** | A bookable physical room or area managed by the School. |
| 3 | **Facility** | Equipment or amenity installed in a space (e.g., projector, microphone). |
| 4 | **BookingRequest** | A request submitted by a user to reserve a space for a specific time and purpose. |
| 5 | **BookingDecision** | The approval or rejection outcome recorded by facility staff/manager. |
| 6 | **CheckInRecord** | Records the actual start of a usage session. |
| 7 | **CompletionRecord** | Records the end of a usage session and final condition. |
| 8 | **MaintenanceRecord** | Tracks a problem reported for a space and its resolution. |

## Relationship Summary

| Left Entity | Relationship | Right Entity | Business Meaning |
|-------------|--------------|--------------|------------------|
| User | 1 → N | BookingRequest | A user can submit many booking requests. |
| Space | 1 → N | BookingRequest | A space can be the subject of many booking requests. |
| BookingRequest | 1 → 1 | BookingDecision | Each booking request has exactly one decision outcome. |
| User | 1 → N | BookingDecision | A staff/manager user makes many booking decisions. |
| BookingRequest | 1 → 1 | CheckInRecord | A booking can be checked in at most once. |
| User | 1 → N | CheckInRecord | A staff user performs many check-ins. |
| BookingRequest | 1 → 1 | CompletionRecord | A booking can be completed at most once. |
| Space | 1 → N | Facility | A space contains many facilities. |
| Space | 1 → N | MaintenanceRecord | A space can have many maintenance records over time. |
| User | 1 → N | MaintenanceRecord | A user can report many issues and be assigned to many jobs. |

## Key Design Decisions

- **BookingDecision** is a separate entity (not an attribute of BookingRequest) because it has its own attributes (decision time, approver, note) and may need to be audited independently.
- **CheckInRecord** and **CompletionRecord** are separate entities to clearly track the two lifecycle events independently. A booking can be checked in but not yet completed (or become no-show without ever checking in).
- **Facility** is a weak entity dependent on Space; it exists only within the context of a space.
- **MaintenanceRecord** has two FK references to User (reporter and assigned staff), representing two distinct roles in the same entity.
