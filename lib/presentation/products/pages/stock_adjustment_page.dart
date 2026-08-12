import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../const/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../../application/bloc/product_bloc.dart';

class StockAdjustmentPage extends StatefulWidget {
  const StockAdjustmentPage({super.key});

  @override
  State<StockAdjustmentPage> createState() => _StockAdjustmentPageState();
}

class _StockAdjustmentPageState extends State<StockAdjustmentPage> {
  final _qtyController = TextEditingController(text: '10');
  final _reasonController = TextEditingController(text: 'Stock Audit Addition');
  bool _isAddition = true;

  void _onSaveAdjustment() {
    final qty = int.tryParse(_qtyController.text) ?? 1;
    final change = _isAddition ? qty : -qty;

    context.read<ProductBloc>().add(
          AdjustStockEvent(
            productId: 'prod_102',
            change: change,
            reason: _reasonController.text,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock quantity adjusted successfully!'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Stock Adjustment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Item: Thermal Receipt Paper Roll (80mm)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Add Stock (+)')),
                    selected: _isAddition,
                    selectedColor: AppColors.secondaryContainer,
                    onSelected: (val) => setState(() => _isAddition = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Reduce Stock (-)')),
                    selected: !_isAddition,
                    selectedColor: AppColors.errorContainer,
                    onSelected: (val) => setState(() => _isAddition = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Quantity Change',
              controller: _qtyController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Reason / Note',
              controller: _reasonController,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Save Stock Adjustment',
              onPressed: _onSaveAdjustment,
            ),
          ],
        ),
      ),
    );
  }
}
