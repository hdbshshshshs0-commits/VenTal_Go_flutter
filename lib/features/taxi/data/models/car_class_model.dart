enum CityType { smallCity, bigCity }

enum CarClass { economy, comfort, comfortPlus, business, eco }

class CarClassPricing {
  final CarClass carClass;
  final int minPrice;
  final int kmRate;

  const CarClassPricing({required this.carClass, required this.minPrice, required this.kmRate});
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
      case CarClass.eco:
        return 'car_class_eco';
    }
  }
}