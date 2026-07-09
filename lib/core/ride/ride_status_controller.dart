import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:vental_go/data/models/ride_status_model.dart';
import 'package:vental_go/data/models/driver_model.dart';

class RideStatusController extends ChangeNotifier {
  RideStatus _status = RideStatus.searching;
  RideStatus get status => _status;

  DriverInfo? _driver;
  DriverInfo? get driver => _driver;

  bool _passengerConfirmedExit = false;
  bool get passengerConfirmedExit => _passengerConfirmedExit;

  Timer? _timer;

  void startSearching() {
    _status = RideStatus.searching;
    _passengerConfirmedExit = false;
    notifyListeners();

    // TODO: заменить на реальный запрос к бэкенду поиска водителя
    _timer = Timer(const Duration(seconds: 4), () {
      _driver = const DriverInfo(
        name: 'Ерлан Ахметов',
        avatarUrl: 'assets/images/drivers/placeholder_avatar.png',
        carModel: 'Toyota Camry, белый',
        carPlate: '123 ABC 02',
        phoneNumber: '+77001234567',
        rating: 4.9,
        etaMinutes: 4,
      );
      _status = RideStatus.driverAssigned;
      notifyListeners();
      _simulateHeading();
    });
  }

  void _simulateHeading() {
    _status = RideStatus.driverHeading;
    notifyListeners();

    // TODO: заменить на реальные апдейты статуса от водителя
    _timer = Timer(const Duration(seconds: 5), () {
      _status = RideStatus.driverArrived;
      notifyListeners();
    });
  }

  /// Клиент нажимает "Выхожу" — только после этого статус может пойти дальше.
  void confirmPassengerExit() {
    if (_status != RideStatus.driverArrived) return;
    _passengerConfirmedExit = true;
    notifyListeners();

    // TODO: отправка события на бэкенд, чтобы у водителя разблокировались статусы
    _timer = Timer(const Duration(seconds: 3), () {
      _status = RideStatus.tripInProgress;
      notifyListeners();
    });
  }

  void cancelSearch() {
    _timer?.cancel();
  }

  void completeTrip() {
    _status = RideStatus.completed;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
