package handler

import (
	"DoseLog/internal/service"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MedicationLogHandler struct {
	medicationLogService *service.MedicationLogService
}

func NewMedicationLogHandler(medicationLogService *service.MedicationLogService) *MedicationLogHandler {
	return &MedicationLogHandler{
		medicationLogService: medicationLogService,
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
// @Failure      500 {object} map[string]string
// @Router       /medication-logs/{id}/mark-taken [put]
func (h *MedicationLogHandler) MarkAsTaken(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid medication log id"})
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
// @Failure      500 {object} map[string]string
// @Router       /medication-logs/user-medication/{user_medication_id} [get]
func (h *MedicationLogHandler) GetByUserMedicationID(c *gin.Context) {
	userMedicationID, err := uuid.Parse(c.Param("user_medication_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user medication id"})
		return
	}

	logs, err := h.medicationLogService.GetByUserMedicationID(c.Request.Context(), userMedicationID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, logs)
}
