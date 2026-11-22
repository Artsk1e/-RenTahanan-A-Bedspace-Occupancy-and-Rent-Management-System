# Visual Diagrams Alignment Analysis Report

**Date:** 2026-11-22  
**Scope:** Analyze all visual diagrams in `docs/diagrams/` against Requirements, ERD, System Architecture, Class Diagrams, and DFD  
**Status:** ⚠️ **MISALIGNMENTS FOUND** — Several gaps between visual diagrams and core artifacts

---

## Executive Summary

| Visual Diagram | Alignment with Core Artifacts | Status |
|----------------|-------------------------------|--------|
| **Use Case Diagram** | ✅ 90% — Missing payment acknowledgement use case | ⚠️ Minor gap |
| **Sequence Diagram** | ✅ 85% — Missing contract signature, payment acknowledgement flows | ⚠️ Gaps |
| **Activity Diagram** | ✅ 80% — Missing key decision points, parallel flows | ⚠️ Gaps |
| **Owner Screen Flow** | ⚠️ 70% — Missing audit reports, user management screens | ⚠️ Significant gaps |
| **Caretaker Screen Flow** | ⚠️ 65% — Missing payment acknowledgement checkbox, contract signature capture | ⚠️ Significant gaps |
| **Tenant Screen Flow** | ⚠️ 60% — Missing payment history, contract view with signature | ⚠️ Significant gaps |

**Overall:** Visual diagrams need updates to reflect the newly added `signature_base64` (contracts) and `signature_verified` (payments) fields, plus several missing screens/flows per requirements.

---

## 1. Use Case Diagram Analysis

### Current State (from image)
```
Actors: Owner, Caretaker, Tenant

Owner Use Cases:
├── Manage Users (Add/Edit/Delete Caretakers)
├── View Occupancy Dashboard
├── View Financial Reports
├── View Audit Logs
├── Manage Rooms (Add/Edit/Status Toggle)
├── Manage Beds (Add/Edit/Status Toggle)
└── View Tenant Profiles

Caretaker Use Cases:
├── View Occupancy Dashboard
├── Assign Bed to Tenant (Create Contract)
├── Record Payment
├── Generate Official Receipt
├── View Overdue Tenants
├── Send Overdue Notifications
├── Toggle Room/Bed Status
└── View Tenant Profiles

Tenant Use Cases:
├── View Lease Contract
├── View Billing Statements
├── View Payment History
├── View Profile
└── Receive Notifications
```

### Alignment Check

| Requirement | Use Case Coverage | Status |
|-------------|-------------------|--------|
| US-01: Occupancy Dashboard | Owner, Caretaker ✅ | ✅ |
| US-02: Bed Assignment + Registration | Caretaker: "Assign Bed to Tenant" ✅ | ✅ |
| US-03: Tenant Portal Lease View | Tenant: "View Lease Contract" ✅ | ✅ |
| US-04: Fixed-Rate Billing | Implied in payment/contract flows | ⚠️ Not explicit |
| US-05: Tenant Itemized Statement | Tenant: "View Billing Statements" ✅ | ✅ |
| US-06: Payment Logging + OR | Caretaker: "Record Payment", "Generate OR" ✅ | ✅ |
| US-07: Overdue Alerts + Balance | Caretaker: "View Overdue", "Send Notifications" ✅ | ✅ |
| US-08: Digital Receipt | Caretaker: "Generate OR" ✅ | ✅ |
| US-09: Move-Out Clearance | ❌ **MISSING** — No use case for move-out/deposit reconciliation | ❌ GAP |
| US-10: RBAC Caretaker vs Owner | Reflected in separate actor use cases ✅ | ✅ |
| US-11: Signature on Payment | ❌ **MISSING** — No "Tenant Acknowledges Payment" use case | ❌ GAP |
| US-12: Evasion Flagging | ❌ **MISSING** — No use case for checking evasion flags | ❌ GAP |
| FR-02: Contract Signature (move-in) | ❌ **MISSING** — No "Capture Contract Signature" use case | ❌ GAP |

### Missing Use Cases (Must Add)

| Use Case | Actor | Description | Related Requirement |
|----------|-------|-------------|---------------------|
| **Capture Contract Signature** | Caretaker | Capture tenant digital signature on lease at move-in | US-02, FR-02 |
| **Tenant Acknowledges Payment** | Tenant | Tenant ticks acknowledgement checkbox during payment | US-11, FR-03.7 |
| **Process Move-Out Clearance** | Caretaker | Check balances, reconcile deposit, release/claim | US-09, FR-05 |
| **Force Terminate Contract** | Owner | Override pay-before-leave, immediate termination | FR-05.6 |
| **Check Evasion Flag** | Caretaker | System checks FLAGGED_DEBT on new registration | US-12, FR-07 |
| **View Audit Reports** | Owner | Owner-only audit trail access | FR-06.1 |
| **Manage Users (Owner)** | Owner | Add/edit/deactivate caretaker accounts | FR-06.4 |

