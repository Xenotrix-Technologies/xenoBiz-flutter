import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/purchase_bloc.dart';
import '../../../const/colors.dart';
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
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _supplierCtrl = TextEditingController();
    _poNumberCtrl = TextEditingController(text: 'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    _amountCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _supplierCtrl.dispose();
    _poNumberCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submitPO() {
    final supplierName = _supplierCtrl.text.trim();
    final poNumber = _poNumberCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

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
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Supplier Name, PO Number, and Amount.'),
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            AppTextField(
              label: 'Supplier Name',
              hint: 'e.g. TechHardware Distributors',
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
            AppTextField(
              label: 'Total Amount (₹)',
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
