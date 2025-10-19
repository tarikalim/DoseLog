package repository

import (
	"DoseLog/internal/core/entity"
	"context"
	"database/sql"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type MedicationRepository interface {
	Create(ctx context.Context, med *entity.Medication) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.Medication, error)
	GetByName(ctx context.Context, name string) (*entity.Medication, error)
	Update(ctx context.Context, med *entity.Medication) error
	List(ctx context.Context, limit, offset int) ([]*entity.Medication, error)
}

type medicationRepository struct {
	db *sqlx.DB
}

func NewMedicationRepository(db *sqlx.DB) MedicationRepository {
	return &medicationRepository{db: db}
}

func (r *medicationRepository) Create(ctx context.Context, med *entity.Medication) error {
	query := `
		INSERT INTO medications (id, name, description, manufacturer, form, strength_mg, pills_per_box, meal_relation, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`
	_, err := r.db.ExecContext(ctx, query,
		med.ID, med.Name, med.Description, med.Manufacturer,
		med.Form, med.StrengthMg, med.PillsPerBox, med.MealRelation, med.CreatedAt)
	return err
}

func (r *medicationRepository) GetByID(ctx context.Context, id uuid.UUID) (*entity.Medication, error) {
	var med entity.Medication
	query := `
		SELECT id, name, description, manufacturer, form, strength_mg, pills_per_box, meal_relation, created_at
		FROM medications
		WHERE id = $1
	`
	err := r.db.GetContext(ctx, &med, query, id)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &med, nil
}

func (r *medicationRepository) GetByName(ctx context.Context, name string) (*entity.Medication, error) {
	var med entity.Medication
	query := `
		SELECT id, name, description, manufacturer, form, strength_mg, pills_per_box, meal_relation, created_at
		FROM medications
		WHERE name = $1
	`
	err := r.db.GetContext(ctx, &med, query, name)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &med, nil
}

func (r *medicationRepository) Update(ctx context.Context, med *entity.Medication) error {
	query := `
		UPDATE medications
		SET name = $2, description = $3, manufacturer = $4, form = $5,
		    strength_mg = $6, pills_per_box = $7, meal_relation = $8
		WHERE id = $1
	`
	_, err := r.db.ExecContext(ctx, query,
		med.ID, med.Name, med.Description, med.Manufacturer,
		med.Form, med.StrengthMg, med.PillsPerBox, med.MealRelation)
	return err
}

func (r *medicationRepository) List(ctx context.Context, limit, offset int) ([]*entity.Medication, error) {
	var medications []*entity.Medication
	query := `
		SELECT id, name, description, manufacturer, form, strength_mg, pills_per_box, meal_relation, created_at
		FROM medications
		ORDER BY created_at DESC
		LIMIT $1 OFFSET $2
	`
	err := r.db.SelectContext(ctx, &medications, query, limit, offset)
	if err != nil {
		return nil, err
	}
	return medications, nil
}
