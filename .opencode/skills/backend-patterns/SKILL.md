---
name: backend-patterns
description: Express.js API patterns, controller structure, middleware organization, and error handling for the RenTahanan PERN stack.
---

## Project Structure

```
server/
├── config/
│   └── db.js                 # PostgreSQL connection pool
├── controllers/
│   ├── authController.js     # Auth: register, login, profile
│   ├── roomController.js     # Room CRUD
│   ├── bedController.js      # Bed CRUD
│   ├── tenantController.js   # Tenant profile CRUD
│   ├── contractController.js # Contract + transactional bed assignment
│   ├── billingController.js  # Billing statement generation
│   └── paymentController.js  # Payment + OR tracking
├── middleware/
│   └── auth.js               # JWT verification + RBAC
├── routes/
│   ├── auth.js               # /api/auth/*
│   ├── users.js              # /api/users/*
│   ├── rooms.js              # /api/rooms/*
│   ├── beds.js               # /api/beds/*
│   ├── tenants.js            # /api/tenants/*
│   ├── contracts.js          # /api/contracts/*
│   ├── billing.js            # /api/billing/*
│   └── payments.js           # /api/payments/*
├── schema/
│   └── init.sql              # Full schema with enums, triggers, seed data
├── server.js                 # Express app entry point
└── test_routes.js            # Route verification script
```

## Controller Pattern

Each controller exports async functions:
```javascript
exports.functionName = async (req, res) => {
  try {
    // validation
    // business logic
    // response
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};
```

## Transaction Pattern (Critical)

Used in `contractController.js` for bed assignment:

```javascript
const client = await pool.connect();
try {
  await client.query('BEGIN');
  
  // Lock row to prevent double-booking
  const bedCheck = await client.query(
    'SELECT status FROM beds WHERE bed_id = $1 FOR UPDATE', 
    [bed_id]
  );
  
  // Validate business rules
  if (bedCheck.rows[0].status === 'OCCUPIED') {
    throw new Error('Bed already occupied');
  }
  
  // ... perform writes
  
  await client.query('COMMIT');
  res.json(result);
} catch (err) {
  await client.query('ROLLBACK');
  res.status(400).json({ error: err.message });
} finally {
  client.release();
}
```

## RBAC Middleware Usage

```javascript
const auth = require('../middleware/auth');

// All authenticated users
router.get('/', auth(['OWNER', 'CARETAKER', 'TENANT']), controller.getAll);

// Staff only
router.post('/', auth(['OWNER', 'CARETAKER']), controller.create);

// Owner only
router.delete('/:id', auth(['OWNER']), controller.delete);
```

## Error Response Format

```javascript
// Success
res.status(201).json({ message: 'Created', data: result });

// Client error (4xx)
res.status(400).json({ error: 'Validation failed: ...' });

// Server error (5xx)
res.status(500).json({ error: 'Internal server error' });
```