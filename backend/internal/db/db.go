package db

import (
	"backend/config"
	"fmt"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

var DB *sqlx.DB

func Connect() error {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		config.DBHost,
		config.DBPort,
		config.DBUser,
		config.DBPassword,
		config.DBName,
	)

	db, err := sqlx.Connect("postgres", dsn)
	if err != nil {
		return err
	}

	DB = db
	return nil
}

func GetDB() *sqlx.DB {
	return DB
}

func Close() {
	if DB != nil {
		DB.Close()
	}
}
