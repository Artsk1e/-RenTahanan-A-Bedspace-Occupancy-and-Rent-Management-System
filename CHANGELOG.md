# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- AI Development Team architecture (9 specialized agents)
- Project-local skills: boarding-house-domain, rental-payment-rules, postgresql-conventions, api-conventions, auth-and-authorization, documentation-standards
- Documentation structure per governance standards

### Changed
- Split legacy `database-backend` agent into `database-engineer` + `backend-developer`
- Added `frontend-developer`, `debugger`, `code-reviewer`, `documenter` agents
- Updated model allocations based on FreeLLMAPI capabilities

### Fixed
- Removed duplicate Superpowers plugin declaration from global config

## [0.1.0] - 2026-10-30

### Added
- Initial backend API with auth, rooms, beds, tenants, contracts, billing, payments
- PostgreSQL schema with enums, triggers, indexes, seed data
- JWT authentication with RBAC (OWNER, CARETAKER, TENANT)
- Transactional bed assignment with FOR UPDATE locking
- Official Receipt (OR) tracking with uniqueness enforcement
- Business rules: one bed per tenant, no partial payments
- Project documentation: API.md, BACKEND_FOUNDATION_SPECIFICATION.md, PROJECT_JOURNAL.md

### Security
- bcrypt password hashing (10 rounds)
- JWT tokens with 24h expiry
- Role-based access control on all endpoints
- Parameterized queries (SQL injection prevention)