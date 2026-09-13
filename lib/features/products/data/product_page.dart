import 'product.dart';

class ProductPage {
  ProductPage({
    required List<Product> products,
    required this.total,
    required this.skip,
    required this.limit,
  }) : products = List.unmodifiable(products);

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  int get nextSkip => skip + products.length;

  bool get hasMore => products.isNotEmpty && nextSkip < total;

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    return ProductPage(
      products: (json['products'] as List<dynamic>)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }
}
