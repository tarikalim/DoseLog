package mapper

import (
	"DoseLog/internal/core/dto"
	"DoseLog/internal/core/entity"
	"github.com/google/uuid"
	"time"
)

// UserToEntity converts UserCreateRequest to User entity with hashed password
func UserToEntity(req *dto.UserCreateRequest, hashedPassword string) *entity.User {
	return &entity.User{
		ID:        uuid.New(),
		Email:     req.Email,
		Password:  hashedPassword,
		CreatedAt: time.Now(),
	}
}

// UserFromEntity converts User entity to UserResponse
func UserFromEntity(user *entity.User) *dto.UserResponse {
	return &dto.UserResponse{
		ID:        user.ID,
		Email:     user.Email,
		CreatedAt: user.CreatedAt,
	}
}
