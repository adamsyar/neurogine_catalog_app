import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../widgets/loading_skeleton.dart';

class CatalogLoadingCard extends StatelessWidget {
  const CatalogLoadingCard({super.key, required this.imageSize});

  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return LoadingSkeleton(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Bone(
                width: imageSize,
                height: imageSize,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(words: 4, fontSize: 17),
                    SizedBox(height: 12),
                    Bone.text(words: 1, fontSize: 19),
                  ],
                ),
              ),
              const SizedBox(width: 38),
            ],
          ),
        ),
      ),
    );
  }
}
