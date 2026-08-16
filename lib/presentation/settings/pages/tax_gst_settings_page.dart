import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/bloc/tax_settings_bloc.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/tax_settings_entity.dart';
import '../../widgets/app_card.dart';


const List<String> _indianStates = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
  'Delhi (NCT)',
  'Jammu & Kashmir',
  'Ladakh',
  'Puducherry',
  'Chandigarh',
  'Dadra and Nagar Haveli and Daman and Diu',
  'Andaman and Nicobar Islands',
  'Lakshadweep',
];

class TaxGstSettingsPage extends StatefulWidget {
  const TaxGstSettingsPage({super.key});

  @override
  State<TaxGstSettingsPage> createState() => _TaxGstSettingsPageState();
}

class _TaxGstSettingsPageState extends State<TaxGstSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const FetchProductsEvent());
  }

  void _saveSettings(TaxSettingsEntity newSettings) {
    context.read<TaxSettingsBloc>().add(UpdateTaxSettingsEvent(newSettings));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tax & GST settings saved successfully'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDisableGstWarningDialog(TaxSettingsEntity currentSettings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Disable GST Billing?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Disabling GST will convert the application into a Non-GST billing system. '
          'New invoices and product screens will omit GST rates, tax amounts, and CGST/SGST breakdown lines.\n\n'
          'Existing product tax configurations will be preserved in storage and restored if GST is enabled again.',
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TaxSettingsBloc>().add(const ToggleGstEnabledEvent(false));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('GST disabled. Invoices will run in Non-GST mode.'),
                  backgroundColor: AppColors.darkBlueText,
                ),
              );
            },
            child: const Text('Disable GST'),
          ),
        ],
      ),
    );
  }

  void _showCustomRateDialog(TaxSettingsEntity currentSettings) {
    final rateCtrl = TextEditingController(
      text: currentSettings.defaultGstRate.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Configure Custom GST Rate',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter custom default tax percentage (0% to 100%):',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rateCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Default GST Percentage (%)',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final val = double.tryParse(rateCtrl.text.trim());
              if (val != null && val >= 0 && val <= 100) {
                _saveSettings(currentSettings.copyWith(defaultGstRate: val));
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid rate between 0% and 100%'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Apply Rate'),
          ),
        ],
      ),
    );
  }

  void _showEditProductTaxDialog(ProductEntity product) {
    final taxCtrl = TextEditingController(
      text: (product.taxPercentage ?? 18.0).toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Product Tax Rate - ${product.name}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set specific GST rate for ${product.name} (SKU: ${product.sku}):',
              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: taxCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'GST Rate (%)',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final val = double.tryParse(taxCtrl.text.trim());
              if (val != null && val >= 0 && val <= 100) {
                final updated = product.copyWith(taxPercentage: val);
                context.read<ProductBloc>().add(UpdateProductEvent(updated));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} tax rate updated to ${val.toStringAsFixed(0)}%'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid percentage. Must be between 0% and 100%'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Save Rate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tax & GST Settings',
          style: TextStyle(color: AppColors.darkBlueText, fontWeight: FontWeight.w700),
        ),
        foregroundColor: AppColors.darkBlueText,
        forceMaterialTransparency: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<TaxSettingsBloc, TaxSettingsState>(
        builder: (context, state) {
          if (state is TaxSettingsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          TaxSettingsEntity settings = const TaxSettingsEntity();
          if (state is TaxSettingsLoadedState) {
            settings = state.settings;
          }

          final commonRates = [0.0, 5.0, 12.0, 18.0, 28.0];
          final isCustomRate = !commonRates.contains(settings.defaultGstRate);

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1: Tax / GST Main Settings
                  _buildSectionHeader('Tax / GST Main Settings', Icons.receipt_long),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enable GST Toggle Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: settings.isGstEnabled
                                    ? AppColors.successTint
                                    : AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                settings.isGstEnabled
                                    ? Icons.check_circle_outline
                                    : Icons.do_not_disturb_on_outlined,
                                color: settings.isGstEnabled
                                    ? AppColors.success
                                    : AppColors.secondaryText,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'GST / Tax Enabled',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.darkBlueText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    settings.isGstEnabled
                                        ? 'GST mode active for invoicing & pricing'
                                        : 'Non-GST mode active (tax disabled)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: settings.isGstEnabled
                                          ? AppColors.success
                                          : AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: settings.isGstEnabled,
                              activeThumbColor: AppColors.primary,
                              onChanged: (val) {
                                if (!val) {
                                  _showDisableGstWarningDialog(settings);
                                } else {
                                  context
                                      .read<TaxSettingsBloc>()
                                      .add(const ToggleGstEnabledEvent(true));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('GST Enabled for billing'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        if (settings.isGstEnabled) ...[
                          const Divider(height: 24),
                          // Default GST Rate Selector
                          const Text(
                            'Default GST Rate',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Applies automatically to new products and invoices unless overridden per product.',
                            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...commonRates.map((rate) {
                                final isSelected =
                                    settings.defaultGstRate == rate && !isCustomRate;
                                return ChoiceChip(
                                  label: Text('${rate.toStringAsFixed(0)}%'),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.darkBlueText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      _saveSettings(
                                          settings.copyWith(defaultGstRate: rate));
                                    }
                                  },
                                );
                              }),
                              ChoiceChip(
                                label: Text(
                                  isCustomRate
                                      ? 'Custom (${settings.defaultGstRate.toStringAsFixed(0)}%)'
                                      : 'Custom Rate',
                                ),
                                selected: isCustomRate,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isCustomRate ? Colors.white : AppColors.darkBlueText,
                                  fontWeight: FontWeight.w700,
                                ),
                                onSelected: (_) {
                                  _showCustomRateDialog(settings);
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Tax Included in Price Toggle
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Product Price Includes Tax',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkBlueText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      settings.isTaxIncludedInPrice
                                          ? 'ON: Entered selling price already includes GST (Inclusive)'
                                          : 'OFF: Entered selling price is before GST (Exclusive)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: settings.isTaxIncludedInPrice,
                                activeThumbColor: AppColors.primary,
                                onChanged: (val) {
                                  _saveSettings(
                                      settings.copyWith(isTaxIncludedInPrice: val));
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Show Tax Details on Invoice Toggle
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Show GST Details on Invoice',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkBlueText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      settings.showTaxDetailsOnInvoice
                                          ? 'ON: Renders full CGST/SGST/IGST breakdown on generated invoice'
                                          : 'OFF: Shows total invoice amount only (hides breakdown)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: settings.showTaxDetailsOnInvoice,
                                activeThumbColor: AppColors.primary,
                                onChanged: (val) {
                                  _saveSettings(
                                      settings.copyWith(showTaxDetailsOnInvoice: val));
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SECTION 2: Tax Calculation
                  if (settings.isGstEnabled) ...[
                    _buildSectionHeader('Tax Calculation', Icons.calculate),
                    const SizedBox(height: 8),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business State',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Determines whether sales are Intra-State (CGST+SGST) or Inter-State (IGST).',
                            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.pageBackground,
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _indianStates.contains(settings.businessState)
                                    ? settings.businessState
                                    : 'Maharashtra',
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                items: _indianStates.map((st) {
                                  return DropdownMenuItem<String>(
                                    value: st,
                                    child: Text(
                                      st,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkBlueText,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    _saveSettings(settings.copyWith(businessState: val));
                                  }
                                },
                              ),
                            ),
                          ),
                          const Divider(height: 24),
                          const Text(
                            'Default Tax Calculation Mode',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildCalcModeTile(
                                title: 'CGST + SGST',
                                subtitle: 'Intra-state sales (${(settings.defaultGstRate / 2).toStringAsFixed(1)}% + ${(settings.defaultGstRate / 2).toStringAsFixed(1)}%)',
                                isSelected: settings.taxCalculationType == 'CGST + SGST',
                                onTap: () => _saveSettings(
                                    settings.copyWith(taxCalculationType: 'CGST + SGST')),
                              ),
                              const SizedBox(width: 10),
                              _buildCalcModeTile(
                                title: 'IGST',
                                subtitle: 'Inter-state sales (${settings.defaultGstRate.toStringAsFixed(0)}% IGST)',
                                isSelected: settings.taxCalculationType == 'IGST',
                                onTap: () => _saveSettings(
                                    settings.copyWith(taxCalculationType: 'IGST')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 4: Product Tax Settings
                    _buildSectionHeader('Product Tax Settings', Icons.inventory_2),
                    const SizedBox(height: 8),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Product Specific Tax Rates',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkBlueText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Default global rate: ${settings.defaultGstRate.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder<ProductBloc, ProductState>(
                            builder: (context, pState) {
                              if (pState is ProductLoadingState) {
                                return const Center(
                                    child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ));
                              }
                              if (pState is ProductsLoadedState) {
                                if (pState.products.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Text(
                                      'No products catalog found. Add products to set individual rates.',
                                      style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                                    ),
                                  );
                                }
                                return Column(
                                  children: pState.products.map((prod) {
                                    final rate = prod.taxPercentage ?? settings.defaultGstRate;
                                    final isCustom = prod.taxPercentage != null;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.pageBackground,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  prod.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                    color: AppColors.darkBlueText,
                                                  ),
                                                ),
                                                Text(
                                                  'SKU: ${prod.sku} • ₹${prod.sellingPrice.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.secondaryText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isCustom
                                                  ? AppColors.primary
                                                  : AppColors.surfaceContainerHigh,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'GST ${rate.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: isCustom ? Colors.white : AppColors.darkBlueText,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                                            onPressed: () => _showEditProductTaxDialog(prod),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlueText,
          ),
        ),
      ],
    );
  }

  Widget _buildCalcModeTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blueTint : AppColors.pageBackground,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 18,
                    color: isSelected ? AppColors.primary : AppColors.secondaryText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppColors.primary : AppColors.darkBlueText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
