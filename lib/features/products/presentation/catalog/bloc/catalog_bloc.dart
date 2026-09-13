import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/product_api_client.dart';
import '../../../data/product_api_exception.dart';
import 'catalog_event.dart';
import 'catalog_load_requested.dart';
import 'catalog_next_page_requested.dart';
import 'catalog_query_changed.dart';
import 'catalog_refresh_requested.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({required this._apiClient})
    : super(const CatalogState.initial()) {
    on<CatalogLoadRequested>(_onLoadRequested);
    on<CatalogNextPageRequested>(_onNextPageRequested);
    on<CatalogQueryChanged>(_onQueryChanged);
    on<CatalogRefreshRequested>(_onRefreshRequested);
  }

  final ProductApiClient _apiClient;
  int _queryRevision = 0;
  String _query = '';
  bool _debouncing = false;
  bool _refreshPending = false;

  void changeQuery(String input) {
    if (isClosed) return;
    final query = input.trim();
    if (query == _query) return;

    _query = query;
    _queryRevision++;
    _debouncing = query.isNotEmpty;
    add(CatalogQueryChanged(query: query, revision: _queryRevision));
  }

  Future<void> refresh() {
    if (isClosed ||
        _debouncing ||
        _refreshPending ||
        state.query != _query ||
        state.isLoadingMore ||
        state.isRefreshing ||
        (state.status != CatalogStatus.success &&
            state.status != CatalogStatus.empty)) {
      return Future.value();
    }

    _refreshPending = true;
    final completer = Completer<void>();
    add(
      CatalogRefreshRequested(
        query: _query,
        revision: _queryRevision,
        completer: completer,
      ),
    );
    return completer.future;
  }

  Future<void> _onQueryChanged(
    CatalogQueryChanged event,
    Emitter<CatalogState> emit,
  ) async {
    if (event.revision != _queryRevision) return;
    emit(CatalogState.loading(query: event.query));

    if (event.query.isNotEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
    if (emit.isDone || event.revision != _queryRevision) return;

    _debouncing = false;
    await _loadFirstPage(emit, event.query, event.revision);
  }

  Future<void> _onLoadRequested(
    CatalogLoadRequested event,
    Emitter<CatalogState> emit,
  ) async {
    if (_debouncing ||
        state.query != _query ||
        (state.status != CatalogStatus.initial &&
            state.status != CatalogStatus.failure)) {
      return;
    }

    final revision = _queryRevision;
    final query = _query;
    emit(CatalogState.loading(query: query));
    await _loadFirstPage(emit, query, revision);
  }

  Future<void> _loadFirstPage(
    Emitter<CatalogState> emit,
    String query,
    int revision,
  ) async {
    try {
      final page = await _apiClient.fetchProducts(query: query);
      if (emit.isDone || revision != _queryRevision) return;

      final seenIds = <int>{};
      final products = page.products
          .where((product) => seenIds.add(product.id))
          .toList();
      emit(
        CatalogState.loaded(
          products,
          query: query,
          total: page.total,
          nextSkip: page.nextSkip,
          hasMore: page.hasMore,
        ),
      );
    } on ProductApiException catch (error) {
      if (emit.isDone || revision != _queryRevision) return;
      emit(CatalogState.failure(error.message, query: query));
    } on Exception catch (error, stackTrace) {
      if (emit.isDone || revision != _queryRevision) return;
      addError(error, stackTrace);
      emit(
        CatalogState.failure(
          'Products could not be loaded. Please try again.',
          query: query,
        ),
      );
    }
  }

  Future<void> _onNextPageRequested(
    CatalogNextPageRequested event,
    Emitter<CatalogState> emit,
  ) async {
    if (_debouncing ||
        state.query != _query ||
        state.status != CatalogStatus.success ||
        state.isLoadingMore ||
        state.isRefreshing ||
        !state.hasMore ||
        (state.paginationError != null && !event.retry)) {
      return;
    }

    final previous = state;
    final revision = _queryRevision;
    emit(CatalogState.pagination(previous, isLoadingMore: true));
    try {
      final page = await _apiClient.fetchProducts(
        skip: previous.nextSkip,
        query: previous.query,
      );
      if (emit.isDone || revision != _queryRevision) return;

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
          query: previous.query,
          total: page.total,
          nextSkip: page.nextSkip,
          hasMore: page.hasMore,
        ),
      );
    } on ProductApiException catch (error) {
      if (emit.isDone || revision != _queryRevision) return;
      emit(CatalogState.pagination(previous, paginationError: error.message));
    } on Exception catch (error, stackTrace) {
      if (emit.isDone || revision != _queryRevision) return;
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

  Future<void> _onRefreshRequested(
    CatalogRefreshRequested event,
    Emitter<CatalogState> emit,
  ) async {
    try {
      if (event.revision != _queryRevision || event.query != _query) return;

      final previous = state;
      emit(CatalogState.refreshing(previous));
      try {
        final page = await _apiClient.fetchProducts(query: event.query);
        if (emit.isDone || event.revision != _queryRevision) return;

        final seenIds = <int>{};
        final products = page.products
            .where((product) => seenIds.add(product.id))
            .toList();
        emit(
          CatalogState.loaded(
            products,
            query: event.query,
            total: page.total,
            nextSkip: page.nextSkip,
            hasMore: page.hasMore,
          ),
        );
      } on ProductApiException catch (error) {
        if (emit.isDone || event.revision != _queryRevision) return;
        emit(
          CatalogState.refreshing(
            previous,
            isRefreshing: false,
            refreshError: error.message,
          ),
        );
      } on Exception catch (error, stackTrace) {
        if (emit.isDone || event.revision != _queryRevision) return;
        addError(error, stackTrace);
        emit(
          CatalogState.refreshing(
            previous,
            isRefreshing: false,
            refreshError: 'Products could not be refreshed. Please try again.',
          ),
        );
      }
    } finally {
      _refreshPending = false;
      if (!event.completer.isCompleted) event.completer.complete();
    }
  }

  @override
  Future<void> close() {
    _queryRevision++;
    return super.close();
  }
}
