package config

import (
	"os"
	"strconv"
)

type Config struct {
	Port             string
	Env              string
	DatabaseURL      string
	JWTSecret        string
	JWTTTLHours      int
	PricingEngineURL string
	OTPStub          bool
	OTPStubCode      string
	SMSAPIKey        string
	AllowedOrigins   string
}

func Load() *Config {
	jwtTTL, _ := strconv.Atoi(getEnv("JWT_TTL_HOURS", "720"))
	otpStub, _ := strconv.ParseBool(getEnv("OTP_STUB", "true"))

	return &Config{
		Port:             getEnv("PORT", "8080"),
		Env:              getEnv("ENV", "development"),
		DatabaseURL:      getEnv("DATABASE_URL", ""),
		JWTSecret:        getEnv("JWT_SECRET", "change-me"),
		JWTTTLHours:      jwtTTL,
		PricingEngineURL: getEnv("PRICING_ENGINE_URL", "http://localhost:8000"),
		OTPStub:          otpStub,
		OTPStubCode:      getEnv("OTP_STUB_CODE", "1234"),
		SMSAPIKey:        getEnv("SMS_API_KEY", ""),
		AllowedOrigins:   getEnv("ALLOWED_ORIGINS", "*"),
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
