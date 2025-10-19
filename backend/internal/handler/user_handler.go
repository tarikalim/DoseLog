package handler

import (
	"backend/internal/service"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type UserHandler struct {
	userService *service.UserService
}

func NewUserHandler(userService *service.UserService) *UserHandler {
	return &UserHandler{
		userService: userService,
	}
}

// GetMe godoc
// @Summary      Get current user
// @Description  Get authenticated user information
// @Tags         users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.UserResponse
// @Failure      401 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /me [get]
func (h *UserHandler) GetMe(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	user, err := h.userService.GetByID(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, user)
}
