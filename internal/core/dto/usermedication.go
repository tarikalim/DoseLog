package dto

import (
	"DoseLog/internal/core/shared"
	"github.com/google/uuid"
	"time"
)

type IntakeSchedule struct {
	TimeSlot   shared.TimeSlot `json:"time_slot"   validate:"required,oneof=morning noon evening night"`
	DoseAmount float64         `json:"dose_amount" validate:"required,gt=0"`
}

type UserMedicationCreateRequest struct {
	MedicationID uuid.UUID        `json:"medication_id" validate:"required"`
	BoxesOwned   int              `json:"boxes_owned"   validate:"required,min=1"`
	Schedules    []IntakeSchedule `json:"schedules"     validate:"required,min=1,dive"`
}

type UserMedicationUpdateRequest struct {
	BoxesOwned *int              `json:"boxes_owned,omitempty" validate:"omitempty,min=1"`
	Schedules  *[]IntakeSchedule `json:"schedules,omitempty"   validate:"omitempty,min=1,dive"`
	Active     *bool             `json:"active,omitempty"`
}

type UserMedicationResponse struct {
	ID           uuid.UUID        `json:"id"`
	UserID       uuid.UUID        `json:"user_id"`
	MedicationID uuid.UUID        `json:"medication_id"`
	BoxesOwned   int              `json:"boxes_owned"`
	Schedules    []IntakeSchedule `json:"schedules"`
	StartAt      time.Time        `json:"start_at"`
	Active       bool             `json:"active"`
	CreatedAt    time.Time        `json:"created_at"`
}
