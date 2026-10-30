# RenTahanan API Documentation

## Authentication (`/api/auth`)
- `POST /register`: Register a new user (default role: TENANT).
- `POST /login`: Login user and receive JWT.
- `GET /profile`: Get current user profile (requires token).

## Users (`/api/users`)
- `GET /`: Get all users (OWNER only).

## Rooms (`/api/rooms`)
- `GET /`: List all rooms.
- `GET /:id`: Get room details.
- `POST /`: Create room (OWNER, CARETAKER).
- `PUT /:id`: Update room (OWNER, CARETAKER).
- `DELETE /:id`: Delete room (OWNER).

## Beds (`/api/beds`)
- `GET /`: List all beds.
- `GET /:id`: Get bed details.
- `POST /`: Create bed (OWNER, CARETAKER).
- `PUT /:id`: Update bed (OWNER, CARETAKER).
- `DELETE /:id`: Delete bed (OWNER).

## Tenants (`/api/tenants`)
- `GET /`: List all tenants (OWNER, CARETAKER).
- `GET /:id`: Get tenant details.
- `POST /`: Create tenant profile (OWNER, CARETAKER).
- `PUT /:id`: Update tenant profile (OWNER, CARETAKER).
- `DELETE /:id`: Delete tenant (OWNER).

## Contracts (`/api/contracts`)
- `GET /`: List all contracts.
- `POST /`: Create contract and assign bed (OWNER, CARETAKER).
- `PUT /:id/terminate`: Terminate contract and vacate bed (OWNER, CARETAKER).

## Billing (`/api/billing`)
- `GET /`: List billing statements.
- `POST /`: Generate monthly billing statement.

## Payments (`/api/payments`)
- `GET /`: List all payments.
- `POST /`: Log a payment with OR number.
