import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../widgets/loading_skeleton.dart';

class CatalogLoadingCard extends StatelessWidget {
  const CatalogLoadingCard({super.key, required this.imageHeight});

  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return LoadingSkeleton(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone(
                width: double.infinity,
                height: imageHeight,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(height: 16),
              const Bone.text(words: 3, fontSize: 16),
              const SizedBox(height: 8),
              const Bone.text(words: 2, fontSize: 16),
              const Spacer(),
              const SizedBox(height: 12),
              const Bone.text(words: 1, fontSize: 20),
            ],
          ),
        ),
      ),
    );
  }
}
