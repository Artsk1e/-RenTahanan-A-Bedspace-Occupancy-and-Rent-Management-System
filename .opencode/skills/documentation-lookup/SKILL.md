---
name: documentation-lookup
description: Use up-to-date library and framework docs via Context7 MCP instead of training data. Activates for setup questions, API references, code examples.
---

## When to Use

- Framework setup questions (Express, React, Vite, PostgreSQL)
- API reference lookups
- Code examples for specific library versions
- Version-specific migration guides

## Supported Sources

- Context7 MCP (primary)
- Official documentation sites
- GitHub READMEs for npm packages

## Workflow

1. Identify the specific library and version needed
2. Query Context7 MCP for current documentation
3. Extract relevant code examples and API references
4. Apply to RenTahanan context with project-specific adaptations

## RenTahanan Stack References

- **Express 5.x** - Routing, middleware, error handling
- **PostgreSQL 14+** - ENUM types, triggers, JSONB
- **Node.js 18+** - ES modules, async/await patterns
- **JWT (jsonwebtoken)** - Token signing, verification, expiry
- **bcryptjs** - Password hashing, salt rounds
- **pg (node-postgres)** - Connection pooling, transactions, parameterized queries