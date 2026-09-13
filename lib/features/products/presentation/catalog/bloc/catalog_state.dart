import '../../../data/product.dart';

enum CatalogStatus { initial, loading, success, empty, failure }

class CatalogState {
  const CatalogState.initial()
    : status = CatalogStatus.initial,
      query = '',
      products = const [],
      errorMessage = null,
      total = 0,
      nextSkip = 0,
      hasMore = false,
      isLoadingMore = false,
      paginationError = null,
      isRefreshing = false,
      refreshError = null;

  const CatalogState.loading({this.query = ''})
    : status = CatalogStatus.loading,
      products = const [],
      errorMessage = null,
      total = 0,
      nextSkip = 0,
      hasMore = false,
      isLoadingMore = false,
      paginationError = null,
      isRefreshing = false,
      refreshError = null;

  CatalogState.loaded(
    List<Product> products, {
    required this.query,
    required this.total,
    required this.nextSkip,
    required this.hasMore,
  }) : status = products.isEmpty ? CatalogStatus.empty : CatalogStatus.success,
       products = List.unmodifiable(products),
       errorMessage = null,
       isLoadingMore = false,
       paginationError = null,
       isRefreshing = false,
       refreshError = null;

  const CatalogState.failure(String message, {this.query = ''})
    : status = CatalogStatus.failure,
      products = const [],
      errorMessage = message,
      total = 0,
      nextSkip = 0,
      hasMore = false,
      isLoadingMore = false,
      paginationError = null,
      isRefreshing = false,
      refreshError = null;

  CatalogState.pagination(
    CatalogState previous, {
    this.isLoadingMore = false,
    this.paginationError,
  }) : status = previous.status,
       query = previous.query,
       products = previous.products,
       errorMessage = previous.errorMessage,
       total = previous.total,
       nextSkip = previous.nextSkip,
       hasMore = previous.hasMore,
       isRefreshing = false,
       refreshError = null;

  CatalogState.refreshing(
    CatalogState previous, {
    this.isRefreshing = true,
    this.refreshError,
  }) : status = previous.status,
       query = previous.query,
       products = previous.products,
       errorMessage = previous.errorMessage,
       total = previous.total,
       nextSkip = previous.nextSkip,
       hasMore = previous.hasMore,
       isLoadingMore = false,
       paginationError = previous.paginationError;

  final CatalogStatus status;
  final String query;
  final List<Product> products;
  final String? errorMessage;
  final int total;
  final int nextSkip;
  final bool hasMore;
  final bool isLoadingMore;
  final String? paginationError;
  final bool isRefreshing;
  final String? refreshError;
}
