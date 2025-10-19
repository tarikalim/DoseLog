package dto

import (
	"DoseLog/internal/core/shared"
	"github.com/google/uuid"
	"time"
)

type MedicationLogUpdateRequest struct {
	Taken *bool `json:"taken,omitempty"`
}

type MedicationLogResponse struct {
	ID               uuid.UUID       `json:"id"`
	UserMedicationID uuid.UUID       `json:"user_medication_id"`
	TimeSlot         shared.TimeSlot `json:"time_slot"`
	PlannedDose      float64         `json:"planned_dose"`
	Taken            bool            `json:"taken"`
	Timestamp        time.Time       `json:"timestamp"`
}
