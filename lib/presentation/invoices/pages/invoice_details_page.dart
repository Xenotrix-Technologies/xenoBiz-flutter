import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/payment_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import 'return_voucher_screen.dart';

class InvoiceDetailsPage extends StatefulWidget {
  final InvoiceEntity? invoice;

  const InvoiceDetailsPage({
    super.key,
    this.invoice,
  });

  @override
  State<InvoiceDetailsPage> createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage> {
  late InvoiceEntity _currentInvoice;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice ??
        InvoiceEntity(
          id: 'inv_demo',
          invoiceNumber: 'INV-1042',
          customerId: 'cust_101',
          customerName: 'Rahul Traders',
          customerPhone: '+91 98765 43210',
          items: const [
            InvoiceItemEntity(
              productId: 'prod_1',
              productName: 'Wireless POS Terminal',
              quantity: 2,
              unitPrice: 1200.0,
              taxPercentage: 18.0,
            ),
          ],
          subtotal: 2400.0,
          taxTotal: 432.0,
          grandTotal: 2832.0,
          paidAmount: 2832.0,
          status: InvoiceStatus.paid,
          issueDate: DateTime.now().subtract(const Duration(hours: 4)),
          dueDate: DateTime.now(),
        );

    // Initial fetch to get latest invoice data from DB
    context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
  }

