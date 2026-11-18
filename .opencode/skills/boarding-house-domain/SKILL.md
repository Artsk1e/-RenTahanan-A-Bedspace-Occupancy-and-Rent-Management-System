---
name: boarding-house-domain
description: Domain terminology and business entities for RenTahanan boarding house management — tenants, rooms, beds, rental periods, occupancy, assignments
---

# Boarding House Domain Model

## Core Entities

### Tenant
A person renting a bedspace in the boarding house.
- **Identity**: `tenant_id` (PK), linked to `users.user_id` (optional — portal access)
- **Profile**: `first_name`, `last_name`, `contact_number`, `emergency_contact`
- **Status**: `ACTIVE` | `MOVED_OUT` | `FLAGGED_DEBT`
- **Business Rule**: One tenant → at most **one active contract** at a time

### Room
A physical room in the boarding house containing 1+ beds.
- **Identity**: `room_id` (PK), `room_number` (UNIQUE, e.g., "101", "203")
- **Type**: `SINGLE` (1 bed) | `DOUBLE` (2 beds) | `QUAD` (4 beds)
- **Capacity**: Must match type (1, 2, or 4)
- **Floor**: `floor_level` (integer)

### Bed (Bedspace)
An individual rentable bed within a room.
- **Identity**: `bed_id` (PK), `bed_code` (UNIQUE, format: `R{room_number}-{letter}`, e.g., "R101-A", "R102-B")
- **Room**: `room_id` (FK → rooms, CASCADE DELETE)
- **Status**: `VACANT` | `OCCUPIED` | `OVERDUE`
- **Business Rule**: One bed → at most **one active contract** at a time

### Contract (Lease Agreement)
A rental agreement assigning a tenant to a bed for a period.
- **Identity**: `contract_id` (PK)
- **Links**: `tenant_id` (FK, RESTRICT DELETE), `bed_id` (FK, RESTRICT DELETE), `created_by_user_id` (FK, SET NULL)
- **Period**: `start_date`, `end_date` (inclusive)
- **Financial**: `monthly_rate` (flat rate, bundled utilities), `advance_rent_paid`, `deposit_paid`
- **Status**: `ACTIVE` | `COMPLETED` | `TERMINATED`
- **Business Rules**:
  - Creating contract → bed status becomes `OCCUPIED` (transactional)
  - Terminating contract → bed status becomes `VACANT` (transactional)
  - `ON DELETE RESTRICT` on tenant/bed prevents orphan contracts

### Billing Statement
Monthly rent charge for an active contract.
- **Identity**: `billing_statement_id` (PK)
- **Links**: `contract_id` (FK, CASCADE), `tenant_id` (FK, CASCADE)
- **Dates**: `billing_date` (default CURRENT_DATE), `due_date`
- **Amount**: `amount_due` (equals contract `monthly_rate` unless adjusted)
- **Status**: `UNPAID` | `PARTIALLY_PAID` | `PAID` | `OVERDUE`

### Payment
Cash collection record with Official Receipt (OR).
- **Identity**: `payment_id` (PK)
- **Links**: `billing_statement_id` (FK, SET NULL — walk-in payments allowed), `tenant_id` (FK, CASCADE), `logged_by_user_id` (FK, SET NULL)
- **Amount**: `amount_paid` (must be ≥ `amount_due` to mark `PAID`)
- **OR Number**: `or_number` (UNIQUE, mandatory, format per business)
- **Date**: `payment_date` (default CURRENT_TIMESTAMP)
- **Remarks**: Optional notes
- **Business Rules**:
  - **No partial payments** — `amount_paid < amount_due` → billing stays `UNPAID`
  - Full payment (`amount_paid >= amount_due`) → billing status → `PAID`
  - OR number uniqueness enforced at DB + application level

### User (Authentication)
System login account for any role.
- **Identity**: `user_id` (PK), `username` (UNIQUE)
- **Auth**: `password_hash` (bcrypt)
- **Role**: `OWNER` | `CARETAKER` | `TENANT`
- **Tenant Link**: `tenants.user_id` (UNIQUE, SET NULL) — optional portal access

## Status Flow Diagrams

### Bed Status
```
VACANT ──(contract created)──→ OCCUPIED ──(contract terminated)──→ VACANT
    ↑                              │
    └──────(rent overdue)─────────┘  (OVERDUE: set by backend job or manual)
```

### Contract Status
```
ACTIVE ──(end_date reached)──→ COMPLETED
   │
   └──(terminated early)──→ TERMINATED
```

### Billing Status
```
UNPAID ──(full payment)──→ PAID
   │
   ├─(partial payment)──→ PARTIALLY_PAID (not allowed per rules)
   │
   └─(due_date passed)──→ OVERDUE
```

### Tenant Status
```
ACTIVE ──(contract terminated, no new contract)──→ MOVED_OUT
   │
   └─(debt flagged)──→ FLAGGED_DEBT ──(debt cleared)──→ ACTIVE
```

## Key Business Invariants (Enforced at DB + API)

| Invariant | Enforcement |
|-----------|-------------|
| One active contract per tenant | API check + DB (application-level) |
| One active contract per bed | API check + `FOR UPDATE` lock + DB status |
| Unique OR numbers | DB `UNIQUE` + API explicit check |
| No partial payments | API validation (`amount_paid >= amount_due`) |
| Bed status sync | Transactional in contract create/terminate |
| Advance rent + deposit tracked separately | Contract columns, not derived |

## Terminology Reference

| Term | Meaning |
|------|---------|
| Bedspace | Synonym for "bed" — individual rentable unit |
| OR / Official Receipt | Government-required receipt number for cash payment |
| Advance Rent | Pre-paid rent (typically 1-2 months) |
| Security Deposit | Refundable deposit held for damages |
| Flat Rate | All-inclusive monthly rent (utilities bundled) |
| Caretaker | Staff managing daily operations (room assignments, payments) |
| Owner | Property owner (full access, user management) |