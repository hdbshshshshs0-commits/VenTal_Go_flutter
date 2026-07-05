enum ParcelCategory { upTo5kg, from5to20kg, from30kg }

enum ParcelDeliveryType { toAddress, doorToDoor }

extension ParcelCategoryLabel on ParcelCategory {
  String get titleKey {
    switch (this) {
      case ParcelCategory.upTo5kg:
        return 'parcel_category_up_to_5kg';
      case ParcelCategory.from5to20kg:
        return 'parcel_category_5_20kg';
      case ParcelCategory.from30kg:
        return 'parcel_category_30kg_plus';
    }
  }
}

extension ParcelDeliveryTypeLabel on ParcelDeliveryType {
  String get titleKey {
    switch (this) {
      case ParcelDeliveryType.toAddress:
        return 'parcel_delivery_to_address';
      case ParcelDeliveryType.doorToDoor:
        return 'parcel_delivery_door_to_door';
    }
  }
}
