import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/product_card.dart';
import 'bloc/catalog_bloc.dart';
import 'bloc/catalog_load_requested.dart';
import 'bloc/catalog_state.dart';
import 'catalog_loading_card.dart';
import 'catalog_message.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

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
                    final loading =
                        state.status == CatalogStatus.initial ||
                        state.status == CatalogStatus.loading;
                    final message = switch (state.status) {
                      CatalogStatus.initial ||
                      CatalogStatus.loading => 'Loading products…',
                      CatalogStatus.success =>
                        '${state.products.length} products loaded',
                      CatalogStatus.empty => 'No products found',
                      CatalogStatus.failure => 'Could not load products',
                    };

                    return CustomScrollView(
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
                                        key: ValueKey(state.products[index].id),
                                        product: state.products[index],
                                        imageHeight: imageHeight,
                                      ),
                                childCount: loading ? 6 : state.products.length,
                              ),
                            ),
                          )
                        else
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: CatalogMessage(
                              message:
                                  state.errorMessage ??
                                  'There are no products to display right now.',
                              onRetry: state.status == CatalogStatus.failure
                                  ? () => context.read<CatalogBloc>().add(
                                      const CatalogLoadRequested(),
                                    )
                                  : null,
                            ),
                          ),
                      ],
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
