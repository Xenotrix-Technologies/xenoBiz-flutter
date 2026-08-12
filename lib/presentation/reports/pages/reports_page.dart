import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../const/strings.dart';
import '../../widgets/app_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.reports),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _ReportTile(
              title: AppStrings.salesAnalytics,
              subtitle: 'Revenue trends, top products & customer volume',
              icon: Icons.bar_chart,
              color: AppColors.secondary,
              onTap: () => context.push(RouteNames.salesAnalytics),
            ),
            const SizedBox(height: 14),
            _ReportTile(
              title: AppStrings.financialAnalytics,
              subtitle: 'Profit & loss, expenses breakdown, GST summary',
              icon: Icons.account_balance_wallet,
              color: AppColors.success,
              onTap: () => context.push(RouteNames.financialAnalytics),
            ),
            const SizedBox(height: 14),
            _ReportTile(
              title: AppStrings.inventoryAnalytics,
              subtitle: 'Stock valuation, fast-moving items & low stock',
              icon: Icons.inventory,
              color: AppColors.warning,
              onTap: () => context.push(RouteNames.inventoryAnalytics),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.outline)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outline),
        ],
      ),
    );
  }
}
