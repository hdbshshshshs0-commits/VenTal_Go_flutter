from dataclasses import dataclass

MIN_MULTIPLIER = 1.0
MAX_MULTIPLIER = 2.0


@dataclass
class ZoneDemand:
    active_orders: int
    free_drivers: int


def calculate_demand_multiplier(zone: ZoneDemand) -> float:
    if zone.free_drivers <= 0:
        if zone.active_orders <= 0:
            return MIN_MULTIPLIER
        return min(1.5, MAX_MULTIPLIER)

    ratio = zone.active_orders / zone.free_drivers

    if ratio <= 1:
        return MIN_MULTIPLIER
    multiplier = MIN_MULTIPLIER + (ratio - 1) * 0.1
    return round(min(multiplier, MAX_MULTIPLIER), 2)