-- ========================================================
-- Migration 003: Fix all schema to match ERD.md exactly
-- Author: RenTahanan Team
-- Updated: 2026-11-22
-- ========================================================

BEGIN;

-- ========================================================
-- 1. ENUM FIXES
-- ========================================================

-- Add room_status enum (missing entirely)
CREATE TYPE room_status AS ENUM ('ACTIVE', 'UNDER_MAINTENANCE', 'DECOMMISSIONED');

-- Add UNAVAILABLE to bed_status enum
ALTER TYPE bed_status ADD VALUE IF NOT EXISTS 'UNAVAILABLE';

-- ========================================================
-- 2. MISSING COLUMNS
-- ========================================================

-- Add status column to rooms table
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS status room_status NOT NULL DEFAULT 'ACTIVE';

-- ========================================================
-- 3. FIX FOREIGN KEY ON DELETE RULES
-- ========================================================

-- beds.room_id -> rooms: should be CASCADE (currently SET DEFAULT)
ALTER TABLE beds DROP CONSTRAINT IF EXISTS beds_room_id_fkey;
ALTER TABLE beds ADD CONSTRAINT beds_room_id_fkey 
    FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE CASCADE;

-- billing_statements.contract_id -> contracts: should be CASCADE (currently SET DEFAULT)
ALTER TABLE billing_statements DROP CONSTRAINT IF EXISTS billing_statements_contract_id_fkey;
ALTER TABLE billing_statements ADD CONSTRAINT billing_statements_contract_id_fkey 
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id) ON DELETE CASCADE;

-- billing_statements.tenant_id -> tenants: should be CASCADE (currently SET DEFAULT)
ALTER TABLE billing_statements DROP CONSTRAINT IF EXISTS billing_statements_tenant_id_fkey;
ALTER TABLE billing_statements ADD CONSTRAINT billing_statements_tenant_id_fkey 
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE;

-- payments.tenant_id -> tenants: should be CASCADE (currently SET DEFAULT)
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_tenant_id_fkey;
ALTER TABLE payments ADD CONSTRAINT payments_tenant_id_fkey 
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE;

-- notifications.user_id -> users: should be CASCADE (currently SET DEFAULT)
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_user_id_fkey;
ALTER TABLE notifications ADD CONSTRAINT notifications_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

-- ========================================================
-- 4. CHECK CONSTRAINTS
-- ========================================================

-- payments.amount_paid > 0
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_amount_paid_positive;
ALTER TABLE payments ADD CONSTRAINT payments_amount_paid_positive CHECK (amount_paid > 0);

-- contracts: monthly_rate > 0
ALTER TABLE contracts DROP CONSTRAINT IF EXISTS contracts_monthly_rate_positive;
ALTER TABLE contracts ADD CONSTRAINT contracts_monthly_rate_positive CHECK (monthly_rate > 0);

-- contracts: advance_rent_paid >= 0
ALTER TABLE contracts DROP CONSTRAINT IF EXISTS contracts_advance_rent_paid_nonneg;
ALTER TABLE contracts ADD CONSTRAINT contracts_advance_rent_paid_nonneg CHECK (advance_rent_paid >= 0);

-- contracts: deposit_paid >= 0
ALTER TABLE contracts DROP CONSTRAINT IF EXISTS contracts_deposit_paid_nonneg;
ALTER TABLE contracts ADD CONSTRAINT contracts_deposit_paid_nonneg CHECK (deposit_paid >= 0);

-- billing_statements: amount_due > 0
ALTER TABLE billing_statements DROP CONSTRAINT IF EXISTS billing_amount_due_positive;
ALTER TABLE billing_statements ADD CONSTRAINT billing_amount_due_positive CHECK (amount_due > 0);

-- billing_statements: overdue_warning_count >= 0
ALTER TABLE billing_statements DROP CONSTRAINT IF EXISTS billing_warning_count_nonneg;
ALTER TABLE billing_statements ADD CONSTRAINT billing_warning_count_nonneg CHECK (overdue_warning_count >= 0);

