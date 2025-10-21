package handler

import (
	"backend/internal/auth"
	"backend/internal/service"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MedicationLogHandler struct {
	medicationLogService  *service.MedicationLogService
	userMedicationService *service.UserMedicationService
}

func NewMedicationLogHandler(medicationLogService *service.MedicationLogService, userMedicationService *service.UserMedicationService) *MedicationLogHandler {
	return &MedicationLogHandler{
		medicationLogService:  medicationLogService,
		userMedicationService: userMedicationService,
	}
}

// MarkAsTaken godoc
// @Summary      Mark dose as taken
// @Description  Mark a medication log as taken
// @Tags         medication-logs
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "Medication Log ID"
// @Success      200 {object} map[string]string
// @Failure      400 {object} map[string]string
// @Failure      401 {object} map[string]string
// @Failure      403 {object} map[string]string
// @Failure      404 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /medication-logs/{id}/mark-taken [put]
func (h *MedicationLogHandler) MarkAsTaken(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid medication log id"})
		return
	}

	log, err := h.medicationLogService.GetByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if log == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "medication log not found"})
		return
	}

	userMedication, err := h.userMedicationService.GetByID(c.Request.Context(), log.UserMedicationID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if userMedication == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user medication not found"})
		return
	}

	if !auth.RequireResourceOwnership(c, userMedication.UserID) {
		return
	}

	if err := h.medicationLogService.MarkAsTaken(c.Request.Context(), id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "medication log marked as taken"})
}

// GetByUserMedicationID godoc
// @Summary      Get medication logs
// @Description  Get all logs for a user medication tracking
// @Tags         medication-logs
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        user_medication_id path string true "User Medication ID"
// @Success      200 {array} dto.MedicationLogResponse
// @Failure      400 {object} map[string]string
// @Failure      401 {object} map[string]string
// @Failure      403 {object} map[string]string
// @Failure      404 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /medication-logs/user-medication/{user_medication_id} [get]
func (h *MedicationLogHandler) GetByUserMedicationID(c *gin.Context) {
	userMedicationID, err := uuid.Parse(c.Param("user_medication_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user medication id"})
		return
	}

	userMedication, err := h.userMedicationService.GetByID(c.Request.Context(), userMedicationID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if userMedication == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user medication not found"})
		return
	}

	if !auth.RequireResourceOwnership(c, userMedication.UserID) {
		return
	}

	logs, err := h.medicationLogService.GetByUserMedicationID(c.Request.Context(), userMedicationID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, logs)
}
