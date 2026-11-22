-- ========================================================
-- RenTahanan Database Initialization Script
-- Client: Evelyn Lady's Dormitory
-- Database: PostgreSQL
-- Author: Papolonias (Backend & Database Lead)
-- Updated: 2026-11-22 - Aligned with ERD.md (9 tables, 7 enums, 12 FKs, 12 CHECKs, 7 triggers)
-- ========================================================

-- Drop existing tables/types if re-initializing (Clean slate)
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS billing_statements CASCADE;
DROP TABLE IF EXISTS contracts CASCADE;
DROP TABLE IF EXISTS tenants CASCADE;
DROP TABLE IF EXISTS beds CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS activity_logs CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;

DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS room_type CASCADE;
DROP TYPE IF EXISTS room_status CASCADE;
DROP TYPE IF EXISTS bed_status CASCADE;
DROP TYPE IF EXISTS tenant_status CASCADE;
DROP TYPE IF EXISTS contract_status CASCADE;
DROP TYPE IF EXISTS billing_status CASCADE;

-- ========================================================
-- 1. ENUM TYPES
-- ========================================================
CREATE TYPE user_role AS ENUM ('OWNER', 'CARETAKER', 'TENANT');
CREATE TYPE room_type AS ENUM ('SINGLE', 'DOUBLE', 'QUAD');
CREATE TYPE room_status AS ENUM ('ACTIVE', 'UNDER_MAINTENANCE', 'DECOMMISSIONED');
CREATE TYPE bed_status AS ENUM ('VACANT', 'OCCUPIED', 'OVERDUE', 'UNAVAILABLE');
CREATE TYPE tenant_status AS ENUM ('ACTIVE', 'MOVED_OUT', 'FLAGGED_DEBT');
CREATE TYPE contract_status AS ENUM ('ACTIVE', 'COMPLETED', 'TERMINATED');
CREATE TYPE billing_status AS ENUM ('UNPAID', 'PAID', 'OVERDUE');

-- ========================================================
-- 2. USERS TABLE (Logins for Owner, Caretaker, & Tenants)
-- ========================================================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'TENANT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_username_not_empty CHECK (length(username) > 0)
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
    status room_status NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT rooms_capacity_positive CHECK (capacity > 0),
    CONSTRAINT rooms_floor_positive CHECK (floor_level > 0)
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT beds_bed_code_format CHECK (bed_code ~ '^R[0-9]{3}-[A-Z]$')
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tenants_contact_format CHECK (contact_number ~ '^\+?[0-9]{10,15}$'),
    CONSTRAINT tenants_emergency_format CHECK (emergency_contact ~ '^\+?[0-9]{10,15}$')
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT contracts_monthly_rate_positive CHECK (monthly_rate > 0),
    CONSTRAINT contracts_advance_rent_paid_nonneg CHECK (advance_rent_paid >= 0),
    CONSTRAINT contracts_deposit_paid_nonneg CHECK (deposit_paid >= 0)
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
    overdue_warning_count INT NOT NULL DEFAULT 0,
    eviction_eligible_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT billing_amount_due_positive CHECK (amount_due > 0),
    CONSTRAINT billing_warning_count_nonneg CHECK (overdue_warning_count >= 0)
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
    remarks TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT payments_amount_paid_positive CHECK (amount_paid > 0)
);

-- ========================================================
-- 9. ACTIVITY LOGS TABLE (Audit Trail for Owner)
-- ========================================================
CREATE TABLE activity_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INT,
    old_value JSONB,
    new_value JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    -- NO updated_at per ERD.md
);

-- ========================================================
-- 10. NOTIFICATIONS TABLE (In-App Alerts for Users)
-- ========================================================
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'SYSTEM',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    linked_entity_type VARCHAR(50),
    linked_entity_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    -- NO updated_at per ERD.md
);

-- ========================================================
-- 11. AUDIT TRIGGERS (updated_at auto-update on 7 core tables)
--     activity_logs and notifications do NOT have updated_at
-- ========================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rooms_updated_at BEFORE UPDATE ON rooms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_beds_updated_at BEFORE UPDATE ON beds
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tenants_updated_at BEFORE UPDATE ON tenants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contracts_updated_at BEFORE UPDATE ON contracts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_billing_statements_updated_at BEFORE UPDATE ON billing_statements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- NO triggers for activity_logs and notifications (no updated_at column)

