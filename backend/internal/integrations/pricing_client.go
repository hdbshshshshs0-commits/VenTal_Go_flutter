package integrations

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type PriceRequest struct {
	CarClass         string  `json:"car_class"`
	DistanceKm       float64 `json:"distance_km"`
	DurationMin      float64 `json:"duration_min"`
	PaymentMethod    string  `json:"payment_method"`
	ZoneActiveOrders int     `json:"zone_active_orders"`
	ZoneFreeDrivers  int     `json:"zone_free_drivers"`
}

type PriceBreakdown struct {
	Boarding          float64 `json:"boarding"`
	DistanceCost      float64 `json:"distance_cost"`
	TimeCost          float64 `json:"time_cost"`
	BaseTotal         float64 `json:"base_total"`
	DemandMultiplier  float64 `json:"demand_multiplier"`
	MultiplierApplied bool    `json:"multiplier_applied"`
	FinalTotal        float64 `json:"final_total"`
}

type PriceResponse struct {
	Price            float64        `json:"price"`
	DriverPayout     float64        `json:"driver_payout"`
	CompanyRevenue   float64        `json:"company_revenue"`
	TaxWithheld      float64        `json:"tax_withheld"`
	DemandMultiplier float64        `json:"demand_multiplier"`
	Breakdown        PriceBreakdown `json:"breakdown"`
}

type PricingClient struct {
	baseURL string
	client  *http.Client
}

func NewPricingClient(baseURL string) *PricingClient {
	return &PricingClient{
		baseURL: baseURL,
		client:  &http.Client{Timeout: 5 * time.Second},
	}
}

func (c *PricingClient) Calculate(req PriceRequest) (*PriceResponse, error) {
	body, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("marshal: %w", err)
	}

	resp, err := c.client.Post(c.baseURL+"/calculate-price", "application/json", bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("pricing engine returned %d", resp.StatusCode)
	}

	var result PriceResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("decode: %w", err)
	}
	return &result, nil
}
