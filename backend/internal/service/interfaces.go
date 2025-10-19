package service

import (
	entity2 "backend/internal/core/entity"
	"context"
	"time"

	"github.com/google/uuid"
)

// UserRepository defines the user data access methods needed by UserService
type UserRepository interface {
	Create(ctx context.Context, user *entity2.User) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity2.User, error)
	GetByEmail(ctx context.Context, email string) (*entity2.User, error)
}

// MedicationRepository defines the medication data access methods needed by MedicationService
type MedicationRepository interface {
	Create(ctx context.Context, med *entity2.Medication) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity2.Medication, error)
	GetByName(ctx context.Context, name string) (*entity2.Medication, error)
	Update(ctx context.Context, med *entity2.Medication) error
	List(ctx context.Context, limit, offset int) ([]*entity2.Medication, error)
}

// UserMedicationRepository defines the user medication data access methods needed by UserMedicationService
type UserMedicationRepository interface {
	Create(ctx context.Context, um *entity2.UserMedication) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity2.UserMedication, error)
	GetByUserID(ctx context.Context, userID uuid.UUID) ([]*entity2.UserMedication, error)
	GetActiveByUserID(ctx context.Context, userID uuid.UUID) ([]*entity2.UserMedication, error)
	Update(ctx context.Context, um *entity2.UserMedication) error
}

// MedicationLogRepository defines the medication log data access methods needed by MedicationLogService
type MedicationLogRepository interface {
	Create(ctx context.Context, log *entity2.MedicationLog) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity2.MedicationLog, error)
	GetByUserMedicationID(ctx context.Context, userMedicationID uuid.UUID) ([]*entity2.MedicationLog, error)
	GetByUserMedicationIDAndDateRange(ctx context.Context, userMedicationID uuid.UUID, start, end time.Time) ([]*entity2.MedicationLog, error)
	Update(ctx context.Context, log *entity2.MedicationLog) error
}
