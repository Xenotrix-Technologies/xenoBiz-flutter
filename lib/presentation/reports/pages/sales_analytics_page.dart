import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/providers/app_providers.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class SalesAnalyticsPage extends ConsumerStatefulWidget {
  const SalesAnalyticsPage({super.key});

  @override
  ConsumerState<SalesAnalyticsPage> createState() => _SalesAnalyticsPageState();
}

class _SalesAnalyticsPageState extends ConsumerState<SalesAnalyticsPage> {
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
    });
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
            colorScheme: ColorScheme.light(
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

  List<InvoiceEntity> _filterInvoices(List<InvoiceEntity> invoices, DateTimeRange range) {
    return invoices.where((inv) {
      if (inv.isPurchase) return false;
      return inv.issueDate.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          inv.issueDate.isBefore(range.end.add(const Duration(seconds: 1)));
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
        builder: (context, state) {
          if (state is InvoiceLoadingState) {
            return const AnalyticsPageSkeleton();
          }

          if (state is InvoiceErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<InvoiceBloc>().add(const FetchInvoicesEvent()),
            );
          }

          List<InvoiceEntity> allInvoices = [];
          if (state is InvoicesLoadedState) {
            allInvoices = state.invoices;
          }

          final salesInvoices = _filterInvoices(allInvoices, range);

          return RefreshIndicator(
            onRefresh: () async {
              context.read<InvoiceBloc>().add(const FetchInvoicesEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TIME PERIOD SELECTOR BAR
                  _buildPeriodSelector(activeFilter, range),
                  const SizedBox(height: 16),

                  if (salesInvoices.isEmpty) ...[
                    // EMPTY STATE
                    _buildEmptyStateCard(activeFilter),
                  ] else ...[
                    // 2. HERO TOTAL SALES & SUMMARY CARDS
                    _buildSummaryMetricsGrid(salesInvoices, activeFilter),
                    const SizedBox(height: 20),

                    // 3. SALES OVERVIEW CHART
                    _buildSalesChartCard(salesInvoices, activeFilter, range),
                    const SizedBox(height: 20),

                    // 4. PAYMENT METHOD BREAKDOWN
                    _buildPaymentMethodBreakdown(salesInvoices),
                    const SizedBox(height: 20),

                    // 5. TOP SELLING PRODUCTS
                    _buildTopSellingProducts(salesInvoices),
                    const SizedBox(height: 20),

                    // 6. RECENT SALES LIST
                    _buildRecentSalesSection(salesInvoices),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // 1. PERIOD SELECTOR WIDGET
  // ===========================================================================
  Widget _buildPeriodSelector(String activeFilter, DateTimeRange range) {
    final filters = ['Today', 'This Week', 'This Month', 'Last Month', 'This Year', 'Custom Range'];

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
  // 2. HERO TOTAL SALES & SUMMARY METRICS GRID
  // ===========================================================================
  Widget _buildSummaryMetricsGrid(List<InvoiceEntity> invoices, String activeFilter) {
    final double totalSales = invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
    final int invoiceCount = invoices.length;
    final double avgInvoiceValue = invoiceCount > 0 ? (totalSales / invoiceCount) : 0.0;
    final double totalGst = invoices.fold(0.0, (sum, inv) => sum + (inv.gstEnabled ? inv.taxTotal : 0.0));
    final double totalDiscount = invoices.fold(0.0, (sum, inv) => sum + inv.discountTotal);
    final double totalExtraExpense = invoices.fold(0.0, (sum, inv) => sum + inv.extraExpenseAmount);
    final double totalPaid = invoices.fold(0.0, (sum, inv) => sum + inv.paidAmount);
    final double totalDue = invoices.fold(0.0, (sum, inv) => sum + (inv.grandTotal - inv.paidAmount).clamp(0.0, double.infinity));

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
                          const Text('INVOICES', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('$invoiceCount Receipts', style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w800)),
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
                          const Text('AVG INVOICE', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(_formatCurrency(avgInvoiceValue), style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w800)),
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
                title: 'Extra Expenses',
                value: _formatCurrency(totalExtraExpense),
                icon: Icons.add_card_rounded,
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF3E8FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Avg Order Size',
                value: _formatCurrency(avgInvoiceValue),
                icon: Icons.shopping_bag_outlined,
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

  // ===========================================================================
  // 3. SALES OVERVIEW CHART (fl_chart)
  // ===========================================================================
  Widget _buildSalesChartCard(List<InvoiceEntity> invoices, String activeFilter, DateTimeRange range) {
    // Generate grouped sales data for chart
    final chartData = _generateChartData(invoices, activeFilter, range);
    double maxSales = 0.0;
    for (var spot in chartData) {
      if (spot.y > maxSales) maxSales = spot.y;
    }
    if (maxSales <= 0) maxSales = 100.0;

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
      // Custom Range
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
  // 4. PAYMENT METHOD BREAKDOWN
  // ===========================================================================
  Widget _buildPaymentMethodBreakdown(List<InvoiceEntity> invoices) {
    final double totalSales = invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);
    Map<String, double> methodTotals = {
      'Cash': 0.0,
      'GPay/UPI': 0.0,
      'Card': 0.0,
      'Other': 0.0,
    };

    for (var inv in invoices) {
      String mode = 'Cash';
      final notes = inv.notes.toLowerCase();
      if (notes.contains('upi') || notes.contains('gpay') || notes.contains('online')) {
        mode = 'GPay/UPI';
      } else if (notes.contains('card') || notes.contains('credit') || notes.contains('debit')) {
        mode = 'Card';
      } else if (notes.contains('cheque') || notes.contains('net')) {
        mode = 'Other';
      }
      methodTotals[mode] = (methodTotals[mode] ?? 0.0) + inv.grandTotal;
    }

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Methods Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 16),

          ...methodTotals.entries.map((entry) {
            final pct = totalSales > 0 ? (entry.value / totalSales) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                      ),
                      Text(
                        '${_formatCurrency(entry.value)} (${(pct * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.key == 'Cash'
                            ? AppColors.success
                            : entry.key == 'GPay/UPI'
                                ? AppColors.primaryBlue
                                : entry.key == 'Card'
                                    ? AppColors.warning
                                    : const Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. TOP SELLING PRODUCTS
  // ===========================================================================
  Widget _buildTopSellingProducts(List<InvoiceEntity> invoices) {
    Map<String, _ProductStat> productMap = {};

    for (var inv in invoices) {
      for (var item in inv.items) {
        final key = item.productName;
        if (!productMap.containsKey(key)) {
          productMap[key] = _ProductStat(name: key);
        }
        productMap[key]!.quantity += item.quantity;
        productMap[key]!.revenue += item.total;
      }
    }

    final topProducts = productMap.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final displayList = topProducts.take(5).toList();

    if (displayList.isEmpty) return const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Top Selling Products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
            ],
          ),
          const SizedBox(height: 14),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (ctx, idx) {
              final prod = displayList[idx];
              return Row(
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
                          prod.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${prod.quantity} units sold',
                          style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(prod.revenue),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. RECENT SALES LIST
  // ===========================================================================
  Widget _buildRecentSalesSection(List<InvoiceEntity> invoices) {
    final sortedInvoices = List<InvoiceEntity>.from(invoices)
      ..sort((a, b) => b.issueDate.compareTo(a.issueDate));
    final recentList = sortedInvoices.take(5).toList();

    final dateFormatter = DateFormat('dd MMM, hh:mm a');

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Invoices',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              InkWell(
                onTap: () => context.push(RouteNames.invoices),
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentList.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (ctx, idx) {
              final inv = recentList[idx];
              final isCashSale = inv.customerName.isEmpty || inv.customerName == 'Cash Sale';

              StatusChip chipWidget;
              if (inv.status == InvoiceStatus.paid) {
                chipWidget = StatusChip.paid();
              } else if (inv.status == InvoiceStatus.partiallyPaid) {
                chipWidget = StatusChip.partiallyPaid();
              } else {
                chipWidget = StatusChip.unpaid();
              }

              return InkWell(
                onTap: () {
                  context.push(RouteNames.invoiceResult, extra: inv);
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.blueTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${inv.invoiceNumber}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isCashSale ? 'Cash Sale' : inv.customerName,
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateFormatter.format(inv.issueDate),
                            style: const TextStyle(fontSize: 11, color: AppColors.outline),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(inv.grandTotal),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                        ),
                        const SizedBox(height: 4),
                        chipWidget,
                      ],
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

  // ===========================================================================
  // 7. EMPTY STATE CARD
  // ===========================================================================
  Widget _buildEmptyStateCard(String activeFilter) {
    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.blueTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 48,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No sales found for $activeFilter',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlueText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'There are no completed sales invoices recorded during this selected date range.',
            style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ref.read(analyticsDateFilterProvider.notifier).state = 'This Month';
            },
            child: const Text('Reset Filter to This Month', style: TextStyle(fontWeight: FontWeight.w700)),
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

class _ProductStat {
  final String name;
  int quantity = 0;
  double revenue = 0.0;
  _ProductStat({required this.name});
}
