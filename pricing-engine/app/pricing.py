from dataclasses import dataclass
from enum import Enum


class CarClass(str, Enum):
    ECONOMY = "economy"
    COMFORT = "comfort"
    COMFORT_PLUS = "comfort_plus"
    BUSINESS = "business"
    ECO = "eco"


class PaymentMethod(str, Enum):
    CASH = "cash"
    KASPI_TRANSFER = "kaspi_transfer"
    HALYK_TRANSFER = "halyk_transfer"
    CARD = "card"


@dataclass(frozen=True)
class ClassPricing:
    boarding: float   # посадка, тг
    per_km: float      # тг за км
    per_min: float       # тг за минуту


# ==== ТАРИФНАЯ СЕТКА ПО КЛАССАМ ====
PRICING_TABLE: dict[CarClass, ClassPricing] = {
    CarClass.ECONOMY: ClassPricing(boarding=600, per_km=60, per_min=10),
    CarClass.COMFORT: ClassPricing(boarding=700, per_km=70, per_min=12),
    CarClass.COMFORT_PLUS: ClassPricing(boarding=800, per_km=80, per_min=15),
    CarClass.BUSINESS: ClassPricing(boarding=1000, per_km=100, per_min=20),
    CarClass.ECO: ClassPricing(boarding=700, per_km=70, per_min=12),
}

# Порог, после которого начинает действовать множитель спроса.
# До этого расстояния — всегда честная база, без наценок.
DEMAND_MULTIPLIER_THRESHOLD_KM = 3.0

# ==== КОМИССИИ ПЛАТФОРМЫ ====
CASH_LIKE_WITHHOLDING_RATE = 0.04  # налог самозанятого, транзитом в бюджет

CARD_WITHHOLDING_RATE = 0.10        # 4% налог + 6% комиссия компании
CARD_COMPANY_SHARE_RATE = 0.06


def get_pricing(car_class: CarClass) -> ClassPricing:
    return PRICING_TABLE[car_class]


def calculate_price(
    car_class: CarClass,
    distance_km: float,
    duration_min: float,
    demand_multiplier: float = 1.0,
) -> float:
    """
    price = посадка + км*тариф_км + мин*тариф_мин

    До DEMAND_MULTIPLIER_THRESHOLD_KM (3 км) множитель НЕ применяется.
    Свыше порога — вся сумма умножается на demand_multiplier.
    """
    if distance_km < 0 or duration_min < 0:
        raise ValueError("distance_km и duration_min не могут быть отрицательными")
    if demand_multiplier < 1.0:
        raise ValueError("demand_multiplier не может быть меньше 1.0")

    pricing = get_pricing(car_class)
    base_price = pricing.boarding + distance_km * pricing.per_km + duration_min * pricing.per_min

    if distance_km <= DEMAND_MULTIPLIER_THRESHOLD_KM:
        return round(base_price, 2)

    return round(base_price * demand_multiplier, 2)


def calculate_price_breakdown(
    car_class: CarClass,
    distance_km: float,
    duration_min: float,
    demand_multiplier: float = 1.0,
) -> dict:
    pricing = get_pricing(car_class)
    boarding = pricing.boarding
    distance_cost = round(distance_km * pricing.per_km, 2)
    time_cost = round(duration_min * pricing.per_min, 2)
    base_total = round(boarding + distance_cost + time_cost, 2)

    multiplier_applied = distance_km > DEMAND_MULTIPLIER_THRESHOLD_KM
    final_total = round(base_total * demand_multiplier, 2) if multiplier_applied else base_total

    return {
        "boarding": boarding,
        "distance_cost": distance_cost,
        "time_cost": time_cost,
        "base_total": base_total,
        "demand_multiplier": demand_multiplier if multiplier_applied else 1.0,
        "multiplier_applied": multiplier_applied,
        "final_total": final_total,
    }


def calculate_driver_payout(price: float, payment_method: PaymentMethod) -> float:
    if payment_method == PaymentMethod.CARD:
        return round(price * (1 - CARD_WITHHOLDING_RATE), 2)
    return round(price * (1 - CASH_LIKE_WITHHOLDING_RATE), 2)


def calculate_company_revenue(price: float, payment_method: PaymentMethod) -> float:
    if payment_method == PaymentMethod.CARD:
        return round(price * CARD_COMPANY_SHARE_RATE, 2)
    return 0.0


def calculate_tax_withheld(price: float, payment_method: PaymentMethod) -> float:
    return round(price * CASH_LIKE_WITHHOLDING_RATE, 2)