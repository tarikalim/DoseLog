package service

import (
	"backend/internal/core/dto"
	"backend/internal/core/mapper"
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
)

type UserMedicationService struct {
	userMedicationRepo   UserMedicationRepository
	medicationService    *MedicationService
	medicationLogService *MedicationLogService
}

func NewUserMedicationService(userMedicationRepo UserMedicationRepository, medicationService *MedicationService, medicationLogService *MedicationLogService) *UserMedicationService {
	return &UserMedicationService{
		userMedicationRepo:   userMedicationRepo,
		medicationService:    medicationService,
		medicationLogService: medicationLogService,
	}
}

func (s *UserMedicationService) GetByID(ctx context.Context, id uuid.UUID) (*dto.UserMedicationResponse, error) {
	userMedication, err := s.userMedicationRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get user medication: %w", err)
	}
	if userMedication == nil {
		return nil, nil
	}
	return mapper.UserMedicationFromEntity(userMedication), nil
}

func (s *UserMedicationService) Create(ctx context.Context, userID uuid.UUID, req *dto.UserMedicationCreateRequest) (*dto.UserMedicationResponse, error) {
	medication, err := s.medicationService.GetByID(ctx, req.MedicationID)
	if err != nil {
		return nil, fmt.Errorf("failed to get medication: %w", err)
	}

	totalPills := req.BoxesOwned * medication.PillsPerBox
	var dailyConsumption float64
	for _, schedule := range req.Schedules {
		dailyConsumption += schedule.DoseAmount
	}

	maxDays := int(float64(totalPills) / dailyConsumption)

	if req.DurationDays > maxDays {
		return nil, fmt.Errorf("insufficient medication: you have %d pills (%.1f pills/day), maximum %d days available, but requested %d days",
			totalPills, dailyConsumption, maxDays, req.DurationDays)
	}

	userMedication := mapper.UserMedicationToEntity(userID, req)

	if err := s.userMedicationRepo.Create(ctx, userMedication); err != nil {
		return nil, fmt.Errorf("failed to create user medication: %w", err)
	}

	if err := s.medicationLogService.CreateLogsForUserMedication(ctx, userMedication, req.DurationDays); err != nil {
		return nil, fmt.Errorf("failed to generate medication logs: %w", err)
	}

	return mapper.UserMedicationFromEntity(userMedication), nil
}

func (s *UserMedicationService) Update(ctx context.Context, id uuid.UUID, req *dto.UserMedicationUpdateRequest) (*dto.UserMedicationResponse, error) {
	userMedication, err := s.userMedicationRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get user medication: %w", err)
	}
	if userMedication == nil {
		return nil, fmt.Errorf("user medication not found with id: %s", id)
	}

	mapper.UpdateUserMedicationEntity(userMedication, req)

	if err := s.userMedicationRepo.Update(ctx, userMedication); err != nil {
		return nil, fmt.Errorf("failed to update user medication: %w", err)
	}

	return mapper.UserMedicationFromEntity(userMedication), nil
}

func (s *UserMedicationService) GetByUserID(ctx context.Context, userID uuid.UUID) ([]*dto.UserMedicationResponse, error) {
	userMedications, err := s.userMedicationRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to get user medications: %w", err)
	}

	responses := make([]*dto.UserMedicationResponse, len(userMedications))
	for i, um := range userMedications {
		responses[i] = mapper.UserMedicationFromEntity(um)
	}

	return responses, nil
}

func (s *UserMedicationService) GetActiveByUserID(ctx context.Context, userID uuid.UUID) ([]*dto.UserMedicationResponse, error) {
	userMedications, err := s.userMedicationRepo.GetActiveByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to get active user medications: %w", err)
	}

	responses := make([]*dto.UserMedicationResponse, len(userMedications))
	for i, um := range userMedications {
		responses[i] = mapper.UserMedicationFromEntity(um)
	}

	return responses, nil
}

func (s *UserMedicationService) GetStats(ctx context.Context, id uuid.UUID) (*dto.UserMedicationStatsResponse, error) {
	userMedication, err := s.userMedicationRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get user medication: %w", err)
	}
	if userMedication == nil {
		return nil, fmt.Errorf("user medication not found with id: %s", id)
	}

	medication, err := s.medicationService.GetByID(ctx, userMedication.MedicationID)
	if err != nil {
		return nil, fmt.Errorf("failed to get medication: %w", err)
	}

	logs, err := s.medicationLogService.GetByUserMedicationID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get logs: %w", err)
	}

	totalPills := userMedication.BoxesOwned * medication.PillsPerBox

	var dailyConsumption float64
	for _, schedule := range userMedication.Schedules {
		dailyConsumption += schedule.DoseAmount
	}

	var usedPills float64
	for _, log := range logs {
		if log.Taken {
			usedPills += log.PlannedDose
		}
	}

	remainingPills := float64(totalPills) - usedPills

	var estimatedDaysRemaining int
	var estimatedEndDate time.Time
	if dailyConsumption > 0 {
		estimatedDaysRemaining = int(remainingPills / dailyConsumption)
		estimatedEndDate = time.Now().AddDate(0, 0, estimatedDaysRemaining)
	}

	warningLevel := "normal"
	if remainingPills <= 10 {
		warningLevel = "critical"
	} else if remainingPills <= 20 {
		warningLevel = "warning"
	}

	daysElapsed := int(time.Since(userMedication.StartAt).Hours() / 24)
	plannedDaysRemaining := userMedication.DurationDays - daysElapsed
	if plannedDaysRemaining < 0 {
		plannedDaysRemaining = 0
	}

	return &dto.UserMedicationStatsResponse{
		TotalPills:             totalPills,
		UsedPills:              usedPills,
		RemainingPills:         remainingPills,
		DailyConsumption:       dailyConsumption,
		EstimatedDaysRemaining: estimatedDaysRemaining,
		EstimatedEndDate:       estimatedEndDate,
		PlannedDurationDays:    userMedication.DurationDays,
		DaysElapsed:            daysElapsed,
		PlannedDaysRemaining:   plannedDaysRemaining,
		WarningLevel:           warningLevel,
	}, nil
}
