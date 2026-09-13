import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/product_api_client.dart';
import '../../../data/product_api_exception.dart';
import 'product_detail_event.dart';
import 'product_detail_load_requested.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc({required this.productId, required this._apiClient})
    : super(const ProductDetailState.initial()) {
    on<ProductDetailLoadRequested>(_onLoadRequested);
  }

  final int productId;
  final ProductApiClient _apiClient;

  Future<void> _onLoadRequested(
    ProductDetailLoadRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    if (state.status != ProductDetailStatus.initial &&
        state.status != ProductDetailStatus.failure) {
      return;
    }

    emit(const ProductDetailState.loading());
    try {
      final product = await _apiClient.fetchProduct(productId);
      if (emit.isDone) return;
      emit(ProductDetailState.success(product));
    } on ProductApiException catch (error) {
      if (emit.isDone) return;
      emit(ProductDetailState.failure(error.message));
    } on Exception catch (error, stackTrace) {
      if (emit.isDone) return;
      addError(error, stackTrace);
      emit(
        const ProductDetailState.failure(
          'Product details could not be loaded. Please try again.',
        ),
      );
    }
  }
}
