import 'package:maplibre_gl/maplibre_gl.dart';

class ParcelAddressDetails {
  final String address;
  final LatLng coordinates;
  final String entrance;
  final String floor;
  final String apartment;
  final String intercom;

  const ParcelAddressDetails({
    required this.address,
    required this.coordinates,
    this.entrance = '',
    this.floor = '',
    this.apartment = '',
    this.intercom = '',
  });
}