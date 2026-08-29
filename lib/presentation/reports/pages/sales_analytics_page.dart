import 'package:fl_chart/fl_chart.dart';
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

class SalesAnalyticsPage extends ConsumerStatefulWidget {
  const SalesAnalyticsPage({super.key});

  @override
  ConsumerState<SalesAnalyticsPage> createState() => _SalesAnalyticsPageState();
}

class _SalesAnalyticsPageState extends ConsumerState<SalesAnalyticsPage> {
  DateTimeRange? _customDateRange;
  List<InvoiceReturnEntity> _salesReturnsList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
      context.read<CustomerBloc>().add(const FetchCustomersEvent());
      _fetchSalesReturns();
    });
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
        final monday = todayStart.subtract(Duration(days: todayStart.weekday - 1));
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
        final quarterEnd = DateTime(now.year, quarterEndMonth + 1, 0, 23, 59, 59);
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

  // Requirement 1 & 2: Filter STRICTLY completed Sales Invoices ONLY (No Quotations, No Purchases)
  List<InvoiceEntity> _filterSalesInvoices(List<InvoiceEntity> invoices, DateTimeRange range) {
    return invoices.where((inv) {
      if (inv.isPurchase || inv.isQuotation || inv.type == InvoiceType.quotation) {
        return false;
      }
      return inv.issueDate.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          inv.issueDate.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();
  }

  List<InvoiceReturnEntity> _filterSalesReturns(List<InvoiceReturnEntity> returns, DateTimeRange range) {
    return returns.where((ret) {
      return ret.returnDate.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          ret.returnDate.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(analyticsDateFilterProvider);
    final range = _getFilterDateRange(activeFilter);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sales Analytics',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, invoiceState) {
          if (invoiceState is InvoiceLoadingState) {
            return const AnalyticsPageSkeleton();
          }

          if (invoiceState is InvoiceErrorState) {
            return ErrorState(
              message: invoiceState.message,
              onRetry: () => context.read<InvoiceBloc>().add(const FetchInvoicesEvent()),
            );
          }

          List<InvoiceEntity> allInvoices = [];
          if (invoiceState is InvoicesLoadedState) {
            allInvoices = invoiceState.invoices;
          }

          final salesInvoices = _filterSalesInvoices(allInvoices, range);
          final periodReturns = _filterSalesReturns(_salesReturnsList, range);

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
                      // 1. TIME PERIOD SELECTOR
                      _buildPeriodSelector(activeFilter, range),
                      const SizedBox(height: 16),

                      // SECTION 1: SALES PERFORMANCE
                      _buildSectionHeader('SALES PERFORMANCE', Icons.trending_up_rounded),
                      const SizedBox(height: 12),

                      _buildSalesPerformanceCards(salesInvoices, periodReturns, activeFilter),
                      const SizedBox(height: 16),

                      // SALES OVERVIEW CHART
                      _buildSalesChartCard(salesInvoices, activeFilter, range),
                      const SizedBox(height: 16),

                      // GROSS & NET SALES SUMMARY CARD
                      _buildGrossNetSummaryCard(salesInvoices, periodReturns),
                      const SizedBox(height: 24),

                      // SECTION 2: CUSTOMER PERFORMANCE
                      _buildSectionHeader('CUSTOMER PERFORMANCE', Icons.people_alt_rounded),
                      const SizedBox(height: 12),

                      _buildCustomerPerformanceSection(
                        salesInvoices: salesInvoices,
                        allCustomers: allCustomers,
                        range: range,
                      ),
                      const SizedBox(height: 24),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppColors.darkBlueText,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 1. PERIOD SELECTOR WIDGET
  // ===========================================================================
  Widget _buildPeriodSelector(String activeFilter, DateTimeRange range) {
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    'Time Period',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                ],
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: filters.contains(activeFilter) ? activeFilter : 'This Month',
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                  ),
                  items: filters.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (val) {
                    if (val == 'Custom Range') {
                      _selectCustomDateRange(context);
                    } else if (val != null) {
                      ref.read(analyticsDateFilterProvider.notifier).state = val;
                    }
                  },
                ),
              ),
            ],
          ),
          if (activeFilter == 'Custom Range' && _customDateRange != null) ...[
            const Divider(height: 12),
            InkWell(
              onTap: () => _selectCustomDateRange(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondaryText),
                    ),
                    const Icon(Icons.edit_calendar_rounded, size: 14, color: AppColors.primaryBlue),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. SALES PERFORMANCE CARDS
  // ===========================================================================
  Widget _buildSalesPerformanceCards(
    List<InvoiceEntity> salesInvoices,
    List<InvoiceReturnEntity> salesReturns,
    String activeFilter,
  ) {
    final double totalSales = salesInvoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
    final int invoiceCount = salesInvoices.length;
    final double avgInvoiceValue = invoiceCount > 0 ? (totalSales / invoiceCount) : 0.0;
    final double totalGst = salesInvoices.fold(0.0, (sum, inv) => sum + (inv.gstEnabled ? inv.taxTotal : 0.0));
    final double totalDiscount = salesInvoices.fold(0.0, (sum, inv) => sum + inv.discountTotal);
    final double totalPaid = salesInvoices.fold(0.0, (sum, inv) => sum + inv.paidAmount);
    final double totalDue = salesInvoices.fold(
        0.0, (sum, inv) => sum + (inv.grandTotal - inv.paidAmount).clamp(0.0, double.infinity));
    final double totalSalesReturns = salesReturns.fold(0.0, (sum, r) => sum + r.totalAmount);

    return Column(
      children: [
        // HERO CARD: TOTAL SALES
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL SALES ($activeFilter)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _formatCurrency(totalSales),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('INVOICES',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('$invoiceCount Invoices',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AVG INVOICE',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(_formatCurrency(avgInvoiceValue),
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2x3 COMPACT METRICS GRID
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Amount Paid',
                value: _formatCurrency(totalPaid),
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                bgColor: AppColors.successContainer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Outstanding Due',
                value: _formatCurrency(totalDue),
                icon: Icons.pending_actions_rounded,
                color: AppColors.danger,
                bgColor: AppColors.errorContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'GST Collected',
                value: _formatCurrency(totalGst),
                icon: Icons.account_balance_outlined,
                color: AppColors.primaryBlue,
                bgColor: AppColors.blueTint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Discounts Given',
                value: _formatCurrency(totalDiscount),
                icon: Icons.local_offer_outlined,
                color: AppColors.warning,
                bgColor: AppColors.warningContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Sales Returns',
                value: _formatCurrency(totalSalesReturns),
                icon: Icons.assignment_return_outlined,
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF3E8FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Avg Invoice Value',
                value: _formatCurrency(avgInvoiceValue),
                icon: Icons.receipt_long_rounded,
                color: AppColors.darkBlueText,
                bgColor: AppColors.surfaceContainerLow,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gross & Net Sales Summary
  Widget _buildGrossNetSummaryCard(
    List<InvoiceEntity> salesInvoices,
    List<InvoiceReturnEntity> salesReturns,
  ) {
    final grossSales = salesInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
    final totalReturns = salesReturns.fold(0.0, (sum, r) => sum + r.totalAmount);
    final netSales = grossSales - totalReturns;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gross Sales',
                  style: TextStyle(fontSize: 13, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
              Text(_formatCurrency(grossSales),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sales Returns',
                  style: TextStyle(fontSize: 13, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
              Text('- ${_formatCurrency(totalReturns)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.danger)),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net Sales',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
              Text(_formatCurrency(netSales),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. SALES OVERVIEW CHART (fl_chart)
  // ===========================================================================
  Widget _buildSalesChartCard(List<InvoiceEntity> invoices, String activeFilter, DateTimeRange range) {
    final chartData = _generateChartData(invoices, activeFilter, range);
    double maxSales = 0.0;
    for (var spot in chartData) {
      if (spot.y > maxSales) maxSales = spot.y;
    }
    if (maxSales <= 0) maxSales = 100.0;

    final hasNoData = invoices.isEmpty;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sales Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activeFilter,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (hasNoData) ...[
            Container(
              height: 160,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.bar_chart_rounded, size: 36, color: AppColors.outline),
                  SizedBox(height: 8),
                  Text(
                    'No sales data for this period',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxSales * 1.15,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppColors.deepNavy,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${chartData[groupIndex].label}\n${_formatCurrency(rod.toY)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < chartData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                chartData[idx].label,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: AppColors.border.withValues(alpha: 0.5), strokeWidth: 1);
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(chartData.length, (idx) {
                    final item = chartData[idx];
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: item.y,
                          color: AppColors.primaryBlue,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxSales * 1.15,
                            color: AppColors.primaryBlue.withValues(alpha: 0.05),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<_ChartPoint> _generateChartData(List<InvoiceEntity> invoices, String activeFilter, DateTimeRange range) {
    if (activeFilter == 'Today') {
      final hours = ['8 AM', '12 PM', '4 PM', '8 PM'];
      final List<_ChartPoint> points = [];
      for (int i = 0; i < 4; i++) {
        final startH = 8 + (i * 4);
        final endH = startH + 4;
        final sum = invoices.where((inv) => inv.issueDate.hour >= startH && inv.issueDate.hour < endH).fold(0.0, (s, inv) => s + inv.grandTotal);
        points.add(_ChartPoint(label: hours[i], y: sum));
      }
      return points;
    } else if (activeFilter == 'This Week') {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final List<_ChartPoint> points = [];
      final monday = range.start;
      for (int i = 0; i < 7; i++) {
        final targetDay = monday.add(Duration(days: i));
        final sum = invoices.where((inv) => inv.issueDate.year == targetDay.year && inv.issueDate.month == targetDay.month && inv.issueDate.day == targetDay.day).fold(0.0, (s, inv) => s + inv.grandTotal);
        points.add(_ChartPoint(label: days[i], y: sum));
      }
      return points;
    } else if (activeFilter == 'This Month' || activeFilter == 'Last Month') {
      final weeks = ['W1', 'W2', 'W3', 'W4'];
      final List<_ChartPoint> points = [];
      for (int i = 0; i < 4; i++) {
        final startDay = 1 + (i * 7);
        final endDay = i == 3 ? 31 : (startDay + 6);
        final sum = invoices.where((inv) => inv.issueDate.day >= startDay && inv.issueDate.day <= endDay).fold(0.0, (s, inv) => s + inv.grandTotal);
        points.add(_ChartPoint(label: weeks[i], y: sum));
      }
      return points;
    } else if (activeFilter == 'This Year') {
      final months = ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];
      final monthIndices = [1, 3, 5, 7, 9, 11];
      final List<_ChartPoint> points = [];
      for (int i = 0; i < monthIndices.length; i++) {
        final m = monthIndices[i];
        final sum = invoices.where((inv) => inv.issueDate.month == m || inv.issueDate.month == m + 1).fold(0.0, (s, inv) => s + inv.grandTotal);
        points.add(_ChartPoint(label: months[i], y: sum));
      }
      return points;
    } else {
      final daysDiff = range.end.difference(range.start).inDays + 1;
      if (daysDiff <= 7) {
        final List<_ChartPoint> points = [];
        for (int i = 0; i < daysDiff; i++) {
          final dayDate = range.start.add(Duration(days: i));
          final sum = invoices.where((inv) => inv.issueDate.year == dayDate.year && inv.issueDate.month == dayDate.month && inv.issueDate.day == dayDate.day).fold(0.0, (s, inv) => s + inv.grandTotal);
          points.add(_ChartPoint(label: DateFormat('dd MMM').format(dayDate), y: sum));
        }
        return points;
      } else {
        final List<_ChartPoint> points = [];
        final step = (daysDiff / 5).ceil();
        for (int i = 0; i < 5; i++) {
          final sDay = range.start.add(Duration(days: i * step));
          final eDay = range.start.add(Duration(days: ((i + 1) * step) - 1));
          final sum = invoices.where((inv) => inv.issueDate.isAfter(sDay.subtract(const Duration(seconds: 1))) && inv.issueDate.isBefore(eDay.add(const Duration(days: 1)))).fold(0.0, (s, inv) => s + inv.grandTotal);
          points.add(_ChartPoint(label: DateFormat('dd/MM').format(sDay), y: sum));
        }
        return points;
      }
    }
  }

  // ===========================================================================
  // 4. SECTION 2: CUSTOMER PERFORMANCE SECTION
  // ===========================================================================
  Widget _buildCustomerPerformanceSection({
    required List<InvoiceEntity> salesInvoices,
    required List<CustomerEntity> allCustomers,
    required DateTimeRange range,
  }) {
    // Group sales invoices by customer name / id
    final Map<String, _CustomerSalesStat> customerStats = {};

    for (var inv in salesInvoices) {
      final custKey = inv.customerId.isNotEmpty
          ? inv.customerId
          : (inv.customerName.isNotEmpty ? inv.customerName : 'Cash Customer');

      if (!customerStats.containsKey(custKey)) {
        customerStats[custKey] = _CustomerSalesStat(
          customerId: inv.customerId,
          name: inv.customerName.isNotEmpty ? inv.customerName : 'Cash Customer',
          phone: inv.customerPhone,
        );
      }

      final stat = customerStats[custKey]!;
      stat.totalSales += inv.grandTotal;
      stat.invoiceCount += 1;
      stat.outstandingDue += (inv.grandTotal - inv.paidAmount).clamp(0.0, double.infinity);
    }

    final sortedStats = customerStats.values.toList()
      ..sort((a, b) => b.totalSales.compareTo(a.totalSales));

    final totalCustomersWithSales = customerStats.length;
    final newCustomers = allCustomers.where((c) {
      return c.createdAt.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          c.createdAt.isBefore(range.end.add(const Duration(seconds: 1)));
    }).length;

    final repeatCustomers = customerStats.values.where((c) => c.invoiceCount > 1).length;
    final topCustomerName = sortedStats.isNotEmpty ? sortedStats.first.name : 'N/A';
    final topCustomerAmount = sortedStats.isNotEmpty ? sortedStats.first.totalSales : 0.0;

    return Column(
      children: [
        // 4 Summary Chips for Customer Stats
        Row(
          children: [
            Expanded(
              child: _buildCustomerStatTile(
                title: 'CUSTOMERS',
                value: '$totalCustomersWithSales',
                sub: 'With Sales',
                icon: Icons.groups_rounded,
                color: AppColors.primaryBlue,
                bgColor: AppColors.blueTint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCustomerStatTile(
                title: 'NEW',
                value: '$newCustomers',
                sub: 'In Period',
                icon: Icons.person_add_alt_1_rounded,
                color: AppColors.success,
                bgColor: AppColors.successContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCustomerStatTile(
                title: 'REPEAT',
                value: '$repeatCustomers',
                sub: '>1 Invoice',
                icon: Icons.replay_rounded,
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF3E8FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCustomerStatTile(
                title: 'TOP CUSTOMER',
                value: topCustomerName,
                sub: _formatCurrency(topCustomerAmount),
                icon: Icons.emoji_events_rounded,
                color: AppColors.warning,
                bgColor: AppColors.warningContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // TOP CUSTOMERS RANKING CARD
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Customers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.military_tech_rounded, size: 18, color: AppColors.warning),
                      SizedBox(width: 4),
                      Text(
                        'By Sales Volume',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (sortedStats.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No customer sales in this period',
                      style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                    ),
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedStats.take(5).length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (ctx, idx) {
                    final stat = sortedStats[idx];
                    final matchingCustomer = allCustomers.firstWhere(
                      (c) => c.id == stat.customerId || c.name == stat.name,
                      orElse: () => CustomerEntity(
                        id: stat.customerId,
                        name: stat.name,
                        phone: stat.phone,
                        email: '',
                        address: '',
                        createdAt: DateTime.now(),
                      ),
                    );

                    return InkWell(
                      onTap: () {
                        context.push(RouteNames.customerDetails, extra: matchingCustomer);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: idx == 0
                                  ? AppColors.warning.withValues(alpha: 0.15)
                                  : AppColors.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '#${idx + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: idx == 0 ? AppColors.warning : AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stat.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlueText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${stat.invoiceCount} ${stat.invoiceCount == 1 ? 'invoice' : 'invoices'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatCurrency(stat.totalSales),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stat.outstandingDue > 0
                                    ? 'Due ${_formatCurrency(stat.outstandingDue)}'
                                    : '₹0 Due',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: stat.outstandingDue > 0
                                      ? AppColors.danger
                                      : AppColors.success,
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
              const SizedBox(height: 16),

              // VIEW ALL CUSTOMERS BUTTON
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    context.push(RouteNames.accounts);
                  },
                  icon: const Icon(Icons.people_outline_rounded, size: 18),
                  label: const Text('View All Customers', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerStatTile({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondaryText,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPoint {
  final String label;
  final double y;
  const _ChartPoint({required this.label, required this.y});
}

class _CustomerSalesStat {
  final String customerId;
  final String name;
  final String phone;
  double totalSales = 0.0;
  int invoiceCount = 0;
  double outstandingDue = 0.0;

  _CustomerSalesStat({
    required this.customerId,
    required this.name,
    required this.phone,
  });
}
