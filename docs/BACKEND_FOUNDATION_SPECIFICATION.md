# RenTahanan Comprehensive Backend Foundation & Architecture Specification

## 1. Executive Summary & Architecture Overview
The RenTahanan backend is built on an enterprise-grade **Node.js, Express, and PostgreSQL (PERN)** architecture designed to manage the comprehensive operational workflows of Evelyn Lady's Dormitory. The system strictly separates concerns into **Config**, **Middleware**, **Controllers**, and **Routes**.

### Core Architectural Principles:
- **Transactional Integrity:** Critical operations (e.g., contract creation, payment logging) utilize database transactions (`BEGIN`, `COMMIT`, `ROLLBACK`) and row-level locking (`FOR UPDATE`) to prevent race conditions (such as double-booking a bed).
- **Role-Based Access Control (RBAC):** Every protected endpoint enforces explicit permission checks for `OWNER`, `CARETAKER`, and `TENANT` roles via a centralized JWT middleware.
- **Financial Compliance:** Enforces strict accounting rules: partial payments are prohibited, advance payments and security deposits are explicitly tracked, and Official Receipt (OR) numbers are strictly unique.

---

## 2. Directory Structure & Module Breakdown
```text
server/
├── config/
│   └── db.js                 # PostgreSQL connection pool configuration
├── controllers/
│   ├── authController.js     # Authentication business logic (bcrypt, JWT)
│   ├── roomController.js     # Room layout and capacity management
│   ├── bedController.js      # Individual bedspace state tracking
│   ├── tenantController.js   # Resident profiles and contact info
│   ├── contractController.js # Lease lifecycle and transactional bed allocation
│   ├── billingController.js  # Monthly flat-rate billing generation
│   └── paymentController.js  # Cash collection and OR tracking
├── middleware/
│   └── auth.js               # JWT verification and RBAC enforcement
├── routes/
│   ├── auth.js               # Authentication endpoints
│   ├── users.js              # User management endpoints
│   ├── rooms.js              # Room management endpoints
│   ├── beds.js               # Bed management endpoints
│   ├── tenants.js            # Tenant profile endpoints
│   ├── contracts.js          # Lease and assignment endpoints
│   ├── billing.js            # Billing statement endpoints
│   └── payments.js           # Cash payment transaction endpoints
├── schema/
│   └── init.sql              # Database schema, enums, triggers, and seed data
├── .env                      # Environment configuration variables
└── server.js                 # Express application entry point
```

---

## 3. Detailed Component Implementation

### A. Database Configuration (`server/config/db.js`)
Establishes a connection pool using the `pg` package, loading parameters securely from environment variables. Includes startup verification to ensure database reachability.

### B. Security & Authentication Middleware (`server/middleware/auth.js`)
- **JWT Verification:** Intercepts incoming requests inspecting the `Authorization: Bearer <token>` header.
- **Role Validation:** Accepts an optional array of allowed roles (`['OWNER', 'CARETAKER']`). If the decoded token role does not match, it returns a `403 Forbidden` response.

### C. Controllers & Business Logic

#### 1. User & Authentication (`server/controllers/userController.js`)
- **Registration (`/api/auth/register`):** Hashes passwords using `bcryptjs` with a salt round of 10. Prevents duplicate usernames.
- **Login (`/api/auth/login`):** Validates credentials, compares password hashes, and issues a JWT token valid for 1 day.

#### 2. Room & Bed Management (`roomController.js`, `bedController.js`)
- Handles CRUD for rooms (`SINGLE`, `DOUBLE`, `QUAD`) and individual beds (`VACANT`, `OCCUPIED`, `OVERDUE`).
- Enforces relational constraints linking beds to rooms.

#### 3. Contracts & Bed Assignment (`server/controllers/contractController.js`)
- **Transactional Bed Allocation:** 
  1. Opens a database transaction.
  2. Selects the target bed with `FOR UPDATE` to lock it against concurrent requests.
  3. Validates that the bed status is `VACANT` and that the tenant does not already have an active contract.
  4. Inserts the contract record.
  5. Updates the bed status to `OCCUPIED`.
  6. Commits the transaction (or rolls back on error).

#### 4. Billing & Payments (`billingController.js`, `paymentController.js`)
- **Billing:** Generates monthly statements tied to active contracts with strict due dates.
- **Payments:** 
  - Enforces strict uniqueness on the `or_number` (Official Receipt).
  - Validates full payment amounts (since partial payments are disabled by business rule).
  - Automatically updates billing statement statuses to `PAID` upon full cash collection.

---

## 4. API Endpoints Reference Matrix

| Endpoint | Method | Access Role | Description |
| :--- | :--- | :--- | :--- |
| `/api/auth/register` | `POST` | Public | Register a new user |
| `/api/auth/login` | `POST` | Public | Authenticate and receive JWT |
| `/api/auth/profile` | `GET` | Authenticated | Retrieve current user session details |
| `/api/users` | `GET` | OWNER | List all system user accounts |
| `/api/rooms` | `GET` | All Roles | List all dormitory rooms |
| `/api/rooms` | `POST` | OWNER, CARETAKER | Create a new room |
| `/api/beds` | `GET` | All Roles | List all bedspaces and statuses |
| `/api/beds` | `POST` | OWNER, CARETAKER | Add a new bed to a room |
| `/api/tenants` | `GET` | OWNER, CARETAKER | List all registered tenants |
| `/api/tenants` | `POST` | OWNER, CARETAKER | Register a tenant profile |
| `/api/contracts` | `GET` | OWNER, CARETAKER | View all active/inactive leases |
| `/api/contracts` | `POST` | OWNER, CARETAKER | Create lease & assign bed (Transactional) |
| `/api/contracts/:id/terminate` | `PUT` | OWNER, CARETAKER | Terminate lease & vacate bed |
| `/api/billing` | `GET` | OWNER, CARETAKER | View monthly billing statements |
| `/api/billing` | `POST` | OWNER, CARETAKER | Generate monthly statement |
| `/api/payments` | `GET` | OWNER, CARETAKER | View payment and OR history |
| `/api/payments` | `POST` | OWNER, CARETAKER | Log cash payment & unique OR number |

---

## 5. Verification & Testing Strategy
- **Module Sanity Check:** Validates that all Express routes, controllers, and database pools mount correctly without syntax or dependency errors.
- **Transactional Rollback Testing:** Ensures that failed contract assignments or duplicate OR numbers trigger a clean database rollback, preserving system state consistency.
