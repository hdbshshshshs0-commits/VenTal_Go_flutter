import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import '../../data/models/courier_order_status.dart';
import 'geo_proximity_indicator.dart';

class CourierOrderBottomSheet extends StatelessWidget {
  final CourierOrderStatus status;
  final int distanceMeters;
  final VoidCallback onGoOnline;
  final VoidCallback onAcceptOrder;
  final VoidCallback onAdvanceStatus;

  const CourierOrderBottomSheet({
    super.key,
    required this.status,
    required this.distanceMeters,
    required this.onGoOnline,
    required this.onAcceptOrder,
    required this.onAdvanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, -6))],
      ),
      child: SafeArea(top: false, child: _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (status) {
      case CourierOrderStatus.offline:
        return _OfflineContent(onGoOnline: onGoOnline);
      case CourierOrderStatus.searching:
        return _SearchingContent();
      case CourierOrderStatus.newOrderIncoming:
        return _NewOrderContent(onAccept: onAcceptOrder);
      case CourierOrderStatus.headingToRestaurant:
      case CourierOrderStatus.pickedUp:
      case CourierOrderStatus.delivering:
      case CourierOrderStatus.delivered:
        return _ActiveOrderContent(status: status, distanceMeters: distanceMeters, onAdvance: onAdvanceStatus);
    }
  }
}

class _OfflineContent extends StatelessWidget {
  final VoidCallback onGoOnline;
  const _OfflineContent({required this.onGoOnline});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: onGoOnline,
        child: Text(context.l10n.t('courier_go_online'), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16)),
      ),
    );
  }
}

class _SearchingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 12),
        Text(context.l10n.t('courier_searching_orders'), style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _NewOrderContent extends StatelessWidget {
  final VoidCallback onAccept;
  const _NewOrderContent({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.t('courier_new_order'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 16),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) > 200) onAccept();
          },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(18)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(context.l10n.t('courier_swipe_to_accept'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveOrderContent extends StatelessWidget {
  final CourierOrderStatus status;
  final int distanceMeters;
  final VoidCallback onAdvance;

  const _ActiveOrderContent({required this.status, required this.distanceMeters, required this.onAdvance});

  String _statusKey() {
    switch (status) {
      case CourierOrderStatus.headingToRestaurant:
        return 'courier_status_to_restaurant';
      case CourierOrderStatus.pickedUp:
        return 'courier_status_picked_up';
      case CourierOrderStatus.delivering:
        return 'courier_status_delivering';
      case CourierOrderStatus.delivered:
        return 'courier_status_delivered';
      default:
        return '';
    }
  }

  bool get _buttonEnabled => distanceMeters <= 150;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.t(_statusKey()), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            GeoProximityIndicator(distanceMeters: distanceMeters),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonEnabled ? AppColors.primary : AppColors.divider,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _buttonEnabled ? onAdvance : null,
            child: Text(context.l10n.t(_statusKey()), style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
