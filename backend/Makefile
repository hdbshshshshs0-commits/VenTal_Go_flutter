include .env
export

.PHONY: run build tidy migrate

run:
	go run ./cmd/api

build:
	go build -o bin/api ./cmd/api

tidy:
	go mod tidy

migrate:
	@echo "Migrations run automatically on startup"

# Docker shortcuts for local dev
db-up:
	docker run -d --name vental-pg \
		-e POSTGRES_DB=vental_go \
		-e POSTGRES_USER=vental \
		-e POSTGRES_PASSWORD=vental \
		-p 5432:5432 \
		postgis/postgis:16-3.4

db-down:
	docker stop vental-pg && docker rm vental-pg

db-psql:
	docker exec -it vental-pg psql -U vental -d vental_go
