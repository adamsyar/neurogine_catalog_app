import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:neurogine_catalog_app/features/products/data/product_api_exception.dart';
import 'package:neurogine_catalog_app/features/products/data/product_page.dart';
import 'package:neurogine_catalog_app/features/products/presentation/catalog/bloc/catalog_bloc.dart';
import 'package:neurogine_catalog_app/features/products/presentation/catalog/bloc/catalog_load_requested.dart';
import 'package:neurogine_catalog_app/features/products/presentation/catalog/bloc/catalog_next_page_requested.dart';
import 'package:neurogine_catalog_app/features/products/presentation/catalog/bloc/catalog_state.dart';

import '../../../../../helpers/fake_product_api_client.dart';
import '../../../../../helpers/product_test_data.dart';

void main() {
  group('CatalogBloc', () {
    test('loads the initial catalog and retries an initial failure', () async {
      var attempt = 0;
      final apiClient = FakeProductApiClient(
        fetchProductsHandler: (_, _) async {
          attempt++;
          if (attempt == 1) {
            throw const ProductApiException('Catalog unavailable');
          }
          return productPageFixture(
            products: [productFixture(1)],
            total: 1,
            skip: 0,
          );
        },
      );
      final bloc = CatalogBloc(apiClient: apiClient);
      addTearDown(bloc.close);

      final failure = _nextState(
        bloc,
        (state) => state.status == CatalogStatus.failure,
      );
      bloc.add(const CatalogLoadRequested());
      expect((await failure).errorMessage, 'Catalog unavailable');

      final success = _nextState(
        bloc,
        (state) => state.status == CatalogStatus.success,
      );
      bloc.add(const CatalogLoadRequested());
      final state = await success;

      expect(state.products.single.id, 1);
      expect(state.total, 1);
      expect(apiClient.productRequests, hasLength(2));
    });

    test(
      'guards pagination, removes duplicates, and stops at the end',
      () async {
        final nextPage = Completer<ProductPage>();
        final apiClient = FakeProductApiClient(
          fetchProductsHandler: (skip, _) {
            if (skip == 0) {
              return Future.value(
                productPageFixture(
                  products: [productFixture(1), productFixture(2)],
                  total: 4,
                  skip: 0,
                ),
              );
            }
            return nextPage.future;
          },
        );
        final bloc = CatalogBloc(apiClient: apiClient);
        addTearDown(bloc.close);

        await _loadCatalog(bloc);
        final loadingMore = _nextState(bloc, (state) => state.isLoadingMore);
        bloc.add(const CatalogNextPageRequested());
        await loadingMore;
        bloc.add(const CatalogNextPageRequested());

        final loaded = _nextState(
          bloc,
          (state) =>
              state.status == CatalogStatus.success && !state.isLoadingMore,
        );
        nextPage.complete(
          productPageFixture(
            products: [productFixture(2), productFixture(3)],
            total: 4,
            skip: 2,
          ),
        );
        final state = await loaded;

        expect(state.products.map((product) => product.id), [1, 2, 3]);
        expect(state.hasMore, isFalse);
        expect(apiClient.productRequests, hasLength(2));

        bloc.add(const CatalogNextPageRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(apiClient.productRequests, hasLength(2));
      },
    );

    test(
      'keeps products after pagination failure and supports retry',
      () async {
        var requestCount = 0;
        final apiClient = FakeProductApiClient(
          fetchProductsHandler: (skip, _) async {
            requestCount++;
            if (skip == 0) {
              return productPageFixture(
                products: [productFixture(1)],
                total: 2,
                skip: 0,
              );
            }
            if (requestCount == 2) {
              throw const ProductApiException('Next page failed');
            }
            return productPageFixture(
              products: [productFixture(2)],
              total: 2,
              skip: 1,
            );
          },
        );
        final bloc = CatalogBloc(apiClient: apiClient);
        addTearDown(bloc.close);

        await _loadCatalog(bloc);
        final failed = _nextState(
          bloc,
          (state) => state.paginationError != null,
        );
        bloc.add(const CatalogNextPageRequested());
        final failedState = await failed;

        expect(failedState.products.single.id, 1);
        expect(failedState.paginationError, 'Next page failed');

        bloc.add(const CatalogNextPageRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(apiClient.productRequests, hasLength(2));

        final retried = _nextState(
          bloc,
          (state) =>
              state.paginationError == null && state.products.length == 2,
        );
        bloc.add(const CatalogNextPageRequested(retry: true));
        final retriedState = await retried;

        expect(retriedState.products.map((product) => product.id), [1, 2]);
        expect(retriedState.hasMore, isFalse);
      },
    );

    test(
      'invalidates an in-flight search as soon as the query changes',
      () async {
        final responses = <String, Completer<ProductPage>>{};
        final apiClient = FakeProductApiClient(
          fetchProductsHandler: (_, query) {
            return (responses[query] ??= Completer<ProductPage>()).future;
          },
        );
        final bloc = CatalogBloc(apiClient: apiClient);
        addTearDown(bloc.close);

        bloc.changeQuery('phone');
        await _waitUntil(() => responses.containsKey('phone'));

        final laptopLoading = _nextState(
          bloc,
          (state) =>
              state.status == CatalogStatus.loading && state.query == 'laptop',
        );
        bloc.changeQuery('laptop');
        await laptopLoading;
        responses['phone']!.complete(
          productPageFixture(
            products: [productFixture(1, title: 'Phone')],
            total: 1,
            skip: 0,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(bloc.state.status, CatalogStatus.loading);
        expect(bloc.state.query, 'laptop');
        await _waitUntil(() => responses.containsKey('laptop'));

        final laptopResult = _nextState(
          bloc,
          (state) =>
              state.status == CatalogStatus.success && state.query == 'laptop',
        );
        responses['laptop']!.complete(
          productPageFixture(
            products: [productFixture(2, title: 'Laptop')],
            total: 1,
            skip: 0,
          ),
        );

        expect((await laptopResult).products.single.title, 'Laptop');
      },
    );

    test('clearing a debounced search restores the normal catalog', () async {
      final apiClient = FakeProductApiClient(
        fetchProductsHandler: (_, query) async {
          return productPageFixture(
            products: [productFixture(1)],
            total: 1,
            skip: 0,
          );
        },
      );
      final bloc = CatalogBloc(apiClient: apiClient);
      addTearDown(bloc.close);

      bloc.changeQuery('phone');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final catalog = _nextState(
        bloc,
        (state) => state.status == CatalogStatus.success && state.query.isEmpty,
      );
      bloc.changeQuery('   ');
      await catalog;
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(apiClient.productRequests, [(skip: 0, query: '')]);
    });

    test('refreshes the active search query', () async {
      var responseId = 0;
      final apiClient = FakeProductApiClient(
        fetchProductsHandler: (_, query) async {
          responseId++;
          return productPageFixture(
            products: [productFixture(responseId)],
            total: 1,
            skip: 0,
          );
        },
      );
      final bloc = CatalogBloc(apiClient: apiClient);
      addTearDown(bloc.close);

      final initialResult = _nextState(
        bloc,
        (state) =>
            state.status == CatalogStatus.success && state.query == 'phone',
      );
      bloc.changeQuery(' phone ');
      expect((await initialResult).products.single.id, 1);

      await bloc.refresh();

      expect(bloc.state.query, 'phone');
      expect(bloc.state.products.single.id, 2);
      expect(apiClient.productRequests.map((request) => request.query), [
        'phone',
        'phone',
      ]);
    });
  });
}

Future<CatalogState> _loadCatalog(CatalogBloc bloc) {
  final result = _nextState(
    bloc,
    (state) => state.status == CatalogStatus.success,
  );
  bloc.add(const CatalogLoadRequested());
  return result;
}

Future<CatalogState> _nextState(
  CatalogBloc bloc,
  bool Function(CatalogState state) predicate,
) {
  return bloc.stream.firstWhere(predicate).timeout(const Duration(seconds: 2));
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not reached before the timeout.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
