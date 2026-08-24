import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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

class TransactionItem {
  final String id;
  final String title;
  final String refNumber;
  final DateTime date;
  final double amount;
  final String status;
  final String type; // 'INVOICE', 'PAYMENT', 'RETURN'
  final dynamic originalObject;

  TransactionItem({
    required this.id,
    required this.title,
    required this.refNumber,
    required this.date,
    required this.amount,
    required this.status,
    required this.type,
    this.originalObject,
  });
}

class CustomerDetailsPage extends StatefulWidget {
  final CustomerEntity? customer;

  const CustomerDetailsPage({super.key, this.customer});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage>
    with SingleTickerProviderStateMixin {
  late CustomerEntity _customer;
  late TabController _tabController;

  List<InvoiceEntity> _customerInvoices = [];
  List<CustomerTimelineEvent> _customerTimeline = [];
  List<TransactionItem> _allTransactions = [];
  List<TransactionItem> _filteredTransactions = [];

  String _txSearchQuery = '';
  String _selectedTxFilter = 'All'; // 'All', 'Invoices', 'Payments', 'Returns'

  final List<CustomerNoteItem> _customerNotes = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _customer = widget.customer ??
        CustomerEntity(
          id: 'CUST-323450',
          name: 'Rahul Traders',
          phone: '98450 11223',
          email: 'rahul@traders.com',
          address: 'MG Road, Thrissur',
          outstandingBalance: 7200,
          totalPurchases: 85400,
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
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _loadCustomerData() async {
    try {
      final invRepo = getIt<InvoiceRepository>();
      final allInvoices = await invRepo.getInvoices();
      final filteredInvoices = allInvoices
          .where((i) =>
              i.customerId == _customer.id || i.customerName == _customer.name)
          .toList();
      filteredInvoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));

      final timeline = await getIt<BillingCustomerRepository>()
          .getCustomerTimeline(_customer.id);

      if (!timeline.any((t) =>
          t.eventType == 'CREATED' ||
          t.title.toLowerCase().contains('created'))) {
        timeline.add(
          CustomerTimelineEvent(
            id: 'CREATED-${_customer.id}',
            customerId: _customer.id,
            eventType: 'CREATED',
            title: 'Customer Created',
            description: 'Account created for ${_customer.name}',
            timestamp: _customer.createdAt,
          ),
        );
      }
      timeline.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final List<TransactionItem> txs = [];

      for (var inv in filteredInvoices) {
        String statusStr = 'Pending';
        if (inv.status == InvoiceStatus.paid) {
          statusStr = 'Paid';
        } else if (inv.status == InvoiceStatus.partiallyPaid) {
          statusStr = 'Partially Paid';
        } else if (inv.dueDate.isBefore(DateTime.now()) &&
            inv.status != InvoiceStatus.paid) {
          statusStr = 'Overdue';
        }

        txs.add(TransactionItem(
          id: inv.id,
          title: 'Invoice #${inv.invoiceNumber}',
          refNumber: inv.invoiceNumber,
          date: inv.issueDate,
          amount: inv.grandTotal,
          status: statusStr,
          type: 'INVOICE',
          originalObject: inv,
        ));

        if (inv.paidAmount > 0) {
          txs.add(TransactionItem(
            id: 'PAY-${inv.id}',
            title: 'Payment #PAY-${inv.invoiceNumber}',
            refNumber: 'PAY-${inv.invoiceNumber}',
            date: inv.issueDate,
            amount: inv.paidAmount,
            status: 'Paid',
            type: 'PAYMENT',
            originalObject: inv,
          ));
        }
      }

      for (var t in timeline) {
        if (t.eventType == 'PAYMENT' &&
            !filteredInvoices
                .any((i) => t.description.contains(i.invoiceNumber))) {
          final match = RegExp(r'₹?\s*(\d+)').firstMatch(t.description);
          final amt = match != null
              ? double.tryParse(match.group(1) ?? '0') ?? 0.0
              : 0.0;
          txs.add(TransactionItem(
            id: t.id,
            title: 'Payment #${t.title}',
            refNumber: t.title,
            date: t.timestamp,
            amount: amt > 0 ? amt : 500.0,
            status: 'Paid',
            type: 'PAYMENT',
          ));
        } else if (t.eventType == 'RETURN') {
          txs.add(TransactionItem(
            id: t.id,
            title: 'Sales Return #${t.title}',
            refNumber: t.title,
            date: t.timestamp,
            amount: 0.0,
            status: 'Completed',
            type: 'RETURN',
          ));
        }
      }

      txs.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _customerInvoices = filteredInvoices;
          _customerTimeline = timeline;
          _allTransactions = txs;
          _applyTxFilters();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyTxFilters() {
    var list = _allTransactions;

    if (_selectedTxFilter == 'Invoices') {
      list = list.where((t) => t.type == 'INVOICE').toList();
    } else if (_selectedTxFilter == 'Payments') {
      list = list.where((t) => t.type == 'PAYMENT').toList();
    } else if (_selectedTxFilter == 'Returns') {
      list = list.where((t) => t.type == 'RETURN').toList();
    }

    if (_txSearchQuery.trim().isNotEmpty) {
      final q = _txSearchQuery.trim().toLowerCase();
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.refNumber.toLowerCase().contains(q))
          .toList();
    }

    _filteredTransactions = list;
  }

  void _showAddNoteDialog({CustomerNoteItem? noteToEdit}) {
    final noteController = TextEditingController(
        text: noteToEdit != null ? noteToEdit.content : '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
              noteToEdit != null ? 'Edit Customer Note' : 'Add Customer Note',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            autofocus: true,
            decoration: InputDecoration(
              hintText:
                  'Enter note details (e.g. credit terms, preferred delivery time)...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white),
              onPressed: () {
                final text = noteController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    if (noteToEdit != null) {
                      final idx = _customerNotes
                          .indexWhere((n) => n.id == noteToEdit.id);
                      if (idx != -1) {
                        _customerNotes[idx] = CustomerNoteItem(
                          id: noteToEdit.id,
                          content: text,
                          timestamp: DateTime.now(),
                        );
                      }
                    } else {
                      _customerNotes.insert(
                        0,
                        CustomerNoteItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          content: text,
                          timestamp: DateTime.now(),
                        ),
                      );
                    }
                  });
                  Navigator.pop(ctx);
                }
              },
              child: Text(noteToEdit != null ? 'Update Note' : 'Save Note'),
            ),
          ],
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

      final totalPurchases =
          _customerInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
      final totalPaid =
          _customerInvoices.fold(0.0, (sum, i) => sum + i.paidAmount);

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
          SnackBar(
              content: Text('Failed to generate PDF statement: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'RT';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPurchases = _customer.totalPurchases > 0
        ? _customer.totalPurchases
        : _customerInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
    final totalPaid =
        _customerInvoices.fold(0.0, (sum, i) => sum + i.paidAmount);
    final invoiceCount = _customerInvoices.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Customer Profile',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _generatePdfStatement,
            tooltip: 'PDF Statement',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push(RouteNames.createMaster, extra: _customer),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: _isLoading
          ? const CustomerDetailsSkeleton()
          : NestedScrollView(
              headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      children: [
                        // 1. HEADER AVATAR, NAME, DETAILS, ACTIONS
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.deepNavy,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _getInitials(_customer.name),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _customer.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkBlueText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_customer.phone.isNotEmpty ? _customer.phone : "No Phone"}${_customer.email.isNotEmpty ? " · ${_customer.email}" : ""}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),

                              // Quick Action Buttons Row
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.darkBlueText,
                                        side: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                            width: 1.5),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      onPressed: () =>
                                          _makePhoneCall(_customer.phone),
                                      child: const Text('Call',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.darkBlueText,
                                        side: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                            width: 1.5),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      onPressed: () =>
                                          _openWhatsApp(_customer.phone),
                                      child: const Text('WhatsApp',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.deepNavy,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => context.push(
                                          RouteNames.createMaster,
                                          extra: _customer),
                                      child: const Text('Edit',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 2. CUSTOMER SUMMARY CARDS (4 Compact Metrics)
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                value: _formatCurrency(totalPurchases),
                                label: 'PURCHASES',
                                isHighlighted: false,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _MetricCard(
                                value: _formatCurrency(totalPaid),
                                label: 'PAID',
                                isHighlighted: false,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _MetricCard(
                                value: _formatCurrency(
                                    _customer.outstandingBalance),
                                label: 'OUTSTANDING',
                                isHighlighted: _customer.outstandingBalance > 0,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _MetricCard(
                                value: '$invoiceCount',
                                label: 'INVOICES',
                                isHighlighted: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. TABS HEADER (Overview | Transactions | Notes | Timeline)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primaryBlue,
                        unselectedLabelColor: AppColors.secondaryText,
                        indicatorColor: AppColors.primaryBlue,
                        indicatorWeight: 3,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        labelStyle: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w800),
                        unselectedLabelStyle: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w500),
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Transactions'),
                          Tab(text: 'Notes'),
                          Tab(text: 'Timeline'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: OVERVIEW
                  _buildOverviewTab(),

                  // TAB 2: TRANSACTIONS
                  _buildTransactionsTab(),

                  // TAB 3: NOTES
                  _buildNotesTab(),

                  // TAB 4: TIMELINE
                  _buildTimelineTab(),
                ],
              ),
            ),
    );
  }

  // ================= TAB 1: OVERVIEW =================
  Widget _buildOverviewTab() {
    final totalPurchases = _customer.totalPurchases > 0
        ? _customer.totalPurchases
        : _customerInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
    final totalPaid =
        _customerInvoices.fold(0.0, (sum, i) => sum + i.paidAmount);
    final invoiceCount = _customerInvoices.length;
    final avgInvoiceValue =
        invoiceCount > 0 ? (totalPurchases / invoiceCount) : 0.0;
    final lastPurchaseDate = _customerInvoices.isNotEmpty
        ? _getTimeAgo(_customerInvoices.first.issueDate)
        : 'No purchases';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Information Card
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Information',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText),
                ),
                const SizedBox(height: 10),
                if (_customer.phone.isNotEmpty) ...[
                  _InfoRow('Phone', _customer.phone),
                  const SizedBox(height: 6),
                ],
                if (_customer.email.isNotEmpty) ...[
                  _InfoRow('Email', _customer.email),
                  const SizedBox(height: 6),
                ],
                if (_customer.address.isNotEmpty) ...[
                  _InfoRow('Address', _customer.address),
                  const SizedBox(height: 6),
                ],
                _InfoRow(
                    'GSTIN',
                    _customer.id.startsWith('32')
                        ? _customer.id
                        : '32AAAAA0000A1Z5'),
                const SizedBox(height: 6),
                _InfoRow('Type', 'Business'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Account Summary Card
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Summary',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText),
                ),
                const SizedBox(height: 10),
                _InfoRow('Last purchase', lastPurchaseDate),
                const SizedBox(height: 6),
                _InfoRow('Average invoice', _formatCurrency(avgInvoiceValue)),
                const SizedBox(height: 6),
                _InfoRow('Total Sales', _formatCurrency(totalPurchases)),
                const SizedBox(height: 6),
                _InfoRow('Total Paid', _formatCurrency(totalPaid)),
                const SizedBox(height: 6),
                _InfoRow(
                  'Outstanding',
                  _formatCurrency(_customer.outstandingBalance),
                  valueColor: _customer.outstandingBalance > 0
                      ? const Color(0xFFB45309)
                      : AppColors.success,
                  isBold: true,
                ),
                const SizedBox(height: 6),
                _InfoRow('Invoices Count', '$invoiceCount'),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ================= TAB 2: TRANSACTIONS =================
  Widget _buildTransactionsTab() {
    return Column(
      children: [
        // Filter Chips & Search Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Cool Modern Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _txSearchQuery = val;
                      _applyTxFilters();
                    });
                  },
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBlueText),
                  decoration: InputDecoration(
                    hintText: 'Search by reference # or status...',
                    hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.search_rounded,
                            color: AppColors.primaryBlue, size: 18),
                      ),
                    ),
                    suffixIcon: _txSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                size: 18, color: AppColors.secondaryText),
                            onPressed: () {
                              setState(() {
                                _txSearchQuery = '';
                                _applyTxFilters();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Chips: All, Invoices, Payments (Nothing else!)
              Row(
                children: ['All', 'Invoices', 'Payments']
                    .map((f) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: ChoiceChip(
                                selected: _selectedTxFilter == f,
                                label: Center(
                                  child: Text(
                                    f,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _selectedTxFilter == f
                                          ? Colors.white
                                          : AppColors.darkBlueText,
                                    ),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                backgroundColor: const Color(0xFFF1F5F9),
                                selectedColor: AppColors.primaryBlue,
                                side: BorderSide.none,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedTxFilter = f;
                                    _applyTxFilters();
                                  });
                                },
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),

        Expanded(
          child: _filteredTransactions.isEmpty
              ? const EmptyState(
                  title: 'No Transactions Found',
                  message:
                      'Transactions will appear here when invoices or payments are created.',
                  icon: Icons.receipt_long_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredTransactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final item = _filteredTransactions[idx];
                    return AppCard(
                      onTap: () {
                        if (item.type == 'INVOICE' &&
                            item.originalObject is InvoiceEntity) {
                          context.push(
                            RouteNames.createInvoice,
                            extra: {
                              'invoiceType':
                                  (item.originalObject as InvoiceEntity).type,
                              'invoiceToEdit': item.originalObject
                            },
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.darkBlueText),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('dd MMM yyyy').format(item.date),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatCurrency(item.amount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.darkBlueText),
                              ),
                              const SizedBox(height: 4),
                              if (item.status == 'Paid')
                                StatusChip.paid()
                              else if (item.status == 'Partially Paid')
                                StatusChip.partiallyPaid()
                              else if (item.status == 'Overdue')
                                StatusChip.unpaid(label: 'Overdue')
                              else
                                StatusChip.unpaid(),
                            ],
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

  // ================= TAB 3: NOTES =================
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
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
                onPressed: () => _showAddNoteDialog(),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('+ Add Note',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _customerNotes.isEmpty
              ? const EmptyState(
                  title: 'No Notes Added',
                  message:
                      'Add customer preferences, payment reminders, or key details here.',
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
                                  const Icon(Icons.sticky_note_2_outlined,
                                      size: 16, color: AppColors.primaryBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Created ${DateFormat("dd MMM yyyy · hh:mm a").format(note.timestamp)}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 16, color: AppColors.primaryBlue),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () =>
                                        _showAddNoteDialog(noteToEdit: note),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                        color: AppColors.danger),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(
                                          () => _customerNotes.removeAt(idx));
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note.content,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.darkBlueText,
                                height: 1.4,
                                fontWeight: FontWeight.w500),
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

  // Helper to format date grouping header
  String _getDateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'TODAY';
    } else if (itemDate == yesterday) {
      return 'YESTERDAY';
    } else {
      return DateFormat('dd MMM yyyy').format(date).toUpperCase();
    }
  }

  void _showTimelineEventDetail(
      BuildContext context, CustomerTimelineEvent item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy · hh:mm a').format(item.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.darkBlueText,
                  height: 1.4,
                ),
              ),
              if (item.amount != null && item.amount! > 0) ...[
                const SizedBox(height: 12),
                Text(
                  'Amount: ${_formatCurrency(item.amount!)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= TAB 4: TIMELINE =================
  Widget _buildTimelineTab() {
    if (_customerTimeline.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  size: 36,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No activity yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Customer interactions and updates will appear here.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _customerTimeline.length,
      itemBuilder: (ctx, idx) {
        final item = _customerTimeline[idx];
        final isFirst = idx == 0;
        final isLast = idx == _customerTimeline.length - 1;

        final currentDateHeader = _getDateGroupLabel(item.timestamp);
        final prevDateHeader = idx > 0
            ? _getDateGroupLabel(_customerTimeline[idx - 1].timestamp)
            : null;
        final showDateHeader = currentDateHeader != prevDateHeader;

        IconData icon = Icons.info_outline;
        Color color = AppColors.primaryBlue;

        if (item.eventType == 'CREATED') {
          icon = Icons.person_add_rounded;
          color = const Color(0xFF2563EB);
        } else if (item.eventType == 'INVOICE') {
          icon = Icons.description_outlined;
          color = const Color(0xFF4F46E5);
        } else if (item.eventType == 'PAYMENT') {
          icon = Icons.check_circle_outline_rounded;
          color = const Color(0xFF059669);
        } else if (item.eventType == 'FOLLOW_UP') {
          icon = Icons.calendar_today_rounded;
          color = const Color(0xFFD97706);
        } else if (item.eventType == 'NOTE') {
          icon = Icons.sticky_note_2_outlined;
          color = const Color(0xFF1E293B);
        } else if (item.eventType == 'CALL') {
          icon = Icons.phone_outlined;
          color = const Color(0xFF0D9488);
        } else if (item.eventType == 'WHATSAPP') {
          icon = Icons.chat_bubble_outline_rounded;
          color = const Color(0xFF16A34A);
        } else if (item.eventType == 'UPDATED') {
          icon = Icons.edit_outlined;
          color = const Color(0xFF7C3AED);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) ...[
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 4, bottom: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentDateHeader,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Vertical Timeline Path & Circular Node
                  SizedBox(
                    width: 36,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Top Line Segment (only if NOT first item)
                        if (!isFirst)
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 17,
                            child: Container(
                              width: 2,
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                        // Bottom Line Segment (only if NOT last item)
                        if (!isLast)
                          Positioned(
                            top: 25,
                            bottom: 0,
                            left: 17,
                            child: Container(
                              width: 2,
                              color: isFirst
                                  ? const Color(0xFF93C5FD)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                        // Node Dot
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: isFirst
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Right Activity Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showTimelineEventDetail(context, item),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isFirst
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFFE2E8F0),
                            width: isFirst ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isFirst ? 0.05 : 0.02),
                              blurRadius: isFirst ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Small Circular Icon Box
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: color, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: isFirst
                                                ? AppColors.darkBlueText
                                                : const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      if (isFirst) ...[
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDBEAFE),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Latest',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1E40AF),
                                            ),
                                          ),
                                        ),
                                      ],
                                      Text(
                                        DateFormat('hh:mm a')
                                                    .format(item.timestamp) !=
                                                '12:00 AM'
                                            ? DateFormat('hh:mm a')
                                                .format(item.timestamp)
                                            : DateFormat('dd MMM')
                                                .format(item.timestamp),
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      height: 1.3,
                                    ),
                                  ),
                                  if (item.amount != null &&
                                      item.amount! > 0) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _formatCurrency(item.amount!),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isHighlighted;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFFEF3C7) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isHighlighted ? const Color(0xFFFDE68A) : const Color(0xFFF3F4F6),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isHighlighted
                    ? const Color(0xFFB45309)
                    : AppColors.darkBlueText,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isHighlighted
                  ? const Color(0xFFB45309)
                  : AppColors.secondaryText,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _InfoRow(
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
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: valueColor ?? AppColors.darkBlueText,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverTabBarDelegate(this.child);

  @override
  double get minExtent => 46;
  @override
  double get maxExtent => 46;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
