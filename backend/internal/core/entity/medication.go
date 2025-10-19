package entity

import (
	"backend/internal/core/shared"
	"time"

	"github.com/google/uuid"
)

type Medication struct {
	ID           uuid.UUID           `db:"id"`
	Name         string              `db:"name"`
	Description  *string             `db:"description"`
	Manufacturer *string             `db:"manufacturer"`
	Form         string              `db:"form"`
	StrengthMg   float32             `db:"strength_mg"`
	PillsPerBox  int                 `db:"pills_per_box"`
	MealRelation shared.MealRelation `db:"meal_relation"`
	CreatedAt    time.Time           `db:"created_at"`
}
