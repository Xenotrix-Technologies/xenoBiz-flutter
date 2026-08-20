import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/accounts_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/business_entity.dart';
import '../../../domain/entities/crm_entities.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/invoice_repository.dart';
import '../../../infrastructure/pdf/pdf_statement_service.dart';
import '../../../infrastructure/services/crm_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class CustomerDetailsPage extends StatefulWidget {
  final CustomerEntity? customer;

  const CustomerDetailsPage({super.key, this.customer});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> with SingleTickerProviderStateMixin {
  late CustomerEntity _customer;
  late final CrmService _crmService;
  late TabController _tabController;

  List<InvoiceEntity> _customerInvoices = [];
  List<CrmNoteEntity> _customerNotes = [];
  List<CrmFollowUpEntity> _customerFollowUps = [];
  List<CustomerTimelineEvent> _customerTimeline = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _crmService = getIt<CrmService>();
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

  Future<void> _loadCustomerData() async {
    try {
      final invRepo = getIt<InvoiceRepository>();
      final allInvoices = await invRepo.getInvoices();
      final filteredInvoices = allInvoices.where((i) => i.customerId == _customer.id || i.customerName == _customer.name).toList();
      filteredInvoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));

      final notes = _crmService.getNotesForCustomer(_customer.id);
      final followUps = _crmService.getFollowUps(customerId: _customer.id);
      final timeline = await _crmService.getCustomerTimeline(_customer.id, customer: _customer);

      if (mounted) {
        setState(() {
          _customerInvoices = filteredInvoices;
          _customerNotes = notes;
          _customerFollowUps = followUps;
          _customerTimeline = timeline;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditNoteDialog([CrmNoteEntity? existingNote]) {
    final textCtrl = TextEditingController(text: existingNote?.text ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingNote == null ? 'Add Customer Note' : 'Edit Customer Note', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add important remarks, communication preferences, or payment instructions.',
              style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g., Customer prefers WhatsApp invoices. Follow up around month-end.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            onPressed: () async {
              final text = textCtrl.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogCtx);
                final note = existingNote?.copyWith(text: text, updatedAt: DateTime.now()) ??
                    CrmNoteEntity(
                      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
                      customerId: _customer.id,
                      text: text,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                await _crmService.saveNote(note);
                _loadCustomerData();
              }
            },
            child: Text(existingNote == null ? 'Save Note' : 'Update Note'),
          ),
        ],
      ),
    );
  }

  void _showAddFollowUpDialog() {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 30);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Schedule Follow-Up', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Follow-up Title *',
                        hintText: 'e.g. Call regarding pending payment',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes',
                        hintText: 'Optional instructions or context',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() => selectedDate = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today_rounded, size: 16),
                            label: Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(context: context, initialTime: selectedTime);
                              if (picked != null) {
                                setDialogState(() => selectedTime = picked);
                              }
                            },
                            icon: const Icon(Icons.access_time_rounded, size: 16),
                            label: Text(selectedTime.format(context), style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (titleCtrl.text.trim().isNotEmpty) {
                      Navigator.pop(dialogCtx);
                      final fu = CrmFollowUpEntity(
                        id: 'fu_${DateTime.now().millisecondsSinceEpoch}',
                        customerId: _customer.id,
                        customerName: _customer.name,
                        title: titleCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                        dueDate: selectedDate,
                        dueTime: selectedTime.format(context),
                        status: 'pending',
                      );
                      await _crmService.saveFollowUp(fu);
                      _loadCustomerData();
                    }
                  },
                  child: const Text('Schedule'),
                ),
              ],
            );
          },
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

  @override
  Widget build(BuildContext context) {
    final totalPurchases = _customer.totalPurchases > 0 ? _customer.totalPurchases : _customerInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
    final totalPaid = _customerInvoices.fold(0.0, (sum, i) => sum + i.paidAmount);
    final invoiceCount = _customerInvoices.length;
    final avgInvoiceValue = invoiceCount > 0 ? (totalPurchases / invoiceCount) : 0.0;
    final lastPurchaseDate = _customerInvoices.isNotEmpty ? DateFormat('dd MMM yyyy').format(_customerInvoices.first.issueDate) : 'No purchases';

    final segment = CustomerSegmentation.calculateSegment(_customer, _customerInvoices);
    final segmentLabel = CustomerSegmentation.getLabel(segment);
    final segmentColor = CustomerSegmentation.getColor(segment);
    final segmentBg = CustomerSegmentation.getBgColor(segment);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Profile & CRM'),
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
          ? const LoadingState(message: 'Loading customer profile...')
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
                                    backgroundColor: segmentBg,
                                    child: Text(
                                      _customer.name.isNotEmpty ? _customer.name.substring(0, 1).toUpperCase() : 'C',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: segmentColor),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _customer.name,
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(color: segmentBg, borderRadius: BorderRadius.circular(6)),
                                              child: Text(segmentLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: segmentColor)),
                                            ),
                                          ],
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
                                        onPressed: () => CrmService.makePhoneCall(_customer.phone),
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
                                        onPressed: () => CrmService.openWhatsApp(_customer.phone),
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
                        Tab(text: 'Follow-ups'),
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

                  // TAB 3: FOLLOW-UPS
                  _buildFollowUpsTab(),

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showAddEditNoteDialog(),
              icon: const Icon(Icons.note_add_outlined, size: 18),
              label: const Text('+ Add Customer Note', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
        Expanded(
          child: _customerNotes.isEmpty
              ? const EmptyState(
                  title: 'No Notes Added',
                  message: 'Keep track of customer preferences, remarks, and reminders.',
                  icon: Icons.note_alt_outlined,
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
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(note.updatedAt),
                                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryBlue),
                                    onPressed: () => _showAddEditNoteDialog(note),
                                    tooltip: 'Edit Note',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                                    onPressed: () async {
                                      await _crmService.deleteNote(note.id);
                                      _loadCustomerData();
                                    },
                                    tooltip: 'Delete Note',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(note.text, style: const TextStyle(fontSize: 13, color: AppColors.darkBlueText, height: 1.3)),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFollowUpsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _showAddFollowUpDialog,
              icon: const Icon(Icons.event_available_outlined, size: 18),
              label: const Text('+ Schedule Follow-Up', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
        Expanded(
          child: _customerFollowUps.isEmpty
              ? const EmptyState(
                  title: 'No Follow-ups Scheduled',
                  message: 'Schedule follow-up calls or payment reminders for this customer.',
                  icon: Icons.notifications_none_rounded,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _customerFollowUps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final fu = _customerFollowUps[idx];
                    return AppCard(
                      child: Row(
                        children: [
                          Checkbox(
                            value: fu.isCompleted,
                            activeColor: AppColors.success,
                            onChanged: (_) async {
                              await _crmService.toggleFollowUpStatus(fu.id);
                              _loadCustomerData();
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fu.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    decoration: fu.isCompleted ? TextDecoration.lineThrough : null,
                                    color: fu.isCompleted ? AppColors.secondaryText : AppColors.darkBlueText,
                                  ),
                                ),
                                if (fu.notes.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(fu.notes, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Due: ${DateFormat('dd MMM yyyy').format(fu.dueDate)} • ${fu.dueTime}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fu.isOverdue ? AppColors.danger : AppColors.primaryBlue),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                            onPressed: () async {
                              await _crmService.deleteFollowUp(fu.id);
                              _loadCustomerData();
                            },
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
