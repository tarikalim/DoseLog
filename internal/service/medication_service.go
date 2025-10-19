package service

import (
	"DoseLog/internal/core/dto"
	"DoseLog/internal/core/mapper"
	"context"
	"fmt"

	"github.com/google/uuid"
)

type MedicationService struct {
	medicationRepo MedicationRepository
}

func NewMedicationService(medicationRepo MedicationRepository) *MedicationService {
	return &MedicationService{
		medicationRepo: medicationRepo,
	}
}

func (s *MedicationService) Create(ctx context.Context, req *dto.MedicationCreateRequest) (*dto.MedicationResponse, error) {
	existingMed, err := s.medicationRepo.GetByName(ctx, req.Name)
	if err != nil {
		return nil, err
	}
	if existingMed != nil {
		return nil, fmt.Errorf("medication already exists with name: %s", req.Name)
	}

	medication := mapper.MedicationToEntity(req)

	if err := s.medicationRepo.Create(ctx, medication); err != nil {
		return nil, fmt.Errorf("failed to create medication: %w", err)
	}

	return mapper.MedicationFromEntity(medication), nil
}

func (s *MedicationService) Update(ctx context.Context, id uuid.UUID, req *dto.MedicationUpdateRequest) (*dto.MedicationResponse, error) {
	medication, err := s.medicationRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get medication: %w", err)
	}
	if medication == nil {
		return nil, fmt.Errorf("medication not found with id: %s", id)
	}

	mapper.UpdateMedicationEntity(medication, req)

	if err := s.medicationRepo.Update(ctx, medication); err != nil {
		return nil, fmt.Errorf("failed to update medication: %w", err)
	}

	return mapper.MedicationFromEntity(medication), nil
}

func (s *MedicationService) GetByID(ctx context.Context, id uuid.UUID) (*dto.MedicationResponse, error) {
	medication, err := s.medicationRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get medication by id: %w", err)
	}
	if medication == nil {
		return nil, fmt.Errorf("medication not found with id: %s", id)
	}

	return mapper.MedicationFromEntity(medication), nil
}

func (s *MedicationService) List(ctx context.Context, limit, offset int) ([]*dto.MedicationResponse, error) {
	medications, err := s.medicationRepo.List(ctx, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list medications: %w", err)
	}

	responses := make([]*dto.MedicationResponse, len(medications))
	for i, med := range medications {
		responses[i] = mapper.MedicationFromEntity(med)
	}

	return responses, nil
}
