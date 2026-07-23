package http

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/vental-go/backend/internal/config"
	"github.com/vental-go/backend/internal/integrations"
	"github.com/vental-go/backend/internal/transport/http/handlers"
	"github.com/vental-go/backend/internal/transport/http/middleware"
)

func NewRouter(db *sqlx.DB, cfg *config.Config) *gin.Engine {
	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery())
	r.Use(corsMiddleware(cfg.AllowedOrigins))

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok", "env": cfg.Env})
	})

	// Init handlers
	pricing := integrations.NewPricingClient(cfg.PricingEngineURL)

	auth     := handlers.NewAuthHandler(db, cfg)
	profile  := handlers.NewProfileHandler(db)
	taxi     := handlers.NewTaxiHandler(db, pricing)
	food     := handlers.NewFoodHandler(db)
	parcels  := handlers.NewParcelsHandler(db)
	driver   := handlers.NewDriverHandler(db)
	courier  := handlers.NewCourierHandler(db)
	restPanel := handlers.NewRestaurantPanelHandler(db)

	// ── Public routes ─────────────────────────────────────────────────────────
	public := r.Group("/api/v1")
	{
		public.POST("/auth/send-otp",    auth.SendOTP)
		public.POST("/auth/verify-otp",  auth.VerifyOTP)
		public.POST("/auth/register",    auth.Register)
		public.POST("/auth/login",       auth.Login)
		public.POST("/auth/google",      auth.LoginGoogle)
	}

	// ── Authenticated routes ──────────────────────────────────────────────────
	api := r.Group("/api/v1")
	api.Use(middleware.Auth(cfg.JWTSecret))
	{
		// Profile
		api.GET("/profile",             profile.Get)
		api.PUT("/profile",             profile.Update)
		api.GET("/profile/history",     profile.History)
		api.POST("/profile/push-token", profile.SavePushToken)

		// Taxi (client)
		api.POST("/taxi/estimate",          taxi.Estimate)
		api.POST("/taxi/orders",            taxi.CreateOrder)
		api.GET("/taxi/orders/:id",         taxi.GetOrder)
		api.POST("/taxi/orders/:id/cancel", taxi.CancelOrder)
		api.POST("/taxi/orders/:id/rate",   taxi.RateTrip)

		// Food (client)
		api.GET("/food/restaurants",               food.ListRestaurants)
		api.GET("/food/restaurants/:id",           food.GetRestaurant)
		api.POST("/food/orders",                   food.CreateOrder)
		api.GET("/food/orders/:id",                food.GetOrder)
		api.POST("/food/orders/:id/cancel",        food.CancelOrder)

		// Parcels (client)
		api.POST("/parcels/orders",               parcels.CreateOrder)
		api.GET("/parcels/orders/:id",            parcels.GetOrder)
		api.POST("/parcels/orders/:id/cancel",    parcels.CancelOrder)

		// Driver panel
		drv := api.Group("/driver")
		drv.Use(middleware.RequireRole("driver", "admin"))
		{
			drv.GET("/profile",           driver.GetProfile)
			drv.PUT("/profile",           driver.UpdateProfile)
			drv.POST("/status",           driver.SetStatus)
			drv.GET("/orders",            driver.AvailableOrders)
			drv.GET("/active",            driver.ActiveTrip)
			drv.POST("/orders/:id/accept", driver.AcceptOrder)
			drv.POST("/orders/:id/status", driver.UpdateTripStatus)
		}

		// Courier panel
		cur := api.Group("/courier")
		cur.Use(middleware.RequireRole("courier", "admin"))
		{
			cur.GET("/orders",              courier.AvailableOrders)
			cur.POST("/parcels/:id/accept", courier.AcceptParcel)
			cur.POST("/parcels/:id/status", courier.UpdateParcelStatus)
			cur.POST("/food/:id/accept",    courier.AcceptFoodOrder)
			cur.POST("/food/:id/status",    courier.UpdateFoodStatus)
		}

		// Restaurant panel
		rest := api.Group("/restaurant")
		rest.Use(middleware.RequireRole("restaurant", "admin"))
		{
			rest.GET("/orders",              restPanel.ListOrders)
			rest.POST("/orders/:id/status",  restPanel.UpdateOrderStatus)
			rest.PUT("/open",                restPanel.SetOpen)
		}
	}

	return r
}

func corsMiddleware(origins string) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", origins)
		c.Header("Access-Control-Allow-Methods", "GET,POST,PUT,PATCH,DELETE,OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Authorization,Content-Type")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	}
}
