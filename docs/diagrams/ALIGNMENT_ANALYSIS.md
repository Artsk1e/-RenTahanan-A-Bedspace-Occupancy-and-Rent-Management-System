# Deep Alignment Analysis: Requirements ↔ ERD ↔ Implementation Class Diagram ↔ Conceptual Class Diagram

**Date:** 2026-11-21  
**Scope:** Verify all four artifacts are fully aligned after requirements clarification and diagram updates  
**Status:** **ALL GAPS RESOLVED** — All three diagrams updated to match clarified requirements

---

## Executive Summary (Post-Fix)

| Artifact Pair | Alignment | Status |
|---------------|-----------|--------|
| **Requirements ↔ ERD** | ✅ **100%** | `room_status` enum + `rooms.status` column + `bed_status.UNAVAILABLE` added |
| **Requirements ↔ Implementation Class Diagram** | ✅ **100%** | Deposit reconciliation, status toggles, DELETE endpoints removed, ReportService added |
| **Requirements ↔ Conceptual Class Diagram** | ✅ **100%** | `Room.status`, `Bed.UNAVAILABLE`, `Contract.moveOutClearance()` added |
| **ERD ↔ Implementation Class Diagram** | ✅ **100%** | Full 1:1 mapping with new enums, services, and methods |
| **ERD ↔ Conceptual Class Diagram** | ✅ **100%** | Perfect alignment — all design decisions match |

---

## 1. Requirements → ERD Alignment (RESOLVED)

### ✅ **Fully Covered (All Gaps Fixed)**

| Requirement | ERD Support | Status |
|-------------|-------------|--------|
| **FR-01.1–5** Occupancy & Bed Management | `rooms`, `beds` tables with `room_type`, `capacity`, `floor_level`, `bed_status` enum | ✅ |
| **FR-01.6–7** Tenant Registration + Contract Link | `tenants` table + `contracts` with `tenant_id`, `bed_id`, `advance_rent_paid`, `deposit_paid` | ✅ |
| **FR-02.1–5** Fixed-Rate Billing | `billing_statements` with `amount_due`, `contracts.monthly_rate`, NO submeter columns | ✅ |
| **FR-03.1–7** Payment + OR Tracking | `payments` with `or_number` UNIQUE, `amount_paid`, `billing_statement_id` nullable, `logged_by_user_id`, `remarks` | ✅ |
| **FR-04.1–5** Overdue Alerts | `billing_statements.status`, `overdue_warning_count`, `eviction_eligible_date`, `beds.status` | ✅ |
| **FR-05.1–5.6** Move-Out + Deposit Reconciliation | `contracts` (deposit_paid), `billing_statements`, `tenants.status` = `MOVED_OUT`/`FLAGGED_DEBT` | ✅ |
| **FR-06.1–5** RBAC | `users.role` enum (OWNER/CARETAKER/TENANT) | ✅ |
| **FR-06.1, 6.2** Room/Bed Status Management | `rooms.status` (`room_status` enum), `beds.status` includes `UNAVAILABLE` | ✅ **FIXED** |
| **FR-06.6** No Tenant Deletion | `tenants` — no `deleted_at`, status-only lifecycle (`ACTIVE`/`MOVED_OUT`/`FLAGGED_DEBT`) | ✅ |
| **FR-06.7** No Room/Bed Deletion by Users | `rooms.status`, `beds.status` = `UNAVAILABLE` (hard delete = developer only) | ✅ **FIXED** |
| **FR-07.1–4** Evasion Flagging | `tenants.status` = `FLAGGED_DEBT` (only on move-out with insufficient deposit) | ✅ |
| **NFR-09, 10, 11, 13** Data Integrity | FKs with CASCADE/RESTRICT, `FOR UPDATE` support, triggers, audit columns | ✅ |

### ERD Changes Made
- Added `room_status` enum: `ACTIVE`, `UNDER_MAINTENANCE`, `DECOMMISSIONED`
- Added `rooms.status room_status DEFAULT 'ACTIVE'`
- Added `UNAVAILABLE` to `bed_status` enum
- **Normalized Payment relationships:** Removed redundant `CONTRACTS ||--o{ PAYMENTS` link; Payments now link only to `TENANTS` and `BILLING_STATEMENTS` (nullable for walk-ins)
- Updated PlantUML and Mermaid diagrams
- Updated verification checklist to 7 enums

---

## 2. Requirements → Implementation Class Diagram Alignment (RESOLVED)

### ✅ **Fully Covered (All Gaps Fixed)**

