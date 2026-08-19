import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductEntity? product;

  const ProductDetailsPage({super.key, this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  ProductEntity? _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    if (_currentProduct != null) {
      context.read<ProductBloc>().add(FetchStockMovementsEvent(_currentProduct!.id));
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _showEditProductDialog(ProductEntity p) {
    final nameCtrl = TextEditingController(text: p.name);
    final skuCtrl = TextEditingController(text: p.sku);
    final barcodeCtrl = TextEditingController(text: p.barcode);
    final categoryCtrl = TextEditingController(text: p.category);
    final sellingPriceCtrl = TextEditingController(text: p.sellingPrice.toStringAsFixed(0));
    final costPriceCtrl = TextEditingController(text: p.purchasePrice > 0 ? p.purchasePrice.toStringAsFixed(0) : '');
    final unitCtrl = TextEditingController(text: p.unit);
    final reorderLevelCtrl = TextEditingController(text: p.reorderLevel.toString());
    final descriptionCtrl = TextEditingController(text: p.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Product Details', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Product Name *', prefixIcon: Icon(Icons.shopping_bag_outlined))),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU', prefixIcon: Icon(Icons.qr_code)))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'Barcode', prefixIcon: Icon(Icons.barcode_reader)))),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined))),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: sellingPriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Selling Price (₹) *', prefixIcon: Icon(Icons.currency_rupee)))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: costPriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost Price (₹)', prefixIcon: Icon(Icons.sell_outlined)))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unit (Pcs, Box, etc.)', prefixIcon: Icon(Icons.straighten)))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: reorderLevelCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Low Stock Limit', prefixIcon: Icon(Icons.warning_amber_rounded)))),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: descriptionCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description / Remarks', prefixIcon: Icon(Icons.notes))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final updated = p.copyWith(
                  name: nameCtrl.text.trim(),
                  sku: skuCtrl.text.trim(),
                  barcode: barcodeCtrl.text.trim(),
                  category: categoryCtrl.text.trim().isNotEmpty ? categoryCtrl.text.trim() : 'General',
                  sellingPrice: double.tryParse(sellingPriceCtrl.text.trim()) ?? p.sellingPrice,
                  purchasePrice: double.tryParse(costPriceCtrl.text.trim()) ?? p.purchasePrice,
                  unit: unitCtrl.text.trim().isNotEmpty ? unitCtrl.text.trim() : 'Pcs',
                  reorderLevel: int.tryParse(reorderLevelCtrl.text.trim()) ?? p.reorderLevel,
                  description: descriptionCtrl.text.trim(),
                  updatedAt: DateTime.now(),
                );
                context.read<ProductBloc>().add(UpdateProductEvent(updated));
                setState(() => _currentProduct = updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product updated successfully!'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivateProduct(ProductEntity p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Product?'),
        content: Text('This product "${p.name}" will no longer appear in active product lists or new sales. Historical invoices and stock logs will remain intact.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProductEvent(productId: p.id, permanent: false));
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Product "${p.name}" deactivated.'), backgroundColor: AppColors.warning),
              );
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        ProductEntity? product = _currentProduct;

        if (state is ProductsLoadedState && product != null) {
          final matches = state.allProducts.where((p) => p.id == product!.id);
          if (matches.isNotEmpty) {
            product = matches.first;
          }
        }

        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product Details')),
            body: const EmptyState(title: 'Product Not Found', message: 'The requested product could not be located.'),
          );
        }

        final movements = state is ProductsLoadedState ? state.movements : <InventoryMovement>[];
        final isLow = product.isLowStock;
        final isOut = product.isOutOfStock;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Product Details'),
            backgroundColor: AppColors.deepNavy,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Product',
                onPressed: () => _showEditProductDialog(product!),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header Card
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isOut
                              ? AppColors.errorContainer
                              : (isLow ? AppColors.warningContainer : AppColors.primaryBlue.withValues(alpha: 0.12)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 36,
                          color: isOut ? AppColors.danger : (isLow ? AppColors.warning : AppColors.primaryBlue),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SKU: ${product.sku.isNotEmpty ? product.sku : "N/A"} • Category: ${product.category}',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                            if (product.barcode.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text('Barcode: ${product.barcode}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                            ],
                            const SizedBox(height: 8),
                            if (isOut)
                              StatusChip.outOfStock()
                            else if (isLow)
                              StatusChip.lowStock()
                            else
                              StatusChip.inStock(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pricing Card
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pricing Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DetailTile(
                              label: 'Selling Price',
                              value: _formatCurrency(product.sellingPrice),
                              valueColor: AppColors.primaryBlue,
                            ),
                          ),
                          Expanded(
                            child: _DetailTile(
                              label: 'Cost / Purchase Price',
                              value: product.purchasePrice > 0 ? _formatCurrency(product.purchasePrice) : 'N/A',
                              valueColor: AppColors.darkBlueText,
                            ),
                          ),
                          if (product.purchasePrice > 0)
                            Expanded(
                              child: _DetailTile(
                                label: 'Profit Margin',
                                value: '${(((product.sellingPrice - product.purchasePrice) / product.sellingPrice) * 100).toStringAsFixed(0)}%',
                                valueColor: AppColors.success,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stock & Reorder Info
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stock & Thresholds', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DetailTile(
                              label: 'Current Stock',
                              value: '${product.stockQuantity} ${product.unit}',
                              valueColor: isOut ? AppColors.danger : (isLow ? AppColors.warning : AppColors.success),
                            ),
                          ),
                          Expanded(
                            child: _DetailTile(
                              label: 'Low Stock Limit',
                              value: '${product.reorderLevel} ${product.unit}',
                              valueColor: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context.push(RouteNames.stockAdjustment, extra: {'product': product, 'initialAddition': true}),
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Restock Product', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context.push(RouteNames.stockAdjustment, extra: {'product': product}),
                        icon: const Icon(Icons.tune, size: 18, color: AppColors.primaryBlue),
                        label: const Text('Adjust Stock', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stock Movement History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Stock Movement History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                    Text('${movements.length} logs', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                  ],
                ),
                const SizedBox(height: 12),

                if (movements.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'No stock movements logged yet.\nUse Adjust Stock or Restock to add entries.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: movements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final m = movements[idx];
                      final isPositive = m.quantityChange >= 0;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              color: isPositive ? AppColors.success : AppColors.danger,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.reason, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkBlueText)),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('dd MMM yyyy, hh:mm a').format(m.timestamp),
                                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isPositive ? "+" : ""}${m.quantityChange}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: isPositive ? AppColors.success : AppColors.danger,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${m.previousQuantity} → ${m.newQuantity}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),

                // Deactivate Product Button
                Center(
                  child: TextButton.icon(
                    onPressed: () => _confirmDeactivateProduct(product!),
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                    label: const Text('Deactivate Product', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DetailTile({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: valueColor)),
      ],
    );
  }
}
