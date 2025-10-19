package repository

import (
	"backend/internal/core/entity"
	"context"
	"database/sql"
	"encoding/json"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type UserMedicationRepository interface {
	Create(ctx context.Context, um *entity.UserMedication) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.UserMedication, error)
	GetByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.UserMedication, error)
	GetActiveByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.UserMedication, error)
	Update(ctx context.Context, um *entity.UserMedication) error
}

type userMedicationRepository struct {
	db *sqlx.DB
}

func NewUserMedicationRepository(db *sqlx.DB) UserMedicationRepository {
	return &userMedicationRepository{db: db}
}

func (r *userMedicationRepository) Create(ctx context.Context, um *entity.UserMedication) error {
	schedulesJSON, err := json.Marshal(um.Schedules)
	if err != nil {
		return err
	}

	query := `
		INSERT INTO user_medications (id, user_id, medication_id, boxes_owned, schedules, start_at, active, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`
	_, err = r.db.ExecContext(ctx, query,
		um.ID, um.UserID, um.MedicationID, um.BoxesOwned,
		schedulesJSON, um.StartAt, um.Active, um.CreatedAt)
	return err
}

func (r *userMedicationRepository) GetByID(ctx context.Context, id uuid.UUID) (*entity.UserMedication, error) {
	var um entity.UserMedication
	var schedulesJSON []byte

	query := `
		SELECT id, user_id, medication_id, boxes_owned, schedules, start_at, active, created_at
		FROM user_medications
		WHERE id = $1
	`
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&um.ID, &um.UserID, &um.MedicationID, &um.BoxesOwned,
		&schedulesJSON, &um.StartAt, &um.Active, &um.CreatedAt)

	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	if err := json.Unmarshal(schedulesJSON, &um.Schedules); err != nil {
		return nil, err
	}

	return &um, nil
}

func (r *userMedicationRepository) GetByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.UserMedication, error) {
	query := `
		SELECT id, user_id, medication_id, boxes_owned, schedules, start_at, active, created_at
		FROM user_medications
		WHERE user_id = $1
		ORDER BY created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return r.scanUserMedications(rows)
}

func (r *userMedicationRepository) GetActiveByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.UserMedication, error) {
	query := `
		SELECT id, user_id, medication_id, boxes_owned, schedules, start_at, active, created_at
		FROM user_medications
		WHERE user_id = $1 AND active = true
		ORDER BY created_at DESC
	`
	rows, err := r.db.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return r.scanUserMedications(rows)
}

func (r *userMedicationRepository) Update(ctx context.Context, um *entity.UserMedication) error {
	schedulesJSON, err := json.Marshal(um.Schedules)
	if err != nil {
		return err
	}

	query := `
		UPDATE user_medications
		SET boxes_owned = $2, schedules = $3, active = $4
		WHERE id = $1
	`
	_, err = r.db.ExecContext(ctx, query, um.ID, um.BoxesOwned, schedulesJSON, um.Active)
	return err
}

func (r *userMedicationRepository) scanUserMedications(rows *sql.Rows) ([]*entity.UserMedication, error) {
	var userMedications []*entity.UserMedication

	for rows.Next() {
		var um entity.UserMedication
		var schedulesJSON []byte

		err := rows.Scan(
			&um.ID, &um.UserID, &um.MedicationID, &um.BoxesOwned,
			&schedulesJSON, &um.StartAt, &um.Active, &um.CreatedAt)
		if err != nil {
			return nil, err
		}

		if err := json.Unmarshal(schedulesJSON, &um.Schedules); err != nil {
			return nil, err
		}

		userMedications = append(userMedications, &um)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return userMedications, nil
}
