import 'package:flutter/material.dart';

class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonContainer({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}