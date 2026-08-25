import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class GstTaxationPage extends StatelessWidget {
  const GstTaxationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _GstToolItem(
        icon: Icons.receipt_long_outlined,
        title: 'GST Reports',
        description: 'GSTR-1, GSTR-3B & Tax return summaries',
        route: RouteNames.reports,
        color: AppColors.primaryBlue,
      ),
      _GstToolItem(
        icon: Icons.summarize_outlined,
        title: 'GST Summary',
        description: 'Output GST, Input Tax Credit & Net Payable',
        route: RouteNames.reports,
        color: AppColors.success,
      ),
      _GstToolItem(
        icon: Icons.percent_outlined,
        title: 'Tax Summary',
        description: 'Item-wise tax rate breakdown (5%, 12%, 18%, 28%)',
        route: RouteNames.reports,
        color: Colors.purple,
      ),
      _GstToolItem(
        icon: Icons.grid_view_outlined,
        title: 'HSN / SAC Summary',
        description: 'HSN/SAC code wise sales & tax statement',
        route: RouteNames.reports,
        color: Colors.teal,
      ),
      _GstToolItem(
        icon: Icons.qr_code_2_outlined,
        title: 'E-Invoice Portal',
        description: 'Generate & manage IRN e-invoices with QR code',
        route: RouteNames.reports,
        color: Colors.deepOrange,
      ),
      _GstToolItem(
        icon: Icons.local_shipping_outlined,
        title: 'E-Way Bill',
        description: 'Generate e-way bills for goods movement',
        route: RouteNames.reports,
        color: AppColors.primaryBlue,
      ),
      _GstToolItem(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Input Tax Credit (ITC)',
        description: 'Track eligible & claimed Input Tax Credit',
        route: RouteNames.reports,
        color: Colors.indigo,
      ),
      _GstToolItem(
        icon: Icons.settings_applications_outlined,
        title: 'Tax Settings',
        description: 'GSTIN, State Code, Tax rates & Composition scheme',
        route: RouteNames.taxGstSettings,
        color: AppColors.secondaryText,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GST & Taxation Hub'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GSTIN Information Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepNavy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('GSTIN / TAX PROFILE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                      Icon(Icons.verified_user_outlined, color: Colors.greenAccent, size: 18),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('27AAAAA0000A1Z5', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Regular GST Scheme', style: TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      const Text('State: Maharashtra (27)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Taxation & E-Filing Utilities',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tools.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (ctx, idx) {
                final item = tools[idx];
                return AppCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () {
                    if (item.route == RouteNames.taxGstSettings) {
                      context.push(item.route);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening ${item.title}...')),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, color: item.color, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.darkBlueText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
}

class _GstToolItem {
  final IconData icon;
  final String title;
  final String description;
  final String route;
  final Color color;

  _GstToolItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
    required this.color,
  });
}
