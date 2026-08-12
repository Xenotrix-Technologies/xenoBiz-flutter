import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class InventoryAnalyticsPage extends StatelessWidget {
  const InventoryAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Total Inventory Valuation', style: TextStyle(fontSize: 13, color: AppColors.outline)),
                  SizedBox(height: 6),
                  Text('₹3,84,500', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
