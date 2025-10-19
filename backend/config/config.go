package config

import "os"

var (
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	JWTSecret  string
	ServerPort string
)

func Load() {
	DBHost = getEnv("DB_HOST", "localhost")
	DBPort = getEnv("DB_PORT", "5432")
	DBUser = getEnv("DB_USER", "doselog_user")
	DBPassword = getEnv("DB_PASSWORD", "doselog_pass")
	DBName = getEnv("DB_NAME", "doselog_db")
	JWTSecret = getEnv("JWT_SECRET", "your-secret-key-change-this-in-production")
	ServerPort = getEnv("SERVER_PORT", "8080")
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
