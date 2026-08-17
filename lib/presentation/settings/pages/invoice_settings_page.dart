import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/app_providers.dart';
import '../../../const/colors.dart';
import '../../widgets/app_card.dart';

class InvoiceSettingsPage extends ConsumerWidget {
  const InvoiceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(invoiceDisplaySettingsProvider);
    final notifier = ref.read(invoiceDisplaySettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Invoice Settings',
          style: TextStyle(color: AppColors.darkBlueText, fontWeight: FontWeight.w700),
        ),
        foregroundColor: AppColors.darkBlueText,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION: Business Information
            _buildSectionHeader('Business Information', Icons.storefront_outlined),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _buildToggleTile(
                    'Business Logo',
                    'Display store logo icon on mobile & printed invoice',
                    settings.showLogo,
                    (val) => notifier.updateSettings(settings.copyWith(showLogo: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Business Address',
                    'Display shop address on invoice header',
                    settings.showBusinessAddress,
                    (val) => notifier.updateSettings(settings.copyWith(showBusinessAddress: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Phone Number',
                    'Display business contact phone',
                    settings.showPhone,
                    (val) => notifier.updateSettings(settings.copyWith(showPhone: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Email Address',
                    'Display business email address',
                    settings.showEmail,
                    (val) => notifier.updateSettings(settings.copyWith(showEmail: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'GSTIN / Tax Registration',
                    'Display GSTIN / Tax number on invoice header',
                    settings.showGstin,
                    (val) => notifier.updateSettings(settings.copyWith(showGstin: val)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECTION: Invoice Details
            _buildSectionHeader('Invoice Details', Icons.receipt_long_outlined),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _buildToggleTile(
                    'Invoice Number',
                    'Show unique invoice reference ID',
                    settings.showInvoiceNumber,
                    (val) => notifier.updateSettings(settings.copyWith(showInvoiceNumber: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Invoice Date',
                    'Show date of invoice creation',
                    settings.showInvoiceDate,
                    (val) => notifier.updateSettings(settings.copyWith(showInvoiceDate: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Invoice Time',
                    'Show time of invoice creation',
                    settings.showInvoiceTime,
                    (val) => notifier.updateSettings(settings.copyWith(showInvoiceTime: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Customer Details',
                    'Show customer name & contact for customer sales',
                    settings.showCustomerInfo,
                    (val) => notifier.updateSettings(settings.copyWith(showCustomerInfo: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Previous Customer Balance',
                    'Show customer outstanding ledger balance on invoice',
                    settings.showPreviousBalance,
                    (val) => notifier.updateSettings(settings.copyWith(showPreviousBalance: val)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECTION: Items & Calculations
            _buildSectionHeader('Items & Line Pricing', Icons.shopping_bag_outlined),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _buildToggleTile(
                    'Quantity',
                    'Display product quantity alongside item name',
                    settings.showQuantity,
                    (val) => notifier.updateSettings(settings.copyWith(showQuantity: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Unit Price',
                    'Display per-unit price breakdown',
                    settings.showUnitPrice,
                    (val) => notifier.updateSettings(settings.copyWith(showUnitPrice: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Discount',
                    'Show discount line item when applicable',
                    settings.showDiscount,
                    (val) => notifier.updateSettings(settings.copyWith(showDiscount: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Tax Row & Rate',
                    'Show tax breakdown when GST is globally enabled',
                    settings.showTax,
                    (val) => notifier.updateSettings(settings.copyWith(showTax: val)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECTION: Payment & Summary
            _buildSectionHeader('Payment & Totals', Icons.payments_outlined),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _buildToggleTile(
                    'Payment Method',
                    'Display payment mode (Cash, UPI, Card, etc.)',
                    settings.showPaymentMethod,
                    (val) => notifier.updateSettings(settings.copyWith(showPaymentMethod: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Amount Paid',
                    'Show received payment amount',
                    settings.showAmountPaid,
                    (val) => notifier.updateSettings(settings.copyWith(showAmountPaid: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Balance Due',
                    'Show remaining due balance if unpaid / partial',
                    settings.showBalanceDue,
                    (val) => notifier.updateSettings(settings.copyWith(showBalanceDue: val)),
                  ),
                  const Divider(height: 16),
                  _buildToggleTile(
                    'Footer Message',
                    'Show thank you note at invoice bottom',
                    settings.showFooterMessage,
                    (val) => notifier.updateSettings(settings.copyWith(showFooterMessage: val)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
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

  Widget _buildToggleTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlueText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
