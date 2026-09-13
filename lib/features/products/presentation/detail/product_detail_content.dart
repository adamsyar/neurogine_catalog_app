import 'package:flutter/material.dart';

import '../../data/product.dart';
import '../widgets/product_image.dart';

class ProductDetailContent extends StatelessWidget {
  const ProductDetailContent({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isEmpty
        ? product.thumbnail
        : product.images.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: ProductImage(url: imageUrl, label: product.title),
          ),
          const SizedBox(height: 28),
          Semantics(
            header: true,
            child: Text(
              product.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Semantics(
                label: 'Rated ${product.rating.toStringAsFixed(1)} out of 5',
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFB27421)),
                    const SizedBox(width: 6),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'About this product',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