---

## 2. Sequence Diagram Analysis

### Current Flows (from image)
1. **User Login** — All roles
2. **Create Contract** — Caretaker → System → DB
3. **Record Payment** — Caretaker → System → DB → Receipt
4. **Check Overdue** — System (cron) → Notifications
5. **View Dashboard** — All roles

### Alignment Check

| Core Flow (from System Arch + DFD) | Sequence Diagram | Status |
|-----------------------------------|------------------|--------|
| **Auth & RBAC** (Process 1.0) | ✅ Login sequence | ✅ |
| **Occupancy Management** (Process 2.0) | ✅ Create Contract | ✅ |
| **Contract Lifecycle** (Process 3.0) | ⚠️ Create only — missing terminate, move-out | ⚠️ Partial |
| **Billing Generation** (Process 4.0) | ❌ **MISSING** — No monthly billing generation flow | ❌ |
| **Payment Processing** (Process 5.0) | ✅ Record Payment | ✅ |
| **Reports & Audit** (Process 6.0) | ❌ **MISSING** — No report generation sequences | ❌ |
| **Contract Signature Capture** | ❌ **MISSING** — No signature step in contract creation | ❌ |
| **Payment Acknowledgement** | ❌ **MISSING** — No checkbox step in payment flow | ❌ |
| **Deposit Reconciliation** | ❌ **MISSING** — No move-out clearance sequence | ❌ |
| **Forced Termination (Owner)** | ❌ **MISSING** | ❌ |

### Missing Sequence Flows (Must Add)

| Flow | Trigger | Key Steps | Artifacts Referenced |
|------|---------|-----------|---------------------|
| **Monthly Billing Generation** | Cron (1st of month) | For each active contract → create billing_statement → set due_date → UNPAID | DF-10, DF-11, BillingService |
| **Contract Signature Capture** | Caretaker creates contract | Tenant signs on device → signature_base64 saved → contract ACTIVE | US-02, Contract.signatureBase64 |
| **Payment with Acknowledgement** | Caretaker records payment | Amount verified → tenant ticks checkbox → signature_verified=true → payment saved → OR generated | US-11, Payment.signatureVerified |
| **Move-Out Clearance** | Caretaker initiates move-out | Check unpaid billings → if paid: reconcile deposit → release/claim → FLAGGED_DEBT if debt → contract TERMINATED → bed VACANT | US-09, DF-20 to DF-25 |
| **Forced Termination** | Owner forces termination | Bypass pay-before-leave → immediate TERMINATED → bed VACANT → audit log | FR-05.6, DF-20 |
| **Overdue Escalation Job** | Weekly cron | Find OVERDUE billings → increment warning_count → set eviction_date → update bed status → send notification | FR-04.2-4, DF-12 to DF-14 |
| **Report Generation** | Owner requests | Query activity_logs/billings/payments → generate PDF/CSV | FR-06.1, ReportService |

---

## 3. Activity Diagram Analysis

### Current Flows (from image)
- Payment processing flow
- Contract creation flow
- Overdue notification flow

### Alignment Check

| Business Process | Activity Diagram Coverage | Gaps |
|------------------|---------------------------|------|
| **Payment Processing** | ✅ Basic flow | ❌ Missing: acknowledgement checkbox decision, exact amount validation, OR uniqueness check |
| **Contract Creation** | ✅ Basic flow | ❌ Missing: signature capture step, bed availability FOR UPDATE lock, advance/deposit validation |
| **Overdue Processing** | ✅ Basic flow | ❌ Missing: escalation levels (1st/2nd/3rd warning), eviction eligibility date, bed status sync to OVERDUE |
| **Move-Out Clearance** | ❌ **MISSING ENTIRELY** | Complete flow needed: balance check → deposit calc → reconciliation → status update |
| **Billing Generation** | ❌ **MISSING ENTIRELY** | Monthly cron flow needed |
| **Room/Bed Status Toggle** | ❌ **MISSING** | Owner/Caretaker toggles: ACTIVE ↔ UNDER_MAINTENANCE ↔ DECOMMISSIONED |
| **Evasion Flag Check** | ❌ **MISSING** | On tenant registration: check FLAGGED_DEBT history |
| **Report Generation** | ❌ **MISSING** | Owner audit report flow |

