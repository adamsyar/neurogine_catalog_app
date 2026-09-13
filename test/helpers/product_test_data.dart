import 'package:neurogine_catalog_app/features/products/data/product.dart';
import 'package:neurogine_catalog_app/features/products/data/product_api_client.dart';
import 'package:neurogine_catalog_app/features/products/data/product_page.dart';

Product productFixture(int id, {String? title}) {
  return Product(
    id: id,
    title: title ?? 'Product $id',
    description: 'Description $id',
    price: id + 0.99,
    rating: 4.5,
    thumbnail: 'https://example.com/$id-thumbnail.png',
    images: ['https://example.com/$id.png'],
  );
}

ProductPage productPageFixture({
  required List<Product> products,
  required int total,
  required int skip,
}) {
  return ProductPage(
    products: products,
    total: total,
    skip: skip,
    limit: ProductApiClient.pageSize,
  );
}
