import 'package:flutter/material.dart';

import '../../data/product.dart';
import '../widgets/product_image.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({super.key, required this.product});

  final Product product;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _currentPage = 0;

  List<String> get _images {
    final images = widget.product.images.toSet().toList();
    if (images.isNotEmpty) return images;
    return [widget.product.thumbnail];
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;

    return AspectRatio(
      aspectRatio: 1.2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: images.length,
            allowImplicitScrolling: true,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) => ProductImage(
              url: images[index],
              label:
                  '${widget.product.title}, image ${index + 1} of ${images.length}',
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Semantics(
              liveRegion: true,
              label: 'Image ${_currentPage + 1} of ${images.length}',
              child: ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xCC253026),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Text(
                      '${_currentPage + 1} / ${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
