enum DeliveryScope { doorToDoor, buildingToBuilding }

class ParcelContactModel {
  final String name;
  final String phone;
  final String address;
  final String? entrance;
  final String? floor;
  final String? apartment;
  final String? intercomCode;
  final String? comment;

  const ParcelContactModel({
    required this.name,
    required this.phone,
    required this.address,
    this.entrance,
    this.floor,
    this.apartment,
    this.intercomCode,
    this.comment,
  });

  bool get isComplete => name.isNotEmpty && phone.isNotEmpty && address.isNotEmpty;
}
