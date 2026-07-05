class RestaurantModel {
  final String id;
  final String name;
  final String imagePath;
  final double rating;
  final int deliveryTimeMin;
  final int minOrderAmount;
  final bool freeDelivery;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.deliveryTimeMin,
    required this.minOrderAmount,
    required this.freeDelivery,
  });
}
