enum PaymentMethod { card, cash, kaspiTransfer, halykTransfer }

extension PaymentMethodLabel on PaymentMethod {
  String get stringKey {
    switch (this) {
      case PaymentMethod.card:
        return 'payment_card';
      case PaymentMethod.cash:
        return 'payment_cash';
      case PaymentMethod.kaspiTransfer:
        return 'payment_kaspi_transfer';
      case PaymentMethod.halykTransfer:
        return 'payment_halyk_transfer';
    }
  }

  String get iconPath {
    switch (this) {
      case PaymentMethod.card:
        return 'assets/images/icons/payment_card.png';
      case PaymentMethod.cash:
        return 'assets/images/icons/payment_cash.png';
      case PaymentMethod.kaspiTransfer:
        return 'assets/images/icons/payment_kaspi.png';
      case PaymentMethod.halykTransfer:
        return 'assets/images/icons/payment_halyk.png';
    }
  }
}
