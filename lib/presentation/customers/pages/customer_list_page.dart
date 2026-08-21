import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/customer_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/crm_entities.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/repositories/invoice_repository.dart';
import '../../../infrastructure/services/crm_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _searchController = TextEditingController();
  CustomerSegment _selectedSegment = CustomerSegment.all;
  String _sortBy = 'Name A-Z'; // 'Name A-Z', 'Highest Purchases', 'Highest Outstanding'

  Map<String, List<InvoiceEntity>> _customerInvoicesMap = {};
  bool _isLoadingInvoices = true;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const FetchCustomersEvent());
    _loadAllInvoices();
  }

  Future<void> _loadAllInvoices() async {
    try {
      final invRepo = getIt<InvoiceRepository>();
      final allInvoices = await invRepo.getInvoices();
      final Map<String, List<InvoiceEntity>> map = {};
      for (var inv in allInvoices) {
        map.putIfAbsent(inv.customerId, () => []).add(inv);
      }
      if (mounted) {
        setState(() {
          _customerInvoicesMap = map;
          _isLoadingInvoices = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingInvoices = false);
    }
  }

  void _showAddCustomerDialog() {
    context.push(RouteNames.createMaster, extra: 1);
  }

  String _formatAmount(double amt) {
    return '₹${amt.toStringAsFixed(0)}';
  }

  List<CustomerEntity> _filterAndSortCustomers(List<CustomerEntity> list) {
    final query = _searchController.text.trim().toLowerCase();

    var filtered = list.where((c) {
      // 1. Query Filter
      if (query.isNotEmpty) {
        final match = c.name.toLowerCase().contains(query) ||
            c.phone.toLowerCase().contains(query) ||
            c.email.toLowerCase().contains(query) ||
            c.id.toLowerCase().contains(query);
        if (!match) return false;
      }

      // 2. Segment Filter
      if (_selectedSegment != CustomerSegment.all) {
        final invs = _customerInvoicesMap[c.id] ?? [];
        final seg = CustomerSegmentation.calculateSegment(c, invs);
        if (_selectedSegment == CustomerSegment.outstanding) {
          if (c.outstandingBalance <= 0) return false;
        } else if (seg != _selectedSegment) {
          return false;
        }
      }

      return true;
    }).toList();

    // 3. Sorting
    if (_sortBy == 'Highest Purchases') {
      filtered.sort((a, b) => b.totalPurchases.compareTo(a.totalPurchases));
    } else if (_sortBy == 'Highest Outstanding') {
      filtered.sort((a, b) => b.outstandingBalance.compareTo(a.outstandingBalance));
    } else {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.customerTitle,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort Customers',
            onSelected: (val) {
              setState(() => _sortBy = val);
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'Name A-Z', child: Text('Sort by Name A-Z')),
              const PopupMenuItem(value: 'Highest Purchases', child: Text('Sort by Highest Purchases')),
              const PopupMenuItem(value: 'Highest Outstanding', child: Text('Sort by Highest Outstanding')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: _showAddCustomerDialog,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Customer', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search customer by name, phone, or email...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),

                // Segment Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: CustomerSegment.values.map((seg) {
                      final isSelected = _selectedSegment == seg;
                      final label = CustomerSegmentation.getLabel(seg);
                      final color = CustomerSegmentation.getColor(seg);

                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          selected: isSelected,
                          showCheckmark: false,
                          label: Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : color,
                            ),
                          ),
                          backgroundColor: color.withValues(alpha: 0.1),
                          selectedColor: color,
                          side: BorderSide(color: color.withValues(alpha: 0.3)),
                          onSelected: (_) {
                            setState(() => _selectedSegment = seg);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoadingState || _isLoadingInvoices) {
                  return const CustomerListSkeleton();
                }

                if (state is CustomersLoadedState) {
                  final filteredList = _filterAndSortCustomers(state.customers);

                  if (filteredList.isEmpty) {
                    return const EmptyState(
                      title: 'No Customers Found',
                      message: 'No customer accounts match your current search and filter criteria.',
                      icon: Icons.person_search_rounded,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final c = filteredList[idx];
                      final invoices = _customerInvoicesMap[c.id] ?? [];
                      final invoiceCount = invoices.length;
                      final totalSpent = c.totalPurchases > 0 ? c.totalPurchases : invoices.fold(0.0, (sum, i) => sum + i.grandTotal);
                      final segment = CustomerSegmentation.calculateSegment(c, invoices);
                      final segmentLabel = CustomerSegmentation.getLabel(segment);
                      final segmentColor = CustomerSegmentation.getColor(segment);
                      final segmentBg = CustomerSegmentation.getBgColor(segment);
                      final lastInvDate = invoices.isNotEmpty ? DateFormat('dd MMM').format(invoices.first.issueDate) : '';

                      return AppCard(
                        onTap: () {
                          context.push(RouteNames.customerDetails, extra: c);
                        },
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: segmentBg,
                                  child: Text(
                                    c.name.isNotEmpty ? c.name.substring(0, 1).toUpperCase() : 'C',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: segmentColor),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c.name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.darkBlueText,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: segmentBg,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: segmentColor.withValues(alpha: 0.3)),
                                            ),
                                            child: Text(
                                              segmentLabel,
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: segmentColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${c.phone.isNotEmpty ? c.phone : 'No phone'} ${c.email.isNotEmpty ? "• ${c.email}" : ""}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Purchases', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                                    const SizedBox(height: 2),
                                    Text(_formatAmount(totalSpent), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Invoices', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                                    const SizedBox(height: 2),
                                    Text('$invoiceCount ${lastInvDate.isNotEmpty ? "($lastInvDate)" : ""}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Outstanding', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatAmount(c.outstandingBalance),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: c.outstandingBalance > 0 ? AppColors.danger : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            if (c.phone.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () => CrmService.makePhoneCall(c.phone),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.phone_outlined, size: 14, color: AppColors.primaryBlue),
                                          SizedBox(width: 4),
                                          Text('Call', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => CrmService.openWhatsApp(c.phone),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF25D366).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF128C7E)),
                                          SizedBox(width: 4),
                                          Text('WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF128C7E))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
