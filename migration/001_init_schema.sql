BEGIN;

-- ==========================================================
-- ENUM DEFINITIONS
-- ==========================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'meal_relation') THEN
CREATE TYPE meal_relation AS ENUM ('before_meal', 'after_meal', 'with_meal', 'irrelevant');
END IF;
END$$;

-- ==========================================================
-- USERS TABLE
-- ==========================================================
CREATE TABLE IF NOT EXISTS users (
                                     id UUID PRIMARY KEY,
                                     password TEXT NOT NULL,
                                     email TEXT UNIQUE NOT NULL,
                                     created_at TIMESTAMPTZ DEFAULT now()
    );

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ==========================================================
-- MEDICATIONS TABLE (General drug definitions)
-- ==========================================================
CREATE TABLE IF NOT EXISTS medications (
                                           id UUID PRIMARY KEY,
                                           name TEXT NOT NULL,
                                           description TEXT,
                                           manufacturer TEXT,
                                           form TEXT NOT NULL,
                                           strength_mg REAL,
                                           pills_per_box INT NOT NULL,
                                           meal_relation meal_relation DEFAULT 'irrelevant',
                                           created_at TIMESTAMPTZ DEFAULT now()
    );

CREATE UNIQUE INDEX IF NOT EXISTS idx_medications_name ON medications(name);

-- ==========================================================
-- USER_MEDICATIONS TABLE (User-specific tracking)
-- ==========================================================
CREATE TABLE IF NOT EXISTS user_medications (
                                                id UUID PRIMARY KEY,
                                                user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    medication_id UUID NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
    boxes_owned INT NOT NULL,
    schedules JSONB NOT NULL,
    start_at TIMESTAMPTZ DEFAULT now(),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT uniq_user_medication UNIQUE (user_id, medication_id)
    );

CREATE INDEX IF NOT EXISTS idx_user_medications_user_id ON user_medications(user_id);
CREATE INDEX IF NOT EXISTS idx_user_medications_medication_id ON user_medications(medication_id);
CREATE INDEX IF NOT EXISTS idx_user_medications_active ON user_medications(active);

-- ==========================================================
-- MEDICATION_LOGS TABLE (Dose tracking)
-- ==========================================================
CREATE TABLE IF NOT EXISTS medication_logs (
    id UUID PRIMARY KEY,
    user_medication_id UUID NOT NULL REFERENCES user_medications(id) ON DELETE CASCADE,
    time_slot TEXT,
    planned_dose DOUBLE PRECISION NOT NULL,
    taken BOOLEAN DEFAULT FALSE,
    timestamp TIMESTAMPTZ DEFAULT now()
    );

CREATE INDEX IF NOT EXISTS idx_medication_logs_user_med_id ON medication_logs(user_medication_id);
CREATE INDEX IF NOT EXISTS idx_medication_logs_timestamp ON medication_logs(timestamp DESC);

COMMIT;

-- ==========================================================
-- END OF SCHEMA
-- ==========================================================
