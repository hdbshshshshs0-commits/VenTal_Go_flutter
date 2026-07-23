# VenTal Go

A Kazakhstan super-app (taxi, food, parcels) with a Flutter mobile frontend and a Go REST backend.

## Project structure

```
vental_go/
├── lib/                    # Flutter app source
│   ├── main.dart
│   ├── app/                # App-level setup (themes, routing)
│   ├── core/               # Core utilities, constants
│   ├── data/               # Models, repositories, API clients
│   ├── features/           # Feature modules (taxi, food, parcels, …)
│   └── shared/             # Shared widgets and helpers
├── backend/                # Go backend (Gin + PostgreSQL)
│   ├── cmd/api/main.go     # Entry point
│   ├── internal/
│   │   ├── config/         # Config loading (env vars)
│   │   ├── db/             # PostgreSQL connection + migrations
│   │   ├── domain/         # Domain models (user, order, trip, …)
│   │   ├── integrations/   # External integrations (FreedomPay, OSM, …)
│   │   └── transport/      # HTTP handlers / routes
│   ├── go.mod
│   └── .env.example        # Required env vars template
├── assets/                 # Images, icons, map styles
├── pubspec.yaml            # Flutter dependencies
└── analysis_options.yaml
```

## Stack

- **Frontend**: Flutter 3 / Dart — MapLibre GL, Provider, Dio, geolocator, flutter_secure_storage
- **Backend**: Go 1.23 — Gin, sqlx, PostgreSQL, JWT, godotenv
- **Map**: MapLibre (offline-capable, OSM-based)

## Running the backend locally

Copy `backend/.env.example` to `backend/.env` and fill in the values, then:

```bash
cd backend
go run ./cmd/api
```

Required env vars (see `.env.example`):
- `DATABASE_URL` — PostgreSQL connection string
- `JWT_SECRET` — signing key for JWTs
- `PORT` — defaults to 8080

## Flutter app

The Flutter app targets Android and iOS. It cannot be built or run directly on Replit (requires Android SDK / Xcode). Edit the Dart source here and build locally or via CI.

## User preferences

- User wants to edit code only — no run workflow needed on Replit.
