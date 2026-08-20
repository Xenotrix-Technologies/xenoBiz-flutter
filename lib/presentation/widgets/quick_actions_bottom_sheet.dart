import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../application/routing/route_names.dart';
import '../../const/colors.dart';
import '../invoices/pages/return_voucher_screen.dart';

class QuickActionsBottomSheet extends StatelessWidget {
  const QuickActionsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickActionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const creamBg = Color(0xFFF1F4E8);
    const blueBg = Color(0xFFE6F5FC);
    const darkText = AppColors.deepNavy;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Quick actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
          const SizedBox(height: 20),

          // Row 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickActionGridItem(
                icon: Icons.description_outlined,
                label: 'New Invoice',
                bgColor: blueBg,
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.createInvoice);
                },
              ),
              _QuickActionGridItem(
                icon: Icons.shopping_cart_outlined,
                label: 'Add Purchase',
                bgColor: creamBg,
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.createPurchaseOrder);
                },
              ),
              _QuickActionGridItem(
                icon: Icons.arrow_downward_rounded,
                label: 'Add Income',
                bgColor: creamBg,
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.income);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Row 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickActionGridItem(
                icon: Icons.arrow_upward_rounded,
                label: 'Add Expense',
                bgColor: creamBg,
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.expense);
                },
              ),
              _QuickActionGridItem(
                icon: Icons.assignment_return_outlined,
                label: 'Sales Return',
                bgColor: creamBg,
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    RouteNames.createReturn,
                    extra: {'returnType': ReturnType.salesReturn},
                  );
                },
              ),
              _QuickActionGridItem(
                icon: Icons.settings_backup_restore_outlined,
                label: 'Purchase Return',
                bgColor: creamBg,
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    RouteNames.createReturn,
                    extra: {'returnType': ReturnType.purchaseReturn},
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Wide full-width button: Add Follow-up
          InkWell(
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.followUps);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: creamBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.access_time_rounded, size: 24, color: darkText),
                  SizedBox(width: 14),
                  Text(
                    'Add Follow-up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _QuickActionGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionGridItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Icon(icon, size: 26, color: AppColors.deepNavy),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.deepNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
