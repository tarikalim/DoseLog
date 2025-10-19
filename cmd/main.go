package main

import (
	"DoseLog/config"
	"DoseLog/internal/db"
	"DoseLog/internal/handler"
	"log"
)

// @title           DoseLog API
// @version         1.0
// @description     Medication tracking and dose logging API
// @termsOfService  http://swagger.io/terms/
// @BasePath  /api
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

func main() {
	config.Load()

	if err := db.Connect(); err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	router := handler.SetupRouter()

	log.Printf("Server starting on port %s", config.ServerPort)
	if err := router.Run(":" + config.ServerPort); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
