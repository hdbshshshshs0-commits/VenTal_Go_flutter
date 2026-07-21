package main

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/joho/godotenv"
	"github.com/vental-go/backend/internal/config"
	"github.com/vental-go/backend/internal/db"
	httpTransport "github.com/vental-go/backend/internal/transport/http"
	"github.com/vental-go/backend/pkg/logger"
)

func main() {
	// Load .env (ignore error in production — envs come from platform)
	_ = godotenv.Load()

	cfg := config.Load()
	log := logger.New(cfg.Env)

	if cfg.DatabaseURL == "" {
		log.Error("DATABASE_URL is not set")
		os.Exit(1)
	}

	// Connect to database
	database, err := db.New(cfg.DatabaseURL)
	if err != nil {
		log.Error("failed to connect to database", "error", err)
		os.Exit(1)
	}
	defer database.Close()
	log.Info("connected to database")

	// Run migrations
	if err := db.Migrate(database); err != nil {
		log.Error("migration failed", "error", err)
		os.Exit(1)
	}
	log.Info("migrations applied")

	// Build router
	router := httpTransport.NewRouter(database, cfg)

	srv := &http.Server{
		Addr:         fmt.Sprintf("0.0.0.0:%s", cfg.Port),
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server
	go func() {
		log.Info("server starting", "port", cfg.Port, "env", cfg.Env)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Error("server error", "error", err)
			os.Exit(1)
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Info("shutting down...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Error("shutdown error", "error", err)
	}
	log.Info("server stopped")
}
