

import './catalog_event.dart';

class CatalogNextPageRequested extends CatalogEvent {
  const CatalogNextPageRequested({this.retry = false});

  final bool retry;
}
