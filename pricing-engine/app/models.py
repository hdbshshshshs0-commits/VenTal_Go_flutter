from pydantic import BaseModel
from app.pricing import CarClass, PaymentMethod


class PriceRequest(BaseModel):
    car_class: CarClass
    distance_km: float
    duration_min: float
    payment_method: PaymentMethod
    zone_active_orders: int
    zone_free_drivers: int


class PriceBreakdown(BaseModel):
    boarding: float
    distance_cost: float
    time_cost: float
    base_total: float
    demand_multiplier: float
    multiplier_applied: bool
    final_total: float


class PriceResponse(BaseModel):
    price: float
    driver_payout: float
    company_revenue: float
    tax_withheld: float
    demand_multiplier: float
    breakdown: PriceBreakdown