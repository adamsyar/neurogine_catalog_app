import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    return ExcludeSemantics(
      child: Skeletonizer.zone(
        enableSwitchAnimation: false,
        effect: reduceMotion
            ? const SolidColorEffect(color: Color(0xFFE4E7DF))
            : const ShimmerEffect(
                baseColor: Color(0xFFE4E7DF),
                highlightColor: Color(0xFFF4F5F0),
              ),
        child: child,
      ),
    );
  }
}
