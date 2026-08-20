import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/payment_entity.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class PaymentPage extends StatefulWidget {
  final InvoiceEntity invoice;
  final CustomerEntity? customer;

  const PaymentPage({
    super.key,
    required this.invoice,
    this.customer,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'GPay/UPI';
  late TextEditingController _amountCtrl;
  final NumberFormat _formatter = NumberFormat('#,##,##0.##', 'en_IN');
  InvoiceEntity? _finalInvoiceCreated;
  bool _isProcessingPurchase = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.invoice.grandTotal.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    return _formatter.format(amount);
  }

  Future<void> _onGenerateInvoice() async {
    final enteredAmount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0.0;
    final grandTotal = widget.invoice.grandTotal;

    // PURCHASE FLOW: Do NOT generate a purchase bill. Record as Expense & Increase Stock!
    if (widget.invoice.type == InvoiceType.purchase) {
      setState(() => _isProcessingPurchase = true);

      // 1. Increase product stock for all purchased items (+)
      for (var item in widget.invoice.items) {
        try {
          final productRepo = getIt<ProductRepository>();
          await productRepo.adjustStock(item.productId, item.quantity, 'Purchase #${widget.invoice.invoiceNumber}');
        } catch (_) {}
      }

      // 2. Create Expense Entity in ExpenseRepository (CASH OUT -> Purchase Expense)
      final expAmount = enteredAmount > 0 ? enteredAmount : grandTotal;
      final partyName = widget.customer?.name.isNotEmpty == true
          ? widget.customer!.name
          : (widget.invoice.customerName.isNotEmpty ? widget.invoice.customerName : 'Supplier');

      final purchaseExpense = ExpenseEntity(
        id: 'exp_pur_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Purchase: $partyName',
        category: 'Purchase Expense',
        amount: expAmount,
        paymentMode: _selectedPaymentMethod,
        expenseDate: DateTime.now(),
        notes: 'Purchase #${widget.invoice.invoiceNumber} from $partyName (${widget.invoice.items.length} items)',
      );

      await getIt<ExpenseRepository>().createExpense(purchaseExpense);

      if (mounted) {
        setState(() => _isProcessingPurchase = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase of ₹${expAmount.toStringAsFixed(0)} recorded in Expenses & Stock Updated!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(RouteNames.dashboard);
      }
      return;
    }

    // SALES INVOICE FLOW: Calculate paid amount allocated to this invoice
    final paidForInvoice =
        enteredAmount >= grandTotal ? grandTotal : enteredAmount;

    final InvoiceStatus status;
    if (paidForInvoice >= grandTotal) {
      status = InvoiceStatus.paid;
    } else if (paidForInvoice > 0) {
      status = InvoiceStatus.partiallyPaid;
    } else {
      status = InvoiceStatus.unpaid;
    }

    final finalInvoice = widget.invoice.copyWith(
      paidAmount: paidForInvoice,
      status: status,
    );

    _finalInvoiceCreated = finalInvoice;

    // 1. Submit Invoice
    context.read<InvoiceBloc>().add(CreateInvoiceSubmittedEvent(finalInvoice));

    // 2. Record Payment if amount paid > 0
    if (enteredAmount > 0) {
      final payment = PaymentEntity(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        invoiceId: finalInvoice.id,
        customerId: widget.customer?.id ?? '',
        customerName: widget.customer?.name ?? 'Cash Customer',
        amount: enteredAmount,
        paymentMode: _selectedPaymentMethod,
        paymentDate: DateTime.now(),
        notes: 'Payment for Invoice #${finalInvoice.invoiceNumber}',
      );
      context.read<InvoiceBloc>().add(RecordPaymentSubmittedEvent(payment));
    }
  }

  Widget _buildPaymentMethodCard(String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == title;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = title;
        });
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueTint : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceContainerHigh,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCashSale = widget.customer == null;
    final enteredAmount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0.0;

    // Calculations
    final previousBalance = widget.customer?.outstandingBalance ?? 0.0;
    final currentInvoiceAmount = widget.invoice.grandTotal;
    final totalDue = previousBalance + currentInvoiceAmount;

    // Change & Balance calculations
    final double change;
    final double newBalance;

    if (isCashSale) {
      change = (enteredAmount - currentInvoiceAmount).clamp(0.0, double.infinity);
      newBalance = 0.0;
    } else {
      if (enteredAmount > totalDue) {
        change = enteredAmount - totalDue;
        newBalance = 0.0;
      } else {
        change = 0.0;
        newBalance = totalDue - enteredAmount;
      }
    }

    final isPurchase = widget.invoice.type == InvoiceType.purchase;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Back Button Card
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMedium),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMedium),
                        border:
                            Border.all(color: AppColors.surfaceContainerHigh),
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
                  Text(
                    isPurchase ? 'Supplier Payment' : 'Payment',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.home_outlined, color: AppColors.primary),
                    tooltip: 'Go Home',
                    onPressed: () => context.go(RouteNames.dashboard),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCashSale ? (isPurchase ? 'Cash Supplier' : 'Cash Customer') : widget.customer!.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Conditional Top Card (Cash Sale vs Customer)
              if (isCashSale) ...[
                // Prominent Total Amount Card for Cash Sale/Purchase
                AppCard(
                  backgroundColor: AppColors.deepNavy,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          isPurchase ? 'PURCHASE AMOUNT' : 'TOTAL AMOUNT',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${_formatAmount(currentInvoiceAmount)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Balance Summary Card for Customer/Supplier Invoice
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _SummaryRow(
                        isPurchase ? 'Previous payable' : 'Previous balance',
                        '₹${_formatAmount(previousBalance)}',
                        valueColor: AppColors.warning,
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        isPurchase ? 'Current purchase' : 'Current invoice',
                        '₹${_formatAmount(currentInvoiceAmount)}',
                      ),
                      const Divider(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.blueTint,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isPurchase ? 'Total payable' : 'Total due',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                            Text(
                              '₹${_formatAmount(totalDue)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Payment Method Selector
              const Text(
                'PAYMENT METHOD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.outline,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentMethodCard(
                      'GPay/UPI',
                      Icons.qr_code_scanner,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentMethodCard(
                      'Cash',
                      Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentMethodCard(
                      'Card',
                      Icons.credit_card,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentMethodCard(
                      'Other',
                      Icons.more_horiz,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Amount Field Label
              Text(
                isPurchase ? 'Amount paid to supplier' : (isCashSale ? 'Amount received' : 'Enter amount paid'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Amount Received/Paid Input Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic Balance / Change-to-Return Card
              if (isCashSale) ...[
                if (enteredAmount >= currentInvoiceAmount) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.successTint,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isPurchase ? 'Balance change' : 'Change to return',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '₹${_formatAmount(change)}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.warningTint,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isPurchase ? 'Unpaid balance' : 'Amount due',
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '₹${_formatAmount(currentInvoiceAmount - enteredAmount)}',
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                if (enteredAmount > totalDue) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.successTint,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Change to return',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '₹${_formatAmount(change)}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'UPDATED BALANCE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.outline,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _SummaryRow(
                              'Paid now',
                              '₹${_formatAmount(enteredAmount)}',
                              valueColor: AppColors.success,
                              isBold: true,
                            ),
                            const SizedBox(height: 10),
                            _SummaryRow(
                              'New balance',
                              '₹${_formatAmount(newBalance)}',
                              valueColor: newBalance > 0
                                  ? AppColors.warning
                                  : AppColors.success,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: 14 + MediaQuery.of(context).padding.bottom,
        ),
        child: BlocConsumer<InvoiceBloc, InvoiceState>(
          listener: (context, state) {
            if (state is InvoiceOperationSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              final enteredAmt = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0.0;
              context.go(
                RouteNames.invoiceResult,
                extra: {
                  'invoice': _finalInvoiceCreated ?? widget.invoice,
                  'customer': widget.customer,
                  'paymentMethod': _selectedPaymentMethod,
                  'amountPaid': enteredAmt,
                  'previousBalance': widget.customer?.outstandingBalance ?? 0.0,
                },
              );
            } else if (state is InvoiceErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return AppButton(
              text: isPurchase ? 'Record Purchase Expense' : 'Generate Invoice',
              onPressed: _onGenerateInvoice,
              isLoading: (state is InvoiceLoadingState) || _isProcessingPurchase,
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow(
    this.label,
    this.value, {
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
