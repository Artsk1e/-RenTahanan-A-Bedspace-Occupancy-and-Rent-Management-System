---
name: auth-and-authorization
description: Authentication requirements, role-based permissions, access control, sensitive data protection for RenTahanan
---

# Authentication & Authorization for RenTahanan

## Authentication

### JWT Implementation
- **Library**: `jsonwebtoken` (HS256)
- **Secret**: `JWT_SECRET` from environment (min 32 chars in production)
- **Expiry**: 24 hours (`JWT_EXPIRY=24h`)
- **Payload**:
  ```json
  {
    "user_id": 1,
    "username": "caretaker_mary",
    "role": "CARETAKER",
    "iat": 1700000000,
    "exp": 1700086400
  }
  ```

### Password Hashing
- **Algorithm**: `bcryptjs`
- **Salt Rounds**: 10
- **Storage**: `users.password_hash` (never plain text)

### Login Flow
```
POST /api/auth/login
  → Validate credentials
  → bcrypt.compare(password, hash)
  → Generate JWT
  → Return { token, user: { user_id, username, role } }
```

### Registration Flow
```
POST /api/auth/register
  → Check username uniqueness
  → bcrypt.hash(password, 10)
  → Insert user (default role: TENANT)
  → Return { user: { user_id, username, role } }
  → Note: Does NOT auto-login (separate login required)
```

### Token Validation (Middleware)
```javascript
// middleware/auth.js
const auth = (allowedRoles = []) => (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  // Check header format
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Access denied. No token provided.' });
  }
  
  const token = authHeader.split(' ')[1];
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // { user_id, username, role }
    
    // Role check
    if (allowedRoles.length && !allowedRoles.includes(decoded.role)) {
      return res.status(403).json({ error: 'Access denied. Insufficient permissions.' });
    }
    
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired. Please login again.' });
    }
    return res.status(400).json({ error: 'Invalid token.' });
  }
};
```

## Role-Based Access Control (RBAC)

### Roles Hierarchy
```
OWNER (highest)
  ↓
CARETAKER
  ↓
TENANT (lowest)
```

### Role Permissions Matrix

| Endpoint | OWNER | CARETAKER | TENANT |
|----------|-------|-----------|--------|
| `POST /api/auth/register` | ✅ | ✅ | ✅ (public) |
| `POST /api/auth/login` | ✅ | ✅ | ✅ (public) |
| `GET /api/auth/profile` | ✅ | ✅ | ✅ |
| `GET /api/users` | ✅ | ❌ | ❌ |
| `GET /api/rooms` | ✅ | ✅ | ✅ |
| `POST /api/rooms` | ✅ | ✅ | ❌ |
| `PUT /api/rooms/:id` | ✅ | ✅ | ❌ |
| `DELETE /api/rooms/:id` | ✅ | ❌ | ❌ |
| `GET /api/beds` | ✅ | ✅ | ✅ |
| `POST /api/beds` | ✅ | ✅ | ❌ |
| `PUT /api/beds/:id` | ✅ | ✅ | ❌ |
| `DELETE /api/beds/:id` | ✅ | ❌ | ❌ |
| `GET /api/tenants` | ✅ | ✅ | ❌ (own only via profile) |
| `POST /api/tenants` | ✅ | ✅ | ❌ |
| `PUT /api/tenants/:id` | ✅ | ✅ | ❌ (own only) |
| `DELETE /api/tenants/:id` | ✅ | ❌ | ❌ |
| `GET /api/contracts` | ✅ | ✅ | ❌ (own only) |
| `POST /api/contracts` | ✅ | ✅ | ❌ |
| `PUT /api/contracts/:id/terminate` | ✅ | ✅ | ❌ |
| `GET /api/billing` | ✅ | ✅ | ❌ (own only) |
| `POST /api/billing` | ✅ | ✅ | ❌ |
| `GET /api/payments` | ✅ | ✅ | ❌ (own only) |
| `POST /api/payments` | ✅ | ✅ | ❌ |

### Tenant Self-Service (Future)
- `GET /api/tenants/me` — Own profile
- `GET /api/contracts/me` — Own active contract
- `GET /api/billing/me` — Own billing statements
- `GET /api/payments/me` — Own payment history
- `PUT /api/tenants/me` — Update own contact info

## Sensitive Data Protection

### Data Classification

| Data | Classification | Handling |
|------|----------------|----------|
| `users.password_hash` | **SECRET** | Never in logs, never in API responses |
| `users.username` | Internal | OK in logs/API (non-sensitive) |
| `payments.or_number` | **SECRET** | Mask in logs (last 4 only), full in authorized API |
| `payments.amount_paid` | Financial | OK in authorized API, aggregate in logs |
| `contracts.monthly_rate` | Financial | OK in authorized API |
| `contracts.advance_rent_paid` | Financial | OK in authorized API |
| `contracts.deposit_paid` | Financial | OK in authorized API |
| `tenants.contact_number` | PII | Authorized API only, not in logs |
| `tenants.emergency_contact` | PII | Authorized API only, not in logs |

### Logging Rules
```javascript
// NEVER log these:
console.log(password);           // ❌
console.log(token);              // ❌
console.log(or_number);          // ❌ (full)
console.log(req.body);           // ❌ (may contain secrets)

// OK to log (sanitized):
console.log({ userId: req.user.user_id, role: req.user.role });
console.log({ orNumber: `***${orNumber.slice(-4)}` });
console.log({ action: 'contract_created', contractId: 123 });
```

### API Response Sanitization
- **Never return** `password_hash` in any response
- **Never return** full `or_number` in list endpoints (mask: `***1234`)
- **Return full** `or_number` only in `GET /api/payments/:id` for authorized roles

## Security Headers (Helmet or Manual)

```javascript
// In server.js
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  // CSP if needed
  next();
});
```

## CORS Configuration

```javascript
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,  // If using cookies
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

## Rate Limiting (Recommended)

```javascript
// npm install express-rate-limit
const rateLimit = require('express-rate-limit');

const authLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10,             // 10 requests per window
  message: { error: 'Too many requests, please try again later' }
});

const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100,
  message: { error: 'Rate limit exceeded' }
});

app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
app.use('/api/', apiLimiter);  // Apply to all API routes
```

## Session Security (If Cookies Used)

```javascript
// If using cookies instead of Authorization header
app.use(cookieParser());

// Set cookie options
res.cookie('token', jwtToken, {
  httpOnly: true,        // Prevent XSS
  secure: true,          // HTTPS only (production)
  sameSite: 'strict',    // CSRF protection
  maxAge: 24 * 60 * 60 * 1000 // 24 hours
});
```

## Audit Trail

### Automatic Logging
- All payment logging includes `logged_by_user_id` (FK to users)
- Contract creation includes `created_by_user_id`
- `updated_at` triggers on all tables capture last modifier

### Manual Audit (Future Enhancement)
- Consider `audit_log` table for sensitive operations:
  - Login/logout events
  - Contract create/terminate
  - Payment void/refund
  - User role changes
  - Schema migrations

## Open Questions (⚠️ UNVERIFIED)

- [ ] Token refresh mechanism needed?
- [ ] Password reset flow?
- [ ] Multi-factor authentication?
- [ ] Session invalidation on password change?
- [ ] Concurrent session limit?
- [ ] IP allowlisting for admin endpoints?
- [ ] Audit log retention policy?