enum RestaurantOrderStatus { newOrder, accepted, cooking, ready, givenToCourier }

extension RestaurantOrderStatusLabel on RestaurantOrderStatus {
  String get titleKey {
    switch (this) {
      case RestaurantOrderStatus.newOrder:
        return 'restaurant_status_new';
      case RestaurantOrderStatus.accepted:
        return 'restaurant_status_accepted';
      case RestaurantOrderStatus.cooking:
        return 'restaurant_status_cooking';
      case RestaurantOrderStatus.ready:
        return 'restaurant_status_ready';
      case RestaurantOrderStatus.givenToCourier:
        return 'restaurant_status_given_to_courier';
    }
  }

  String get actionLabelKey {
    switch (this) {
      case RestaurantOrderStatus.newOrder:
        return 'restaurant_accept_order';
      case RestaurantOrderStatus.accepted:
        return 'restaurant_mark_cooking';
      case RestaurantOrderStatus.cooking:
        return 'restaurant_mark_ready';
      case RestaurantOrderStatus.ready:
        return 'restaurant_mark_given';
      case RestaurantOrderStatus.givenToCourier:
        return '';
    }
  }

  RestaurantOrderStatus? get next {
    switch (this) {
      case RestaurantOrderStatus.newOrder:
        return RestaurantOrderStatus.accepted;
      case RestaurantOrderStatus.accepted:
        return RestaurantOrderStatus.cooking;
      case RestaurantOrderStatus.cooking:
        return RestaurantOrderStatus.ready;
      case RestaurantOrderStatus.ready:
        return RestaurantOrderStatus.givenToCourier;
      case RestaurantOrderStatus.givenToCourier:
        return null;
    }
  }
}

class RestaurantOrderModel {
  final String id;
  final String clientName;
  final int total;
  RestaurantOrderStatus status;

  RestaurantOrderModel({required this.id, required this.clientName, required this.total, required this.status});
}
