import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/bloc/dashboard_bloc.dart';
import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../infrastructure/services/backup_restore_service.dart';
import '../../../infrastructure/storage/hive_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static Future<void> showCloseShopDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.storefront_rounded, color: AppColors.danger, size: 26),
            SizedBox(width: 10),
            Text(
              'Close Shop',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Are you sure you want to close shop and exit the application?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlueText),
            ),
            SizedBox(height: 10),
            Text(
              'Your business backup will be saved automatically before closing.',
              style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _performAutoBackupAndExit(
                context,
                isCloseShop: true,
              );
            },
            icon: const Icon(Icons.power_settings_new_rounded, size: 18),
            label: const Text('Close Shop & Exit', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  static Future<void> _performAutoBackupAndExit(
    BuildContext context, {
    required bool isCloseShop,
  }) async {
    BuildContext? progressCtx;

    // Show blocking progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        progressCtx = dialogCtx;
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryBlue),
                  const SizedBox(height: 18),
                  const Text(
                    'Saving Backup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isCloseShop
                        ? 'Please wait while we securely save your business backup before closing the shop.'
                        : 'Please wait while we save your business backup.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final backupService = BackupRestoreService(getIt<HiveService>());
    final result = await backupService.performAutoExitBackup();

    // Dismiss progress dialog if open
    if (progressCtx != null && progressCtx!.mounted) {
      Navigator.of(progressCtx!).pop();
    }

    if (result.success) {
      await SystemNavigator.pop();
      exit(0);
    } else {
      if (!context.mounted) return;
      _showBackupFailedDialog(context, isCloseShop: isCloseShop);
    }
  }

  static Future<void> _showBackupFailedDialog(
    BuildContext context, {
    required bool isCloseShop,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 28),
            SizedBox(width: 10),
            Text(
              'Backup Failed',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "We couldn't save your backup. Your data is still safe on this device.",
              style: TextStyle(fontSize: 13, color: AppColors.darkBlueText, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await SystemNavigator.pop();
              exit(0);
            },
            child: Text(isCloseShop ? 'Close Shop Without Backup' : 'Exit Without Backup'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _performAutoBackupAndExit(context, isCloseShop: isCloseShop);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchDashboardDataEvent());
    context.read<ProductBloc>().add(const FetchProductsEvent());
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          DashboardPage.showCloseShopDialog(context);
        }
      },
      child: Scaffold(
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
            // Close Shop Exit Button
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => DashboardPage.showCloseShopDialog(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.power_settings_new_rounded, color: AppColors.danger, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Close Shop',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoadingState) {
            return const DashboardSkeleton();
          }
          if (state is DashboardErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<DashboardBloc>().add(FetchDashboardDataEvent()),
            );
          }
          if (state is DashboardLoadedState) {
            final todaySales = state.todaySales;
            final weeklySales = state.weeklySales;
            final monthlySales = state.monthlySales;
            final receivables = state.totalReceivables;
            final profit = state.netProfit;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(FetchDashboardDataEvent());
                context.read<ProductBloc>().add(const FetchProductsEvent());
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

                    // Global Search Bar Entry Button
                    InkWell(
                      onTap: () => context.push(RouteNames.globalSearch),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: AppColors.primaryBlue, size: 22),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Search anything (customers, invoices, products)...',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward, size: 16, color: AppColors.primaryBlue),
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

                    // Relocated Section 1: Today Summary (Sales, Expenses, Net)
                    _buildTodaySummarySection(context, state),
                    const SizedBox(height: 14),

                    // Relocated Section 2: Invoice Stats & Outstanding Summary
                    _buildInvoiceStatsAndOutstanding(context, state),
                    const SizedBox(height: 14),

                    // Inventory Overview Section
                    _buildInventoryOverviewSection(context),
                    const SizedBox(height: 20),

                    // Relocated Section 3: Weekly Overview Dual Bar Chart
                    _buildWeeklyChartSection(state),
                    const SizedBox(height: 14),

                    // Relocated Section 4: Weekly Summary (Sales, Expenses, Net)
                    _buildWeeklySummarySection(state),
                    const SizedBox(height: 20),

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
                                avatar: const Icon(Icons.people_alt_outlined, size: 18),
                                label: const Text('Customers'),
                                onPressed: () =>
                                    context.push(RouteNames.customers),
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
                          onTap: () async {
                            final bloc = context.read<InvoiceBloc>();
                            await context.push(
                              RouteNames.createInvoice,
                              extra: {
                                'invoiceType': inv.type,
                                'invoiceToEdit': inv,
                              },
                            );
                            if (!mounted) return;
                            bloc.add(const FetchInvoicesEvent());
                          },
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
    ),
  );
}
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  // TODAY SUMMARY CARDS (Relocated from Sales Overview)
  Widget _buildTodaySummarySection(BuildContext context, DashboardLoadedState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today Overview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlueText,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryMetricCard(
                title: 'Sales',
                amount: _formatCurrency(state.todaySales),
                amountColor: AppColors.primaryBlue,
                onTap: () {
                  context.push(
                    RouteNames.dailyLedger,
                    extra: {'initialTab': 0, 'initialDate': DateTime.now()},
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryMetricCard(
                title: 'Expenses',
                amount: _formatCurrency(state.todayExpenses),
                amountColor: AppColors.warning,
                onTap: () {
                  context.push(
                    RouteNames.dailyLedger,
                    extra: {'initialTab': 1, 'initialDate': DateTime.now()},
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryMetricCard(
                title: 'Net',
                amount: _formatCurrency(state.todayNet),
                amountColor: state.todayNet >= 0 ? AppColors.success : AppColors.danger,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // INVOICE STATS & OUTSTANDING CARD (Relocated from Sales Overview)
  Widget _buildInvoiceStatsAndOutstanding(BuildContext context, DashboardLoadedState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${state.todayInvoiceCount} invoices',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlueText,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('•', style: TextStyle(color: AppColors.secondaryText)),
              ),
              Text(
                '${state.todayPaidCount} paid',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('•', style: TextStyle(color: AppColors.secondaryText)),
              ),
              Text(
                '${state.todayDueCount} due',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          onTap: () {
            context.push(RouteNames.salesOverview);
          },
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Outstanding',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(state.totalOutstandingAmount),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Text(
                    'View Unpaid',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: AppColors.primaryBlue, size: 20),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // WEEKLY DUAL BAR CHART (SALES VS EXPENSES) (Relocated from Sales Overview)
  Widget _buildWeeklyChartSection(DashboardLoadedState state) {
    double maxVal = 0.0;
    for (var day in state.weeklyDailyBreakdown) {
      if (day.sales > maxVal) maxVal = day.sales;
      if (day.expenses > maxVal) maxVal = day.expenses;
    }
    if (maxVal == 0.0) maxVal = 1.0;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Sales', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Expenses', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: state.weeklyDailyBreakdown.map((dayData) {
                    final salesPct = (dayData.sales / maxVal).clamp(0.05, 1.0);
                    final expPct = (dayData.expenses / maxVal).clamp(0.05, 1.0);

                    final salesBarHeight = dayData.sales > 0 ? (100 * salesPct) : 4.0;
                    final expBarHeight = dayData.expenses > 0 ? (100 * expPct) : 4.0;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Tooltip(
                              message: 'Sales: ${_formatCurrency(dayData.sales)}',
                              child: Container(
                                width: 10,
                                height: salesBarHeight,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Tooltip(
                              message: 'Expenses: ${_formatCurrency(dayData.expenses)}',
                              child: Container(
                                width: 10,
                                height: expBarHeight,
                                decoration: const BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayData.dayName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // WEEKLY SUMMARY ROW
  Widget _buildWeeklySummarySection(DashboardLoadedState state) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This week',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sales', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              Text(_formatCurrency(state.weeklySales), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Expenses', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              Text(_formatCurrency(state.weeklyExpenses), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.warning)),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
              Text(
                _formatCurrency(state.weeklyNet),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: state.weeklyNet >= 0 ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color amountColor;
  final VoidCallback? onTap;

  const _SummaryMetricCard({
    required this.title,
    required this.amount,
    required this.amountColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
            ),
          ],
        ),
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

// INVENTORY OVERVIEW SECTION FOR DASHBOARD
Widget _buildInventoryOverviewSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Inventory Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlueText,
            ),
          ),
          GestureDetector(
            onTap: () => context.push(RouteNames.stockManagement),
            child: const Text(
              'Manage',
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
      BlocBuilder<ProductBloc, ProductState>(
        builder: (context, pState) {
          if (pState is ProductsLoadedState) {
            final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push(RouteNames.stockManagement),
                          child: _InventorySummaryBox(
                            label: 'Total Products',
                            value: '${pState.totalProducts}',
                            subText: '${pState.totalItems} Total Items',
                            valueColor: AppColors.darkBlueText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push(RouteNames.stockManagement),
                          child: _InventorySummaryBox(
                            label: 'Low Stock',
                            value: '${pState.lowStockCount}',
                            subText: 'Running Low',
                            valueColor: pState.lowStockCount > 0 ? AppColors.warning : AppColors.secondaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push(RouteNames.stockManagement),
                          child: _InventorySummaryBox(
                            label: 'Out of Stock',
                            value: '${pState.outOfStockCount}',
                            subText: 'Empty Stock',
                            valueColor: pState.outOfStockCount > 0 ? AppColors.danger : AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.secondaryText),
                            SizedBox(width: 6),
                            Text('Stock Value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                          ],
                        ),
                        Text(
                          formatter.format(pState.stockValue),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        const Text('Stock Health: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondaryText)),
                        _InventoryHealthBadge(label: 'Healthy ${pState.healthyCount}', color: AppColors.success, bg: AppColors.successContainer),
                        const SizedBox(width: 6),
                        _InventoryHealthBadge(label: 'Low ${pState.lowStockCount}', color: AppColors.warning, bg: AppColors.warningContainer),
                        const SizedBox(width: 6),
                        _InventoryHealthBadge(label: 'Out ${pState.outOfStockCount}', color: AppColors.danger, bg: AppColors.errorContainer),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    ],
  );
}

class _InventorySummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final String subText;
  final Color valueColor;

  const _InventorySummaryBox({
    required this.label,
    required this.value,
    required this.subText,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText), maxLines: 1),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: valueColor),
            ),
          ),
          const SizedBox(height: 2),
          Text(subText, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText), maxLines: 1),
        ],
      ),
    );
  }
}

class _InventoryHealthBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _InventoryHealthBadge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

