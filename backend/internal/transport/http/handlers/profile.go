package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/vental-go/backend/internal/domain"
	"github.com/vental-go/backend/internal/transport/http/middleware"
)

type ProfileHandler struct{ db *sqlx.DB }

func NewProfileHandler(db *sqlx.DB) *ProfileHandler { return &ProfileHandler{db: db} }

// GET /profile
func (h *ProfileHandler) Get(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	var user domain.User
	if err := h.db.Get(&user, `SELECT * FROM users WHERE id=$1`, uid); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}
	c.JSON(http.StatusOK, user)
}

// PUT /profile
func (h *ProfileHandler) Update(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	var req struct {
		Name   *string `json:"name"`
		CityID *string `json:"city_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user domain.User
	err := h.db.Get(&user,
		`UPDATE users SET
			name    = COALESCE($2, name),
			city_id = COALESCE($3, city_id)
		 WHERE id=$1 RETURNING *`,
		uid, req.Name, req.CityID,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "update failed"})
		return
	}
	c.JSON(http.StatusOK, user)
}

// GET /profile/history  — все заказы пользователя (такси + еда + посылки)
func (h *ProfileHandler) History(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)

	trips := []domain.TaxiTrip{}
	h.db.Select(&trips,
		`SELECT * FROM taxi_trips WHERE client_id=$1 ORDER BY created_at DESC LIMIT 20`, uid)

	foodOrders := []domain.FoodOrder{}
	h.db.Select(&foodOrders,
		`SELECT * FROM food_orders WHERE client_id=$1 ORDER BY created_at DESC LIMIT 20`, uid)

	parcels := []domain.ParcelOrder{}
	h.db.Select(&parcels,
		`SELECT * FROM parcel_orders WHERE client_id=$1 ORDER BY created_at DESC LIMIT 20`, uid)

	c.JSON(http.StatusOK, gin.H{
		"trips":       trips,
		"food_orders": foodOrders,
		"parcels":     parcels,
	})
}

// POST /profile/push-token
func (h *ProfileHandler) SavePushToken(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	var req struct {
		Token    string `json:"token"    binding:"required"`
		Platform string `json:"platform"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	h.db.Exec(
		`INSERT INTO push_tokens (user_id, token, platform)
		 VALUES ($1,$2,$3)
		 ON CONFLICT (user_id, token) DO UPDATE SET platform=$3, updated_at=NOW()`,
		uid, req.Token, req.Platform,
	)
	c.JSON(http.StatusOK, gin.H{"ok": true})
}
