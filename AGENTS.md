# AGENTS.md - RenTahanan

## Project Overview
RenTahanan: A Bedspace Occupancy and Rent Management System for Evelyn Lady's Dormitory.
- **Team Roles:** Papolonias (Backend/DB), Jacuba (Frontend/UI), Malinao (DB/QA).
- **Stack:** PERN (PostgreSQL, Express, React, Node.js).

## Developer Commands
- **Start Backend Dev Server:** `npm run dev --prefix server` (or `node server/server.js`)
- **Run Verification Check:** `node server/test_routes.js`

## Architecture & Conventions
- **Database:** PostgreSQL schema initialized via `server/schema/init.sql`. Uses enums for roles (`OWNER`, `CARETAKER`, `TENANT`), room types, and statuses.
- **Transactions:** Critical financial and bed assignment actions use PostgreSQL transactions (`BEGIN`/`COMMIT`/`ROLLBACK`) and `FOR UPDATE` row locking to prevent double-booking.
- **Auth & RBAC:** Centralized JWT middleware in `server/middleware/auth.js` enforcing role-based permissions (`OWNER`, `CARETAKER`, `TENANT`).
- **Financial Rules:** Partial payments are prohibited; advance payments and security deposits are explicitly tracked; Official Receipt (OR) numbers must be strictly unique.

## Agent Team Mapping
- **Documentation Agent (`doc-updater` / manual):** Maintains `docs/automation/PROJECT_JOURNAL.md`, `docs/API.md`, and specification records.
- **Planner Agent (`planner`):** Manages project scope, implementation plans, and sprint milestones.
- **Database / Backend Specialists (`database-reviewer`, `general`):** Handle PostgreSQL schema integrity and Express API routes/controllers.
