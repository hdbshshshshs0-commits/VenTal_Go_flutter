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
	"golang.org/x/crypto/bcrypt"
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
		resp["debug_code"] = code
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
	if h.cfg.OTPStub && req.Code == h.cfg.OTPStubCode {
		h.issueToken(c, req.Phone)
		return
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

// POST /auth/register — name + phone + password
func (h *AuthHandler) Register(c *gin.Context) {
	var req struct {
		Phone    string `json:"phone"    binding:"required"`
		Name     string `json:"name"     binding:"required"`
		Password string `json:"password" binding:"required,min=6"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var count int
	h.db.Get(&count, `SELECT COUNT(*) FROM users WHERE phone=$1`, req.Phone)
	if count > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "phone already registered"})
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "password hashing failed"})
		return
	}

	var user domain.User
	err = h.db.Get(&user,
		`INSERT INTO users (phone, name, password_hash)
		 VALUES ($1, $2, $3) RETURNING id, phone, name, avatar_url, role, city_id, rating, is_active, created_at, updated_at`,
		req.Phone, req.Name, string(hash),
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "registration failed"})
		return
	}

	token, err := h.mintJWT(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "token error"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"token": token, "user": user})
}

// POST /auth/login — phone + password
func (h *AuthHandler) Login(c *gin.Context) {
	var req struct {
		Phone    string `json:"phone"    binding:"required"`
		Password string `json:"password" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Fetch user including password_hash
	type userWithHash struct {
		domain.User
		Hash *string `db:"password_hash"`
	}
	var uh userWithHash
	err := h.db.Get(&uh,
		`SELECT id, phone, name, avatar_url, role, city_id, rating, is_active, created_at, updated_at, password_hash
		 FROM users WHERE phone=$1`, req.Phone,
	)
	if err != nil || uh.Hash == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}
	if bcrypt.CompareHashAndPassword([]byte(*uh.Hash), []byte(req.Password)) != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	token, err := h.mintJWT(uh.User)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "token error"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"token": token, "user": uh.User})
}

// POST /auth/google — Google ID token → JWT
func (h *AuthHandler) LoginGoogle(c *gin.Context) {
	var req struct {
		GoogleID string `json:"google_id" binding:"required"`
		Name     string `json:"name"`
		Email    string `json:"email"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: validate IDToken via Google's tokeninfo endpoint before trusting google_id

	var user domain.User
	err := h.db.Get(&user,
		`SELECT id, phone, name, avatar_url, role, city_id, rating, is_active, created_at, updated_at
		 FROM users WHERE google_id=$1`, req.GoogleID,
	)
	if err != nil {
		// New Google user — upsert
		err = h.db.Get(&user,
			`INSERT INTO users (phone, name, google_id)
			 VALUES ($1, $2, $3)
			 ON CONFLICT (phone) DO UPDATE SET google_id=EXCLUDED.google_id, name=COALESCE(users.name, EXCLUDED.name)
			 RETURNING id, phone, name, avatar_url, role, city_id, rating, is_active, created_at, updated_at`,
			req.Email, req.Name, req.GoogleID,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "user upsert failed"})
			return
		}
	}

	token, err := h.mintJWT(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "token error"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"token": token, "user": user})
}

func (h *AuthHandler) issueToken(c *gin.Context, phone string) {
	var user domain.User
	err := h.db.Get(&user,
		`SELECT id, phone, name, avatar_url, role, city_id, rating, is_active, created_at, updated_at
		 FROM users WHERE phone=$1`, phone,
	)
	if err != nil {
		err = h.db.Get(&user,
			`INSERT INTO users (phone)
			 VALUES ($1)
			 RETURNING id, phone, name, avatar_url, role, city_id, rating, is_active, created_at, updated_at`,
			phone,
		)
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
	c.JSON(http.StatusOK, gin.H{"token": token, "user": user})
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