-- ========================================================
-- 12. PERFORMANCE INDEXES
-- ========================================================
-- FK indexes (for JOIN performance)
CREATE INDEX idx_beds_room_id ON beds(room_id);
CREATE INDEX idx_contracts_tenant ON contracts(tenant_id);
CREATE INDEX idx_contracts_bed ON contracts(bed_id);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_billing_status ON billing_statements(status);
CREATE INDEX idx_billing_tenant_id ON billing_statements(tenant_id);
CREATE INDEX idx_billing_contract_id ON billing_statements(contract_id);
CREATE INDEX idx_billing_due_date ON billing_statements(due_date);
CREATE INDEX idx_payments_tenant_id ON payments(tenant_id);
CREATE INDEX idx_payments_billing_statement_id ON payments(billing_statement_id);
CREATE INDEX idx_payments_or ON payments(or_number);
CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_tenants_status ON tenants(status);
CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_action ON activity_logs(action);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- ========================================================
-- 13. INITIAL TEST SEED DATA (For Local Testing)
-- ========================================================
-- Create Default Staff Users
INSERT INTO users (username, password_hash, role)
VALUES
    ('owner_evelyn', 'hashed_owner_password', 'OWNER'),
    ('caretaker_mary', 'hashed_caretaker_password', 'CARETAKER');

-- Create Test Rooms (~50 rooms across 2 floors: 2nd and 3rd)
-- NOTE: Room types (SINGLE/DOUBLE/QUAD) are NOT finalized per client interview.
-- This seed uses a representative mix as placeholders.
INSERT INTO rooms (room_number, type, capacity, floor_level)
VALUES
    -- Floor 2 (25 rooms): 10 SINGLE, 10 DOUBLE, 5 QUAD
    ('201', 'SINGLE', 1, 2), ('202', 'SINGLE', 1, 2), ('203', 'SINGLE', 1, 2), ('204', 'SINGLE', 1, 2), ('205', 'SINGLE', 1, 2),
    ('206', 'SINGLE', 1, 2), ('207', 'SINGLE', 1, 2), ('208', 'SINGLE', 1, 2), ('209', 'SINGLE', 1, 2), ('210', 'SINGLE', 1, 2),
    ('211', 'DOUBLE', 2, 2), ('212', 'DOUBLE', 2, 2), ('213', 'DOUBLE', 2, 2), ('214', 'DOUBLE', 2, 2), ('215', 'DOUBLE', 2, 2),
    ('216', 'DOUBLE', 2, 2), ('217', 'DOUBLE', 2, 2), ('218', 'DOUBLE', 2, 2), ('219', 'DOUBLE', 2, 2), ('220', 'DOUBLE', 2, 2),
    ('221', 'QUAD', 4, 2), ('222', 'QUAD', 4, 2), ('223', 'QUAD', 4, 2), ('224', 'QUAD', 4, 2), ('225', 'QUAD', 4, 2),
    -- Floor 3 (25 rooms): 10 SINGLE, 10 DOUBLE, 5 QUAD
    ('301', 'SINGLE', 1, 3), ('302', 'SINGLE', 1, 3), ('303', 'SINGLE', 1, 3), ('304', 'SINGLE', 1, 3), ('305', 'SINGLE', 1, 3),
    ('306', 'SINGLE', 1, 3), ('307', 'SINGLE', 1, 3), ('308', 'SINGLE', 1, 3), ('309', 'SINGLE', 1, 3), ('310', 'SINGLE', 1, 3),
    ('311', 'DOUBLE', 2, 3), ('312', 'DOUBLE', 2, 3), ('313', 'DOUBLE', 2, 3), ('314', 'DOUBLE', 2, 3), ('315', 'DOUBLE', 2, 3),
    ('316', 'DOUBLE', 2, 3), ('317', 'DOUBLE', 2, 3), ('318', 'DOUBLE', 2, 3), ('319', 'DOUBLE', 2, 3), ('320', 'DOUBLE', 2, 3),
    ('321', 'QUAD', 4, 3), ('322', 'QUAD', 4, 3), ('323', 'QUAD', 4, 3), ('324', 'QUAD', 4, 3), ('325', 'QUAD', 4, 3);

-- Create Test Beds for all rooms
-- Uses DO blocks to generate beds per room type automatically
DO $$
DECLARE
    r RECORD;
    i INT;
BEGIN
    FOR r IN SELECT room_id, room_number, type FROM rooms ORDER BY room_id LOOP
        IF r.type = 'SINGLE' THEN
            INSERT INTO beds (room_id, bed_code, status) VALUES (r.room_id, 'R' || r.room_number || '-A', 'VACANT');
        ELSIF r.type = 'DOUBLE' THEN
            FOR i IN 1..2 LOOP
                INSERT INTO beds (room_id, bed_code, status) VALUES (r.room_id, 'R' || r.room_number || '-' || CHR(64+i), 'VACANT');
            END LOOP;
        ELSIF r.type = 'QUAD' THEN
            FOR i IN 1..4 LOOP
                INSERT INTO beds (room_id, bed_code, status) VALUES (r.room_id, 'R' || r.room_number || '-' || CHR(64+i), 'VACANT');
            END LOOP;
        END IF;
    END LOOP;
END $$;