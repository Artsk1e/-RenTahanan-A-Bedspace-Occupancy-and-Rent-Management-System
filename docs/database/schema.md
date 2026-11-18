# Database Schema — RenTahanan

## Overview
PostgreSQL schema for the RenTahanan Boarding House Management System.
Single boarding house (Evelyn Lady's Dormitory), flat-rate rent, cash payments with OR tracking.

## Current Version
Baseline: `server/schema/init.sql` (clean-slate dev script)
Migrations: `server/migrations/` (to be created for production changes)

## ENUM Types

| Enum | Values | Description |
|------|--------|-------------|
| `user_role` | `OWNER`, `CARETAKER`, `TENANT` | System access roles |
| `room_type` | `SINGLE`, `DOUBLE`, `QUAD` | Room capacity categories |
| `bed_status` | `VACANT`, `OCCUPIED`, `OVERDUE` | Bedspace availability |
| `tenant_status` | `ACTIVE`, `MOVED_OUT`, `FLAGGED_DEBT` | Tenant lifecycle |
| `contract_status` | `ACTIVE`, `COMPLETED`, `TERMINATED` | Lease lifecycle |
| `billing_status` | `UNPAID`, `PARTIALLY_PAID`, `PAID`, `OVERDUE` | Payment status |

## Tables

### users
Authentication accounts for all roles.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | SERIAL | PRIMARY KEY | Unique identifier |
| `username` | VARCHAR(50) | UNIQUE, NOT NULL | Login username |
| `password_hash` | VARCHAR(255) | NOT NULL | bcrypt hash |
| `role` | user_role | NOT NULL, DEFAULT 'TENANT' | Access role |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation time |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update (trigger) |

**Indexes**: Primary key on `user_id`, Unique on `username`

**Trigger**: `update_users_updated_at` → `update_updated_at_column()`

---

### rooms
Physical room definitions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `room_id` | SERIAL | PRIMARY KEY | Unique identifier |
| `room_number` | VARCHAR(10) | UNIQUE, NOT NULL | Room label (e.g., "101") |
| `type` | room_type | NOT NULL | SINGLE/DOUBLE/QUAD |
| `capacity` | INT | NOT NULL | Bed count (1/2/4) |
| `floor_level` | INT | NOT NULL | Floor number |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation time |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update (trigger) |

**Indexes**: Primary key on `room_id`, Unique on `room_number`

**Trigger**: `update_rooms_updated_at` → `update_updated_at_column()`

**Check Constraint** (recommended):
```sql
CHECK (
  (type = 'SINGLE' AND capacity = 1) OR
  (type = 'DOUBLE' AND capacity = 2) OR
  (type = 'QUAD' AND capacity = 4)
)
```

---

### beds
Individual rentable bedspaces.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `bed_id` | SERIAL | PRIMARY KEY | Unique identifier |
| `room_id` | INT | FK → rooms(room_id), CASCADE | Parent room |
| `bed_code` | VARCHAR(15) | UNIQUE, NOT NULL | Code (e.g., "R101-A") |
| `status` | bed_status | NOT NULL, DEFAULT 'VACANT' | VACANT/OCCUPIED/OVERDUE |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation time |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update (trigger) |

**Indexes**: Primary key on `bed_id`, Unique on `bed_code`, `idx_beds_status` on `status`

**FK**: `room_id` → `rooms.room_id` ON DELETE CASCADE

**Trigger**: `update_beds_updated_at` → `update_updated_at_column()`

---

### tenants
Resident profiles.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `tenant_id` | SERIAL | PRIMARY KEY | Unique identifier |
| `user_id` | INT | FK → users(user_id), SET NULL, UNIQUE | Portal account link |
| `first_name` | VARCHAR(50) | NOT NULL | Given name |
| `last_name` | VARCHAR(50) | NOT NULL | Family name |
| `contact_number` | VARCHAR(15) | NOT NULL | Phone |
| `emergency_contact` | VARCHAR(15) | NOT NULL | Emergency phone |
| `status` | tenant_status | NOT NULL, DEFAULT 'ACTIVE' | ACTIVE/MOVED_OUT/FLAGGED_DEBT |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation time |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update (trigger) |

**Indexes**: Primary key on `tenant_id`, Unique on `user_id`, `idx_tenants_status` on `status` (recommended)

**FK**: `user_id` → `users.user_id` ON DELETE SET NULL

**Trigger**: `update_tenants_updated_at` → `update_updated_at_column()`

---

### contracts
Lease agreements with bed assignment.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `contract_id` | SERIAL | PRIMARY KEY | Unique identifier |
| `tenant_id` | INT | FK → tenants(tenant_id), RESTRICT | Tenant reference |
| `bed_id` | INT | FK → beds(bed_id), RESTRICT | Bed reference |
| `created_by_user_id` | INT | FK → users(user_id), SET NULL | Staff creator |
| `start_date` | DATE | NOT NULL | Lease start |
| `end_date` | DATE | NOT NULL | Lease end |
| `monthly_rate` | NUMERIC(10,2) | NOT NULL, CHECK ≥ 0 | Flat monthly rent |
| `advance_rent_paid` | NUMERIC(10,2) | DEFAULT 0.00, CHECK ≥ 0 | Advance payment |
| `deposit_paid` | NUMERIC(10,2) | DEFAULT 0.00, CHECK ≥ 0 | Security deposit |
| `status` | contract_status | NOT NULL, DEFAULT 'ACTIVE' | ACTIVE/COMPLETED/TERMINATED |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation time |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update (trigger) |

**Indexes**: Primary key on `contract_id`, `idx_contracts_tenant` on `tenant_id`, `idx_contracts_bed` on `bed_id` (recommended), `idx_contracts_status` on `status` (recommended)

**FKs**:
- `tenant_id` → `tenants.tenant_id` ON DELETE RESTRICT
- `bed_id` → `beds.bed_id` ON DELETE RESTRICT
- `created_by_user_id` → `users.user_id` ON DELETE SET NULL

**Trigger**: `update_contracts_updated_at` → `update_updated_at_column()`

**Business Rules**:
- One active contract per tenant (API enforced)
- One active contract per bed (API + DB enforced)
- Creating contract → bed status = 'OCCUPIED' (transactional)
- Terminating contract → bed status = 'VACANT' (transactional)

---

### billing_statements
Monthly rent charges.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `billing_statement_id` | SERIAL | PRIMARY KEY | Unique identifier |
| `contract_id` | INT | FK → contracts(contract_id), CASCADE | Source contract |
| `tenant_id` | INT | FK → tenants(tenant_id), CASCADE | Tenant reference |
| `billing_date` | DATE | NOT NULL, DEFAULT CURRENT_DATE | Statement date |
| `due_date` | DATE | NOT NULL | Payment due date |
| `amount_due` | NUMERIC(10,2) | NOT NULL, CHECK ≥ 0 | Amount owed |
| `status` | billing_status | NOT NULL, DEFAULT 'UNPAID' | UNPAID/PARTIALLY_PAID/PAID/OVERDUE |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation time |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update (trigger) |

**Indexes**: Primary key on `billing_statement_id`, `idx_billing_status` on `status`, `idx_billing_tenant_due` on `(tenant_id, due_date)` (recommended)

**FKs**:
- `contract_id` → `contracts.contract_id` ON DELETE CASCADE
- `tenant_id` → `tenants.tenant_id` ON DELETE CASCADE

**Trigger**: `update_billing_statements_updated_at` → `update_updated_at_column()`

---

### payments
Cash collections with Official Receipt.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `payment_id` | SERIAL | PRIMARY KEY | Unique identifier |
| `billing_statement_id` | INT | FK → billing_statements(billing_statement_id), SET NULL | Linked billing (nullable) |
| `tenant_id` | INT | FK → tenants(tenant_id), CASCADE | Payer reference |
| `logged_by_user_id` | INT | FK → users(user_id), SET NULL | Collector |
| `amount_paid` | NUMERIC(10,2) | NOT NULL, CHECK > 0 | Payment amount |
| `or_number` | VARCHAR(50) | UNIQUE, NOT NULL | Official Receipt # |
| `payment_date` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Payment timestamp |
| `remarks` | TEXT | — | Notes |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update (trigger) |

**Indexes**: Primary key on `payment_id`, `idx_payments_or` on `or_number`, `idx_payments_tenant_date` on `(tenant_id, payment_date)` (recommended), `idx_payments_billing` on `billing_statement_id` (recommended)

**FKs**:
- `billing_statement_id` → `billing_statements.billing_statement_id` ON DELETE SET NULL
- `tenant_id` → `tenants.tenant_id` ON DELETE CASCADE
- `logged_by_user_id` → `users.user_id` ON DELETE SET NULL

**Trigger**: `update_payments_updated_at` → `update_updated_at_column()`

**Business Rules**:
- OR number unique (DB + API enforced)
- No partial payments: `amount_paid >= amount_due` → billing = 'PAID'
- Walk-in payments allowed (`billing_statement_id` nullable)

---

## Triggers

### `update_updated_at_column()`
Shared function updating `updated_at` on row modification.

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';
```

Applied to all 7 tables via `update_<table>_updated_at` triggers.

---

## Indexes Summary

| Index | Table | Columns | Purpose |
|-------|-------|---------|---------|
| `idx_beds_status` | beds | status | Fast vacant bed lookup |
| `idx_billing_status` | billing_statements | status | Overdue/unpaid filtering |
| `idx_payments_or` | payments | or_number | OR number lookup |
| `idx_contracts_tenant` | contracts | tenant_id | Tenant contract history |
| `idx_contracts_bed` | contracts | bed_id | Bed contract lookup (rec.) |
| `idx_contracts_status` | contracts | status | Active contract filtering (rec.) |
| `idx_billing_tenant_due` | billing_statements | (tenant_id, due_date) | Tenant billing queries (rec.) |
| `idx_payments_tenant_date` | payments | (tenant_id, payment_date) | Tenant payment history (rec.) |
| `idx_payments_billing` | payments | billing_statement_id | Billing payment lookup (rec.) |
| `idx_tenants_status` | tenants | status | Active tenant filtering (rec.) |

---

## Migration History

| Migration | Description | Status |
|-----------|-------------|--------|
| 001_initial_schema | Baseline schema from `init.sql` | Applied (dev) |

---

## ERD Reference
See `docs/erd.png` and `docs/updated erd.png` for visual schema.

---

## Conventions Reference
See `postgresql-conventions` skill and `docs/database/migrations.md` for migration procedures.