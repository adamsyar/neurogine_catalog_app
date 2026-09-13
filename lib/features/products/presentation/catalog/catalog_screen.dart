import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/product.dart';
import '../../data/product_api_client.dart';
import '../detail/bloc/product_detail_bloc.dart';
import '../detail/bloc/product_detail_load_requested.dart';
import '../detail/product_detail_screen.dart';
import '../widgets/product_card.dart';
import 'bloc/catalog_bloc.dart';
import 'bloc/catalog_load_requested.dart';
import 'bloc/catalog_next_page_requested.dart';
import 'bloc/catalog_state.dart';
import 'catalog_header.dart';
import 'catalog_loading_card.dart';
import 'catalog_message.dart';
import 'catalog_pagination_footer.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _scrollController = ScrollController();
  bool _loadCheckScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreIfNeeded);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreIfNeeded() {
    if (!mounted || !_scrollController.hasClients) return;
    final bloc = context.read<CatalogBloc>();
    final state = bloc.state;
    if (state.status == CatalogStatus.success &&
        state.hasMore &&
        !state.isLoadingMore &&
        !state.isRefreshing &&
        state.paginationError == null &&
        _scrollController.position.extentAfter < 500) {
      bloc.add(const CatalogNextPageRequested());
    }
  }

  void _scheduleLoadCheck() {
    if (_loadCheckScheduled) return;
    _loadCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCheckScheduled = false;
      _loadMoreIfNeeded();
    });
  }

  void _changeQuery(String input) {
    final bloc = context.read<CatalogBloc>();
    final changed = input.trim() != bloc.state.query;
    bloc.changeQuery(input);
    if (changed && _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _openProduct(Product product) {
    final apiClient = context.read<ProductApiClient>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              ProductDetailBloc(productId: product.id, apiClient: apiClient)
                ..add(const ProductDetailLoadRequested()),
          child: const ProductDetailScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final padding = constraints.maxWidth < 600 ? 20.0 : 32.0;
                final width = math.max(1.0, constraints.maxWidth - padding * 2);
                final scale = MediaQuery.textScalerOf(context);
                final minimumCardWidth = math.max(360.0, scale.scale(240));
                final columns = (width / minimumCardWidth).floor().clamp(1, 3);
                final imageSize = constraints.maxWidth < 600 ? 112.0 : 120.0;
                final cardHeight = math.max(
                  imageSize + 24,
                  scale.scale(17) * 2.7 + scale.scale(19) * 1.3 + 60,
                );

                return BlocConsumer<CatalogBloc, CatalogState>(
                  listenWhen: (previous, current) =>
                      previous.refreshError != current.refreshError &&
                      current.refreshError != null,
                  listener: (context, state) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text(state.refreshError!)),
                      );
                  },
                  builder: (context, state) {
                    _scheduleLoadCheck();
                    final loading =
                        state.status == CatalogStatus.initial ||
                        state.status == CatalogStatus.loading;
                    final message = state.isRefreshing
                        ? state.query.isEmpty
                              ? 'Refreshing products…'
                              : 'Refreshing results for “${state.query}”…'
                        : switch (state.status) {
                            CatalogStatus.initial || CatalogStatus.loading =>
                              state.query.isEmpty
                                  ? 'Loading products…'
                                  : 'Searching for “${state.query}”…',
                            CatalogStatus.success =>
                              state.query.isEmpty
                                  ? '${state.total} products · ${state.products.length} loaded'
                                  : '${state.total} results · ${state.products.length} loaded',
                            CatalogStatus.empty =>
                              state.query.isEmpty
                                  ? 'No products found'
                                  : 'No results for “${state.query}”',
                            CatalogStatus.failure => 'Could not load products',
                          };

                    return RefreshIndicator.adaptive(
                      onRefresh: context.read<CatalogBloc>().refresh,
                      child: NotificationListener<ScrollMetricsNotification>(
                        onNotification: (notification) {
                          _scheduleLoadCheck();
                          return false;
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                padding,
                                28,
                                padding,
                                28,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: CatalogHeader(
                                  message: message,
                                  onSearchChanged: _changeQuery,
                                ),
                              ),
                            ),
                            if (loading ||
                                state.status == CatalogStatus.success)
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  padding,
                                  0,
                                  padding,
                                  32,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent: cardHeight,
                                      ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => loading
                                        ? CatalogLoadingCard(
                                            imageSize: imageSize,
                                          )
                                        : ProductCard(
                                            key: ValueKey(
                                              state.products[index].id,
                                            ),
                                            product: state.products[index],
                                            imageSize: imageSize,
                                            onTap: () => _openProduct(
                                              state.products[index],
                                            ),
                                          ),
                                    childCount: loading
                                        ? 6
                                        : state.products.length,
                                  ),
                                ),
                              )
                            else
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: CatalogMessage(
                                  message:
                                      state.errorMessage ??
                                      (state.query.isEmpty
                                          ? 'There are no products to display right now.'
                                          : 'Try another product name or clear your search.'),
                                  onRetry: state.status == CatalogStatus.failure
                                      ? () => context.read<CatalogBloc>().add(
                                          const CatalogLoadRequested(),
                                        )
                                      : null,
                                ),
                              ),
                            if (state.status == CatalogStatus.success)
                              SliverToBoxAdapter(
                                child: CatalogPaginationFooter(
                                  state: state,
                                  onLoadMore: () =>
                                      context.read<CatalogBloc>().add(
                                        CatalogNextPageRequested(
                                          retry: state.paginationError != null,
                                        ),
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
