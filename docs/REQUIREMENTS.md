# RenTahanan — Requirements Specification

**Source:** Agile Methodology Group Exercise (Jacuba, Malinao, Papolonias) — Week 3 Assessment  
**Client:** Evelyn Lady's Dormitory  
**Project:** RenTahanan: A Bedspace Occupancy and Rent Management System  
**Date:** 2026-09-25 (original) | Extracted: 2026-11-20

---

## 1. Problem Statement (Recap)

Managing 50+ bed spaces using paper notebooks and manual contracts creates five bottlenecks:
1. **Inflexible Billing** — Commercial systems assume submeter calculations; Evelyn's uses flat-rate bundled rent (electricity, water, laptops, phones, rice cookers included).
2. **Paper-Based Occupancy** — Caretakers manually scan handwritten room tables for vacancies across Single/Double/Quad rooms.
3. **No Role Separation** — Owner (audits/financials) vs Caretaker (cash/OR logging) share one paper logbook.
4. **Disjointed Deposits/Contracts** — Advance (1-month) + Deposit (1-month) in separate paper folders; move-out clearance is slow.
5. **Audit Vulnerabilities** — Handwritten ORs, transcription errors, missing signatures during reconciliation.

---

## 2. Epics (3 Core Epics)

| Epic ID | Epic Name | Description |
|---------|-----------|-------------|
| **EPIC-01** | **Occupancy & Bedspace Management** | Visual property map, bed assignment, tenant registration, real-time status (Vacant/Occupied/Overdue) |
| **EPIC-02** | **Fixed-Rate Billing & Payment Tracking** | Flat-rate rent with bundled utilities, OR logging, balance calculation, overdue alerts |
| **EPIC-03** | **Role-Based Access & Contract Lifecycle** | Owner vs Caretaker permissions, digital contracts, move-out clearance, deposit reconciliation, evasion flagging |

---

## 3. User Stories (12 Total)

| ID | Epic | User Story | Priority (MoSCoW) |
|----|------|------------|-------------------|
| **US-01** | EPIC-01 | As a **landlord**, I want to view my property as color-coded room/bed cards, so that I can instantly see which beds are occupied, overdue, or vacant at a glance. | **Must Have** |
| **US-02** | EPIC-01 | As a **caretaker**, I want to assign new boarders to specific bed spaces and register their contract details, so that I can prevent double-bookings and maintain accurate bed occupancy records. | **Must Have** |
| **US-03** | EPIC-01 | As a **student boarder**, I want to view my assigned room number and check-in contract details online, so that I can verify my agreement without checking paper documents. | **Should Have** |
| **US-04** | EPIC-02 | As a **landlord**, I want the system to generate fixed monthly rent statements with bundled utility allowances, so that I can send consistent monthly bills without calculating electric or water meters. | **Must Have** |
| **US-05** | EPIC-02 | As a **student boarder**, I want to see a clear breakdown of my monthly rent and bundled utilities, so that I can understand my total bill before paying. | **Should Have** |
| **US-06** | EPIC-02 | As a **caretaker**, I want to input cash payments along with their Official Receipt (OR) numbers, so that every payment is digitally logged with proof. | **Must Have** |
| **US-07** | EPIC-02 | As a **landlord**, I want the system to automatically calculate and flag unpaid rent balances, so that I can track remaining debts and prevent revenue loss. | **Must Have** |
| **US-08** | EPIC-02 | As a **caretaker**, I want the system to generate a digital receipt with tenant signature confirmation upon payment, so that both parties have a clear financial record. | **Could Have** |
| **US-09** | EPIC-03 | As a **student boarder**, I want to check my outstanding balance and payment history on my portal, so that my advance deposit can be accurately applied to my final bill when I move out. | **Must Have** |
| **US-10** | EPIC-03 | As a **caretaker**, I want a restricted transaction entry portal that only permits cash collection and OR logging, so that sensitive landlord financial configurations remain secure. | **Must Have** |
| **US-11** | EPIC-03 | As a **caretaker**, I want to capture a digital signature or manual payment acknowledgement flag when issuing an Official Receipt (OR), so that on-site payments are recorded with mutual proof. | **Must Have** |
| **US-12** | EPIC-03 | As a **landlord**, I want the system to flag past tenants who left with unsettled debts, so that they are prevented from re-registering or renting bed spaces in the future. | **Could Have** |

