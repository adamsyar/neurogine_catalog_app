import '../../../data/product.dart';

enum ProductDetailStatus { initial, loading, success, failure }

class ProductDetailState {
  const ProductDetailState.initial()
    : status = ProductDetailStatus.initial,
      product = null,
      errorMessage = null;

  const ProductDetailState.loading()
    : status = ProductDetailStatus.loading,
      product = null,
      errorMessage = null;

  const ProductDetailState.success(Product this.product)
    : status = ProductDetailStatus.success,
      errorMessage = null;

  const ProductDetailState.failure(String this.errorMessage)
    : status = ProductDetailStatus.failure,
      product = null;

  final ProductDetailStatus status;
  final Product? product;
  final String? errorMessage;
}
