---
name: systematic-debugging
description: Structured approach to debugging issues in Express/Node.js/PostgreSQL applications. Use when encountering any bug, test failure, or unexpected behavior.
---

## Workflow

1. **Reproduce** - Create a minimal reproduction case
2. **Isolate** - Narrow down the failing component (controller, middleware, DB query)
3. **Hypothesize** - Form specific, testable hypotheses about root cause
4. **Verify** - Test each hypothesis with targeted checks
5. **Fix** - Apply minimal fix with regression test
6. **Document** - Record findings in PROJECT_JOURNAL.md

## Key Principles

- **Evidence before assertions** - Never claim a fix works without verification
- **Check the obvious first** - Environment variables, DB connectivity, schema mismatches
- **Use structured logging** - Add `console.error` with context before complex debugging
- **Test edge cases** - Empty results, null values, concurrent requests

## Common RenTahanan Debug Patterns

### Database Issues
```javascript
// Check: connection pool exhaustion
pool.totalCount, pool.idleCount, pool.waitingCount

// Check: transaction deadlocks
SELECT * FROM pg_locks WHERE NOT granted;

// Check: constraint violations
\d+ table_name  -- check constraints
```

### Auth/RBAC Issues
- Verify JWT_SECRET is loaded in .env
- Check token expiry (1 day default)
- Verify role strings match exactly: 'OWNER', 'CARETAKER', 'TENANT'

### Transaction Issues
- All bed assignments must use `BEGIN`/`COMMIT`/`ROLLBACK`
- Use `FOR UPDATE` when selecting beds for assignment
- Check for nested transaction attempts (not supported)

## Debug Commands

```bash
# Run route verification
node server/test_routes.js

# Check DB connection
npm run dev --prefix server

# View logs
tail -f server/logs/app.log  # if logging configured
```