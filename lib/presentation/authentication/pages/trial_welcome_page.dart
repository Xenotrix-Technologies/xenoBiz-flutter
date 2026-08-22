import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class TrialWelcomePage extends StatelessWidget {
  const TrialWelcomePage({super.key});

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required List<String> bulletItems,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...bulletItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          context.go(RouteNames.dashboard);
        } else if (state is UnauthenticatedState) {
          context.go(RouteNames.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top welcome badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Welcome to XenoBiz',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main Header Title
                    const Text(
                      'Manage billing, customers and sales – from one place',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepNavy,
                        letterSpacing: -0.4,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      "Here's what's included in your trial.",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feature Card 1: Billing
                    _buildFeatureCard(
                      icon: Icons.receipt_long_outlined,
                      iconBgColor: AppColors.blueTint,
                      iconColor: AppColors.primary,
                      title: 'Billing',
                      bulletItems: const [
                        'Create invoices',
                        'Manage products & services',
                        'Track payments',
                        'View sales',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Feature Card 2: CRM
                    _buildFeatureCard(
                      icon: Icons.people_outline,
                      iconBgColor: AppColors.successTint,
                      iconColor: AppColors.success,
                      title: 'CRM',
                      bulletItems: const [
                        'Manage leads',
                        'Follow-ups',
                        'Customer profiles',
                        'Sales pipeline',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Feature Card 3: Business Insights
                    _buildFeatureCard(
                      icon: Icons.bar_chart_rounded,
                      iconBgColor: AppColors.warningTint,
                      iconColor: AppColors.warning,
                      title: 'Business Insights',
                      bulletItems: const [
                        'Revenue overview',
                        'Outstanding payments',
                        'Sales analytics',
                        'Reports',
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Action Button 1: Continue to Trial -> Completes Onboarding & Opens Dashboard
                    AppButton(
                      text: 'Continue to Trial',
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(CompleteTrialOnboardingEvent());
                      },
                    ),
                    const SizedBox(height: 12),

                    // Action Button 2: View Plans -> Opens Plans & Pricing
                    AppButton(
                      text: 'View Plans',
                      variant: AppButtonVariant.outline,
                      onPressed: () {
                        context.go(RouteNames.plansAndPricing);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Text Buttons: Continue Trial & Skip for now

                    Center(
                      child: TextButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(CompleteTrialOnboardingEvent());
                        },
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
