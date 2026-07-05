import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vental_go/core/theme/app_colors.dart';

class OnlineOfflineToggle extends StatefulWidget {
  final ValueChanged<bool> onChanged;

  const OnlineOfflineToggle({super.key, required this.onChanged});

  @override
  State<OnlineOfflineToggle> createState() => _OnlineOfflineToggleState();
}

class _OnlineOfflineToggleState extends State<OnlineOfflineToggle> {
  bool isOnline = false;

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() => isOnline = !isOnline);
    widget.onChanged(isOnline);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      onHorizontalDragEnd: (_) => _toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 84,
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: isOnline ? AppColors.success : Colors.grey.shade400, borderRadius: BorderRadius.circular(24)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(isOnline ? Icons.bolt : Icons.power_settings_new, size: 18, color: isOnline ? AppColors.success : Colors.grey),
          ),
        ),
      ),
    );
  }
}
