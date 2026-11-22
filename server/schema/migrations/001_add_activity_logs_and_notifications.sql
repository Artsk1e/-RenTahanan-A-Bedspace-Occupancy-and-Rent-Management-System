-- ========================================================
-- Migration 001: Add activity_logs and notifications tables
-- Author: RenTahanan Team
-- Updated: 2026-11-22
-- ========================================================

BEGIN;

-- 1. ACTIVITY LOGS TABLE (Audit Trail for Owner)
CREATE TABLE IF NOT EXISTS activity_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INT,
    old_value JSONB,
    new_value JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. NOTIFICATIONS TABLE (In-App Alerts for Users)
CREATE TABLE IF NOT EXISTS notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'SYSTEM',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    linked_entity_type VARCHAR(50),
    linked_entity_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. TRIGGERS (updated_at auto-update)
CREATE TRIGGER update_activity_logs_updated_at BEFORE UPDATE ON activity_logs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 4. INDEXES
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_action ON activity_logs(action);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

COMMIT;
