import '../../../data/product.dart';

enum CatalogStatus { initial, loading, success, empty, failure }

class CatalogState {
  const CatalogState.initial()
    : status = CatalogStatus.initial,
      products = const [],
      errorMessage = null,
      nextSkip = 0,
      hasMore = false,
      isLoadingMore = false,
      paginationError = null;

  const CatalogState.loading()
    : status = CatalogStatus.loading,
      products = const [],
      errorMessage = null,
      nextSkip = 0,
      hasMore = false,
      isLoadingMore = false,
      paginationError = null;

  CatalogState.loaded(
    List<Product> products, {
    required this.nextSkip,
    required this.hasMore,
  }) : status = products.isEmpty ? CatalogStatus.empty : CatalogStatus.success,
       products = List.unmodifiable(products),
       errorMessage = null,
       isLoadingMore = false,
       paginationError = null;

  const CatalogState.failure(String message)
    : status = CatalogStatus.failure,
      products = const [],
      errorMessage = message,
      nextSkip = 0,
      hasMore = false,
      isLoadingMore = false,
      paginationError = null;

  CatalogState.pagination(
    CatalogState previous, {
    this.isLoadingMore = false,
    this.paginationError,
  }) : status = previous.status,
       products = previous.products,
       errorMessage = previous.errorMessage,
       nextSkip = previous.nextSkip,
       hasMore = previous.hasMore;

  final CatalogStatus status;
  final List<Product> products;
  final String? errorMessage;
  final int nextSkip;
  final bool hasMore;
  final bool isLoadingMore;
  final String? paginationError;
}
