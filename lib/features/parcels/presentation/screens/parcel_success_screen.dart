import 'package:flutter/material.dart';

import 'package:vental_go/core/widgets/order_success_screen.dart';

class ParcelSuccessScreen extends StatelessWidget {
  const ParcelSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrderSuccessScreen(
      titleKey: 'parcel_success_title',
      subtitleKey: 'parcel_success_subtitle',
    );
  }
}
