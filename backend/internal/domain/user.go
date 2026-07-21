package domain

import "time"

type Role string

const (
	RoleClient     Role = "client"
	RoleDriver     Role = "driver"
	RoleCourier    Role = "courier"
	RoleRestaurant Role = "restaurant"
	RoleAdmin      Role = "admin"
)

type User struct {
	ID        string    `db:"id"         json:"id"`
	Phone     string    `db:"phone"       json:"phone"`
	Name      *string   `db:"name"        json:"name"`
	AvatarURL *string   `db:"avatar_url"  json:"avatar_url"`
	Role      Role      `db:"role"        json:"role"`
	CityID    string    `db:"city_id"     json:"city_id"`
	Rating    float64   `db:"rating"      json:"rating"`
	IsActive  bool      `db:"is_active"   json:"is_active"`
	CreatedAt time.Time `db:"created_at"  json:"created_at"`
	UpdatedAt time.Time `db:"updated_at"  json:"updated_at"`
}

type DriverProfile struct {
	UserID    string   `db:"user_id"    json:"user_id"`
	CarClass  string   `db:"car_class"  json:"car_class"`
	CarModel  *string  `db:"car_model"  json:"car_model"`
	CarPlate  *string  `db:"car_plate"  json:"car_plate"`
	CarColor  *string  `db:"car_color"  json:"car_color"`
	IsOnline  bool     `db:"is_online"  json:"is_online"`
	LastLat   *float64 `db:"last_lat"   json:"last_lat"`
	LastLng   *float64 `db:"last_lng"   json:"last_lng"`
}
