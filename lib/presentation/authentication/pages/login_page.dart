import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../const/strings.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin');

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    if (email.isNotEmpty && pass.isNotEmpty) {
      context.read<AuthBloc>().add(LoginSubmittedEvent(emailOrPhone: email, password: pass));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your username/email and password.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _showRegisterDialog() {
    final regNameCtrl = TextEditingController();
    final regEmailPhoneCtrl = TextEditingController();
    final regPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Register New Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Full Name / Business Owner',
                hint: 'e.g. John Doe',
                controller: regNameCtrl,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Username / Email / Mobile',
                hint: 'e.g. merchant@xenobiz.com',
                controller: regEmailPhoneCtrl,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Password',
                hint: 'Create password',
                controller: regPassCtrl,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final name = regNameCtrl.text.trim();
              final identifier = regEmailPhoneCtrl.text.trim();
              final pass = regPassCtrl.text.trim();

              if (identifier.isNotEmpty && pass.isNotEmpty) {
                Navigator.pop(dialogCtx);
                context.read<AuthBloc>().add(
                      RegisterSubmittedEvent(
                        name: name.isNotEmpty ? name : 'Merchant',
                        email: identifier.contains('@') ? identifier : '',
                        phone: !identifier.contains('@') ? identifier : '',
                        password: pass,
                      ),
                    );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username/Email and Password are required.'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            child: const Text('Register Account'),
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
        } else if (state is BusinessSetupRequiredState) {
          context.go(RouteNames.onboarding);
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    ),
                    child: const Icon(Icons.storefront, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    AppStrings.loginTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    AppStrings.loginSubtitle,
                    style: TextStyle(fontSize: 14, color: AppColors.outline),
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: AppStrings.emailOrPhoneLabel,
                  hint: 'Username / Email / Mobile (e.g. admin)',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.passwordLabel,
                  hint: 'Enter password (e.g. admin)',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 28),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        AppButton(
                          text: AppStrings.loginButton,
                          onPressed: _onLoginPressed,
                          isLoading: state is AuthLoadingState,
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          text: 'Register New Account',
                          variant: AppButtonVariant.outline,
                          icon: Icons.person_add_outlined,
                          onPressed: _showRegisterDialog,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
