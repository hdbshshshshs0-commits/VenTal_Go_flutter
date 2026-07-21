import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';

class HistorySegmentedToggle extends StatelessWidget {
  final int selectedIndex; // 0 = Активные, 1 = История
  final ValueChanged<int> onChanged;

  const HistorySegmentedToggle({super.key, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(selectedIndex == 0 ? 1 : 0),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(22)),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(child: _label(context, 'history_active_tab', 0)),
                Expanded(child: _label(context, 'history_past_tab', 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String key, int index) {
    final isActive = selectedIndex == index;
    return Center(
      child: Text(
        context.l10n.t(key),
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isActive ? AppColors.primary : AppColors.textHint),
      ),
    );
  }
}