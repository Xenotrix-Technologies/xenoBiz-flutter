import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/product_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class ServicesListPage extends StatefulWidget {
  const ServicesListPage({super.key});

  @override
  State<ServicesListPage> createState() => _ServicesListPageState();
}

class _ServicesListPageState extends State<ServicesListPage> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _sortBy = 'Name';

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

  void _confirmDeleteService(BuildContext context, ProductEntity service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service?'),
        content: Text(
            'Are you sure you want to delete "${service.name}"? Past invoices containing this service will remain safe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<ProductBloc>().add(
                    DeleteProductEvent(productId: service.id, permanent: false),
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Service "${service.name}" deleted.'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, ProductsLoadedState state) {
    String tempCategory = _selectedCategory;
    String tempSort = _sortBy;

    final categories = state.serviceCategories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter & Sort Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Filter by Category
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSel = tempCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.surfaceContainerLow,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : AppColors.darkBlueText,
                          ),
                          onSelected: (val) {
                            if (val) setSheetState(() => tempCategory = cat);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Sort Options
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Name',
                        'Price: High to Low',
                        'Price: Low to High',
                        'Recently Updated',
                      ].map((s) {
                        final isSel = tempSort == s;
                        return ChoiceChip(
                          label: Text(s),
                          selected: isSel,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.surfaceContainerLow,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : AppColors.darkBlueText,
                          ),
                          onSelected: (val) {
                            if (val) setSheetState(() => tempSort = s);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'All';
                                _sortBy = 'Name';
                              });
                              Navigator.pop(sheetCtx);
                            },
                            child: const Text('Reset All',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedCategory = tempCategory;
                                _sortBy = tempSort;
                              });
                              Navigator.pop(sheetCtx);
                            },
                            child: const Text('Apply Filters',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
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

  void _showServiceDetails(BuildContext context, ProductEntity service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Service Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.design_services_outlined,
                          size: 30,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Category: ${service.category}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildDetailRow('Service Rate', _formatCurrency(service.sellingPrice)),
                if (service.hsnCode.isNotEmpty)
                  _buildDetailRow('SAC Code', service.hsnCode),
                if (service.sku.isNotEmpty)
                  _buildDetailRow('Item Code / SKU', service.sku),
                if (service.description.isNotEmpty)
                  _buildDetailRow('Description', service.description),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await context.push(
                            RouteNames.createMaster,
                            extra: service,
                          );
                          if (context.mounted) {
                            context
                                .read<ProductBloc>()
                                .add(const FetchProductsEvent());
                          }
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Service',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmDeleteService(context, service);
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlueText,
              ),
              textAlign: TextAlign.end,
            ),
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
        title: const Text('Services'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
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
            final query = _searchController.text.trim().toLowerCase();

            // Filter services (all items with isService == true & isActive == true)
            var services = state.allProducts.where((p) => p.isService && p.isActive).toList();

            // Category filter
            if (_selectedCategory != 'All') {
              services = services.where((s) => s.category == _selectedCategory).toList();
            }

            // Search query filter
            if (query.isNotEmpty) {
              services = services.where((s) {
                return s.name.toLowerCase().contains(query) ||
                    s.sku.toLowerCase().contains(query) ||
                    s.hsnCode.toLowerCase().contains(query) ||
                    s.category.toLowerCase().contains(query);
              }).toList();
            }

            // Sorting
            switch (_sortBy) {
              case 'Price: High to Low':
                services.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
                break;
              case 'Price: Low to High':
                services.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
                break;
              case 'Recently Updated':
                services.sort((a, b) {
                  final tA = a.updatedAt ?? a.createdAt;
                  final tB = b.updatedAt ?? b.createdAt;
                  return tB.compareTo(tA);
                });
                break;
              case 'Name':
              default:
                services.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                break;
            }

            final serviceCategories = state.serviceCategories;

            return Column(
              children: [
                // 1. Search Bar + Filter Button Row (Identical to Inventory Screen)
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText:
                                'Search services by name, SAC, or category...',
                            hintStyle: const TextStyle(
                                fontSize: 13, color: AppColors.secondaryText),
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.secondaryText, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
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
                          backgroundColor: (_selectedCategory != 'All' ||
                                  _sortBy != 'Name')
                              ? AppColors.primaryBlue.withValues(alpha: 0.15)
                              : AppColors.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(
                          Icons.filter_list,
                          color: (_selectedCategory != 'All' ||
                                  _sortBy != 'Name')
                              ? AppColors.primaryBlue
                              : AppColors.darkBlueText,
                        ),
                        onPressed: () => _showFilterBottomSheet(context, state),
                        tooltip: 'Filter Services',
                      ),
                    ],
                  ),
                ),

                // 2. Horizontally Scrollable Filter Chips Bar (Identical to Inventory Screen)
                if (serviceCategories.length > 1)
                  Container(
                    color: Colors.white,
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      itemCount: serviceCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, idx) {
                        final cat = serviceCategories[idx];
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat == 'All' ? 'All' : 'Cat: $cat'),
                          selected: isSelected,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.surfaceContainerLow,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected ? Colors.white : AppColors.darkBlueText,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),

                // 3. Services List Content
                Expanded(
                  child: services.isEmpty
                      ? EmptyState(
                          title: 'No Services Found',
                          message: query.isNotEmpty || _selectedCategory != 'All'
                              ? 'No services matching your search or filter.'
                              : 'Add your first service to offer non-physical goods & labor.',
                          icon: Icons.design_services_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: services.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final s = services[idx];

                            return AppCard(
                              onTap: () => _showServiceDetails(context, s),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.design_services_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.darkBlueText,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (s.hsnCode.isNotEmpty)
                                              Text(
                                                'SAC: ${s.hsnCode}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.secondaryText,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              )
                                            else if (s.sku.isNotEmpty)
                                              Text(
                                                'Code: ${s.sku}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.secondaryText,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              )
                                            else
                                              const Text(
                                                'Service Item',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.secondaryText,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            if (s.category.isNotEmpty &&
                                                s.category != 'General') ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppColors.pageBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                      color: AppColors.border),
                                                ),
                                                child: Text(
                                                  s.category,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors
                                                        .secondaryText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatCurrency(s.sellingPrice),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert,
                                        size: 20, color: AppColors.secondaryText),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onSelected: (val) async {
                                      if (val == 'view') {
                                        _showServiceDetails(context, s);
                                      } else if (val == 'edit') {
                                        await context.push(
                                          RouteNames.createMaster,
                                          extra: s,
                                        );
                                        if (context.mounted) {
                                          context.read<ProductBloc>().add(
                                                const FetchProductsEvent(),
                                              );
                                        }
                                      } else if (val == 'delete') {
                                        _confirmDeleteService(context, s);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'view',
                                        child: Row(
                                          children: [
                                            Icon(Icons.visibility_outlined,
                                                size: 18,
                                                color: AppColors.primaryBlue),
                                            SizedBox(width: 8),
                                            Text('View'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined,
                                                size: 18,
                                                color: AppColors.primaryBlue),
                                            SizedBox(width: 8),
                                            Text('Edit Service'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline,
                                                size: 18,
                                                color: AppColors.danger),
                                            SizedBox(width: 8),
                                            Text('Delete',
                                                style: TextStyle(
                                                    color: AppColors.danger)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
