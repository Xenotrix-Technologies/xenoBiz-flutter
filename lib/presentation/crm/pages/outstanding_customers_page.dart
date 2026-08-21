import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/crm_customer_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/crm_customer_entity.dart';
import '../../../infrastructure/services/crm_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';
import '../widgets/add_crm_customer_dialog.dart';

class OutstandingCustomersPage extends StatefulWidget {
  const OutstandingCustomersPage({super.key});

  @override
  State<OutstandingCustomersPage> createState() => _OutstandingCustomersPageState();
}

class _OutstandingCustomersPageState extends State<OutstandingCustomersPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _onSearchChanged(String query) {
    context.read<CrmCustomerBloc>().add(FetchCrmCustomersEvent(query: query));
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _isSearching = false);
    context.read<CrmCustomerBloc>().add(const FetchCrmCustomersEvent(query: ''));
  }

  void _confirmDelete(BuildContext context, CrmCustomerEntity customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete CRM Customer',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
        ),
        content: Text(
          'Are you sure you want to delete "${customer.name}"? This action cannot be undone.',
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
              context.read<CrmCustomerBloc>().add(DeleteCrmCustomerEvent(customer.id));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Customer "${customer.name}" deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Search by name, company or phone...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : const Text(
                'CRM Customers & Contacts',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _clearSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search Customers',
              onPressed: () {
                setState(() => _isSearching = true);
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Customers',
            onPressed: () {
              context.read<CrmCustomerBloc>().add(
                    FetchCrmCustomersEvent(query: _searchController.text.trim()),
                  );
            },
          ),
        ],
      ),
      body: BlocBuilder<CrmCustomerBloc, CrmCustomerState>(
        builder: (context, state) {
          if (state is CrmCustomerLoadingState) {
            return const LoadingState(message: 'Loading customers...');
          }

          if (state is CrmCustomerErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
                  const SizedBox(height: 12),
                  Text('Failed to load customers: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CrmCustomerBloc>().add(const FetchCrmCustomersEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final loadedState = state is CrmCustomersLoadedState ? state : const CrmCustomersLoadedState([]);
          final customers = loadedState.customers;
          final searchQuery = loadedState.query;

          // Calculate Metrics
          final totalCount = customers.length;
          final activeCount = customers.where((c) => c.status.toLowerCase() == 'active').length;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CrmCustomerBloc>().add(
                    FetchCrmCustomersEvent(query: searchQuery),
                  );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. IMPROVED CUSTOMER STATISTICS (2 Cards Only)
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'TOTAL CUSTOMERS',
                          value: '$totalCount',
                          subtitle: 'Registered CRM records',
                          color: AppColors.primaryBlue,
                          icon: Icons.people_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'ACTIVE CUSTOMERS',
                          value: '$activeCount',
                          subtitle: 'Active engagement',
                          color: AppColors.success,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. DIRECTORY SECTION HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CRM CUSTOMER DIRECTORY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryText,
                          letterSpacing: 0.6,
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        Text(
                          '${customers.length} found',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. CUSTOMER DIRECTORY LIST
                  if (customers.isEmpty)
                    if (searchQuery.isNotEmpty)
                      EmptyState(
                        title: 'No customers found',
                        message: 'No CRM customers match "$searchQuery".',
                        icon: Icons.search_off_rounded,
                      )
                    else
                      EmptyState(
                        title: 'No customers yet',
                        message: 'Customers created from won leads will appear here.',
                        icon: Icons.people_outline_rounded,
                        actionText: 'View Leads',
                        onAction: () => context.go(RouteNames.leadPipeline),
                      )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: customers.length,
                      itemBuilder: (context, idx) {
                        final c = customers[idx];
                        final initials = _getInitials(c.name);

                        Color statusColor = AppColors.primaryBlue;
                        final st = c.status.toLowerCase();
                        if (st == 'active') statusColor = AppColors.success;
                        if (st == 'lead') statusColor = const Color(0xFF8B5CF6);
                        if (st == 'contacted') statusColor = const Color(0xFFD97706);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            padding: EdgeInsets.zero,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              onTap: () {
                                context.push(RouteNames.crmCustomerDetails, extra: c);
                              },
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor: statusColor.withValues(alpha: 0.14),
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              title: Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText,
                                ),
                              ),
                              subtitle: c.companyName.isNotEmpty
                                  ? Text(
                                      c.companyName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryText,
                                      ),
                                    )
                                  : null,
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: AppColors.secondaryText,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) async {
                                  switch (value) {
                                    case 'view':
                                      context.push(RouteNames.crmCustomerDetails, extra: c);
                                      break;
                                    case 'edit':
                                      final updated = await showAddCrmCustomerDialog(context);
                                      if (updated != null && context.mounted) {
                                        context.read<CrmCustomerBloc>().add(UpdateCrmCustomerEvent(updated));
                                      }
                                      break;
                                    case 'call':
                                      if (c.phone.isNotEmpty) {
                                        CrmService.makePhoneCall(c.phone);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('No phone number available.')),
                                        );
                                      }
                                      break;
                                    case 'whatsapp':
                                      if (c.phone.isNotEmpty) {
                                        CrmService.openWhatsApp(
                                          c.phone,
                                          text: 'Hello ${c.name}, following up from XenoBiz CRM.',
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('No phone number available.')),
                                        );
                                      }
                                      break;
                                    case 'delete':
                                      _confirmDelete(context, c);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility_outlined, size: 18, color: AppColors.primaryBlue),
                                        SizedBox(width: 10),
                                        Text('View Customer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18, color: AppColors.darkBlueText),
                                        SizedBox(width: 10),
                                        Text('Edit Customer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  if (c.phone.isNotEmpty) ...[
                                    const PopupMenuItem(
                                      value: 'call',
                                      child: Row(
                                        children: [
                                          Icon(Icons.phone_outlined, size: 18, color: AppColors.primaryBlue),
                                          SizedBox(width: 10),
                                          Text('Call Phone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'whatsapp',
                                      child: Row(
                                        children: [
                                          Icon(Icons.send_rounded, size: 18, color: Color(0xFF128C7E)),
                                          SizedBox(width: 10),
                                          Text('Send WhatsApp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                                        SizedBox(width: 10),
                                        Text('Delete Customer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.danger)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
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
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondaryText,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
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
