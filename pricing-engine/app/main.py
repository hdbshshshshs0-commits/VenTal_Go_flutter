from fastapi import FastAPI
from app.models import PriceRequest, PriceResponse, PriceBreakdown
from app.pricing import (
    calculate_price,
    calculate_price_breakdown,
    calculate_driver_payout,
    calculate_company_revenue,
    calculate_tax_withheld,
)
from app.demand import calculate_demand_multiplier, ZoneDemand

app = FastAPI()


@app.post("/calculate-price", response_model=PriceResponse)
def calculate(request: PriceRequest):
    zone = ZoneDemand(
        active_orders=request.zone_active_orders,
        free_drivers=request.zone_free_drivers,
    )
    multiplier = calculate_demand_multiplier(zone)

    price = calculate_price(
        request.car_class,
        request.distance_km,
        request.duration_min,
        demand_multiplier=multiplier,
    )

    breakdown = calculate_price_breakdown(
        request.car_class,
        request.distance_km,
        request.duration_min,
        demand_multiplier=multiplier,
    )

    return PriceResponse(
        price=price,
        driver_payout=calculate_driver_payout(price, request.payment_method),
        company_revenue=calculate_company_revenue(price, request.payment_method),
        tax_withheld=calculate_tax_withheld(price, request.payment_method),
        demand_multiplier=multiplier,
        breakdown=PriceBreakdown(**breakdown),
    )


@app.get("/health")
def health():
    return {"status": "ok"}