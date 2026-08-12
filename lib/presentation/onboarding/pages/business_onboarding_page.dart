import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/strings.dart';
import '../../../domain/entities/business_entity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class BusinessOnboardingPage extends StatefulWidget {
  const BusinessOnboardingPage({super.key});

  @override
  State<BusinessOnboardingPage> createState() => _BusinessOnboardingPageState();
}

class _BusinessOnboardingPageState extends State<BusinessOnboardingPage> {
  final _nameController = TextEditingController();
  final _gstinController = TextEditingController();
  String _category = 'Retail Store';

  void _onCompleteSetup() {
    if (_nameController.text.trim().isNotEmpty) {
      final business = BusinessEntity(
        id: 'biz_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        phone: '+91 98470 11223',
        address: 'Kochi, Kerala',
        gstin: _gstinController.text.trim().isNotEmpty ? _gstinController.text.trim() : null,
        category: _category,
        createdAt: DateTime.now(),
      );
      context.read<AuthBloc>().add(BusinessSetupSubmittedEvent(business));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          context.go(RouteNames.dashboard);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.onboardingTitle),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.onboardingSubtitle,
                style: TextStyle(fontSize: 14, color: AppColors.outline),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: AppStrings.businessNameLabel,
                hint: 'e.g. Apex Hardware & POS Solutions',
                controller: _nameController,
                prefixIcon: Icons.store,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: AppStrings.gstinLabel,
                controller: _gstinController,
                prefixIcon: Icons.receipt_long,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: AppStrings.categoryLabel,
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: ['Retail Store', 'Wholesale Trader', 'Service Business', 'Manufacturing']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 32),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AppButton(
                    text: AppStrings.setupButton,
                    onPressed: _onCompleteSetup,
                    isLoading: state is AuthLoadingState,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
