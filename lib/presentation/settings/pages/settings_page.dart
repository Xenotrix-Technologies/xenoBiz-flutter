import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              onTap: () => context.push(RouteNames.subscription),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: AppColors.secondary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Subscription & Entitlement', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text('7-Day Free Trial Active', style: TextStyle(color: AppColors.outline, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outline),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              onTap: () => context.push(RouteNames.offlineSync),
              child: Row(
                children: [
                  const Icon(Icons.sync, color: AppColors.primary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Offline Sync Center', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text('Manage pending queue & connection', style: TextStyle(color: AppColors.outline, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outline),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Sign Out / Switch Account',
              variant: AppButtonVariant.outline,
              icon: Icons.logout,
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
                context.go(RouteNames.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
