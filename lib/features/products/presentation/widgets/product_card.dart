import 'package:flutter/material.dart';

import '../../data/product.dart';
import 'product_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.imageHeight,
    required this.onTap,
  });

  final Product product;
  final double imageHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          '${product.title}, \$${product.price.toStringAsFixed(2)}. View details',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: ProductImage(
                    url: product.thumbnail,
                    label: product.title,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 12),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
