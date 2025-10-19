package mapper

import (
	"backend/internal/core/dto"
	"backend/internal/core/entity"
	"time"

	"github.com/google/uuid"
)

// MedicationToEntity converts MedicationCreateRequest to Medication entity
func MedicationToEntity(req *dto.MedicationCreateRequest) *entity.Medication {
	return &entity.Medication{
		ID:           uuid.New(),
		Name:         req.Name,
		Description:  req.Description,
		Manufacturer: req.Manufacturer,
		Form:         req.Form,
		StrengthMg:   float32(req.StrengthMg),
		PillsPerBox:  req.PillsPerBox,
		MealRelation: req.MealRelation,
		CreatedAt:    time.Now(),
	}
}

// MedicationFromEntity converts Medication entity to MedicationResponse
func MedicationFromEntity(med *entity.Medication) *dto.MedicationResponse {
	return &dto.MedicationResponse{
		ID:           med.ID,
		Name:         med.Name,
		Description:  med.Description,
		Manufacturer: med.Manufacturer,
		Form:         med.Form,
		StrengthMg:   int(med.StrengthMg),
		PillsPerBox:  med.PillsPerBox,
		MealRelation: med.MealRelation,
		CreatedAt:    med.CreatedAt,
	}
}

// UpdateMedicationEntity applies MedicationUpdateRequest to existing Medication entity
func UpdateMedicationEntity(med *entity.Medication, req *dto.MedicationUpdateRequest) {
	if req.Name != nil {
		med.Name = *req.Name
	}
	if req.Form != nil {
		med.Form = *req.Form
	}
	if req.StrengthMg != nil {
		med.StrengthMg = float32(*req.StrengthMg)
	}
	if req.MealRelation != nil {
		med.MealRelation = *req.MealRelation
	}
	if req.Manufacturer != nil {
		med.Manufacturer = req.Manufacturer
	}
	if req.Description != nil {
		med.Description = req.Description
	}
}
