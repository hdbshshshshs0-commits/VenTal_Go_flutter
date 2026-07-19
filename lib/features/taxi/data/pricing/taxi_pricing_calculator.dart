import '../models/car_class_model.dart';

class PriceBreakdown {
  final double boarding;
  final double distanceCost;
  final double timeCost;
  final double baseTotal;
  final double demandMultiplier;
  final bool multiplierApplied;
  final double finalTotal;

  const PriceBreakdown({
    required this.boarding,
    required this.distanceCost,
    required this.timeCost,
    required this.baseTotal,
    required this.demandMultiplier,
    required this.multiplierApplied,
    required this.finalTotal,
  });
}

class TaxiPricingCalculator {
  // Единая тарифная сетка — цена не зависит от города (честная фикс. цена).
  static const List<CarClassPricing> _table = [
    CarClassPricing(carClass: CarClass.economy, boarding: 600, perKm: 60, perMin: 10, photoPath: 'assets/images/cars/economy.png'),
    CarClassPricing(carClass: CarClass.comfort, boarding: 700, perKm: 70, perMin: 12, photoPath: 'assets/images/cars/comfort.png'),
    CarClassPricing(carClass: CarClass.comfortPlus, boarding: 800, perKm: 80, perMin: 15, photoPath: 'assets/images/cars/comfort_plus.png'),
    CarClassPricing(carClass: CarClass.business, boarding: 1200, perKm: 130, perMin: 25, photoPath: 'assets/images/cars/business.png'),
    CarClassPricing(carClass: CarClass.premium, boarding: 1200, perKm: 200, perMin: 30, photoPath: 'assets/images/cars/premium.png'),
    CarClassPricing(carClass: CarClass.eco, boarding: 700, perKm: 70, perMin: 12, photoPath: 'assets/images/cars/eco.png'),
  ];

  // Множитель спроса действует ТОЛЬКО в диапазоне (3 км; 15 км].
  static const double demandMultiplierMinKm = 3.0;
  static const double demandMultiplierMaxKm = 15.0;

  /// cityType сохранён в сигнатуре для обратной совместимости вызовов,
  /// но больше не влияет на цену — тариф единый по всей стране.
  static List<CarClassPricing> classesFor(CityType cityType) => _table;

  static CarClassPricing pricingFor(CarClass carClass) {
    return _table.firstWhere((p) => p.carClass == carClass);
  }

  static bool _isInMultiplierZone(double distanceKm) {
    return distanceKm > demandMultiplierMinKm && distanceKm <= demandMultiplierMaxKm;
  }

  static double calculatePrice({
    required CityType cityType,
    required CarClass carClass,
    required double distanceKm,
    double durationMin = 0,
    double demandMultiplier = 1.0,
  }) {
    final pricing = pricingFor(carClass);
    final baseTotal = pricing.boarding + pricing.perKm * distanceKm + pricing.perMin * durationMin;

    if (_isInMultiplierZone(distanceKm)) {
      return baseTotal * demandMultiplier;
    }
    return baseTotal;
  }

  static PriceBreakdown calculateBreakdown({
    required CarClass carClass,
    required double distanceKm,
    double durationMin = 0,
    double demandMultiplier = 1.0,
  }) {
    final pricing = pricingFor(carClass);
    final distanceCost = pricing.perKm * distanceKm;
    final timeCost = pricing.perMin * durationMin;
    final baseTotal = pricing.boarding + distanceCost + timeCost;

    final multiplierApplied = _isInMultiplierZone(distanceKm);
    final finalTotal = multiplierApplied ? baseTotal * demandMultiplier : baseTotal;

    return PriceBreakdown(
      boarding: pricing.boarding,
      distanceCost: distanceCost,
      timeCost: timeCost,
      baseTotal: baseTotal,
      demandMultiplier: multiplierApplied ? demandMultiplier : 1.0,
      multiplierApplied: multiplierApplied,
      finalTotal: finalTotal,
    );
  }
}