class FoodPricingCalculator {
  static const int minOrderAmount = 3500;
  static const int freeDeliveryThreshold = 7000;
  static const int largeOrderThreshold = 13000;

  static const double serviceFeeStandard = 0.05;
  static const double serviceFeeLargeOrder = 0.035;

  static const int courierBaseFee = 700;
  static const Map<String, int> courierKmRateByTransport = {
    'walk': 60,
    'bike': 80,
    'scooter': 80,
    'ebike': 80,
    'car': 100,
  };

  static double serviceFeeRate(int subtotal) => subtotal > largeOrderThreshold ? serviceFeeLargeOrder : serviceFeeStandard;

  static int serviceFeeAmount(int subtotal) => (subtotal * serviceFeeRate(subtotal)).round();

  static bool isDeliveryFree(int subtotal) => subtotal >= freeDeliveryThreshold;

  static int calculateTotal(int subtotal) {
    final fee = serviceFeeAmount(subtotal);
    return subtotal + fee;
  }
}
