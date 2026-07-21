package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/vental-go/backend/internal/domain"
	"github.com/vental-go/backend/internal/transport/http/middleware"
)

type DriverHandler struct{ db *sqlx.DB }

func NewDriverHandler(db *sqlx.DB) *DriverHandler { return &DriverHandler{db: db} }

// GET /driver/profile
func (h *DriverHandler) GetProfile(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	var dp domain.DriverProfile
	if err := h.db.Get(&dp, `SELECT * FROM driver_profiles WHERE user_id=$1`, uid); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "driver profile not found"})
		return
	}
	c.JSON(http.StatusOK, dp)
}

// PUT /driver/profile
func (h *DriverHandler) UpdateProfile(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	var req struct {
		CarClass *string `json:"car_class"`
		CarModel *string `json:"car_model"`
		CarPlate *string `json:"car_plate"`
		CarColor *string `json:"car_color"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var dp domain.DriverProfile
	err := h.db.Get(&dp, `
		INSERT INTO driver_profiles (user_id, car_class, car_model, car_plate, car_color)
		VALUES ($1, COALESCE($2,'economy'), $3, $4, $5)
		ON CONFLICT (user_id) DO UPDATE SET
			car_class = COALESCE($2, driver_profiles.car_class),
			car_model = COALESCE($3, driver_profiles.car_model),
			car_plate = COALESCE($4, driver_profiles.car_plate),
			car_color = COALESCE($5, driver_profiles.car_color),
			updated_at = NOW()
		RETURNING *`,
		uid, req.CarClass, req.CarModel, req.CarPlate, req.CarColor,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "update failed"})
		return
	}
	c.JSON(http.StatusOK, dp)
}

// POST /driver/status — онлайн/оффлайн + координаты
func (h *DriverHandler) SetStatus(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	var req struct {
		IsOnline bool     `json:"is_online"`
		Lat      *float64 `json:"lat"`
		Lng      *float64 `json:"lng"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	h.db.Exec(`
		INSERT INTO driver_profiles (user_id, is_online, last_lat, last_lng)
		VALUES ($1,$2,$3,$4)
		ON CONFLICT (user_id) DO UPDATE SET
			is_online  = $2,
			last_lat   = COALESCE($3, driver_profiles.last_lat),
			last_lng   = COALESCE($4, driver_profiles.last_lng),
			updated_at = NOW()`,
		uid, req.IsOnline, req.Lat, req.Lng,
	)
	c.JSON(http.StatusOK, gin.H{"is_online": req.IsOnline})
}

// GET /driver/orders — доступные заказы рядом (searching)
func (h *DriverHandler) AvailableOrders(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)

	var dp domain.DriverProfile
	if err := h.db.Get(&dp, `SELECT * FROM driver_profiles WHERE user_id=$1`, uid); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "driver profile missing"})
		return
	}

	var trips []domain.TaxiTrip
	h.db.Select(&trips, `
		SELECT * FROM taxi_trips
		WHERE status='searching' AND car_class=$1
		ORDER BY created_at ASC LIMIT 10`,
		dp.CarClass,
	)
	c.JSON(http.StatusOK, trips)
}

// POST /driver/orders/:id/accept
func (h *DriverHandler) AcceptOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	res, err := h.db.Exec(`
		UPDATE taxi_trips SET driver_id=$2, status='driver_assigned'
		WHERE id=$1 AND status='searching'`, id, uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "accept failed"})
		return
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "order already taken or not found"})
		return
	}
	// TODO: push-уведомление клиенту
	c.JSON(http.StatusOK, gin.H{"ok": true})
}

// POST /driver/orders/:id/status — водитель меняет статус поездки
func (h *DriverHandler) UpdateTripStatus(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	var req struct {
		Status string `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	allowed := map[string]string{
		"driver_heading":  "driver_assigned",
		"driver_arrived":  "driver_heading",
		"in_progress":     "driver_arrived",
		"completed":       "in_progress",
	}
	requiredCurrent, ok := allowed[req.Status]
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid status transition"})
		return
	}

	extra := ""
	if req.Status == "in_progress" {
		extra = ", started_at=NOW()"
	}
	if req.Status == "completed" {
		extra = ", completed_at=NOW()"
	}

	res, err := h.db.Exec(
		`UPDATE taxi_trips SET status=$3`+extra+`
		 WHERE id=$1 AND driver_id=$2 AND status=$4`,
		id, uid, req.Status, requiredCurrent,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "update failed"})
		return
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid transition or not your trip"})
		return
	}
	// TODO: push клиенту о смене статуса
	c.JSON(http.StatusOK, gin.H{"status": req.Status})
}

// GET /driver/active — текущая активная поездка водителя
func (h *DriverHandler) ActiveTrip(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	var trip domain.TripWithDriver
	err := h.db.Get(&trip, `
		SELECT t.*, u.name AS driver_name, u.phone AS driver_phone
		FROM taxi_trips t
		LEFT JOIN users u ON u.id=t.driver_id
		WHERE t.driver_id=$1 AND t.status NOT IN ('completed','cancelled')
		ORDER BY t.created_at DESC LIMIT 1`, uid)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"trip": nil})
		return
	}
	c.JSON(http.StatusOK, gin.H{"trip": trip})
}
