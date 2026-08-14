import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
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

class _CreateInvoicePageState extends State<CreateInvoicePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCashSale = true;
  final String _invoiceId = 'XNOB-1001';
  final DateTime _createdDateTime = DateTime.now();

  final _customerNameCtrl = TextEditingController(text: 'Apex Technologies Pvt Ltd');
  final _customerPhoneCtrl = TextEditingController(text: '+91 98470 11223');
  final _notesCtrl = TextEditingController(text: 'Thank you for your business!');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != (_isCashSale ? 0 : 1)) {
        setState(() {
          _isCashSale = _tabController.index == 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

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
      invoiceNumber: _invoiceId,
      customerId: _isCashSale ? 'cust_cash' : 'cust_101',
      customerName: _isCashSale ? 'Cash Customer' : _customerNameCtrl.text,
      customerPhone: _isCashSale ? 'N/A' : _customerPhoneCtrl.text,
      items: _items,
      subtotal: subtotal,
      taxTotal: taxTotal,
      grandTotal: grandTotal,
      paidAmount: 0.0,
      status: _isCashSale ? InvoiceStatus.paid : InvoiceStatus.unpaid,
      issueDate: _createdDateTime,
      dueDate: _createdDateTime.add(const Duration(days: 10)),
      notes: _notesCtrl.text,
    );

    context.read<InvoiceBloc>().add(CreateInvoiceSubmittedEvent(invoice));
  }

  @override
  Widget build(BuildContext context) {
    final formattedDateTime = DateFormat('dd MMM, h:mm a').format(_createdDateTime);

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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  children: [
                    // Back Button Card
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          border: Border.all(color: AppColors.surfaceContainerHigh),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: AppColors.onSurface,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title
                    const Text(
                      AppStrings.newInvoice,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    // Top Right: Invoice ID & Timestamp
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _invoiceId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDateTime,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // TabBar (Cash Sale vs Customer)
                Container(
                  height: 52,
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: AppColors.blueTint,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.onSurface,
                    unselectedLabelColor: AppColors.outline,
                    labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 20,
                              color: _isCashSale ? AppColors.success : AppColors.outline,
                            ),
                            const SizedBox(width: 8),
                            const Text(AppStrings.cashSale),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 20,
                              color: !_isCashSale ? AppColors.primary : AppColors.outline,
                            ),
                            const SizedBox(width: 8),
                            const Text(AppStrings.customer),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Animated Switcher between Cash Sale Info and Customer Details
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _isCashSale
                      ? KeyedSubtree(
                          key: const ValueKey('cash_sale_card'),
                          child: AppCard(
                            backgroundColor: AppColors.successTint.withValues(alpha: 0.5),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.successTint,
                                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                  ),
                                  child: const Icon(Icons.point_of_sale, color: AppColors.success, size: 22),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cash Sale Mode',
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Direct counter sale without individual customer details',
                                        style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : KeyedSubtree(
                          key: const ValueKey('customer_details_card'),
                          child: AppCard(
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