---

## 4. Functional Requirements (FR)

Derived from user stories and acceptance criteria:

### FR-01: Occupancy & Bedspace Management
| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-01.1 | Display all rooms with capacity (Single/Double/Quad) as color-coded cards | US-01 |
| FR-01.2 | Show bed status badges: **Green** = Occupied, **Blue** = Vacant, **Red** = Overdue | US-01 |
| FR-01.3 | Filter/sort rooms by floor, type, status | US-01 |
| FR-01.4 | Assign tenant to specific bed; update bed status → `OCCUPIED` | US-02 |
| FR-01.5 | Prevent double-booking: one active contract per bed, one per tenant | US-02 |
| FR-01.6 | Register tenant profile: name, contact, emergency contact, advance rent (1-month), deposit (1-month) | US-02 |
| FR-01.7 | Link signed contract record to tenant + bed | US-02 |
| FR-01.8 | Tenant portal: view room number, check-in date, monthly rate, deposit history | US-03 |

### FR-02: Fixed-Rate Billing & Utility Allocation
| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-02.1 | Generate monthly billing statements at fixed rate per bed | US-04 |
| FR-02.2 | Bundled utilities included automatically (electricity, water, laptops, phones, rice cookers) — **no submeter calculation** | US-04 |
| FR-02.3 | Configurable monthly rate per bed/room type | US-04 |
| FR-02.4 | Billing cycle trigger (manual or scheduled) generates statements for all active contracts | US-04 |
| FR-02.5 | Tenant itemized statement: base rent + bundled utilities list = total due | US-05 |

### FR-03: Payment Logging & OR Tracking
| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-03.1 | Caretaker enters: amount, date, OR number → logs to digital ledger | US-06 |
| FR-03.2 | **OR number uniqueness enforced** (DB constraint + API check) | US-06 |
| FR-03.3 | **No partial payments** — exact full amount required (`amount_paid == amount_due`) | US-06, US-07 |
| FR-03.4 | On full payment: billing status → `PAID`, balance = 0 | US-06 |
| FR-03.5 | Walk-in payments allowed (nullable `billing_statement_id`) | US-06 |
| FR-03.6 | Digital receipt generation: OR number, amount, remaining balance, tenant signature | US-08 |
| FR-03.7 | Tenant digital signature / acknowledgement checkbox required before finalizing payment entry | US-11 |

### FR-04: Balance Calculation & Overdue Alerts
| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-04.1 | Auto-calculate outstanding balance per tenant: Σ(amount_due) - Σ(amount_paid for linked bills) | US-07 |
| FR-04.2 | Flag **billing statement** as `OVERDUE` when `due_date` passed and status = `UNPAID`; set bed status to `OVERDUE`; increment `overdue_warning_count`; set `eviction_eligible_date = due_date + 3 months`. **Tenant status remains `ACTIVE` during tenancy — only billing/bed status change.** | US-07 |
| FR-04.3 | Increment `overdue_warning_count` weekly; set `eviction_eligible_date = due_date + 3 months` | US-07 |
| FR-04.4 | Bed status → `OVERDUE` when linked billing is overdue | US-07 |
| FR-04.5 | Prevent hidden unpaid balances — all balances visible on dashboard | US-07 |

### FR-05: Move-Out Clearance & Deposit Reconciliation
| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-05.1 | On move-out initiation: calculate total outstanding balance across all billing statements (Σ amount_due - Σ amount_paid) | US-09 |
| FR-05.2 | Apply 1-month security deposit (`contracts.deposit_paid`) to outstanding balance | US-09 |
| FR-05.3 | If deposit ≥ outstanding balance: set tenant status = `MOVED_OUT`, refund excess (deposit - balance) | US-09 |
| FR-05.4 | If deposit < outstanding balance: set tenant status = `FLAGGED_DEBT`, record remaining debt for evasion tracking | US-09 |
| FR-05.5 | Pay-before-leave rule: **normal** contract termination blocked if any `UNPAID`/`OVERDUE` billing exists | US-09 |
| FR-05.6 | Forced move-out (eviction after `eviction_eligible_date`, abandonment, or owner decision): owner can override with deposit reconciliation per FR-05.1–5.4 | US-09 |

