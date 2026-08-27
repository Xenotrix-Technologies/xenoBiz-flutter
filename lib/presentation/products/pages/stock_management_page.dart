import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/product_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/product_entity.dart';

import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key});

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  Completer<void>? _refreshCompleter;

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
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  Future<void> _handleRefresh(ProductsLoadedState state) async {
    final bloc = context.read<ProductBloc>();
    final streamFuture = bloc.stream.firstWhere(
      (s) => s is ProductsLoadedState || s is ProductErrorState,
    );

    bloc.add(
      FetchProductsEvent(
        query: _searchController.text,
        stockFilter: state.selectedStockFilter,
        category: state.selectedCategory,
        sortBy: state.sortBy,
      ),
    );

    await Future.any([
      streamFuture,
      Future.delayed(const Duration(milliseconds: 800)),
    ]);
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
                        const Text('Filter & Sort Inventory',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetCtx)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Stock Status',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlueText)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                'All',
                                'In Stock',
                                'Low Stock',
                                'Out of Stock',
                                'Inactive'
                              ].map((st) {
                                final isSelected = tempStockFilter == st;
                                return ChoiceChip(
                                  label: Text(st),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.darkBlueText,
                                      fontWeight: FontWeight.w700),
                                  onSelected: (val) {
                                    if (val) {
                                      setSheetState(() => tempStockFilter = st);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            const Text('Category',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlueText)),
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
                                  labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.darkBlueText,
                                      fontWeight: FontWeight.w700),
                                  onSelected: (val) {
                                    if (val) {
                                      setSheetState(() => tempCategory = cat);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            const Text('Sort By',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlueText)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                'Name',
                                'Stock Quantity',
                                'Price',
                                'Low Stock First',
                                'Recently Updated'
                              ].map((sortOpt) {
                                final isSelected = tempSort == sortOpt;
                                return ChoiceChip(
                                  label: Text(sortOpt),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.darkBlueText,
                                      fontWeight: FontWeight.w700),
                                  onSelected: (val) {
                                    if (val) {
                                      setSheetState(() => tempSort = sortOpt);
                                    }
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
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
                        child: const Text('Apply Inventory Filter',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
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
        content: Text(
            'This product "${product.name}" will no longer appear in active product lists or new sales. Past sales & invoice history will remain safe.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white),
            onPressed: () {
              context.read<ProductBloc>().add(
                  DeleteProductEvent(productId: product.id, permanent: false));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Product "${product.name}" deactivated.'),
                    backgroundColor: AppColors.warning),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Product',
            onPressed: () async {
              await context.push(RouteNames.createMaster, extra: 0);
              if (context.mounted) {
                final currentState = context.read<ProductBloc>().state;
                if (currentState is ProductsLoadedState) {
                  context.read<ProductBloc>().add(
                        FetchProductsEvent(
                          query: _searchController.text,
                          stockFilter: currentState.selectedStockFilter,
                          category: currentState.selectedCategory,
                          sortBy: currentState.sortBy,
                        ),
                      );
                } else {
                  context.read<ProductBloc>().add(const FetchProductsEvent());
                }
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductsLoadedState || state is ProductErrorState) {
            if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
              _refreshCompleter!.complete();
            }
          }
          if (state is ProductErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to refresh inventory: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductLoadingState || state is ProductInitialState) {
            return const StockManagementSkeleton();
          }

          if (state is ProductErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<ProductBloc>().add(const FetchProductsEvent()),
            );
          }

          if (state is ProductsLoadedState) {
            return Column(
              children: [
                // Search Bar + Filter Button Row
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            hintText:
                                'Search products by name, SKU, or barcode...',
                            hintStyle: const TextStyle(
                                fontSize: 13, color: AppColors.secondaryText),
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.secondaryText, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: (state.selectedStockFilter !=
                                      'All' ||
                                  state.selectedCategory != 'All')
                              ? AppColors.primaryBlue.withValues(alpha: 0.15)
                              : AppColors.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(
                          Icons.filter_list,
                          color: (state.selectedStockFilter != 'All' ||
                                  state.selectedCategory != 'All')
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
            final isSelected = state.selectedStockFilter == f &&
                state.selectedCategory == 'All';
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
    final physicalProducts =
        state.filteredProducts.where((p) => p.isProduct).toList();

    Widget childWidget;
    if (physicalProducts.isEmpty) {
      childWidget = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          child: EmptyState(
            title: 'No Products Found',
            message: state.searchQuery.isNotEmpty ||
                    state.selectedStockFilter != 'All'
                ? 'Try changing your search or filters.'
                : 'Add your first product to start managing your inventory.',
            icon: Icons.inventory_2_outlined,
          ),
        ),
      );
    } else {
      childWidget = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        itemCount: physicalProducts.length +
            (state.outOfStockCount > 0 || state.lowStockCount > 0 ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, idx) {
          // Render Stock Alerts Banner as first item if issues exist
          if ((state.outOfStockCount > 0 || state.lowStockCount > 0) &&
              idx == 0) {
            return _buildStockAlertsCard(context, state);
          }

          final productIdx =
              (state.outOfStockCount > 0 || state.lowStockCount > 0)
                  ? idx - 1
                  : idx;
          final p = physicalProducts[productIdx];
          final isLow = p.isLowStock;
          final isOut = p.isOutOfStock;

          return Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Container Icon (Rounded Square matching Invoice Tile)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isOut
                          ? AppColors.errorContainer
                          : (isLow
                              ? AppColors.warningContainer
                              : AppColors.primaryBlue.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: isOut
                          ? AppColors.danger
                          : (isLow ? AppColors.warning : AppColors.primaryBlue),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Middle Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row 1: CATEGORY • Product Name
                        Row(
                          children: [
                            Text(
                              p.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'PlusJakartaSans',
                                color: isOut
                                    ? AppColors.danger
                                    : (isLow
                                        ? AppColors.warning
                                        : AppColors.primaryBlue),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '•',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.darkBlueText,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'PlusJakartaSans',
                                  color: AppColors.darkBlueText,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Row 2: Stock Count & optional SKU
                        Text(
                          p.sku.trim().isNotEmpty
                              ? 'SKU: ${p.sku} · Stock: ${p.stockQuantity} ${p.unit}'
                              : 'Stock: ${p.stockQuantity} ${p.unit}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'PlusJakartaSans',
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right Column: Price top row, Status Chip bottom row
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatCurrency(p.sellingPrice),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'PlusJakartaSans',
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 2),
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (isOut)
                        StatusChip.outOfStock()
                      else if (isLow)
                        StatusChip.lowStock()
                      else
                        StatusChip.inStock(),
                    ],
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    elevation: 4,
                    onSelected: (value) async {
                      if (value == 'view') {
                        await context.push(RouteNames.productDetails, extra: p);
                        if (context.mounted) {
                          context.read<ProductBloc>().add(
                                FetchProductsEvent(
                                  query: _searchController.text,
                                  stockFilter: state.selectedStockFilter,
                                  category: state.selectedCategory,
                                  sortBy: state.sortBy,
                                ),
                              );
                        }
                      } else if (value == 'edit') {
                        await context.push(RouteNames.createMaster, extra: p);
                        if (context.mounted) {
                          context.read<ProductBloc>().add(
                                FetchProductsEvent(
                                  query: _searchController.text,
                                  stockFilter: state.selectedStockFilter,
                                  category: state.selectedCategory,
                                  sortBy: state.sortBy,
                                ),
                              );
                        }
                      } else if (value == 'delete') {
                        _confirmDeactivateProduct(context, p);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem<String>(
                        value: 'view',
                        height: 38,
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined,
                                size: 18, color: AppColors.primaryBlue),
                            SizedBox(width: 10),
                            Text('View',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkBlueText)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit',
                        height: 38,
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 18, color: AppColors.primaryBlue),
                            SizedBox(width: 10),
                            Text('Edit',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkBlueText)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        height: 38,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: AppColors.danger),
                            SizedBox(width: 10),
                            Text('Delete',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.only(
                          left: 2.0, right: 0.0, top: 4.0, bottom: 4.0),
                      child: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      backgroundColor: Colors.white,
      onRefresh: () => _handleRefresh(state),
      child: childWidget,
    );
  }

  // STOCK ALERTS CARD BANNER
  Widget _buildStockAlertsCard(
      BuildContext context, ProductsLoadedState state) {
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
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning, size: 18),
              SizedBox(width: 6),
              Text('Stock Alerts',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.darkBlueText)),
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
                child: Text(
                    '⚠ ${state.outOfStockCount} products are out of stock (Tap to view)',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger)),
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
                child: Text(
                    '⚠ ${state.lowStockCount} products are running low in stock (Tap to view)',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning)),
              ),
            ),
        ],
      ),
    );
  }
}
