---
name: api-conventions
description: REST endpoint conventions, request/response structures, validation, error handling, API documentation for RenTahanan
---

# API Conventions for RenTahanan

## Base URL & Versioning

- **Development**: `http://localhost:5000/api`
- **Production**: `https://api.rentahanan.example.com/api`
- **Versioning**: URL path not used (single boarding house, controlled deployment)
- **Future**: `/api/v1/` if needed

## Authentication

- **Method**: JWT Bearer token in `Authorization` header
- **Header**: `Authorization: Bearer <token>`
- **Token Expiry**: 24 hours (configurable via `JWT_EXPIRY`)
- **Refresh**: Not implemented (re-login required)
- **Public Endpoints**: `POST /api/auth/register`, `POST /api/auth/login`

## Request/Response Standards

### Content Type
- **Request**: `application/json`
- **Response**: `application/json`

### Date Format
- **ISO 8601**: `YYYY-MM-DD` for dates, `YYYY-MM-DDTHH:mm:ss.sssZ` for timestamps
- **Database**: `DATE` for dates, `TIMESTAMP` for timestamps

### Numeric Format
- **Money**: Strings to preserve precision (`"5000.00"`) — not JSON numbers
- **IDs**: Integers in JSON (JavaScript safe integers)

### Error Response Format
```json
{
  "error": "Human-readable error message",
  "details": {}  // Optional: validation errors, etc.
}
```

### Success Response Formats

#### Single Resource (200, 201)
```json
{
  "message": "Descriptive success message",
  "data": { ... }  // Resource object
}
```

#### Collection (200)
```json
[
  { ... },  // Array of resource objects
  { ... }
]
```

#### No Content (204)
Empty body

## HTTP Status Codes

| Code | Use Case |
|------|----------|
| 200 | Successful GET, PUT, PATCH |
| 201 | Successful POST (resource created) |
| 204 | Successful DELETE |
| 400 | Validation error, business rule violation |
| 401 | Missing/invalid/expired JWT |
| 403 | Valid JWT but insufficient role |
| 404 | Resource not found |
| 409 | Conflict (e.g., duplicate unique field) |
| 500 | Unexpected server error |

## REST Endpoint Patterns

| Resource | Collection | Single |
|----------|------------|--------|
| Rooms | `GET /api/rooms`<br>`POST /api/rooms` | `GET /api/rooms/:id`<br>`PUT /api/rooms/:id`<br>`DELETE /api/rooms/:id` |
| Beds | `GET /api/beds`<br>`POST /api/beds` | `GET /api/beds/:id`<br>`PUT /api/beds/:id`<br>`DELETE /api/beds/:id` |
| Tenants | `GET /api/tenants`<br>`POST /api/tenants` | `GET /api/tenants/:id`<br>`PUT /api/tenants/:id`<br>`DELETE /api/tenants/:id` |
| Contracts | `GET /api/contracts`<br>`POST /api/contracts` | `GET /api/contracts/:id`<br>`PUT /api/contracts/:id/terminate` |
| Billing | `GET /api/billing`<br>`POST /api/billing` | `GET /api/billing/:id` |
| Payments | `GET /api/payments`<br>`POST /api/payments` | `GET /api/payments/:id` |
| Users | `GET /api/users` | — |
| Auth | `POST /api/auth/register`<br>`POST /api/auth/login`<br>`GET /api/auth/profile` | — |

### Action Endpoints (Non-REST)
- `PUT /api/contracts/:id/terminate` — Terminate contract (business action)
- Future: `POST /api/billing/:id/send-reminder`, `POST /api/payments/:id/void`

## Role-Based Access Control (RBAC)

| Role | Permissions |
|------|-------------|
| `OWNER` | All endpoints |
| `CARETAKER` | All except user management (`/api/users`), room deletion |
| `TENANT` | Read-only: rooms, beds, own tenant profile, own contracts, own billing, own payments |

