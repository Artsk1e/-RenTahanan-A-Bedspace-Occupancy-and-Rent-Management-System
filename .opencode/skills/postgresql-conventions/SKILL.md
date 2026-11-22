---
name: postgresql-conventions
description: PostgreSQL naming conventions, schema organization, constraints, migrations, query conventions, transaction safety for RenTahanan
---

# PostgreSQL Conventions for RenTahanan

## Naming Conventions

| Object | Convention | Example |
|--------|------------|---------|
| Tables | `snake_case`, plural | `billing_statements`, `users` |
| Columns | `snake_case` | `bed_code`, `monthly_rate`, `created_at` |
| Primary Keys | `<table>_id` | `user_id`, `bed_id`, `contract_id` |
| Foreign Keys | `<referenced_table>_id` | `room_id`, `tenant_id`, `created_by_user_id` |
| Enums | `<domain>_type` or `<domain>_status` | `user_role`, `bed_status`, `billing_status` |
| Indexes | `idx_<table>_<column(s)>` | `idx_beds_status`, `idx_payments_or` |
| Triggers | `update_<table>_updated_at` | `update_users_updated_at` |
| Trigger Functions | `update_updated_at_column` | (shared) |
| Constraints | `<table>_<column>_<type>` | `payments_or_number_unique` |

## Schema Organization

### File Structure
```
server/
├── schema/
│   └── init.sql              # Baseline schema (clean slate for dev)
├── migrations/
│   ├── 001_initial_schema.sql
│   ├── 002_add_tenant_email.sql
│   └── ...
└── db/
    └── queries/              # Optional: reusable query functions
```

### Enum Definitions
All enums defined upfront in `init.sql`:
```sql
CREATE TYPE user_role AS ENUM ('OWNER', 'CARETAKER', 'TENANT');
CREATE TYPE room_type AS ENUM ('SINGLE', 'DOUBLE', 'QUAD');
CREATE TYPE bed_status AS ENUM ('VACANT', 'OCCUPIED', 'OVERDUE');
CREATE TYPE tenant_status AS ENUM ('ACTIVE', 'MOVED_OUT', 'FLAGGED_DEBT');
CREATE TYPE contract_status AS ENUM ('ACTIVE', 'COMPLETED', 'TERMINATED');
CREATE TYPE billing_status AS ENUM ('UNPAID', 'PAID', 'OVERDUE');
```

## Table Design Standards

### Required Columns (All Tables)
```sql
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

### Updated At Trigger (All Tables)
```sql
CREATE TRIGGER update_<table>_updated_at
    BEFORE UPDATE ON <table>
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### Primary Keys
```sql
<table>_id SERIAL PRIMARY KEY
```

### Foreign Keys
```sql
<ref_table>_id INT REFERENCES <ref_table>(<ref_table>_id) ON DELETE <ACTION>
```

| Relationship | ON DELETE | Reason |
|--------------|-----------|--------|
| `beds.room_id → rooms` | `CASCADE` | Room deleted → beds deleted |
| `contracts.tenant_id → tenants` | `RESTRICT` | Prevent tenant deletion with active contract |
| `contracts.bed_id → beds` | `RESTRICT` | Prevent bed deletion with active contract |
| `contracts.created_by_user_id → users` | `SET NULL` | Staff deletion preserves contract |
| `billing_statements.contract_id → contracts` | `CASCADE` | Contract deleted → billings deleted |
| `billing_statements.tenant_id → tenants` | `CASCADE` | Tenant deleted → billings deleted |
| `payments.billing_statement_id → billing_statements` | `SET NULL` | Walk-in payments allowed |
| `payments.tenant_id → tenants` | `CASCADE` | Tenant deleted → payments deleted |
| `payments.logged_by_user_id → users` | `SET NULL` | Staff deletion preserves payment |
| `tenants.user_id → users` | `SET NULL` | User deleted → tenant profile preserved |

### Unique Constraints
- `users.username` — One account per username
- `rooms.room_number` — One room per number
- `beds.bed_code` — One bed per code (format: `R{room}-{letter}`)
- `payments.or_number` — One payment per OR number
- `tenants.user_id` — One tenant profile per user account

### Check Constraints (Where Applicable)
```sql
-- Capacity matches room type
ALTER TABLE rooms ADD CONSTRAINT rooms_capacity_check
  CHECK (
    (type = 'SINGLE' AND capacity = 1) OR
    (type = 'DOUBLE' AND capacity = 2) OR
    (type = 'QUAD' AND capacity = 4)
  );

-- Positive financial amounts
ALTER TABLE contracts ADD CONSTRAINT contracts_positive_rates
  CHECK (monthly_rate >= 0 AND advance_rent_paid >= 0 AND deposit_paid >= 0);

ALTER TABLE billing_statements ADD CONSTRAINT billing_positive_amount
  CHECK (amount_due >= 0);

ALTER TABLE payments ADD CONSTRAINT payments_positive_amount
  CHECK (amount_paid > 0);
```

## Indexing Strategy

### Current Indexes (from `init.sql`)
```sql
CREATE INDEX idx_beds_status ON beds(status);
CREATE INDEX idx_billing_status ON billing_statements(status);
CREATE INDEX idx_payments_or ON payments(or_number);
CREATE INDEX idx_contracts_tenant ON contracts(tenant_id);
```

