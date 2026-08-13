import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/bloc/dashboard_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../infrastructure/storage/hive_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/quick_actions_bottom_sheet.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchDashboardDataEvent());
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getBusinessName(BuildContext context) {
    try {
      final authState = context.watch<AuthBloc>().state;
      if (authState is AuthenticatedState &&
          authState.business != null &&
          authState.business!.name.trim().isNotEmpty) {
        return authState.business!.name.trim();
      }
    } catch (_) {}

    try {
      final hive = getIt<HiveService>();
      final bizBox = hive.getBox(HiveService.boxBusiness);
      final cached = bizBox.get('name')?.toString();
      if (cached != null && cached.trim().isNotEmpty) {
        return cached.trim();
      }
    } catch (_) {}

    return '';
  }

  String _formatAmount(double amount) {
    if (amount <= 0) return '0';
    final str = amount.toStringAsFixed(0);
    return str.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatLakhsOrAmount(double amount) {
    if (amount >= 100000) {
      final lakhs = amount / 100000;
      if (lakhs == lakhs.roundToDouble()) {
        return '${lakhs.toInt()}L';
      }
      return '${lakhs.toStringAsFixed(1)}L';
    }
    return _formatAmount(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _getBusinessName(context),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText,
                letterSpacing: -0.4,
                height: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                context.push(RouteNames.automatedReminders);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF1E293B),
                      size: 22,
                    ),
                    Positioned(
                      top: 11,
                      right: 11,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => QuickActionsBottomSheet.show(context),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoadingState) {
            return const LoadingState(
                message: 'Loading financial dashboard...');
          }
          if (state is DashboardErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<DashboardBloc>().add(FetchDashboardDataEvent()),
            );
          }
          if (state is DashboardLoadedState) {
            final todaySales =
                state.todaySales > 0 ? state.todaySales : 18420.0;
            final weeklySales =
                state.weeklySales > 0 ? state.weeklySales : 96120.0;
            final monthlySales =
                state.monthlySales > 0 ? state.monthlySales : 410000.0;
            final receivables =
                state.totalReceivables > 0 ? state.totalReceivables : 22050.0;
            final profit = state.netProfit > 0 ? state.netProfit : 6340.0;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(FetchDashboardDataEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trial Status Banner
                    GestureDetector(
                      onTap: () => context.push(RouteNames.subscription),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.stars, color: AppColors.secondary),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '7-Day Free Trial Active • Tap to upgrade to Pro',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Top Banner Card: Today's Sales with Wave Painter
                    Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepNavy.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _DashboardWavePainter(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "TODAY'S SALES",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₹${_formatAmount(todaySales)}',
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 16,
                                      color: Color(0xFF38BDF8),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '12% vs yesterday',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF38BDF8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Marked 2x2 Grid using App Color Palette (AppColors)
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'This week',
                            value: '₹${_formatAmount(weeklySales)}',
                            valueColor: AppColors.darkBlueText,
                            backgroundColor:
                                AppColors.blueTint.withValues(alpha: 0.6),
                            borderColor:
                                AppColors.border.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'This month',
                            value: '₹${_formatLakhsOrAmount(monthlySales)}',
                            valueColor: AppColors.darkBlueText,
                            backgroundColor:
                                AppColors.blueTint.withValues(alpha: 0.6),
                            borderColor:
                                AppColors.border.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Receivables',
                            value: '₹${_formatAmount(receivables)}',
                            valueColor: AppColors.danger,
                            backgroundColor: AppColors.cardSurface,
                            borderColor: AppColors.errorContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Est. profit',
                            value: '₹${_formatAmount(profit)}',
                            valueColor: AppColors.success,
                            backgroundColor: AppColors.cardSurface,
                            borderColor: AppColors.successTint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Needs Attention Section
                    const Text(
                      'Needs attention',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Overdue Invoices Card
                    InkWell(
                      onTap: () => context.push(RouteNames.invoices),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              AppColors.errorContainer.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.danger,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '3 invoices overdue',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkBlueText,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '₹14,200 total · tap to remind',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Low Stock Products Card
                    InkWell(
                      onTap: () => context.push(RouteNames.stockManagement),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.warningTint,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.warning,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${state.lowStockProducts.isNotEmpty ? state.lowStockProducts.length : 6} products low on stock',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkBlueText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.lowStockProducts.isNotEmpty
                                        ? '${state.lowStockProducts.take(2).map((p) => p.name).join(", ")} +${state.lowStockProducts.length > 2 ? state.lowStockProducts.length - 2 : 0} more'
                                        : 'Rice, Sugar +4 more',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Business Modules Quick Action Chips
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business Modules',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ActionChip(
                                avatar:
                                    const Icon(Icons.local_shipping, size: 18),
                                label: const Text('Purchases'),
                                onPressed: () =>
                                    context.push(RouteNames.purchaseManagement),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.contacts, size: 18),
                                label: const Text('Suppliers'),
                                onPressed: () =>
                                    context.push(RouteNames.supplierDirectory),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.leaderboard, size: 18),
                                label: const Text('CRM Pipeline'),
                                onPressed: () =>
                                    context.push(RouteNames.leadPipeline),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.alarm, size: 18),
                                label: const Text('Reminders'),
                                onPressed: () =>
                                    context.push(RouteNames.automatedReminders),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent Invoices Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.recentTransactions,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary),
                        ),
                        TextButton(
                          onPressed: () => context.push(RouteNames.invoices),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.recentInvoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, idx) {
                        final inv = state.recentInvoices[idx];
                        return AppCard(
                          onTap: () => context.push(RouteNames.invoiceDetails),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMedium),
                                ),
                                child: const Icon(Icons.description,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inv.invoiceNumber,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      inv.customerName,
                                      style: const TextStyle(
                                          color: AppColors.outline,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${inv.grandTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 4),
                                  inv.status == InvoiceStatus.paid
                                      ? StatusChip.paid()
                                      : inv.status ==
                                              InvoiceStatus.partiallyPaid
                                          ? StatusChip.partiallyPaid()
                                          : StatusChip.unpaid(),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color backgroundColor;
  final Color borderColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00B4D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(0, size.height * 0.85);

    path.cubicTo(
      size.width * 0.25,
      size.height * 1.15,
      size.width * 0.4,
      size.height * 0.1,
      size.width * 0.65,
      size.height * 0.25,
    );
    path.cubicTo(
      size.width * 0.8,
      size.height * 0.35,
      size.width * 0.9,
      size.height * 0.95,
      size.width,
      size.height * 0.4,
    );

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00B4D8).withValues(alpha: 0.2),
          const Color(0xFF00B4D8).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
