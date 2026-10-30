# RenTahanan Project Journal

## Project Overview
- **Client:** Evelyn Lady's Dormitory
- **Team:** Papolonias (Backend/DB), Jacuba (Frontend/UI), Malinao (DB/QA)
- **Stack:** PERN (PostgreSQL, Express, React, Node.js)

## Milestones & Status

| Milestone | Status | Date Started | Date Completed |
| :--- | :--- | :--- | :--- |
| Phase 1: Auth & Users | In Progress | 2026-10-30 | - |
| Phase 2: Room & Bed Management | Pending | - | - |
| Phase 3: Tenants & Contracts | Pending | - | - |

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
