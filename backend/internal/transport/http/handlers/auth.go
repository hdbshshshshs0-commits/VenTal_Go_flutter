package handlers

import (
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/jmoiron/sqlx"
	"github.com/vental-go/backend/internal/config"
	"github.com/vental-go/backend/internal/domain"
)

type AuthHandler struct {
	db  *sqlx.DB
	cfg *config.Config
}

func NewAuthHandler(db *sqlx.DB, cfg *config.Config) *AuthHandler {
	return &AuthHandler{db: db, cfg: cfg}
}

// POST /auth/send-otp
func (h *AuthHandler) SendOTP(c *gin.Context) {
	var req struct {
		Phone string `json:"phone" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	code := h.generateCode()
	expires := time.Now().Add(5 * time.Minute)

	_, err := h.db.Exec(
		`INSERT INTO otp_codes (phone, code, expires_at) VALUES ($1, $2, $3)`,
		req.Phone, code, expires,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "db error"})
		return
	}

	if !h.cfg.OTPStub {
		// TODO: send real SMS via h.cfg.SMSAPIKey
	}

	resp := gin.H{"message": "OTP sent"}
	if h.cfg.OTPStub {
		resp["debug_code"] = code // только в dev-режиме
	}
	c.JSON(http.StatusOK, resp)
}

// POST /auth/verify-otp
func (h *AuthHandler) VerifyOTP(c *gin.Context) {
	var req struct {
		Phone string `json:"phone" binding:"required"`
		Code  string `json:"code"  binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Stub mode
	if h.cfg.OTPStub && req.Code == h.cfg.OTPStubCode {
		return h.issueToken(c, req.Phone)
	}

	var record struct {
		ID        string    `db:"id"`
		ExpiresAt time.Time `db:"expires_at"`
		Used      bool      `db:"used"`
	}
	err := h.db.Get(&record,
		`SELECT id, expires_at, used FROM otp_codes
		 WHERE phone=$1 AND code=$2
		 ORDER BY created_at DESC LIMIT 1`,
		req.Phone, req.Code,
	)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid code"})
		return
	}
	if record.Used || time.Now().After(record.ExpiresAt) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "code expired or already used"})
		return
	}

	h.db.Exec(`UPDATE otp_codes SET used=true WHERE id=$1`, record.ID)
	h.issueToken(c, req.Phone)
}

func (h *AuthHandler) issueToken(c *gin.Context, phone string) {
	// Upsert user
	var user domain.User
	err := h.db.Get(&user, `SELECT * FROM users WHERE phone=$1`, phone)
	if err != nil {
		// create new user
		err = h.db.Get(&user,
			`INSERT INTO users (phone) VALUES ($1) RETURNING *`, phone)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "user create failed"})
			return
		}
	}

	token, err := h.mintJWT(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "token error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": token,
		"user":  user,
	})
}

func (h *AuthHandler) mintJWT(user domain.User) (string, error) {
	claims := jwt.MapClaims{
		"sub":  user.ID,
		"role": string(user.Role),
		"exp":  time.Now().Add(time.Duration(h.cfg.JWTTTLHours) * time.Hour).Unix(),
		"iat":  time.Now().Unix(),
	}
	t := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return t.SignedString([]byte(h.cfg.JWTSecret))
}

func (h *AuthHandler) generateCode() string {
	if h.cfg.OTPStub {
		return h.cfg.OTPStubCode
	}
	return fmt.Sprintf("%04d", rand.Intn(10000))
}
