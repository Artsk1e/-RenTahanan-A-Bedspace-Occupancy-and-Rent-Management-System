---
name: api-design
description: REST API design patterns for RenTahanan — resource naming, status codes, RBAC per route, and error responses.
---

## Route Conventions

Resources are plural nouns, actions are HTTP verbs:

| Route | Verb | RBAC | Purpose |
|-------|------|------|---------|
| `/api/rooms` | GET | all roles | List rooms |
| `/api/rooms` | POST | OWNER, CARETAKER | Create room |
| `/api/rooms/:id` | PUT | OWNER, CARETAKER | Update room |
| `/api/rooms/:id` | DELETE | OWNER | Delete room |
| `/api/contracts` | POST | OWNER, CARETAKER | Create contract (transactional) |
| `/api/contracts/:id/terminate` | PUT | OWNER, CARETAKER | Terminate contract |

## Status Code Rules

- **200** — successful GET/PUT
- **201** — successful resource creation
- **400** — validation failure or business rule violation
- **401** — missing/invalid token
- **403** — role not permitted
- **404** — resource not found
- **500** — unexpected server error

## Response Shapes

```javascript
// Success (single resource)
{ "message": "Contract created", "contract": { ... } }

// Success (collection) — return array directly
[ { "room_id": 1, ... }, ... ]

// Error
{ "error": "Bed already occupied" }
```

## Adding a New Endpoint Checklist

1. Create/update controller function in `server/controllers/<name>Controller.js`
2. Register route in `server/routes/<name>.js` with correct RBAC roles
3. Mount router in `server/server.js` if it's a new resource
4. Validate required fields first; return 400 with specific message
5. Wrap DB writes in transactions when multiple tables change
6. Update `docs/API.md` and `docs/automation/PROJECT_JOURNAL.md`

## Business Rule Enforcement Points

- Bed assignment: `contractController.createContract` (BEGIN/COMMIT + FOR UPDATE)
- OR uniqueness: `paymentController.createPayment` (explicit check + DB unique constraint)
- Single active contract per tenant: checked inside the same transaction
- No partial payments: `amount_paid >= amount_due` marks billing PAID, otherwise stays UNPAID