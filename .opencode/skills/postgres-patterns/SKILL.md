---
name: postgres-patterns
description: PostgreSQL schema design, query optimization, indexing, and transaction management for RenTahanan.
---

## Schema Conventions

### Enum Types
Defined in `server/schema/init.sql`:
- `user_role`: OWNER, CARETAKER, TENANT
- `room_type`: SINGLE, DOUBLE, QUAD
- `bed_status`: VACANT, OCCUPIED, OVERDUE
- `tenant_status`: ACTIVE, MOVED_OUT, FLAGGED_DEBT
- `contract_status`: ACTIVE, COMPLETED, TERMINATED
- `billing_status`: UNPAID, PAID, OVERDUE

### Timestamp Triggers
All tables use `update_updated_at_column()` trigger:
```sql
CREATE TRIGGER update_table_updated_at
    BEFORE UPDATE ON table_name
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### Indexes (Performance)
```sql
CREATE INDEX idx_beds_status ON beds(status);
CREATE INDEX idx_billing_status ON billing_statements(status);
CREATE INDEX idx_payments_or ON payments(or_number);
CREATE INDEX idx_contracts_tenant ON contracts(tenant_id);
```

## Transaction Safety Rules

### Bed Assignment (contractController.js)
```sql
-- 1. Lock the bed row
SELECT * FROM beds WHERE bed_id = $1 FOR UPDATE;

-- 2. Check status in same transaction
-- 3. Insert contract
-- 4. Update bed status to OCCUPIED
-- 5. COMMIT
```

### Payment Recording (paymentController.js)
```sql
-- 1. Check OR number uniqueness
SELECT * FROM payments WHERE or_number = $1;

-- 2. Insert payment
-- 3. Update billing_statement status if fully paid
-- 4. COMMIT
```

## Query Patterns

### Joins for Related Data
```javascript
// Contracts with tenant and bed info
const contracts = await pool.query(`
  SELECT contracts.*, tenants.first_name, tenants.last_name, beds.bed_code 
  FROM contracts 
  JOIN tenants ON contracts.tenant_id = tenants.tenant_id 
  JOIN beds ON contracts.bed_id = beds.bed_id
`);
```

### Pagination
```javascript
const page = parseInt(req.query.page) || 1;
const limit = parseInt(req.query.limit) || 20;
const offset = (page - 1) * limit;

const result = await pool.query(
  'SELECT * FROM table ORDER BY created_at DESC LIMIT $1 OFFSET $2',
  [limit, offset]
);
```

## Migration Safety

- Use `server/schema/init.sql` for full re-initialization (dev only)
- For production: create numbered migration files
- Never drop columns in production without expand-contract pattern
- Test migrations on staging with production data volume