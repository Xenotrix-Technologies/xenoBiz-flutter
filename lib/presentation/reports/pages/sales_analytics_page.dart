import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class SalesAnalyticsPage extends StatelessWidget {
  const SalesAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales Analytics'),
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
                  Text('Total Sales Volume', style: TextStyle(fontSize: 13, color: AppColors.outline)),
                  SizedBox(height: 6),
                  Text('₹4,92,000', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  SizedBox(height: 4),
                  Text('64 Invoices Generated in August', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