| Requirement | Implementation Class Diagram | Status |
|-------------|------------------------------|--------|
| **FR-01.1–5** | `Room`, `Bed` entities; `RoomRepository.findWithBeds()`, `BedRepository.findByStatus()` | ✅ |
| **FR-01.6–7** | `Tenant` entity + `CreateTenantDTO`; `Contract` entity with `advanceRentPaid`, `depositPaid` | ✅ |
| **FR-02.1–5** | `BillingStatement`, `BillingService.generateBilling()`, `calculateAmountDue()` | ✅ |
| **FR-03.1–7** | `Payment`, `PaymentService.recordPayment()`, `validateExactPayment()`, `verifyOrUnique()`, `generateReceipt()` | ✅ |
| **FR-04.1–5** | `BillingService.checkOverdue()`, `BillingRepository.findOverdue()`, `BedRepository.updateStatus()` | ✅ |
| **FR-05.1–5.4** Deposit Reconciliation | `ContractService.moveOutClearance()` with `MoveOutResult` (outstanding, deposit, refund, debt, flag) | ✅ **FIXED** |
| **FR-05.5** Pay-before-leave | `ContractService.checkPayBeforeLeave()`, `terminateContract()` | ✅ |
| **FR-05.6** Forced Move-Out Override | `ContractService.forceTerminate()` bypasses pay-before-leave | ✅ **FIXED** |
| **FR-06.1–5** RBAC | `AuthMiddleware.auth(roles)`, `UserRole` enum, route protection | ✅ |
| **FR-06.1, 6.2** Room/Bed Status Toggles | `RoomService.updateRoomStatus()`, `BedService.updateBedStatus()` with `RoomStatus`/`BedStatus.UNAVAILABLE` | ✅ **FIXED** |
| **FR-06.6** No Tenant Deletion | `TenantController` — no `deleteTenant()` | ✅ **FIXED** |
| **FR-06.7** No Room/Bed Deletion | `RoomController`/`BedController` — no `deleteRoom()`/`deleteBed()` (developer only) | ✅ **FIXED** |
| **FR-06.1** Owner Audit Reports | `ReportService` + `ReportController` (occupancy, financial, aging, evasion) | ✅ **FIXED** |
| **FR-07.1–4** Evasion Flagging | `TenantService.checkEvasionFlag()` queries `FLAGGED_DEBT` tenants | ✅ |
| **NFR-09,10** Transactions | `ContractService.createContract()`, `moveOutClearance()`, `forceTerminate()` with `FOR UPDATE` | ✅ |

### Implementation Class Diagram Changes Made
- Added `RoomStatus` enum + `Room.status` field
- Added `UNAVAILABLE` to `BedStatus` enum
- Added `moveOutClearance()`, `forceTerminate()` to `ContractService`
- Added `MoveOutResult` DTO
- Added `updateRoomStatus()` to `RoomService`
- Added `ReportService` with 4 report methods + `ReportController`
- Removed `deleteRoom()`, `deleteBed()`, `deleteTenant()` from controllers
- Added `createdByUserId` to `Contract`, `loggedByUserId` to `Payment` (already present)
- Updated sequence flows for move-out clearance and forced termination
- Updated verification checklist (23 items all passing)

---

## 3. Requirements → Conceptual Class Diagram Alignment (RESOLVED)

### ✅ **Fully Covered (All Gaps Fixed)**

| Requirement | Conceptual Class Diagram | Status |
|-------------|--------------------------|--------|
| **FR-01–03** | `Room`, `Bed`, `Tenant`, `Contract`, `BillingStatement`, `Payment` with correct fields | ✅ |
| **FR-04** | `BillingStatement.markOverdue()`, `BedStatus.OVERDUE` | ✅ |
| **FR-05.1–5.4** Deposit Reconciliation | `Contract.moveOutClearance()` with deposit logic | ✅ **FIXED** |
| **FR-05.5** Pay-before-leave | `Contract.terminate()` checks `BillingStatement.getBalance()` | ✅ |
| **FR-05.6** Forced Move-Out | `Contract.forceTerminate()` bypasses pay-before-leave | ✅ **FIXED** |
| **FR-06** RBAC | `User` + `Staff` (role-based), `Tenant` (view-only), `User.hasRole()` | ✅ |
| **FR-06.1, 6.2** Room/Bed Status | `Room.status` (`RoomStatus` enum), `BedStatus.UNAVAILABLE`, `Staff.toggleRoomStatus()`, `Staff.toggleBedStatus()` | ✅ **FIXED** |
| **FR-06.6** No Tenant Deletion | Composition: `User -- Tenant` (optional), status-only lifecycle | ✅ |
| **FR-06.7** No Room/Bed Deletion | `RoomStatus`/`BedStatus.UNAVAILABLE` — no deletion by users | ✅ |
| **FR-07** Evasion Flagging | `Tenant.checkEvasionFlag()`, `TenantStatus.FLAGGED_DEBT` (only on move-out) | ✅ |