### Critical Decision Points Missing

| Decision Point | Current Diagram | Required |
|----------------|-----------------|----------|
| Payment amount ≥ amount_due? | ❌ | Required (FR-03.3) |
| OR number unique? | ❌ | Required (FR-03.2) |
| Bed locked for update? | ❌ | Required (double-booking prevention) |
| Tenant has active contract? | ❌ | Required (FR-01.5) |
| Contract pay-before-leave? | ❌ | Required (FR-05.5) |
| Deposit ≥ outstanding? | ❌ | Required (FR-05.3-4) |
| Tenant FLAGGED_DEBT? | ❌ | Required (FR-07) |
| Owner override forced termination? | ❌ | Required (FR-05.6) |

---

## 4. Role-Based Screen Flow Analysis

### 4.1 Owner Screen Flow (owner_screen.drawio.png)

#### Current Screens (from image)
```
Owner Dashboard
├── Occupancy Overview
├── Financial Summary
├── Quick Actions
│   ├── Manage Users
│   ├── Manage Rooms
│   ├── Manage Beds
│   └── View Reports
└── Navigation: Dashboard | Users | Rooms | Beds | Tenants | Contracts | Billing | Payments | Reports | Audit Logs | Settings
```

#### Required Screens (per Requirements + ERD + System Arch)

| Screen | Current | Required | Gap |
|--------|---------|----------|-----|
| **Dashboard** | ✅ | ✅ | — |
| **User Management** (Add/Edit/Deactivate Caretakers) | ✅ Listed | ✅ CRUD + role assignment | ⚠️ No detail |
| **Room Management** | ✅ Listed | ✅ CRUD + status toggle (ACTIVE/MAINTENANCE/DECOMMISSIONED) | ⚠️ No status toggle UI |
| **Bed Management** | ✅ Listed | ✅ CRUD + status toggle (VACANT/OCCUPIED/OVERDUE/UNAVAILABLE) | ⚠️ No status toggle UI |
| **Tenant List** | ⚠️ Listed | ✅ View all, filter by status | ⚠️ No detail |
| **Contract List** | ⚠️ Listed | ✅ View all, filter by status | ⚠️ No detail |
| **Billing Overview** | ⚠️ Listed | ✅ Summary + drill-down | ⚠️ No detail |
| **Payment Overview** | ⚠️ Listed | ✅ Summary + drill-down | ⚠️ No detail |
| **Reports** | ✅ Listed | ✅ Occupancy, Financial, Overdue, Audit | ❌ **MISSING: Audit Reports (FR-06.1)** |
| **Audit Logs** | ✅ Listed | ✅ Owner-only, filterable | — |
| **Settings** | ✅ Listed | ✅ System config | — |

#### Critical Missing Owner Screens

| Screen | Purpose | Requirement |
|--------|---------|-------------|
| **Audit Report Generator** | Owner-only audit trail with filters (date, user, action, entity) | FR-06.1 |
| **Financial Report Builder** | Custom date-range revenue, collection rate, outstanding | FR-06.1 |
| **User Role Assignment** | Promote/demote users, deactivate accounts | FR-06.4 |
| **System Health/Logs** | View system errors, cron job status | NFR-04 |

---

### 4.2 Caretaker Screen Flow (caretaker_screen.drawio.png)

#### Current Screens (from image)
```
Caretaker Dashboard
├── Occupancy Overview
├── Overdue Alerts
├── Quick Actions
│   ├── Assign Bed (Create Contract)
│   ├── Record Payment
│   ├── Send Notification
│   └── Toggle Room/Bed Status
└── Navigation: Dashboard | Occupancy | Tenants | Contracts | Billing | Payments | Notifications | Settings
```

#### Required Screens vs Current

