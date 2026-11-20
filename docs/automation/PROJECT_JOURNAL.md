# RenTahanan Project Journal

## Project Overview
- **Client:** Evelyn Lady's Dormitory
- **Team:** Papolonias (Backend/DB), Jacuba (Frontend/UI), Malinao (DB/QA)
- **Stack:** PERN (PostgreSQL, Express, React, Node.js)

## Milestones & Status

| Milestone | Status | Date Started | Date Completed |
| :--- | :--- | :--- | :--- |
| Phase 1: Auth & Users | Complete | 2026-10-30 | 2026-10-30 |
| Phase 2: Room & Bed Management | Complete | 2026-10-30 | 2026-10-30 |
| Phase 3: Tenants & Contracts | Complete | 2026-10-30 | 2026-10-30 |
| Phase 4: Billing & Payments | Complete | 2026-10-30 | 2026-10-30 |
| Phase 5: QA & Testing (Verifying endpoints) | Complete | 2026-11-19 | 2026-11-19 |

## Activity Log

### 2026-10-30
- **Initialization:** Project initialized with PERN stack.
- **Infrastructure:** Created documentation directories (`docs/automation/`, `docs/adr/`).
- **Infrastructure:** Initialized `PROJECT_JOURNAL.md`.
- **Planning:** Finalized Backend Core & Auth plan.
- **Implementation:** Created JWT authentication middleware (`server/middleware/auth.js`).
- **Implementation:** Added password hashing with bcrypt (`server/controllers/userController.js`).
- **Implementation:** Set up user registration and login routes (`server/routes/auth.js`).
- **Implementation:** Added role-based access control (RBAC) for user endpoints (`server/routes/users.js`).
- **Implementation:** Updated main server file to use structured routes (`server/server.js`).
- **Implementation:** Added Room and Bed Controllers and Routes (`server/controllers/roomController.js`, `server/controllers/bedController.js`, `server/routes/rooms.js`, `server/routes/beds.js`).
- **Implementation:** Added Tenant Controller and Routes (`server/controllers/tenantController.js`, `server/routes/tenants.js`).
- **Implementation:** Added Billing and Payment Controllers and Routes with OR tracking and business rule enforcement (`server/controllers/billingController.js`, `server/controllers/paymentController.js`, `server/routes/billing.js`, `server/routes/payments.js`).
- **Phase 1 & 2 Complete:** Backend core API foundation is ready.
- **Current Task:** Moving to Phase 3, QA & Testing (Verifying endpoints).

### 2026-11-19
- **Verification:** Started backend server on port 5000, confirmed health check.
- **Verification:** Ran `analyze-db.js` — confirmed all 7 tables, 6 enum types, foreign keys, triggers, indexes match schema.
- **Verification:** End-to-end API testing:
  - Auth: Register, Login, Profile (JWT tokens working)
  - Users: OWNER-only access enforced (403 for CARETAKER/TENANT)
  - Rooms: CRUD with RBAC (OWNER/CARETAKER write, all roles read)
  - Beds: CRUD with RBAC, status transitions tracked
  - Tenants: CRUD with RBAC (OWNER/CARETAKER write)
  - Contracts: Transactional create with `FOR UPDATE` locking — prevents double-booking beds and duplicate tenant contracts
  - Billing: Monthly statement generation linked to active contracts
  - Payments: OR number uniqueness enforced, auto-updates billing status to PAID on full payment
- **Business Rules Verified:**
  - Partial payments prohibited (full amount required for PAID status)
  - OR numbers strictly unique
  - Bed status transitions: VACANT → OCCUPIED on contract create → VACANT on terminate
  - Tenant cannot have multiple active contracts
- **Phase 5 Complete:** All backend endpoints verified and working correctly.

### 2026-11-20
- **Schema Update (Client Interview Requirements):** Applied business rule changes from Evelyn Lady's Dormitory interview:
  1. **Removed `PARTIALLY_PAID`** from `billing_status` enum — only `UNPAID`, `PAID`, `OVERDUE` remain.
  2. **Strict exact payment enforcement** — `amount_paid` must equal `amount_due` exactly (no partial, no overpay). Updated `paymentController.js` to reject with clear error.
  3. **Eviction grace period (3 months)** — Added `overdue_warning_count` (INT, default 0) and `eviction_eligible_date` (DATE, nullable) to `billing_statements`. Weekly overdue check increments warnings, sets eviction date to `due_date + INTERVAL '3 months'`.
  4. **Pay-before-leave rule** — `terminateContract` now blocks if tenant has any `UNPAID` or `OVERDUE` billing statements.
  5. **Room seed updated** — 50 rooms across 2 floors (2nd: 201-225, 3rd: 301-325). Room types (SINGLE/DOUBLE/QUAD) are placeholder mix, not finalized per client.
- **Files Modified:**
  - `server/schema/init.sql` — enum, new columns, 50-room seed with DO block for beds
  - `server/controllers/paymentController.js` — exact payment validation
  - `server/controllers/billingController.js` — added `checkOverdue` endpoint (POST /api/billing/check-overdue)
  - `server/routes/billing.js` — new route for overdue check
  - `server/controllers/contractController.js` — pay-before-leave validation
  - `docs/diagrams/ERD.md`, `ERD.dot`, `ERD.svg` — updated with new columns and enum
  - `docs/database/schema.md` — updated enum, new columns, business rules
- **Verification:** `init.sql` re-ran successfully, `analyze-db.js` confirms schema (50 rooms, 100 beds, 3-value billing_status, new columns present), `test_routes.js` passes.