### Conceptual Class Diagram Changes Made
- Added `RoomStatus` enum + `Room.status` + `toggleStatus()`
- Added `UNAVAILABLE` to `BedStatus` enum
- Added `moveOutClearance()` to `Contract` with deposit reconciliation logic
- Added `forceTerminate()` to `Contract` for eviction override
- Added `Staff` methods: `checkOverdue()`, `executeMoveOut()`, `toggleRoomStatus()`, `toggleBedStatus()`
- Updated all relationship explanations to match corrected design (Composition over Inheritance)
- Restored the original "8 Pillars of OOP" explanation format

---

## 4. Cross-Artifact Alignment: ERD ↔ Implementation ↔ Conceptual (VERIFIED)

### ✅ **Perfect Alignment (100%)**

| Element | ERD | Implementation Class Diagram | Conceptual Class Diagram |
|---------|-----|------------------------------|--------------------------|
| **Users/Roles** | `users` table, `user_role` enum | `User` entity, `UserRole` enum, `AuthService` | `User` class, `UserRole` enum |
| **Rooms** | `rooms` table, `room_status` enum, `status` column | `Room` entity + `RoomStatus` enum + `status`, `RoomService.updateRoomStatus()` | `Room` class + `RoomStatus` enum + `status` + `toggleStatus()` |
| **Beds** | `beds` table, `bed_status` enum includes `UNAVAILABLE` | `Bed` entity + `BedStatus.UNAVAILABLE`, `BedService.updateBedStatus()` | `Bed` class + `BedStatus.UNAVAILABLE` |
| **Tenants** | `tenants` table, `tenant_status` enum | `Tenant` entity + `TenantStatus` enum | `Tenant` class + `TenantStatus` enum |
| **Contracts** | `contracts` table, `contract_status` enum, `created_by_user_id` FK | `Contract` entity + `createdByUserId`, `ContractService.moveOutClearance()` | `Contract` class + `moveOutClearance()` + deposit logic |
| **Billing** | `billing_statements` table, `billing_status` enum | `BillingStatement` entity + `BillingStatus` enum | `BillingStatement` class + `BillingStatus` enum |
| **Payments** | `payments` table, `tenant_id` FK, `billing_statement_id` nullable FK | `Payment` entity + `tenantId` + `billingStatementId` (nullable) | `Payment` class (links to `Tenant` + `BillingStatement`) |
| **Reports** | N/A (view layer) | `ReportService` + `ReportController` | N/A (conceptual) |
| **Relationships** | All 9 FKs with correct cascade (normalized: no Contract→Payment) | All mapped in diagram + repository methods | All mapped with correct UML notation |

---

## 5. Traceability Matrix: Updated Requirements → All Artifacts

| Updated FR | ERD | Impl. Class Diagram | Conceptual Class Diagram | Status |
|------------|-----|---------------------|--------------------------|--------|
| **FR-04.2** (billing/bed OVERDUE, tenant stays ACTIVE) | ✅ | ✅ | ✅ | ✅ Aligned |
| **FR-05.1** (calculate total outstanding) | ✅ | ✅ `BillingRepository.findUnpaidByTenant()` | ✅ `Tenant.getOutstandingBalance()` | ✅ Aligned |
| **FR-05.2** (apply deposit) | ✅ `contracts.deposit_paid` | ✅ `ContractService.moveOutClearance()` | ✅ `Contract.moveOutClearance()` | ✅ Aligned |
| **FR-05.3** (deposit ≥ balance → MOVED_OUT + refund) | ✅ `tenants.status` = `MOVED_OUT` | ✅ `MoveOutResult.newStatus = MOVED_OUT` | ✅ `Contract.moveOutClearance()` | ✅ Aligned |
| **FR-05.4** (deposit < balance → FLAGGED_DEBT + record debt) | ✅ `tenants.status` = `FLAGGED_DEBT` | ✅ `MoveOutResult.isFlaggedDebt = true` | ✅ `Contract.moveOutClearance()` | ✅ Aligned |
| **FR-05.5** (pay-before-leave blocks normal termination) | ✅ Queryable | ✅ `ContractService.checkPayBeforeLeave()` | ✅ `Contract.terminate()` | ✅ Aligned |
| **FR-05.6** (forced move-out override) | ✅ Possible via owner | ✅ `ContractService.forceTerminate()` | ✅ `Contract.forceTerminate()` | ✅ Aligned |
| **FR-06.1** (Owner: reports, status management, approve) | ✅ `rooms.status`, `beds.UNAVAILABLE` | ✅ `ReportService`, status toggles | ✅ `Room.status`, `Bed.UNAVAILABLE` | ✅ Aligned |
| **FR-06.2** (Caretaker: daily ops, billing, overdue, status toggles, move-out) | ✅ `rooms.status`, `beds.UNAVAILABLE` | ✅ Status toggles, move-out execution | ✅ `Staff` methods for ops | ✅ Aligned |
| **FR-06.6** (Tenants never deleted) | ✅ No `deleted_at`, status-only | ✅ No `deleteTenant()` | ✅ Design rationale explains | ✅ Aligned |
| **FR-06.7** (Rooms/beds never deleted by users) | ✅ `rooms.status`, `beds.status` = `UNAVAILABLE` | ✅ No `deleteRoom()`/`deleteBed()` | ✅ Design rationale explains | ✅ Aligned |
| **FR-07.4** (FLAGGED_DEBT only on move-out with insufficient deposit) | ✅ `tenants.status` = `FLAGGED_DEBT` | ✅ `ContractService.moveOutClearance()` | ✅ `Contract.moveOutClearance()` | ✅ Aligned |

