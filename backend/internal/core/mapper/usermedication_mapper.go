package mapper

import (
	"backend/internal/core/dto"
	"backend/internal/core/entity"
	"time"

	"github.com/google/uuid"
)

// UserMedicationToEntity converts UserMedicationCreateRequest to UserMedication entity
func UserMedicationToEntity(userID uuid.UUID, req *dto.UserMedicationCreateRequest) *entity.UserMedication {
	schedules := make([]entity.IntakeSchedule, len(req.Schedules))
	for i, s := range req.Schedules {
		schedules[i] = entity.IntakeSchedule{
			TimeSlot:   s.TimeSlot,
			DoseAmount: s.DoseAmount,
		}
	}

	return &entity.UserMedication{
		ID:           uuid.New(),
		UserID:       userID,
		MedicationID: req.MedicationID,
		BoxesOwned:   req.BoxesOwned,
		Schedules:    schedules,
		StartAt:      time.Now(),
		Active:       true,
		CreatedAt:    time.Now(),
	}
}

// UserMedicationFromEntity converts UserMedication entity to UserMedicationResponse
func UserMedicationFromEntity(um *entity.UserMedication) *dto.UserMedicationResponse {
	schedules := make([]dto.IntakeSchedule, len(um.Schedules))
	for i, s := range um.Schedules {
		schedules[i] = dto.IntakeSchedule{
			TimeSlot:   s.TimeSlot,
			DoseAmount: s.DoseAmount,
		}
	}

	return &dto.UserMedicationResponse{
		ID:           um.ID,
		UserID:       um.UserID,
		MedicationID: um.MedicationID,
		BoxesOwned:   um.BoxesOwned,
		Schedules:    schedules,
		StartAt:      um.StartAt,
		Active:       um.Active,
		CreatedAt:    um.CreatedAt,
	}
}

// UpdateUserMedicationEntity applies UserMedicationUpdateRequest to existing UserMedication entity
func UpdateUserMedicationEntity(um *entity.UserMedication, req *dto.UserMedicationUpdateRequest) {
	if req.BoxesOwned != nil {
		um.BoxesOwned = *req.BoxesOwned
	}
	if req.Schedules != nil {
		schedules := make([]entity.IntakeSchedule, len(*req.Schedules))
		for i, s := range *req.Schedules {
			schedules[i] = entity.IntakeSchedule{
				TimeSlot:   s.TimeSlot,
				DoseAmount: s.DoseAmount,
			}
		}
		um.Schedules = schedules
	}
	if req.Active != nil {
		um.Active = *req.Active
	}
}
