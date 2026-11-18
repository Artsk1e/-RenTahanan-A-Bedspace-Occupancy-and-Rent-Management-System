# API Reference — RenTahanan

## Overview
REST API for the RenTahanan Boarding House Management System.

## Base URL
- **Development**: `http://localhost:5000/api`
- **Production**: `https://api.rentahanan.example.com/api`

## Authentication
- **Method**: JWT Bearer Token
- **Header**: `Authorization: Bearer <token>`
- **Token Expiry**: 24 hours
- **Public Endpoints**: `POST /api/auth/register`, `POST /api/auth/login`

## Roles
| Role | Description |
|------|-------------|
| `OWNER` | Full system access |
| `CARETAKER` | Operational access (no user management, no room deletion) |
| `TENANT` | Read-only self-service (own profile, contracts, billing, payments) |

## Error Format
```json
{
  "error": "Human-readable message",
  "details": {}  // Optional validation errors
}
```

## Status Codes
| Code | Meaning |
|------|---------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Validation error / Business rule violation |
| 401 | Missing/invalid/expired token |
| 403 | Insufficient role |
| 404 | Not found |
| 409 | Conflict (duplicate) |
| 500 | Server error |

## Pagination
Query params: `page` (default 1), `limit` (default 20, max 100)

Response:
```json
{
  "data": [...],
  "pagination": { "page": 1, "limit": 20, "total": 150, "totalPages": 8 }
}
```

## Endpoints

### Authentication
| Method | Endpoint | Roles | Description |
|--------|----------|-------|-------------|
| POST | `/api/auth/register` | Public | Register new user |
| POST | `/api/auth/login` | Public | Login, return JWT |
| GET | `/api/auth/profile` | All | Current user profile |

### Users
| Method | Endpoint | Roles | Description |
|--------|----------|-------|-------------|
| GET | `/api/users` | OWNER | List all users |

### Rooms
| Method | Endpoint | Roles | Description |
|--------|----------|-------|-------------|
| GET | `/api/rooms` | All | List rooms |
| POST | `/api/rooms` | OWNER, CARETAKER | Create room |
| GET | `/api/rooms/:id` | All | Get room |
| PUT | `/api/rooms/:id` | OWNER, CARETAKER | Update room |
| DELETE | `/api/rooms/:id` | OWNER | Delete room |

### Beds
| Method | Endpoint | Roles | Description |
|--------|----------|-------|-------------|
| GET | `/api/beds` | All | List beds |
| POST | `/api/beds` | OWNER, CARETAKER | Create bed |
| GET | `/api/beds/:id` | All | Get bed |
| PUT | `/api/beds/:id` | OWNER, CARETAKER | Update bed |
| DELETE | `/api/beds/:id` | OWNER | Delete bed |

### Tenants
| Method | Endpoint | Roles | Description |
|--------|----------|-------|-------------|
| GET | `/api/tenants` | OWNER, CARETAKER | List tenants |
| POST | `/api/tenants` | OWNER, CARETAKER | Create tenant |
| GET | `/api/tenants/:id` | All* | Get tenant |
| PUT | `/api/tenants/:id` | OWNER, CARETAKER | Update tenant |
| DELETE | `/api/tenants/:id` | OWNER | Delete tenant |

*TENANT can only access own profile via `/api/auth/profile`

### Contracts
| Method | Endpoint | Roles | Description |
|--------|----------|-------|-------------|
| GET | `/api/contracts` | OWNER, CARETAKER | List contracts |
| POST | `/api/contracts` | OWNER, CARETAKER | Create contract (transactional) |
| GET | `/api/contracts/:id` | OWNER, CARETAKER | Get contract |
| PUT | `/api/contracts/:id/terminate` | OWNER, CARETAKER | Terminate contract |

### Billing
| Method | Endpoint | Roles | Description |
|--------|----------|-------|-------------|
| GET | `/api/billing` | OWNER, CARETAKER | List billing statements |
| POST | `/api/billing` | OWNER, CARETAKER | Generate billing |

### Payments
| Method | Endpoint | Roles | Description |
|--------|----------|-------|-------------|
| GET | `/api/payments` | OWNER, CARETAKER | List payments |
| POST | `/api/payments` | OWNER, CARETAKER | Log payment |

## Business Rules Enforced
- One bed per tenant
- No double-booking (transactional FOR UPDATE)
- Unique OR numbers
- No partial payments (full amount required)
- Advance rent + deposit tracked separately

## Detailed Documentation
- [Auth Endpoints](endpoints/auth.md)
- [Rooms](endpoints/rooms.md)
- [Beds](endpoints/beds.md)
- [Tenants](endpoints/tenants.md)
- [Contracts](endpoints/contracts.md)
- [Billing](endpoints/billing.md)
- [Payments](endpoints/payments.md)