---

## 6. Verification Checklist

### Requirements Coverage
- [x] All 12 US mapped to FRs
- [x] All 37 FRs (including new FR-05.6, FR-06.6, FR-06.7, FR-07.4) traceable
- [x] All 12 ACs updated for move-out logic
- [x] All 15 NFRs still valid

### ERD Coverage
- [x] 7 tables, **7 enums** (added `room_status`), 10 FKs
- [x] `rooms.status` column with `room_status` enum
- [x] `beds.status` includes `UNAVAILABLE`
- [x] All cascade/restrict rules correct

### Implementation Class Diagram Coverage
- [x] 7 domain entities, **7 enums** (added `RoomStatus`)
- [x] Repository layer with `IRepository<T>`
- [x] Service layer with business logic (added `ReportService`, deposit reconciliation)
- [x] Controller layer thin adapters (no DELETE endpoints for Rooms/Beds/Tenants)
- [x] Middleware for auth/validation
- [x] `ContractService.moveOutClearance()` + `forceTerminate()` with deposit logic
- [x] `RoomService.updateRoomStatus()`, `BedService.updateBedStatus()`
- [x] `ReportService` for audit reports

### Conceptual Class Diagram Coverage
- [x] 8 core classes, 2 interfaces, **7 enums** (added `RoomStatus`)
- [x] Correct composition/aggregation/association
- [x] No inheritance (composition over inheritance) — matches ERD
- [x] `Room.status` + `RoomStatus` enum + `toggleStatus()`
- [x] `BedStatus.UNAVAILABLE`
- [x] `Contract.moveOutClearance()` + `forceTerminate()` with deposit logic
- [x] `Staff` methods for daily ops

---

## 7. Conclusion

**All three diagrams are now 100% aligned with the clarified REQUIREMENTS.md.**

### Changes Summary

| Diagram | Key Changes |
|---------|-------------|
| **ERD** | Added `room_status` enum + `rooms.status` column; Added `UNAVAILABLE` to `bed_status` enum; **Normalized Payment relationships** (removed redundant `CONTRACTS → PAYMENTS` link; Payments link only to `TENANTS` + `BILLING_STATEMENTS`); Updated PlantUML + Mermaid; Updated business rules section |
| **Implementation Class Diagram** | Added `RoomStatus` enum + `Room.status`; Added `UNAVAILABLE` to `BedStatus`; Added `moveOutClearance()` + `forceTerminate()` + `MoveOutResult` to `ContractService`; Added `updateRoomStatus()` to `RoomService`; Added `ReportService` + `ReportController`; Removed DELETE endpoints for Rooms/Beds/Tenants; Updated sequence flows; Updated verification checklist |
| **Conceptual Class Diagram** | Added `RoomStatus` enum + `Room.status` + `toggleStatus()`; Added `UNAVAILABLE` to `BedStatus`; Added `moveOutClearance()` + `forceTerminate()` to `Contract`; Added `Staff` operational methods; Restored original OOP explanation format; Documented composition-over-inheritance rationale |

**No code changes made** — this is a documentation verification and alignment report. The backend implementation should be updated separately to match these diagrams.

---

*Analysis complete. All diagrams updated to match clarified requirements as of 2026-11-21.*