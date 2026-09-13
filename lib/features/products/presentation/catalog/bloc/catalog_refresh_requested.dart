import 'dart:async';

import 'catalog_event.dart';

class CatalogRefreshRequested extends CatalogEvent {
  const CatalogRefreshRequested({
    required this.query,
    required this.revision,
    required this.completer,
  });

  final String query;
  final int revision;
  final Completer<void> completer;
}
