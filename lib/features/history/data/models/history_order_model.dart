enum HistoryOrderCategory { delivery, taxi, food, parcels }

class HistoryOrderModel {
  final String orderNumber;
  final String date;
  final String title;
  final int price;
  final HistoryOrderCategory category;

  const HistoryOrderModel({
    required this.orderNumber,
    required this.date,
    required this.title,
    required this.price,
    required this.category,
  });
}

/// TODO: заменить на реальные данные с бэкенда — сейчас это моки для UI.
class HistoryMockData {
  static const List<HistoryOrderModel> orders = [
    HistoryOrderModel(orderNumber: '#20491', date: '12 мая, 18:45', title: 'KFC', price: 3400, category: HistoryOrderCategory.food),
    HistoryOrderModel(orderNumber: '#20490', date: '9 мая, 14:20', title: 'Поездка эконом', price: 1652, category: HistoryOrderCategory.taxi),
    HistoryOrderModel(orderNumber: '#20489', date: '5 мая, 20:10', title: 'Посылка', price: 900, category: HistoryOrderCategory.parcels),
    HistoryOrderModel(orderNumber: '#20488', date: '1 мая, 13:30', title: 'KFC', price: 3400, category: HistoryOrderCategory.food),
  ];
}