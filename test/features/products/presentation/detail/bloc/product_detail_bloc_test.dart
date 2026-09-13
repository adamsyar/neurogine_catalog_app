import 'package:flutter_test/flutter_test.dart';
import 'package:neurogine_catalog_app/features/products/data/product_api_exception.dart';
import 'package:neurogine_catalog_app/features/products/presentation/detail/bloc/product_detail_bloc.dart';
import 'package:neurogine_catalog_app/features/products/presentation/detail/bloc/product_detail_load_requested.dart';
import 'package:neurogine_catalog_app/features/products/presentation/detail/bloc/product_detail_state.dart';

import '../../../../../helpers/fake_product_api_client.dart';
import '../../../../../helpers/product_test_data.dart';

void main() {
  group('ProductDetailBloc', () {
    test('loads product details by ID', () async {
      final apiClient = FakeProductApiClient(
        fetchProductHandler: (id) async => productFixture(id),
      );
      final bloc = ProductDetailBloc(productId: 42, apiClient: apiClient);
      addTearDown(bloc.close);
      final success = bloc.stream.firstWhere(
        (state) => state.status == ProductDetailStatus.success,
      );

      bloc.add(const ProductDetailLoadRequested());
      final state = await success;

      expect(state.product!.id, 42);
      expect(apiClient.detailRequests, [42]);
    });

    test('shows a readable failure and retries it', () async {
      var attempt = 0;
      final apiClient = FakeProductApiClient(
        fetchProductHandler: (id) async {
          attempt++;
          if (attempt == 1) {
            throw const ProductApiException('Detail unavailable');
          }
          return productFixture(id);
        },
      );
      final bloc = ProductDetailBloc(productId: 7, apiClient: apiClient);
      addTearDown(bloc.close);

      final failure = bloc.stream.firstWhere(
        (state) => state.status == ProductDetailStatus.failure,
      );
      bloc.add(const ProductDetailLoadRequested());
      expect((await failure).errorMessage, 'Detail unavailable');

      final success = bloc.stream.firstWhere(
        (state) => state.status == ProductDetailStatus.success,
      );
      bloc.add(const ProductDetailLoadRequested());
      final state = await success;

      expect(state.product!.id, 7);
      expect(apiClient.detailRequests, [7, 7]);
    });
  });
}
