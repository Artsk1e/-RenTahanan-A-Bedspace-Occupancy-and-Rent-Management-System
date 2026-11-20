# Comprehensive Structural Documentation: RenTahanan

**Date:** 2026-11-21  
**Status:** Updated (Analysis of current system state post-requirements clarification)

---

## 1. Executive Summary & Recent Activity Log (Nov 20–21, 2026)

This document provides a consolidated structural view of the RenTahanan system. Following recent requirements clarification (move-out deposit reconciliation, forced move-out/eviction, maintenance statuses), the following artifacts were updated for full alignment:

*   **Requirements:** Clarified move-out clearance steps, eviction handling, and role-based operational permissions.
*   **ERD:** Added `room_status` enum + `rooms.status` column, added `UNAVAILABLE` to `bed_status` enum.
*   **Implementation Class Diagram:** Added deposit reconciliation (`moveOutClearance`), status toggles (`updateRoomStatus`), and added `ReportService` for auditor requirements.
*   **Conceptual Class Diagram:** Updated OOP model to strictly reflect composition over inheritance; documented the 8 Pillars of OOP.
*   **Alignment:** 100% alignment across all diagrams based on the Traceability Analysis.

---

## 2. Requirements Analysis (Summary)

### 2.1. User Stories (US) Highlights
*   **EPIC-01 (Occupancy):** Dashboard occupancy tracking, bed assignments, tenant portal.
*   **EPIC-02 (Billing):** Fixed-rate bundled rent billing, payment logging, overdue flags.
*   **EPIC-03 (Contracts/RBAC):** Role-based access, move-out clearance, deposit reconciliation, evasion flagging (`FLAGGED_DEBT`).

### 2.2. Requirements Overview
*   **Functional (FR):** 37 requirements. Key updates include:
    *   **FR-05 (Move-out):** Full pay-before-leave enforcement, deposit reconciliation, forced move-out (eviction) override.
    *   **FR-06 (RBAC/Status):** Status-only lifecycle management for Rooms/Beds/Tenants (no user-facing DELETE).
    *   **FR-07 (Evasion):** `FLAGGED_DEBT` set only on move-out with shortfall.
*   **Non-Functional (NFR):** 15 requirements. Performance (dashboard <2s), Security (RBAC/JWT), Reliability (Transactions `FOR UPDATE`), Auditability.

---

## 3. Database Structural Design (ERD)

The `rentahanan_db` schema.

### 3.1. Tables & Entities
| Table | Key Responsibility |
|-------|--------------------|
| `users` | Auth principal (id, username, password_hash, role). |
| `rooms` | Container for beds. Status: `ACTIVE`, `UNDER_MAINTENANCE`, `DECOMMISSIONED`. |
| `beds` | Rentable unit. Status: `VACANT`, `OCCUPIED`, `OVERDUE`, `UNAVAILABLE`. |
| `tenants` | Tenant profile. Status: `ACTIVE`, `MOVED_OUT`, `FLAGGED_DEBT`. |
| `contracts` | Lease agreement. Links `tenant` + `bed`. |
| `billing_statements` | Rent invoice (fixed-rate). |
| `payments` | Transaction record. Unique OR number enforced. |

### 3.2. Enumerations (Full List)
| Enum | Purpose | Values |
|------|---------|--------|
| `user_role` | RBAC | `OWNER`, `CARETAKER`, `TENANT` |
| `room_type` | Capacity | `SINGLE`, `DOUBLE`, `QUAD` |
| `room_status`| Status | `ACTIVE`, `UNDER_MAINTENANCE`, `DECOMMISSIONED` |
| `bed_status` | Status | `VACANT`, `OCCUPIED`, `OVERDUE`, `UNAVAILABLE` |
| `tenant_status`| Lifecycle | `ACTIVE`, `MOVED_OUT`, `FLAGGED_DEBT` |
| `contract_status`| Lease | `ACTIVE`, `COMPLETED`, `TERMINATED` |
| `billing_status`| Payment | `UNPAID`, `PAID`, `OVERDUE` |

### 3.3. Key Database Rules
1. **Unique OR numbers:** `payments.or_number` UNIQUE constraint.
2. **Double-booking prevention:** `contracts.bed_id` RESTRICT + API-level `FOR UPDATE` lock.
3. **Cascade cleanup:** Room delete → Beds deleted; Contract delete → Billings deleted.
4. **No deletion of Rooms/Beds/Tenants:** Status-only lifecycle management.

---

## 4. Conceptual Class Model (OOP)

This model defines the domain entities based on pure OOP principles, independent of data-type noise.

### 4.1. The 8 Pillars of OOP (RenTahanan Context)
1. **Abstraction**: `User` abstracts authentication mechanics (`login`, `updateProfile`).
2. **Inheritance**: **Not used.** Preferred Composition (Tenant/Staff *has* a User).
3. **Interface**: `IPayable` (Billing), `IAssignable` (Beds).
4. **Polymorphism**: Services handle any `IPayable` or `IAssignable` object generically.
5. **Encapsulation**: Private fields (`-`) and public methods (e.g., `markPaid()`, `toggleStatus()`) to enforce rules.
6. **Composition**: Strict whole-part (e.g., `Room` *-- `Bed`). Parent destruction cascades.
7. **Aggregation**: None (all `CASCADE` relationships are Composition).
8. **Association**: Independent objects linked (e.g., `Tenant` -- `Contract`).

### 4.2. Core Classes
- **Domain Classes:** `User`, `Staff`, `Tenant`, `Room`, `Bed`, `Contract`, `BillingStatement`, `Payment`.
- **Services:** Manage orchestration (e.g., `ContractService.moveOutClearance`, `ReportService`).

---

## 5. Architecture & RBAC

### 5.1. Layered Architecture
| Layer | Responsibility |
|-------|----------------|
| **Domain** | Entities, Enums (pure biz rules). |
| **Repository** | Data access, transactions, `FOR UPDATE`. |
| **Service** | Orchestration, complex validation. |
| **Controller** | HTTP adapter, thin mapping. |
| **Middleware** | Auth, Zod validation, Error handling. |

### 5.2. RBAC & Permission Analysis
| Capability | OWNER | CARETAKER | TENANT |
|------------|-------|-----------|--------|
| View Ledger | ✅ | ✅ | ❌ |
| Create Contracts | ✅ | ✅ | ❌ |
| Record Payments | ✅ | ✅ | ❌ |
| Move-out Clearance | ✅ | ✅ | ❌ |
| Force Move-out (Eviction)| ✅ | ❌ | ❌ |
| Manage Statuses | ✅ | ✅ | ❌ |
| Financial Reports | ✅ | ❌ | ❌ |
| Portal Access | ✅ | ✅ | ✅ |

---

## 6. Traceability Matrix Summary

| Updated FR | ERD Support | Impl. Class Support | Conceptual Class Support |
|------------|-------------|---------------------|--------------------------|
| **FR-05.1–5.4** (Move-out) | ✅ (`tenants.status`) | ✅ (`ContractService.moveOutClearance`) | ✅ (`Contract.moveOutClearance`) |
| **FR-05.6** (Eviction) | ✅ | ✅ (`ContractService.forceTerminate`) | ✅ (`Contract.forceTerminate`) |
| **FR-06.1** (Owner Audit) | ✅ | ✅ (`ReportService`) | ✅ (`Staff` methods) |
| **FR-06.6/6.7** (No Delete)| ✅ (Status-only) | ✅ (No DELETE controllers) | ✅ (Design rationale) |

*Documentation complete as of 2026-11-21.*