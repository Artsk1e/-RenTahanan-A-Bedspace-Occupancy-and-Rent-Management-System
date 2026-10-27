-- ========================================================
-- RenTahanan Database Initialization Script
-- Client: Evelyn Lady's Dormitory
-- Database: PostgreSQL
-- Author: Papolonias (Backend & Database Lead)
-- ========================================================

-- Drop existing tables/types if re-initializing (Clean slate)
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS billing_statements CASCADE;
DROP TABLE IF EXISTS contracts CASCADE;
DROP TABLE IF EXISTS tenants CASCADE;
DROP TABLE IF EXISTS beds CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS users CASCADE;

DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS room_type CASCADE;
DROP TYPE IF EXISTS bed_status CASCADE;
DROP TYPE IF EXISTS tenant_status CASCADE;
DROP TYPE IF EXISTS contract_status CASCADE;
DROP TYPE IF EXISTS billing_status CASCADE;

-- ========================================================
-- 1. ENUM TYPES
-- ========================================================
CREATE TYPE user_role AS ENUM ('OWNER', 'CARETAKER', 'TENANT');
CREATE TYPE room_type AS ENUM ('SINGLE', 'DOUBLE', 'QUAD');
CREATE TYPE bed_status AS ENUM ('VACANT', 'OCCUPIED', 'OVERDUE');
CREATE TYPE tenant_status AS ENUM ('ACTIVE', 'MOVED_OUT', 'FLAGGED_DEBT');
CREATE TYPE contract_status AS ENUM ('ACTIVE', 'COMPLETED', 'TERMINATED');
CREATE TYPE billing_status AS ENUM ('UNPAID', 'PARTIALLY_PAID', 'PAID', 'OVERDUE');

-- ========================================================
-- 2. USERS TABLE (Logins for Owner, Caretaker, & Tenants)
-- ========================================================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'TENANT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- 3. ROOMS TABLE (Single, Double, and Quad Layouts)
-- ========================================================
CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    type room_type NOT NULL,
    capacity INT NOT NULL,
    floor_level INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- 4. BEDS TABLE (50+ Individual Bedspaces)
-- ========================================================
CREATE TABLE beds (
    bed_id SERIAL PRIMARY KEY,
    room_id INT REFERENCES rooms(room_id) ON DELETE CASCADE,
    bed_code VARCHAR(15) UNIQUE NOT NULL,
    -- e.g., 'R101-A', 'R101-B'
    status bed_status NOT NULL DEFAULT 'VACANT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- 5. TENANTS TABLE (Resident Profiles & Portal Link)
-- ========================================================
CREATE TABLE tenants (
    tenant_id SERIAL PRIMARY KEY,
    user_id INT UNIQUE REFERENCES users(user_id) ON DELETE SET NULL,
    -- Optional link to Tenant Portal login account
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    emergency_contact VARCHAR(15) NOT NULL,
    status tenant_status NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- 6. CONTRACTS TABLE (Leases, Advance Rent, & Deposits)
-- ========================================================
CREATE TABLE contracts (
    contract_id SERIAL PRIMARY KEY,
    tenant_id INT REFERENCES tenants(tenant_id) ON DELETE RESTRICT,
    bed_id INT REFERENCES beds(bed_id) ON DELETE RESTRICT,
    created_by_user_id INT REFERENCES users(user_id) ON DELETE SET NULL,
    -- Staff (Caretaker/Owner) who created lease
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    monthly_rate NUMERIC(10, 2) NOT NULL,
    -- Flat-rate rent with bundled utilities
    advance_rent_paid NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    deposit_paid NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    status contract_status NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- 7. BILLING STATEMENTS TABLE (Flat-rate Monthly Rent)
-- ========================================================
CREATE TABLE billing_statements (
    billing_statement_id SERIAL PRIMARY KEY,
    contract_id INT REFERENCES contracts(contract_id) ON DELETE CASCADE,
    tenant_id INT REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    billing_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    amount_due NUMERIC(10, 2) NOT NULL,
    status billing_status NOT NULL DEFAULT 'UNPAID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- 8. PAYMENTS TABLE (Cash Collection & Official Receipt)
-- ========================================================
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    billing_statement_id INT REFERENCES billing_statements(billing_statement_id) ON DELETE SET NULL,
    tenant_id INT REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    logged_by_user_id INT REFERENCES users(user_id) ON DELETE SET NULL,
    -- Caretaker or Owner who collected cash
    amount_paid NUMERIC(10, 2) NOT NULL,
    or_number VARCHAR(50) UNIQUE NOT NULL,
    -- Mandatory Official Receipt Number
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT
);

-- ========================================================
-- 9. PERFORMANCE INDEXES
-- ========================================================
CREATE INDEX idx_beds_status ON beds(status);
CREATE INDEX idx_billing_status ON billing_statements(status);
CREATE INDEX idx_payments_or ON payments(or_number);
CREATE INDEX idx_contracts_tenant ON contracts(tenant_id);

-- ========================================================
-- 10. INITIAL TEST SEED DATA (For Local Testing)
-- ========================================================
-- Create Default Staff Users
INSERT INTO users (username, password_hash, role)
VALUES
    ('owner_evelyn', 'hashed_owner_password', 'OWNER'),
    ('caretaker_mary', 'hashed_caretaker_password', 'CARETAKER');

-- Create Test Rooms
INSERT INTO rooms (room_number, type, capacity, floor_level)
VALUES
    ('101', 'SINGLE', 1, 1),
    ('102', 'DOUBLE', 2, 1),
    ('103', 'QUAD', 4, 1);

-- Create Test Beds for Room 101, 102, 103
INSERT INTO beds (room_id, bed_code, status)
VALUES
    (1, 'R101-A', 'VACANT'),
    (2, 'R102-A', 'VACANT'),
    (2, 'R102-B', 'VACANT'),
    (3, 'R103-A', 'VACANT'),
    (3, 'R103-B', 'VACANT'),
    (3, 'R103-C', 'VACANT'),
    (3, 'R103-D', 'VACANT');