-- rooms: capacity > 0
ALTER TABLE rooms DROP CONSTRAINT IF EXISTS rooms_capacity_positive;
ALTER TABLE rooms ADD CONSTRAINT rooms_capacity_positive CHECK (capacity > 0);

-- rooms: floor_level > 0
ALTER TABLE rooms DROP CONSTRAINT IF EXISTS rooms_floor_positive;
ALTER TABLE rooms ADD CONSTRAINT rooms_floor_positive CHECK (floor_level > 0);

-- beds: bed_code format (e.g., R101-A)
ALTER TABLE beds DROP CONSTRAINT IF EXISTS beds_bed_code_format;
ALTER TABLE beds ADD CONSTRAINT beds_bed_code_format CHECK (bed_code ~ '^R[0-9]{3}-[A-Z]$');

-- tenants: contact_number format
ALTER TABLE tenants DROP CONSTRAINT IF EXISTS tenants_contact_format;
ALTER TABLE tenants ADD CONSTRAINT tenants_contact_format CHECK (contact_number ~ '^\+?[0-9]{10,15}$');

-- tenants: emergency_contact format
ALTER TABLE tenants DROP CONSTRAINT IF EXISTS tenants_emergency_format;
ALTER TABLE tenants ADD CONSTRAINT tenants_emergency_format CHECK (emergency_contact ~ '^\+?[0-9]{10,15}$');

-- users: username not empty
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_username_not_empty;
ALTER TABLE users ADD CONSTRAINT users_username_not_empty CHECK (length(username) > 0);

-- ========================================================
-- 5. INDEXES (ensure all exist)
-- ========================================================

-- FK indexes (for JOIN performance)
CREATE INDEX IF NOT EXISTS idx_beds_room_id ON beds(room_id);
CREATE INDEX IF NOT EXISTS idx_contracts_tenant ON contracts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_contracts_bed ON contracts(bed_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON contracts(status);
CREATE INDEX IF NOT EXISTS idx_billing_status ON billing_statements(status);
CREATE INDEX IF NOT EXISTS idx_billing_tenant_id ON billing_statements(tenant_id);
CREATE INDEX IF NOT EXISTS idx_billing_contract_id ON billing_statements(contract_id);
CREATE INDEX IF NOT EXISTS idx_billing_due_date ON billing_statements(due_date);
CREATE INDEX IF NOT EXISTS idx_payments_tenant_id ON payments(tenant_id);
CREATE INDEX IF NOT EXISTS idx_payments_billing_statement_id ON payments(billing_statement_id);
CREATE INDEX IF NOT EXISTS idx_payments_or ON payments(or_number);
CREATE INDEX IF NOT EXISTS idx_rooms_status ON rooms(status);
CREATE INDEX IF NOT EXISTS idx_tenants_status ON tenants(status);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_action ON activity_logs(action);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- ========================================================
-- 6. TRIGGERS (updated_at on all tables)
-- ========================================================

-- Ensure function exists
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop and recreate all triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_rooms_updated_at ON rooms;
CREATE TRIGGER update_rooms_updated_at BEFORE UPDATE ON rooms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_beds_updated_at ON beds;
CREATE TRIGGER update_beds_updated_at BEFORE UPDATE ON beds
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_tenants_updated_at ON tenants;
CREATE TRIGGER update_tenants_updated_at BEFORE UPDATE ON tenants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_contracts_updated_at ON contracts;
CREATE TRIGGER update_contracts_updated_at BEFORE UPDATE ON contracts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_billing_statements_updated_at ON billing_statements;
CREATE TRIGGER update_billing_statements_updated_at BEFORE UPDATE ON billing_statements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_activity_logs_updated_at ON activity_logs;
CREATE TRIGGER update_activity_logs_updated_at BEFORE UPDATE ON activity_logs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_notifications_updated_at ON notifications;
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMIT;