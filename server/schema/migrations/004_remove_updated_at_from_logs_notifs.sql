-- ========================================================
-- Migration 004: Align activity_logs and notifications to ERD.md
-- Remove updated_at from activity_logs and notifications (per Mermaid ERD)
-- Author: RenTahanan Team
-- Updated: 2026-11-22
-- ========================================================

BEGIN;

-- Drop triggers first
DROP TRIGGER IF EXISTS update_activity_logs_updated_at ON activity_logs;
DROP TRIGGER IF EXISTS update_notifications_updated_at ON notifications;

-- Drop updated_at columns (ERD.md shows only created_at for these tables)
ALTER TABLE activity_logs DROP COLUMN IF EXISTS updated_at;
ALTER TABLE notifications DROP COLUMN IF EXISTS updated_at;

COMMIT;