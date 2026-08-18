import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/accounts_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/business_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/invoice_repository.dart';
import '../../../infrastructure/pdf/pdf_statement_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class CustomerDetailsPage extends StatefulWidget {
  final CustomerEntity? customer;

  const CustomerDetailsPage({super.key, this.customer});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  late CustomerEntity _customer;
  List<InvoiceEntity> _customerInvoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer ??
        CustomerEntity(
          id: 'CUST-001',
          name: 'Apex Technologies Pvt Ltd',
          phone: '+91 98470 11223',
          email: 'finance@apextech.in',
          address: 'Kochi, Kerala',
          outstandingBalance: 2550,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );

    _loadCustomerInvoices();
  }

  Future<void> _loadCustomerInvoices() async {
    try {
      final invRepo = getIt<InvoiceRepository>();
      final allInvoices = await invRepo.getInvoices();
      final filtered = allInvoices.where((i) => i.customerId == _customer.id || i.customerName == _customer.name).toList();
      filtered.sort((a, b) => b.issueDate.compareTo(a.issueDate));

      setState(() {
        _customerInvoices = filtered;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showEditCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: _customer.name);
    final phoneCtrl = TextEditingController(text: _customer.phone);
    final emailCtrl = TextEditingController(text: _customer.email);
    final addressCtrl = TextEditingController(text: _customer.address);
    final balanceCtrl = TextEditingController(text: _customer.outstandingBalance.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Customer Account', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Customer Name *', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: balanceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Outstanding Balance (₹)', prefixIcon: Icon(Icons.currency_rupee)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final balance = double.tryParse(balanceCtrl.text.trim()) ?? 0.0;
                  final updatedCust = _customer.copyWith(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                    outstandingBalance: balance,
                  );

                  context.read<AccountsBloc>().add(UpdateCustomerAccountEvent(updatedCust));
                  setState(() => _customer = updatedCust);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCustomer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer Account'),
        content: Text('Are you sure you want to delete "${_customer.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              context.read<AccountsBloc>().add(DeleteCustomerAccountEvent(_customer.id));
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReceivePaymentDialog(BuildContext context) {
    final amountCtrl = TextEditingController(text: _customer.outstandingBalance > 0 ? _customer.outstandingBalance.toInt().toString() : '');
    final noteCtrl = TextEditingController();
    String selectedMethod = 'Cash';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Receive Payment', style: TextStyle(fontWeight: FontWeight.w800)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Customer Outstanding: ${_formatCurrency(_customer.outstandingBalance)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.danger),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Payment Amount (₹) *',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedMethod,
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Cash', 'GPay/UPI', 'Card', 'Other']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        labelText: 'Note / Reference',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                    if (amt > 0) {
                      context.read<AccountsBloc>().add(
                            RecordCustomerPaymentEvent(
                              customerId: _customer.id,
                              amount: amt,
                              paymentMethod: selectedMethod,
                              note: noteCtrl.text.trim(),
                              date: DateTime.now(),
                            ),
                          );

                      setState(() {
                        final newDue = (_customer.outstandingBalance - amt).clamp(0.0, double.infinity);
                        _customer = _customer.copyWith(outstandingBalance: newDue);
                      });

                      _loadCustomerInvoices();
                      Navigator.pop(dialogCtx);
                    }
                  },
                  child: const Text('Record Payment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generatePdfStatement() async {
    try {
      final authRepo = getIt<AuthRepository>();
      final business = await authRepo.getBusinessProfile() ??
          BusinessEntity(
            id: 'biz',
            name: 'XenoBiz Store',
            phone: '',
            address: '',
            category: 'Retail Store',
            createdAt: DateTime.now(),
          );

      double runningBalance = 0.0;
      final List<PdfStatementLedgerRow> rows = [];

      for (var inv in _customerInvoices.reversed) {
        runningBalance += inv.grandTotal;
        rows.add(
          PdfStatementLedgerRow(
            date: DateFormat('MMM dd, yyyy').format(inv.issueDate),
            description: 'Sales Invoice',
            reference: '#${inv.invoiceNumber}',
            debit: inv.grandTotal,
            credit: 0.0,
            balance: runningBalance,
          ),
        );

        if (inv.paidAmount > 0) {
          runningBalance -= inv.paidAmount;
          rows.add(
            PdfStatementLedgerRow(
              date: DateFormat('MMM dd, yyyy').format(inv.issueDate),
              description: 'Payment Received',
              reference: 'PAY-${inv.invoiceNumber}',
              debit: 0.0,
              credit: inv.paidAmount,
              balance: runningBalance,
            ),
          );
        }
      }

      final totalPurchases = _customerInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
      final totalPaid = _customerInvoices.fold(0.0, (sum, i) => sum + i.paidAmount);

      await PdfStatementService.shareCustomerStatement(
        business: business,
        customer: _customer,
        totalPurchases: totalPurchases,
        totalPaid: totalPaid,
        outstandingBalance: _customer.outstandingBalance,
        ledgerRows: rows,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF statement: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final totalPurchases = _customerInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
    final totalPaid = _customerInvoices.fold(0.0, (sum, i) => sum + i.paidAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Account Details'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditCustomerDialog(context),
            tooltip: 'Edit Account',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _generatePdfStatement,
            tooltip: 'PDF Statement',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'delete') _confirmDeleteCustomer(context);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete Account', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Loading customer account...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Header Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                              child: Text(
                                _customer.name.isNotEmpty ? _customer.name.substring(0, 1).toUpperCase() : 'C',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _customer.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                                  ),
                                  const SizedBox(height: 2),
                                  Text('Customer ID: ${_customer.id}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        if (_customer.phone.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 16, color: AppColors.secondaryText),
                                const SizedBox(width: 8),
                                Text(_customer.phone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        if (_customer.email.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.email_outlined, size: 16, color: AppColors.secondaryText),
                                const SizedBox(width: 8),
                                Text(_customer.email, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        if (_customer.address.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.secondaryText),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_customer.address, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Financial Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Purchases', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(_formatCurrency(totalPurchases), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Paid', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(_formatCurrency(totalPaid), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Outstanding', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(_formatCurrency(_customer.outstandingBalance), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _customer.outstandingBalance > 0 ? AppColors.danger : AppColors.success)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Receive Payment Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _showReceivePaymentDialog(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('+ Receive Payment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sales / Invoice History Section
                  const Text(
                    'Sales & Invoice History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                  ),
                  const SizedBox(height: 10),

                  if (_customerInvoices.isEmpty)
                    const EmptyState(
                      title: 'No invoices for this customer',
                      message: 'Invoices created for this customer will appear here.',
                      icon: Icons.receipt_long_outlined,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _customerInvoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, idx) {
                        final inv = _customerInvoices[idx];
                        return AppCard(
                          onTap: () {
                            context.push(RouteNames.invoiceDetails, extra: inv);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('#${inv.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(DateFormat('MMM dd, yyyy').format(inv.issueDate), style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(_formatCurrency(inv.grandTotal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  if (inv.status == InvoiceStatus.paid)
                                    StatusChip.paid()
                                  else if (inv.status == InvoiceStatus.partiallyPaid)
                                    StatusChip.partiallyPaid()
                                  else
                                    StatusChip.unpaid(),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
