---
name: error-handling
description: Typed errors, error boundaries, retries, and user-facing error messages for Express/Node.js APIs.
---

## RenTahanan Error Response Contract

| Status | Meaning | Example |
|--------|---------|---------|
| 400 | Client error / validation | `Invalid credentials`, `Bed already occupied` |
| 401 | Missing/invalid token | `Access denied. No token provided.` |
| 403 | Wrong role | `Access denied. Insufficient permissions.` |
| 404 | Resource not found | `Room not found` |
| 500 | Server error | `Server error` |

## Controller Error Pattern

```javascript
exports.createThing = async (req, res) => {
  try {
    // validation returns early with 400
    if (!required) return res.status(400).json({ error: '...' });

    // business logic
    // success returns 200/201
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};
```

## Transaction Error Pattern

```javascript
const client = await pool.connect();
try {
  await client.query('BEGIN');
  // ...work...
  await client.query('COMMIT');
} catch (err) {
  await client.query('ROLLBACK');
  // Return 400 for business rule violations, 500 for unexpected errors
  res.status(400).json({ error: err.message });
} finally {
  client.release(); // ALWAYS release — pool exhaustion otherwise
}
```

## Rules

- Always release pool clients in `finally` blocks
- Log `err.message` (and stack in dev) before responding
- Never leak stack traces or SQL in responses
- Validate inputs before hitting the database
- Unique constraint violations (OR number, room number, bed code) → check explicitly first, return 400 with clear message

## Debugging Errors

1. Check `server/.env` is loaded (JWT_SECRET, DB_*)
2. Check PostgreSQL is running: `pg_isready`
3. Run `node server/test_routes.js` to verify route mounting
4. Add temporary `console.error(err)` for full stack