### FR-06: Role-Based Access Control (RBAC)
| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-06.1 | **OWNER**: View all dashboards/reports; approve move-out clearances; generate financial/occupancy reports; manage room/bed **status** (ACTIVE/UNDER_MAINTENANCE/DECOMMISSIONED); manage users; view audit trails | US-10 |
| FR-06.2 | **CARETAKER**: Daily operations — tenant registration, bed assignment (contract create), payment logging (OR), billing generation, overdue check, room/bed **status toggle** (ACTIVE/UNAVAILABLE), move-out execution (with deposit reconciliation) | US-10 |
| FR-06.3 | **TENANT**: Read-only portal — own profile, contract, billings, payment history | US-03, US-05, US-09 |
| FR-06.4 | JWT authentication with role claims | US-10 |
| FR-06.5 | Route-level middleware enforces permissions (403 for unauthorized) | US-10 |
| FR-06.6 | **Tenants never deleted** — lifecycle via status: `ACTIVE` → `MOVED_OUT` or `FLAGGED_DEBT` | US-09 |
| FR-06.7 | **Rooms/beds never deleted by users** — managed via status toggles; hard delete = developer migration only | — |

### FR-07: Evasion Flagging & Re-registration Block
| Req ID | Requirement | Source |
|--------|-------------|--------|
| FR-07.1 | On tenant registration: cross-check against tenants with status = `FLAGGED_DEBT` | US-12 |
| FR-07.2 | If `FLAGGED_DEBT` tenant has remaining unsettled debt → block registration | US-12 |
| FR-07.3 | If `FLAGGED_DEBT` tenant settles debt → allow registration, update status to `ACTIVE` | US-12 |
| FR-07.4 | **FLAGGED_DEBT is set only on move-out/eviction** when deposit is insufficient to cover outstanding balance (per FR-05.4); **not** set during tenancy for overdue bills | US-12 |

---

## 5. Non-Functional Requirements (NFR)

