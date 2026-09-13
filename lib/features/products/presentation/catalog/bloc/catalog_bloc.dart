import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/product_api_client.dart';
import '../../../data/product_api_exception.dart';
import 'catalog_event.dart';
import 'catalog_load_requested.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({required this._apiClient})
    : super(const CatalogState.initial()) {
    on<CatalogLoadRequested>(_onLoadRequested);
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
      emit(CatalogState.loaded(products));
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
}
