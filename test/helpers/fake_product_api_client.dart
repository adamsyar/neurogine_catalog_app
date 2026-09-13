import 'package:http/testing.dart';
import 'package:neurogine_catalog_app/features/products/data/product.dart';
import 'package:neurogine_catalog_app/features/products/data/product_api_client.dart';
import 'package:neurogine_catalog_app/features/products/data/product_page.dart';

typedef FetchProductsHandler =
    Future<ProductPage> Function(int skip, String query);
typedef FetchProductHandler = Future<Product> Function(int id);

class FakeProductApiClient extends ProductApiClient {
  FakeProductApiClient({this.fetchProductsHandler, this.fetchProductHandler})
    : super(
        client: MockClient((_) async {
          throw UnsupportedError('The fake client does not perform HTTP.');
        }),
      );

  final FetchProductsHandler? fetchProductsHandler;
  final FetchProductHandler? fetchProductHandler;
  final List<({int skip, String query})> productRequests = [];
  final List<int> detailRequests = [];

  @override
  Future<ProductPage> fetchProducts({int skip = 0, String query = ''}) {
    productRequests.add((skip: skip, query: query));
    final handler = fetchProductsHandler;
    if (handler == null) {
      throw StateError('No catalog response was configured.');
    }
    return handler(skip, query);
  }

  @override
  Future<Product> fetchProduct(int id) {
    detailRequests.add(id);
    final handler = fetchProductHandler;
    if (handler == null) {
      throw StateError('No detail response was configured.');
    }
    return handler(id);
  }
}
