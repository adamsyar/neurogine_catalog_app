import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/product_card.dart';
import 'bloc/catalog_bloc.dart';
import 'bloc/catalog_load_requested.dart';
import 'bloc/catalog_next_page_requested.dart';
import 'bloc/catalog_state.dart';
import 'catalog_loading_card.dart';
import 'catalog_message.dart';
import 'catalog_pagination_footer.dart';
import 'catalog_search_field.dart';

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
                final minimumCardWidth = math.max(240.0, scale.scale(160));
                final columns = (width / minimumCardWidth).floor().clamp(1, 4);
                final cardWidth = (width - (columns - 1) * 16) / columns;
                final imageHeight = math.min(
                  200.0,
                  math.max(80.0, cardWidth - 32),
                );
                final cardHeight =
                    imageHeight +
                    64 +
                    scale.scale(16) * 2.8 +
                    scale.scale(20) * 1.3;

                return BlocBuilder<CatalogBloc, CatalogState>(
                  builder: (context, state) {
                    _scheduleLoadCheck();
                    final loading =
                        state.status == CatalogStatus.initial ||
                        state.status == CatalogStatus.loading;
                    final message = switch (state.status) {
                      CatalogStatus.initial || CatalogStatus.loading =>
                        state.query.isEmpty
                            ? 'Loading products…'
                            : 'Searching for “${state.query}”…',
                      CatalogStatus.success =>
                        state.query.isEmpty
                            ? '${state.products.length} products loaded'
                            : '${state.products.length} results for “${state.query}”',
                      CatalogStatus.empty =>
                        state.query.isEmpty
                            ? 'No products found'
                            : 'No results for “${state.query}”',
                      CatalogStatus.failure => 'Could not load products',
                    };

                    return NotificationListener<ScrollMetricsNotification>(
                      onNotification: (notification) {
                        _scheduleLoadCheck();
                        return false;
                      },
                      child: CustomScrollView(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              padding,
                              32,
                              padding,
                              24,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Semantics(
                                    header: true,
                                    child: const Text(
                                      'Product Catalog',
                                      style: TextStyle(
                                        fontSize: 32,
                                        height: 1.2,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Discover something for your everyday.',
                                    style: TextStyle(fontSize: 16, height: 1.5),
                                  ),
                                  const SizedBox(height: 24),
                                  CatalogSearchField(onChanged: _changeQuery),
                                  const SizedBox(height: 20),
                                  Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      message,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (loading || state.status == CatalogStatus.success)
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
                                          imageHeight: imageHeight,
                                        )
                                      : ProductCard(
                                          key: ValueKey(
                                            state.products[index].id,
                                          ),
                                          product: state.products[index],
                                          imageHeight: imageHeight,
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
