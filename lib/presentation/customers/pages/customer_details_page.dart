import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../application/bloc/accounts_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/business_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/billing_customer_repository.dart';
import '../../../domain/repositories/invoice_repository.dart';
import '../../../infrastructure/pdf/pdf_statement_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class CustomerNoteItem {
  final String id;
  final String content;
  final DateTime timestamp;

  CustomerNoteItem({
    required this.id,
    required this.content,
    required this.timestamp,
  });
}

class _RawTransaction {
  final DateTime date;
  final String type;
  final String ref;
  final double debit;
  final double credit;

  _RawTransaction({
    required this.date,
    required this.type,
    required this.ref,
    required this.debit,
    required this.credit,
  });
}

class _PassbookRow {
  final DateTime date;
  final String type;
  final String ref;
  final double debit;
  final double credit;
  final double runningBalance;

  _PassbookRow({
    required this.date,
    required this.type,
    required this.ref,
    required this.debit,
    required this.credit,
    required this.runningBalance,
  });
}

class CustomerDetailsPage extends StatefulWidget {
  final CustomerEntity? customer;

  const CustomerDetailsPage({super.key, this.customer});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> with SingleTickerProviderStateMixin {
  late CustomerEntity _customer;
  late TabController _tabController;

  List<InvoiceEntity> _customerInvoices = [];
  List<CustomerTimelineEvent> _customerTimeline = [];
  final List<CustomerNoteItem> _customerNotes = [
    CustomerNoteItem(
      id: '1',
      content: 'Requested 30-day credit terms on bulk purchases.',
      timestamp: DateTime.now().subtract(const Duration(days: 10)),
    ),
    CustomerNoteItem(
      id: '2',
      content: 'Prefers digital invoices over WhatsApp.',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

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

    _loadCustomerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _loadCustomerData() async {
    try {
      final invRepo = getIt<InvoiceRepository>();
      final allInvoices = await invRepo.getInvoices();
      final filteredInvoices = allInvoices.where((i) => i.customerId == _customer.id || i.customerName == _customer.name).toList();
      filteredInvoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));

      final timeline = await getIt<BillingCustomerRepository>().getCustomerTimeline(_customer.id);

      if (mounted) {
        setState(() {
          _customerInvoices = filteredInvoices;
          _customerTimeline = timeline;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddNoteDialog() {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Customer Note', style: TextStyle(fontWeight: FontWeight.w800)),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter note details (e.g. credit terms, delivery note)...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                final text = noteController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _customerNotes.insert(
                      0,
                      CustomerNoteItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        content: text,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Note'),
            ),
          ],
        );
      },
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

                      _loadCustomerData();
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
    return '₹${amount.toStringAsFixed(0)}';
  }

  List<_PassbookRow> _calculatePassbookRows() {
    final List<_RawTransaction> raw = [];

    for (var inv in _customerInvoices) {
      raw.add(_RawTransaction(
        date: inv.issueDate,
        type: 'Sale',
        ref: '#${inv.invoiceNumber}',
        debit: inv.grandTotal,
        credit: 0,
      ));

      if (inv.paidAmount > 0) {
        raw.add(_RawTransaction(
          date: inv.issueDate.add(const Duration(seconds: 1)),
          type: 'Payment',
          ref: 'Rec #${inv.invoiceNumber}',
          debit: 0,
          credit: inv.paidAmount,
        ));
      }
    }

    for (var t in _customerTimeline) {
      if (t.eventType == 'PAYMENT' && !_customerInvoices.any((i) => t.description.contains(i.invoiceNumber))) {
        raw.add(_RawTransaction(
          date: t.timestamp,
          type: 'Receipt',
          ref: t.title,
          debit: 0,
          credit: double.tryParse(RegExp(r'\d+').firstMatch(t.description)?.group(0) ?? '') ?? 0,
        ));
      }
    }

    // Sort by date ascending (creation date order)
    raw.sort((a, b) => a.date.compareTo(b.date));

    double running = 0;
    final List<_PassbookRow> result = [];
    for (var item in raw) {
      running += (item.debit - item.credit);
      result.add(_PassbookRow(
        date: item.date,
        type: item.type,
        ref: item.ref,
        debit: item.debit,
        credit: item.credit,
        runningBalance: running,
      ));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final totalPurchases = _customer.totalPurchases > 0 ? _customer.totalPurchases : _customerInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
    final totalPaid = _customerInvoices.fold(0.0, (sum, i) => sum + i.paidAmount);
    final invoiceCount = _customerInvoices.length;
    final avgInvoiceValue = invoiceCount > 0 ? (totalPurchases / invoiceCount) : 0.0;
    final lastPurchaseDate = _customerInvoices.isNotEmpty ? DateFormat('dd MMM yyyy').format(_customerInvoices.first.issueDate) : 'No purchases';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Profile'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _generatePdfStatement,
            tooltip: 'PDF Statement',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(RouteNames.createMaster, extra: _customer),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: _isLoading
          ? const CustomerDetailsSkeleton()
          : NestedScrollView(
              headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. CUSTOMER INFO CARD
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                                    child: Text(
                                      _customer.name.isNotEmpty ? _customer.name.substring(0, 1).toUpperCase() : 'C',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
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
                              const SizedBox(height: 14),

                              // Quick Communication Buttons
                              if (_customer.phone.isNotEmpty)
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryBlue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () => _makePhoneCall(_customer.phone),
                                        icon: const Icon(Icons.phone_rounded, size: 16),
                                        label: const Text('Call', style: TextStyle(fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF25D366),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () => _openWhatsApp(_customer.phone),
                                        icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                                        label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2. BUSINESS SUMMARY GRID
                        const Text(
                          'Business Summary',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _SummaryCard('Total Purchases', _formatCurrency(totalPurchases), AppColors.darkBlueText)),
                            const SizedBox(width: 8),
                            Expanded(child: _SummaryCard('Total Paid', _formatCurrency(totalPaid), AppColors.success)),
                            const SizedBox(width: 8),
                            Expanded(child: _SummaryCard('Outstanding', _formatCurrency(_customer.outstandingBalance), _customer.outstandingBalance > 0 ? AppColors.danger : AppColors.success)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _SummaryCard('Invoices Count', '$invoiceCount', AppColors.darkBlueText)),
                            const SizedBox(width: 8),
                            Expanded(child: _SummaryCard('Avg Invoice', _formatCurrency(avgInvoiceValue), AppColors.primaryBlue)),
                            const SizedBox(width: 8),
                            Expanded(child: _SummaryCard('Last Purchase', lastPurchaseDate, AppColors.secondaryText)),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Receive Payment Button
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _showReceivePaymentDialog(context),
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            label: const Text('+ Record Customer Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primaryBlue,
                      unselectedLabelColor: AppColors.secondaryText,
                      indicatorColor: AppColors.primaryBlue,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Invoices'),
                        Tab(text: 'Notes'),
                        Tab(text: 'Book'),
                        Tab(text: 'Timeline'),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: INVOICES
                  _buildInvoicesTab(),

                  // TAB 2: NOTES
                  _buildNotesTab(),

                  // TAB 3: BOOK (Passbook Table View)
                  _buildBookTab(),

                  // TAB 4: TIMELINE
                  _buildTimelineTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildInvoicesTab() {
    if (_customerInvoices.isEmpty) {
      return const EmptyState(
        title: 'No Invoices Recorded',
        message: 'Sales invoices generated for this customer will appear here.',
        icon: Icons.receipt_long_outlined,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _customerInvoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final inv = _customerInvoices[idx];
        return AppCard(
          onTap: () {
            context.push(
              RouteNames.createInvoice,
              extra: {'invoiceType': inv.type, 'invoiceToEdit': inv},
            );
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
                  if (inv.status == InvoiceStatus.paid) StatusChip.paid() else if (inv.status == InvoiceStatus.partiallyPaid) StatusChip.partiallyPaid() else StatusChip.unpaid(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Notes (${_customerNotes.length})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _showAddNoteDialog,
                icon: const Icon(Icons.note_add_outlined, size: 16),
                label: const Text('Add Note', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _customerNotes.isEmpty
              ? const EmptyState(
                  title: 'No Notes Added',
                  message: 'Add customer preferences, payment reminders, or key details here.',
                  icon: Icons.note_add_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _customerNotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final note = _customerNotes[idx];
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.sticky_note_2_outlined, size: 16, color: AppColors.primaryBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('dd MMM yyyy, hh:mm a').format(note.timestamp),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() => _customerNotes.removeAt(idx));
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            note.content,
                            style: const TextStyle(fontSize: 13, color: AppColors.darkBlueText, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookTab() {
    final List<_PassbookRow> rows = _calculatePassbookRows();

    if (rows.isEmpty) {
      return const EmptyState(
        title: 'No Ledger Entries',
        message: 'Passbook transaction ledger will appear here once sales or payments are recorded.',
        icon: Icons.menu_book_outlined,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              // Table Header
              Container(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: const Row(
                  children: [
                    Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkBlueText))),
                    Expanded(flex: 3, child: Text('Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkBlueText))),
                    Expanded(flex: 2, child: Text('Debit (+)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.danger), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text('Credit (-)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text('Balance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkBlueText), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Table Rows
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 12, endIndent: 12),
                itemBuilder: (ctx, idx) {
                  final row = rows[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            DateFormat('dd MMM').format(row.date),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkBlueText),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                row.type,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                              ),
                              if (row.ref.isNotEmpty)
                                Text(
                                  row.ref,
                                  style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            row.debit > 0 ? '₹${row.debit.toStringAsFixed(0)}' : '-',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            row.credit > 0 ? '₹${row.credit.toStringAsFixed(0)}' : '-',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹${row.runningBalance.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: row.runningBalance > 0 ? AppColors.danger : AppColors.success,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
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

  Widget _buildTimelineTab() {
    if (_customerTimeline.isEmpty) {
      return const EmptyState(
        title: 'No Activity Recorded',
        message: 'Chronological timeline of customer transactions and communications will show here.',
        icon: Icons.history_rounded,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _customerTimeline.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final item = _customerTimeline[idx];
        IconData icon = Icons.info_outline;
        Color color = AppColors.primaryBlue;

        if (item.eventType == 'INVOICE') {
          icon = Icons.receipt_long_rounded;
          color = AppColors.primaryBlue;
        } else if (item.eventType == 'PAYMENT') {
          icon = Icons.payments_rounded;
          color = AppColors.success;
        } else if (item.eventType == 'FOLLOW_UP') {
          icon = Icons.notifications_rounded;
          color = AppColors.warning;
        } else if (item.eventType == 'NOTE') {
          icon = Icons.note_alt_rounded;
          color = AppColors.deepNavy;
        }

        return AppCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                    const SizedBox(height: 2),
                    Text(item.description, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                  ],
                ),
              ),
              Text(DateFormat('dd/MM').format(item.timestamp), style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryCard(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText), maxLines: 1),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: valueColor)),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
