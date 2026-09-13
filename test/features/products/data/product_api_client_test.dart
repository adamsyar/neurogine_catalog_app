import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:neurogine_catalog_app/features/products/data/product_api_client.dart';
import 'package:neurogine_catalog_app/features/products/data/product_api_exception.dart';

void main() {
  group('ProductApiClient', () {
    test('requests and parses a catalog page', () async {
      late Uri requestedUri;
      final client = MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '''
          {
            "products": [
              {
                "id": 21,
                "title": "Phone",
                "description": "A sample phone",
                "price": 99,
                "rating": 4.5,
                "thumbnail": "https://example.com/thumbnail.png",
                "images": ["https://example.com/image.png"]
              }
            ],
            "total": 194,
            "skip": 20,
            "limit": 20
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      addTearDown(client.close);
      final apiClient = ProductApiClient(client: client);

      final page = await apiClient.fetchProducts(skip: 20);

      expect(requestedUri.host, 'dummyjson.com');
      expect(requestedUri.path, '/products');
      expect(requestedUri.queryParameters, {'limit': '20', 'skip': '20'});
      expect(page.products.single.id, 21);
      expect(page.products.single.price, 99.0);
      expect(page.total, 194);
      expect(page.nextSkip, 21);
      expect(page.hasMore, isTrue);
    });

    test('normalizes a query and uses the search endpoint', () async {
      late Uri requestedUri;
      final client = MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"products": [], "total": 0, "skip": 0, "limit": 20}',
          200,
        );
      });
      addTearDown(client.close);
      final apiClient = ProductApiClient(client: client);

      await apiClient.fetchProducts(query: '  phone  ');

      expect(requestedUri.path, '/products/search');
      expect(requestedUri.queryParameters, {
        'limit': '20',
        'skip': '0',
        'q': 'phone',
      });
    });

    test('maps an unsuccessful response to a readable exception', () async {
      final client = MockClient((_) async => http.Response('{}', 404));
      addTearDown(client.close);
      final apiClient = ProductApiClient(client: client);

      await expectLater(
        apiClient.fetchProduct(999),
        throwsA(
          isA<ProductApiException>()
              .having((error) => error.statusCode, 'statusCode', 404)
              .having(
                (error) => error.message,
                'message',
                'The requested product could not be found.',
              ),
        ),
      );
    });
  });
}
