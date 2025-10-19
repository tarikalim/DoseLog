package repository

import (
	"DoseLog/internal/core/entity"
	"context"
	"database/sql"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"time"
)

type MedicationLogRepository interface {
	Create(ctx context.Context, log *entity.MedicationLog) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.MedicationLog, error)
	GetByUserMedicationID(ctx context.Context, userMedicationID uuid.UUID) ([]*entity.MedicationLog, error)
	GetByUserMedicationIDAndDateRange(ctx context.Context, userMedicationID uuid.UUID, start, end time.Time) ([]*entity.MedicationLog, error)
	Update(ctx context.Context, log *entity.MedicationLog) error
}

type medicationLogRepository struct {
	db *sqlx.DB
}

func NewMedicationLogRepository(db *sqlx.DB) MedicationLogRepository {
	return &medicationLogRepository{db: db}
}

func (r *medicationLogRepository) Create(ctx context.Context, log *entity.MedicationLog) error {
	query := `
		INSERT INTO medication_logs (id, user_medication_id, time_slot, planned_dose, taken, timestamp)
		VALUES ($1, $2, $3, $4, $5, $6)
	`
	_, err := r.db.ExecContext(ctx, query, log.ID, log.UserMedicationID, log.TimeSlot, log.PlannedDose, log.Taken, log.Timestamp)
	return err
}

func (r *medicationLogRepository) GetByID(ctx context.Context, id uuid.UUID) (*entity.MedicationLog, error) {
	var log entity.MedicationLog
	query := `
		SELECT id, user_medication_id, time_slot, planned_dose, taken, timestamp
		FROM medication_logs
		WHERE id = $1
	`
	err := r.db.GetContext(ctx, &log, query, id)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &log, nil
}

func (r *medicationLogRepository) GetByUserMedicationID(ctx context.Context, userMedicationID uuid.UUID) ([]*entity.MedicationLog, error) {
	var logs []*entity.MedicationLog
	query := `
		SELECT id, user_medication_id, time_slot, planned_dose, taken, timestamp
		FROM medication_logs
		WHERE user_medication_id = $1
		ORDER BY timestamp DESC
	`
	err := r.db.SelectContext(ctx, &logs, query, userMedicationID)
	if err != nil {
		return nil, err
	}
	return logs, nil
}

func (r *medicationLogRepository) GetByUserMedicationIDAndDateRange(ctx context.Context, userMedicationID uuid.UUID, start, end time.Time) ([]*entity.MedicationLog, error) {
	var logs []*entity.MedicationLog
	query := `
		SELECT id, user_medication_id, time_slot, planned_dose, taken, timestamp
		FROM medication_logs
		WHERE user_medication_id = $1
		  AND timestamp >= $2
		  AND timestamp < $3
		ORDER BY timestamp DESC
	`
	err := r.db.SelectContext(ctx, &logs, query, userMedicationID, start, end)
	if err != nil {
		return nil, err
	}
	return logs, nil
}

func (r *medicationLogRepository) Update(ctx context.Context, log *entity.MedicationLog) error {
	query := `
		UPDATE medication_logs
		SET taken = $2
		WHERE id = $1
	`
	_, err := r.db.ExecContext(ctx, query, log.ID, log.Taken)
	return err
}
