import 'package:maplibre_gl/maplibre_gl.dart';
import 'car_class_model.dart';
import 'payment_method_model.dart';

enum RideStatus { searching, driverAssigned, driverArriving, inProgress, completed, cancelled }

class RideModel {
  final String id;
  final LatLng fromPosition;
  final LatLng toPosition;
  final String fromAddress;
  final String toAddress;
  final double distanceKm;
  final CarClass carClass;
  final PaymentMethod paymentMethod;
  final int price;
  final RideStatus status;

  const RideModel({
    required this.id,
    required this.fromPosition,
    required this.toPosition,
    required this.fromAddress,
    required this.toAddress,
    required this.distanceKm,
    required this.carClass,
    required this.paymentMethod,
    required this.price,
    this.status = RideStatus.searching,
  });
}
