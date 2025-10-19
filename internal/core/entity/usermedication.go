package entity

import (
	"DoseLog/internal/core/shared"
	"github.com/google/uuid"
	"time"
)

type IntakeSchedule struct {
	TimeSlot   shared.TimeSlot `json:"time_slot"`
	DoseAmount float64         `json:"dose_amount"`
}

type UserMedication struct {
	ID           uuid.UUID        `db:"id"`
	UserID       uuid.UUID        `db:"user_id"`
	MedicationID uuid.UUID        `db:"medication_id"`
	BoxesOwned   int              `db:"boxes_owned"`
	Schedules    []IntakeSchedule `db:"schedules"`
	StartAt      time.Time        `db:"start_at"`
	Active       bool             `db:"active"`
	CreatedAt    time.Time        `db:"created_at"`
}
