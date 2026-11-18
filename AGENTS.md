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

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

Rules:
- When graphify-out/graph.json exists, run `graphify query "<question>"` before your first grep, search or source-file read for a codebase question, and put this rule in every subagent prompt that explores code. Read raw files only for lines the graph or an earlier read already located. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. When the answer is under a Markdown heading, `graphify section "<heading>"` prints that section's text, so the .md need not be opened. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates; dirty graph files are not a reason to skip graphify. Only skip graphify if the task is about stale or incorrect graph output, or the user explicitly says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
- A committed graphify-out/graph.json is rewritten whole on every build, so a large diff to it in a pull request is expected. Do not flag it as churn or suggest skipping the graph rebuild or its hooks.
