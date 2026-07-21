package domain

import "time"

type TripStatus string

const (
	TripSearching       TripStatus = "searching"
	TripDriverAssigned  TripStatus = "driver_assigned"
	TripDriverHeading   TripStatus = "driver_heading"
	TripDriverArrived   TripStatus = "driver_arrived"
	TripInProgress      TripStatus = "in_progress"
	TripCompleted       TripStatus = "completed"
	TripCancelled       TripStatus = "cancelled"
)

type TaxiTrip struct {
	ID            string     `db:"id"             json:"id"`
	ClientID      string     `db:"client_id"      json:"client_id"`
	DriverID      *string    `db:"driver_id"      json:"driver_id"`
	Status        TripStatus `db:"status"         json:"status"`
	CarClass      string     `db:"car_class"      json:"car_class"`
	PaymentMethod string     `db:"payment_method" json:"payment_method"`
	FromAddress   string     `db:"from_address"   json:"from_address"`
	FromLat       float64    `db:"from_lat"       json:"from_lat"`
	FromLng       float64    `db:"from_lng"       json:"from_lng"`
	ToAddress     string     `db:"to_address"     json:"to_address"`
	ToLat         float64    `db:"to_lat"         json:"to_lat"`
	ToLng         float64    `db:"to_lng"         json:"to_lng"`
	DistanceKm    *float64   `db:"distance_km"    json:"distance_km"`
	DurationMin   *float64   `db:"duration_min"   json:"duration_min"`
	Price         *float64   `db:"price"          json:"price"`
	DriverPayout  *float64   `db:"driver_payout"  json:"driver_payout"`
	CityID        string     `db:"city_id"        json:"city_id"`
	ClientRating  *int       `db:"client_rating"  json:"client_rating"`
	DriverRating  *int       `db:"driver_rating"  json:"driver_rating"`
	CancelledBy   *string    `db:"cancelled_by"   json:"cancelled_by"`
	CancelReason  *string    `db:"cancel_reason"  json:"cancel_reason"`
	StartedAt     *time.Time `db:"started_at"     json:"started_at"`
	CompletedAt   *time.Time `db:"completed_at"   json:"completed_at"`
	CreatedAt     time.Time  `db:"created_at"     json:"created_at"`
	UpdatedAt     time.Time  `db:"updated_at"     json:"updated_at"`
}

type TripWithDriver struct {
	TaxiTrip
	DriverName     *string  `db:"driver_name"     json:"driver_name"`
	DriverAvatar   *string  `db:"driver_avatar"   json:"driver_avatar"`
	DriverPhone    *string  `db:"driver_phone"    json:"driver_phone"`
	DriverRatingV  *float64 `db:"driver_rating_v" json:"driver_rating_v"`
	CarModel       *string  `db:"car_model"       json:"car_model"`
	CarPlate       *string  `db:"car_plate"       json:"car_plate"`
	CarColor       *string  `db:"car_color"       json:"car_color"`
}
