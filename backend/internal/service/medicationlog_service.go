package service

import (
	"backend/internal/core/dto"
	entity2 "backend/internal/core/entity"
	"backend/internal/core/mapper"
	"context"
	"fmt"

	"github.com/google/uuid"
)

type MedicationLogService struct {
	medicationLogRepo MedicationLogRepository
}

func NewMedicationLogService(medicationLogRepo MedicationLogRepository) *MedicationLogService {
	return &MedicationLogService{
		medicationLogRepo: medicationLogRepo,
	}
}

func (s *MedicationLogService) GetByID(ctx context.Context, id uuid.UUID) (*dto.MedicationLogResponse, error) {
	log, err := s.medicationLogRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get medication log: %w", err)
	}
	if log == nil {
		return nil, nil
	}
	return mapper.MedicationLogFromEntity(log), nil
}

func (s *MedicationLogService) MarkAsTaken(ctx context.Context, id uuid.UUID) error {
	log, err := s.medicationLogRepo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to get medication log: %w", err)
	}
	if log == nil {
		return fmt.Errorf("medication log not found with id: %s", id)
	}

	log.Taken = true

	if err := s.medicationLogRepo.Update(ctx, log); err != nil {
		return fmt.Errorf("failed to mark medication log as taken: %w", err)
	}

	return nil
}

func (s *MedicationLogService) GetByUserMedicationID(ctx context.Context, userMedicationID uuid.UUID) ([]*dto.MedicationLogResponse, error) {
	logs, err := s.medicationLogRepo.GetByUserMedicationID(ctx, userMedicationID)
	if err != nil {
		return nil, fmt.Errorf("failed to get medication logs: %w", err)
	}

	responses := make([]*dto.MedicationLogResponse, len(logs))
	for i, log := range logs {
		responses[i] = mapper.MedicationLogFromEntity(log)
	}

	return responses, nil
}

func (s *MedicationLogService) CreateLogsForUserMedication(ctx context.Context, um *entity2.UserMedication, durationDays int) error {
	endDate := um.StartAt.AddDate(0, 0, durationDays)

	for d := um.StartAt; d.Before(endDate); d = d.AddDate(0, 0, 1) {
		for _, schedule := range um.Schedules {
			log := &entity2.MedicationLog{
				ID:               uuid.New(),
				UserMedicationID: um.ID,
				TimeSlot:         schedule.TimeSlot,
				PlannedDose:      schedule.DoseAmount,
				Taken:            false,
				Timestamp:        d,
			}

			if err := s.medicationLogRepo.Create(ctx, log); err != nil {
				return fmt.Errorf("failed to create medication log: %w", err)
			}
		}
	}

	return nil
}
