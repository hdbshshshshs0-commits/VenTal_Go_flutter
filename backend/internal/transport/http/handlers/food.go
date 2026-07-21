package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/vental-go/backend/internal/domain"
	"github.com/vental-go/backend/internal/transport/http/middleware"
)

type FoodHandler struct{ db *sqlx.DB }

func NewFoodHandler(db *sqlx.DB) *FoodHandler { return &FoodHandler{db: db} }

// GET /food/restaurants?city_id=ereymentau
func (h *FoodHandler) ListRestaurants(c *gin.Context) {
	cityID := c.DefaultQuery("city_id", "ereymentau")
	var restaurants []domain.Restaurant
	err := h.db.Select(&restaurants,
		`SELECT * FROM restaurants WHERE city_id=$1 AND is_open=true ORDER BY rating DESC`,
		cityID,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "db error"})
		return
	}
	c.JSON(http.StatusOK, restaurants)
}

// GET /food/restaurants/:id
func (h *FoodHandler) GetRestaurant(c *gin.Context) {
	id := c.Param("id")
	var r domain.Restaurant
	if err := h.db.Get(&r, `SELECT * FROM restaurants WHERE id=$1`, id); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "restaurant not found"})
		return
	}

	categories := []domain.MenuCategory{}
	h.db.Select(&categories,
		`SELECT * FROM menu_categories WHERE restaurant_id=$1 ORDER BY sort_order`, id)

	items := []domain.MenuItem{}
	h.db.Select(&items,
		`SELECT * FROM menu_items WHERE restaurant_id=$1 AND is_available=true ORDER BY sort_order`, id)

	c.JSON(http.StatusOK, gin.H{
		"restaurant": r,
		"categories": categories,
		"items":      items,
	})
}

// POST /food/orders — оформить заказ
func (h *FoodHandler) CreateOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)

	var req struct {
		RestaurantID  string            `json:"restaurant_id"  binding:"required"`
		Items         []domain.CartItem `json:"items"          binding:"required,min=1"`
		Address       string            `json:"address"        binding:"required"`
		Lat           *float64          `json:"lat"`
		Lng           *float64          `json:"lng"`
		PaymentMethod string            `json:"payment_method" binding:"required"`
		Notes         *string           `json:"notes"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Получаем ресторан для delivery_fee
	var rest domain.Restaurant
	if err := h.db.Get(&rest, `SELECT * FROM restaurants WHERE id=$1`, req.RestaurantID); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "restaurant not found"})
		return
	}

	// Считаем сумму позиций
	var subtotal float64
	type itemRow struct {
		ID    string  `db:"id"`
		Price float64 `db:"price"`
	}
	for _, ci := range req.Items {
		var row itemRow
		if err := h.db.Get(&row, `SELECT id, price FROM menu_items WHERE id=$1 AND restaurant_id=$2 AND is_available=true`,
			ci.MenuItemID, req.RestaurantID); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "menu item not found: " + ci.MenuItemID})
			return
		}
		subtotal += row.Price * float64(ci.Quantity)
	}
	total := subtotal + rest.DeliveryFee

	// Транзакция: создаём заказ + позиции
	tx, err := h.db.Beginx()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "tx begin failed"})
		return
	}
	defer tx.Rollback()

	var order domain.FoodOrder
	err = tx.Get(&order, `
		INSERT INTO food_orders
			(client_id, restaurant_id, payment_method, address, lat, lng, subtotal, delivery_fee, total, notes)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		RETURNING *`,
		uid, req.RestaurantID, req.PaymentMethod, req.Address, req.Lat, req.Lng,
		subtotal, rest.DeliveryFee, total, req.Notes,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "order create failed"})
		return
	}

	for _, ci := range req.Items {
		var price float64
		h.db.Get(&price, `SELECT price FROM menu_items WHERE id=$1`, ci.MenuItemID)
		tx.Exec(`
			INSERT INTO food_order_items (order_id, menu_item_id, quantity, unit_price, total_price)
			VALUES ($1,$2,$3,$4,$5)`,
			order.ID, ci.MenuItemID, ci.Quantity, price, price*float64(ci.Quantity),
		)
	}

	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "commit failed"})
		return
	}

	c.JSON(http.StatusCreated, order)
}

// GET /food/orders/:id
func (h *FoodHandler) GetOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	var order domain.FoodOrder
	if err := h.db.Get(&order, `SELECT * FROM food_orders WHERE id=$1 AND client_id=$2`, id, uid); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "order not found"})
		return
	}

	items := []domain.FoodOrderItem{}
	h.db.Select(&items, `SELECT * FROM food_order_items WHERE order_id=$1`, id)

	c.JSON(http.StatusOK, gin.H{"order": order, "items": items})
}

// POST /food/orders/:id/cancel
func (h *FoodHandler) CancelOrder(c *gin.Context) {
	uid := c.GetString(middleware.UserIDKey)
	id := c.Param("id")

	res, err := h.db.Exec(`
		UPDATE food_orders SET status='cancelled'
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
