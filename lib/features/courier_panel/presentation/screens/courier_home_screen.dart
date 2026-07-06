import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/maps/map_widget.dart';
import '../../data/models/courier_order_status.dart';
import '../widgets/courier_order_bottom_sheet.dart';

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  State<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  LatLng? _position;
  CourierOrderStatus _status = CourierOrderStatus.offline;
  int _distanceMeters = 500;

  void _goOnline() {
    setState(() => _status = CourierOrderStatus.searching);
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _status = CourierOrderStatus.newOrderIncoming);
    });
  }

  void _acceptOrder() {
    setState(() {
      _status = CourierOrderStatus.headingToRestaurant;
      _distanceMeters = 500;
    });
  }

  void _advanceStatus() {
    setState(() {
      switch (_status) {
        case CourierOrderStatus.headingToRestaurant:
          _status = CourierOrderStatus.pickedUp;
          _distanceMeters = 800;
          break;
        case CourierOrderStatus.pickedUp:
          _status = CourierOrderStatus.delivering;
          break;
        case CourierOrderStatus.delivering:
          _status = CourierOrderStatus.delivered;
          _distanceMeters = 0;
          break;
        case CourierOrderStatus.delivered:
          _status = CourierOrderStatus.searching;
          Future.delayed(const Duration(seconds: 3), () {
            if (!mounted) return;
            setState(() => _status = CourierOrderStatus.newOrderIncoming);
          });
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapWidget(
              initialPosition: _position,
              onUserLocationFound: (position) => setState(() => _position = position),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CourierOrderBottomSheet(
              status: _status,
              distanceMeters: _distanceMeters,
              onGoOnline: _goOnline,
              onAcceptOrder: _acceptOrder,
              onAdvanceStatus: _advanceStatus,
            ),
          ),
        ],
      ),
    );
  }
}
