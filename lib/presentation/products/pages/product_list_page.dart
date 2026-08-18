import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/ui_state_widgets.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const FetchProductsEvent());
  }

  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.addProduct),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Product Name', controller: nameCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'SKU / Barcode', controller: skuCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'Selling Price (₹)', controller: priceCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AppTextField(label: 'Initial Stock Qty', controller: stockCtrl, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final newProd = ProductEntity(
                  id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  sku: skuCtrl.text.isNotEmpty ? skuCtrl.text : 'SKU-GEN-01',
                  category: 'General',
                  sellingPrice: double.tryParse(priceCtrl.text) ?? 100.0,
                  purchasePrice: (double.tryParse(priceCtrl.text) ?? 100.0) * 0.7,
                  stockQuantity: int.tryParse(stockCtrl.text) ?? 10,
                  createdAt: DateTime.now(),
                );
                context.read<ProductBloc>().add(CreateProductEvent(newProd));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Product'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.inventoryTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              context.push(RouteNames.stockAdjustment);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceCard,
            child: AppTextField(
              label: 'Search Catalog',
              hint: 'Search by item name, SKU, or category...',
              controller: _searchController,
              prefixIcon: Icons.search,
              onChanged: (q) {
                context.read<ProductBloc>().add(FetchProductsEvent(query: q));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoadingState) {
                  return const LoadingState(message: 'Loading inventory catalog...');
                }
                if (state is ProductsLoadedState) {
                  if (state.products.isEmpty) {
                    return const EmptyState(
                      title: 'No Products Found',
                      message: 'Create your inventory catalog to start billing & tracking stock.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final p = state.products[idx];
                      return AppCard(
                        onTap: () {
                          context.push(RouteNames.productDetails);
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: p.isLowStock
                                    ? AppColors.errorContainer
                                    : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                color: p.isLowStock ? AppColors.error : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p.sku} • ${p.category}',
                                    style: const TextStyle(fontSize: 13, color: AppColors.outline),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${p.sellingPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: p.isLowStock
                                        ? AppColors.errorContainer
                                        : AppColors.successContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${p.stockQuantity} ${p.unit}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: p.isLowStock ? AppColors.error : AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
