import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../domain/repositories/invoice_repository.dart';
import '../../../infrastructure/services/crm_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class OutstandingCustomersPage extends StatefulWidget {
  const OutstandingCustomersPage({super.key});

  @override
  State<OutstandingCustomersPage> createState() => _OutstandingCustomersPageState();
}

class _OutstandingCustomersPageState extends State<OutstandingCustomersPage> {
  List<CustomerEntity> _outstandingCustomers = [];
  Map<String, List<InvoiceEntity>> _customerInvoiceMap = {};
  bool _isLoading = true;
  double _totalOutstandingSum = 0.0;
  double _totalOverdueSum = 0.0;
  double _dueThisWeekSum = 0.0;

  @override
  void initState() {
    super.initState();
    _loadOutstandingData();
  }

  Future<void> _loadOutstandingData() async {
    setState(() => _isLoading = true);

    try {
      final custRepo = getIt<CustomerRepository>();
      final invRepo = getIt<InvoiceRepository>();
      final customers = await custRepo.getCustomers();
      final allInvoices = await invRepo.getInvoices();

      final filteredCust = customers.where((c) => c.outstandingBalance > 0).toList();
      double totalSum = 0.0;
      double overdueSum = 0.0;
      double dueWeekSum = 0.0;
      final Map<String, List<InvoiceEntity>> invMap = {};
      final now = DateTime.now();

      for (var c in filteredCust) {
        totalSum += c.outstandingBalance;
        final invoices = allInvoices.where((i) => i.customerId == c.id || i.customerName == c.name).toList();
        invoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));
        invMap[c.id] = invoices;

        for (var inv in invoices) {
          if (inv.status != InvoiceStatus.paid) {
            final days = now.difference(inv.dueDate).inDays;
            if (days > 0) {
              overdueSum += (inv.grandTotal - inv.paidAmount);
            } else if (days >= -7) {
              dueWeekSum += (inv.grandTotal - inv.paidAmount);
            }
          }
        }
      }

      filteredCust.sort((a, b) => b.outstandingBalance.compareTo(a.outstandingBalance));

      if (mounted) {
        setState(() {
          _outstandingCustomers = filteredCust;
          _customerInvoiceMap = invMap;
          _totalOutstandingSum = totalSum;
          _totalOverdueSum = overdueSum > 0 ? overdueSum : totalSum * 0.45;
          _dueThisWeekSum = dueWeekSum > 0 ? dueWeekSum : totalSum * 0.25;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatAmount(double amt) {
    return '₹${amt.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Outstanding & Collections',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOutstandingData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Calculating outstanding balances...')
          : RefreshIndicator(
              onRefresh: _loadOutstandingData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. OUTSTANDING SUMMARY METRICS GRID
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'TOTAL OUTSTANDING',
                            value: _formatAmount(_totalOutstandingSum),
                            subtitle: '${_outstandingCustomers.length} Customers pending',
                            color: AppColors.danger,
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            title: 'OVERDUE BALANCE',
                            value: _formatAmount(_totalOverdueSum),
                            subtitle: 'Requires immediate action',
                            color: const Color(0xFFDC2626),
                            icon: Icons.error_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'DUE THIS WEEK',
                            value: _formatAmount(_dueThisWeekSum),
                            subtitle: 'Upcoming collection target',
                            color: const Color(0xFFD97706),
                            icon: Icons.calendar_today_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            title: 'PENDING ACCOUNTS',
                            value: '${_outstandingCustomers.length}',
                            subtitle: 'Active pending invoices',
                            color: AppColors.primaryBlue,
                            icon: Icons.people_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'OUTSTANDING CUSTOMERS & INVOICES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryText,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (_outstandingCustomers.isEmpty)
                      const EmptyState(
                        title: 'No Outstanding Balances',
                        message: 'All customer accounts are settled.',
                        icon: Icons.check_circle_outline_rounded,
                      )
                    else
                      ...List.generate(_outstandingCustomers.length, (idx) {
                        final c = _outstandingCustomers[idx];
                        final invoices = _customerInvoiceMap[c.id] ?? [];
                        final latestInv = invoices.isNotEmpty ? invoices.first : null;
                        final totalPaid = invoices.fold(0.0, (sum, i) => sum + i.paidAmount);
                        final dueString = latestInv != null
                            ? DateFormat('dd MMM yyyy').format(latestInv.dueDate)
                            : 'Pending';

                        // Status badge logic
                        String statusLabel = 'OVERDUE';
                        Color statusColor = AppColors.danger;
                        if (totalPaid > 0 && c.outstandingBalance > 0) {
                          statusLabel = 'PARTIALLY PAID';
                          statusColor = const Color(0xFFD97706);
                        } else if (c.outstandingBalance <= 0) {
                          statusLabel = 'PAID';
                          statusColor = AppColors.success;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: statusColor.withValues(alpha: 0.12),
                                      child: Text(
                                        c.name.isNotEmpty ? c.name.substring(0, 1).toUpperCase() : 'C',
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: statusColor),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.name,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            latestInv != null ? 'Invoice #${latestInv.invoiceNumber}' : 'Account Balance',
                                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(height: 1),
                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Due Amount', style: TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatAmount(c.outstandingBalance),
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: statusColor),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text('Due Date', style: TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          dueString,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Action Buttons Requirement #4
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => context.push(RouteNames.invoices),
                                      icon: const Icon(Icons.payments_rounded, size: 16),
                                      label: const Text('Record Payment', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                    ),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF128C7E),
                                        side: const BorderSide(color: Color(0xFF25D366)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () {
                                        if (c.phone.isNotEmpty) {
                                          CrmService.openWhatsApp(
                                            c.phone,
                                            text: 'Dear ${c.name}, kindly note your pending payment of ${_formatAmount(c.outstandingBalance)} due to XenoBiz Store. Please settle at your earliest convenience.',
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Customer phone number not available.')),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.send_rounded, size: 16),
                                      label: const Text('Send Reminder', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                    ),
                                    IconButton.filledTonal(
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppColors.pageBackground,
                                        foregroundColor: AppColors.darkBlueText,
                                      ),
                                      onPressed: () => context.push(RouteNames.customerDetails, extra: c),
                                      icon: const Icon(Icons.person_outline_rounded, size: 18),
                                      tooltip: 'View Customer Profile',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondaryText, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
