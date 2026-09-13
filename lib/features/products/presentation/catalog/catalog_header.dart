import 'package:flutter/material.dart';

import 'catalog_search_field.dart';

class CatalogHeader extends StatelessWidget {
  const CatalogHeader({
    super.key,
    required this.message,
    required this.onSearchChanged,
  });

  final String message;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Catalog',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: const Text(
            'Find your everyday.',
            style: TextStyle(
              fontSize: 34,
              height: 1.15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'A little discovery, one product at a time.',
          style: TextStyle(fontSize: 17, height: 1.45),
        ),
        const SizedBox(height: 28),
        CatalogSearchField(onChanged: onSearchChanged),
        const SizedBox(height: 26),
        Semantics(
          liveRegion: true,
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
