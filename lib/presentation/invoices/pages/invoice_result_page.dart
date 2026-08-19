import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../application/bloc/auth_bloc.dart';
import '../../../application/bloc/tax_settings_bloc.dart';
import '../../../application/providers/app_providers.dart';
import '../../../application/providers/create_invoice_provider.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/business_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/tax_settings_entity.dart';
import '../../../infrastructure/pdf/pdf_invoice_service.dart';

class InvoiceResultPage extends ConsumerWidget {
  final InvoiceEntity invoice;
  final CustomerEntity? customer;
  final String paymentMethod;
  final double amountPaid;
  final double previousBalance;

  const InvoiceResultPage({
    super.key,
    required this.invoice,
    this.customer,
    this.paymentMethod = 'Cash',
    this.amountPaid = 0.0,
    this.previousBalance = 0.0,
  });

  Future<void> _launchWhatsApp(BuildContext context, String message, String? phone) async {
    final cleanPhone = (phone != null && phone.trim().isNotEmpty && phone != 'N/A')
        ? phone.replaceAll(RegExp(r'[^\d+]'), '')
        : '';
    final encodedMessage = Uri.encodeComponent(message);
    final urlString = cleanPhone.isNotEmpty
        ? 'https://wa.me/$cleanPhone?text=$encodedMessage'
        : 'https://wa.me/?text=$encodedMessage';

    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch WhatsApp'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  BusinessEntity _getBusinessEntity(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState && authState.business != null) {
      return authState.business!;
    }
    return BusinessEntity(
      id: 'biz_main',
      name: 'XenoBiz Enterprise',
      phone: '+91 98765 43210',
      email: 'contact@xenobiz.com',
      address: '123 Business Parkway, Suite 400',
      category: 'Retail POS',
      currency: '₹',
      createdAt: DateTime.now(),
    );
  }

  TaxSettingsEntity _getTaxSettings(BuildContext context) {
    final taxState = context.read<TaxSettingsBloc>().state;
    if (taxState is TaxSettingsLoadedState) {
      return taxState.settings;
    }
    return const TaxSettingsEntity();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displaySettings = ref.watch(invoiceDisplaySettingsProvider);
    final business = _getBusinessEntity(context);
    final taxSettings = _getTaxSettings(context);

    final isGstActive = taxSettings.isGstEnabled && displaySettings.showTax;
    final isCashSale = customer == null;

    final subtotal = invoice.subtotal;
    final taxTotal = isGstActive ? invoice.taxTotal : 0.0;
    final grandTotal = isGstActive ? invoice.grandTotal : subtotal;
    final effectivePaid = amountPaid > 0 ? amountPaid : invoice.paidAmount;
    final balanceDue = (grandTotal - effectivePaid).clamp(0.0, double.infinity);

    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('HH:mm');
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlueText),
          onPressed: () => context.go(RouteNames.dashboard),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: AppColors.darkBlueText,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.darkBlueText),
            onSelected: (val) {
              if (val == 'settings') {
                context.push(RouteNames.invoiceSettings);
              } else if (val == 'print') {
                PdfInvoiceService.printInvoice(
                  invoice: invoice,
                  business: business,
                  settings: displaySettings,
                  taxSettings: taxSettings,
                  customer: customer,
                  previousBalance: previousBalance,
                  paymentMethod: paymentMethod,
                );
              } else if (val == 'share') {
                PdfInvoiceService.sharePdf(
                  invoice: invoice,
                  business: business,
                  settings: displaySettings,
                  taxSettings: taxSettings,
                  customer: customer,
                  previousBalance: previousBalance,
                  paymentMethod: paymentMethod,
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'print', child: Text('Print A4 Invoice')),
              const PopupMenuItem(value: 'share', child: Text('Share PDF')),
              const PopupMenuItem(value: 'settings', child: Text('Invoice Settings')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // CENTERED ELEVATED INVOICE CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Store Logo Icon Box
                  if (displaySettings.showLogo) ...[
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A3FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Business Header
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkBlueText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  if (displaySettings.showBusinessAddress && business.address.isNotEmpty)
                    Text(
                      business.address,
                      style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                      textAlign: TextAlign.center,
                    ),
                  if (displaySettings.showEmail && (business.email ?? '').isNotEmpty)
                    Text(
                      business.email!,
                      style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 18),

                  // INVOICE METADATA ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (displaySettings.showInvoiceNumber) ...[
                            const Text(
                              'INVOICE NO.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.outline,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '#${invoice.invoiceNumber}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (displaySettings.showInvoiceDate) ...[
                            const Text(
                              'DATE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.outline,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${dateFormatter.format(invoice.issueDate)} ${displaySettings.showInvoiceTime ? '- ${timeFormatter.format(invoice.issueDate)}' : ''}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BILLED TO CUSTOMER SECTION
                  if (displaySettings.showCustomerInfo) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BILLED TO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.outline,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCashSale ? 'Cash Sale' : customer!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          if (!isCashSale && displaySettings.showCustomerPhone && customer!.phone.isNotEmpty)
                            Text(
                              'Attn: ${customer!.phone}',
                              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 14),

                  // ITEM TABLE HEADERS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.outline,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'QTY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.outline,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 24),
                          Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.outline,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // PRODUCT ITEMS LIST
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: invoice.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, idx) {
                      final item = invoice.items[idx];
                      final itemTotal = item.quantity * item.unitPrice;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlueText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displaySettings.showUnitPrice
                                      ? '${item.quantity} × ${currencyFormatter.format(item.unitPrice)}'
                                      : 'Qty: ${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            currencyFormatter.format(itemTotal),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),

                  // CALCULATIONS SUMMARY
                  _buildSummaryLine('Subtotal', currencyFormatter.format(subtotal)),
                  if (isGstActive)
                    _buildSummaryLine('Tax (GST)', currencyFormatter.format(taxTotal)),
                  if (!isCashSale && displaySettings.showPreviousBalance && previousBalance > 0)
                    _buildSummaryLine('Previous Balance', currencyFormatter.format(previousBalance), color: AppColors.warning),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),

                  // GRAND TOTAL DISPLAY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlueText,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(grandTotal),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0066CC),
                        ),
                      ),
                    ],
                  ),

                  // PAYMENT SUMMARY
                  if (displaySettings.showAmountPaid || displaySettings.showBalanceDue) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pageBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          if (displaySettings.showPaymentMethod)
                            _buildMiniSummary('Payment Mode', paymentMethod),
                          if (displaySettings.showAmountPaid)
                            _buildMiniSummary('Amount Paid', currencyFormatter.format(effectivePaid), color: AppColors.success),
                          if (displaySettings.showBalanceDue && balanceDue > 0)
                            _buildMiniSummary('Balance Due', currencyFormatter.format(balanceDue), color: AppColors.danger),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ACTION BUTTONS SECTION

            // 1. SEND ON WHATSAPP (FULL WIDTH GREEN BUTTON)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final msg = 'Dear ${isCashSale ? "Customer" : customer!.name}, your invoice #${invoice.invoiceNumber} for ${currencyFormatter.format(grandTotal)} is generated. Thank you for shopping with ${business.name}!';
                  _launchWhatsApp(context, msg, isCashSale ? null : customer!.phone);
                },
                icon: const Icon(Icons.chat_bubble, size: 20),
                label: const Text(
                  'SEND ON WHATSAPP',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. SHARE PDF & PRINT BUTTON ROW
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0066CC),
                      side: const BorderSide(color: Color(0xFF0066CC), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      PdfInvoiceService.sharePdf(
                        invoice: invoice,
                        business: business,
                        settings: displaySettings,
                        taxSettings: taxSettings,
                        customer: customer,
                        previousBalance: previousBalance,
                        paymentMethod: paymentMethod,
                      );
                    },
                    icon: const Icon(Icons.ios_share, size: 18),
                    label: const Text(
                      'SHARE PDF',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0066CC),
                      side: const BorderSide(color: Color(0xFF0066CC), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      PdfInvoiceService.print2InchThermalInvoice(
                        invoice: invoice,
                        business: business,
                        settings: displaySettings,
                        taxSettings: taxSettings,
                        customer: customer,
                        previousBalance: previousBalance,
                        paymentMethod: paymentMethod,
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text(
                      'PRINT',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. CREATE ANOTHER INVOICE (LIGHT BLUE CONTAINER BUTTON)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6F2FF),
                  foregroundColor: const Color(0xFF0066CC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  // Completely reset create invoice form state
                  ref.read(createInvoiceFormProvider.notifier).reset();
                  // Open fresh Create Invoice Screen
                  context.go(RouteNames.createInvoice);
                },
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text(
                  'CREATE ANOTHER INVOICE',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color ?? AppColors.darkBlueText),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummary(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color ?? AppColors.darkBlueText)),
        ],
      ),
    );
  }
}
