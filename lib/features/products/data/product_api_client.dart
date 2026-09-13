import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'product.dart';
import 'product_api_exception.dart';
import 'product_page.dart';

class ProductApiClient {
  ProductApiClient({
    required this._client,
    this.requestTimeout = const Duration(seconds: 15),
  });

  static const pageSize = 20;

  final http.Client _client;
  final Duration requestTimeout;

  Future<ProductPage> fetchProducts({int skip = 0, String query = ''}) async {
    if (skip < 0) {
      throw ArgumentError.value(skip, 'skip', 'Must not be negative');
    }
    final normalizedQuery = query.trim();
    final uri = Uri.https(
      'dummyjson.com',
      normalizedQuery.isEmpty ? '/products' : '/products/search',
      {
        'limit': '$pageSize',
        'skip': '$skip',
        if (normalizedQuery.isNotEmpty) 'q': normalizedQuery,
      },
    );
    final json = await _get(uri);
    try {
      return ProductPage.fromJson(json);
    } on TypeError {
      throw const ProductApiException('The product data could not be read.');
    }
  }

  Future<Product> fetchProduct(int id) async {
    if (id <= 0) {
      throw ArgumentError.value(id, 'id', 'Must be positive');
    }
    final json = await _get(Uri.https('dummyjson.com', '/products/$id'));
    try {
      return Product.fromJson(json);
    } on TypeError {
      throw const ProductApiException('The product data could not be read.');
    }
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(requestTimeout);
      if (response.statusCode != 200) {
        throw ProductApiException(
          response.statusCode == 404
              ? 'The requested product could not be found.'
              : 'Products could not be loaded. Please try again.',
          statusCode: response.statusCode,
        );
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object');
      }
      return json;
    } on TimeoutException {
      throw const ProductApiException(
        'The request timed out. Please try again.',
      );
    } on http.ClientException {
      throw const ProductApiException(
        'Could not connect. Check your connection and try again.',
      );
    } on FormatException {
      throw const ProductApiException('The product data could not be read.');
    }
  }
}
