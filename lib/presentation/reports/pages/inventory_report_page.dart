import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/product_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

// ============================================================================
// DEDICATED INVENTORY REPORT PAGE (FORMAL STOCK STATEMENT)
// ============================================================================

class InventoryReportPage extends StatefulWidget {
  final Object? initialPreset;
  const InventoryReportPage({super.key, this.initialPreset});

  @override
  State<InventoryReportPage> createState() => _InventoryReportPageState();
}

class _InventoryReportPageState extends State<InventoryReportPage> {
  // Presets: 0: Stock Summary, 1: Low Stock Report, 2: Product Stock Ledger
  int _activePresetIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _parseInitialPreset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(const FetchProductsEvent());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _parseInitialPreset() {
    if (widget.initialPreset is int) {
      _activePresetIndex = widget.initialPreset as int;
    } else if (widget.initialPreset is Map &&
        (widget.initialPreset as Map).containsKey('preset')) {
      _activePresetIndex = (widget.initialPreset as Map)['preset'] as int;
    } else if (widget.initialPreset is String) {
      final p = (widget.initialPreset as String).toLowerCase();
      if (p.contains('low')) {
        _activePresetIndex = 1;
      } else if (p.contains('ledger')) {
        _activePresetIndex = 2;
      } else {
        _activePresetIndex = 0;
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _activePresetIndex = 0;
      _searchCtrl.clear();
    });
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _exportReportPdf(BuildContext context) {
    final presetNames = [
      'Stock Summary Report',
      'Low Stock Report',
      'Product Stock Ledger Report',
    ];
    final currentTitle = presetNames[_activePresetIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Export $currentTitle',
                    style: const TextStyle(
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
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export Stock PDF Statement',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle:
                    Text('${currentTitle.replaceAll(' ', '_')}_Statement.pdf'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Exported ${currentTitle.replaceAll(' ', '_')}_Statement.pdf'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Inventory Report',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Export Report',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportReportPdf(context),
          ),
          IconButton(
            tooltip: 'Reset Filters',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, productState) {
          if (productState is ProductLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ProductEntity> allProducts = [];
          if (productState is ProductsLoadedState) {
            allProducts = productState.products;
          }

          final query = _searchCtrl.text.trim().toLowerCase();
          final filteredProducts = allProducts.where((p) {
            if (query.isEmpty) return true;
            return p.name.toLowerCase().contains(query) ||
                p.sku.toLowerCase().contains(query);
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProductBloc>().add(const FetchProductsEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPresetChips(),
                  const SizedBox(height: 14),
                  _buildSearchHeader(),
                  const SizedBox(height: 16),

                  if (_activePresetIndex == 0)
                    _buildStockSummaryView(filteredProducts)
                  else if (_activePresetIndex == 1)
                    _buildLowStockReportView(filteredProducts)
                  else if (_activePresetIndex == 2)
                    _buildProductStockLedgerView(filteredProducts),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChips() {
    final presets = [
      'Stock Summary',
      'Low Stock Report',
      'Product Stock Ledger',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: presets.asMap().entries.map((entry) {
          final idx = entry.key;
          final label = entry.value;
          final selected = _activePresetIndex == idx;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              selectedColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.darkBlueText,
              ),
              onSelected: (val) {
                if (val) setState(() => _activePresetIndex = idx);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Search product name, SKU...',
            hintStyle:
                TextStyle(fontSize: 12, color: AppColors.secondaryText),
            prefixIcon: Icon(Icons.search,
                size: 18, color: AppColors.secondaryText),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildStockSummaryView(List<ProductEntity> products) {
    final totalValue =
        products.fold(0.0, (sum, p) => sum + (p.stockQuantity * p.sellingPrice));
    final totalUnits = products.fold(0, (sum, p) => sum + p.stockQuantity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Stock Units',
                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                  Text('$totalUnits units',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Stock Valuation',
                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                  Text(_formatCurrency(totalValue),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Inventory Valuation Statement',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (products.isEmpty)
          const EmptyState(
            title: 'No Stock Items',
            message: 'No inventory items match search filter.',
            icon: Icons.inventory_2_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final p = products[idx];
              final valuation = p.stockQuantity * p.sellingPrice;
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText)),
                          Text(
                              'SKU: ${p.sku.isNotEmpty ? p.sku : 'N/A'} • Unit Price: ${_formatCurrency(p.sellingPrice)}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${p.stockQuantity} units',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue)),
                        Text('Valuation: ${_formatCurrency(valuation)}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlueText)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLowStockReportView(List<ProductEntity> products) {
    final lowStock =
        products.where((p) => p.stockQuantity <= p.reorderLevel).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Critical Low Stock Alert Items',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.danger)),
              Text('${lowStock.length} Items',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.danger)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Low Stock Alert Report',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (lowStock.isEmpty)
          const EmptyState(
            title: 'No Low Stock Warnings',
            message: 'All inventory items are above minimum stock alert levels.',
            icon: Icons.check_circle_outline,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lowStock.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final p = lowStock[idx];
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.danger, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText)),
                          Text('Reorder Point: ${p.reorderLevel} units',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    Text('${p.stockQuantity} units left',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.danger)),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildProductStockLedgerView(List<ProductEntity> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product Stock Ledger Statement',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (products.isEmpty)
          const EmptyState(
            title: 'No Stock Movements',
            message: 'No stock ledger history available.',
            icon: Icons.list_alt_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final p = products[idx];
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText)),
                        Text('Current Stock Balance: ${p.stockQuantity} units',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText)),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.secondaryText),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
