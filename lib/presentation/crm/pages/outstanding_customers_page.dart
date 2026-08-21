import 'package:flutter/material.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/crm_customer_entity.dart';
import '../../../domain/repositories/crm_customer_repository.dart';
import '../../../infrastructure/services/crm_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class OutstandingCustomersPage extends StatefulWidget {
  const OutstandingCustomersPage({super.key});

  @override
  State<OutstandingCustomersPage> createState() => _OutstandingCustomersPageState();
}

class _OutstandingCustomersPageState extends State<OutstandingCustomersPage> {
  List<CrmCustomerEntity> _crmCustomers = [];
  bool _isLoading = true;
  int _activeCount = 0;
  int _leadCount = 0;
  int _contactedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCrmCustomerData();
  }

  Future<void> _loadCrmCustomerData() async {
    setState(() => _isLoading = true);

    try {
      final repo = getIt<CrmCustomerRepository>();
      final customers = await repo.getCrmCustomers();

      int active = 0;
      int leads = 0;
      int contacted = 0;

      for (var c in customers) {
        final st = c.status.toLowerCase();
        if (st == 'active') active++;
        if (st == 'lead') leads++;
        if (st == 'contacted') contacted++;
      }

      if (mounted) {
        setState(() {
          _crmCustomers = customers;
          _activeCount = active;
          _leadCount = leads;
          _contactedCount = contacted;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'CRM Customers & Contacts',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadCrmCustomerData,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState(message: 'Loading CRM customer accounts...')
          : RefreshIndicator(
              onRefresh: _loadCrmCustomerData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. CRM CUSTOMER SUMMARY METRICS GRID
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'TOTAL CRM CUSTOMERS',
                            value: '${_crmCustomers.length}',
                            subtitle: 'Registered CRM records',
                            color: AppColors.primaryBlue,
                            icon: Icons.people_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            title: 'ACTIVE CUSTOMERS',
                            value: '$_activeCount',
                            subtitle: 'Active engagement',
                            color: AppColors.success,
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'CONTACTED',
                            value: '$_contactedCount',
                            subtitle: 'In communication',
                            color: const Color(0xFFD97706),
                            icon: Icons.phone_in_talk_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            title: 'LEADS',
                            value: '$_leadCount',
                            subtitle: 'Potential prospects',
                            color: const Color(0xFF8B5CF6),
                            icon: Icons.person_search_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'CRM CUSTOMER DIRECTORY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryText,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (_crmCustomers.isEmpty)
                      const EmptyState(
                        title: 'No CRM Customers Yet',
                        message: 'Add customers in CRM to manage relationships and follow-ups.',
                        icon: Icons.people_outline_rounded,
                      )
                    else
                      ...List.generate(_crmCustomers.length, (idx) {
                        final c = _crmCustomers[idx];

                        Color statusColor = AppColors.primaryBlue;
                        if (c.status.toLowerCase() == 'active') statusColor = AppColors.success;
                        if (c.status.toLowerCase() == 'lead') statusColor = const Color(0xFF8B5CF6);
                        if (c.status.toLowerCase() == 'contacted') statusColor = const Color(0xFFD97706);

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
                                            c.companyName.isNotEmpty ? c.companyName : 'Source: ${c.source}',
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
                                        c.status.toUpperCase(),
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                                if (c.notes.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.pageBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      c.notes,
                                      style: const TextStyle(fontSize: 12, color: AppColors.darkBlueText),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 14),
                                const Divider(height: 1),
                                const SizedBox(height: 12),

                                // Action Buttons
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (c.phone.isNotEmpty)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryBlue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () => CrmService.makePhoneCall(c.phone),
                                        icon: const Icon(Icons.phone_rounded, size: 16),
                                        label: const Text('Call', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                      ),
                                    if (c.phone.isNotEmpty)
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF128C7E),
                                          side: const BorderSide(color: Color(0xFF25D366)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () => CrmService.openWhatsApp(c.phone, text: 'Hello ${c.name}, following up from XenoBiz CRM.'),
                                        icon: const Icon(Icons.send_rounded, size: 16),
                                        label: const Text('WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
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
