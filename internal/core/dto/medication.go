package dto

import (
	"DoseLog/internal/core/shared"
	"github.com/google/uuid"
	"time"
)

type MedicationCreateRequest struct {
	Name         string              `json:"name"                    validate:"required,min=2"`
	Description  *string             `json:"description,omitempty"   validate:"omitempty,min=2"`
	Manufacturer *string             `json:"manufacturer,omitempty"  validate:"omitempty"`
	Form         string              `json:"form"                    validate:"required,oneof=tablet capsule syrup drop injection"`
	PillsPerBox  int                 `json:"pills_per_box"           validate:"required,min=1"`
	StrengthMg   int                 `json:"strength_mg"             validate:"required,gt=0"`
	MealRelation shared.MealRelation `json:"meal_relation"           validate:"required,oneof=before_meal after_meal with_meal irrelevant"`
}

type MedicationUpdateRequest struct {
	Name         *string              `json:"name,omitempty"          validate:"omitempty,min=2"`
	Form         *string              `json:"form,omitempty"          validate:"omitempty,oneof=tablet capsule syrup drop injection"`
	StrengthMg   *int                 `json:"strength_mg,omitempty"   validate:"omitempty,gt=0"`
	MealRelation *shared.MealRelation `json:"meal_relation,omitempty" validate:"omitempty,oneof=before_meal after_meal with_meal irrelevant"`
	Manufacturer *string              `json:"manufacturer,omitempty"  validate:"omitempty,min=2"`
	Description  *string              `json:"description,omitempty"   validate:"omitempty,min=2"`
}

type MedicationResponse struct {
	ID           uuid.UUID           `json:"id"`
	Name         string              `json:"name"`
	Description  *string             `json:"description"`
	Manufacturer *string             `json:"manufacturer"`
	Form         string              `json:"form"`
	StrengthMg   int                 `json:"strength_mg"`
	PillsPerBox  int                 `json:"pills_per_box"`
	MealRelation shared.MealRelation `json:"meal_relation"`
	CreatedAt    time.Time           `json:"created_at"`
}
