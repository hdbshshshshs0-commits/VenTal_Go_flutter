class ServiceTileModel {
  final String id;
  final String labelKey;
  final String iconPath;
  final int sortOrder;

  const ServiceTileModel({
    required this.id,
    required this.labelKey,
    required this.iconPath,
    this.sortOrder = 0,
  });
}
