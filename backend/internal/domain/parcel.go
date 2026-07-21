package domain

import "time"

type ParcelStatus string

const (
	ParcelPending   ParcelStatus = "pending"
	ParcelAssigned  ParcelStatus = "assigned"
	ParcelPickedUp  ParcelStatus = "picked_up"
	ParcelInTransit ParcelStatus = "in_transit"
	ParcelDelivered ParcelStatus = "delivered"
	ParcelCancelled ParcelStatus = "cancelled"
)

type ParcelOrder struct {
	ID            string       `db:"id"             json:"id"`
	ClientID      string       `db:"client_id"      json:"client_id"`
	CourierID     *string      `db:"courier_id"     json:"courier_id"`
	Status        ParcelStatus `db:"status"         json:"status"`
	PaymentMethod string       `db:"payment_method" json:"payment_method"`
	FromAddress   string       `db:"from_address"   json:"from_address"`
	FromLat       *float64     `db:"from_lat"       json:"from_lat"`
	FromLng       *float64     `db:"from_lng"       json:"from_lng"`
	FromContact   *string      `db:"from_contact"   json:"from_contact"`
	FromPhone     *string      `db:"from_phone"     json:"from_phone"`
	ToAddress     string       `db:"to_address"     json:"to_address"`
	ToLat         *float64     `db:"to_lat"         json:"to_lat"`
	ToLng         *float64     `db:"to_lng"         json:"to_lng"`
	ToContact     *string      `db:"to_contact"     json:"to_contact"`
	ToPhone       *string      `db:"to_phone"       json:"to_phone"`
	WeightKg      *float64     `db:"weight_kg"      json:"weight_kg"`
	DeliveryType  string       `db:"delivery_type"  json:"delivery_type"`
	Price         *float64     `db:"price"          json:"price"`
	Notes         *string      `db:"notes"          json:"notes"`
	CreatedAt     time.Time    `db:"created_at"     json:"created_at"`
	UpdatedAt     time.Time    `db:"updated_at"     json:"updated_at"`
}
