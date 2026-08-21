import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/bloc/crm_customer_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/crm_customer_entity.dart';
import '../../../domain/entities/crm_entities.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/payment_entity.dart';
import '../../../domain/repositories/crm_customer_repository.dart';
import '../../../infrastructure/services/crm_service.dart';
import '../../../infrastructure/storage/hive_service.dart';
import '../../widgets/app_card.dart';
import '../widgets/add_crm_customer_dialog.dart';

class CrmCustomerDetailsPage extends StatefulWidget {
  final CrmCustomerEntity customer;

  const CrmCustomerDetailsPage({
    super.key,
    required this.customer,
  });

  @override
  State<CrmCustomerDetailsPage> createState() => _CrmCustomerDetailsPageState();
}

class _CrmCustomerDetailsPageState extends State<CrmCustomerDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CrmCustomerEntity _currentCustomer;

  List<PaymentEntity> _payments = [];
  List<CrmNoteEntity> _notes = [];
  List<CustomerTimelineEvent> _timeline = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
    _tabController = TabController(length: 4, vsync: this);
    _loadCustomerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerData() async {
    setState(() => _isLoadingData = true);
    final crmService = CrmService(
      hiveService: getIt<HiveService>(),
      crmCustomerRepository: getIt<CrmCustomerRepository>(),
    );

    final payments = crmService.getPaymentsForCustomer(_currentCustomer.id);
    final notes = crmService.getNotesForCustomer(_currentCustomer.id);
    final timeline = await crmService.getCrmCustomerTimeline(_currentCustomer.id, customer: _currentCustomer);

    if (mounted) {
      setState(() {
        _payments = payments;
        _notes = notes;
        _timeline = timeline;
        _isLoadingData = false;
      });
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'C';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'C';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete CRM Customer',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
        ),
        content: Text(
          'Are you sure you want to delete "${_currentCustomer.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              context.read<CrmCustomerBloc>().add(DeleteCrmCustomerEvent(_currentCustomer.id));
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Customer "${_currentCustomer.name}" deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ==================== DIALOG 1: ADD NOTE ====================
  void _showAddNoteDialog() {
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Customer Note', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(
            hintText: 'Enter note remarks or interaction summary...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              final content = noteCtrl.text.trim();
              if (content.isEmpty) return;

              final note = CrmNoteEntity(
                id: 'note_${DateTime.now().millisecondsSinceEpoch}',
                customerId: _currentCustomer.id,
                text: content,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              final crmService = CrmService(
                hiveService: getIt<HiveService>(),
                crmCustomerRepository: getIt<CrmCustomerRepository>(),
              );
              await crmService.saveNote(note);

              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note added successfully!'), backgroundColor: AppColors.success),
                );
                _loadCustomerData();
              }
            },
            child: const Text('Save Note', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==================== DIALOG 2: RECORD PAYMENT ====================
  void _showRecordPaymentDialog() {
    final amountCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String paymentMode = 'CASH';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Record Payment for ${_currentCustomer.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹) *', hintText: 'e.g. 2500', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                const Text('Payment Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: paymentMode,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: ['CASH', 'UPI', 'BANK_TRANSFER', 'CARD', 'CHEQUE'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => paymentMode = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: refCtrl,
                  decoration: const InputDecoration(labelText: 'Reference / Txn ID', hintText: 'Optional transaction ID', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Payment Remarks', hintText: 'Optional remarks', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                if (amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount.')));
                  return;
                }

                final payment = PaymentEntity(
                  id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                  invoiceId: '',
                  customerId: _currentCustomer.id,
                  customerName: _currentCustomer.name,
                  amount: amt,
                  paymentMode: paymentMode,
                  referenceNumber: refCtrl.text.trim(),
                  paymentDate: DateTime.now(),
                  notes: notesCtrl.text.trim(),
                );

                final crmService = CrmService(
                  hiveService: getIt<HiveService>(),
                  crmCustomerRepository: getIt<CrmCustomerRepository>(),
                );
                await crmService.saveCustomerPayment(payment);

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment of ₹${amt.toStringAsFixed(0)} recorded successfully!'), backgroundColor: AppColors.success),
                  );
                  _loadCustomerData();
                }
              },
              child: const Text('Save Payment', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(_currentCustomer.name);
    Color statusColor = AppColors.primaryBlue;
    final st = _currentCustomer.status.toLowerCase();
    if (st == 'active') statusColor = AppColors.success;
    if (st == 'lead') statusColor = const Color(0xFF8B5CF6);
    if (st == 'contacted') statusColor = const Color(0xFFD97706);
    if (st == 'inactive') statusColor = AppColors.secondaryText;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Customer Details'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Customer',
            onPressed: () async {
              final updated = await showAddCrmCustomerDialog(context);
              if (updated != null && context.mounted) {
                context.read<CrmCustomerBloc>().add(UpdateCrmCustomerEvent(updated));
                setState(() => _currentCustomer = updated);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Customer',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Profile Summary Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: statusColor.withValues(alpha: 0.14),
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentCustomer.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          if (_currentCustomer.companyName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              _currentCustomer.companyName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _currentCustomer.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Call & WhatsApp Prominent Action Buttons
                Row(
                  children: [
                    if (_currentCustomer.phone.isNotEmpty) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => CrmService.makePhoneCall(_currentCustomer.phone),
                          icon: const Icon(Icons.phone_rounded, size: 18),
                          label: const Text(
                            'Call',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => CrmService.openWhatsApp(
                            _currentCustomer.phone,
                            text: 'Hello ${_currentCustomer.name}, following up from XenoBiz CRM.',
                          ),
                          icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                          label: const Text(
                            'WhatsApp',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // EXACT 4 SECTION TABS: Overview, Payments, Notes, Activity
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.secondaryText,
                  indicatorColor: AppColors.primaryBlue,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Payments'),
                    Tab(text: 'Notes'),
                    Tab(text: 'Activity'),
                  ],
                ),
              ],
            ),
          ),

          // Tab Content Views
          Expanded(
            child: _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: OVERVIEW (CRM Info Only — NO Financial Figures)
                      _buildOverviewTab(),

                      // TAB 2: PAYMENTS (Recorded Customer Payments)
                      _buildPaymentsTab(),

                      // TAB 3: NOTES (Customer Notes & Dialog)
                      _buildNotesTab(),

                      // TAB 4: ACTIVITY (Relationship History)
                      _buildActivityTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: OVERVIEW ====================
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONTACT INFORMATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryText,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: _currentCustomer.phone.isNotEmpty ? _currentCustomer.phone : 'Not provided',
                ),
                const Divider(height: 20),
                _DetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: _currentCustomer.email.isNotEmpty ? _currentCustomer.email : 'Not provided',
                ),
                const Divider(height: 20),
                _DetailRow(
                  icon: Icons.business_outlined,
                  label: 'Company Name',
                  value: _currentCustomer.companyName.isNotEmpty ? _currentCustomer.companyName : 'Not provided',
                ),
                const Divider(height: 20),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: _currentCustomer.address.isNotEmpty ? _currentCustomer.address : 'Not provided',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'RELATIONSHIP DETAILS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryText,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.source_outlined,
                  label: 'Lead Source',
                  value: _currentCustomer.source.isNotEmpty ? _currentCustomer.source : 'Direct',
                ),
                const Divider(height: 20),
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Assigned Staff',
                  value: _currentCustomer.assignedStaff.isNotEmpty ? _currentCustomer.assignedStaff : 'Unassigned',
                ),
                const Divider(height: 20),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Created Date',
                  value: '${_currentCustomer.createdAt.day}/${_currentCustomer.createdAt.month}/${_currentCustomer.createdAt.year}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_currentCustomer.notes.isNotEmpty) ...[
            const Text(
              'INITIAL REMARKS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                _currentCustomer.notes,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkBlueText,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== TAB 2: PAYMENTS ====================
  Widget _buildPaymentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECORDED PAYMENTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryText,
                  letterSpacing: 0.6,
                ),
              ),
              TextButton.icon(
                onPressed: _showRecordPaymentDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('+ Record Payment', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_payments.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.payments_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'No payments recorded yet.',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap "+ Record Payment" to log a payment.',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final p = _payments[idx];
                return AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.payments_rounded, color: Color(0xFF10B981), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${p.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${p.paymentMode}${p.referenceNumber.isNotEmpty ? " • Ref: ${p.referenceNumber}" : ""}',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                            ),
                            if (p.notes.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(p.notes, style: const TextStyle(fontSize: 12, color: AppColors.darkBlueText)),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '${p.paymentDate.day}/${p.paymentDate.month}/${p.paymentDate.year}',
                        style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==================== TAB 3: NOTES ====================
  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CUSTOMER NOTES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryText,
                  letterSpacing: 0.6,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddNoteDialog,
                icon: const Icon(Icons.note_add_rounded, size: 18),
                label: const Text('+ Add Note', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_notes.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.note_alt_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'No notes added for this customer yet.',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap "+ Add Note" to add an interaction note.',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final note = _notes[idx];
                return AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Admin',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primaryBlue),
                          ),
                          Text(
                            '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year} ${note.updatedAt.hour}:${note.updatedAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        note.text,
                        style: const TextStyle(fontSize: 13, color: AppColors.darkBlueText, height: 1.3, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==================== TAB 4: ACTIVITY ====================
  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVITY HISTORY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryText,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          if (_timeline.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(32),
              child: const Center(
                child: Text('No activity recorded for this customer yet.', style: TextStyle(color: AppColors.secondaryText)),
              ),
            )
          else
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _timeline.map((event) => _buildTimelineItem(event)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(CustomerTimelineEvent item) {
    IconData icon;
    Color color;

    switch (item.eventType.toUpperCase()) {
      case 'NOTE':
        icon = Icons.note_alt_rounded;
        color = const Color(0xFF0D9488);
        break;
      case 'FOLLOW_UP':
        icon = Icons.event_available_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case 'ACCOUNT':
        icon = Icons.person_rounded;
        color = AppColors.primaryBlue;
        break;
      default:
        icon = Icons.history_toggle_off_rounded;
        color = AppColors.deepNavy;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.timestamp.day}/${item.timestamp.month} ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlueText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
