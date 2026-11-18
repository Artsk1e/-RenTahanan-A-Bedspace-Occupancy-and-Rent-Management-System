---
name: tdd-workflow
description: Test-driven development for RenTahanan — write a failing test first, watch it fail, implement the smallest change to green, then refactor.
---

## Red → Green → Refactor

1. **Red**: Write a failing test that describes the desired behavior
2. **Green**: Write the smallest implementation change that makes it pass
3. **Refactor**: Clean up while keeping tests green

## Testing Stack (Planned)

- `jest` — test runner and assertions
- `supertest` — HTTP assertions against the Express app
- Test DB strategy: dedicated `rentahanan_test` database, `init.sql` re-run in setup, transaction rollback per test

## Test File Layout (Planned)

```
server/tests/
├── setup/db.js              # Test DB bootstrap + teardown
├── auth.test.js             # register/login/profile
├── middleware/auth.test.js  # JWT + RBAC (401/403/200)
├── rooms.test.js            # Room CRUD + permissions
├── beds.test.js             # Bed CRUD + status transitions
├── tenants.test.js          # Tenant CRUD + permissions
├── contracts.test.js        # Transactional assignment, double-booking guard
├── billing.test.js          # Statement generation
├── payments.test.js         # OR uniqueness, full-payment rule
└── integration/workflow.test.js  # End-to-end happy path
```

## Critical Test Cases (Business Rules)

| Rule | Test |
|------|------|
| One bed per tenant | Second active contract for tenant → 400 |
| No double-booking | Contract on OCCUPIED bed → 400; concurrent requests → only one succeeds |
| OR uniqueness | Duplicate OR number → 400 |
| No partial payments | `amount_paid < amount_due` → billing stays UNPAID |
| Full payment | `amount_paid >= amount_due` → billing becomes PAID |
| Rollback integrity | Error mid-transaction → bed stays VACANT, no orphan rows |

## App Export Requirement

`supertest` needs the app without `listen`. `server/server.js` already ends with `module.exports = app;` — require it in tests:

```javascript
const request = require('supertest');
const app = require('../server');
```

## Conventions

- One `describe` block per endpoint, one `it` per behavior
- Name tests as behavior: "returns 400 when bed is already occupied"
- Never mock `pg` for transaction tests — real DB required to verify locking
- Tests must clean up all created rows (setup/teardown handles this)