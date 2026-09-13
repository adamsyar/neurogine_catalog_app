import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'loading_skeleton.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final validUrl =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: const Color(0xFFF0F2EB),
        child: validUrl
            ? Image.network(
                url,
                key: ValueKey(url),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                semanticLabel: label,
                frameBuilder: (context, child, frame, synchronouslyLoaded) {
                  if (synchronouslyLoaded || frame != null) return child;
                  return const LoadingSkeleton(
                    child: Bone(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Semantics(
    label: 'Image unavailable for $label',
    child: const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 36,
        color: Color(0xFF697565),
      ),
    ),
  );
}
