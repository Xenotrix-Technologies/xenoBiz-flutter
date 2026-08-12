import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class PurchaseManagementPage extends StatelessWidget {
  const PurchaseManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Purchase Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: () {
              context.push(RouteNames.supplierDirectory);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          context.push(RouteNames.createPurchaseOrder);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('PO-2026-088', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('Supplier: TechHardware Distributors Ltd', style: TextStyle(color: AppColors.outline, fontSize: 13)),
                  ],
                ),
                const Text('₹62,000', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