  @override
  void didUpdateWidget(covariant InvoiceDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.invoice != null && widget.invoice != oldWidget.invoice) {
      setState(() {
        _currentInvoice = widget.invoice!;
      });
    }
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy, h:mm a').format(date);
  }

  Future<void> _shareInvoice(BuildContext context, InvoiceEntity inv) async {
    final text =
        'Invoice ${inv.invoiceNumber} for ${inv.customerName}\nTotal: ${_formatCurrency(inv.grandTotal)}\nPaid: ${_formatCurrency(inv.paidAmount)}\nBalance Due: ${_formatCurrency(inv.dueAmount)}\nGenerated via XenoBiz Manager.';
    await Share.share(text, subject: 'Invoice ${inv.invoiceNumber}');
  }

  void _showRecordPaymentDialog(BuildContext context, InvoiceEntity inv) {
    final due = inv.dueAmount > 0 ? inv.dueAmount : inv.grandTotal;
    final amountCtrl = TextEditingController(text: due.toStringAsFixed(0));
    String selectedMode = 'UPI';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Record Payment - ${inv.invoiceNumber}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${inv.customerName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Outstanding Due: ${_formatCurrency(inv.dueAmount)}',
                    style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                const SizedBox(height: 14),
                TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Payment Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Payment Mode',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children:
                      ['UPI', 'Cash', 'Card', 'Bank Transfer'].map((mode) {
                    final isSel = selectedMode == mode;
                    return ChoiceChip(
                      label: Text(mode),
                      selected: isSel,
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                          color:
                              isSel ? Colors.white : AppColors.darkBlueText,
                          fontWeight: FontWeight.w600),
                      onSelected: (val) {
                        if (val) setModalState(() => selectedMode = mode);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                  if (amount <= 0) return;
                  final payment = PaymentEntity(
                    id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                    invoiceId: inv.id,
                    customerId: inv.customerId,
                    customerName: inv.customerName,
                    amount: amount,
                    paymentMode: selectedMode,
                    paymentDate: DateTime.now(),
                  );
                  context
                      .read<InvoiceBloc>()
                      .add(RecordPaymentSubmittedEvent(payment));
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Recorded payment of ${_formatCurrency(amount)} for ${inv.invoiceNumber}')),
                  );
                },
                child: const Text('Confirm Payment',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmCancelInvoice(BuildContext context, InvoiceEntity inv) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Invoice?'),
        content: Text(
            'Are you sure you want to cancel invoice ${inv.invoiceNumber}? This transaction will be marked as Cancelled.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('No, Keep')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white),
            onPressed: () {
              final cancelledInv =
                  inv.copyWith(status: InvoiceStatus.cancelled);
              context
                  .read<InvoiceBloc>()
                  .add(UpdateInvoiceSubmittedEvent(cancelledInv));
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Invoice ${inv.invoiceNumber} has been cancelled.')),
              );
            },
            child: const Text('Yes, Cancel Invoice'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoiceBloc, InvoiceState>(
      listener: (context, state) {
        if (state is InvoicesLoadedState) {
          final updated = state.invoices.firstWhere(
            (i) => i.id == _currentInvoice.id,
            orElse: () => _currentInvoice,
          );
          if (mounted && updated != _currentInvoice) {
            setState(() {
              _currentInvoice = updated;
            });
          }
        } else if (state is InvoiceOperationSuccessState) {
          context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
        }
      },
      child: _buildDetailsScaffold(context, _currentInvoice),
    );
  }

  Widget _buildDetailsScaffold(BuildContext context, InvoiceEntity inv) {
    final now = DateTime.now();
    final isOverdue =
        (inv.status == InvoiceStatus.unpaid ||
                inv.status == InvoiceStatus.partiallyPaid) &&
            inv.dueDate.isBefore(now);
    final isReturned = inv.notes.toLowerCase().contains('return') ||
        inv.invoiceNumber.toLowerCase().contains('ret');

    Widget statusWidget;
    if (inv.status == InvoiceStatus.cancelled) {
      statusWidget = StatusChip.cancelled();
    } else if (isReturned) {
      statusWidget = StatusChip.returned();
    } else if (inv.status == InvoiceStatus.paid) {
      statusWidget = StatusChip.paid();
    } else if (isOverdue) {
      statusWidget = StatusChip.overdue();
    } else if (inv.status == InvoiceStatus.partiallyPaid) {
      statusWidget = StatusChip.partiallyPaid();
    } else {
      statusWidget = StatusChip.unpaid();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          inv.invoiceNumber,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => _shareInvoice(context, inv),
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print / Result',
            onPressed: () {
              context.push(
                RouteNames.invoiceResult,
                extra: {
                  'invoice': inv,
                  'paymentMethod': 'Cash',
                  'amountPaid': inv.paidAmount,
                },
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) async {
              if (val == 'edit') {
                await context.push(
                  RouteNames.createInvoice,
                  extra: {
                    'invoiceType': inv.type,
                    'invoiceToEdit': inv,
                  },
                );
                if (context.mounted) {
                  context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
                }
              } else if (val == 'convert') {
                await context.push(
                  RouteNames.createInvoice,
                  extra: {
                    'invoiceType': InvoiceType.sale,
                    'fromQuotation': inv,
                  },
                );
                if (context.mounted) {
                  context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
                }
              } else if (val == 'return') {
                await context.push(
                  RouteNames.createReturn,
                  extra: {'returnType': ReturnType.salesReturn},
                );
                if (context.mounted) {
                  context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
                }
              } else if (val == 'cancel') {
                _confirmCancelInvoice(context, inv);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Document')
                  ],
                ),
              ),
              if (inv.type == InvoiceType.quotation)
                const PopupMenuItem(
                  value: 'convert',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.primaryBlue),
                      SizedBox(width: 8),
                      Text('Convert to Sale', style: TextStyle(color: AppColors.primaryBlue)),
                    ],
                  ),
                ),
              if (inv.type != InvoiceType.quotation)
                const PopupMenuItem(
                  value: 'return',
                  child: Row(
                    children: [
                      Icon(Icons.assignment_return_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Create Sales Return')
                    ],
                  ),
                ),
              if (inv.status != InvoiceStatus.cancelled)
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined,
                          size: 18, color: AppColors.danger),
                      SizedBox(width: 8),
                      Text('Cancel Document',
                          style: TextStyle(color: AppColors.danger))
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Invoice Overview Header Card
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv.type == InvoiceType.quotation
                                ? 'QUOTATION'
                                : (inv.type == InvoiceType.purchase
                                    ? 'PURCHASE VOUCHER'
                                    : 'SALES INVOICE'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            inv.invoiceNumber,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                        ],
                      ),
                      statusWidget,
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              inv.type == InvoiceType.quotation
                                  ? 'Quotation Date'
                                  : 'Issue Date',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText)),
                          const SizedBox(height: 2),
                          Text(_formatDate(inv.issueDate),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              inv.type == InvoiceType.quotation
                                  ? 'Valid Until'
                                  : 'Due Date',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText)),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('d MMM yyyy').format(inv.dueDate),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isOverdue
                                  ? AppColors.danger
                                  : AppColors.darkBlueText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Info Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person_outline,
                        color: AppColors.primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inv.customerName.isNotEmpty
                              ? inv.customerName
                              : 'General Customer',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText),
                        ),
                        if (inv.customerPhone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(inv.customerPhone,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryText)),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppColors.secondaryText),
                    onPressed: () {
                      final customer = CustomerEntity(
                        id: inv.customerId.isNotEmpty
                            ? inv.customerId
                            : 'cust_gen',
                        name: inv.customerName,
                        phone: inv.customerPhone,
                        email: '',
                        address: '',
                        outstandingBalance: inv.dueAmount,
                        createdAt: inv.issueDate,
                      );
                      context.push(RouteNames.customerDetails, extra: customer);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Itemized Invoice Items List
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invoice Items',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText),
                  ),
                  const SizedBox(height: 14),
                  if (inv.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                          'No itemized details recorded for this invoice.',
                          style: TextStyle(
                              color: AppColors.secondaryText, fontSize: 13)),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: inv.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 18),
                      itemBuilder: (ctx, index) {
                        final item = inv.items[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkBlueText),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.quantity} x ${_formatCurrency(item.unitPrice)}${item.taxPercentage > 0 ? ' (+${item.taxPercentage.toStringAsFixed(0)}% Tax)' : ''}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatCurrency(item.total),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText),
                            ),
                          ],
                        );
                      },
                    ),
                  const Divider(height: 24),

                  // Financial Breakdown
                  _buildSummaryLine('Subtotal', _formatCurrency(inv.subtotal)),
                  if (inv.taxTotal > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryLine(
                        'Tax / GST', _formatCurrency(inv.taxTotal)),
                  ],
                  if (inv.discountTotal > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryLine('Discount',
                        '-${_formatCurrency(inv.discountTotal)}',
                        isDiscount: true),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText)),
                      Text(
                        _formatCurrency(inv.grandTotal),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Paid Amount',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.secondaryText)),
                      Text(_formatCurrency(inv.paidAmount),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success)),
                    ],
                  ),
                  if (inv.dueAmount > 0 &&
                      inv.status != InvoiceStatus.paid &&
                      inv.status != InvoiceStatus.cancelled) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Outstanding Due',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger)),
                        Text(_formatCurrency(inv.dueAmount),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.danger)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (inv.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notes / Terms',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBlueText)),
                    const SizedBox(height: 4),
                    Text(inv.notes,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.secondaryText)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Bottom Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Share WhatsApp',
                    icon: Icons.chat_bubble_outline,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => _shareInvoice(context, inv),
                  ),
                ),
                if (inv.type == InvoiceType.quotation) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Convert to Sale',
                      icon: Icons.swap_horiz_rounded,
                      onPressed: () {
                        context.push(
                          RouteNames.createInvoice,
                          extra: {
                            'invoiceType': InvoiceType.sale,
                            'fromQuotation': inv,
                          },
                        );
                      },
                    ),
                  ),
                ] else if (inv.dueAmount > 0 &&
                    inv.status != InvoiceStatus.paid &&
                    inv.status != InvoiceStatus.cancelled) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Record Payment',
                      icon: Icons.payments_outlined,
                      onPressed: () => _showRecordPaymentDialog(context, inv),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String title, String value,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 13, color: AppColors.secondaryText)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount ? AppColors.success : AppColors.darkBlueText,
          ),
        ),
      ],
    );
  }
}
