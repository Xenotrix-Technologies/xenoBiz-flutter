import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/dashboard_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/invoice_entity.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Offline Sync Center',
            onPressed: () {
              context.push(RouteNames.offlineSync);
            },
          ),
          IconButton(
            icon: const Icon(Icons.workspace_premium),
            tooltip: 'Subscription Entitlements',
            onPressed: () {
              context.push(RouteNames.subscription);
            },
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
            return const LoadingState(message: 'Loading financial dashboard...');
          }
          if (state is DashboardErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<DashboardBloc>().add(FetchDashboardDataEvent()),
            );
          }
          if (state is DashboardLoadedState) {
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
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.stars, color: AppColors.secondary),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '7-Day Free Trial Active • Tap to upgrade to Pro',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Financial KPIs Card
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.monthlySales,
                            style: const TextStyle(fontSize: 13, color: AppColors.outline, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${state.monthlySales.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _KpiSubMetric(
                                  label: 'Today Sales',
                                  value: '₹${state.todaySales.toStringAsFixed(0)}',
                                  color: AppColors.success,
                                ),
                              ),
                              Expanded(
                                child: _KpiSubMetric(
                                  label: AppStrings.receivables,
                                  value: '₹${state.totalReceivables.toStringAsFixed(0)}',
                                  color: AppColors.error,
                                ),
                              ),
                              Expanded(
                                child: _KpiSubMetric(
                                  label: AppStrings.payables,
                                  value: '₹${state.totalPayables.toStringAsFixed(0)}',
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Additional Navigation Grid
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business Modules',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.local_shipping, size: 18),
                                label: const Text('Purchases'),
                                onPressed: () => context.push(RouteNames.purchaseManagement),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.contacts, size: 18),
                                label: const Text('Suppliers'),
                                onPressed: () => context.push(RouteNames.supplierDirectory),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.leaderboard, size: 18),
                                label: const Text('CRM Pipeline'),
                                onPressed: () => context.push(RouteNames.leadPipeline),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.alarm, size: 18),
                                label: const Text('Reminders'),
                                onPressed: () => context.push(RouteNames.automatedReminders),
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
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
                                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                ),
                                child: const Icon(Icons.description, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inv.invoiceNumber,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    Text(
                                      inv.customerName,
                                      style: const TextStyle(color: AppColors.outline, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${inv.grandTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 4),
                                  inv.status == InvoiceStatus.paid
                                      ? StatusChip.paid()
                                      : inv.status == InvoiceStatus.partiallyPaid
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

class _KpiSubMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiSubMetric({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.outline, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}
