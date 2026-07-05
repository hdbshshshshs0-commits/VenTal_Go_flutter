import '../models/parcel_model.dart';

class ParcelPricingCalculator {
  static const Map<ParcelCategory, int> _basePrices = {
    ParcelCategory.upTo5kg: 800,
    ParcelCategory.from5to20kg: 1200,
    ParcelCategory.from30kg: 2500,
  };

  static const int doorToDoorSurcharge = 300;

  static int calculate({required ParcelCategory category, required ParcelDeliveryType deliveryType}) {
    final base = _basePrices[category]!;
    final surcharge = deliveryType == ParcelDeliveryType.doorToDoor ? doorToDoorSurcharge : 0;
    return base + surcharge;
  }
}
