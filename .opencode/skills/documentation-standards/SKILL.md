---
name: documentation-standards
description: Documentation structure, required updates, architecture decisions, API and database documentation for RenTahanan
---

# Documentation Standards for RenTahanan

## Documentation Philosophy

1. **Documentation as Code** — Docs live in `docs/`, versioned with code
2. **Single Source of Truth** — Implementation is truth; docs reflect reality
3. **No Invented Features** — Never document functionality that doesn't exist
3. **Distinguish Implemented vs Planned** — Use clear markers
4. **Decision Recording** — Important technical decisions → ADRs
5. **Synchronization** — Docs updated in same PR as code changes

## Documentation Structure

```
docs/
├── architecture/
│   ├── overview.md              # System overview, data flow, tech stack
│   ├── decisions/               # ADRs (001-title.md, 002-title.md)
│   └── ai-development-team.md   # This AI team architecture
├── database/
│   ├── schema.md                # Current schema: tables, enums, constraints, indexes
│   ├── migrations.md            # Migration history, procedures, rollback guide
│   └── erd.md                   # ERD reference (link to PNG)
├── api/
│   ├── index.md                 # API overview, auth, base URL, errors, pagination
│   ├── endpoints/               # Per-endpoint documentation
│   │   ├── auth.md
│   │   ├── rooms.md
│   │   ├── beds.md
│   │   ├── tenants.md
│   │   ├── contracts.md
│   │   ├── billing.md
│   │   └── payments.md
│   └── types.md                 # Shared types (Zod/TypeScript), request/response schemas
├── development/
│   ├── setup.md                 # Prerequisites, installation, .env, running locally
│   ├── backend-guide.md         # Server structure, conventions, adding endpoints
│   ├── frontend-guide.md        # Client structure, components, state, API client
│   ├── testing-guide.md         # Test structure, running tests, writing tests
│   ├── deployment.md            # Build, deploy, environment variables, CI/CD
│   └── conventions.md           # Code style, git workflow, PR process
├── testing/
│   ├── strategy.md              # Test pyramid, coverage targets, tools
│   ├── backend-tests.md         # Unit, integration test patterns
│   ├── frontend-tests.md        # Component, E2E test patterns
│   └── regression.md            # Bug regression test process
├── requirements/
│   ├── business-rules.md        # Verified business rules (no invented rules)
│   ├── user-stories.md          # User stories with acceptance criteria
│   └── open-questions.md        # Unresolved decisions
└── automation/
    └── PROJECT_JOURNAL.md       # Milestone log (auto-updated by agents)
```

## Root Files

