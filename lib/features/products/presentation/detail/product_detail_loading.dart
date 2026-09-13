import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../widgets/loading_skeleton.dart';

class ProductDetailLoading extends StatelessWidget {
  const ProductDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingSkeleton(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone(
              width: double.infinity,
              height: 320,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            SizedBox(height: 28),
            Bone.text(words: 4, fontSize: 28),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Bone.text(words: 1, fontSize: 24),
                Bone.text(words: 2, fontSize: 18),
              ],
            ),
            SizedBox(height: 28),
            Bone.multiText(lines: 4, fontSize: 16),
          ],
        ),
      ),
    );
  }
}
