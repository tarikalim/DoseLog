package handler

import (
	"backend/internal/auth"
	"backend/internal/db"
	repository2 "backend/internal/repository"
	service2 "backend/internal/service"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	_ "backend/docs"
)

func SetupRouter() *gin.Engine {
	router := gin.Default()

	database := db.GetDB()

	userRepo := repository2.NewUserRepository(database)
	medicationRepo := repository2.NewMedicationRepository(database)
	userMedicationRepo := repository2.NewUserMedicationRepository(database)
	medicationLogRepo := repository2.NewMedicationLogRepository(database)

	userService := service2.NewUserService(userRepo)
	authService := service2.NewAuthService(userRepo)
	medicationService := service2.NewMedicationService(medicationRepo)
	medicationLogService := service2.NewMedicationLogService(medicationLogRepo)
	userMedicationService := service2.NewUserMedicationService(userMedicationRepo, medicationService, medicationLogService)

	authHandler := NewAuthHandler(authService, userService)
	userHandler := NewUserHandler(userService)
	medicationHandler := NewMedicationHandler(medicationService)
	userMedicationHandler := NewUserMedicationHandler(userMedicationService)
	medicationLogHandler := NewMedicationLogHandler(medicationLogService)

	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	api := router.Group("/api")
	{
		authGroup := api.Group("/auth")
		{
			authGroup.POST("/register", authHandler.Register)
			authGroup.POST("/login", authHandler.Login)
		}

		protectedGroup := api.Group("")
		protectedGroup.Use(auth.AuthMiddleware())
		{
			protectedGroup.GET("/me", userHandler.GetMe)

			medicationGroup := protectedGroup.Group("/medications")
			{
				medicationGroup.POST("", medicationHandler.Create)
				medicationGroup.GET("", medicationHandler.List)
				medicationGroup.GET("/:id", medicationHandler.GetByID)
				medicationGroup.PUT("/:id", medicationHandler.Update)
			}

			userMedicationGroup := protectedGroup.Group("/user-medications")
			{
				userMedicationGroup.POST("", userMedicationHandler.Create)
				userMedicationGroup.GET("", userMedicationHandler.GetByUserID)
				userMedicationGroup.GET("/active", userMedicationHandler.GetActiveByUserID)
				userMedicationGroup.PUT("/:id", userMedicationHandler.Update)
				userMedicationGroup.GET("/:id/stats", userMedicationHandler.GetStats)
			}

			medicationLogGroup := protectedGroup.Group("/medication-logs")
			{
				medicationLogGroup.PUT("/:id/mark-taken", medicationLogHandler.MarkAsTaken)
				medicationLogGroup.GET("/user-medication/:user_medication_id", medicationLogHandler.GetByUserMedicationID)
			}
		}
	}

	return router
}
