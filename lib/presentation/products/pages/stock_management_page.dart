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

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key});

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const FetchProductsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _showAddProductDialog(BuildContext context, {ProductEntity? productToEdit}) {
    final isEditing = productToEdit != null;
    final nameCtrl = TextEditingController(text: productToEdit?.name ?? '');
    final skuCtrl = TextEditingController(text: productToEdit?.sku ?? '');
    final barcodeCtrl = TextEditingController(text: productToEdit?.barcode ?? '');
    final categoryCtrl = TextEditingController(text: productToEdit?.category ?? 'General');
    final sellingPriceCtrl = TextEditingController(text: isEditing ? productToEdit.sellingPrice.toStringAsFixed(0) : '');
    final purchasePriceCtrl = TextEditingController(text: isEditing && productToEdit.purchasePrice > 0 ? productToEdit.purchasePrice.toStringAsFixed(0) : '');
    final stockCtrl = TextEditingController(text: isEditing ? productToEdit.stockQuantity.toString() : '10');
    final unitCtrl = TextEditingController(text: productToEdit?.unit ?? 'Pcs');
    final thresholdCtrl = TextEditingController(text: isEditing ? productToEdit.reorderLevel.toString() : '5');
    final descriptionCtrl = TextEditingController(text: productToEdit?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            isEditing ? 'Edit Product' : 'Add New Product',
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    hintText: 'e.g. Coca Cola 500ml',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: skuCtrl,
                        decoration: const InputDecoration(labelText: 'SKU', hintText: 'CC500', prefixIcon: Icon(Icons.qr_code)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: barcodeCtrl,
                        decoration: const InputDecoration(labelText: 'Barcode', hintText: '890123...', prefixIcon: Icon(Icons.barcode_reader)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(labelText: 'Category', hintText: 'Beverages, Food, etc.', prefixIcon: Icon(Icons.category_outlined)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sellingPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Selling Price (₹) *', prefixIcon: Icon(Icons.currency_rupee)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: purchasePriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cost Price (₹)', prefixIcon: Icon(Icons.sell_outlined)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        enabled: !isEditing,
                        decoration: InputDecoration(
                          labelText: isEditing ? 'Stock' : 'Opening Stock',
                          prefixIcon: const Icon(Icons.inventory),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        decoration: const InputDecoration(labelText: 'Unit', hintText: 'Pcs, Kg, Box', prefixIcon: Icon(Icons.straighten)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: thresholdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Low Stock Threshold',
                    hintText: 'Default 5',
                    prefixIcon: Icon(Icons.warning_amber_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.notes)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final sellingPrice = double.tryParse(sellingPriceCtrl.text.trim()) ?? 0.0;
                  final costPrice = double.tryParse(purchasePriceCtrl.text.trim()) ?? 0.0;
                  final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
                  final threshold = int.tryParse(thresholdCtrl.text.trim()) ?? 5;

                  if (isEditing) {
                    final updated = productToEdit.copyWith(
                      name: nameCtrl.text.trim(),
                      sku: skuCtrl.text.trim(),
                      barcode: barcodeCtrl.text.trim(),
                      category: categoryCtrl.text.trim().isNotEmpty ? categoryCtrl.text.trim() : 'General',
                      sellingPrice: sellingPrice,
                      purchasePrice: costPrice,
                      unit: unitCtrl.text.trim().isNotEmpty ? unitCtrl.text.trim() : 'Pcs',
                      reorderLevel: threshold,
                      description: descriptionCtrl.text.trim(),
                      updatedAt: DateTime.now(),
                    );
                    context.read<ProductBloc>().add(UpdateProductEvent(updated));
                  } else {
                    final newProd = ProductEntity(
                      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      sku: skuCtrl.text.trim().isNotEmpty ? skuCtrl.text.trim() : 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      barcode: barcodeCtrl.text.trim(),
                      category: categoryCtrl.text.trim().isNotEmpty ? categoryCtrl.text.trim() : 'General',
                      sellingPrice: sellingPrice,
                      purchasePrice: costPrice,
                      stockQuantity: stock,
                      reorderLevel: threshold,
                      unit: unitCtrl.text.trim().isNotEmpty ? unitCtrl.text.trim() : 'Pcs',
                      description: descriptionCtrl.text.trim(),
                      createdAt: DateTime.now(),
                    );
                    context.read<ProductBloc>().add(CreateProductEvent(newProd));
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Product updated successfully!' : 'Product added to inventory!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text(isEditing ? 'Update Product' : 'Save Product'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context, ProductsLoadedState state) {
    String tempStockFilter = state.selectedStockFilter;
    String tempCategory = state.selectedCategory;
    String tempSort = state.sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetCtx).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filter & Sort Inventory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(sheetCtx)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Stock Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: ['All', 'In Stock', 'Low Stock', 'Out of Stock', 'Inactive'].map((st) {
                                final isSelected = tempStockFilter == st;
                                return ChoiceChip(
                                  label: Text(st),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.darkBlueText, fontWeight: FontWeight.w700),
                                  onSelected: (val) {
                                    if (val) setSheetState(() => tempStockFilter = st);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: state.categories.map((cat) {
                                final isSelected = tempCategory == cat;
                                return ChoiceChip(
                                  label: Text(cat),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.darkBlueText, fontWeight: FontWeight.w700),
                                  onSelected: (val) {
                                    if (val) setSheetState(() => tempCategory = cat);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            const Text('Sort By', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: ['Name', 'Stock Quantity', 'Price', 'Low Stock First', 'Recently Updated'].map((sortOpt) {
                                final isSelected = tempSort == sortOpt;
                                return ChoiceChip(
                                  label: Text(sortOpt),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.darkBlueText, fontWeight: FontWeight.w700),
                                  onSelected: (val) {
                                    if (val) setSheetState(() => tempSort = sortOpt);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          context.read<ProductBloc>().add(
                                FetchProductsEvent(
                                  query: state.searchQuery,
                                  stockFilter: tempStockFilter,
                                  category: tempCategory,
                                  sortBy: tempSort,
                                ),
                              );
                          Navigator.pop(sheetCtx);
                        },
                        child: const Text('Apply Inventory Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeactivateProduct(BuildContext context, ProductEntity product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Product?'),
        content: Text('This product "${product.name}" will no longer appear in active product lists or new sales. Past sales & invoice history will remain safe.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProductEvent(productId: product.id, permanent: false));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Product "${product.name}" deactivated.'), backgroundColor: AppColors.warning),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showAddProductDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoadingState || state is ProductInitialState) {
            return const LoadingState(message: 'Loading inventory...');
          }

          if (state is ProductErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<ProductBloc>().add(const FetchProductsEvent()),
            );
          }

          if (state is ProductsLoadedState) {
            return Column(
              children: [
                // Top Stock Metrics Summary Bar
                _buildTopSummaryBar(context, state),
                const Divider(height: 1, color: AppColors.border),

                // Stock Health Breakdown Bar
                _buildStockHealthBar(state),

                // Search Bar + Filter Button Row
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            context.read<ProductBloc>().add(
                                  FetchProductsEvent(
                                    query: val,
                                    stockFilter: state.selectedStockFilter,
                                    category: state.selectedCategory,
                                    sortBy: state.sortBy,
                                  ),
                                );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search products by name, SKU, or barcode...',
                            hintStyle: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                            prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: (state.selectedStockFilter != 'All' || state.selectedCategory != 'All')
                              ? AppColors.primaryBlue.withValues(alpha: 0.15)
                              : AppColors.surfaceContainerLow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(
                          Icons.filter_list,
                          color: (state.selectedStockFilter != 'All' || state.selectedCategory != 'All')
                              ? AppColors.primaryBlue
                              : AppColors.darkBlueText,
                        ),
                        onPressed: () => _showFilterBottomSheet(context, state),
                        tooltip: 'Filter Inventory',
                      ),
                    ],
                  ),
                ),

                // Horizontally Scrollable Filter Chips Bar
                _buildFilterChipsBar(context, state),

                // Main Product List Content
                Expanded(
                  child: _buildProductList(context, state),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // TOP SUMMARY BAR
  Widget _buildTopSummaryBar(BuildContext context, ProductsLoadedState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryBox(
                  label: 'Total Products',
                  value: '${state.totalProducts}',
                  subText: '${state.totalItems} Total Items',
                  valueColor: AppColors.darkBlueText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<ProductBloc>().add(
                          FetchProductsEvent(
                            query: state.searchQuery,
                            stockFilter: 'Low Stock',
                            category: state.selectedCategory,
                            sortBy: state.sortBy,
                          ),
                        );
                  },
                  child: _SummaryBox(
                    label: 'Low Stock',
                    value: '${state.lowStockCount}',
                    subText: 'Running Low',
                    valueColor: state.lowStockCount > 0 ? AppColors.warning : AppColors.secondaryText,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<ProductBloc>().add(
                          FetchProductsEvent(
                            query: state.searchQuery,
                            stockFilter: 'Out of Stock',
                            category: state.selectedCategory,
                            sortBy: state.sortBy,
                          ),
                        );
                  },
                  child: _SummaryBox(
                    label: 'Out of Stock',
                    value: '${state.outOfStockCount}',
                    subText: 'Empty Stock',
                    valueColor: state.outOfStockCount > 0 ? AppColors.danger : AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.secondaryText),
                    const SizedBox(width: 6),
                    const Text('Stock Value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                  ],
                ),
                Text(
                  _formatCurrency(state.stockValue),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // COMPACT STOCK HEALTH BAR
  Widget _buildStockHealthBar(ProductsLoadedState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Text('Stock Health: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
          _HealthBadge(label: 'Healthy ${state.healthyCount}', color: AppColors.success, bg: AppColors.successContainer),
          const SizedBox(width: 6),
          _HealthBadge(label: 'Low ${state.lowStockCount}', color: AppColors.warning, bg: AppColors.warningContainer),
          const SizedBox(width: 6),
          _HealthBadge(label: 'Out ${state.outOfStockCount}', color: AppColors.danger, bg: AppColors.errorContainer),
        ],
      ),
    );
  }

  // HORIZONTALLY SCROLLABLE FILTER CHIPS
  Widget _buildFilterChipsBar(BuildContext context, ProductsLoadedState state) {
    final filters = ['All', 'In Stock', 'Low Stock', 'Out of Stock'];

    return Container(
      color: Colors.white,
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: filters.length + state.categories.length - 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, idx) {
          if (idx < filters.length) {
            final f = filters[idx];
            final isSelected = state.selectedStockFilter == f && state.selectedCategory == 'All';
            return ChoiceChip(
              label: Text(f),
              selected: isSelected,
              selectedColor: AppColors.primaryBlue,
              backgroundColor: AppColors.surfaceContainerLow,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.darkBlueText,
              ),
              onSelected: (val) {
                if (val) {
                  context.read<ProductBloc>().add(
                        FetchProductsEvent(
                          query: state.searchQuery,
                          stockFilter: f,
                          category: 'All',
                          sortBy: state.sortBy,
                        ),
                      );
                }
              },
            );
          } else {
            final cat = state.categories[idx - filters.length + 1];
            final isSelected = state.selectedCategory == cat;
            return ChoiceChip(
              label: Text('Cat: $cat'),
              selected: isSelected,
              selectedColor: AppColors.primaryBlue,
              backgroundColor: AppColors.surfaceContainerLow,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.darkBlueText,
              ),
              onSelected: (val) {
                if (val) {
                  context.read<ProductBloc>().add(
                        FetchProductsEvent(
                          query: state.searchQuery,
                          stockFilter: state.selectedStockFilter,
                          category: cat,
                          sortBy: state.sortBy,
                        ),
                      );
                }
              },
            );
          }
        },
      ),
    );
  }

  // PRODUCT LIST CONTENT
  Widget _buildProductList(BuildContext context, ProductsLoadedState state) {
    if (state.filteredProducts.isEmpty) {
      return EmptyState(
        title: 'No Products Found',
        message: state.searchQuery.isNotEmpty || state.selectedStockFilter != 'All'
            ? 'Try changing your search or filters.'
            : 'Add your first product to start managing your inventory.',
        icon: Icons.inventory_2_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredProducts.length + (state.outOfStockCount > 0 || state.lowStockCount > 0 ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        // Render Stock Alerts Banner as first item if issues exist
        if ((state.outOfStockCount > 0 || state.lowStockCount > 0) && idx == 0) {
          return _buildStockAlertsCard(context, state);
        }

        final productIdx = (state.outOfStockCount > 0 || state.lowStockCount > 0) ? idx - 1 : idx;
        final p = state.filteredProducts[productIdx];
        final isLow = p.isLowStock;
        final isOut = p.isOutOfStock;

        return AppCard(
          onTap: () => context.push(RouteNames.productDetails, extra: p),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isOut
                      ? AppColors.errorContainer
                      : (isLow ? AppColors.warningContainer : AppColors.primaryBlue.withValues(alpha: 0.12)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: isOut ? AppColors.danger : (isLow ? AppColors.warning : AppColors.primaryBlue),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isOut)
                          StatusChip.outOfStock()
                        else if (isLow)
                          StatusChip.lowStock()
                        else
                          StatusChip.inStock(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${p.sku.isNotEmpty ? p.sku : "N/A"} • ${p.category}',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Stock: ${p.stockQuantity} ${p.unit}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isOut ? AppColors.danger : (isLow ? AppColors.warning : AppColors.darkBlueText),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatCurrency(p.sellingPrice),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOut || isLow) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    context.push(RouteNames.stockAdjustment, extra: {'product': p, 'initialAddition': true});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Restock', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.secondaryText),
                onSelected: (val) {
                  if (val == 'details') {
                    context.push(RouteNames.productDetails, extra: p);
                  } else if (val == 'adjust') {
                    context.push(RouteNames.stockAdjustment, extra: {'product': p});
                  } else if (val == 'edit') {
                    _showAddProductDialog(context, productToEdit: p);
                  } else if (val == 'deactivate') {
                    _confirmDeactivateProduct(context, p);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'details', child: Row(children: [Icon(Icons.visibility_outlined, size: 18), SizedBox(width: 8), Text('View Details')])),
                  PopupMenuItem(value: 'adjust', child: Row(children: [Icon(Icons.tune, size: 18), SizedBox(width: 8), Text('Adjust Stock')])),
                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit Product')])),
                  PopupMenuItem(value: 'deactivate', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Deactivate', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // STOCK ALERTS CARD BANNER
  Widget _buildStockAlertsCard(BuildContext context, ProductsLoadedState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
              SizedBox(width: 6),
              Text('Stock Alerts', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.darkBlueText)),
            ],
          ),
          const SizedBox(height: 6),
          if (state.outOfStockCount > 0)
            GestureDetector(
              onTap: () {
                context.read<ProductBloc>().add(
                      FetchProductsEvent(
                        query: state.searchQuery,
                        stockFilter: 'Out of Stock',
                        category: state.selectedCategory,
                        sortBy: state.sortBy,
                      ),
                    );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('⚠ ${state.outOfStockCount} products are out of stock (Tap to view)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.danger)),
              ),
            ),
          if (state.lowStockCount > 0)
            GestureDetector(
              onTap: () {
                context.read<ProductBloc>().add(
                      FetchProductsEvent(
                        query: state.searchQuery,
                        stockFilter: 'Low Stock',
                        category: state.selectedCategory,
                        sortBy: state.sortBy,
                      ),
                    );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('⚠ ${state.lowStockCount} products are running low in stock (Tap to view)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.warning)),
              ),
            ),
        ],
      ),
    );
  }
}

// SUMMARY BOX WIDGET
class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final String subText;
  final Color valueColor;

  const _SummaryBox({
    required this.label,
    required this.value,
    required this.subText,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText), maxLines: 1),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: valueColor),
            ),
          ),
          const SizedBox(height: 2),
          Text(subText, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText), maxLines: 1),
        ],
      ),
    );
  }
}

// HEALTH BADGE
class _HealthBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _HealthBadge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