| File | Purpose |
|------|---------|
| `README.md` | Project overview, quick start, tech stack, key commands |
| `CHANGELOG.md` | Keep a Changelog format (Unreleased, versions, dates) |
| `AGENTS.md` | AI agent team reference (this project's agent definitions) |

## Update Triggers & Responsibilities

| Change | Docs to Update | Responsible Agent |
|--------|----------------|-------------------|
| New API endpoint | `docs/api/endpoints/*.md`, `docs/api/types.md` | `backend-developer` + `documenter` |
| Schema change (migration) | `docs/database/schema.md`, `docs/database/migrations.md` | `database-engineer` + `documenter` |
| New ADR | `docs/architecture/decisions/NNN-title.md`, `docs/architecture/overview.md` | `architect` + `documenter` |
| New feature | `README.md`, `CHANGELOG.md`, relevant guide | `build` + `documenter` |
| Bug fix (business logic) | `docs/requirements/business-rules.md`, `CHANGELOG.md` | `debugger` + `documenter` |
| Convention change | `docs/development/conventions.md` | `architect` + `documenter` |
| Test infrastructure | `docs/testing/*.md` | `qa-engineer` + `documenter` |
| Frontend changes | `docs/development/frontend-guide.md` | `frontend-developer` + `documenter` |

## Documentation Markers

### Status Markers (Required)
- ✅ **IMPLEMENTED** — Feature exists in code
- 🚧 **IN PROGRESS** — Actively being worked on
- 📋 **PLANNED** — Approved, not started
- ❌ **NOT IMPLEMENTED** — Explicitly not done
- ⚠️ **UNVERIFIED** — Business rule not confirmed with stakeholder
- 🔄 **DEPRECATED** — Will be removed

### Usage Examples
```markdown
## Contract Creation

✅ **IMPLEMENTED** — `POST /api/contracts` creates contract with transactional bed assignment.

---

## Late Fees

⚠️ **UNVERIFIED** — No automated late fees implemented. Business decision needed on:
- Grace period
- Fixed vs percentage fee
- Maximum cap
```

## ADR Format (Required)

```markdown
# ADR-NNN: Short Title

## Status
Proposed | Accepted | Superseded | Deprecated

## Context
What problem are we solving? What forces are at play?

## Decision
What did we decide? Be specific.

## Alternatives Considered
1. **Alternative A** — Why rejected
2. **Alternative B** — Why rejected
3. **Current approach** — Why chosen

## Consequences
### Positive
- Benefit 1
- Benefit 2

### Negative
- Drawback 1
- Migration needed: ...

### Risks
- Risk 1
- Mitigation: ...

## References
- Related code: `server/schema/init.sql`
- Related docs: `docs/database/schema.md`
- Discussion: PR #XX
```

## API Endpoint Documentation Template

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

## Business Rules Enforced
- One bed per tenant
- No double-booking (FOR UPDATE lock)
- Bed status: VACANT → OCCUPIED (transactional)
```

## Database Schema Documentation Template

```markdown
# Table: contracts

## Purpose
Lease agreements assigning tenants to beds for a rental period.

## Columns
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| contract_id | SERIAL | PRIMARY KEY | Unique identifier |
| tenant_id | INT | FK → tenants, RESTRICT | Tenant reference |
| bed_id | INT | FK → beds, RESTRICT | Bed reference |
| created_by_user_id | INT | FK → users, SET NULL | Staff who created |
| start_date | DATE | NOT NULL | Lease start |
| end_date | DATE | NOT NULL | Lease end |
| monthly_rate | NUMERIC(10,2) | NOT NULL, ≥ 0 | Flat monthly rent |
| advance_rent_paid | NUMERIC(10,2) | DEFAULT 0.00 | Advance payment |
| deposit_paid | NUMERIC(10,2) | DEFAULT 0.00 | Security deposit |
| status | contract_status | DEFAULT 'ACTIVE' | ACTIVE/COMPLETED/TERMINATED |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update (trigger) |

## Indexes
- `idx_contracts_tenant` on `tenant_id`

## Constraints
- `tenant_id` FK → `tenants.tenant_id` ON DELETE RESTRICT
- `bed_id` FK → `beds.bed_id` ON DELETE RESTRICT
- `created_by_user_id` FK → `users.user_id` ON DELETE SET NULL
- `monthly_rate ≥ 0`, `advance_rent_paid ≥ 0`, `deposit_paid ≥ 0`

## Triggers
- `update_contracts_updated_at` — Updates `updated_at` on modification

## Business Rules
- One active contract per tenant (API enforced)
- One active contract per bed (API + DB enforced)
- Bed status sync: ACTIVE contract → bed OCCUPIED
```

## Changelog Format (Keep a Changelog)

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Feature X

### Changed
- Behavior Y

### Fixed
- Bug Z

### Removed
- Deprecated feature W

## [1.0.0] - 2026-XX-XX

### Added
- Initial backend API with auth, rooms, beds, tenants, contracts, billing, payments
- PostgreSQL schema with enums, triggers, indexes
- JWT authentication with RBAC
```

## README.md Template

```markdown
# RenTahanan — Boarding House Management System

## Overview
RenTahanan manages boarding house operations for Evelyn Lady's Dormitory:
tenant management, room/bed assignments, rental contracts, billing, and payments.

## Tech Stack
- **Backend**: Node.js + Express + TypeScript (in progress)
- **Database**: PostgreSQL
- **Frontend**: React + TypeScript + Vite (planned)
- **Auth**: JWT + bcrypt, RBAC (OWNER, CARETAKER, TENANT)

## Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- FreeLLMAPI running on localhost:3001 (for AI development)

### Backend Setup
```bash
cd server
cp .env.example .env  # Configure DB credentials
npm install
# Run migrations or init.sql
npm run dev
```

### Commands
| Command | Description |
|---------|-------------|
| `npm run dev --prefix server` | Start backend dev server |
| `node server/test_routes.js` | Verify routes load correctly |
| `npm test --prefix server` | Run backend tests |

## Project Structure
```
server/
├── config/         # DB connection
├── controllers/    # Request handlers
├── middleware/     # Auth, validation, errors
├── routes/         # API route definitions
├── schemas/        # Zod validation (shared)
├── migrations/     # SQL migrations
├── tests/          # Jest + Supertest
└── server.ts       # App entry point
```

## Documentation
- [API Reference](docs/api/index.md)
- [Database Schema](docs/database/schema.md)
- [Architecture](docs/architecture/overview.md)
- [Development Guide](docs/development/backend-guide.md)

## AI Development Team
See [AGENTS.md](AGENTS.md) for agent definitions and [docs/architecture/ai-development-team.md](docs/architecture/ai-development-team.md) for architecture.
```

## Quality Checks

### Before Merging Docs
- [ ] All status markers (✅/🚧/📋/❌/⚠️/🔄) accurate
- [ ] No invented features documented
- [ ] API examples match actual implementation
- [ ] Database schema matches `init.sql` + migrations
- [ ] Cross-references valid (links work)
- [ ] ADR format followed for new decisions

### Validation Commands
```bash
# Check markdown links
npx markdown-link-check docs/**/*.md

# Check for TODO/FIXME in docs
grep -r "TODO\|FIXME" docs/ --include="*.md"

# Verify status markers present
grep -r "IMPLEMENTED\|IN PROGRESS\|PLANNED\|NOT IMPLEMENTED\|UNVERIFIED\|DEPRECATED" docs/ --include="*.md"
```