#!/bin/bash

# Check if swag is installed
if ! command -v swag &> /dev/null; then
    echo "Installing swag..."
    go install github.com/swaggo/swag/cmd/swag@latest
fi

# Use go run to execute swag if not in PATH
SWAG_CMD="swag"
if ! command -v swag &> /dev/null; then
    SWAG_CMD="$(go env GOPATH)/bin/swag"
fi

# Generate swagger documentation
echo "Generating swagger documentation..."
$SWAG_CMD init \
    --parseDependency \
    --parseInternal \
    --parseDepth 2 \
    --output ./docs \
    --dir ./cmd,./internal/handler \
    --generalInfo main.go \
    --propertyStrategy camelcase \
    --parseFuncBody

echo "Swagger documentation generated successfully!"