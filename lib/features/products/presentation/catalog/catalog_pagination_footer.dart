import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../widgets/loading_skeleton.dart';
import 'bloc/catalog_state.dart';

class CatalogPaginationFooter extends StatelessWidget {
  const CatalogPaginationFooter({
    super.key,
    required this.state,
    required this.onLoadMore,
  });

  final CatalogState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final message = state.isLoadingMore
        ? 'Loading more products…'
        : state.paginationError ??
              (state.hasMore
                  ? 'More products available'
                  : 'All products loaded');

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(message, textAlign: TextAlign.center),
          ),
          if (state.isLoadingMore) ...[
            const SizedBox(height: 16),
            const LoadingSkeleton(
              child: SizedBox(
                height: 64,
                child: Bone(width: double.infinity, height: 64),
              ),
            ),
          ] else if (state.hasMore) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onLoadMore,
              icon: Icon(
                state.paginationError == null
                    ? Icons.expand_more
                    : Icons.refresh,
              ),
              label: Text(
                state.paginationError == null
                    ? 'Load more'
                    : 'Retry loading more',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
