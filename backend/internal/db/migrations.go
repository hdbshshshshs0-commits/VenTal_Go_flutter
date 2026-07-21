package db

import (
	"fmt"

	"github.com/jmoiron/sqlx"
)

// Migrate runs all DDL statements in order.
// Idempotent — safe to call on every startup.
func Migrate(db *sqlx.DB) error {
	statements := []string{
		// ─── Extensions ──────────────────────────────────────────────────────
		`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`,
		`CREATE EXTENSION IF NOT EXISTS "postgis"`,

		// ─── ENUM types ──────────────────────────────────────────────────────
		`DO $$ BEGIN
			CREATE TYPE user_role AS ENUM ('client','driver','courier','restaurant','admin');
		EXCEPTION WHEN duplicate_object THEN NULL; END $$`,

		`DO $$ BEGIN
			CREATE TYPE trip_status AS ENUM (
				'searching','driver_assigned','driver_heading',
				'driver_arrived','in_progress','completed','cancelled'
			);
		EXCEPTION WHEN duplicate_object THEN NULL; END $$`,

		`DO $$ BEGIN
			CREATE TYPE order_status AS ENUM (
				'pending','accepted','preparing','ready','picked_up','delivered','cancelled'
			);
		EXCEPTION WHEN duplicate_object THEN NULL; END $$`,

		`DO $$ BEGIN
			CREATE TYPE parcel_status AS ENUM (
				'pending','assigned','picked_up','in_transit','delivered','cancelled'
			);
		EXCEPTION WHEN duplicate_object THEN NULL; END $$`,

		`DO $$ BEGIN
			CREATE TYPE payment_method AS ENUM ('cash','kaspi_transfer','halyk_transfer','card');
		EXCEPTION WHEN duplicate_object THEN NULL; END $$`,

		`DO $$ BEGIN
			CREATE TYPE car_class AS ENUM ('economy','comfort','comfort_plus','business','premium','eco');
		EXCEPTION WHEN duplicate_object THEN NULL; END $$`,

		// ─── Users ───────────────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS users (
			id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			phone        VARCHAR(20) UNIQUE NOT NULL,
			name         VARCHAR(120),
			avatar_url   TEXT,
			role         user_role NOT NULL DEFAULT 'client',
			city_id      VARCHAR(40) DEFAULT 'ereymentau',
			rating       NUMERIC(3,2) DEFAULT 5.00,
			is_active    BOOLEAN NOT NULL DEFAULT true,
			created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`,

		// ─── OTP codes ───────────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS otp_codes (
			id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			phone       VARCHAR(20) NOT NULL,
			code        VARCHAR(10) NOT NULL,
			expires_at  TIMESTAMPTZ NOT NULL,
			used        BOOLEAN NOT NULL DEFAULT false,
			created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`,
		`CREATE INDEX IF NOT EXISTS idx_otp_phone ON otp_codes(phone)`,

		// ─── Driver profiles ─────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS driver_profiles (
			user_id      UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
			car_class    car_class NOT NULL DEFAULT 'economy',
			car_model    VARCHAR(100),
			car_plate    VARCHAR(20),
			car_color    VARCHAR(40),
			is_online    BOOLEAN NOT NULL DEFAULT false,
			last_lat     DOUBLE PRECISION,
			last_lng     DOUBLE PRECISION,
			updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`,

		// ─── Taxi trips ──────────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS taxi_trips (
			id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			client_id        UUID NOT NULL REFERENCES users(id),
			driver_id        UUID REFERENCES users(id),
			status           trip_status NOT NULL DEFAULT 'searching',
			car_class        car_class NOT NULL DEFAULT 'economy',
			payment_method   payment_method NOT NULL DEFAULT 'cash',
			from_address     TEXT NOT NULL,
			from_lat         DOUBLE PRECISION NOT NULL,
			from_lng         DOUBLE PRECISION NOT NULL,
			to_address       TEXT NOT NULL,
			to_lat           DOUBLE PRECISION NOT NULL,
			to_lng           DOUBLE PRECISION NOT NULL,
			distance_km      NUMERIC(8,2),
			duration_min     NUMERIC(6,1),
			price            NUMERIC(10,2),
			driver_payout    NUMERIC(10,2),
			city_id          VARCHAR(40) DEFAULT 'ereymentau',
			client_rating    SMALLINT,
			driver_rating    SMALLINT,
			cancelled_by     VARCHAR(10),
			cancel_reason    TEXT,
			started_at       TIMESTAMPTZ,
			completed_at     TIMESTAMPTZ,
			created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`,
		`CREATE INDEX IF NOT EXISTS idx_trips_client ON taxi_trips(client_id)`,
		`CREATE INDEX IF NOT EXISTS idx_trips_driver ON taxi_trips(driver_id)`,
		`CREATE INDEX IF NOT EXISTS idx_trips_status ON taxi_trips(status)`,

		// ─── Restaurants ─────────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS restaurants (
			id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			owner_id     UUID REFERENCES users(id),
			name         VARCHAR(200) NOT NULL,
			description  TEXT,
			logo_url     TEXT,
			cover_url    TEXT,
			address      TEXT,
			city_id      VARCHAR(40) DEFAULT 'ereymentau',
			lat          DOUBLE PRECISION,
			lng          DOUBLE PRECISION,
			phone        VARCHAR(20),
			is_open      BOOLEAN NOT NULL DEFAULT true,
			rating       NUMERIC(3,2) DEFAULT 5.00,
			min_order    NUMERIC(10,2) DEFAULT 0,
			delivery_fee NUMERIC(10,2) DEFAULT 0,
			created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`,

		// ─── Menu categories ─────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS menu_categories (
			id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
			name          VARCHAR(100) NOT NULL,
			sort_order    SMALLINT DEFAULT 0
		)`,

		// ─── Menu items ──────────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS menu_items (
			id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
			category_id   UUID REFERENCES menu_categories(id),
			name          VARCHAR(200) NOT NULL,
			description   TEXT,
			image_url     TEXT,
			price         NUMERIC(10,2) NOT NULL,
			is_available  BOOLEAN NOT NULL DEFAULT true,
			sort_order    SMALLINT DEFAULT 0
		)`,

		// ─── Food orders ─────────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS food_orders (
			id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			client_id      UUID NOT NULL REFERENCES users(id),
			restaurant_id  UUID NOT NULL REFERENCES restaurants(id),
			courier_id     UUID REFERENCES users(id),
			status         order_status NOT NULL DEFAULT 'pending',
			payment_method payment_method NOT NULL DEFAULT 'cash',
			address        TEXT NOT NULL,
			lat            DOUBLE PRECISION,
			lng            DOUBLE PRECISION,
			subtotal       NUMERIC(10,2) NOT NULL,
			delivery_fee   NUMERIC(10,2) NOT NULL DEFAULT 0,
			total          NUMERIC(10,2) NOT NULL,
			notes          TEXT,
			created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`,

		// ─── Food order items ────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS food_order_items (
			id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			order_id     UUID NOT NULL REFERENCES food_orders(id) ON DELETE CASCADE,
			menu_item_id UUID NOT NULL REFERENCES menu_items(id),
			quantity     SMALLINT NOT NULL DEFAULT 1,
			unit_price   NUMERIC(10,2) NOT NULL,
			total_price  NUMERIC(10,2) NOT NULL
		)`,

		// ─── Parcel orders ───────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS parcel_orders (
			id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			client_id        UUID NOT NULL REFERENCES users(id),
			courier_id       UUID REFERENCES users(id),
			status           parcel_status NOT NULL DEFAULT 'pending',
			payment_method   payment_method NOT NULL DEFAULT 'cash',
			from_address     TEXT NOT NULL,
			from_lat         DOUBLE PRECISION,
			from_lng         DOUBLE PRECISION,
			from_contact     VARCHAR(100),
			from_phone       VARCHAR(20),
			to_address       TEXT NOT NULL,
			to_lat           DOUBLE PRECISION,
			to_lng           DOUBLE PRECISION,
			to_contact       VARCHAR(100),
			to_phone         VARCHAR(20),
			weight_kg        NUMERIC(5,2),
			delivery_type    VARCHAR(20) DEFAULT 'car',
			price            NUMERIC(10,2),
			notes            TEXT,
			created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`,

		// ─── Push tokens ─────────────────────────────────────────────────────
		`CREATE TABLE IF NOT EXISTS push_tokens (
			id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
			user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
			token      TEXT NOT NULL,
			platform   VARCHAR(10),
			updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			UNIQUE(user_id, token)
		)`,

		// ─── updated_at trigger function ─────────────────────────────────────
		`CREATE OR REPLACE FUNCTION set_updated_at()
		RETURNS TRIGGER AS $$
		BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
		$$ LANGUAGE plpgsql`,

		applyTrigger("users"),
		applyTrigger("taxi_trips"),
		applyTrigger("food_orders"),
		applyTrigger("parcel_orders"),
		applyTrigger("driver_profiles"),
	}

	for _, stmt := range statements {
		if _, err := db.Exec(stmt); err != nil {
			return fmt.Errorf("migration failed: %w\nSQL: %s", err, stmt[:min(len(stmt), 120)])
		}
	}
	return nil
}

func applyTrigger(table string) string {
	return fmt.Sprintf(`
		DROP TRIGGER IF EXISTS trg_%s_updated_at ON %s;
		CREATE TRIGGER trg_%s_updated_at
		BEFORE UPDATE ON %s
		FOR EACH ROW EXECUTE FUNCTION set_updated_at()`,
		table, table, table, table)
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
