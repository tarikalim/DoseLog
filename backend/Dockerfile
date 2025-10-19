# Build stage
FROM golang:1.25-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY backend/go.mod backend/go.sum ./
RUN go mod download

COPY backend/ .

RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/server ./cmd/main.go

# Final stage
FROM alpine:latest

COPY --from=builder /bin/server /bin/server

ENTRYPOINT ["/bin/server"]