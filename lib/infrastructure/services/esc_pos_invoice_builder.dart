import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../../domain/entities/business_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/invoice_display_settings.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/tax_settings_entity.dart';
import 'esc_pos_command_builder.dart';

/// Formats invoice entity into a 2-inch (32 column) ESC/POS byte array.
class EscPosInvoiceBuilder {
  static Uint8List buildInvoiceBytes({
    required InvoiceEntity invoice,
    required BusinessEntity business,
    required InvoiceDisplaySettingsEntity settings,
    required TaxSettingsEntity taxSettings,
    CustomerEntity? customer,
    double previousBalance = 0.0,
    String paymentMethod = 'Cash',
    int paperWidth = 32,
  }) {
    final builder = EscPosCommandBuilder()..initialize();
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    final isGstActive = taxSettings.isGstEnabled && invoice.gstEnabled && settings.showTax;
    final isCashSale = customer == null;

    final subtotal = invoice.subtotal;
    final discountTotal = invoice.discountTotal;
    final taxableAmount = (subtotal - discountTotal).clamp(0.0, double.infinity);
    final taxTotal = isGstActive ? invoice.taxTotal : 0.0;
    final extraExpense = invoice.extraExpenseAmount;
    final grandTotal = invoice.grandTotal;
    final amountPaid = invoice.paidAmount;
    final balanceDue = (grandTotal - amountPaid).clamp(0.0, double.infinity);

    // 1. BUSINESS HEADER (Centered, Bold, Double Size)
    builder.setAlign(EscPosAlign.center);
    builder.setBold(true);
    builder.setSize(doubleHeight: true, doubleWidth: true);
    builder.text(business.name.toUpperCase());
    builder.setSize();
    builder.setBold(false);

    if (settings.showBusinessAddress && business.address.isNotEmpty) {
      builder.text(business.address);
    }
    if (settings.showPhone && business.phone.isNotEmpty) {
      builder.text('Ph: ${business.phone}');
    }
    if (settings.showEmail && (business.email ?? '').isNotEmpty) {
      builder.text('Email: ${business.email}');
    }
    if (settings.showGstin && (business.gstin ?? '').isNotEmpty) {
      builder.setBold(true);
      builder.text('GSTIN: ${business.gstin}');
      builder.setBold(false);
    }

    builder.line(width: paperWidth);

    // 2. INVOICE METADATA & CUSTOMER DETAILS
    builder.setAlign(EscPosAlign.center);
    builder.setBold(true);
    builder.text('TAX INVOICE');
    builder.setBold(false);

    builder.setAlign(EscPosAlign.left);
    if (settings.showInvoiceNumber) {
      builder.twoColumnRow('Invoice No:', '#${invoice.invoiceNumber}', width: paperWidth);
    }
    if (settings.showInvoiceDate) {
      final timeStr = settings.showInvoiceTime ? ' ${timeFormatter.format(invoice.issueDate)}' : '';
      builder.twoColumnRow('Date:', '${dateFormatter.format(invoice.issueDate)}$timeStr', width: paperWidth);
    }
    if (settings.showCustomerInfo) {
      builder.twoColumnRow('Billed To:', isCashSale ? 'Cash Sale' : customer.name, width: paperWidth);
      if (!isCashSale && settings.showCustomerPhone && customer.phone.isNotEmpty) {
        builder.twoColumnRow('Phone:', customer.phone, width: paperWidth);
      }
    }

    builder.line(width: paperWidth);

    // 3. PRODUCT ITEMS LIST
    builder.twoColumnRow('ITEM DESCRIPTION', 'AMOUNT', width: paperWidth, bold: true);
    builder.line(width: paperWidth);

    for (var item in invoice.items) {
      final itemTotal = item.quantity * item.unitPrice;
      builder.setBold(true);
      builder.text(item.productName);
      builder.setBold(false);
      builder.twoColumnRow(
        '  ${item.quantity} x Rs.${item.unitPrice.toStringAsFixed(2)}',
        'Rs.${itemTotal.toStringAsFixed(2)}',
        width: paperWidth,
      );
    }

    builder.line(width: paperWidth);

    // 4. CALCULATIONS BREAKDOWN
    builder.twoColumnRow('Subtotal:', 'Rs.${subtotal.toStringAsFixed(2)}', width: paperWidth);
    if (discountTotal > 0) {
      builder.twoColumnRow('Discount:', '-Rs.${discountTotal.toStringAsFixed(2)}', width: paperWidth);
      builder.twoColumnRow('Taxable Amt:', 'Rs.${taxableAmount.toStringAsFixed(2)}', width: paperWidth);
    }
    if (isGstActive) {
      builder.twoColumnRow('GST / Tax:', 'Rs.${taxTotal.toStringAsFixed(2)}', width: paperWidth);
    }
    if (extraExpense > 0) {
      final label = invoice.extraExpenseDescription.isNotEmpty ? 'Extra (${invoice.extraExpenseDescription}):' : 'Extra Expense:';
      builder.twoColumnRow(label, 'Rs.${extraExpense.toStringAsFixed(2)}', width: paperWidth);
    }
    if (!isCashSale && settings.showPreviousBalance && previousBalance > 0) {
      builder.twoColumnRow('Prev Balance:', 'Rs.${previousBalance.toStringAsFixed(2)}', width: paperWidth);
    }

    builder.line(width: paperWidth);

    // 5. GRAND TOTAL (Bold & Prominent)
    builder.setBold(true);
    builder.twoColumnRow('GRAND TOTAL:', 'Rs.${grandTotal.toStringAsFixed(2)}', width: paperWidth, bold: true);
    builder.setBold(false);

    builder.line(width: paperWidth);

    // 6. PAYMENT SUMMARY
    if (settings.showPaymentMethod) {
      builder.twoColumnRow('Payment Mode:', paymentMethod, width: paperWidth);
    }
    if (settings.showAmountPaid) {
      builder.twoColumnRow('Amount Paid:', 'Rs.${amountPaid.toStringAsFixed(2)}', width: paperWidth);
    }
    if (settings.showBalanceDue && balanceDue > 0) {
      builder.twoColumnRow('Balance Due:', 'Rs.${balanceDue.toStringAsFixed(2)}', width: paperWidth, bold: true);
    }

    builder.line(width: paperWidth);

    // 7. FOOTER
    builder.setAlign(EscPosAlign.center);
    if (settings.showFooterMessage && settings.footerMessage.isNotEmpty) {
      builder.setBold(true);
      builder.text(settings.footerMessage);
      builder.setBold(false);
    }
    builder.text('*** Thank You! Visit Again ***');
    builder.text('Powered by XenoBiz POS');

    // 8. PAPER FEED & CUT
    builder.feed(4);
    builder.cut();

    return builder.build();
  }
}
