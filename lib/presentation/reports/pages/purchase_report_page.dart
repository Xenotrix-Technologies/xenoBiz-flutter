import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/bloc/purchase_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/providers/app_providers.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/invoice_return_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../../domain/repositories/returns_repository.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';
import '../widgets/report_export_sheet.dart';

// ============================================================================
// DEDICATED PURCHASE REPORT PAGE (FORMAL ACCOUNTING STATEMENT)
// ============================================================================

class PurchaseReportPage extends ConsumerStatefulWidget {
  final Object? initialPreset;
  const PurchaseReportPage({super.key, this.initialPreset});

  @override
  ConsumerState<PurchaseReportPage> createState() => _PurchaseReportPageState();
}

class _PurchaseReportPageState extends ConsumerState<PurchaseReportPage> {
  DateTimeRange? _customDateRange;
  List<InvoiceReturnEntity> _purchaseReturnsList = [];

  // Preset State: 0: Purchase Summary, 1: Purchase by Supplier, 2: Purchase Returns, 3: Outstanding Payables
  int _activePresetIndex = 0;
  String _paymentStatusFilter = 'All'; // All, Paid, Unpaid, Partial
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _parseInitialPreset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
      context.read<PurchaseBloc>().add(const FetchSuppliersEvent());
      _fetchPurchaseReturns();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _parseInitialPreset() {
    if (widget.initialPreset is int) {
      _activePresetIndex = widget.initialPreset as int;
    } else if (widget.initialPreset is Map &&
        (widget.initialPreset as Map).containsKey('preset')) {
      _activePresetIndex = (widget.initialPreset as Map)['preset'] as int;
    } else if (widget.initialPreset is String) {
      final p = (widget.initialPreset as String).toLowerCase();
      if (p.contains('supplier')) {
        _activePresetIndex = 1;
      } else if (p.contains('return')) {
        _activePresetIndex = 2;
      } else if (p.contains('payable')) {
        _activePresetIndex = 3;
      } else {
        _activePresetIndex = 0;
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _activePresetIndex = 0;
      _paymentStatusFilter = 'All';
      _searchCtrl.clear();
      _customDateRange = null;
    });
    ref.read(analyticsDateFilterProvider.notifier).state = 'This Month';
  }

