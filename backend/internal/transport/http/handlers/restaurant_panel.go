package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/vental-go/backend/internal/domain"
	"github.com/vental-go/backend/internal/transport/http/middleware"
)

type RestaurantPanelHandler struct{ db *sqlx.DB }

func NewRestaurantPanelHandler(db *sqlx.DB) *RestaurantPanelHandler {
	return &RestaurantPanelHandler{db: db}
}

// GET /restaurant/orders — активные заказы ресторана
func (h *RestaurantPanelHandler) ListOrders(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)

	var rest domain.Restaurant
	if err := h.db.Get(&rest, `SELECT * FROM restaurants WHERE owner_id=$1`, uid); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "restaurant not found for this account"})
		return
	}

	status := c.DefaultQuery("status", "")
	var orders []domain.FoodOrder
	if status != "" {
		h.db.Select(&orders,
			`SELECT * FROM food_orders WHERE restaurant_id=$1 AND status=$2 ORDER BY created_at DESC`,
			rest.ID, status)
	} else {
		h.db.Select(&orders,
			`SELECT * FROM food_orders WHERE restaurant_id=$1 AND status NOT IN ('delivered','cancelled') ORDER BY created_at DESC`,
			rest.ID)
	}
	c.JSON(http.StatusOK, orders)
}

// POST /restaurant/orders/:id/status
func (h *RestaurantPanelHandler) UpdateOrderStatus(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	var req struct {
		Status string `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	res, err := h.db.Exec(`
		UPDATE food_orders SET status=$3
		WHERE id=$1
		  AND restaurant_id = (SELECT id FROM restaurants WHERE owner_id=$2)
		  AND status != 'cancelled'`,
		id, uid, req.Status,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "update failed"})
		return
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "order not found or cannot update"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": req.Status})
}

// PUT /restaurant/open — открыть/закрыть ресторан
func (h *RestaurantPanelHandler) SetOpen(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	var req struct {
		IsOpen bool `json:"is_open"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	h.db.Exec(`UPDATE restaurants SET is_open=$2 WHERE owner_id=$1`, uid, req.IsOpen)
	c.JSON(http.StatusOK, gin.H{"is_open": req.IsOpen})
}
