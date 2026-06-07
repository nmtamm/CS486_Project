# Business Requirement Analysis — Library Management System

> **Example** — for reference only; replace with actual project content.

---

## 1. Business Purpose

**Core problem:** The library currently tracks book loans on paper, causing lost records, overdue returns, and no visibility into inventory.

**Primary objectives:**
- Digitize check-in/check-out of books.
- Enforce borrowing limits and due-date policies automatically.
- Provide members and librarians real-time visibility into availability.

**Scope:**
- **In scope:** Book catalog, member management, borrowing/returning, fine calculation.
- **Out of scope:** Acquisitions/purchasing, inter-library loans, digital e-books.

---

## 2. Actors

| ID | Role | Responsibilities | Interactions |
|----|------|-----------------|--------------|
| A-01 | Librarian | Manage book catalog, process check-in/out, handle fines. | Full CRUD on books and loans; override fines. |
| A-02 | Member | Search catalog, borrow/return books, view own loan history. | Search, place hold, renew items via self-service portal. |
| A-03 | System Admin | Manage librarian accounts, view audit logs. | User management, system configuration. |

---

## 3. Business Data Entities & Attributes

| Entity | Core Identity | Key Attributes | Enums (Predefined Options) |
|--------|---------------|----------------|---------------------------|
| Book | ISBN | Title, Author, Publisher, Publication Year, Category, Total Copies, Available Copies | Category: Fiction, Non-Fiction, Reference, Periodical; Status: Available, Borrowed, Under Repair, Lost |
| Member | Member ID | Full Name, Email, Phone, Join Date, Max Borrow Limit | Membership Type: Student, Faculty, Staff, Public |
| Loan | Loan ID | Book ISBN, Member ID, Borrow Date, Due Date, Return Date, Fine Amount | Status: Active, Returned, Overdue, Lost |
| Fine | Fine ID | Loan ID, Amount, Issued Date, Paid Date | Status: Unpaid, Paid, Waived |

---

## 4. Business Rules

| ID | Rule |
|----|------|
| BR-01 | A member may borrow at most **5 books** at any given time. |
| BR-02 | Loan period is **14 days**; renewals extend by another **7 days**, max **2 renewals** per loan. |
| BR-03 | Overdue books incur a fine of **$0.50 per day**; fines must be cleared before new borrowing. |
| BR-04 | A hold can only be placed on books that are currently checked out; the hold is fulfilled in FIFO order when the book is returned. |
| BR-05 | A loan transitions through statuses: Active → Overdue → Lost, or Active → Returned, or Overdue → Returned. |
| BR-06 | Librarians can override any fine or due date, and the override must be logged with their ID and reason. |
| BR-07 | A book with status "Under Repair" or "Lost" cannot be borrowed. |
