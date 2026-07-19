enum CityType { smallCity, bigCity }

enum CarClass { economy, comfort, comfortPlus, business, premium, eco }

class CarClassPricing {
  final CarClass carClass;
  final double boarding;
  final double perKm;
  final double perMin;
  final String photoPath;

  const CarClassPricing({
    required this.carClass,
    required this.boarding,
    required this.perKm,
    required this.perMin,
    required this.photoPath,
  });
}

extension CarClassLabel on CarClass {
  String get stringKey {
    switch (this) {
      case CarClass.economy:
        return 'car_class_economy';
      case CarClass.comfort:
        return 'car_class_comfort';
      case CarClass.comfortPlus:
        return 'car_class_comfort_plus';
      case CarClass.business:
        return 'car_class_business';
      case CarClass.premium:
        return 'car_class_premium';
      case CarClass.eco:
        return 'car_class_eco';
    }
  }
}