import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/product_api_client.dart';
import '../../../data/product_api_exception.dart';
import 'catalog_event.dart';
import 'catalog_load_requested.dart';
import 'catalog_next_page_requested.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({required this._apiClient})
    : super(const CatalogState.initial()) {
    on<CatalogLoadRequested>(_onLoadRequested);
    on<CatalogNextPageRequested>(_onNextPageRequested);
  }

  final ProductApiClient _apiClient;

  Future<void> _onLoadRequested(
    CatalogLoadRequested event,
    Emitter<CatalogState> emit,
  ) async {
    if (state.status != CatalogStatus.initial &&
        state.status != CatalogStatus.failure) {
      return;
    }

    emit(const CatalogState.loading());
    try {
      final page = await _apiClient.fetchProducts();
      if (emit.isDone) return;

      final seenIds = <int>{};
      final products = page.products
          .where((product) => seenIds.add(product.id))
          .toList();
      emit(
        CatalogState.loaded(
          products,
          nextSkip: page.nextSkip,
          hasMore: page.hasMore,
        ),
      );
    } on ProductApiException catch (error) {
      if (emit.isDone) return;
      emit(CatalogState.failure(error.message));
    } on Exception catch (error, stackTrace) {
      if (emit.isDone) return;
      addError(error, stackTrace);
      emit(
        const CatalogState.failure(
          'Products could not be loaded. Please try again.',
        ),
      );
    }
  }

  Future<void> _onNextPageRequested(
    CatalogNextPageRequested event,
    Emitter<CatalogState> emit,
  ) async {
    if (state.status != CatalogStatus.success ||
        state.isLoadingMore ||
        !state.hasMore ||
        (state.paginationError != null && !event.retry)) {
      return;
    }

    final previous = state;
    emit(CatalogState.pagination(previous, isLoadingMore: true));
    try {
      final page = await _apiClient.fetchProducts(skip: previous.nextSkip);
      if (emit.isDone) return;

      if (page.skip != previous.nextSkip) {
        throw const ProductApiException(
          'The next page could not be loaded. Please try again.',
        );
      }
      final seenIds = previous.products.map((product) => product.id).toSet();
      final products = [
        ...previous.products,
        ...page.products.where((product) => seenIds.add(product.id)),
      ];
      emit(
        CatalogState.loaded(
          products,
          nextSkip: page.nextSkip,
          hasMore: page.hasMore,
        ),
      );
    } on ProductApiException catch (error) {
      if (emit.isDone) return;
      emit(CatalogState.pagination(previous, paginationError: error.message));
    } on Exception catch (error, stackTrace) {
      if (emit.isDone) return;
      addError(error, stackTrace);
      emit(
        CatalogState.pagination(
          previous,
          paginationError:
              'More products could not be loaded. Please try again.',
        ),
      );
    }
  }
}
