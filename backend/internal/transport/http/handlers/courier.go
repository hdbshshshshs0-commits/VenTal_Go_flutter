package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/vental-go/backend/internal/domain"
	"github.com/vental-go/backend/internal/transport/http/middleware"
)

type CourierHandler struct{ db *sqlx.DB }

func NewCourierHandler(db *sqlx.DB) *CourierHandler { return &CourierHandler{db: db} }

// GET /courier/orders — доступные посылки / заказы еды для курьера
func (h *CourierHandler) AvailableOrders(c *gin.Context) {
	parcels := []domain.ParcelOrder{}
	h.db.Select(&parcels, `SELECT * FROM parcel_orders WHERE status='pending' ORDER BY created_at ASC LIMIT 10`)

	foodOrders := []domain.FoodOrder{}
	h.db.Select(&foodOrders, `SELECT * FROM food_orders WHERE status='ready' AND courier_id IS NULL ORDER BY created_at ASC LIMIT 10`)

	c.JSON(http.StatusOK, gin.H{
		"parcels":     parcels,
		"food_orders": foodOrders,
	})
}

// POST /courier/parcels/:id/accept
func (h *CourierHandler) AcceptParcel(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	res, err := h.db.Exec(`
		UPDATE parcel_orders SET courier_id=$2, status='assigned'
		WHERE id=$1 AND status='pending'`, id, uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "accept failed"})
		return
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "order already taken"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"ok": true})
}

// POST /courier/parcels/:id/status
func (h *CourierHandler) UpdateParcelStatus(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	var req struct {
		Status string `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	allowed := map[string]bool{
		"picked_up": true, "in_transit": true, "delivered": true,
	}
	if !allowed[req.Status] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid status"})
		return
	}

	res, err := h.db.Exec(`
		UPDATE parcel_orders SET status=$3
		WHERE id=$1 AND courier_id=$2 AND status!='cancelled'`, id, uid, req.Status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "update failed"})
		return
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "not your order or invalid"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": req.Status})
}

// POST /courier/food/:id/accept
func (h *CourierHandler) AcceptFoodOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	res, err := h.db.Exec(`
		UPDATE food_orders SET courier_id=$2
		WHERE id=$1 AND status='ready' AND courier_id IS NULL`, id, uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "accept failed"})
		return
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "order already taken"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"ok": true})
}

// POST /courier/food/:id/status
func (h *CourierHandler) UpdateFoodStatus(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	var req struct {
		Status string `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	allowed := map[string]bool{"picked_up": true, "delivered": true}
	if !allowed[req.Status] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid status"})
		return
	}

	h.db.Exec(`
		UPDATE food_orders SET status=$3
		WHERE id=$1 AND courier_id=$2`, id, uid, req.Status)
	c.JSON(http.StatusOK, gin.H{"status": req.Status})
}
