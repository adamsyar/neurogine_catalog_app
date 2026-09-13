import '../../../data/product.dart';

enum CatalogStatus { initial, loading, success, empty, failure }

class CatalogState {
  const CatalogState.initial()
    : status = CatalogStatus.initial,
      products = const [],
      errorMessage = null;

  const CatalogState.loading()
    : status = CatalogStatus.loading,
      products = const [],
      errorMessage = null;

  CatalogState.loaded(List<Product> products)
    : status = products.isEmpty ? CatalogStatus.empty : CatalogStatus.success,
      products = List.unmodifiable(products),
      errorMessage = null;

  const CatalogState.failure(String message)
    : status = CatalogStatus.failure,
      products = const [],
      errorMessage = message;

  final CatalogStatus status;
  final List<Product> products;
  final String? errorMessage;
}
