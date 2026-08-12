import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/subscription_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class SubscriptionPaywallPage extends StatelessWidget {
  const SubscriptionPaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Unlock XenoBiz Pro'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.secondary, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('7-Day Free Trial Active', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        SizedBox(height: 2),
                        Text('Unlimited access to GST Invoicing, Inventory & CRM', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _PlanCard(
              title: 'Pro Monthly Plan',
              price: '₹499 / mo',
              description: 'Full business suite for growing merchants & store owners',
              isPopular: true,
              onTap: () {
                context.read<SubscriptionBloc>().add(
                      const PurchasePlanEvent(businessId: 'biz_101', planId: 'pro_monthly'),
                    );
                context.go(RouteNames.dashboard);
              },
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: 'Pro Annual Plan',
              price: '₹4,499 / yr',
              description: 'Save 25% with annual billing + priority support',
              isPopular: false,
              onTap: () {
                context.read<SubscriptionBloc>().add(
                      const PurchasePlanEvent(businessId: 'biz_101', planId: 'pro_annual'),
                    );
                context.go(RouteNames.dashboard);
              },
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Continue with Active Trial',
              variant: AppButtonVariant.outline,
              onPressed: () {
                context.go(RouteNames.dashboard);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final bool isPopular;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.description,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('MOST POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 12, color: AppColors.outline)),
        ],
      ),
    );
  }
}
