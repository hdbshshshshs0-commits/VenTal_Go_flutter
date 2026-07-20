enum ParcelTransport { walking, scooter, car, truck }

extension ParcelTransportLabel on ParcelTransport {
  String get stringKey {
    switch (this) {
      case ParcelTransport.walking:
        return 'parcel_transport_walking';
      case ParcelTransport.scooter:
        return 'parcel_transport_scooter';
      case ParcelTransport.car:
        return 'parcel_transport_car';
      case ParcelTransport.truck:
        return 'parcel_transport_truck';
    }
  }

  String get iconAsset {
    switch (this) {
      case ParcelTransport.walking:
        return 'assets/images/icons/parcel_walking.png';
      case ParcelTransport.scooter:
        return 'assets/images/icons/parcel_scooter.png';
      case ParcelTransport.car:
        return 'assets/images/icons/parcel_car.png';
      case ParcelTransport.truck:
        return 'assets/images/icons/parcel_truck.png';
    }
  }

  String get maxWeightLabelKey {
    switch (this) {
      case ParcelTransport.walking:
        return 'parcel_weight_up_to_5kg';
      case ParcelTransport.scooter:
        return 'parcel_weight_up_to_15kg';
      case ParcelTransport.car:
        return 'parcel_weight_up_to_25kg';
      case ParcelTransport.truck:
        return 'parcel_weight_25kg_plus';
    }
  }
}

class ParcelPricingRow {
  final ParcelTransport transport;
  final String id; // уникален в рамках транспорта: 'light' | 'medium' | 'large' | 'truck'
  final String weightLabelKey;
  final double clientBase;
  final double courierPayout;
  final double companyIncome;
  final double perKm; // 0, если фикс
  final bool isFixedPrice;

  const ParcelPricingRow({
    required this.transport,
    required this.id,
    required this.weightLabelKey,
    required this.clientBase,
    required this.courierPayout,
    required this.companyIncome,
    required this.perKm,
    this.isFixedPrice = false,
  });
}