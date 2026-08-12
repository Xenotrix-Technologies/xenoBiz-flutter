import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class MoreMenuPage extends StatelessWidget {
  const MoreMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('More Options & Business Hub'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pro Account Status Card
            AppCard(
              onTap: () => context.push(RouteNames.subscription),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.blueTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.workspace_premium, color: AppColors.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'XenoBiz Pro • 7-Day Trial',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.darkBlueText),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tap to view plan details & billing',
                          style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.secondaryText),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Sales & Invoicing',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 10),
            _MenuGrid(
              items: [
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'All Invoices',
                  route: RouteNames.invoices,
                  color: AppColors.primaryBlue,
                ),
                _MenuItem(
                  icon: Icons.add_circle_outline,
                  title: 'New Invoice',
                  route: RouteNames.createInvoice,
                  color: AppColors.primaryBlue,
                ),
                _MenuItem(
                  icon: Icons.analytics_outlined,
                  title: 'Sales Analytics',
                  route: RouteNames.salesAnalytics,
                  color: AppColors.success,
                ),
                _MenuItem(
                  icon: Icons.point_of_sale_outlined,
                  title: 'Reports Hub',
                  route: RouteNames.reports,
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Inventory & Purchasing',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 10),
            _MenuGrid(
              items: [
                _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Product Catalog',
                  route: RouteNames.products,
                  color: AppColors.deepNavy,
                ),
                _MenuItem(
                  icon: Icons.tune_outlined,
                  title: 'Stock Adjustment',
                  route: RouteNames.stockAdjustment,
                  color: AppColors.deepNavy,
                ),
                _MenuItem(
                  icon: Icons.local_shipping_outlined,
                  title: 'Purchases',
                  route: RouteNames.purchaseManagement,
                  color: AppColors.primaryBlue,
                ),
                _MenuItem(
                  icon: Icons.store_outlined,
                  title: 'Suppliers',
                  route: RouteNames.supplierDirectory,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'CRM & Communication',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 10),
            _MenuGrid(
              items: [
                _MenuItem(
                  icon: Icons.leaderboard_outlined,
                  title: 'Lead Pipeline',
                  route: RouteNames.leadPipeline,
                  color: AppColors.success,
                ),
                _MenuItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Follow-ups',
                  route: RouteNames.followUps,
                  color: AppColors.warning,
                ),
                _MenuItem(
                  icon: Icons.chat_outlined,
                  title: 'WhatsApp Templates',
                  route: RouteNames.whatsappTemplates,
                  color: AppColors.success,
                ),
                _MenuItem(
                  icon: Icons.alarm_outlined,
                  title: 'Reminders',
                  route: RouteNames.automatedReminders,
                  color: AppColors.danger,
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'System & Settings',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 10),
            _MenuGrid(
              items: [
                _MenuItem(
                  icon: Icons.sync_outlined,
                  title: 'Offline Sync',
                  route: RouteNames.offlineSync,
                  color: AppColors.primaryBlue,
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  route: RouteNames.settings,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sign out button
            Center(
              child: TextButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  context.go(RouteNames.login);
                },
                icon: const Icon(Icons.logout, color: AppColors.danger, size: 20),
                label: const Text(
                  'Sign Out of Account',
                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String route;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
  });
}

class _MenuGrid extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, idx) {
        final item = items[idx];
        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onTap: () => context.push(item.route),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlueText,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
