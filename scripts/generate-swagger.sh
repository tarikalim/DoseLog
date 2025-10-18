#!/bin/bash

# Check if swag is installed
if ! command -v swag &> /dev/null; then
    echo "Installing swag..."
    go install github.com/swaggo/swag/cmd/swag@latest
fi

# Generate swagger documentation
echo "Generating swagger documentation..."
swag init \
    --parseDependency \
    --parseInternal \
    --parseDepth 2 \
    --output ./docs \
    --dir ./pkg/servers/rest \
    --generalInfo rest.go \
    --propertyStrategy camelcase \
    --parseFuncBody

echo "Swagger documentation generated successfully!"