| NFR ID | Category | Requirement | Priority |
|--------|----------|-------------|----------|
| NFR-01 | **Usability** | Mobile-first responsive UI; large touch targets for caretaker payment entry on phone | Must Have |
| NFR-02 | **Usability** | High-contrast status badges (Green/Blue/Red) for bed cards; color-blind safe palette | Must Have |
| NFR-03 | **Usability** | Simplified payment form: minimal fields (amount, date, OR#), quick keypad entry | Must Have |
| NFR-04 | **Performance** | Dashboard loads < 2s with 50 rooms / 100 beds; occupancy map renders in < 500ms | Must Have |
| NFR-05 | **Performance** | Payment entry → DB commit < 500ms (caretaker waits for confirmation) | Must Have |
| NFR-06 | **Security** | JWT tokens expire in 24h; bcrypt password hashing (salt 10) | Must Have |
| NFR-07 | **Security** | OR numbers unique at DB level; SQL injection prevented via parameterized queries | Must Have |
| NFR-08 | **Security** | Role-based route protection — no direct DB access from frontend | Must Have |
| NFR-09 | **Data Integrity** | PostgreSQL transactions for contract creation (bed lock + contract insert + bed status update) | Must Have |
| NFR-10 | **Data Integrity** | `FOR UPDATE` row locking prevents double-booking concurrent requests | Must Have |
| NFR-11 | **Data Integrity** | Cascade rules: Room delete → Beds deleted; Contract delete → Billings deleted | Must Have |
| NFR-12 | **Reliability** | Automated `updated_at` triggers on all 7 tables | Should Have |
| NFR-13 | **Auditability** | Every payment logs `logged_by_user_id`, `payment_date`, `or_number` | Must Have |
| NFR-14 | **Maintainability** | Code coverage ≥ 80% on business logic (billing, payments, contracts) | Should Have |
| NFR-15 | **Deployability** | Dockerized PERN stack; deployable to Vercel (frontend) + Render/Supabase (backend+DB) | Could Have |

---

## 6. Acceptance Criteria (Given–When–Then)

### US-01: Occupancy & Bedspace Management
- **Given** the landlord or caretaker accesses the dashboard
- **When** they view the room management screen
- **Then** the system displays all rooms and bed capacities (solo, good for 2, good for 4) with color-coded status badges: Green = Occupied, Blue = Vacant, Red = Overdue

### US-02: Bedspace Assignment and Tenant Registration
- **Given** a new boarder checks in and submits their 1-month advance rent and 1-month deposit
- **When** the caretaker assigns them to an open bed in a specific room
- **Then** the system updates that bed to "Occupied" and links the tenant profile and signed contract record to the room

### US-03: Tenant Portal Lease and Record Verification
- **Given** a student boarder logs into their account
- **When** they navigate to their profile page
- **Then** they can view their assigned room number, check-in date, fixed monthly rent rate, and advance deposit history

### US-04: Fixed-Rate Rent & All-Inclusive Utility Allocation
- **Given** the owner or caretaker generates monthly billing for rooms with fixed or all-inclusive rent structures
- **When** the monthly billing cycle triggers
- **Then** the system applies the fixed monthly rate per boarder including all bundled utility permissions (laptops, phones, appliances) without requiring submeter calculations

### US-05: Tenant Itemized Statement View
- **Given** a boarder checks their monthly invoice
- **When** they open the bill details section
- **Then** the system displays a breakdown showing total rent due and bundled utilities included

### US-06: Payment Logging with Official Receipt (OR) Tracking
- **Given** a boarder pays their rent in cash to the caretaker
- **When** the caretaker enters the payment amount, date, and issued Official Receipt (OR) number into the system
- **Then** the system logs the entry into the digital ledger, updates the balance, and attaches the OR reference number

### US-07: Partial Balance & Unpaid Rent Alerts
- **Given** a boarder makes an incomplete payment or misses a monthly due date
- **When** the caretaker views the room ledger
- **Then** the system flags the tenant as "Overdue/Has Balance," calculates the exact remaining balance, and prevents hidden unpaid balances

### US-08: Digital Receipt & Signature Logging
- **Given** a payment transaction is successfully recorded by the caretaker
- **When** the receipt confirmation is submitted
- **Then** the system generates a printable or downloadable digital receipt containing the OR number, amount paid, remaining balance, and tenant signature confirmation

### US-09: Move-Out Clearance and Contract Deposit Reconciliation
- **Given** a student is moving out at the end of the semester (normal) or being evicted (forced)
- **When** the caretaker initiates the check-out process
- **Then** the system:
  1. Calculates total outstanding balance across all billing statements
  2. Applies 1-month security deposit to the balance
  3. If deposit ≥ balance: sets tenant status = `MOVED_OUT`, refunds excess
  4. If deposit < balance: sets tenant status = `FLAGGED_DEBT`, records remaining debt
  5. Updates contract status = `TERMINATED`, bed status = `VACANT`
  5. **Normal move-out**: blocked if any `UNPAID`/`OVERDUE` billings exist (pay-before-leave)
  6. **Forced move-out** (eviction/abandonment): owner can override with deposit reconciliation

### US-10: Role-Based Caretaker Cash Entry vs Landlord Review
- **Given** a caretaker logs into the application
- **When** they navigate to the payment portal
- **Then** the system grants access only to cash collection and OR logging interfaces, restricting access to system-wide ledger configurations reserved for the landlord

### US-11: In-Person Digital Acknowledgement / Signature Logging
- **Given** a caretaker receives an in-person cash payment
- **When** they record the OR details and present the receipt confirmation screen
- **Then** the system requires a tenant digital signature or acknowledgement check mark before finalizing the transaction entry into the ledger

### US-12: Evasion Flagging
- **Given** a tenant attempts to register
- **When** the system cross-checks their account history against `tenants` with status = `FLAGGED_DEBT`
- **Then**:
  - If `FLAGGED_DEBT` tenant has remaining unsettled debt → block registration (return 409)
  - If `FLAGGED_DEBT` tenant settles debt → allow registration, update status to `ACTIVE`
  - **Note**: `FLAGGED_DEBT` is only set on move-out/eviction when deposit is insufficient (FR-05.4), not during tenancy for overdue bills

---

## 7. Product Backlog (Prioritized)

| Priority | ID | Epic | User Story | Sprint |
|----------|----|------|------------|--------|
| **Must Have** | US-01 | EPIC-01 | Color-coded occupancy dashboard | Sprint 1 |
| **Must Have** | US-02 | EPIC-01 | Bedspace assignment + tenant registration | Sprint 1 |
| **Must Have** | US-04 | EPIC-02 | Fixed-rate billing + bundled utilities | Sprint 1 |
| **Must Have** | US-06 | EPIC-02 | Payment logging + OR tracking | Sprint 1 |
| **Must Have** | US-07 | EPIC-02 | Auto balance calculation + overdue flags | Sprint 1 |
| **Must Have** | US-09 | EPIC-03 | Move-out clearance + deposit reconciliation | Sprint 2 |
| **Must Have** | US-10 | EPIC-03 | Role-based caretaker cash entry portal | Sprint 1 |
| **Must Have** | US-11 | EPIC-03 | In-person digital signature/acknowledgement | Sprint 2 |
| **Should Have** | US-03 | EPIC-01 | Tenant portal lease verification | Sprint 2 |
| **Should Have** | US-05 | EPIC-02 | Tenant itemized statement view | Sprint 2 |
| **Could Have** | US-08 | EPIC-02 | Digital receipt generation + download | Sprint 3 |
| **Could Have** | US-12 | EPIC-03 | Evasion flagging / re-registration block | Sprint 3 |

---

## 8. Sprint 1 Plan (2 Weeks)

**Sprint Goal:** Establish core foundational system for real-time bedspace occupancy tracking and digital payment/OR logging to prevent missed debts.

| User Story | Dev Tasks | Responsible | Expected Output |
|------------|-----------|-------------|-----------------|
| **US-01** | Design DB tables for rooms/beds; create frontend color-coded occupancy card UI | Dev 1 (Frontend/DB) | Functional dashboard displaying room cards with live vacant/occupied/overdue badges |
| **US-02** | Create tenant registration form + bed space assignment modal; link contract deposit data | Dev 2 (Backend/UI) | Registration form that updates bed status to "Occupied" and saves tenant details |
| **US-04** | Implement flat-rate monthly billing logic + bundled utility allowance config | Dev 3 (Backend) | Automated invoice generator applying fixed monthly rent rates per tenant |
| **US-06** | Build payment entry interface for caretakers to log cash amounts, dates, OR numbers | Dev 1 & 2 | Form that records cash transactions and attaches OR numbers to tenant ledgers |
| **US-07** | Develop automated balance calculation algorithms + overdue tenant highlighting | Dev 3 (Backend) | Real-time balance calculation that flags unpaid accounts on dashboard |
| **US-10** | Implement JWT auth + role middleware (OWNER/CARETAKER/TENANT); restrict caretaker routes | Dev 2 (Backend) | Caretaker sees only cash/OR entry; Owner sees full ledger config |

---

## 9. Definition of Done (DoD)

A user story is **Done** when ALL conditions are met:

1. ✅ **Acceptance Criteria Met** — All Given–When–Then criteria pass for the story
2. ✅ **Database Integrity & Ledger Accuracy** — All backend operations update PostgreSQL correctly; balances, deposits, fixed rents mathematically accurate
3. ✅ **Role-Based Access Verified** — Feature works under correct role (caretaker = cash/OR only; tenant = read-only)
4. ✅ **Usability & Interface Testing** — UI intuitive on mobile browser; non-tech caretaker completes task without confusion
5. ✅ **Code Review & Deployment** — Peer-reviewed, no critical bugs, merged to `main` without breaking existing features

---

## 10. Team Workflow & Responsibilities

### Kanban Board Columns
```
BACKLOG → TO DO → IN PROGRESS → REVIEW/TESTING → DONE
```

### Role Assignments
| Responsibility | Member(s) |
|----------------|-----------|
| Client Communication | Jacuba |
| Requirements Coordination | Malinao |
| UI/UX Design | Jacuba, Malinao |
| Frontend Development | Jacuba, Malinao |
| Backend Development | Papolonias |
| Database Design & Queries | Papolonias |
| Testing / QA | Papolonias |
| Documentation | Jacuba, Malinao |
| Repository / Version Control | Papolonias |

### WIP Limits (Kanban)
- **IN PROGRESS**: Max 3 items per developer
- **REVIEW/TESTING**: Max 2 items per reviewer

---

## 11. Risk Register & Mitigations

| Risk | Effect | Mitigation |
|------|--------|------------|
| Caretaker finds digital entry complex/slow | Reverts to paper logbooks; incomplete records | Usability testing with large touch targets, quick OR logging, visual user guide |
| Unrecorded/delayed cash payments | Discrepancy between cash-on-hand and ledger | Mandatory OR reference validation + automated unpaid balance alerts |
| DB schema mismatch during PERN integration | Broken API endpoints, halted progress | Strict API data contracts; backend tests PG queries before frontend integration |
| Miscalculated advance deposits on move-out | Financial conflict, revenue loss | Automated deposit deduction logic flags historical unpaid balances before clearance |
| Scope creep from client feature requests | Delay in Must-Have deliverables | Strict MoSCoW prioritization; non-essential → backlog for future sprints |

---

## 12. Team Agreements (Start–Stop–Continue)

| Category | Action |
|----------|--------|
| **START** | Daily 5-min async standups via group chat to flag integration blockers early |
| **STOP** | Pushing unreviewed code directly to `main` without peer testing or DB transaction edge-case tests |
| **CONTINUE** | Clear role division for fast parallel development |
| **AGREEMENT** | Before any code merges to `main`, at least one other member must test it and confirm all Given–When–Then criteria pass |

---

## 13. Traceability Matrix (User Story → Code Coverage)

| US ID | Backend Controller | Frontend Component | DB Tables | API Endpoints |
|-------|-------------------|-------------------|-----------|---------------|
| US-01 | `roomController`, `bedController` | `OccupancyDashboard`, `RoomCard` | `rooms`, `beds` | `GET /api/rooms`, `GET /api/beds` |
| US-02 | `tenantController`, `contractController` | `TenantRegistrationForm`, `BedAssignmentModal` | `tenants`, `contracts`, `beds` | `POST /api/tenants`, `POST /api/contracts` |
| US-03 | `tenantController` | `TenantPortalProfile` | `tenants`, `contracts` | `GET /api/tenants/:id` |
| US-04 | `billingController` | `BillingGenerator` | `billing_statements`, `contracts` | `POST /api/billing` |
| US-05 | `billingController` | `TenantInvoiceView` | `billing_statements` | `GET /api/billing/tenant/:id` |
| US-06 | `paymentController` | `PaymentEntryForm` | `payments`, `billing_statements` | `POST /api/payments` |
| US-07 | `billingController`, `paymentController` | `OverdueAlertsPanel` | `billing_statements`, `beds` | `POST /api/billing/check-overdue` |
| US-08 | `paymentController` | `DigitalReceiptGenerator` | `payments` | `GET /api/payments/:id/receipt` |
| US-09 | `contractController`, `tenantController` | `MoveOutClearanceFlow` | `contracts`, `billing_statements`, `tenants` | `DELETE /api/contracts/:id` |
| US-10 | `middleware/auth` | `CaretakerPaymentPortal` | `users` (role) | All routes via `auth(['CARETAKER'])` |
| US-11 | `paymentController` | `SignatureCapture` | `payments` (signature field) | `POST /api/payments` (signature required) |
| US-12 | `tenantController` | `RegistrationCheck` | `tenants` (status=FLAGGED_DEBT) | `POST /api/tenants` (pre-check) |

---

## 14. Current Implementation Status (as of 2026-11-20)

| Area | Status | Notes |
|------|--------|-------|
| **Database Schema** | ✅ Complete | `init.sql` with 50 rooms, 100 beds, enums, new columns |
| **Auth & RBAC** | ✅ Complete | JWT, roles, middleware, route protection |
| **Rooms/Beds CRUD** | ✅ Complete | Full API + validation |
| **Tenants CRUD** | ✅ Complete | Full API + validation |
| **Contracts** | ✅ Complete | Transactional create + terminate with bed locking |
| **Billing** | ✅ Complete | Generate statements, **new**: `checkOverdue` endpoint |
| **Payments** | ✅ Complete | OR uniqueness, **new**: exact payment enforcement |
| **Move-Out Clearance** | ⚠️ Partial | Pay-before-leave validation in `terminateContract`; **Missing**: deposit reconciliation, tenant status update (MOVED_OUT/FLAGGED_DEBT), forced move-out override |
| **Overdue Tracking** | ✅ Complete | **New**: `overdue_warning_count`, `eviction_eligible_date`, weekly check endpoint |
| **Tenant Portal (US-03, US-05)** | ❌ Not Started | Frontend only |
| **Digital Receipts (US-08)** | ❌ Not Started | PDF generation + signature capture |
| **Evasion Flagging (US-12)** | ❌ Not Started | Pre-registration check against `FLAGGED_DEBT` |
| **Frontend Dashboard (US-01)** | ❌ Not Started | React components for occupancy map |
| **Frontend Payment Form (US-06, US-11)** | ❌ Not Started | Mobile-first caretaker entry form |

---

## 14. Requirements Traceability Matrix (RTM)

| US | Requirement (FR/NFR) | AC / Test | Relevant Diagrams |
|----|---------------------|-----------|-------------------|
| **US-01** | FR-01.1, FR-01.2, FR-01.3<br>NFR-01, NFR-02, NFR-04 | AC-01: Dashboard shows all rooms with color-coded badges (Green/Blue/Red)<br>Test: Render 50 rooms / 100 beds < 500ms; color-blind safe palette verified | ERD: `rooms`, `beds` tables<br>Class Diagram: `Room`, `Bed` entities<br>Sequence: Dashboard load → GET /api/rooms |
| **US-02** | FR-01.4, FR-01.5, FR-01.6, FR-01.7<br>NFR-09, NFR-10 | AC-02: Assign tenant to vacant bed → status=OCCUPIED, contract linked<br>Test: Concurrent assignment blocked by FOR UPDATE lock; double-booking prevented | ERD: `tenants`, `contracts`, `beds`<br>Class Diagram: `Tenant`, `Contract`, `Bed`<br>Sequence: POST /api/tenants → POST /api/contracts → bed lock |
| **US-03** | FR-01.8<br>NFR-01, NFR-06 | AC-03: Tenant portal shows room#, check-in date, rate, deposit history<br>Test: JWT TENANT role access; read-only; no edit permissions | ERD: `tenants`, `contracts`<br>Class Diagram: `Tenant`, `Contract`<br>Wireframe: TenantPortalProfile |
| **US-04** | FR-02.1, FR-02.2, FR-02.3, FR-02.4<br>NFR-04, NFR-11 | AC-04: Monthly statements generated at fixed rate with bundled utilities<br>Test: All active contracts get billing_statement; no submeter math; cascade delete on contract | ERD: `billing_statements`, `contracts`<br>Class Diagram: `BillingStatement`, `Contract`<br>Sequence: POST /api/billing → generate for all active |
| **US-05** | FR-02.5<br>NFR-01, NFR-06 | AC-05: Tenant invoice shows base rent + bundled utilities = total due<br>Test: GET /api/billing/tenant/:id returns itemized breakdown; no appliance surcharges | ERD: `billing_statements`<br>Class Diagram: `BillingStatement`<br>Wireframe: TenantInvoiceView |
| **US-06** | FR-03.1, FR-03.2, FR-03.3, FR-03.4, FR-03.5<br>NFR-03, NFR-05, NFR-07, NFR-13 | AC-06: Caretaker logs cash payment with OR# → balance updated, OR unique<br>Test: Exact amount required (400 if due=400); duplicate OR# rejected 409; walk-in (null billing_id) allowed | ERD: `payments`, `billing_statements`<br>Class Diagram: `Payment`, `BillingStatement`<br>Sequence: POST /api/payments → verify OR → update status |
| **US-07** | FR-04.1, FR-04.2, FR-04.3, FR-04.4, FR-04.5<br>NFR-04, NFR-13 | AC-07: Overdue flagged when due_date passed; warning count++; eviction_eligible_date set<br>Test: POST /api/billing/check-overdue increments count weekly; bed status=OVERDUE; dashboard shows all | ERD: `billing_statements`, `beds`<br>Class Diagram: `BillingStatement.markOverdue()`<br>Sequence: Weekly cron → check-overdue → update beds |
| **US-08** | FR-03.6, FR-03.7<br>NFR-01, NFR-03, NFR-13 | AC-08: Digital receipt generated with OR#, amount, balance, tenant signature<br>Test: Signature/acknowledgement required before finalize; PDF downloadable; OR# on receipt | ERD: `payments` (signature field)<br>Class Diagram: `Payment`<br>Wireframe: DigitalReceiptGenerator, SignatureCapture |
| **US-09** | FR-05.1, FR-05.2, FR-05.3, FR-05.4, FR-05.5, FR-05.6<br>NFR-09, NFR-11, NFR-13 | AC-09: Move-out cross-checks unpaid balances; deducts from deposit; pay-before-leave enforced; forced move-out with deposit reconciliation<br>Test: Normal termination fails 400 if UNPAID/OVERDUE; deposit calc correct; status=MOVED_OUT or FLAGGED_DEBT; forced move-out applies same reconciliation | ERD: `contracts`, `billing_statements`, `tenants`<br>Class Diagram: `ContractService.checkPayBeforeLeave()`, `moveOutClearance()`<br>Sequence: MoveOutClearanceFlow → validate → deposit reconciliation → update status |
| **US-10** | FR-06.1, FR-06.2, FR-06.4, FR-06.5<br>NFR-06, NFR-08 | AC-10: Caretaker sees only cash/OR entry; Owner sees full ledger config<br>Test: JWT role middleware; 403 for CARETAKER on owner routes; 403 for TENANT on all write | ERD: `users` (role)<br>Class Diagram: `AuthService`, middleware/auth<br>Sequence: All routes → auth(['ROLE']) |
| **US-11** | FR-03.7 (signature capture)<br>NFR-01, NFR-03, NFR-13 | AC-11: Tenant digital signature/acknowledgement required before finalizing payment entry<br>Test: POST /api/payments fails 400 without signature field; mobile touch-friendly | ERD: `payments` (signature field)<br>Class Diagram: `Payment`<br>Wireframe: SignatureCapture |
| **US-12** | FR-07.1, FR-07.2, FR-07.3, FR-07.4<br>NFR-07, NFR-13 | AC-12: Registration blocked if FLAGGED_DEBT tenant with unpaid balance; settles → allow; FLAGGED_DEBT only set on move-out with insufficient deposit<br>Test: POST /api/tenants pre-check queries FLAGGED_DEBT; returns 409 if flagged with debt; settles → allow; verify FLAGGED_DEBT not set during tenancy | ERD: `tenants` (status=FLAGGED_DEBT)<br>Class Diagram: `TenantService`, `TenantRepository`<br>Sequence: RegistrationCheck → cross-check → allow/block |

---

## 15. Next Steps (Proposed)

1. **Sprint 2**: US-03, US-05, US-09, US-11 (Tenant portal, itemized statement view, move-out UX, signature capture)
2. **Sprint 3**: US-08, US-12 (Digital receipts, evasion flagging)
3. **Parallel**: Frontend development for all US-01 through US-12 (React components, mobile-first)
4. **Hardening**: E2E tests, load test with 50 rooms, security audit

---

*Document generated from Agile Methodology Week 3 Assessment (Jacuba, Malinao, Papolonias). All user stories, acceptance criteria, and priorities sourced directly from the submitted group exercise.*