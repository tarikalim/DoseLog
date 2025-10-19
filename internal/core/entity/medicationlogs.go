package entity

import (
	"DoseLog/internal/core/shared"
	"github.com/google/uuid"
	"time"
)

type MedicationLog struct {
	ID               uuid.UUID       `db:"id"`
	UserMedicationID uuid.UUID       `db:"user_medication_id"`
	TimeSlot         shared.TimeSlot `db:"time_slot"`
	PlannedDose      float64         `db:"planned_dose"`
	Taken            bool            `db:"taken"`
	Timestamp        time.Time       `db:"timestamp"`
}
