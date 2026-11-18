# Graph Report - -RenTahanan-A-Bedspace-Occupancy-and-Rent-Management-System  (2026-11-18)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 191 nodes · 255 edges · 19 communities (11 shown, 8 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8128bf66`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- server.js
- db.js
- agents
- userController.js
- opencode.json
- roomController.js
- build
- database-engineer
- debugger
- documenter
- frontend-developer
- planner
- Entity Relationship Diagram
- API Reference
- planner
- Sign Up UI Mockup

## God Nodes (most connected - your core abstractions)
1. `Project Journal` - 16 edges
2. `express` - 11 edges
3. `agents` - 11 edges
4. `Frontend Developer Agent` - 11 edges
5. `Environment Audit Report` - 10 edges
6. `auth()` - 9 edges
7. `Lead Orchestrator Agent` - 9 edges
8. `build (Lead Orchestrator)` - 9 edges
9. `Backend Developer Agent` - 6 edges
10. `Database Engineer Agent` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Frontend Developer Agent` --references--> `Assign Tenant UI Mockup`  [EXTRACTED]
  .opencode/agents/frontend-developer.md → docs/assign tenant to vacant bed.png
- `Frontend Developer Agent` --references--> `Bedspace Dashboard UI Mockup`  [EXTRACTED]
  .opencode/agents/frontend-developer.md → docs/bedspace dashboard.png
- `Frontend Developer Agent` --references--> `Caretaker OR Entry UI Mockup`  [EXTRACTED]
  .opencode/agents/frontend-developer.md → docs/caretaker OR entry.png
- `Frontend Developer Agent` --references--> `Digital Receipt UI Mockup`  [EXTRACTED]
  .opencode/agents/frontend-developer.md → docs/digital receipt.png
- `Frontend Developer Agent` --references--> `Login Screen UI Mockup`  [EXTRACTED]
  .opencode/agents/frontend-developer.md → docs/log-in screen.png

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **AI Development Team Architecture** — opencode_agents_build, opencode_agents_architect, opencode_agents_backend_developer, opencode_agents_database_engineer, opencode_agents_frontend_developer, opencode_agents_code_reviewer, opencode_agents_debugger, opencode_agents_qa_engineer, opencode_agents_documenter, opencode_agents_planner [EXTRACTED 1.00]
- **AI Development Team Orchestration** — docs_architecture_ai_development_team_build, docs_architecture_ai_development_team_architect, docs_architecture_ai_development_team_planner, docs_architecture_ai_development_team_documenter, docs_architecture_ai_development_team_backend_developer, docs_architecture_ai_development_team_database_engineer, docs_architecture_ai_development_team_qa_engineer, docs_architecture_ai_development_team_frontend_developer, docs_architecture_ai_development_team_debugger, docs_architecture_ai_development_team_code_reviewer [EXTRACTED 1.00]
- **Backend Core Implementation** — server_middleware_auth_js, server_controllers_usercontroller, server_routes_auth_js, server_routes_users_js, server_server, server_controllers_roomcontroller, server_controllers_bedcontroller, server_routes_rooms_js, server_routes_beds_js, server_controllers_tenantcontroller, server_routes_tenants_js, server_controllers_billingcontroller, server_controllers_paymentcontroller, server_routes_billing_js, server_routes_payments_js [INFERRED 0.90]

## Communities (19 total, 8 thin omitted)

### Community 0 - "server.js"
Cohesion: 0.06
Nodes (10): Project Journal, {Pool}, auth.js, auth.js (routes), beds.js (routes), billing.js (routes), payments.js (routes), rooms.js (routes) (+2 more)

### Community 1 - "db.js"
Cohesion: 0.12
Nodes (23): express, auth(), jwt, express, router, express, router, express (+15 more)

### Community 2 - "agents"
Cohesion: 0.06
Nodes (31): agents, architect, backend-developer, build, code-reviewer, documenter, frontend-developer, description (+23 more)

### Community 3 - "userController.js"
Cohesion: 0.12
Nodes (17): bcryptjs, cors, dotenv, jsonwebtoken, nodemon, pg, bcrypt, jwt (+9 more)

### Community 4 - "opencode.json"
Cohesion: 0.18
Nodes (20): Environment Audit Report, Assign Tenant UI Mockup, Bedspace Dashboard UI Mockup, Caretaker OR Entry UI Mockup, Digital Receipt UI Mockup, Login Screen UI Mockup, Role Selection UI Mockup, Tenant Billing History UI Mockup (+12 more)

### Community 5 - "roomController.js"
Cohesion: 0.22
Nodes (9): architect (System Architect), backend-developer, build (Lead Orchestrator), code-reviewer, database-engineer, debugger, documenter, frontend-developer (+1 more)

### Community 6 - "build"
Cohesion: 0.33
Nodes (5): default_agent, model, permissions, $schema, skills

### Community 7 - "database-engineer"
Cohesion: 0.40
Nodes (5): database-engineer, description, mode, model, permissions

### Community 8 - "debugger"
Cohesion: 0.40
Nodes (5): debugger, description, mode, model, permissions

### Community 9 - "documenter"
Cohesion: 0.40
Nodes (5): planner, description, mode, model, permissions

### Community 10 - "frontend-developer"
Cohesion: 0.40
Nodes (5): qa-engineer, description, mode, model, permissions

## Knowledge Gaps
- **33 isolated node(s):** `auth.js`, `auth.js (routes)`, `beds.js (routes)`, `billing.js (routes)`, `payments.js (routes)` (+28 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 121 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Project Journal` connect `server.js` to `db.js`, `userController.js`, `roomController.js`?**
  _High betweenness centrality (0.113) - this node is a cross-community bridge._
- **What connects `auth.js`, `auth.js (routes)`, `beds.js (routes)` to the rest of the system?**
  _33 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `server.js` be split into smaller, more focused modules?**
  _Cohesion score 0.05668016194331984 - nodes in this community are weakly interconnected._
- **Why does `agents` connect `agents` to `build`, `database-engineer`, `debugger`, `documenter`, `frontend-developer`?**
  _High betweenness centrality (0.079) - this node is a cross-community bridge._
- **Should `db.js` be split into smaller, more focused modules?**
  _Cohesion score 0.11586452762923351 - nodes in this community are weakly interconnected._
- **Why does `build (Lead Orchestrator)` connect `roomController.js` to `server.js`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **Should `agents` be split into smaller, more focused modules?**
  _Cohesion score 0.06451612903225806 - nodes in this community are weakly interconnected._