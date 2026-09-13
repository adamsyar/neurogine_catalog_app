import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/product_detail_bloc.dart';
import 'bloc/product_detail_load_requested.dart';
import 'bloc/product_detail_state.dart';
import 'product_detail_content.dart';
import 'product_detail_loading.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
              builder: (context, state) {
                return switch (state.status) {
                  ProductDetailStatus.initial ||
                  ProductDetailStatus.loading => const ProductDetailLoading(),
                  ProductDetailStatus.success => ProductDetailContent(
                    product: state.product!,
                  ),
                  ProductDetailStatus.failure => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => context
                                .read<ProductDetailBloc>()
                                .add(const ProductDetailLoadRequested()),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}