### RBAC Middleware
```javascript
// middleware/auth.js
const auth = (allowedRoles = []) => (req, res, next) => {
  // Verify JWT, attach req.user = { user_id, username, role }
  // If allowedRoles.length > 0 and !allowedRoles.includes(req.user.role) → 403
};
```

### Route Protection Examples
```javascript
router.get('/rooms', auth(['OWNER', 'CARETAKER', 'TENANT']), getAllRooms);
router.post('/rooms', auth(['OWNER', 'CARETAKER']), createRoom);
router.delete('/rooms/:id', auth(['OWNER']), deleteRoom);
router.post('/contracts', auth(['OWNER', 'CARETAKER']), createContract);
```

## Request Validation (Zod)

### Schema Location
`server/schemas/<resource>.ts` — Shared with frontend

### Example: Contract Creation
```typescript
// server/schemas/contract.ts
import { z } from 'zod';

export const createContractSchema = z.object({
  body: z.object({
    tenant_id: z.number().int().positive(),
    bed_id: z.number().int().positive(),
    start_date: z.string().date(),
    end_date: z.string().date(),
    monthly_rate: z.string().regex(/^\d+(\.\d{1,2})?$/),
    advance_rent_paid: z.string().regex(/^\d+(\.\d{1,2})?$/).optional(),
    deposit_paid: z.string().regex(/^\d+(\.\d{1,2})?$/).optional(),
  }),
});

export type CreateContractInput = z.infer<typeof createContractSchema>['body'];
```

### Validation Middleware
```javascript
// middleware/validate.js
const validate = (schema) => (req, res, next) => {
  const result = schema.safeParse({ body: req.body, query: req.query, params: req.params });
  if (!result.success) {
    return res.status(400).json({
      error: 'Validation failed',
      details: result.error.flatten().fieldErrors,
    });
  }
  req.validated = result.data;
  next();
};
```

## Pagination & Filtering

### Query Parameters
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | integer | 1 | Page number |
| `limit` | integer | 20 | Items per page (max 100) |
| `sort` | string | `created_at` | Sort field |
| `order` | `asc`\|`desc` | `desc` | Sort order |
| `status` | enum | — | Filter by status (where applicable) |
| `search` | string | — | Text search (where applicable) |

### Response with Pagination
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

## Rate Limiting

### Auth Endpoints
- `POST /api/auth/login` — 10 requests/minute per IP
- `POST /api/auth/register` — 5 requests/minute per IP

### General API
- 100 requests/minute per authenticated user

## CORS
- **Development**: `http://localhost:3000` (frontend)
- **Production**: Specific domain only
- **Credentials**: `true` (for cookies if used)

## API Documentation

### Endpoint Documentation Template
Each endpoint in `docs/api/endpoints/<resource>.md`:

```markdown
# POST /api/contracts

Create a new contract and assign a bed to a tenant.

## Authentication
Bearer token required. Roles: `OWNER`, `CARETAKER`

## Request Body
```json
{
  "tenant_id": 1,
  "bed_id": 5,
  "start_date": "2026-01-01",
  "end_date": "2026-12-31",
  "monthly_rate": "5000.00",
  "advance_rent_paid": "10000.00",
  "deposit_paid": "5000.00"
}
```

## Response (201)
```json
{
  "message": "Contract created and bed assigned successfully",
  "data": {
    "contract_id": 10,
    "tenant_id": 1,
    "bed_id": 5,
    "start_date": "2026-01-01",
    "end_date": "2026-12-31",
    "monthly_rate": "5000.00",
    "advance_rent_paid": "10000.00",
    "deposit_paid": "5000.00",
    "status": "ACTIVE",
    "created_at": "2026-01-15T10:30:00Z"
  }
}
```

## Errors
| Code | Condition |
|------|-----------|
| 400 | Validation failed, bed not vacant, tenant has active contract |
| 401 | Missing/invalid token |
| 403 | Role not OWNER/CARETAKER |
| 404 | Tenant or bed not found |
| 500 | Server error |
```