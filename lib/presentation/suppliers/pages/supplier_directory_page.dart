import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class SupplierDirectoryPage extends StatelessWidget {
  const SupplierDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Supplier Directory'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            onTap: () => context.push(RouteNames.supplierDetails),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('TechHardware Distributors Ltd', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('+91 98950 12345 • Kalamassery, Kochi', style: TextStyle(color: AppColors.outline, fontSize: 13)),
                  ],
                ),
                const Text('₹42,000 Due', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
