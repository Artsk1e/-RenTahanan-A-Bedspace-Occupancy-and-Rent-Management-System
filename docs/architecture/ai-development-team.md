# AI Development Team Architecture — RenTahanan

**Version**: 1.0  
**Date**: 2026-11-18  
**Project**: RenTahanan Boarding House Management System

---

## Overview

This document describes the AI engineering team architecture for the RenTahanan project. The team consists of specialized OpenCode agents coordinated by a Lead Orchestrator (`build`), each with defined roles, permissions, models, and skills.

---

## Team Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    build (Lead Orchestrator)                 │
│  Model: freellmapi/gemini-3.8-flash | Mode: primary         │
│  Permissions: Full project access, subagent delegation       │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  architect    │    │  planner      │    │  documenter   │
│  (design)     │    │  (planning)   │    │  (docs)       │
│  glm-4.7-flash│    │  gemma-4-31b-it│   │  gemini-2.5-flash│
│  RO: docs/**  │    │  RO: all      │    │  RW: docs/**  │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ backend-dev   │    │ database-eng  │    │  qa-engineer  │
│ gemini-3.8-flash│   │ gemini-3.8-flash│  │ gemini-2.5-flash│
│ RW: server/** │    │ RW: schema/   │    │ RW: tests/**  │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ frontend-dev  │    │   debugger    │    │ code-reviewer │
│ gemini-2.5-flash│   │ gemini-3.8-flash│  │  glm-4.7-flash│
│ RW: client/** │    │ RW: all*      │    │  RO: all      │
└───────────────┘    └───────────────┘    └───────────────┘

* debugger writes only when assigned fixes by build
```

---

## Agent Definitions

### 1. build — Lead Orchestrator
**Model**: `freellmapi/gemini-3.8-flash`  
**Mode**: `primary`  
**Role**: End-to-end delivery coordination

**Responsibilities**:
- Requirements analysis and scope clarification
- Task decomposition and delegation to specialists
- Integration of specialist outputs
- Verification loop execution (typecheck, lint, tests, build)
- Progress reporting to `docs/automation/PROJECT_JOURNAL.md`

**Delegation Rules**:
| Task Type | Delegate To |
|-----------|-------------|
| System design, ADRs, module boundaries | `architect` |
| React components, UI, client state | `frontend-developer` |
| Express routes, business logic, API | `backend-developer` |
| Schema, migrations, queries, transactions | `database-engineer` |
| Bug reproduction, root cause, fixes | `debugger` |
| Test creation, execution, coverage | `qa-engineer` |
| Independent code/security review | `code-reviewer` |
| Documentation updates, ADRs, guides | `documenter` |

**Permissions**: Full project read/write, `npm`, `node`, `git`, subagent delegation

---

### 2. architect — System Architect
**Model**: `freellmapi/glm-4.7-flash` (strong reasoning, 131K context)  
**Mode**: `subagent`  
**Role**: Technical design, ADRs, implementation planning

**Responsibilities**:
- Architecture design and module boundaries
- API contracts, database schema design
- Architecture Decision Records (ADRs)
- Implementation plans with task breakdown

**Boundaries**: READ-ONLY for code (`server/**`, `client/**`); WRITE for `docs/architecture/**`, `docs/adr/**`, `docs/api/**`, `docs/database/**`

**Skills**: `@api-design`, `@postgresql-conventions`, `@auth-and-authorization`, `@architecture-decision-records`, `@codebase-onboarding`

---

### 3. frontend-developer — Frontend Specialist
**Model**: `freellmapi/gemini-2.5-flash` (fast coding, tool calling)  
**Mode**: `subagent`  
**Role**: React + TypeScript SPA implementation

**Responsibilities**:
- Component architecture and UI implementation from mockups
- API integration with typed client
- Client state management (auth, forms, UI)
- Accessibility (WCAG 2.1 AA) and responsive design
- Forms with React Hook Form + Zod validation
- **Visual Quality** — Apply `design-taste-frontend` skill for all UI work (see skill workflow)

**Boundaries**: WRITE `client/**`, `docs/development/**`; READ backend contracts, NO backend/db changes

**Skills**: `@design-taste-frontend`, `@frontend-patterns`, `@react-patterns`, `@frontend-a11y`, `@make-interfaces-feel-better`, `@api-design`, `@api-conventions`

**Mockups to Implement** (from `docs/*.png`):
- Login, Role Selection, Owner/Caretaker/Tenant Dashboards
- Tenant Registration, Caretaker OR Entry, Billing History, Digital Receipt
- Bedspace Dashboard, Assign Tenant to Vacant Bed, Forgot Password

**design-taste-frontend Skill Integration:**
- **RenTahanan is "software" kind** (SaaS/management system) — per skill section 1 table
- **Page kinds**: All pages are `software` kind (auth pages, admin panels, user portal, data entry forms)
- **Skill Workflow**: Run gate start → deal hero → deal palette → deal CSS → deal moments → build page → run gate
- **Browser Gates Required**: 1440, 1024, 768, 390
- **Key Rules**: One section per screen, equal edges, hover micro-animations, real icons/photographs, hero entrance, dealt moments, no violet/lavender, real icons not drawn
- **Skill Location**: `/home/art/.agents/skills/design-taste-frontend/`
- **Gate Commands**: `gate.mjs --start` → `deal.mjs` → `start.mjs deal/css/brand` → `moments.mjs` → build → `gate.mjs` (must PASS)

---

### 4. backend-developer — Backend Specialist
**Model**: `freellmapi/gemini-3.8-flash` (strong coding, tool calling)  
**Mode**: `subagent`  
**Role**: Express + TypeScript REST API

**Responsibilities**:
- API controllers, routes, middleware
- Business logic: contracts, bed assignment, billing, payments
- Request validation (Zod schemas shared with frontend)
- Auth integration (JWT middleware, RBAC)
- Error handling per `api-conventions`

**Boundaries**: WRITE `server/**`, `docs/api/**`, `docs/development/**`; READ schema, architecture; NO direct schema changes

**Skills**: `@backend-patterns`, `@api-design`, `@error-handling`, `@auth-and-authorization`, `@tdd-workflow`, `@api-conventions`

**Current Endpoints** (25+):
- Auth: register, login, profile
- Users: list (OWNER)
- Rooms/Beds/Tenants: CRUD with RBAC
- Contracts: create (transactional), terminate
- Billing: list, generate
- Payments: list, log (OR tracking)

---

### 5. database-engineer — Database Engineer
**Model**: `freellmapi/gemini-3.8-flash` (SQL expertise)  
**Mode**: `subagent`  
**Role**: PostgreSQL schema, migrations, transaction safety

**Responsibilities**:
- Schema design: tables, enums, constraints, indexes
- Versioned migrations in `server/migrations/`
- Query optimization and index strategy
- Data integrity: FK, CHECK, UNIQUE, triggers
- Transaction safety guidance for backend

**Boundaries**: WRITE `server/schema/**`, `server/migrations/**`, `docs/database/**`; NO application code

**Skills**: `@postgresql-conventions`, `@database-migrations`, `@postgres-patterns`

**Current Schema** (from `server/schema/init.sql`):
- 6 ENUMs: `user_role`, `room_type`, `bed_status`, `tenant_status`, `contract_status`, `billing_status`
- 7 tables: `users`, `rooms`, `beds`, `tenants`, `contracts`, `billing_statements`, `payments`
- Triggers: `updated_at` on all tables
- Indexes: status, OR number, tenant lookups

---

### 6. debugger — Debugger
**Model**: `freellmapi/gemini-3.8-flash` (strong reasoning)  
**Mode**: `subagent`  
**Role**: Systematic root-cause analysis

**Responsibilities**:
- Bug reproduction and isolation
- Cross-layer tracing (frontend → API → DB)
- Fix implementation (when assigned by `build`)
- Regression test addition

**Boundaries**: READ all; WRITE only when assigned; NO new features

**Skills**: `@systematic-debugging`, `@error-handling`, `@backend-patterns`, `@postgres-patterns`

**Key Debug Areas**:
- DB: pool exhaustion, deadlocks, constraint violations
- Auth: JWT validation, RBAC, token expiry
- Transactions: nested tx, `FOR UPDATE`, client leaks
- Financial: double-booking, OR collisions, partial payments

---

### 7. qa-engineer — QA Engineer
**Model**: `freellmapi/gemini-2.5-flash` (fast test execution)  
**Mode**: `subagent`  
**Role**: Test infrastructure and execution

**Responsibilities**:
- Test infrastructure: Jest+Supertest (backend), Vitest+RTL (frontend), Playwright (E2E)
- Unit, integration, E2E tests
- Coverage gates: ≥80% backend, ≥70% frontend
- Regression tests per fixed bug

**Boundaries**: WRITE `server/tests/**`, `client/tests/**`, test configs; NO production code

**Skills**: `@tdd-workflow`, `@test-driven-development`, `@e2e-testing`, `@ai-regression-testing`

**Critical Test Cases**:
- One bed per tenant
- No double-booking (concurrent requests)
- Unique OR numbers
- No partial payments
- Transaction rollback integrity
- RBAC enforcement (401/403/200)

---

### 8. code-reviewer — Code Reviewer
**Model**: `freellmapi/glm-4.7-flash` (strong analysis, 131K context)  
**Mode**: `subagent`  
**Role**: Independent read-only review

**Responsibilities**:
- Security review (OWASP Top 10)
- Code quality (complexity, naming, patterns)
- Architectural compliance
- Correctness (business rules, edge cases)
- Performance (N+1, indexes, bundle size)

**Boundaries**: READ-ONLY; WRITE `docs/reviews/` only

**Skills**: `@security-review`, `@code-reviewer`, `@api-design`, `@postgresql-conventions`, `@auth-and-authorization`

**Blocking Criteria** (FAIL = no merge):
- CRITICAL: Secrets, SQLi, XSS, auth bypass, financial correctness
- HIGH: Architecture violation, missing auth, missing tests

---

### 9. documenter — Documenter
**Model**: `freellmapi/gemini-2.5-flash` (fast writing)  
**Mode**: `subagent`  
**Role**: Documentation synchronization

**Responsibilities**:
- `README.md`, `CHANGELOG.md`
- `docs/architecture/**`, `docs/adr/**`
- `docs/database/**`, `docs/api/**`
- `docs/development/**`, `docs/testing/**`, `docs/requirements/**`

**Boundaries**: WRITE `docs/**`, `README.md`, `CHANGELOG.md`; READ all code

**Skills**: `@documentation-standards`, `@documentation-lookup`, `@architecture-decision-records`, `@codebase-onboarding`

---

### 10. planner — Project Planner
**Model**: `freellmapi/gemma-4-31b-it` (planning optimized)  
**Mode**: `subagent`  
**Role**: Scope, plans, milestones

**Responsibilities**:
- Implementation plans with task breakdown
- Sprint milestones and Definition of Ready/Done
- Risk register and dependency tracking

**Boundaries**: READ-ONLY; NO code changes

**Skills**: `@codebase-onboarding`, `@product-capability`, `@writing-plans`, `@blueprint`

---

### Legacy Agents (Deprecated — Use New Specialists)

| Legacy Agent | Replaced By |
|--------------|-------------|
| `database-backend` | `database-engineer` + `backend-developer` |
| `qa-test` | `qa-engineer` |
| `debug` | `debugger` |
| `document` | `documenter` |

---

## Skills Inventory

### Project-Local Skills (`.opencode/skills/`)
| Skill | Used By |
|-------|---------|
| `boarding-house-domain` | All agents (domain context) |
| `rental-payment-rules` | `backend-developer`, `database-engineer`, `qa-engineer` |
| `postgresql-conventions` | `database-engineer`, `backend-developer`, `architect` |
| `api-conventions` | `backend-developer`, `frontend-developer`, `architect` |
| `auth-and-authorization` | `backend-developer`, `frontend-developer`, `architect`, `code-reviewer` |
| `documentation-standards` | `documenter`, `architect`, `build` |
| `design-taste-frontend` | `frontend-developer`, `build` (visual quality, professional UI standards) |

### ECC Global Skills (Reused)
| Skill | Used By |
|-------|---------|
| `backend-patterns` | `backend-developer`, `architect`, `debugger` |
| `api-design` | `backend-developer`, `frontend-developer`, `architect` |
| `postgres-patterns` | `database-engineer`, `backend-developer`, `debugger` |
| `database-migrations` | `database-engineer` |
| `error-handling` | `backend-developer`, `debugger`, `code-reviewer` |
| `tdd-workflow` | `backend-developer`, `qa-engineer`, `frontend-developer` |
| `frontend-patterns` | `frontend-developer` |
| `react-patterns` | `frontend-developer` |
| `frontend-a11y` | `frontend-developer` |
| `make-interfaces-feel-better` | `frontend-developer` |
| `systematic-debugging` | `debugger`, `qa-engineer` |
| `verification-loop` | `build`, `qa-engineer` |
| `security-review` | `code-reviewer`, `backend-developer` |
| `architecture-decision-records` | `architect`, `documenter` |
| `codebase-onboarding` | All agents |
| `documentation-lookup` | `documenter`, `architect` |
| `coding-standards` | `code-reviewer`, `backend-developer`, `frontend-developer` |

---

## Model Allocation Rationale

| Agent | Model | Reason |
|-------|-------|--------|
| `build` | `gemini-3.8-flash` | Reliable orchestration, strong tool calling, 1M context |
| `architect` | `glm-4.7-flash` | Strong reasoning for architecture, 131K context |
| `frontend-developer` | `gemini-2.5-flash` | Fast coding iterations, good tool calling |
| `backend-developer` | `gemini-3.8-flash` | Complex business logic, transactional code |
| `database-engineer` | `gemini-3.8-flash` | SQL expertise, schema reasoning |
| `debugger` | `gemini-3.8-flash` | Deep reasoning for root cause analysis |
| `qa-engineer` | `gemini-2.5-flash` | High-volume test generation/execution |
| `code-reviewer` | `glm-4.7-flash` | Independent analysis, large context for reviews |
| `documenter` | `gemini-2.5-flash` | Fast documentation writing |
| `planner` | `gemma-4-31b-it` | Planning-optimized model |

**Default**: `freellmapi/auto` (Balanced routing via FreeLLMAPI)  
**Consensus**: `freellmapi/fusion` (Panel + judge for ambiguous decisions)

---

## Permission Model (Least Privilege)

| Agent | Read | Write | Shell | Subagent |
|-------|------|-------|-------|----------|
| `build` | * | * | npm, node, git | All |
| `architect` | * | docs/architecture/**, docs/adr/**, docs/api/**, docs/database/** | — | — |
| `frontend-developer` | * | client/**, docs/development/** | npm, npx | — |
| `backend-developer` | * | server/**, docs/api/**, docs/development/** | npm, node, npx | — |
| `database-engineer` | * | server/schema/**, server/migrations/**, docs/database/** | psql, npm | — |
| `debugger` | * | * (when assigned) | * | — |
| `qa-engineer` | * | server/tests/**, client/tests/**, configs | npm test*, npx jest*, npx playwright* | debug |
| `code-reviewer` | * | docs/reviews/ | — | — |
| `documenter` | * | docs/**, README.md, CHANGELOG.md | — | — |
| `planner` | * | — | — | — |

---

## Integration with Superpowers & ECC

### Superpowers Workflows (via Plugin)
- **Brainstorming** → `build` uses before new features
- **Writing Plans** → `planner` / `architect` for implementation plans
- **Subagent-Driven Development** → `build` delegates to specialists
- **TDD** → `backend-developer`, `frontend-developer`, `qa-engineer` follow `@tdd-workflow`
- **Systematic Debugging** → `debugger` uses `@systematic-debugging`
- **Code Review** → `code-reviewer` before merge
- **Verification Loop** → `build` runs before completion
- **Branch Completion** → `build` manages integration

### ECC Skills (Reused, Not Duplicated)
All relevant ECC skills from `~/.config/opencode/skills/` are available via the skills path in `opencode.json`. Project-local skills **extend** or **specialize** ECC skills for RenTahanan domain.

---

## Communication Protocol

### Delegation Message Format (from `build` to specialist)
```
Task: [Clear title]
Context: [Relevant background, links to docs/code]
Acceptance Criteria: [Specific, testable outcomes]
Files to Modify: [Explicit paths]
Skills to Load: [@skill-id list]
Report Format: [Expected deliverable structure]
```

### Completion Report Format (from specialist to `build`)
```
Status: COMPLETE / BLOCKED / PARTIAL
Files Changed: [List with paths]
Tests: [Pass/fail, coverage]
Verification: [Commands run, results]
Blockers: [If any, with what's needed]
Next Steps: [If partial]
```

---

## Verification Loop (Mandatory Before "Done")

`build` executes before declaring any feature complete:

1. **Type Check**: `npx tsc --noEmit` (backend & frontend)
2. **Lint**: `npm run lint`
3. **Unit Tests**: `npm test` (backend + frontend)
4. **Integration Tests**: `npm run test:integration`
5. **Build**: `npm run build` (both)
6. **Coverage**: ≥80% backend, ≥70% frontend
7. **Security Grep**: No secrets, no `console.log`, proper auth checks
8. **Diff Review**: `git diff` review

Only **PASS** on all → feature complete.

---

## Current Project Phase

| Phase | Status | Focus |
|-------|--------|-------|
| 1: Auth & Users | ✅ Done | JWT, RBAC, registration |
| 2: Rooms & Beds | ✅ Done | CRUD, status tracking |
| 3: Tenants & Contracts | ✅ Done | Transactional bed assignment |
| 4: Billing & Payments | ✅ Done | OR tracking, full-payment rule |
| **5: QA & Testing** | 🔄 **Active** | Test suite, coverage, CI |
| 6: Frontend Buildout | ⏳ Pending | React SPA from mockups |
| 7: Debug & Harden | ⏳ Pending | Logging, validation, security |
| 8: Docs & Knowledge | ⏳ Pending | Living docs, ADRs, code tours |

---

## Open Questions for Human Review

1. **Frontend Scope** — Full React SPA from all mockups, or MVP (Owner dashboard + Caretaker OR entry only)?
2. **Late Fees** — Grace period? Fixed/percentage? Cap? (See `rental-payment-rules` skill)
3. **Token Refresh** — Needed? Concurrent session limits?
4. **Password Reset** — Required flow?
5. **Audit Log** — Retention policy, what events?
5. **Deployment Target** — Docker? VPS? Serverless?

---

*This architecture is maintained in `docs/architecture/ai-development-team.md` and updated by `documenter` when agent configurations change.*