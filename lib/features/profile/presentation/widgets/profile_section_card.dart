import 'package:flutter/material.dart';

import 'package:vental_go/core/theme/app_colors.dart';

class ProfileSectionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileSectionCard({super.key, required this.icon, required this.label, required this.onTap});

  @override
  State<ProfileSectionCard> createState() => _ProfileSectionCardState();
}

class _ProfileSectionCardState extends State<ProfileSectionCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(child: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5))),
              const Icon(Icons.chevron_right_rounded, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
