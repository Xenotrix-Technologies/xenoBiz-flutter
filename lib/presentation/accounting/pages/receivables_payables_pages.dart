import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

// ============================================================================
// RECEIVABLES PAGE
// ============================================================================

class ReceivablesPage extends StatefulWidget {
  const ReceivablesPage({super.key});

  @override
  State<ReceivablesPage> createState() => _ReceivablesPageState();
}

class _ReceivablesPageState extends State<ReceivablesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedAgingFilter = 'All';

  final List<_DebtorModel> _allDebtors = [
    _DebtorModel(
      id: 'd-1',
      name: 'Rahul Sharma',
      amount: 15400.0,
      dueDays: 12,
      isOverdue: true,
      invoiceNo: 'INV-2026-089',
      phone: '+91 98765 43210',
      lastPaymentDate: DateTime.now().subtract(const Duration(days: 25)),
    ),
    _DebtorModel(
      id: 'd-2',
      name: 'Ankit Traders',
      amount: 28900.0,
      dueDays: 45,
      isOverdue: true,
      invoiceNo: 'INV-2026-042',
      phone: '+91 98123 45678',
      lastPaymentDate: DateTime.now().subtract(const Duration(days: 60)),
    ),
    _DebtorModel(
      id: 'd-3',
      name: 'Priya Enterprise',
      amount: 8200.0,
      dueDays: 5,
      isOverdue: false,
      invoiceNo: 'INV-2026-105',
      phone: '+91 97000 11223',
      lastPaymentDate: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _sendReminder(BuildContext context, _DebtorModel debtor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.success),
            const SizedBox(width: 8),
            Text('Send Payment Reminder',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipient: ${debtor.name} (${debtor.phone})',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlueText)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pageBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Dear ${debtor.name},\nThis is a friendly reminder that payment of ${_formatCurrency(debtor.amount)} for invoice ${debtor.invoiceNo} is overdue by ${debtor.dueDays} days.\nPlease settle the payment at your earliest convenience.\n\nThank you,\nXenobiz Store',
                style: const TextStyle(fontSize: 12, color: AppColors.darkBlueText),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment reminder sent to ${debtor.name} via WhatsApp/SMS!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  void _exportReceivables(BuildContext context, double total, int count) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Export Receivables Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Total Outstanding: ${_formatCurrency(total)} ($count customers)',
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('PDF Aging Statement',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Outstanding_Receivables_Statement.pdf'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generated Outstanding_Receivables_Statement.pdf'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined, color: Colors.green),
                title: const Text('Excel / CSV Export',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Receivables_Aging_Summary.csv'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generated Receivables_Aging_Summary.csv'),
                      backgroundColor: AppColors.success,
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

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();

    List<_DebtorModel> filtered = _allDebtors.where((d) {
      if (_selectedAgingFilter == 'Overdue' && !d.isOverdue) return false;
      if (_selectedAgingFilter == 'Current' && d.isOverdue) return false;
      if (_selectedAgingFilter == '30+ Days' && d.dueDays < 30) return false;

      if (query.isEmpty) return true;
      return d.name.toLowerCase().contains(query) ||
          d.invoiceNo.toLowerCase().contains(query) ||
          d.phone.toLowerCase().contains(query);
    }).toList();

    final totalReceivable = _allDebtors.fold(0.0, (sum, d) => sum + d.amount);
    final overdueTotal = _allDebtors
        .where((d) => d.isOverdue)
        .fold(0.0, (sum, d) => sum + d.amount);
    final currentTotal = totalReceivable - overdueTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Receivables'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () =>
                _exportReceivables(context, totalReceivable, _allDebtors.length),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.pageBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search customer name, invoice, phone...',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        overflow: TextOverflow.ellipsis,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          size: 20, color: AppColors.secondaryText),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontally Scrollable Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Overdue', 'Current', '30+ Days'].map((tag) {
                      final selected = _selectedAgingFilter == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tag),
                          selected: selected,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.pageBackground,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.darkBlueText,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedAgingFilter = tag);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // KPI Summary Cards
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.call_received,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Outstanding Receivables',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(totalReceivable),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Secondary KPI Summary Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Overdue Dues',
                    amount: _formatCurrency(overdueTotal),
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Current Dues',
                    amount: _formatCurrency(currentTotal),
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // List of Customers / Dues
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    title: 'No Receivables Found',
                    message: query.isNotEmpty
                        ? 'No customers match your search.'
                        : 'No pending customer receivables for this filter.',
                    icon: Icons.call_received,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final debtor = filtered[idx];
                      return _buildDebtorCard(context, debtor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
      {required String label, required String amount, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtorCard(BuildContext context, _DebtorModel debtor) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              // Circle Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.success.withValues(alpha: 0.15),
                child: Text(
                  debtor.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name & Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debtor.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${debtor.invoiceNo} • ${debtor.phone}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount & Due Tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(debtor.amount),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: debtor.isOverdue
                          ? AppColors.danger.withValues(alpha: 0.12)
                          : AppColors.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      debtor.isOverdue
                          ? 'Overdue ${debtor.dueDays}d'
                          : 'Due in ${debtor.dueDays}d',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: debtor.isOverdue
                            ? AppColors.danger
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 18),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: AppColors.success),
                    foregroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _sendReminder(context, debtor),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Reminder',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.push(
                      RouteNames.ledger,
                      extra: debtor.name,
                    );
                  },
                  icon: const Icon(Icons.auto_stories_outlined, size: 16),
                  label: const Text('View Ledger',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebtorModel {
  final String id;
  final String name;
  final double amount;
  final int dueDays;
  final bool isOverdue;
  final String invoiceNo;
  final String phone;
  final DateTime lastPaymentDate;

  _DebtorModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDays,
    required this.isOverdue,
    required this.invoiceNo,
    required this.phone,
    required this.lastPaymentDate,
  });
}

