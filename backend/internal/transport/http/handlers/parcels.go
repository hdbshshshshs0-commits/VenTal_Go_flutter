package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/vental-go/backend/internal/domain"
	"github.com/vental-go/backend/internal/transport/http/middleware"
)

type ParcelsHandler struct{ db *sqlx.DB }

func NewParcelsHandler(db *sqlx.DB) *ParcelsHandler { return &ParcelsHandler{db: db} }

// POST /parcels/orders
func (h *ParcelsHandler) CreateOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)

	var req struct {
		PaymentMethod string   `json:"payment_method" binding:"required"`
		FromAddress   string   `json:"from_address"   binding:"required"`
		FromLat       *float64 `json:"from_lat"`
		FromLng       *float64 `json:"from_lng"`
		FromContact   *string  `json:"from_contact"`
		FromPhone     *string  `json:"from_phone"`
		ToAddress     string   `json:"to_address"     binding:"required"`
		ToLat         *float64 `json:"to_lat"`
		ToLng         *float64 `json:"to_lng"`
		ToContact     *string  `json:"to_contact"`
		ToPhone       *string  `json:"to_phone"`
		WeightKg      *float64 `json:"weight_kg"`
		DeliveryType  string   `json:"delivery_type"`
		Price         *float64 `json:"price"`
		Notes         *string  `json:"notes"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	deliveryType := req.DeliveryType
	if deliveryType == "" {
		deliveryType = "car"
	}

	var parcel domain.ParcelOrder
	err := h.db.Get(&parcel, `
		INSERT INTO parcel_orders (
			client_id, payment_method,
			from_address, from_lat, from_lng, from_contact, from_phone,
			to_address,   to_lat,   to_lng,   to_contact,   to_phone,
			weight_kg, delivery_type, price, notes
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
		RETURNING *`,
		uid, req.PaymentMethod,
		req.FromAddress, req.FromLat, req.FromLng, req.FromContact, req.FromPhone,
		req.ToAddress, req.ToLat, req.ToLng, req.ToContact, req.ToPhone,
		req.WeightKg, deliveryType, req.Price, req.Notes,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "create failed"})
		return
	}

	c.JSON(http.StatusCreated, parcel)
}

// GET /parcels/orders/:id
func (h *ParcelsHandler) GetOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	var parcel domain.ParcelOrder
	if err := h.db.Get(&parcel, `
		SELECT * FROM parcel_orders WHERE id=$1 AND (client_id=$2 OR courier_id=$2)`,
		id, uid,
	); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
		return
	}
	c.JSON(http.StatusOK, parcel)
}

// POST /parcels/orders/:id/cancel
func (h *ParcelsHandler) CancelOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	res, err := h.db.Exec(`
		UPDATE parcel_orders SET status='cancelled'
		WHERE id=$1 AND client_id=$2 AND status='pending'`, id, uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "cancel failed"})
		return
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "cannot cancel"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"ok": true})
}
