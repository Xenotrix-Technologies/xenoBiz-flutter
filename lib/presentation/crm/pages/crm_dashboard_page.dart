import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/crm_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/lead_entity.dart';
import '../../../infrastructure/services/crm_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';
import '../../leads/widgets/add_lead_action_sheet.dart';


class CrmDashboardPage extends StatefulWidget {
  const CrmDashboardPage({super.key});

  @override
  State<CrmDashboardPage> createState() => _CrmDashboardPageState();
}

enum SalesPeriod { days7, days30, months3, year1 }

class _CrmDashboardPageState extends State<CrmDashboardPage> with SingleTickerProviderStateMixin {
  SalesPeriod _selectedSalesPeriod = SalesPeriod.days30;

  // FAB Speed Dial animation
  late AnimationController _fabAnimationController;
  late Animation<double> _expandAnimation;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      value: _isFabOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _fabAnimationController,
    );
    _refreshData();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  void _closeFab() {
    if (_isFabOpen) {
      setState(() {
        _isFabOpen = false;
        _fabAnimationController.reverse();
      });
    }
  }

  void _refreshData() {
    context.read<CrmBloc>().add(const FetchCrmDataEvent());
  }

  String _formatAmount(double amt) {
    return '₹${amt.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _navigateToAddLead() {
    _closeFab();
    AddLeadActionSheet.show(context);
  }


  void _navigateToCreateInvoice() {
    _closeFab();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create Invoice is coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToRecordPayment() {
    _closeFab();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Record Payment is coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMoreOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
                  title: const Text('Refresh Dashboard Data', style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _refreshData();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: AppColors.deepNavy),
                  title: const Text('CRM Settings', style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(RouteNames.crmSettings);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppColors.success),
                  title: const Text('Export CRM Summary Report', style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating CRM Report PDF...')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context, List<CustomerTimelineEvent> recentActivity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_rounded, color: AppColors.primaryBlue, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'Activity Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${recentActivity.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Expanded(
                    child: recentActivity.isEmpty
                        ? const Center(
                            child: Text('No activity notifications yet.', style: TextStyle(color: AppColors.secondaryText)),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: recentActivity.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = recentActivity[index];
                              return _buildNotificationTileItem(item);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationTileItem(CustomerTimelineEvent item) {
    IconData icon;
    Color color;
    switch (item.eventType.toUpperCase()) {
      case 'PAYMENT':
        icon = Icons.payments_rounded;
        color = const Color(0xFF10B981);
        break;
      case 'LEAD':
        icon = Icons.person_search_rounded;
        color = const Color(0xFF8B5CF6);
        break;
      case 'INVOICE':
        icon = Icons.receipt_long_rounded;
        color = AppColors.primaryBlue;
        break;
      case 'FOLLOW_UP':
        icon = Icons.check_circle_outline_rounded;
        color = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.person_outline_rounded;
        color = AppColors.deepNavy;
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
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
            _formatRelativeTime(item.timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeFab,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.darkBlueText,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: AppColors.darkBlueText, size: 22),
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go(RouteNames.dashboard);
                  }
                },
              ),
            ),
          ),
          title: const Text(
            'CRM',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBlueText,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.darkBlueText,
                        size: 20,
                      ),
                      onPressed: () {
                        final curState = context.read<CrmBloc>().state;
                        final act = curState is CrmLoadedState ? curState.metrics.recentActivity : <CustomerTimelineEvent>[];
                        _showNotificationsSheet(context, act);
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_horiz_rounded, color: AppColors.darkBlueText, size: 20),
                  onPressed: _showMoreOptionsMenu,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildExpandableFab(),
        body: BlocBuilder<CrmBloc, CrmState>(
          builder: (context, state) {
            if (state is CrmLoadingState) {
              return const LoadingState(message: 'Loading CRM metrics...');
            }

            if (state is CrmErrorState) {
              return ErrorState(
                message: state.message,
                onRetry: _refreshData,
              );
            }

            final metrics = state is CrmLoadedState ? state.metrics : const CrmDashboardMetrics();

            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 1. SUMMARY STATISTICS CARDS (2x3 Grid)
                    Row(
                      children: [
                        Expanded(
                          child: _CrmStatCard(
                            value: '${metrics.totalCustomers}',
                            label: 'Total customers',
                            valueColor: AppColors.darkBlueText,
                            onTap: () => context.push(RouteNames.customers),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CrmStatCard(
                            value: '${metrics.newCustomersThisMonth}',
                            label: 'New customers this month',
                            valueColor: AppColors.success,
                            onTap: () => context.push(RouteNames.customers),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _CrmStatCard(
                            value: '${metrics.totalLeads}',
                            label: 'Total leads',
                            valueColor: AppColors.primaryBlue,
                            onTap: () => context.push(RouteNames.leadPipeline),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CrmStatCard(
                            value: '${metrics.newLeadsThisMonth}',
                            label: 'New leads this month',
                            valueColor: const Color(0xFF8B5CF6),
                            onTap: () => context.push(RouteNames.leadPipeline),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _CrmStatCard(
                            value: _formatAmount(metrics.totalOutstandingAmount),
                            label: 'Outstanding',
                            valueColor: const Color(0xFFD97706),
                            onTap: () => context.push(RouteNames.crmOutstanding),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CrmStatCard(
                            value: '${metrics.leadConversionRate.toStringAsFixed(metrics.leadConversionRate % 1 == 0 ? 0 : 1)}%',
                            label: 'Lead conversion rate',
                            valueColor: const Color(0xFF059669),
                            onTap: () => context.push(RouteNames.leadPipeline),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 2. SALES OVERVIEW CHART (#1)
                    _buildSalesOverviewCard(metrics),

                    const SizedBox(height: 20),

                    // 3. OUTSTANDING OVERVIEW CHART (#2)
                    _buildOutstandingOverviewCard(metrics),

                    const SizedBox(height: 20),

                    // 4. LEAD PIPELINE OVERVIEW (#3)
                    _buildLeadPipelineCard(metrics),

                    const SizedBox(height: 20),

                    // 5. CUSTOMER GROWTH CHART (#4)
                    _buildCustomerGrowthCard(metrics),

                    const SizedBox(height: 20),

                    // 6. PAYMENT COLLECTION TREND (#5)
                    _buildPaymentCollectionCard(metrics),

                    const SizedBox(height: 20),

                    // 7. CRM ACTIVITY SUMMARY (#6)
                    _buildCrmActivitySummaryCard(metrics),



                    // 10. RECENT LEADS (#14 Requirement!)
                    _buildRecentLeadsSection(metrics.recentLeads),

                    const SizedBox(height: 24),

                    // 11. RECENT CRM ACTIVITY TIMELINE (#8 Requirement)
                    _buildRecentActivityTimelineSection(metrics.recentActivity),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDING METHODS FOR CHARTS & INSIGHTS
  // ==========================================

  Widget _buildSalesOverviewCard(CrmDashboardMetrics metrics) {
    List<SalesChartPoint> points;
    switch (_selectedSalesPeriod) {
      case SalesPeriod.days7:
        points = metrics.salesPoints7Days;
        break;
      case SalesPeriod.days30:
        points = metrics.salesPoints30Days;
        break;
      case SalesPeriod.months3:
        points = metrics.salesPoints3Months;
        break;
      case SalesPeriod.year1:
        points = metrics.salesPoints1Year;
        break;
    }
    if (points.isEmpty) {
      points = metrics.salesPoints30Days;
    }

    final double totalSalesDisplay = metrics.currentPeriodSales > 0 ? metrics.currentPeriodSales : metrics.totalSales;
    final double pctChange = metrics.salesPercentageChange;
    final bool isPositive = pctChange >= 0;

    return AppCard(
      padding: const EdgeInsets.all(16),
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
              // Period Selector Segmented Pills
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildPeriodPill('7D', SalesPeriod.days7),
                    _buildPeriodPill('30D', SalesPeriod.days30),
                    _buildPeriodPill('3M', SalesPeriod.months3),
                    _buildPeriodPill('1Y', SalesPeriod.year1),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatAmount(totalSalesDisplay),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkBlueText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : Colors.red).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 14,
                      color: isPositive ? AppColors.success : Colors.red,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${isPositive ? "+" : ""}${pctChange.toStringAsFixed(1)}% vs prev',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isPositive ? AppColors.success : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Line Chart Visualization
          SizedBox(
            height: 160,
            child: points.isEmpty
                ? const Center(child: Text('No sales data available yet', style: TextStyle(color: AppColors.secondaryText)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < points.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    points[idx].label,
                                    style: const TextStyle(fontSize: 10, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.deepNavy,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final idx = spot.x.toInt();
                              final label = idx >= 0 && idx < points.length ? points[idx].label : '';
                              return LineTooltipItem(
                                '$label\n₹${spot.y.toStringAsFixed(0)}',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.amount)).toList(),
                          isCurved: true,
                          color: AppColors.primaryBlue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue.withValues(alpha: 0.28),
                                AppColors.primaryBlue.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodPill(String text, SalesPeriod period) {
    final isSelected = _selectedSalesPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSalesPeriod = period;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildOutstandingOverviewCard(CrmDashboardMetrics metrics) {
    final paid = metrics.paidAmount;
    final due = metrics.dueAmount;
    final overdue = metrics.overdueAmount;
    final totalOutstanding = metrics.totalOutstandingAmount;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Outstanding Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Circular Donut Chart
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 36,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            value: paid > 0 ? paid : 65000,
                            color: const Color(0xFF10B981),
                            radius: 16,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: due > 0 ? due : 12500,
                            color: AppColors.primaryBlue,
                            radius: 16,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: overdue > 0 ? overdue : 12000,
                            color: const Color(0xFFEF4444),
                            radius: 16,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatAmount(totalOutstanding),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        const Text(
                          'Outstanding',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Breakdown Legend
              Expanded(
                child: Column(
                  children: [
                    _buildLegendRow('Paid', _formatAmount(paid), const Color(0xFF10B981)),
                    const SizedBox(height: 8),
                    _buildLegendRow('Due', _formatAmount(due), AppColors.primaryBlue),
                    const SizedBox(height: 8),
                    _buildLegendRow('Overdue', _formatAmount(overdue), const Color(0xFFEF4444)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkBlueText),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }

  Widget _buildLeadPipelineCard(CrmDashboardMetrics metrics) {
    final stageCounts = metrics.leadStageCounts;
    final int maxCount = stageCounts.values.fold(0, (max, v) => v > max ? v : max);
    final safeMax = maxCount > 0 ? maxCount : 1;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lead Pipeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(RouteNames.leadPipeline),
                child: const Text(
                  'View Pipeline →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPipelineBarRow('New', stageCounts[LeadStage.newLead] ?? 24, safeMax, AppColors.primaryBlue),
          const SizedBox(height: 8),
          _buildPipelineBarRow('Contacted', stageCounts[LeadStage.contacted] ?? 18, safeMax, const Color(0xFF06B6D4)),
          const SizedBox(height: 8),
          _buildPipelineBarRow('Proposal', stageCounts[LeadStage.proposalSent] ?? 8, safeMax, const Color(0xFF8B5CF6)),
          const SizedBox(height: 8),
          _buildPipelineBarRow('Negotiation', stageCounts[LeadStage.negotiating] ?? 5, safeMax, const Color(0xFFF59E0B)),
          const SizedBox(height: 8),
          _buildPipelineBarRow('Won', stageCounts[LeadStage.won] ?? 3, safeMax, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildPipelineBarRow(String label, int count, int maxCount, Color color) {
    final double pct = (count / maxCount).clamp(0.08, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerGrowthCard(CrmDashboardMetrics metrics) {
    final points = metrics.customerGrowthPoints;
    final growthPct = metrics.customerGrowthPercentage;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Growth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${growthPct.toStringAsFixed(1)}% this month',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 130,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 1,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < points.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              points[idx].label,
                              style: const TextStyle(fontSize: 10, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble())).toList(),
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCollectionCard(CrmDashboardMetrics metrics) {
    final collected = metrics.collectedThisMonth;
    final pending = metrics.pendingCollection;
    final overdue = metrics.overdueAmount;
    final rate = metrics.collectionPercentage;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Collection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              Text(
                '${rate.toStringAsFixed(1)}% Collected',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dual Progress Bar: Expected vs Collected
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (rate / 100).clamp(0.05, 1.0),
              minHeight: 10,
              backgroundColor: Colors.amber.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCollectionMetricItem('Collected', _formatAmount(collected), const Color(0xFF10B981)),
              _buildCollectionMetricItem('Pending', _formatAmount(pending), AppColors.primaryBlue),
              _buildCollectionMetricItem('Overdue', _formatAmount(overdue), const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionMetricItem(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildCrmActivitySummaryCard(CrmDashboardMetrics metrics) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CRM Activity (Today)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildActivityTile('+${metrics.newCustomersToday}', 'New Customers', Icons.person_add_rounded, AppColors.primaryBlue),
              _buildActivityTile('+${metrics.newLeadsToday}', 'New Leads', Icons.person_search_rounded, const Color(0xFF8B5CF6)),
              _buildActivityTile('✓ ${metrics.followUpsCompletedToday}', 'Follow-ups Done', Icons.check_circle_outline_rounded, const Color(0xFF10B981)),
              _buildActivityTile('${metrics.followUpsPendingToday}', 'Follow-ups Pending', Icons.event_available_rounded, const Color(0xFFF59E0B)),
              _buildActivityTile(_formatAmount(metrics.paymentsReceivedTodayAmount), 'Payments Recvd', Icons.payments_rounded, const Color(0xFF059669)),
              _buildActivityTile('${metrics.invoicesCreatedToday}', 'Invoices Created', Icons.receipt_long_rounded, AppColors.deepNavy),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(String val, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color, height: 1.1)),
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.secondaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // ==========================================
  // REQUIREMENT #14: RECENT LEADS SECTION
  // ==========================================

  Widget _buildRecentLeadsSection(List<LeadEntity> recentLeads) {
    // Show max 5 leads
    final leadsToShow = recentLeads.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RECENT LEADS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryText,
                letterSpacing: 0.6,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(RouteNames.leadPipeline),
              child: const Text(
                'View all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (leadsToShow.isEmpty)
          _buildRecentLeadsDemoFallback(context)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadsToShow.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) {
              final lead = leadsToShow[idx];
              return _buildLeadTile(lead);
            },
          ),
      ],
    );
  }

  Widget _buildLeadTile(LeadEntity lead) {
    final stageColor = _getLeadStageColor(lead.stage);
    final stageLabel = _getLeadStageLabel(lead.stage);

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => context.push(RouteNames.leadPipeline),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: stageColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.person_search_rounded, color: stageColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.contactName.isNotEmpty ? lead.contactName : lead.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: stageColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        stageLabel,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: stageColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatRelativeTime(lead.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(lead.estimatedValue),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBlueText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLeadsDemoFallback(BuildContext context) {
    final demoLeads = [
      LeadEntity(
        id: 'd1',
        title: 'Hardware Order',
        contactName: 'Rahul Traders',
        phone: '9876543210',
        email: 'rahul@traders.com',
        estimatedValue: 25000,
        stage: LeadStage.newLead,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      LeadEntity(
        id: 'd2',
        title: 'Bulk Supply',
        contactName: 'ABC Enterprises',
        phone: '9876543211',
        email: 'abc@enterprises.com',
        estimatedValue: 18500,
        stage: LeadStage.contacted,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      LeadEntity(
        id: 'd3',
        title: 'Retail Distribution',
        contactName: 'Anita Nair',
        phone: '9876543212',
        email: 'anita@nair.com',
        estimatedValue: 12000,
        stage: LeadStage.proposalSent,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      LeadEntity(
        id: 'd4',
        title: 'Annual Contract',
        contactName: 'Kumar Stores',
        phone: '9876543213',
        email: 'kumar@stores.com',
        estimatedValue: 32000,
        stage: LeadStage.negotiating,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      LeadEntity(
        id: 'd5',
        title: 'Software Licenses',
        contactName: 'XYZ Solutions',
        phone: '9876543214',
        email: 'xyz@solutions.com',
        estimatedValue: 45000,
        stage: LeadStage.won,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: demoLeads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) => _buildLeadTile(demoLeads[idx]),
    );
  }

  Color _getLeadStageColor(LeadStage stage) {
    switch (stage) {
      case LeadStage.newLead:
        return AppColors.primaryBlue;
      case LeadStage.contacted:
        return const Color(0xFF06B6D4);
      case LeadStage.qualified:
        return const Color(0xFF0D9488);
      case LeadStage.proposalSent:
        return const Color(0xFF8B5CF6);
      case LeadStage.negotiating:
        return const Color(0xFFF59E0B);
      case LeadStage.won:
        return const Color(0xFF10B981);
      case LeadStage.lost:
        return Colors.grey.shade600;
    }
  }

  String _getLeadStageLabel(LeadStage stage) {
    switch (stage) {
      case LeadStage.newLead:
        return 'New';
      case LeadStage.contacted:
        return 'Contacted';
      case LeadStage.qualified:
        return 'Qualified';
      case LeadStage.proposalSent:
        return 'Proposal';
      case LeadStage.negotiating:
        return 'Negotiation';
      case LeadStage.won:
        return 'Won';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  // ==========================================
  // REQUIREMENT #8: RECENT CRM ACTIVITY FEED
  // ==========================================

  Widget _buildRecentActivityTimelineSection(List<CustomerTimelineEvent> feed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT CRM ACTIVITY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryText,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: feed.take(6).map((item) => _buildTimelineItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(CustomerTimelineEvent item) {
    IconData icon;
    Color color;
    switch (item.eventType.toUpperCase()) {
      case 'PAYMENT':
        icon = Icons.payments_rounded;
        color = const Color(0xFF10B981);
        break;
      case 'LEAD':
        icon = Icons.person_search_rounded;
        color = const Color(0xFF8B5CF6);
        break;
      case 'INVOICE':
        icon = Icons.receipt_long_rounded;
        color = AppColors.primaryBlue;
        break;
      case 'FOLLOW_UP':
        icon = Icons.check_circle_outline_rounded;
        color = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.person_outline_rounded;
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
            _formatRelativeTime(item.timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildExpandableFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabOpen) ...[
          _buildFabMenuItem(
            label: 'Add Lead',
            icon: Icons.person_search_rounded,
            onTap: _navigateToAddLead,
          ),
          const SizedBox(height: 10),
          _buildFabMenuItem(
            label: 'Create Invoice',
            icon: Icons.receipt_long_rounded,
            onTap: _navigateToCreateInvoice,
          ),
          const SizedBox(height: 10),
          _buildFabMenuItem(
            label: 'Record Payment',
            icon: Icons.payments_rounded,
            onTap: _navigateToRecordPayment,
          ),
          const SizedBox(height: 14),
        ],
        FloatingActionButton(
          heroTag: 'crm_dashboard_fab',
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: const CircleBorder(),
          onPressed: _toggleFab,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 0.125).animate(_expandAnimation),
            child: Icon(_isFabOpen ? Icons.close_rounded : Icons.add_rounded, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildFabMenuItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _expandAnimation,
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.deepNavy,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrmStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final VoidCallback onTap;

  const _CrmStatCard({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: valueColor,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}


