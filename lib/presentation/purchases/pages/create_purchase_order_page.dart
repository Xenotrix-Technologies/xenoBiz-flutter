import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../application/bloc/purchase_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CreatePurchaseOrderPage extends StatefulWidget {
  const CreatePurchaseOrderPage({super.key});

  @override
  State<CreatePurchaseOrderPage> createState() => _CreatePurchaseOrderPageState();
}

class _CreatePurchaseOrderPageState extends State<CreatePurchaseOrderPage> {
  late TextEditingController _supplierCtrl;
  late TextEditingController _poNumberCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _notesCtrl;
  ProductEntity? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _supplierCtrl = TextEditingController();
    _poNumberCtrl = TextEditingController(text: 'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    _amountCtrl = TextEditingController();
    _qtyCtrl = TextEditingController(text: '10');
    _notesCtrl = TextEditingController();
    context.read<ProductBloc>().add(const FetchProductsEvent());
  }

  @override
  void dispose() {
    _supplierCtrl.dispose();
    _poNumberCtrl.dispose();
    _amountCtrl.dispose();
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submitPO() {
    final supplierName = _supplierCtrl.text.trim();
    final poNumber = _poNumberCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final purchasedQty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;

    if (supplierName.isNotEmpty && poNumber.isNotEmpty && amount > 0) {
      final purchase = PurchaseEntity(
        id: '',
        poNumber: poNumber,
        supplierId: 'sup_${supplierName.toLowerCase().replaceAll(' ', '_')}',
        supplierName: supplierName,
        totalAmount: amount,
        status: 'RECEIVED',
        orderDate: DateTime.now(),
        notes: _notesCtrl.text.trim(),
      );

      context.read<PurchaseBloc>().add(CreatePurchaseOrderSubmittedEvent(purchase));

      // Increase stock in Hive if product selected
      if (_selectedProduct != null && purchasedQty > 0) {
        context.read<ProductBloc>().add(
              AdjustStockEvent(
                productId: _selectedProduct!.id,
                change: purchasedQty,
                reason: 'Purchase #$poNumber ($supplierName)',
              ),
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase order saved! Stock updated for ${_selectedProduct?.name ?? 'supplier'}.'),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Supplier Name, PO Number, and Total Amount.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Purchase Order'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Supplier / Vendor Name',
              hint: 'e.g. ABC Wholesalers',
              controller: _supplierCtrl,
              prefixIcon: Icons.business_outlined,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'PO Number',
              hint: 'e.g. PO-2026-088',
              controller: _poNumberCtrl,
              prefixIcon: Icons.receipt_outlined,
            ),
            const SizedBox(height: 14),

            // Select Product for Stock Increase
            const Text(
              'Select Product to Restock (Optional)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 6),
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, pState) {
                if (pState is ProductsLoadedState && pState.allProducts.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductEntity>(
                        isExpanded: true,
                        hint: const Text('Choose product to increase stock...'),
                        value: _selectedProduct,
                        items: pState.allProducts.map((p) {
                          return DropdownMenuItem<ProductEntity>(
                            value: p,
                            child: Text('${p.name} (Current Stock: ${p.stockQuantity} ${p.unit})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedProduct = val;
                            if (val != null && val.purchasePrice > 0) {
                              final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 10;
                              _amountCtrl.text = (val.purchasePrice * qty).toStringAsFixed(0);
                            }
                          });
                        },
                      ),
                    ),
                  );
                }
                return const Text('No products in inventory yet.', style: TextStyle(fontSize: 12, color: AppColors.secondaryText));
              },
            ),
            if (_selectedProduct != null) ...[
              const SizedBox(height: 14),
              AppTextField(
                label: 'Purchased Quantity (${_selectedProduct!.unit})',
                hint: 'e.g. 50',
                controller: _qtyCtrl,
                prefixIcon: Icons.add_box_outlined,
                keyboardType: TextInputType.number,
                onChanged: (qStr) {
                  final q = int.tryParse(qStr) ?? 0;
                  if (_selectedProduct != null && _selectedProduct!.purchasePrice > 0) {
                    _amountCtrl.text = (_selectedProduct!.purchasePrice * q).toStringAsFixed(0);
                  }
                },
              ),
            ],

            const SizedBox(height: 14),
            AppTextField(
              label: 'Total Purchase Amount (₹)',
              hint: 'e.g. 25000',
              controller: _amountCtrl,
              prefixIcon: Icons.currency_rupee_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Notes / Remarks (Optional)',
              hint: 'e.g. Delivered to main warehouse',
              controller: _notesCtrl,
              prefixIcon: Icons.note_outlined,
            ),
            const SizedBox(height: 28),
            AppButton(
              text: 'Save Purchase Order',
              onPressed: _submitPO,
            ),
          ],
        ),
      ),
    );
  }
}
