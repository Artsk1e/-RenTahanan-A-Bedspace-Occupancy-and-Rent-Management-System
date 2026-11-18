# Graph Report - -RenTahanan-A-Bedspace-Occupancy-and-Rent-Management-System  (2026-11-18)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 143 nodes · 194 edges · 12 communities (10 shown, 2 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
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
- build
- database-engineer
- debugger
- documenter
- frontend-developer
- planner

## God Nodes (most connected - your core abstractions)
1. `express` - 11 edges
2. `agents` - 11 edges
3. `auth()` - 9 edges
4. `frontend-developer` - 5 edges
5. `planner` - 5 edges
6. `architect` - 5 edges
7. `backend-developer` - 5 edges
8. `code-reviewer` - 5 edges
9. `qa-engineer` - 5 edges
10. `build` - 5 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (12 total, 2 thin omitted)

### Community 0 - "server.js"
Cohesion: 0.11
Nodes (24): express, auth(), jwt, express@^5.3.0, express, router, express, router (+16 more)

### Community 2 - "agents"
Cohesion: 0.10
Nodes (21): agents, architect, backend-developer, code-reviewer, qa-engineer, description, mode, model (+13 more)

### Community 3 - "userController.js"
Cohesion: 0.13
Nodes (16): bcryptjs, cors, dotenv, jsonwebtoken, nodemon, pg, bcrypt, jwt (+8 more)

### Community 4 - "opencode.json"
Cohesion: 0.33
Nodes (5): default_agent, model, permissions, $schema, skills

### Community 6 - "build"
Cohesion: 0.40
Nodes (5): build, description, mode, model, permissions

### Community 7 - "database-engineer"
Cohesion: 0.40
Nodes (5): database-engineer, description, mode, model, permissions

### Community 8 - "debugger"
Cohesion: 0.40
Nodes (5): debugger, description, mode, model, permissions

### Community 9 - "documenter"
Cohesion: 0.40
Nodes (5): documenter, description, mode, model, permissions

### Community 10 - "frontend-developer"
Cohesion: 0.40
Nodes (5): frontend-developer, description, mode, model, permissions

### Community 11 - "planner"
Cohesion: 0.40
Nodes (5): planner, description, mode, model, permissions

## Knowledge Gaps
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `agents` connect `agents` to `opencode.json`, `build`, `database-engineer`, `debugger`, `documenter`, `frontend-developer`, `planner`?**
  _High betweenness centrality (0.142) - this node is a cross-community bridge._
- **Should `server.js` be split into smaller, more focused modules?**
  _Cohesion score 0.11092436974789915 - nodes in this community are weakly interconnected._
- **Why does `express` connect `server.js` to `userController.js`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **Should `db.js` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._
- **Why does `frontend-developer` connect `frontend-developer` to `agents`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **Should `agents` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._
- **Should `userController.js` be split into smaller, more focused modules?**
  _Cohesion score 0.12857142857142856 - nodes in this community are weakly interconnected._