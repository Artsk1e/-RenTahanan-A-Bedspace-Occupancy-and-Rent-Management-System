# RenTahanan — Boarding House Management System

## Overview
RenTahanan manages boarding house operations for Evelyn Lady's Dormitory:
tenant management, room/bed assignments, rental contracts, billing, and payments.

## Tech Stack
- **Backend**: Node.js + Express + TypeScript (in progress — currently JavaScript)
- **Database**: PostgreSQL
- **Frontend**: React + TypeScript + Vite (planned)
- **Auth**: JWT + bcrypt, RBAC (OWNER, CARETAKER, TENANT)
- **AI Development**: OpenCode + FreeLLMAPI (localhost:3001)

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
└── server.ts       # App entry point (to be created)
```

## Documentation
- [API Reference](docs/api/index.md)
- [Database Schema](docs/database/schema.md)
- [Architecture](docs/architecture/overview.md)
- [Development Guide](docs/development/backend-guide.md)
- [AI Development Team](docs/architecture/ai-development-team.md)

## AI Development Team
See [AGENTS.md](AGENTS.md) for agent definitions and [docs/architecture/ai-development-team.md](docs/architecture/ai-development-team.md) for architecture.