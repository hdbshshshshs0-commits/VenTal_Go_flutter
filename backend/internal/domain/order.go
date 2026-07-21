package domain

import "time"

type OrderStatus string

const (
	OrderPending   OrderStatus = "pending"
	OrderAccepted  OrderStatus = "accepted"
	OrderPreparing OrderStatus = "preparing"
	OrderReady     OrderStatus = "ready"
	OrderPickedUp  OrderStatus = "picked_up"
	OrderDelivered OrderStatus = "delivered"
	OrderCancelled OrderStatus = "cancelled"
)

type Restaurant struct {
	ID          string   `db:"id"           json:"id"`
	OwnerID     *string  `db:"owner_id"     json:"owner_id"`
	Name        string   `db:"name"         json:"name"`
	Description *string  `db:"description"  json:"description"`
	LogoURL     *string  `db:"logo_url"     json:"logo_url"`
	CoverURL    *string  `db:"cover_url"    json:"cover_url"`
	Address     *string  `db:"address"      json:"address"`
	CityID      string   `db:"city_id"      json:"city_id"`
	Lat         *float64 `db:"lat"          json:"lat"`
	Lng         *float64 `db:"lng"          json:"lng"`
	Phone       *string  `db:"phone"        json:"phone"`
	IsOpen      bool     `db:"is_open"      json:"is_open"`
	Rating      float64  `db:"rating"       json:"rating"`
	MinOrder    float64  `db:"min_order"    json:"min_order"`
	DeliveryFee float64  `db:"delivery_fee" json:"delivery_fee"`
}

type MenuCategory struct {
	ID           string `db:"id"            json:"id"`
	RestaurantID string `db:"restaurant_id" json:"restaurant_id"`
	Name         string `db:"name"          json:"name"`
	SortOrder    int    `db:"sort_order"    json:"sort_order"`
}

type MenuItem struct {
	ID           string   `db:"id"            json:"id"`
	RestaurantID string   `db:"restaurant_id" json:"restaurant_id"`
	CategoryID   *string  `db:"category_id"   json:"category_id"`
	Name         string   `db:"name"          json:"name"`
	Description  *string  `db:"description"   json:"description"`
	ImageURL     *string  `db:"image_url"     json:"image_url"`
	Price        float64  `db:"price"         json:"price"`
	IsAvailable  bool     `db:"is_available"  json:"is_available"`
	SortOrder    int      `db:"sort_order"    json:"sort_order"`
}

type FoodOrder struct {
	ID           string      `db:"id"            json:"id"`
	ClientID     string      `db:"client_id"     json:"client_id"`
	RestaurantID string      `db:"restaurant_id" json:"restaurant_id"`
	CourierID    *string     `db:"courier_id"    json:"courier_id"`
	Status       OrderStatus `db:"status"        json:"status"`
	PaymentMethod string     `db:"payment_method" json:"payment_method"`
	Address      string      `db:"address"       json:"address"`
	Lat          *float64    `db:"lat"           json:"lat"`
	Lng          *float64    `db:"lng"           json:"lng"`
	Subtotal     float64     `db:"subtotal"      json:"subtotal"`
	DeliveryFee  float64     `db:"delivery_fee"  json:"delivery_fee"`
	Total        float64     `db:"total"         json:"total"`
	Notes        *string     `db:"notes"         json:"notes"`
	CreatedAt    time.Time   `db:"created_at"    json:"created_at"`
	UpdatedAt    time.Time   `db:"updated_at"    json:"updated_at"`
}

type FoodOrderItem struct {
	ID         string  `db:"id"           json:"id"`
	OrderID    string  `db:"order_id"     json:"order_id"`
	MenuItemID string  `db:"menu_item_id" json:"menu_item_id"`
	Quantity   int     `db:"quantity"     json:"quantity"`
	UnitPrice  float64 `db:"unit_price"   json:"unit_price"`
	TotalPrice float64 `db:"total_price"  json:"total_price"`
}

type CartItem struct {
	MenuItemID string `json:"menu_item_id"`
	Quantity   int    `json:"quantity"`
}
