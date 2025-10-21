BEGIN;

-- ==========================================================
-- ADD duration_days COLUMN TO user_medications TABLE
-- ==========================================================
ALTER TABLE user_medications
ADD COLUMN duration_days INT NOT NULL DEFAULT 30;

COMMIT;

