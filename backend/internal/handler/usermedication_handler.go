package handler

import (
	"backend/internal/core/dto"
	"backend/internal/service"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type UserMedicationHandler struct {
	userMedicationService *service.UserMedicationService
}

func NewUserMedicationHandler(userMedicationService *service.UserMedicationService) *UserMedicationHandler {
	return &UserMedicationHandler{
		userMedicationService: userMedicationService,
	}
}

// Create godoc
// @Summary      Start medication tracking
// @Description  Create user medication tracking with schedules
// @Tags         user-medications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.UserMedicationCreateRequest true "Tracking details"
// @Success      201 {object} dto.UserMedicationResponse
// @Failure      400 {object} map[string]string
// @Failure      401 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /user-medications [post]
func (h *UserMedicationHandler) Create(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var req dto.UserMedicationCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userMedication, err := h.userMedicationService.Create(c.Request.Context(), userID.(uuid.UUID), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, userMedication)
}

// Update godoc
// @Summary      Update medication tracking
// @Description  Update user medication tracking details
// @Tags         user-medications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "User Medication ID"
// @Param        request body dto.UserMedicationUpdateRequest true "Updated tracking details"
// @Success      200 {object} dto.UserMedicationResponse
// @Failure      400 {object} map[string]string
// @Failure      401 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /user-medications/{id} [put]
func (h *UserMedicationHandler) Update(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user medication id"})
		return
	}

	var req dto.UserMedicationUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userMedication, err := h.userMedicationService.Update(c.Request.Context(), id, &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, userMedication)
}

// GetByUserID godoc
// @Summary      Get user medications
// @Description  Get all medication trackings for current user
// @Tags         user-medications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200 {array} dto.UserMedicationResponse
// @Failure      401 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /user-medications [get]
func (h *UserMedicationHandler) GetByUserID(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	userMedications, err := h.userMedicationService.GetByUserID(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, userMedications)
}

// GetActiveByUserID godoc
// @Summary      Get active user medications
// @Description  Get active medication trackings for current user
// @Tags         user-medications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200 {array} dto.UserMedicationResponse
// @Failure      401 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /user-medications/active [get]
func (h *UserMedicationHandler) GetActiveByUserID(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	userMedications, err := h.userMedicationService.GetActiveByUserID(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, userMedications)
}

// GetStats godoc
// @Summary      Get medication statistics
// @Description  Get detailed statistics about medication usage and remaining pills
// @Tags         user-medications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "User Medication ID"
// @Success      200 {object} dto.UserMedicationStatsResponse
// @Failure      400 {object} map[string]string
// @Failure      401 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /user-medications/{id}/stats [get]
func (h *UserMedicationHandler) GetStats(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user medication id"})
		return
	}

	stats, err := h.userMedicationService.GetStats(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, stats)
}
