import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/app_card.dart';

class StockAdjustmentPage extends StatefulWidget {
  final ProductEntity? product;
  final bool initialAddition;

  const StockAdjustmentPage({
    super.key,
    this.product,
    this.initialAddition = true,
  });

  @override
  State<StockAdjustmentPage> createState() => _StockAdjustmentPageState();
}

class _StockAdjustmentPageState extends State<StockAdjustmentPage> {
  late bool _isAddition;
  ProductEntity? _selectedProduct;
  final _qtyController = TextEditingController(text: '10');
  final _reasonController = TextEditingController();
  String _selectedReasonPreset = 'Stock received';

  final List<String> _addReasons = [
    'Stock received',
    'Stock correction',
    'Customer return',
    'Manual adjustment',
  ];

  final List<String> _removeReasons = [
    'Damaged item',
    'Expired item',
    'Lost item',
    'Internal use',
    'Stock correction',
    'Manual adjustment',
  ];

  @override
  void initState() {
    super.initState();
    _isAddition = widget.initialAddition;
    _selectedProduct = widget.product;
    _selectedReasonPreset = _isAddition ? 'Stock received' : 'Damaged item';
    _reasonController.text = _selectedReasonPreset;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onSaveAdjustment() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product first'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity greater than 0'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final change = _isAddition ? qty : -qty;
    final reasonText = _reasonController.text.trim().isNotEmpty ? _reasonController.text.trim() : _selectedReasonPreset;

    context.read<ProductBloc>().add(
          AdjustStockEvent(
            productId: _selectedProduct!.id,
            change: change,
            reason: reasonText,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Adjusted stock for ${_selectedProduct!.name} successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final reasons = _isAddition ? _addReasons : _removeReasons;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Adjust Stock'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          List<ProductEntity> availableProducts = [];
          if (state is ProductsLoadedState) {
            availableProducts = state.allProducts.where((p) => p.isActive).toList();
            if (_selectedProduct == null && availableProducts.isNotEmpty) {
              _selectedProduct = availableProducts.first;
            } else if (_selectedProduct != null) {
              // Refresh selected product reference from state if present
              final match = availableProducts.where((p) => p.id == _selectedProduct!.id);
              if (match.isNotEmpty) {
                _selectedProduct = match.first;
              }
            }
          }

          final currentStock = _selectedProduct?.stockQuantity ?? 0;
          final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
          final newStock = (_isAddition ? currentStock + qty : currentStock - qty).clamp(0, 999999);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Selection Header Card
                const Text('Select Product', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                const SizedBox(height: 8),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: widget.product != null
                      ? Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryBlue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedProduct?.name ?? 'Product',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SKU: ${_selectedProduct?.sku ?? "-"} • ${_selectedProduct?.unit ?? "Pcs"}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedProduct?.id,
                            isExpanded: true,
                            hint: const Text('Choose a product...'),
                            items: availableProducts.map((p) {
                              return DropdownMenuItem<String>(
                                value: p.id,
                                child: Text('${p.name} (Stock: ${p.stockQuantity} ${p.unit})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedProduct = availableProducts.firstWhere((p) => p.id == val);
                                });
                              }
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // Adjustment Type Selector
                const Text('Adjustment Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAddition = true;
                            _selectedReasonPreset = 'Stock received';
                            _reasonController.text = _selectedReasonPreset;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isAddition ? AppColors.successContainer : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isAddition ? AppColors.success : AppColors.border,
                              width: _isAddition ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, color: _isAddition ? AppColors.success : AppColors.secondaryText),
                              const SizedBox(width: 8),
                              Text(
                                'Add Stock (+)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _isAddition ? AppColors.success : AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAddition = false;
                            _selectedReasonPreset = 'Damaged item';
                            _reasonController.text = _selectedReasonPreset;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isAddition ? AppColors.errorContainer : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !_isAddition ? AppColors.danger : AppColors.border,
                              width: !_isAddition ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove_circle_outline, color: !_isAddition ? AppColors.danger : AppColors.secondaryText),
                              const SizedBox(width: 8),
                              Text(
                                'Remove Stock (-)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: !_isAddition ? AppColors.danger : AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Live Stock Calculation Preview Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Current Stock', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                          const SizedBox(height: 4),
                          Text('$currentStock ${_selectedProduct?.unit ?? ""}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                        ],
                      ),
                      Icon(_isAddition ? Icons.arrow_forward : Icons.arrow_forward, color: _isAddition ? AppColors.success : AppColors.danger),
                      Column(
                        children: [
                          const Text('New Stock', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                          const SizedBox(height: 4),
                          Text('$newStock ${_selectedProduct?.unit ?? ""}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _isAddition ? AppColors.success : AppColors.danger,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quantity Input Field
                const Text('Quantity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                const SizedBox(height: 8),
                TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Enter quantity',
                    prefixIcon: const Icon(Icons.numbers, color: AppColors.secondaryText),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
                const SizedBox(height: 20),

                // Preset Reasons Chips
                const Text('Reason Preset', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reasons.map((preset) {
                    final isSelected = _selectedReasonPreset == preset;
                    return ChoiceChip(
                      label: Text(preset),
                      selected: isSelected,
                      selectedColor: _isAddition ? AppColors.primaryBlue : AppColors.warning,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.darkBlueText,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedReasonPreset = preset;
                            _reasonController.text = preset;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Reason / Note Input
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason / Remarks *',
                    hintText: 'e.g. Stock audit addition, damaged package...',
                    prefixIcon: const Icon(Icons.note_alt_outlined, color: AppColors.secondaryText),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAddition ? AppColors.primaryBlue : AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _onSaveAdjustment,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Save Stock Adjustment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
