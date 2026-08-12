import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class SalesOverviewPage extends StatelessWidget {
  const SalesOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sales Overview'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('August 2026 Revenue', style: TextStyle(fontSize: 13, color: AppColors.outline)),
                  SizedBox(height: 6),
                  Text('₹4,92,000', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  SizedBox(height: 4),
                  Text('+18.4% growth vs July', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Weekly Sales Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            AppCard(
              child: SizedBox(
                height: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    _Bar('Mon', 0.4),
                    _Bar('Tue', 0.65),
                    _Bar('Wed', 0.8),
                    _Bar('Thu', 0.5),
                    _Bar('Fri', 0.95),
                    _Bar('Sat', 0.85),
                    _Bar('Sun', 0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double heightPct;
  const _Bar(this.label, this.heightPct);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 130 * heightPct,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
