package service

import (
	"DoseLog/internal/core/entity"
	"context"
	"time"

	"github.com/google/uuid"
)

// UserRepository defines the user data access methods needed by UserService
type UserRepository interface {
	Create(ctx context.Context, user *entity.User) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.User, error)
	GetByEmail(ctx context.Context, email string) (*entity.User, error)
}

// MedicationRepository defines the medication data access methods needed by MedicationService
type MedicationRepository interface {
	Create(ctx context.Context, med *entity.Medication) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.Medication, error)
	GetByName(ctx context.Context, name string) (*entity.Medication, error)
	Update(ctx context.Context, med *entity.Medication) error
	List(ctx context.Context, limit, offset int) ([]*entity.Medication, error)
}

// UserMedicationRepository defines the user medication data access methods needed by UserMedicationService
type UserMedicationRepository interface {
	Create(ctx context.Context, um *entity.UserMedication) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.UserMedication, error)
	GetByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.UserMedication, error)
	GetActiveByUserID(ctx context.Context, userID uuid.UUID) ([]*entity.UserMedication, error)
	Update(ctx context.Context, um *entity.UserMedication) error
}

// MedicationLogRepository defines the medication log data access methods needed by MedicationLogService
type MedicationLogRepository interface {
	Create(ctx context.Context, log *entity.MedicationLog) error
	GetByID(ctx context.Context, id uuid.UUID) (*entity.MedicationLog, error)
	GetByUserMedicationID(ctx context.Context, userMedicationID uuid.UUID) ([]*entity.MedicationLog, error)
	GetByUserMedicationIDAndDateRange(ctx context.Context, userMedicationID uuid.UUID, start, end time.Time) ([]*entity.MedicationLog, error)
	Update(ctx context.Context, log *entity.MedicationLog) error
}
