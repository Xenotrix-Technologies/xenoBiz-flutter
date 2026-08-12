import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../const/colors.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import '../../../application/bloc/invoice_bloc.dart';

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  final _customerNameCtrl = TextEditingController(text: 'Apex Technologies Pvt Ltd');
  final _customerPhoneCtrl = TextEditingController(text: '+91 98470 11223');
  final _notesCtrl = TextEditingController(text: 'Thank you for your business!');

  final List<InvoiceItemEntity> _items = [
    const InvoiceItemEntity(
      productId: 'prod_101',
      productName: 'Wireless Smart POS Machine v2',
      quantity: 2,
      unitPrice: 8500.0,
      taxPercentage: 18.0,
    ),
    const InvoiceItemEntity(
      productId: 'prod_103',
      productName: 'Bluetooth Barcode Scanner HD',
      quantity: 1,
      unitPrice: 3200.0,
      taxPercentage: 18.0,
    ),
  ];

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get taxTotal => _items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get grandTotal => subtotal + taxTotal;

  void _onCreateInvoice() {
    final invoice = InvoiceEntity(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: 'XB-2026-${(100 + DateTime.now().second)}',
      customerId: 'cust_101',
      customerName: _customerNameCtrl.text,
      customerPhone: _customerPhoneCtrl.text,
      items: _items,
      subtotal: subtotal,
      taxTotal: taxTotal,
      grandTotal: grandTotal,
      paidAmount: 0.0,
      status: InvoiceStatus.unpaid,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 10)),
      notes: _notesCtrl.text,
    );

    context.read<InvoiceBloc>().add(CreateInvoiceSubmittedEvent(invoice));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoiceBloc, InvoiceState>(
      listener: (context, state) {
        if (state is InvoiceOperationSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.createInvoice),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customer Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Customer Name', controller: _customerNameCtrl),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Mobile Number', controller: _customerPhoneCtrl, keyboardType: TextInputType.phone),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Invoice Items', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('${item.quantity} x ₹${item.unitPrice.toStringAsFixed(0)} (18% GST)',
                                  style: const TextStyle(color: AppColors.outline, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('₹${item.total.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  children: [
                    _SummaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    _SummaryRow('GST Total (18%)', '₹${taxTotal.toStringAsFixed(2)}'),
                    const Divider(height: 20),
                    _SummaryRow('Grand Total', '₹${grandTotal.toStringAsFixed(2)}', isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<InvoiceBloc, InvoiceState>(
                builder: (context, state) {
                  return AppButton(
                    text: 'Generate & Save Invoice',
                    onPressed: _onCreateInvoice,
                    isLoading: state is InvoiceLoadingState,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500)),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 18 : 14,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: isBold ? AppColors.primary : AppColors.onSurface)),
      ],
    );
  }
}
