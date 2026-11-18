---
name: database-migrations
description: Safe, reversible PostgreSQL migration patterns for RenTahanan schema changes.
---

## Current State

Schema lives in `server/schema/init.sql` — a full re-initialization script (DROP + CREATE + seed). It is a **clean-slate dev script**, not a migration runner.

## Migration Rules

### Adding columns/tables
1. New numbered migration file: `server/schema/migrations/002_add_column.sql`
2. Write `ALTER TABLE ... ADD COLUMN ...` with defaults for existing rows
3. Never modify `init.sql` destructively unless re-initializing is acceptable
4. Update `init.sql` to match final state so fresh installs get the full schema

### Destructive changes (drop column, rename, type change)
Use **expand-contract**:
1. **Expand**: add new column/table alongside old
2. **Migrate**: backfill data in batches
3. **Contract**: switch reads/writes, then drop old (separate migration, separate deploy)

### Constraint changes
- Adding NOT NULL: add as nullable first, backfill, then `SET NOT NULL`
- Adding FK: validate with `NOT VALID` then `VALIDATE CONSTRAINT` on large tables

## Transaction & Lock Notes for RenTahanan

- `contracts.bed_id` is `ON DELETE RESTRICT` — deleting a bed with contracts fails by design
- `payments.or_number` is UNIQUE — DB enforces what the controller checks
- Never run destructive DDL while the dev server holds pool connections

## Verification Steps

```bash
# 1. Apply migration
psql -U postgres -d rentahanan_db -f server/schema/migrations/002_change.sql

# 2. Verify schema
psql -U postgres -d rentahanan_db -c '\d table_name'

# 3. Run route check
node server/test_routes.js
```

## Rollback

Every migration file should have a matching down-migration or documented manual rollback. If a migration fails mid-way inside a transaction, PostgreSQL rolls back automatically — wrap each migration in `BEGIN; ... COMMIT;`.