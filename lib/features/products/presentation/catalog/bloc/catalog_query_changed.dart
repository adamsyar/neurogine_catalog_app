import 'catalog_event.dart';

class CatalogQueryChanged extends CatalogEvent {
  const CatalogQueryChanged({required this.query, required this.revision});

  final String query;
  final int revision;
}
