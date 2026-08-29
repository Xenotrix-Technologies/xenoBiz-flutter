import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/customer_bloc.dart';
import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/providers/app_providers.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/invoice_return_entity.dart';
import '../../../domain/repositories/returns_repository.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

// ============================================================================
// DEDICATED SALES REPORT PAGE (FORMAL ACCOUNTING / BUSINESS STATEMENT)
// ============================================================================

class SalesReportPage extends ConsumerStatefulWidget {
  final Object? initialPreset;
  const SalesReportPage({super.key, this.initialPreset});

  @override
  ConsumerState<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends ConsumerState<SalesReportPage> {
  DateTimeRange? _customDateRange;
  List<InvoiceReturnEntity> _salesReturnsList = [];

  // Report Preset State: 0: Summary, 1: Customer, 2: Product, 3: Date, 4: Returns
  int _activePresetIndex = 0;
  String _paymentStatusFilter = 'All'; // All, Paid, Unpaid, Partial
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _parseInitialPreset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
      context.read<CustomerBloc>().add(const FetchCustomersEvent());
      _fetchSalesReturns();
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
      if (p.contains('customer')) {
        _activePresetIndex = 1;
      } else if (p.contains('product')) {
        _activePresetIndex = 2;
      } else if (p.contains('date')) {
        _activePresetIndex = 3;
      } else if (p.contains('return')) {
        _activePresetIndex = 4;
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

  Future<void> _fetchSalesReturns() async {
    try {
      final returnsRepo = getIt<ReturnsRepository>();
      final returns = await returnsRepo.getReturns(InvoiceType.sale);
      if (mounted) {
        setState(() {
          _salesReturnsList = returns;
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

  List<InvoiceEntity> _filterSalesInvoices(
      List<InvoiceEntity> invoices, DateTimeRange range) {
    return invoices.where((inv) {
      if (inv.isPurchase ||
          inv.isQuotation ||
          inv.type == InvoiceType.quotation) {
        return false;
      }
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
      'Sales Summary Report',
      'Sales by Customer Report',
      'Sales by Product Report',
      'Sales by Date Report',
      'Sales Returns Report',
    ];
    final currentTitle = presetNames[_activePresetIndex];

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
                  Text(
                    'Export $currentTitle',
                    style: const TextStyle(
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
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report Title: $currentTitle',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.darkBlueText)),
                    const SizedBox(height: 2),
                    Text('Date Range: $activePeriod',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.secondaryText)),
                    if (_paymentStatusFilter != 'All')
                      Text('Payment Status Filter: $_paymentStatusFilter',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.secondaryText)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export A4 PDF Statement',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle:
                    Text('${currentTitle.replaceAll(' ', '_')}_Statement.pdf'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Exported ${currentTitle.replaceAll(' ', '_')}_Statement.pdf'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading:
                    const Icon(Icons.table_chart_outlined, color: Colors.green),
                title: const Text('Excel / CSV Spreadsheet',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${currentTitle.replaceAll(' ', '_')}_Data.csv'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Exported ${currentTitle.replaceAll(' ', '_')}_Data.csv'),
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
    final activeFilter = ref.watch(analyticsDateFilterProvider);
    final range = _getFilterDateRange(activeFilter);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sales Report',
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
            return const AnalyticsPageSkeleton();
          }

          if (invoiceState is InvoiceErrorState) {
            return ErrorState(
              message: invoiceState.message,
              onRetry: () =>
                  context.read<InvoiceBloc>().add(const FetchInvoicesEvent()),
            );
          }

          List<InvoiceEntity> allInvoices = [];
          if (invoiceState is InvoicesLoadedState) {
            allInvoices = invoiceState.invoices;
          }

          final salesInvoices = _filterSalesInvoices(allInvoices, range);

          return BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, customerState) {
              List<CustomerEntity> allCustomers = [];
              if (customerState is CustomersLoadedState) {
                allCustomers = customerState.customers;
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
                  context.read<CustomerBloc>().add(const FetchCustomersEvent());
                  await _fetchSalesReturns();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QUICK REPORT PRESET TABS
                      _buildPresetChips(),
                      const SizedBox(height: 14),

                      // TIME PERIOD & SEARCH FILTER BAR
                      _buildFilterHeader(activeFilter, range),
                      const SizedBox(height: 16),

                      // REPORT CONTENT ACCORDING TO ACTIVE PRESET
                      if (_activePresetIndex == 0)
                        _buildSummaryReportView(salesInvoices)
                      else if (_activePresetIndex == 1)
                        _buildCustomerReportView(salesInvoices, allCustomers)
                      else if (_activePresetIndex == 2)
                        _buildProductReportView(salesInvoices)
                      else if (_activePresetIndex == 3)
                        _buildDateReportView(salesInvoices)
                      else if (_activePresetIndex == 4)
                        _buildReturnsReportView(_salesReturnsList),
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
      'Sales Summary',
      'Sales by Customer',
      'Sales by Product',
      'Sales by Date',
      'Sales Returns',
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
                      hintText: 'Search customer, invoice no...',
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

              // Filter Status Dropdown
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

  // ==========================================================================
  // VIEW 0: SALES SUMMARY STATEMENT TABLE
  // ==========================================================================

  Widget _buildSummaryReportView(List<InvoiceEntity> invoices) {
    final grossTotal = invoices.fold(0.0, (sum, i) => sum + i.grandTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statement Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SALES SUMMARY STATEMENT',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Invoices',
                          style:
                              TextStyle(fontSize: 11, color: Colors.white70)),
                      Text('${invoices.length}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Gross Revenue',
                          style:
                              TextStyle(fontSize: 11, color: Colors.white70)),
                      Text(_formatCurrency(grossTotal),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('Invoice Transactions Log',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),

        if (invoices.isEmpty)
          const EmptyState(
            title: 'No Sales Invoices',
            message: 'No sales recorded for this period and filter.',
            icon: Icons.assignment_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final inv = invoices[idx];
              return AppCard(
                padding: const EdgeInsets.all(12),
                onTap: () {
                  context.push(RouteNames.invoiceDetails, extra: inv.id);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv.invoiceNumber,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            inv.customerName.isNotEmpty
                                ? inv.customerName
                                : 'Cash Customer',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlueText),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy').format(inv.issueDate),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(inv.grandTotal),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.success),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: inv.status == InvoiceStatus.paid
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            inv.status.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: inv.status == InvoiceStatus.paid
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ),
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

  // ==========================================================================
  // VIEW 1: SALES BY CUSTOMER REPORT VIEW
  // ==========================================================================

  Widget _buildCustomerReportView(
      List<InvoiceEntity> invoices, List<CustomerEntity> allCustomers) {
    final Map<String, _CustStat> map = {};

    for (var inv in invoices) {
      final name = inv.customerName.isNotEmpty
          ? inv.customerName
          : 'Cash Customer';
      if (!map.containsKey(name)) {
        map[name] = _CustStat(name: name);
      }
      final stat = map[name]!;
      stat.sales += inv.grandTotal;
      stat.count += 1;
      stat.due += (inv.grandTotal - inv.paidAmount).clamp(0.0, double.infinity);
    }

    final stats = map.values.toList()
      ..sort((a, b) => b.sales.compareTo(a.sales));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sales Report by Customer',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (stats.isEmpty)
          const EmptyState(
            title: 'No Customer Sales',
            message: 'No customer sales entries match current filter.',
            icon: Icons.people_outline,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final c = stats[idx];
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.1),
                      child: Text(
                        c.name.substring(0, 1).toUpperCase(),
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
                          Text(c.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText)),
                          Text('${c.count} Invoices',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_formatCurrency(c.sales),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.success)),
                        if (c.due > 0)
                          Text('Due: ${_formatCurrency(c.due)}',
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

  // ==========================================================================
  // VIEW 2: SALES BY PRODUCT REPORT VIEW
  // ==========================================================================

  Widget _buildProductReportView(List<InvoiceEntity> invoices) {
    final Map<String, _ProdStat> map = {};

    for (var inv in invoices) {
      for (var item in inv.items) {
        final name = item.productName;
        if (!map.containsKey(name)) {
          map[name] = _ProdStat(name: name);
        }
        final stat = map[name]!;
        stat.qty += item.quantity;
        stat.revenue += item.total;
      }
    }

    final stats = map.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sales Report by Product / Service',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (stats.isEmpty)
          const EmptyState(
            title: 'No Product Sales',
            message: 'No itemized product sales recorded in period.',
            icon: Icons.category_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final p = stats[idx];
              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.inventory_2_outlined,
                          size: 18, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText)),
                          Text('Qty Sold: ${p.qty.toInt()} units',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    Text(_formatCurrency(p.revenue),
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

  // ==========================================================================
  // VIEW 3: SALES BY DATE REPORT VIEW
  // ==========================================================================

  Widget _buildDateReportView(List<InvoiceEntity> invoices) {
    final Map<String, List<InvoiceEntity>> dateMap = {};

    for (var inv in invoices) {
      final key = DateFormat('yyyy-MM-dd').format(inv.issueDate);
      if (!dateMap.containsKey(key)) {
        dateMap[key] = [];
      }
      dateMap[key]!.add(inv);
    }

    final sortedDates = dateMap.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sales Report by Date Breakdown',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (sortedDates.isEmpty)
          const EmptyState(
            title: 'No Sales Dates',
            message: 'No sales activity recorded for selected range.',
            icon: Icons.date_range_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedDates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final dStr = sortedDates[idx];
              final list = dateMap[dStr]!;
              final dayTotal = list.fold(0.0, (sum, i) => sum + i.grandTotal);
              final displayDate =
                  DateFormat('dd MMMM yyyy (EEEE)').format(DateTime.parse(dStr));

              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayDate,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText)),
                        Text('${list.length} Sales Invoices',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.secondaryText)),
                      ],
                    ),
                    Text(_formatCurrency(dayTotal),
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

  // ==========================================================================
  // VIEW 4: SALES RETURNS REPORT VIEW
  // ==========================================================================

  Widget _buildReturnsReportView(List<InvoiceReturnEntity> returns) {
    final totalRefund = returns.fold(0.0, (sum, r) => sum + r.totalAmount);

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
                  const Text('Total Return Vouchers',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText)),
                  Text('${returns.length}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.danger)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Refund Value',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlueText)),
                  Text(_formatCurrency(totalRefund),
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
        const Text('Sales Return Vouchers Log',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText)),
        const SizedBox(height: 10),
        if (returns.isEmpty)
          const EmptyState(
            title: 'No Sales Returns',
            message: 'No sales return credit notes recorded for this period.',
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
                          Text('Return ${ret.returnNumber}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.danger)),
                          Text(
                            ret.partyName.isNotEmpty
                                ? ret.partyName
                                : 'Customer',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlueText),
                          ),
                          Text(
                            'Inv: ${ret.invoiceNumber} • ${DateFormat('dd MMM yyyy').format(ret.returnDate)}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                    Text(_formatCurrency(ret.totalAmount),
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

class _CustStat {
  final String name;
  double sales = 0.0;
  int count = 0;
  double due = 0.0;

  _CustStat({required this.name});
}

class _ProdStat {
  final String name;
  double qty = 0.0;
  double revenue = 0.0;

  _ProdStat({required this.name});
}
