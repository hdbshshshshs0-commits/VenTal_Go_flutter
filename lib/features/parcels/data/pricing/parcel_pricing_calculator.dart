import '../models/parcel_pricing_model.dart';

class ParcelPriceBreakdown {
  final double clientPrice;
  final double distanceKm;
  final double perKm;
  final bool isFixedPrice;

  const ParcelPriceBreakdown({
    required this.clientPrice,
    required this.distanceKm,
    required this.perKm,
    required this.isFixedPrice,
  });
}

class ParcelPricingCalculator {
  static const List<ParcelPricingRow> table = [
    // Машина (до 25 кг — свыше это уже отдельный транспорт "Грузовая")
    ParcelPricingRow(transport: ParcelTransport.car, id: 'light', weightLabelKey: 'parcel_weight_up_to_5kg', clientBase: 1000, courierPayout: 700, companyIncome: 300, perKm: 80),
    ParcelPricingRow(transport: ParcelTransport.car, id: 'medium', weightLabelKey: 'parcel_weight_5_15kg', clientBase: 2000, courierPayout: 1500, companyIncome: 500, perKm: 100),
    ParcelPricingRow(transport: ParcelTransport.car, id: 'large', weightLabelKey: 'parcel_weight_15_25kg', clientBase: 3500, courierPayout: 3000, companyIncome: 500, perKm: 0, isFixedPrice: true),
    // Грузовая (25+ кг) — отдельный транспорт, фикс. цена
    ParcelPricingRow(transport: ParcelTransport.truck, id: 'truck', weightLabelKey: 'parcel_weight_25kg_plus', clientBase: 6000, courierPayout: 5000, companyIncome: 1000, perKm: 0, isFixedPrice: true),
    // Скутер/вело (максимум 15 кг)
    ParcelPricingRow(transport: ParcelTransport.scooter, id: 'light', weightLabelKey: 'parcel_weight_up_to_5kg', clientBase: 700, courierPayout: 550, companyIncome: 150, perKm: 50),
    ParcelPricingRow(transport: ParcelTransport.scooter, id: 'medium', weightLabelKey: 'parcel_weight_5_15kg', clientBase: 1200, courierPayout: 1000, companyIncome: 200, perKm: 60),
    // Пеший (максимум 5 кг)
    ParcelPricingRow(transport: ParcelTransport.walking, id: 'light', weightLabelKey: 'parcel_weight_up_to_5kg', clientBase: 500, courierPayout: 400, companyIncome: 100, perKm: 40),
  ];

  static List<ParcelPricingRow> rowsFor(ParcelTransport transport) {
    return table.where((r) => r.transport == transport).toList();
  }

  static ParcelPricingRow rowById(ParcelTransport transport, String id) {
    return table.firstWhere((r) => r.transport == transport && r.id == id);
  }

  static ParcelPriceBreakdown calculate({
    required ParcelTransport transport,
    required String weightId,
    required double distanceKm,
  }) {
    final row = rowById(transport, weightId);
    final distanceCost = row.isFixedPrice ? 0.0 : row.perKm * distanceKm;
    final clientPrice = row.clientBase + distanceCost;

    return ParcelPriceBreakdown(
      clientPrice: clientPrice,
      distanceKm: distanceKm,
      perKm: row.perKm,
      isFixedPrice: row.isFixedPrice,
    );
  }
}