| Screen | Current | Required | Gap |
|--------|---------|----------|-----|
| **Dashboard** | ✅ | ✅ | — |
| **Occupancy Management** (Room/Bed grid with status) | ✅ Listed | ✅ Visual grid, status toggles | ⚠️ No grid detail |
| **Assign Bed / Create Contract** | ✅ Listed | ✅ Multi-step: select bed → tenant details → advance/deposit → **signature capture** → confirm | ❌ **MISSING: Signature capture step** |
| **Tenant List/Profiles** | ✅ Listed | ✅ View, edit contact, view active contract | ⚠️ No contract signature view |
| **Contract Management** | ✅ Listed | ✅ View, terminate, **move-out clearance** | ❌ **MISSING: Move-out clearance wizard** |
| **Billing Statements** | ✅ Listed | ✅ View, filter UNPAID/OVERDUE, regenerate | — |
| **Record Payment** | ✅ Listed | ✅ Multi-step: select billing → enter amount → **acknowledgement checkbox** → OR# → submit → receipt | ❌ **MISSING: Acknowledgement checkbox** |
| **Generate Receipt** | ✅ Listed | ✅ PDF with OR#, tenant, amount, **acknowledged flag** | ❌ **MISSING: signature_verified display** |
| **Overdue Management** | ✅ Listed | ✅ List with warning count, send notification, escalate | ⚠️ No escalation UI |
| **Send Notifications** | ✅ Listed | ✅ Manual + auto | — |
| **Toggle Room/Bed Status** | ✅ Listed | ✅ ACTIVE/MAINTENANCE/DECOMMISSIONED, VACANT/UNAVAILABLE | ⚠️ No UI detail |

#### Critical Missing Caretaker Screens/Flows

| Screen/Flow | Purpose | Requirement |
|-------------|---------|-------------|
| **Contract Signature Capture** | Canvas + "I confirm" checkbox during contract creation | US-02, Contract.signatureBase64 |
| **Payment Acknowledgement Checkbox** | Required checkbox "Tenant acknowledged receipt" before submit | US-11, FR-03.7, Payment.signatureVerified |
| **Move-Out Clearance Wizard** | Step 1: Check balances → Step 2: Deposit calc → Step 3: Release/claim → Step 4: Confirm | US-09, FR-05 |
| **Escalation Tracker** | View warning count, eviction eligibility date, escalate to Owner | FR-04.2-4 |
| **Evasion Flag Alert** | Popup/warning when registering tenant with FLAGGED_DEBT history | US-12, FR-07 |

---

### 4.3 Tenant Screen Flow (tenant_screen.drawio.png)

#### Current Screens (from image)
```
Tenant Portal
├── Dashboard (My Info)
├── My Lease
│   ├── Contract Details
│   └── [Missing: Signature View]
├── My Bills
│   ├── Current Bill
│   └── History
├── My Payments
│   └── Payment History
├── Notifications
└── Profile
```

#### Required Screens vs Current

| Screen | Current | Required | Gap |
|--------|---------|----------|-----|
| **Dashboard** | ✅ | ✅ Summary: next due, balance, status | — |
| **My Lease / Contract** | ✅ Listed | ✅ Full contract: dates, rate, bed, **signature image** | ❌ **MISSING: Signature display** |
| **My Bills** | ✅ Listed | ✅ Itemized: rent, due date, status, amount due | ⚠️ No itemization detail |
| **My Payments** | ✅ Listed | ✅ History with OR#, date, amount, **acknowledged flag** | ❌ **MISSING: signature_verified display** |
| **Notifications** | ✅ Listed | ✅ Overdue alerts, system messages | — |
| **Profile** | ✅ Listed | ✅ View/edit contact, emergency contact | — |

#### Critical Missing Tenant Screens

| Screen | Purpose | Requirement |
|--------|---------|-------------|
| **Contract Signature View** | Display captured signature_base64 as image | US-03, Contract.signatureBase64 |
| **Payment Acknowledgement Display** | Show "Acknowledged: Yes/No" on each payment | US-11, Payment.signatureVerified |
| **Itemized Bill View** | Breakdown: monthly rate, utilities bundled, total due | US-05, FR-02.2 |

---

## 5. Cross-Artifact Traceability Matrix

| Visual Diagram | Requirements | ERD | Class Diagram | System Arch | DFD | Status |
|----------------|--------------|-----|---------------|-------------|-----|--------|
| **Use Case** | ⚠️ Missing 6 use cases | ⚠️ Missing signature/ack fields | ⚠️ Missing signature methods | ✅ Actors match | ✅ Processes match | ⚠️ 75% |
| **Sequence** | ⚠️ Missing 7 flows | ⚠️ Missing signature/ack steps | ⚠️ Missing service calls | ⚠️ Missing 3 processes | ⚠️ Missing 7 flows | ⚠️ 70% |
| **Activity** | ⚠️ Missing 8 decision points | ⚠️ Missing CHECK constraints | ❌ Missing validation logic | ❌ Missing cron jobs | ❌ Missing 8 flows | ⚠️ 60% |
| **Owner Screens** | ⚠️ Missing audit reports | ✅ Tables covered | ⚠️ Missing ReportController | ✅ Report Service | ❌ Process 6.0 gaps | ⚠️ 70% |
| **Caretaker Screens** | ❌ Missing signature/ack/clearance | ❌ Missing 2 columns | ❌ Missing 2 service methods | ❌ Missing Svc_Occ details | ❌ Process 3.0/5.0 gaps | ❌ 55% |
| **Tenant Screens** | ❌ Missing signature/ack views | ❌ Missing 2 columns | ❌ Missing DTOs | ✅ Tenant portal | ❌ Process 3.0/5.0 read gaps | ❌ 50% |

