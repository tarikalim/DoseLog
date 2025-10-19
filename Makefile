.PHONY: help generate-protos generate-docs setup run build

help:
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

sec: ## Run go security check
	@echo "Running security check"
	@gosec ./...

.PHONY: generate-docs
generate-docs: ## Generate Swagger documentation
	@echo "Generating Swagger documentation..."
	@./scripts/generate-swagger.sh

.PHONY: setup
setup: ## Install dependencies and setup the project
	@echo "Installing Go dependencies..."
	@go mod download
	@go mod tidy
	@echo "Dependencies installed successfully!"

.PHONY: run
run: ## Run the development server
	@echo "Running server..."
	@go run ./cmd/main.go

.PHONY: build
build: ## Build the server binary
	@echo "Building server..."
	@go build -o bin/doselog ./cmd/main.go
	@echo "Build completed. Binary available at: bin/doselog"


install-air: ## Install air for live reloading
	@echo "Installing air for $(OS)..."
	@go install github.com/air-verse/air@latest
	@echo "Air installed successfully"

run-dev: ## Download air and run server with air
	@echo "Installing air for $(OS)..."
	@go install github.com/air-verse/air@latest
	@echo "Air installed successfully"
	@echo "Starting development server with air..."
ifeq ($(OS),windows)
	@air -c air/windows.toml
else
	@air -c air/unix.toml
endif