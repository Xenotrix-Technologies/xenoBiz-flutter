import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../const/strings.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Login Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();

  // Component State
  bool _isRegisterMode = false;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isRegPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regEmailPhoneController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    if (email.isNotEmpty && pass.isNotEmpty) {
      context
          .read<AuthBloc>()
          .add(LoginSubmittedEvent(emailOrPhone: email, password: pass));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your username/email and password.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _onRegisterPressed() {
    final name = _regNameController.text.trim();
    final identifier = _regEmailPhoneController.text.trim();
    final pass = _regPasswordController.text.trim();

    if (identifier.isNotEmpty && pass.isNotEmpty) {
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
          content: Text(
              'Username/Email and Password are required for registration.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetController =
        TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        backgroundColor: AppColors.surfaceCard,
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.deepNavy,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered username or email to receive password reset instructions.',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Username or Email',
              hint: 'e.g. merchant@xenobiz.com',
              controller: resetController,
              prefixIcon: Icons.email_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Password reset link sent to your registered email/mobile.'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send Reset Instructions'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        backgroundColor: AppColors.surfaceCard,
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Authentication Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepNavy,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.vpn_key_outlined,
              title: 'Forgot Credentials?',
              description:
                  'Use the "Forgot password?" link on the login form to reset your password.',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              icon: Icons.person_add_alt_outlined,
              title: 'New Merchant Setup',
              description:
                  'Tap "Register New Account" to set up your business workspace.',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              icon: Icons.wifi_off_outlined,
              title: 'Offline Billing Ready',
              description:
                  'XenoBiz saves your sales offline. Reconnect anytime to auto-sync with the cloud.',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              icon: Icons.headset_mic_outlined,
              title: 'Customer Helpdesk',
              description:
                  'Need assistance? Email support@xenobiz.local or call 1800-XENOBIZ.',
            ),
          ],
        ),
        actions: [
          AppButton(
            text: 'Got It',
            height: AppSizes.buttonHeightSmall,
            onPressed: () => Navigator.pop(dialogCtx),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
      {required IconData icon,
      required String title,
      required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShowHideToggle(
      {required bool isVisible, required VoidCallback onToggle}) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Text(
          isVisible ? 'HIDE' : 'SHOW',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText.withValues(alpha: 0.8),
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          context.go(RouteNames.dashboard);
        } else if (state is RegistrationSuccessState) {
          context.go(RouteNames.registrationSuccess);
        } else if (state is TrialOnboardingRequiredState) {
          context.go(RouteNames.trialWelcome);
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
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: AppCard(
                    key: ValueKey<bool>(_isRegisterMode),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Logo
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLarge),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2. App Name
                        const Center(
                          child: Text(
                            AppStrings.brandName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepNavy,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // 3. Subtitle / Tagline
                        const Center(
                          child: Text(
                            AppStrings.brandTagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Form Fields depending on mode
                        if (!_isRegisterMode) ...[
                          // 4. Login: Username or Email
                          AppTextField(
                            label: AppStrings.emailOrPhoneLabel,
                            hint: 'Enter your username or email',
                            controller: _emailController,
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // 5. Login: Password
                          AppTextField(
                            label: AppStrings.passwordLabel,
                            hint: 'Enter your password',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline,
                            obscureText: !_isPasswordVisible,
                            suffixIcon: _buildShowHideToggle(
                              isVisible: _isPasswordVisible,
                              onToggle: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 6. Login: Remember me + Forgot password?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusXs),
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: AppColors.primary,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              _rememberMe = val ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        AppStrings.rememberMe,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.deepNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: _showForgotPasswordDialog,
                                child: const Text(
                                  AppStrings.forgotPassword,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 7. Login Primary Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return AppButton(
                                text: AppStrings.loginButton,
                                onPressed: _onLoginPressed,
                                isLoading: state is AuthLoadingState,
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // 8. Divider with "or"
                          _buildDivider(),
                          const SizedBox(height: 20),

                          // 9. Register Secondary Outlined Button
                          AppButton(
                            text: AppStrings.registerButton,
                            variant: AppButtonVariant.outline,
                            onPressed: () {
                              context.push(RouteNames.register);
                            },
                          ),
                          const SizedBox(height: 20),

                          // 10. Bottom Action: Need help logging in?
                          Center(
                            child: TextButton(
                              onPressed: _showHelpDialog,
                              child: const Text(
                                AppStrings.needHelpLoggingIn,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // 4. Register: Full Name / Business Owner
                          AppTextField(
                            label: 'Full Name / Business Owner',
                            hint: 'e.g. John Doe',
                            controller: _regNameController,
                            prefixIcon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),

                          // 5. Register: Username / Email / Mobile
                          AppTextField(
                            label: 'Username or Email',
                            hint: 'e.g. merchant@xenobiz.com',
                            controller: _regEmailPhoneController,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // 6. Register: Password
                          AppTextField(
                            label: AppStrings.passwordLabel,
                            hint: 'Create password',
                            controller: _regPasswordController,
                            prefixIcon: Icons.lock_outline,
                            obscureText: !_isRegPasswordVisible,
                            suffixIcon: _buildShowHideToggle(
                              isVisible: _isRegPasswordVisible,
                              onToggle: () {
                                setState(() {
                                  _isRegPasswordVisible =
                                      !_isRegPasswordVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 7. Register Primary Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return AppButton(
                                text: AppStrings.registerButton,
                                onPressed: _onRegisterPressed,
                                isLoading: state is AuthLoadingState,
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // 8. Divider with "or"
                          _buildDivider(),
                          const SizedBox(height: 20),

                          // 9. Login Secondary Outlined Button
                          AppButton(
                            text: AppStrings.loginButton,
                            variant: AppButtonVariant.outline,
                            onPressed: () {
                              setState(() {
                                _isRegisterMode = false;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // 10. Bottom Action: Need help signing in?
                          Center(
                            child: TextButton(
                              onPressed: _showHelpDialog,
                              child: const Text(
                                AppStrings.needHelpSigningIn,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