### Recommended Additional Indexes
```sql
-- Frequent queries
CREATE INDEX idx_contracts_bed ON contracts(bed_id);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_billing_tenant_due ON billing_statements(tenant_id, due_date);
CREATE INDEX idx_payments_tenant_date ON payments(tenant_id, payment_date);
CREATE INDEX idx_payments_billing ON payments(billing_statement_id);
CREATE INDEX idx_tenants_status ON tenants(status);
```

### Index Guidelines
- **No indexes on small tables** (<1000 rows) — sequential scan is faster
- **Covering indexes** for common query patterns
- **Partial indexes** for status filters: `CREATE INDEX idx_beds_vacant ON beds(bed_id) WHERE status = 'VACANT';`
- **CONCURRENTLY** for production index creation on large tables

## Migration Conventions

### Migration Files
```
server/migrations/
├── 001_initial_schema.sql          # Baseline (matches init.sql)
├── 002_add_tenant_email.sql
├── 003_add_late_fee_column.sql
└── ...
```

### Migration Format
```sql
-- 002_add_tenant_email.sql
-- Description: Add email column to tenants table
-- Author: <name>
-- Date: 2026-XX-XX

BEGIN;

-- Up migration
ALTER TABLE tenants ADD COLUMN email VARCHAR(100);
CREATE INDEX idx_tenants_email ON tenants(email);

COMMIT;

-- Rollback (documented separately or in .down.sql)
-- ALTER TABLE tenants DROP COLUMN email;
```

### Migration Rules
1. **Never modify applied migrations** — Create new migration
2. **Idempotent where possible** — `IF NOT EXISTS`, `IF EXISTS`
3. **Single transaction** — Each migration in `BEGIN; ... COMMIT;`
3. **Lock awareness** — Avoid long locks; use `CONCURRENTLY` for indexes
4. **Data migrations** — Batch large updates, avoid long transactions
5. **Test on staging** — With production-like data volume

## Query Conventions

### Parameterized Queries (Always)
```javascript
// GOOD
const result = await pool.query(
  'SELECT * FROM tenants WHERE tenant_id = $1 AND status = $2',
  [tenantId, 'ACTIVE']
);

// BAD — SQL injection risk
const result = await pool.query(`SELECT * FROM tenants WHERE tenant_id = ${tenantId}`);
```

### Transaction Pattern
```javascript
const client = await pool.connect();
try {
  await client.query('BEGIN');
  
  // FOR UPDATE for contested rows
  const bed = await client.query(
    'SELECT * FROM beds WHERE bed_id = $1 FOR UPDATE',
    [bedId]
  );
  
  // Business logic checks
  if (bed.rows[0].status !== 'VACANT') {
    throw new Error('Bed not vacant');
  }
  
  // Mutations
  await client.query('INSERT INTO contracts ...', [...]);
  await client.query("UPDATE beds SET status = 'OCCUPIED' WHERE bed_id = $1", [bedId]);
  
  await client.query('COMMIT');
  return result;
} catch (error) {
  await client.query('ROLLBACK');
  throw error;
} finally {
  client.release(); // ALWAYS release
}
```

### Connection Pool
```javascript
// config/db.js
const pool = new Pool({
  max: 20,                    // Production: adjust for load
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});
```

### Common Query Patterns

#### Pagination
```sql
SELECT * FROM <table>
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;
```

#### Joins for Related Data
```sql
-- Contracts with tenant + bed info
SELECT c.*, t.first_name, t.last_name, b.bed_code, r.room_number
FROM contracts c
JOIN tenants t ON c.tenant_id = t.tenant_id
JOIN beds b ON c.bed_id = b.bed_id
JOIN rooms r ON b.room_id = r.room_id
WHERE c.status = 'ACTIVE';
```

#### Aggregations
```sql
-- Outstanding balance per tenant
SELECT t.tenant_id, t.first_name, t.last_name,
       COALESCE(SUM(bs.amount_due), 0) - COALESCE(SUM(p.amount_paid), 0) AS balance
FROM tenants t
LEFT JOIN billing_statements bs ON t.tenant_id = bs.tenant_id
LEFT JOIN payments p ON bs.billing_statement_id = p.billing_statement_id
WHERE t.status = 'ACTIVE'
GROUP BY t.tenant_id;
```

## Transaction Safety Rules

| Operation | Isolation | Locking |
|-----------|-----------|---------|
| Bed assignment (contract create) | `READ COMMITTED` | `FOR UPDATE` on bed row |
| Contract termination | `READ COMMITTED` | `FOR UPDATE` on contract + bed |
| Payment logging | `READ COMMITTED` | `FOR UPDATE` on billing_statement (if linked) |
| Bulk operations | `READ COMMITTED` | Batch with small transactions |

### Deadlock Prevention
1. **Consistent lock order** — Always lock parent before child (e.g., contract before bed)
2. **Short transactions** — Minimize work between `BEGIN` and `COMMIT`
3. **Timeout** — Set `lock_timeout = '5s'` in session

## Monitoring Queries
```sql
-- Active connections
SELECT * FROM pg_stat_activity WHERE state = 'active';

-- Blocking queries
SELECT blocked_locks.pid AS blocked_pid,
       blocked_activity.query AS blocked_query,
       blocking_locks.pid AS blocking_pid,
       blocking_activity.query AS blocking_query
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted AND blocking_locks.granted;

-- Slow queries (requires pg_stat_statements)
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC LIMIT 20;
```