package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/vental-go/backend/internal/domain"
	"github.com/vental-go/backend/internal/integrations"
	"github.com/vental-go/backend/internal/transport/http/middleware"
)

type TaxiHandler struct {
	db      *sqlx.DB
	pricing *integrations.PricingClient
}

func NewTaxiHandler(db *sqlx.DB, pricing *integrations.PricingClient) *TaxiHandler {
	return &TaxiHandler{db: db, pricing: pricing}
}

// POST /taxi/estimate — предварительный расчёт цены
func (h *TaxiHandler) Estimate(c *gin.Context) {
	var req integrations.PriceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	result, err := h.pricing.Calculate(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": "pricing engine unavailable"})
		return
	}
	c.JSON(http.StatusOK, result)
}

// POST /taxi/orders — создать заказ
func (h *TaxiHandler) CreateOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)

	var req struct {
		CarClass      string  `json:"car_class"       binding:"required"`
		PaymentMethod string  `json:"payment_method"  binding:"required"`
		FromAddress   string  `json:"from_address"    binding:"required"`
		FromLat       float64 `json:"from_lat"        binding:"required"`
		FromLng       float64 `json:"from_lng"        binding:"required"`
		ToAddress     string  `json:"to_address"      binding:"required"`
		ToLat         float64 `json:"to_lat"          binding:"required"`
		ToLng         float64 `json:"to_lng"          binding:"required"`
		DistanceKm    float64 `json:"distance_km"`
		DurationMin   float64 `json:"duration_min"`
		Price         float64 `json:"price"`
		DriverPayout  float64 `json:"driver_payout"`
		CityID        string  `json:"city_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var trip domain.TaxiTrip
	err := h.db.Get(&trip, `
		INSERT INTO taxi_trips (
			client_id, car_class, payment_method,
			from_address, from_lat, from_lng,
			to_address, to_lat, to_lng,
			distance_km, duration_min, price, driver_payout, city_id
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
		RETURNING *`,
		uid, req.CarClass, req.PaymentMethod,
		req.FromAddress, req.FromLat, req.FromLng,
		req.ToAddress, req.ToLat, req.ToLng,
		nullableFloat(req.DistanceKm), nullableFloat(req.DurationMin),
		nullableFloat(req.Price), nullableFloat(req.DriverPayout),
		cityOrDefault(req.CityID),
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "create trip failed"})
		return
	}

	// TODO: уведомить ближайших онлайн-водителей (WebSocket / push)
	c.JSON(http.StatusCreated, trip)
}

// GET /taxi/orders/:id — статус поездки с инфо о водителе
func (h *TaxiHandler) GetOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	var trip domain.TripWithDriver
	err := h.db.Get(&trip, `
		SELECT
			t.*,
			u.name        AS driver_name,
			u.avatar_url  AS driver_avatar,
			u.phone       AS driver_phone,
			u.rating      AS driver_rating_v,
			dp.car_model, dp.car_plate, dp.car_color
		FROM taxi_trips t
		LEFT JOIN users        u  ON u.id  = t.driver_id
		LEFT JOIN driver_profiles dp ON dp.user_id = t.driver_id
		WHERE t.id=$1 AND (t.client_id=$2 OR t.driver_id=$2)`,
		id, uid,
	)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "trip not found"})
		return
	}
	c.JSON(http.StatusOK, trip)
}

// POST /taxi/orders/:id/cancel
func (h *TaxiHandler) CancelOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	var req struct {
		Reason string `json:"reason"`
	}
	c.ShouldBindJSON(&req)

	res, err := h.db.Exec(`
		UPDATE taxi_trips SET status='cancelled', cancelled_by='client', cancel_reason=$3
		WHERE id=$1 AND client_id=$2 AND status IN ('searching','driver_assigned','driver_heading')`,
		id, uid, req.Reason,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "cancel failed"})
		return
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "cannot cancel this trip"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"ok": true})
}

// POST /taxi/orders/:id/rate — клиент ставит оценку водителю
func (h *TaxiHandler) RateTrip(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	var req struct {
		Rating int `json:"rating" binding:"required,min=1,max=5"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.db.Exec(`
		UPDATE taxi_trips SET driver_rating=$3
		WHERE id=$1 AND client_id=$2 AND status='completed'`,
		id, uid, req.Rating,
	)
	// Пересчёт среднего рейтинга водителя
	h.db.Exec(`
		UPDATE users SET rating = (
			SELECT AVG(driver_rating) FROM taxi_trips
			WHERE driver_id = (SELECT driver_id FROM taxi_trips WHERE id=$1)
			AND driver_rating IS NOT NULL
		) WHERE id = (SELECT driver_id FROM taxi_trips WHERE id=$1)`, id,
	)
	c.JSON(http.StatusOK, gin.H{"ok": true})
}

// ── helpers ──────────────────────────────────────────────────────────────────

func nullableFloat(v float64) interface{} {
	if v == 0 {
		return nil
	}
	return v
}

func cityOrDefault(v string) string {
	if v == "" {
		return "ereymentau"
	}
	return v
}
