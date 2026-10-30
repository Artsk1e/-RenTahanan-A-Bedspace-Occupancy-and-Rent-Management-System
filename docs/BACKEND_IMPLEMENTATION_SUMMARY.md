# Documentation: RenTahanan Backend Core Implementation

## Overview
This document summarizes the initial backend development phase for the RenTahanan Bedspace Occupancy and Rent Management System. The foundation implements the core business logic required for managing dormitory occupancy and financial records.

## Summary of Changes
- **Project Structure**: Established a modular Express.js directory structure (`controllers`, `middleware`, `routes`, `utils`, `config`).
- **Authentication System**:
    - Implemented JWT-based authentication with RBAC (Role-Based Access Control).
    - Added bcrypt hashing for secure user passwords.
    - Protected API routes using middleware to distinguish between Owner, Caretaker, and Tenant access levels.
- **Data Management**:
    - Implemented CRUD logic for Rooms, Beds, and Tenants.
    - Integrated transactional logic for contract creation (simultaneous bed assignment and status locking) to ensure data integrity.
    - Implemented billing and payment tracking with mandatory OR (Official Receipt) number uniqueness.
- **API Foundation**: Updated `server.js` to serve modularized routes and provided `docs/API.md` as the developer reference.

## Technical Details
- **Architecture**: PERN stack (PostgreSQL, Express, React, Node.js).
- **Concurrency Control**: Used database transactions (`BEGIN`/`COMMIT`/`ROLLBACK`) to prevent duplicate bed assignments or inconsistent payment recording.
- **Verification**: Verified endpoint scaffolding and route loading via local test script `server/test_routes.js`.

## Team Guidelines
- **Roles**: 
    - **Papolonias**: Oversee backend stability and integration.
    - **Jacuba**: UI development using API endpoints specified in `docs/API.md`.
    - **Malinao**: Conduct QA testing and schema verification.
- **Automation**: Development progress is tracked in `docs/automation/PROJECT_JOURNAL.md`.
