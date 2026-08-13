import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/auth_bloc.dart';
import '../../../application/bloc/dashboard_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/business_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../infrastructure/storage/hive_service.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _gstinController;
  late TextEditingController _logoUrlController;

  String _selectedCategory = 'General Store';
  String _selectedCurrency = '₹';
  String? _logoUrl;
  bool _isLoading = false;

  final List<String> _categories = [
    'General Store',
    'Retail Store',
    'Supermarket',
    'Pharmacy',
    'Electronics',
    'Clothing & Fashion',
    'Services',
    'Wholesale',
    'Restaurant',
    'Other',
  ];

  final List<Map<String, String>> _currencies = [
    {'symbol': '₹', 'label': '₹ (INR - Indian Rupee)'},
    {'symbol': '\$', 'label': '\$ (USD - US Dollar)'},
    {'symbol': '€', 'label': '€ (EUR - Euro)'},
    {'symbol': '£', 'label': '£ (GBP - British Pound)'},
    {'symbol': '¥', 'label': '¥ (JPY - Japanese Yen)'},
  ];

  final List<Map<String, String>> _presetLogos = [
    {
      'name': 'General Store',
      'url': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=200&q=80'
    },
    {
      'name': 'Supermarket',
      'url': 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=200&q=80'
    },
    {
      'name': 'Boutique',
      'url': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=200&q=80'
    },
    {
      'name': 'Electronics',
      'url': 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=200&q=80'
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _gstinController = TextEditingController();
    _logoUrlController = TextEditingController();

    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    setState(() => _isLoading = true);
    try {
      final hive = getIt<HiveService>();
      final bizBox = hive.getBox(HiveService.boxBusiness);

      String name = bizBox.get('name')?.toString() ?? '';
      String phone = bizBox.get('phone')?.toString() ?? '';
      String email = bizBox.get('email')?.toString() ?? '';
      String address = bizBox.get('address')?.toString() ?? '';
      String gstin = bizBox.get('gstin')?.toString() ?? '';
      String category = bizBox.get('category')?.toString() ?? 'General Store';
      String currency = bizBox.get('currency')?.toString() ?? '₹';
      String? logo = bizBox.get('logoUrl')?.toString();

      // If hive is empty, fetch from AuthRepository
      if (name.isEmpty) {
        final authRepo = getIt<AuthRepository>();
        final profile = await authRepo.getBusinessProfile();
        if (profile != null) {
          name = profile.name;
          phone = profile.phone;
          email = profile.email ?? '';
          address = profile.address;
          gstin = profile.gstin ?? '';
          category = profile.category.isNotEmpty ? profile.category : 'General Store';
          currency = profile.currency.isNotEmpty ? profile.currency : '₹';
          logo = profile.logoUrl;
        }
      }

      // Default fallback if brand new
      if (name.isEmpty) {
        name = 'XenoBiz';
      }

      if (!_categories.contains(category)) {
        _categories.add(category);
      }

      _nameController.text = name;
      _phoneController.text = phone;
      _emailController.text = email;
      _addressController.text = address;
      _gstinController.text = gstin;
      _selectedCategory = category;
      _selectedCurrency = currency;
      _logoUrl = logo;
      _logoUrlController.text = logo ?? '';
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  void _showLogoChangeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final customUrlController = TextEditingController(text: _logoUrl ?? '');
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Change Business Logo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose a preset store logo or enter a custom image URL:',
                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetLogos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final logo = _presetLogos[index];
                    final isSelected = _logoUrl == logo['url'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _logoUrl = logo['url'];
                          _logoUrlController.text = logo['url']!;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBlue : AppColors.border,
                            width: isSelected ? 2.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                logo['url']!,
                                width: 42,
                                height: 42,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 28),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              logo['name']!,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: customUrlController,
                decoration: InputDecoration(
                  labelText: 'Custom Logo Image URL',
                  hintText: 'https://example.com/logo.png',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_logoUrl != null && _logoUrl!.isNotEmpty) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _logoUrl = null;
                          _logoUrlController.clear();
                        });
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                      label: const Text('Remove Logo', style: TextStyle(color: AppColors.danger)),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final val = customUrlController.text.trim();
                        setState(() {
                          _logoUrl = val.isNotEmpty ? val : null;
                          _logoUrlController.text = val;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Apply Logo', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final hive = getIt<HiveService>();
      final bizBox = hive.getBox(HiveService.boxBusiness);

      final String updatedId = bizBox.get('id')?.toString() ?? 'biz_main';
      final String name = _nameController.text.trim();
      final String phone = _phoneController.text.trim();
      final String email = _emailController.text.trim();
      final String address = _addressController.text.trim();
      final String gstin = _gstinController.text.trim();
      final String? logo = _logoUrl;

      // Write directly to Hive box to ensure immediate local update
      await bizBox.put('id', updatedId);
      await bizBox.put('name', name);
      await bizBox.put('phone', phone);
      await bizBox.put('email', email);
      await bizBox.put('address', address);
      await bizBox.put('gstin', gstin);
      await bizBox.put('category', _selectedCategory);
      await bizBox.put('currency', _selectedCurrency);
      if (logo != null && logo.isNotEmpty) {
        await bizBox.put('logoUrl', logo);
      } else {
        await bizBox.delete('logoUrl');
      }

      final updatedEntity = BusinessEntity(
        id: updatedId,
        name: name,
        phone: phone,
        email: email.isNotEmpty ? email : null,
        address: address,
        gstin: gstin.isNotEmpty ? gstin : null,
        category: _selectedCategory,
        currency: _selectedCurrency,
        logoUrl: logo,
        createdAt: DateTime.now(),
      );

      if (!mounted) return;

      // Dispatch event to AuthBloc to update app state
      context.read<AuthBloc>().add(BusinessSetupSubmittedEvent(updatedEntity));

      // Refresh Dashboard data
      context.read<DashboardBloc>().add(FetchDashboardDataEvent());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update business profile: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'BS';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _buildLogoAvatar() {
    Widget avatarChild;

    if (_logoUrl != null && _logoUrl!.trim().isNotEmpty) {
      final url = _logoUrl!.trim();
      if (url.startsWith('http://') || url.startsWith('https://')) {
        avatarChild = Image.network(
          url,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackInitials(),
        );
      } else if (url.startsWith('assets/')) {
        avatarChild = Image.asset(
          url,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackInitials(),
        );
      } else {
        avatarChild = _buildFallbackInitials();
      }
    } else {
      avatarChild = _buildFallbackInitials();
    }

    return Stack(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.deepNavy,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepNavy.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: avatarChild,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _showLogoChangeBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackInitials() {
    return Text(
      _getInitials(_nameController.text),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Business Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkBlueText,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Business Logo Display & Edit Trigger
                    _buildLogoAvatar(),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _showLogoChangeBottomSheet,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text(
                        'Change Store Logo',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Store Details Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business & Store Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Business Name
                          TextFormField(
                            controller: _nameController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Business / Store Name *',
                              prefixIcon: const Icon(Icons.storefront_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter business name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Industry Category
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Industry Category',
                              prefixIcon: const Icon(Icons.category_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            items: _categories
                                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCategory = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Currency Selector
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCurrency,
                            decoration: InputDecoration(
                              labelText: 'Currency Symbol',
                              prefixIcon: const Icon(Icons.monetization_on_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            items: _currencies
                                .map((curr) => DropdownMenuItem(
                                      value: curr['symbol'],
                                      child: Text(curr['label']!),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCurrency = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contact & Legal Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contact & Billing Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Phone Number
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Business Address
                          TextFormField(
                            controller: _addressController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Business Address',
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // GSTIN / Tax Number
                          TextFormField(
                            controller: _gstinController,
                            decoration: InputDecoration(
                              labelText: 'GSTIN / Tax Number (Optional)',
                              prefixIcon: const Icon(Icons.receipt_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text(
                          'Save Profile Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
