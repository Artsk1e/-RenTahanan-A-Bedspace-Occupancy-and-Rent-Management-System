---
name: codebase-onboarding
description: Analyze an unfamiliar codebase and generate a structured onboarding guide with architecture map, key entry points, conventions, and a starter CLAUDE.md.
---

## RenTahanan Onboarding Checklist

### 1. Architecture Overview
- **Stack**: PERN (PostgreSQL, Express, React, Node.js)
- **Server**: `server/` directory with Express API
- **Database**: PostgreSQL schema in `server/schema/init.sql`
- **Frontend**: Not yet implemented (planned `client/` with React + Vite)

### 2. Key Entry Points
- `server/server.js` - Express app initialization, route mounting
- `server/config/db.js` - PostgreSQL connection pool
- `server/middleware/auth.js` - JWT authentication + RBAC
- `server/routes/*.js` - API route definitions
- `server/controllers/*.js` - Business logic

### 3. Critical Files to Understand
- `server/schema/init.sql` - Complete schema with enums, triggers, indexes
- `server/controllers/contractController.js` - Transactional bed assignment
- `server/controllers/paymentController.js` - OR tracking + billing updates
- `server/controllers/userController.js` - Auth with bcrypt + JWT

### 4. Business Rules
- One bed per tenant (enforced in contract creation)
- No partial payments (full amount required)
- OR numbers must be unique
- Advance payments and security deposits tracked separately
- Bed statuses: VACANT → OCCUPIED → VACANT (on termination)

### 5. Development Commands
```bash
# Start backend
npm run dev --prefix server

# Verify routes load
node server/test_routes.js
```

### 6. Environment Setup
Required `.env` variables:
```
PORT=5000
DB_USER=postgres
DB_PASSWORD=123
DB_HOST=localhost
DB_PORT=5432
DB_NAME=rentahanan_db
JWT_SECRET=your-secret-key
FRONTEND_URL=http://localhost:3000
```