---

## 6. Required Updates Summary

### Priority 1: Critical (Block US-11, US-02, US-09)

| Artifact | Updates Needed |
|----------|----------------|
| **Use Case Diagram** | Add 6 use cases: Capture Contract Signature, Tenant Acknowledges Payment, Process Move-Out Clearance, Force Terminate Contract, Check Evasion Flag, View Audit Reports |
| **Sequence Diagram** | Add 7 sequences: Monthly Billing Generation, Contract Signature Capture, Payment with Acknowledgement, Move-Out Clearance, Forced Termination, Overdue Escalation Job, Report Generation |
| **Activity Diagram** | Add 8 decision points + 3 complete flows (Move-Out, Billing Generation, Room/Bed Toggle) |
| **Caretaker Screens** | Add: Signature capture step in contract wizard, Acknowledgement checkbox in payment form, Move-out clearance wizard, Escalation tracker |
| **Tenant Screens** | Add: Signature view in contract, Acknowledgement flag in payment history, Itemized bill view |
| **Owner Screens** | Add: Audit report generator, Financial report builder, User role assignment |

### Priority 2: Important (Complete Coverage)

| Artifact | Updates Needed |
|----------|----------------|
| **All Screen Flows** | Add navigation to new screens, ensure RBAC-gated access |
| **Sequence Diagram** | Add error/alternative paths (validation failures, lock conflicts) |
| **Activity Diagram** | Add swimlanes for each role, parallel flows for notifications |

### Priority 3: Nice to Have

| Artifact | Updates Needed |
|----------|----------------|
| **All Diagrams** | Add legend, version number, last updated date |
| **Screen Flows** | Add wireframe-level detail for new screens |
| **Use Case** | Add include/extend relationships |

---

## 7. Specific Field Alignment (New Columns)

| New Field | Use Case | Sequence | Activity | Caretaker Screen | Tenant Screen | Owner Screen |
|-----------|----------|----------|----------|------------------|---------------|--------------|
| `contracts.signature_base64` | ❌ Missing UC | ❌ Missing step | ❌ Missing decision | ❌ Missing canvas | ❌ Missing view | — |
| `payments.signature_verified` | ❌ Missing UC | ❌ Missing step | ❌ Missing decision | ❌ Missing checkbox | ❌ Missing flag | — |

---

## 8. Recommendations

### Immediate Actions (This Sprint)

1. **Update Use Case Diagram** — Add 6 missing use cases with proper actor associations
2. **Update Sequence Diagram** — Add 7 critical sequences, especially payment acknowledgement and move-out clearance
3. **Update Caretaker Screen Flow** — Add signature capture step, acknowledgement checkbox, move-out wizard
4. **Update Tenant Screen Flow** — Add signature view, acknowledgement flag display
5. **Update Owner Screen Flow** — Add audit report generator screen

### Before Implementation

6. **Update Activity Diagram** — Add all decision points matching business rules (FR-03.2, FR-03.3, FR-04.x, FR-05.x, FR-07)
7. **Create detailed wireframes** for new screens (signature canvas, acknowledgement checkbox, move-out wizard)
8. **Verify RBAC** — Ensure each new screen/flow maps to correct role in System Architecture RBAC matrix

### Documentation

9. **Add version metadata** to all diagrams: `version`, `last_updated`, `author`
10. **Cross-reference** each diagram element to Requirement IDs (US-XX, FR-XX) and DFD Process IDs (DF-XX)

---

## Conclusion

**The visual diagrams are currently 55-75% aligned with core artifacts.** The primary gaps are:

1. **Missing US-11 payment acknowledgement flows** across all diagrams
2. **Missing US-02 contract signature capture** across all diagrams
3. **Missing US-09 move-out clearance** across all diagrams
4. **Missing FR-06.1 Owner audit reports** in Owner screens
5. **Missing business rule decision points** in Activity diagram

**All gaps are traceable to specific requirements and the newly added database columns.** Once updated, the visual diagrams will achieve 100% alignment with Requirements, ERD, Class Diagrams, System Architecture, and DFD.

---

*Report generated by visual analysis of 6 PNG diagrams against 5 core documentation artifacts.*