  Future<void> _fetchPurchaseReturns() async {
    try {
      final returnsRepo = getIt<ReturnsRepository>();
      final returns = await returnsRepo.getReturns(InvoiceType.purchase);
      if (mounted) {
        setState(() {
          _purchaseReturnsList = returns;
        });
      }
    } catch (_) {}
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkBlueText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
      });
      ref.read(analyticsDateFilterProvider.notifier).state = 'Custom Range';
    }
  }

  DateTimeRange _getFilterDateRange(String filter) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (filter) {
      case 'Today':
        return DateTimeRange(start: todayStart, end: todayEnd);
      case 'This Week':
        final monday =
            todayStart.subtract(Duration(days: todayStart.weekday - 1));
        return DateTimeRange(start: monday, end: todayEnd);
      case 'This Month':
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: monthStart, end: monthEnd);
      case 'This Quarter':
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final quarterStartMonth = (currentQuarter - 1) * 3 + 1;
        final quarterStart = DateTime(now.year, quarterStartMonth, 1);
        final quarterEndMonth = quarterStartMonth + 2;
        final quarterEnd =
            DateTime(now.year, quarterEndMonth + 1, 0, 23, 59, 59);
        return DateTimeRange(start: quarterStart, end: quarterEnd);
      case 'Last Month':
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateTimeRange(start: lastMonthStart, end: lastMonthEnd);
      case 'This Year':
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: yearStart, end: yearEnd);
      case 'Custom Range':
        if (_customDateRange != null) {
          final s = _customDateRange!.start;
          final e = _customDateRange!.end;
          return DateTimeRange(
            start: DateTime(s.year, s.month, s.day),
            end: DateTime(e.year, e.month, e.day, 23, 59, 59),
          );
        }
        final monthStart = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: monthStart, end: todayEnd);
      default:
        final monthStart = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: monthStart, end: todayEnd);
    }
  }

  List<InvoiceEntity> _filterPurchaseInvoices(
      List<InvoiceEntity> invoices, DateTimeRange range) {
    return invoices.where((inv) {
      if (!inv.isPurchase) return false;
      final dateMatch = inv.issueDate
              .isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          inv.issueDate.isBefore(range.end.add(const Duration(seconds: 1)));
      if (!dateMatch) return false;

      if (_paymentStatusFilter == 'Paid' && inv.status != InvoiceStatus.paid) {
        return false;
      }
      if (_paymentStatusFilter == 'Unpaid' &&
          inv.status != InvoiceStatus.unpaid) {
        return false;
      }
      if (_paymentStatusFilter == 'Partial' &&
          inv.status != InvoiceStatus.partiallyPaid) {
        return false;
      }

      final query = _searchCtrl.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final matchesName = inv.customerName.toLowerCase().contains(query);
        final matchesNumber = inv.invoiceNumber.toLowerCase().contains(query);
        if (!matchesName && !matchesNumber) return false;
      }

      return true;
    }).toList();
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _exportReportPdf(BuildContext context, String activePeriod) {
    final presetNames = [
      'Purchase Summary Report',
      'Purchase by Supplier Report',
      'Purchase Returns Report',
      'Outstanding Payables Report',
    ];
    final currentTitle = presetNames[_activePresetIndex];
    showReportPdfExportModal(
      context,
      reportTitle: currentTitle,
      period: activePeriod,
      filterSummary: _paymentStatusFilter != 'All' ? 'Payment Status: $_paymentStatusFilter' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(analyticsDateFilterProvider);
    final range = _getFilterDateRange(activeFilter);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Purchase Report',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Export Report',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportReportPdf(context, activeFilter),
          ),
          IconButton(
            tooltip: 'Reset Filters',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, invoiceState) {
          if (invoiceState is InvoiceLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          List<InvoiceEntity> allInvoices = [];
          if (invoiceState is InvoicesLoadedState) {
            allInvoices = invoiceState.invoices;
          }

          final purchases = _filterPurchaseInvoices(allInvoices, range);

          return BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, purchaseState) {
              List<SupplierEntity> allSuppliers = [];
              if (purchaseState is PurchaseLoadedState) {
                allSuppliers = purchaseState.suppliers;
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
                  context.read<PurchaseBloc>().add(const FetchSuppliersEvent());
                  await _fetchPurchaseReturns();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPresetChips(),
                      const SizedBox(height: 14),
                      _buildFilterHeader(activeFilter, range),
                      const SizedBox(height: 16),

                      if (_activePresetIndex == 0)
                        _buildPurchaseSummaryView(purchases)
                      else if (_activePresetIndex == 1)
                        _buildSupplierReportView(purchases, allSuppliers)
                      else if (_activePresetIndex == 2)
                        _buildReturnsReportView(_purchaseReturnsList)
                      else if (_activePresetIndex == 3)
                        _buildPayablesReportView(purchases, allSuppliers),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPresetChips() {
    final presets = [
      'Purchase Summary',
      'Purchase by Supplier',
      'Purchase Returns',
      'Outstanding Payables',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: presets.asMap().entries.map((entry) {
          final idx = entry.key;
          final label = entry.value;
          final selected = _activePresetIndex == idx;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              selectedColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.darkBlueText,
              ),
              onSelected: (val) {
                if (val) setState(() => _activePresetIndex = idx);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterHeader(String activeFilter, DateTimeRange range) {
    final filters = [
      'Today',
      'This Week',
      'This Month',
      'This Quarter',
      'Last Month',
      'This Year',
      'Custom Range'
    ];

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pageBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search supplier, bill no...',
                      hintStyle: TextStyle(
                          fontSize: 12, color: AppColors.secondaryText),
                      prefixIcon: Icon(Icons.search,
                          size: 18, color: AppColors.secondaryText),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _paymentStatusFilter,
                    icon: const Icon(Icons.filter_list,
                        size: 18, color: AppColors.primaryBlue),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlueText),
                    items: ['All', 'Paid', 'Unpaid', 'Partial']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentStatusFilter = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((f) {
                final isSelected = activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(f, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.pageBackground,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkBlueText,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (val) {
                      if (val) {
                        if (f == 'Custom Range') {
                          _selectCustomDateRange(context);
                        } else {
                          ref
                              .read(analyticsDateFilterProvider.notifier)
                              .state = f;
                        }
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseSummaryView(List<InvoiceEntity> purchases) {
    final totalExpense = purchases.fold(0.0, (sum, p) => sum + p.grandTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Purchase Bills',
                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                  Text('${purchases.length}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Procurement Cost',
                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                  Text(_formatCurrency(totalExpense),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Purchase Transactions Log',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (purchases.isEmpty)
          const EmptyState(
            title: 'No Purchase Bills',
            message: 'No purchase bills match current period & filter.',
            icon: Icons.shopping_bag_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: purchases.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final p = purchases[idx];
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.invoiceNumber,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryBlue)),
                          Text(
                              p.customerName.isNotEmpty
                                  ? p.customerName
                                  : 'Supplier',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkBlueText)),
                          Text(DateFormat('dd MMM yyyy').format(p.issueDate),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    Text(_formatCurrency(p.grandTotal),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkBlueText)),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSupplierReportView(
      List<InvoiceEntity> purchases, List<SupplierEntity> suppliers) {
    final Map<String, _SupStat> map = {};

    for (var p in purchases) {
      final name = p.customerName.isNotEmpty ? p.customerName : 'Supplier';
      if (!map.containsKey(name)) {
        map[name] = _SupStat(name: name);
      }
      final stat = map[name]!;
      stat.total += p.grandTotal;
      stat.count += 1;
      stat.due += (p.grandTotal - p.paidAmount).clamp(0.0, double.infinity);
    }

    final stats = map.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Purchase Report by Supplier',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (stats.isEmpty)
          const EmptyState(
            title: 'No Supplier Purchases',
            message: 'No supplier purchase records for this period.',
            icon: Icons.local_shipping_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final s = stats[idx];
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.1),
                      child: Text(
                        s.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText)),
                          Text('${s.count} Bills',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_formatCurrency(s.total),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkBlueText)),
                        if (s.due > 0)
                          Text('Due: ${_formatCurrency(s.due)}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildReturnsReportView(List<InvoiceReturnEntity> returns) {
    final totalRefund = returns.fold(0.0, (sum, r) => sum + r.totalAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Debit Notes',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText)),
                  Text('${returns.length}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Return Debit Value',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText)),
                  Text(_formatCurrency(totalRefund),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Purchase Return Debit Notes Log',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (returns.isEmpty)
          const EmptyState(
            title: 'No Purchase Returns',
            message: 'No purchase debit note vouchers recorded.',
            icon: Icons.assignment_return_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: returns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final ret = returns[idx];
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Debit Note ${ret.returnNumber}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.success)),
                          Text(ret.partyName.isNotEmpty ? ret.partyName : 'Supplier',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkBlueText)),
                        ],
                      ),
                    ),
                    Text(_formatCurrency(ret.totalAmount),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.success)),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPayablesReportView(
      List<InvoiceEntity> purchases, List<SupplierEntity> suppliers) {
    final unpaid = purchases.where((p) => p.status != InvoiceStatus.paid).toList();
    final totalPayable = unpaid.fold(0.0, (sum, p) => sum + (p.grandTotal - p.paidAmount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pending Payables Bills',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText)),
                  Text('${unpaid.length}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.danger)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Outstanding Due',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText)),
                  Text(_formatCurrency(totalPayable),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.danger)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Outstanding Supplier Payables Statement',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (unpaid.isEmpty)
          const EmptyState(
            title: 'No Outstanding Payables',
            message: 'All purchase bills are fully paid.',
            icon: Icons.check_circle_outline,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: unpaid.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final p = unpaid[idx];
              final due = (p.grandTotal - p.paidAmount).clamp(0.0, double.infinity);
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.invoiceNumber,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryBlue)),
                          Text(p.customerName.isNotEmpty ? p.customerName : 'Supplier',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkBlueText)),
                          Text('Due Date: ${DateFormat('dd MMM yyyy').format(p.dueDate)}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.danger)),
                        ],
                      ),
                    ),
                    Text(_formatCurrency(due),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.danger)),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SupStat {
  final String name;
  double total = 0.0;
  int count = 0;
  double due = 0.0;

  _SupStat({required this.name});
}
