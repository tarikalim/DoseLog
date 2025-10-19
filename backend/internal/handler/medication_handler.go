package handler

import (
	"backend/internal/core/dto"
	"backend/internal/service"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MedicationHandler struct {
	medicationService *service.MedicationService
}

func NewMedicationHandler(medicationService *service.MedicationService) *MedicationHandler {
	return &MedicationHandler{
		medicationService: medicationService,
	}
}

// Create godoc
// @Summary      Create medication
// @Description  Add a new medication to the system
// @Tags         medications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.MedicationCreateRequest true "Medication details"
// @Success      201 {object} dto.MedicationResponse
// @Failure      400 {object} map[string]string
// @Failure      401 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /medications [post]
func (h *MedicationHandler) Create(c *gin.Context) {
	var req dto.MedicationCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	medication, err := h.medicationService.Create(c.Request.Context(), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, medication)
}

// Update godoc
// @Summary      Update medication
// @Description  Update medication details
// @Tags         medications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "Medication ID"
// @Param        request body dto.MedicationUpdateRequest true "Updated medication details"
// @Success      200 {object} dto.MedicationResponse
// @Failure      400 {object} map[string]string
// @Failure      401 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /medications/{id} [put]
func (h *MedicationHandler) Update(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid medication id"})
		return
	}

	var req dto.MedicationUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	medication, err := h.medicationService.Update(c.Request.Context(), id, &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, medication)
}

// GetByID godoc
// @Summary      Get medication by ID
// @Description  Get medication details by ID
// @Tags         medications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "Medication ID"
// @Success      200 {object} dto.MedicationResponse
// @Failure      400 {object} map[string]string
// @Failure      401 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /medications/{id} [get]
func (h *MedicationHandler) GetByID(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid medication id"})
		return
	}

	medication, err := h.medicationService.GetByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, medication)
}

// List godoc
// @Summary      List medications
// @Description  Get paginated list of medications
// @Tags         medications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        limit query int false "Limit" default(10)
// @Param        offset query int false "Offset" default(0)
// @Success      200 {array} dto.MedicationResponse
// @Failure      401 {object} map[string]string
// @Failure      500 {object} map[string]string
// @Router       /medications [get]
func (h *MedicationHandler) List(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	medications, err := h.medicationService.List(c.Request.Context(), limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, medications)
}
