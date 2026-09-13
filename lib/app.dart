import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'features/products/data/product_api_client.dart';
import 'features/products/presentation/catalog/bloc/catalog_bloc.dart';
import 'features/products/presentation/catalog/bloc/catalog_load_requested.dart';
import 'features/products/presentation/catalog/catalog_screen.dart';

class ProductCatalogApp extends StatefulWidget {
  const ProductCatalogApp({super.key});

  @override
  State<ProductCatalogApp> createState() => _ProductCatalogAppState();
}

class _ProductCatalogAppState extends State<ProductCatalogApp> {
  late final http.Client _client;
  late final ProductApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _client = http.Client();
    _apiClient = ProductApiClient(client: _client);
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF526B50),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF496347),
          surface: const Color(0xFFF8F7F2),
          onSurface: const Color(0xFF252B25),
        );
    return RepositoryProvider.value(
      value: _apiClient,
      child: MaterialApp(
        title: 'Product Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colors,
          scaffoldBackgroundColor: colors.surface,
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        home: BlocProvider(
          create: (_) =>
              CatalogBloc(apiClient: _apiClient)
                ..add(const CatalogLoadRequested()),
          child: const CatalogScreen(),
        ),
      ),
    );
  }
}
