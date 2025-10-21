package dto

import (
	"backend/internal/core/shared"
	"time"

	"github.com/google/uuid"
)

type IntakeSchedule struct {
	TimeSlot   shared.TimeSlot `json:"time_slot"   validate:"required,oneof=morning noon evening night"`
	DoseAmount float64         `json:"dose_amount" validate:"required,gt=0"`
}

type UserMedicationCreateRequest struct {
	MedicationID uuid.UUID        `json:"medication_id" validate:"required"`
	BoxesOwned   int              `json:"boxes_owned"   validate:"required,min=1"`
	Schedules    []IntakeSchedule `json:"schedules"     validate:"required,min=1,dive"`
	DurationDays int              `json:"duration_days" validate:"required,min=1"`
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
	DurationDays int              `json:"duration_days"`
	StartAt      time.Time        `json:"start_at"`
	Active       bool             `json:"active"`
	CreatedAt    time.Time        `json:"created_at"`
}

type UserMedicationStatsResponse struct {
	TotalPills             int       `json:"total_pills"`
	UsedPills              float64   `json:"used_pills"`
	RemainingPills         float64   `json:"remaining_pills"`
	DailyConsumption       float64   `json:"daily_consumption"`
	EstimatedDaysRemaining int       `json:"estimated_days_remaining"`
	EstimatedEndDate       time.Time `json:"estimated_end_date"`
	PlannedDurationDays    int       `json:"planned_duration_days"`
	DaysElapsed            int       `json:"days_elapsed"`
	PlannedDaysRemaining   int       `json:"planned_days_remaining"`
	WarningLevel           string    `json:"warning_level"` // "normal", "warning", "critical"
}
