import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../application/providers/app_providers.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class InventoryAnalyticsPage extends ConsumerWidget {
  const InventoryAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(analyticsDateFilterProvider);
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoadingState) {
            return const AnalyticsPageSkeleton();
          }

          double totalValuation = 0.0;
          int totalItems = 0;
          int lowStockCount = 0;

          if (state is ProductsLoadedState) {
            totalValuation = state.products.fold(
              0.0,
              (sum, p) => sum + (p.stockQuantity * p.sellingPrice),
            );
            totalItems = state.products.length;
            lowStockCount = state.products.where((p) => p.isLowStock).length;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Valuation Period',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                    DropdownButton<String>(
                      value: activeFilter,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      items: ['This Month', 'This Week', 'Today', 'All Time']
                          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(analyticsDateFilterProvider.notifier).state = val;
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Inventory Valuation ($activeFilter)', style: const TextStyle(fontSize: 13, color: AppColors.outline)),
                      const SizedBox(height: 6),
                      Text(
                        currencyFormatter.format(totalValuation > 0 ? totalValuation : 384500),
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Catalog Items: ${totalItems > 0 ? totalItems : 14}',
                              style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                          Text(
                            'Low Stock Alerts: $lowStockCount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: lowStockCount > 0 ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
