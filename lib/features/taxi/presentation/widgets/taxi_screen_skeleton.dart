import 'package:flutter/material.dart';
import 'package:vental_go/core/widgets/skeleton_box.dart';

class TaxiScreenSkeleton extends StatelessWidget {
  const TaxiScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: double.infinity, height: 52),
          const SizedBox(height: 10),
          const SkeletonBox(width: double.infinity, height: 52),
          const SizedBox(height: 20),
          ...List.generate(4, (i) => const Padding(padding: EdgeInsets.only(bottom: 8), child: SkeletonBox(width: double.infinity, height: 58))),
        ],
      ),
    );
  }
}
