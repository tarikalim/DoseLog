package mapper

import (
	"backend/internal/core/dto"
	"backend/internal/core/entity"
)

// MedicationLogFromEntity converts MedicationLog entity to MedicationLogResponse
func MedicationLogFromEntity(log *entity.MedicationLog) *dto.MedicationLogResponse {
	return &dto.MedicationLogResponse{
		ID:               log.ID,
		UserMedicationID: log.UserMedicationID,
		TimeSlot:         log.TimeSlot,
		PlannedDose:      log.PlannedDose,
		Taken:            log.Taken,
		Timestamp:        log.Timestamp,
	}
}

// UpdateMedicationLogEntity applies MedicationLogUpdateRequest to existing MedicationLog entity
func UpdateMedicationLogEntity(log *entity.MedicationLog, req *dto.MedicationLogUpdateRequest) {
	if req.Taken != nil {
		log.Taken = *req.Taken
	}
}
