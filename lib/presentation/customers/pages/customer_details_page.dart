import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class CustomerDetailsPage extends StatelessWidget {
  const CustomerDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu),
            onPressed: () {
              context.push(RouteNames.customerTimeline);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryContainer,
                    child: const Text(
                      'A',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Apex Technologies Pvt Ltd',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '+91 98470 11223 • finance@apextech.in',
                    style: TextStyle(fontSize: 13, color: AppColors.outline),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerLow,
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push(RouteNames.whatsappTemplates);
                        },
                        icon: const Icon(Icons.chat, size: 18),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successContainer,
                          foregroundColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Outstanding', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                        SizedBox(height: 6),
                        Text('₹14,500', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.error)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Total Lifetime Sales', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                        SizedBox(height: 6),
                        Text('₹1,85,000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.success)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'View Full Activity Timeline',
              icon: Icons.timeline,
              onPressed: () {
                context.push(RouteNames.customerTimeline);
              },
            ),
          ],
        ),
      ),
    );
  }
}
