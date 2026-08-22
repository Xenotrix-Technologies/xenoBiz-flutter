import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class PlansAndPricingPage extends StatelessWidget {
  const PlansAndPricingPage({super.key});

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_rounded,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanUnavailableSnackbar(BuildContext context, String planName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('$planName plan selection will be available soon.'),
            ),
          ],
        ),
        backgroundColor: AppColors.deepNavy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar with Back button & Title
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              size: 24,
                              color: AppColors.deepNavy,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(RouteNames.trialWelcome);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Plans & Pricing',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepNavy,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Plan 1: Trial (Free, Active) ---
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.blueTint,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Trial',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                              Text(
                                'Free',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCheckItem('7 days full access'),
                          _buildCheckItem('Billing & invoicing'),
                          _buildCheckItem('CRM & follow-ups'),
                          _buildCheckItem('Basic reports'),
                          const SizedBox(height: 20),
                          AppButton(
                            text: 'Currently Active',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Plan 2: Basic (₹499/mo) ---
                    AppCard(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Basic',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                              Text(
                                '₹499/mo',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCheckItem('Unlimited invoices'),
                          _buildCheckItem('Up to 500 customers'),
                          _buildCheckItem('CRM follow-ups'),
                          _buildCheckItem('Email support'),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () => _showPlanUnavailableSnackbar(
                                context, 'Basic'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium),
                              ),
                            ),
                            child: const Text(
                              'Choose Basic',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Plan 3: Pro (₹999/mo, MOST POPULAR) ---
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF0284C7),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Pro',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.deepNavy,
                                    ),
                                  ),
                                  Text(
                                    '₹999/mo',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.deepNavy,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildCheckItem('Everything in Basic'),
                              _buildCheckItem('Unlimited customers'),
                              _buildCheckItem('Sales pipeline & analytics'),
                              _buildCheckItem('WhatsApp invoice sharing'),
                              _buildCheckItem('Priority support'),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _showPlanUnavailableSnackbar(
                                    context, 'Pro'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  backgroundColor: const Color(0xFF0284C7),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMedium),
                                  ),
                                ),
                                child: const Text(
                                  'Choose Pro',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -12,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.deepNavy,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'MOST POPULAR',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Plan 4: Business (₹1999/mo) ---
                    AppCard(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Business',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                              Text(
                                '₹1999/mo',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCheckItem('Everything in Pro'),
                          _buildCheckItem('Multi-user access'),
                          _buildCheckItem('Multi-branch inventory'),
                          _buildCheckItem('Dedicated account manager'),
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: () => _showPlanUnavailableSnackbar(
                                context, 'Business'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium),
                              ),
                            ),
                            child: const Text(
                              'Choose Business',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          'Continue Trial instead',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
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
