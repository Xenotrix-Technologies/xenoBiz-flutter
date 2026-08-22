import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Section 1: Account Information Controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Section 2: Owner Information Controllers
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Section 3: Business Information Controllers
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _gstinController = TextEditingController();

  // Dropdown selection
  String _selectedBusinessType = 'Retail Store';
  final List<String> _businessTypes = [
    'Retail Store',
    'Wholesale / Distributor',
    'Services & Consulting',
    'Manufacturing',
    'Restaurant / Food & Bev',
    'Other Business',
  ];

  // Focus Nodes for Auto-Scroll / Auto-Focus
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _ownerNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _shopNameFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _pinCodeFocus = FocusNode();

  // Component State
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    // Add listeners to trigger progress updates live as the user types
    _usernameController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
    _ownerNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _shopNameController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _stateController.addListener(_onFieldChanged);
    _pinCodeController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {}); // Triggers progress bar update
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _confirmPasswordController.removeListener(_onFieldChanged);
    _ownerNameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _shopNameController.removeListener(_onFieldChanged);
    _addressController.removeListener(_onFieldChanged);
    _cityController.removeListener(_onFieldChanged);
    _stateController.removeListener(_onFieldChanged);
    _pinCodeController.removeListener(_onFieldChanged);

    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _gstinController.dispose();

    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _ownerNameFocus.dispose();
    _phoneFocus.dispose();
    _shopNameFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _pinCodeFocus.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  // --- Dynamic Progress Calculation (10 Required Fields) ---
  bool _isUsernameValid() => _usernameController.text.trim().length >= 3;
  bool _isPasswordValid() => _passwordController.text.length >= 6;
  bool _isConfirmPasswordValid() =>
      _confirmPasswordController.text == _passwordController.text &&
      _confirmPasswordController.text.isNotEmpty;
  bool _isOwnerNameValid() => _ownerNameController.text.trim().length >= 2;
  bool _isPhoneValid() {
    final digits = _phoneController.text.trim();
    return digits.length == 10 && RegExp(r'^[0-9]{10}$').hasMatch(digits);
  }

  bool _isShopNameValid() => _shopNameController.text.trim().isNotEmpty;
  bool _isAddressValid() => _addressController.text.trim().isNotEmpty;
  bool _isCityValid() => _cityController.text.trim().isNotEmpty;
  bool _isStateValid() => _stateController.text.trim().isNotEmpty;
  bool _isPinCodeValid() {
    final pin = _pinCodeController.text.trim();
    return pin.length == 6 && RegExp(r'^[0-9]{6}$').hasMatch(pin);
  }

  int get _completedRequiredFieldsCount {
    int count = 0;
    if (_isUsernameValid()) count++;
    if (_isPasswordValid()) count++;
    if (_isConfirmPasswordValid()) count++;
    if (_isOwnerNameValid()) count++;
    if (_isPhoneValid()) count++;
    if (_isShopNameValid()) count++;
    if (_isAddressValid()) count++;
    if (_isCityValid()) count++;
    if (_isStateValid()) count++;
    if (_isPinCodeValid()) count++;
    return count;
  }

  double get _progressFraction => _completedRequiredFieldsCount / 10.0;

  void _onCreateAccountPressed() {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
    });

    // 1. Check first invalid field to focus & scroll
    if (!_isUsernameValid()) {
      _focusAndScroll(_usernameFocus);
      _validateForm();
      return;
    }
    if (!_isPasswordValid()) {
      _focusAndScroll(_passwordFocus);
      _validateForm();
      return;
    }
    if (!_isConfirmPasswordValid()) {
      _focusAndScroll(_confirmPasswordFocus);
      _validateForm();
      return;
    }
    if (!_isOwnerNameValid()) {
      _focusAndScroll(_ownerNameFocus);
      _validateForm();
      return;
    }
    if (!_isPhoneValid()) {
      _focusAndScroll(_phoneFocus);
      _validateForm();
      return;
    }
    if (!_isShopNameValid()) {
      _focusAndScroll(_shopNameFocus);
      _validateForm();
      return;
    }
    if (!_isAddressValid()) {
      _focusAndScroll(_addressFocus);
      _validateForm();
      return;
    }
    if (!_isCityValid()) {
      _focusAndScroll(_cityFocus);
      _validateForm();
      return;
    }
    if (!_isStateValid()) {
      _focusAndScroll(_stateFocus);
      _validateForm();
      return;
    }
    if (!_isPinCodeValid()) {
      _focusAndScroll(_pinCodeFocus);
      _validateForm();
      return;
    }

    // 2. Validate entire form
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // 3. Check Terms & Conditions
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                    'Please accept the Terms & Conditions and Privacy Policy to proceed.'),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 4. Submit Registration to AuthBloc
    final name = _ownerNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    context.read<AuthBloc>().add(
          RegisterSubmittedEvent(
            name: name,
            email: email.isNotEmpty ? email : ' ',
            phone: phone,
            password: password,
            shopName: _shopNameController.text.trim(),
            address: _addressController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
            pinCode: _pinCodeController.text.trim(),
            gstin: _gstinController.text.trim(),
            businessType: _selectedBusinessType,
          ),
        );
  }

  void _validateForm() {
    _formKey.currentState?.validate();
  }

  void _focusAndScroll(FocusNode node) {
    node.requestFocus();
    if (node.context != null) {
      Scrollable.ensureVisible(
        node.context!,
        duration: const Duration(milliseconds: 300),
        alignment: 0.2,
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.deepNavy,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildPhonePrefixWidget() {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone_outlined,
              size: AppSizes.iconSmall, color: AppColors.outline),
          const SizedBox(width: 8),
          const Text(
            '+91',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 22,
            color: AppColors.border,
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildEyeToggle(
      {required bool isVisible, required VoidCallback onToggle}) {
    return IconButton(
      icon: Icon(
        isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: isVisible ? AppColors.primary : AppColors.outline,
        size: 20,
      ),
      onPressed: onToggle,
      tooltip: isVisible ? 'Hide password' : 'Show password',
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completedRequiredFieldsCount;
    final progressPct = (completedCount * 10).toInt();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is RegistrationSuccessState) {
          context.go(RouteNames.registrationSuccess);
        } else if (state is AuthenticatedState) {
          context.go(RouteNames.dashboard);
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
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Header ---
                        Center(
                          child: Container(
                            width: 60,
                            height: 60,
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
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Center(
                          child: Text(
                            AppStrings.brandName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepNavy,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Center(
                          child: Text(
                            'Create Your Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Center(
                          child: Text(
                            'Setup your merchant billing & CRM workspace',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Dynamic Registration Progress Bar ---
                        Container(
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: AppColors.blueTint.withValues(alpha: 0.6),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMedium),
                            border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: const Text(
                                      'Registration Progress',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.deepNavy,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$progressPct% ($completedCount/10 completed)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                tween: Tween<double>(
                                    begin: 0.0, end: _progressFraction),
                                builder: (context, value, child) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusFull),
                                    child: LinearProgressIndicator(
                                      value: value,
                                      minHeight: 8,
                                      backgroundColor: AppColors.border,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              AppColors.primary),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- SECTION 1: ACCOUNT INFORMATION ---
                        _buildSectionHeader(
                            'Account Information', Icons.lock_outline),

                        AppTextField(
                          label: 'Username',
                          hint: 'Choose a unique username',
                          controller: _usernameController,
                          focusNode: _usernameFocus,
                          isRequired: true,
                          prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Username is required.';
                            }
                            if (val.trim().length < 3) {
                              return 'Username must be at least 3 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        AppTextField(
                          label: 'Password',
                          hint: 'Min. 6 characters',
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          isRequired: true,
                          obscureText: !_isPasswordVisible,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _buildEyeToggle(
                            isVisible: _isPasswordVisible,
                            onToggle: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Password is required.';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        AppTextField(
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          isRequired: true,
                          obscureText: !_isConfirmPasswordVisible,
                          prefixIcon: Icons.lock_clock_outlined,
                          suffixIcon: _buildEyeToggle(
                            isVisible: _isConfirmPasswordVisible,
                            onToggle: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please confirm your password.';
                            }
                            if (val != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // --- SECTION 2: OWNER INFORMATION ---
                        _buildSectionHeader(
                            'Owner Information', Icons.badge_outlined),

                        AppTextField(
                          label: 'Owner / Customer Name',
                          hint: 'e.g. Rahul Sharma',
                          controller: _ownerNameController,
                          focusNode: _ownerNameFocus,
                          isRequired: true,
                          prefixIcon: Icons.person_pin_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Owner name is required.';
                            }
                            if (val.trim().length < 2) {
                              return 'Owner name must be at least 2 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        AppTextField(
                          label: 'Phone Number',
                          hint: '10-digit mobile number',
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          isRequired: true,
                          prefix: _buildPhonePrefixWidget(),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Phone number is required.';
                            }
                            if (val.trim().length != 10 ||
                                !RegExp(r'^[0-9]{10}$').hasMatch(val.trim())) {
                              return 'Please enter a valid 10-digit mobile number.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        AppTextField(
                          label: 'Email (Optional)',
                          hint: 'e.g. owner@store.com',
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'Please enter a valid email address.';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // --- SECTION 3: BUSINESS INFORMATION ---
                        _buildSectionHeader(
                            'Business Information', Icons.store_outlined),

                        AppTextField(
                          label: 'Shop / Business Name',
                          hint: 'e.g. Apex Traders',
                          controller: _shopNameController,
                          focusNode: _shopNameFocus,
                          isRequired: true,
                          prefixIcon: Icons.business_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Shop / Business name is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        AppTextField(
                          label: 'Business Address',
                          hint: 'Street, Shop No., Landmark',
                          controller: _addressController,
                          focusNode: _addressFocus,
                          isRequired: true,
                          prefixIcon: Icons.location_on_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Business address is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'City',
                                hint: 'e.g. Mumbai',
                                controller: _cityController,
                                focusNode: _cityFocus,
                                isRequired: true,
                                prefixIcon: Icons.location_city_outlined,
                                textInputAction: TextInputAction.next,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'City is required.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'State',
                                hint: 'e.g. Maharashtra',
                                controller: _stateController,
                                focusNode: _stateFocus,
                                isRequired: true,
                                prefixIcon: Icons.map_outlined,
                                textInputAction: TextInputAction.next,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'State is required.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        AppTextField(
                          label: 'PIN Code',
                          hint: '6-digit PIN code',
                          controller: _pinCodeController,
                          focusNode: _pinCodeFocus,
                          isRequired: true,
                          prefixIcon: Icons.markunread_mailbox_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'PIN Code is required.';
                            }
                            if (val.trim().length != 6 ||
                                !RegExp(r'^[0-9]{6}$').hasMatch(val.trim())) {
                              return 'Enter a valid 6-digit PIN code.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Optional GSTIN
                        AppTextField(
                          label: 'GSTIN (Optional)',
                          hint: 'e.g. 27AAAAA0000A1Z5',
                          controller: _gstinController,
                          prefixIcon: Icons.receipt_long_outlined,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 14),

                        // Optional Business Type Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Business Type (Optional)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedBusinessType,
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.onSurface),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surfaceCard,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                prefixIcon: const Icon(Icons.category_outlined,
                                    size: AppSizes.iconSmall,
                                    color: AppColors.outline),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSmall),
                                  borderSide: const BorderSide(
                                      color: AppColors.outlineVariant,
                                      width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSmall),
                                  borderSide: const BorderSide(
                                      color: AppColors.secondary, width: 2.0),
                                ),
                              ),
                              items: _businessTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedBusinessType = val;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- TERMS & CONDITIONS CHECKBOX ---
                        InkWell(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusXs),
                          onTap: () {
                            setState(() {
                              _acceptTerms = !_acceptTerms;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _acceptTerms,
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _acceptTerms = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'I agree to the Terms & Conditions and Privacy Policy of XenoBiz Manager.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.deepNavy,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- CREATE ACCOUNT BUTTON ---
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return AppButton(
                              text: 'Create Account',
                              onPressed: _onCreateAccountPressed,
                              isLoading: state is AuthLoadingState,
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // --- BACK TO LOGIN ---
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go(RouteNames.login);
                                  }
                                },
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
