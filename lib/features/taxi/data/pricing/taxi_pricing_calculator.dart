import '../models/car_class_model.dart';

class TaxiPricingCalculator {
  static const Map<CityType, List<CarClassPricing>> _table = {
    CityType.smallCity: [
      CarClassPricing(carClass: CarClass.economy, minPrice: 500, kmRate: 60),
      CarClassPricing(carClass: CarClass.comfort, minPrice: 700, kmRate: 80),
      CarClassPricing(carClass: CarClass.comfortPlus, minPrice: 900, kmRate: 100),
      CarClassPricing(carClass: CarClass.business, minPrice: 1100, kmRate: 120),
      CarClassPricing(carClass: CarClass.eco, minPrice: 1035, kmRate: 115),
    ],
    CityType.bigCity: [
      CarClassPricing(carClass: CarClass.economy, minPrice: 1100, kmRate: 80),
      CarClassPricing(carClass: CarClass.comfort, minPrice: 1200, kmRate: 100),
      CarClassPricing(carClass: CarClass.comfortPlus, minPrice: 1300, kmRate: 120),
      CarClassPricing(carClass: CarClass.business, minPrice: 1500, kmRate: 150),
      CarClassPricing(carClass: CarClass.eco, minPrice: 1495, kmRate: 138),
    ],
  };

  static const double cardCommissionRate = 0.06;
  static const double taxRate = 0.04;

  static List<CarClassPricing> classesFor(CityType cityType) => _table[cityType]!;

  static int calculatePrice({required CityType cityType, required CarClass carClass, required double distanceKm}) {
    final pricing = _table[cityType]!.firstWhere((p) => p.carClass == carClass);
    return (pricing.minPrice + pricing.kmRate * distanceKm).round();
  }

  static int driverEarningsCard(int ridePrice) => (ridePrice * (1 - cardCommissionRate - taxRate)).round();

  static int driverEarningsCash(int ridePrice) => ridePrice;
}