// ============================================================================
// PAYABLES PAGE
// ============================================================================

class PayablesPage extends StatefulWidget {
  const PayablesPage({super.key});

  @override
  State<PayablesPage> createState() => _PayablesPageState();
}

class _PayablesPageState extends State<PayablesPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedAgingFilter = 'All';

  final List<_CreditorModel> _allCreditors = [
    _CreditorModel(
      id: 'c-1',
      name: 'Metro Wholesalers',
      amount: 42500.0,
      dueDays: 10,
      isOverdue: false,
      invoiceNo: 'PUR-2026-088',
      phone: '+91 99887 76655',
    ),
    _CreditorModel(
      id: 'c-2',
      name: 'Apex Distributors',
      amount: 19800.0,
      dueDays: 22,
      isOverdue: true,
      invoiceNo: 'PUR-2026-061',
      phone: '+91 98888 55443',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _exportPayables(BuildContext context, double total, int count) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Export Payables Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Total Payable: ${_formatCurrency(total)} ($count vendors)',
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('PDF Vendor Payables Statement',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Outstanding_Payables_Statement.pdf'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generated Outstanding_Payables_Statement.pdf'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined, color: Colors.green),
                title: const Text('Excel / CSV Export',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Payables_Aging_Summary.csv'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generated Payables_Aging_Summary.csv'),
                      backgroundColor: AppColors.success,
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

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();

    List<_CreditorModel> filtered = _allCreditors.where((c) {
      if (_selectedAgingFilter == 'Overdue' && !c.isOverdue) return false;
      if (_selectedAgingFilter == 'Upcoming' && c.isOverdue) return false;

      if (query.isEmpty) return true;
      return c.name.toLowerCase().contains(query) ||
          c.invoiceNo.toLowerCase().contains(query) ||
          c.phone.toLowerCase().contains(query);
    }).toList();

    final totalPayable = _allCreditors.fold(0.0, (sum, c) => sum + c.amount);
    final overdueTotal = _allCreditors
        .where((c) => c.isOverdue)
        .fold(0.0, (sum, c) => sum + c.amount);
    final upcomingTotal = totalPayable - overdueTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payables'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () =>
                _exportPayables(context, totalPayable, _allCreditors.length),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.pageBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search supplier name, bill, phone...',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        overflow: TextOverflow.ellipsis,
                      ),
                      prefixIcon: const Icon(Icons.search,
                          size: 20, color: AppColors.secondaryText),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontally Scrollable Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Overdue', 'Upcoming'].map((tag) {
                      final selected = _selectedAgingFilter == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tag),
                          selected: selected,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.pageBackground,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.darkBlueText,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedAgingFilter = tag);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // KPI Summary Cards
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.call_made,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Outstanding Payables',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(totalPayable),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Secondary KPI Summary Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Overdue Dues',
                    amount: _formatCurrency(overdueTotal),
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Upcoming Dues',
                    amount: _formatCurrency(upcomingTotal),
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // List of Creditors / Bills
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    title: 'No Payables Found',
                    message: query.isNotEmpty
                        ? 'No vendors match your search.'
                        : 'No pending supplier payables for this filter.',
                    icon: Icons.call_made,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final creditor = filtered[idx];
                      return _buildCreditorCard(context, creditor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
      {required String label, required String amount, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditorCard(BuildContext context, _CreditorModel creditor) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              // Circle Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.danger.withValues(alpha: 0.15),
                child: Text(
                  creditor.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.danger,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name & Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creditor.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${creditor.invoiceNo} • ${creditor.phone}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount & Due Tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(creditor.amount),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: creditor.isOverdue
                          ? AppColors.danger.withValues(alpha: 0.12)
                          : AppColors.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      creditor.isOverdue
                          ? 'Overdue ${creditor.dueDays}d'
                          : 'Due in ${creditor.dueDays}d',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: creditor.isOverdue
                            ? AppColors.danger
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 18),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: AppColors.primaryBlue),
                    foregroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.push(
                      RouteNames.ledger,
                      extra: creditor.name,
                    );
                  },
                  icon: const Icon(Icons.auto_stories_outlined, size: 16),
                  label: const Text('View Ledger',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.push(RouteNames.expense);
                  },
                  icon: const Icon(Icons.payment, size: 16),
                  label: const Text('Pay Bill',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreditorModel {
  final String id;
  final String name;
  final double amount;
  final int dueDays;
  final bool isOverdue;
  final String invoiceNo;
  final String phone;

  _CreditorModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDays,
    required this.isOverdue,
    required this.invoiceNo,
    required this.phone,
  });
}
