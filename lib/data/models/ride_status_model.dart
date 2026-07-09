enum RideStatus {
  searching,
  driverAssigned,
  driverHeading,
  driverArrived,
  tripInProgress,
  completed,
}

extension RideStatusLabel on RideStatus {
  String get stringKey {
    switch (this) {
      case RideStatus.searching:
        return 'ride_status_searching';
      case RideStatus.driverAssigned:
        return 'ride_status_assigned';
      case RideStatus.driverHeading:
        return 'ride_status_heading';
      case RideStatus.driverArrived:
        return 'ride_status_arrived';
      case RideStatus.tripInProgress:
        return 'ride_status_in_progress';
      case RideStatus.completed:
        return 'ride_status_completed';
    }
  }
}
