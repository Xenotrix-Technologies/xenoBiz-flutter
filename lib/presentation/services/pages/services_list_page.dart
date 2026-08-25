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

  void _showServiceDetails(BuildContext context, ProductEntity service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                const SizedBox(height: 16),
                _buildDetailRow('Service Code / SAC', service.sku.isNotEmpty ? service.sku : 'N/A'),
                _buildDetailRow('Price', _formatCurrency(service.sellingPrice)),
                if (service.taxPercentage != null && service.taxPercentage! > 0)
                  _buildDetailRow('Tax / GST', '${service.taxPercentage!.toStringAsFixed(0)}%'),
                if (service.description.isNotEmpty)
                  _buildDetailRow('Description', service.description),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push(RouteNames.createMaster, extra: service);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text(
                      'Edit Service',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlueText,
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
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Service',
            onPressed: () async {
              await context.push(
                RouteNames.createMaster,
                extra: {'tab': 0, 'isService': true},
              );
              if (context.mounted) {
                context.read<ProductBloc>().add(const FetchProductsEvent());
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_service_fab',
        backgroundColor: AppColors.primaryBlue,
        onPressed: () async {
          await context.push(
            RouteNames.createMaster,
            extra: {'tab': 0, 'isService': true},
          );
          if (context.mounted) {
            context.read<ProductBloc>().add(const FetchProductsEvent());
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Service',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
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
            final services = state.allProducts.where((p) {
              if (!p.isService || !p.isActive) return false;
              if (query.isEmpty) return true;
              return p.name.toLowerCase().contains(query) ||
                  p.sku.toLowerCase().contains(query) ||
                  p.category.toLowerCase().contains(query);
            }).toList();

            return Column(
              children: [
                // Search Bar
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search services by name, SAC, or category...',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: AppColors.secondaryText),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.secondaryText, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),

                // Services List Content
                Expanded(
                  child: services.isEmpty
                      ? EmptyState(
                          title: 'No Services Found',
                          message: query.isNotEmpty
                              ? 'No services matching "$query".'
                              : 'Add your first service to offer non-physical goods & labor.',
                          icon: Icons.design_services_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 80),
                          itemCount: services.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final s = services[idx];

                            return Container(
                              padding: const EdgeInsets.all(14),
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
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
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
                                  const SizedBox(width: 12),
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
                                        const SizedBox(height: 3),
                                        Text(
                                          s.hsnCode.isNotEmpty
                                              ? 'SAC: ${s.hsnCode}'
                                              : (s.sku.isNotEmpty ? 'Code: ${s.sku}' : 'Service Item'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.secondaryText,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                                    itemBuilder: (ctx) => const [
                                      PopupMenuItem(
                                        value: 'view',
                                        height: 38,
                                        child: Row(
                                          children: [
                                            Icon(Icons.visibility_outlined,
                                                size: 18,
                                                color: AppColors.primaryBlue),
                                            SizedBox(width: 10),
                                            Text('View',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
                                        height: 38,
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined,
                                                size: 18,
                                                color: AppColors.primaryBlue),
                                            SizedBox(width: 10),
                                            Text('Edit Service',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        height: 38,
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline,
                                                size: 18,
                                                color: AppColors.danger),
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
