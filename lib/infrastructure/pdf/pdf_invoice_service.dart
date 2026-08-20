import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/business_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/invoice_display_settings.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/tax_settings_entity.dart';

class PdfInvoiceService {
  static Future<Uint8List> generatePdf({
    required InvoiceEntity invoice,
    required BusinessEntity business,
    required InvoiceDisplaySettingsEntity settings,
    required TaxSettingsEntity taxSettings,
    CustomerEntity? customer,
    double previousBalance = 0.0,
    String paymentMethod = 'Cash',
  }) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final timeFormatter = DateFormat('HH:mm');

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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER: Business Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        business.name.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      if (settings.showBusinessAddress && business.address.isNotEmpty)
                        pw.Text(business.address, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      if (settings.showPhone && business.phone.isNotEmpty)
                        pw.Text('Phone: ${business.phone}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      if (settings.showEmail && (business.email ?? '').isNotEmpty)
                        pw.Text('Email: ${business.email}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      if (settings.showGstin && (business.gstin ?? '').isNotEmpty)
                        pw.Text('GSTIN: ${business.gstin}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.SizedBox(height: 6),
                      if (settings.showInvoiceNumber)
                        pw.Text('#${invoice.invoiceNumber}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      if (settings.showInvoiceDate)
                        pw.Text('Date: ${dateFormatter.format(invoice.issueDate)}', style: const pw.TextStyle(fontSize: 10)),
                      if (settings.showInvoiceTime)
                        pw.Text('Time: ${timeFormatter.format(invoice.issueDate)}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // BILLED TO CUSTOMER SECTION
              if (settings.showCustomerInfo) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BILLED TO', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          isCashSale ? 'CASH SALE' : customer.name,
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        if (!isCashSale && settings.showCustomerPhone && customer.phone.isNotEmpty)
                          pw.Text('Phone: ${customer.phone}', style: const pw.TextStyle(fontSize: 10)),
                        if (!isCashSale && settings.showCustomerAddress && customer.address.isNotEmpty)
                          pw.Text('Address: ${customer.address}', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    if (settings.showPaymentMethod)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('PAYMENT METHOD', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                          pw.SizedBox(height: 4),
                          pw.Text(paymentMethod, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],

              // PRODUCT / ITEM TABLE
              pw.TableHelper.fromTextArray(
                headers: ['DESCRIPTION', 'QTY', 'UNIT PRICE', 'TOTAL'],
                data: invoice.items.map((item) {
                  return [
                    item.productName,
                    '${item.quantity}',
                    'INR ${item.unitPrice.toStringAsFixed(2)}',
                    'INR ${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 16),

              // SUMMARY BREAKDOWN & TOTALS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 250,
                    child: pw.Column(
                      children: [
                        _pdfSummaryRow('Subtotal', 'INR ${subtotal.toStringAsFixed(2)}'),
                        if (discountTotal > 0) ...[
                          _pdfSummaryRow('Discount', '- INR ${discountTotal.toStringAsFixed(2)}', color: PdfColors.green800),
                          _pdfSummaryRow('Taxable Amount', 'INR ${taxableAmount.toStringAsFixed(2)}'),
                        ],
                        if (isGstActive) _pdfSummaryRow('Tax (GST)', 'INR ${taxTotal.toStringAsFixed(2)}'),
                        if (extraExpense > 0)
                          _pdfSummaryRow(
                            invoice.extraExpenseDescription.isNotEmpty
                                ? 'Extra Expense (${invoice.extraExpenseDescription})'
                                : 'Extra Expense',
                            'INR ${extraExpense.toStringAsFixed(2)}',
                          ),
                        if (!isCashSale && settings.showPreviousBalance && previousBalance > 0)
                          _pdfSummaryRow('Previous Balance', 'INR ${previousBalance.toStringAsFixed(2)}'),
                        pw.Divider(thickness: 1, color: PdfColors.grey400),
                        _pdfSummaryRow('Grand Total', 'INR ${grandTotal.toStringAsFixed(2)}', isBold: true, fontSize: 14),
                        if (settings.showAmountPaid)
                          _pdfSummaryRow('Amount Paid', 'INR ${amountPaid.toStringAsFixed(2)}', color: PdfColors.green800),
                        if (settings.showBalanceDue && balanceDue > 0)
                          _pdfSummaryRow('Balance Due', 'INR ${balanceDue.toStringAsFixed(2)}', color: PdfColors.red800, isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // FOOTER
              if (settings.showFooterMessage) ...[
                pw.Center(
                  child: pw.Text(
                    settings.footerMessage,
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                  ),
                ),
                pw.SizedBox(height: 4),
              ],
              pw.Center(
                child: pw.Text(
                  'Generated by XenoBiz POS Application',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfSummaryRow(String label, String value, {bool isBold = false, double fontSize = 10, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? (isBold ? PdfColors.blue900 : PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> printInvoice({
    required InvoiceEntity invoice,
    required BusinessEntity business,
    required InvoiceDisplaySettingsEntity settings,
    required TaxSettingsEntity taxSettings,
    CustomerEntity? customer,
    double previousBalance = 0.0,
    String paymentMethod = 'Cash',
  }) async {
    final pdfBytes = await generatePdf(
      invoice: invoice,
      business: business,
      settings: settings,
      taxSettings: taxSettings,
      customer: customer,
      previousBalance: previousBalance,
      paymentMethod: paymentMethod,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice_${invoice.invoiceNumber}',
    );
  }

  static Future<void> sharePdf({
    required InvoiceEntity invoice,
    required BusinessEntity business,
    required InvoiceDisplaySettingsEntity settings,
    required TaxSettingsEntity taxSettings,
    CustomerEntity? customer,
    double previousBalance = 0.0,
    String paymentMethod = 'Cash',
  }) async {
    final pdfBytes = await generatePdf(
      invoice: invoice,
      business: business,
      settings: settings,
      taxSettings: taxSettings,
      customer: customer,
      previousBalance: previousBalance,
      paymentMethod: paymentMethod,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Invoice_${invoice.invoiceNumber}.pdf',
    );
  }

  // ===========================================================================
  // 2-INCH THERMAL RECEIPT GENERATOR & PRINTER
  // ===========================================================================
  static Future<Uint8List> generate2InchThermalPdf({
    required InvoiceEntity invoice,
    required BusinessEntity business,
    required InvoiceDisplaySettingsEntity settings,
    required TaxSettingsEntity taxSettings,
    CustomerEntity? customer,
    double previousBalance = 0.0,
    String paymentMethod = 'Cash',
  }) async {
    final pdf = pw.Document();
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

    // 2-inch thermal paper format (58mm width roll)
    const rollFormat = PdfPageFormat(
      58 * PdfPageFormat.mm,
      double.infinity,
      marginLeft: 3 * PdfPageFormat.mm,
      marginRight: 3 * PdfPageFormat.mm,
      marginTop: 4 * PdfPageFormat.mm,
      marginBottom: 8 * PdfPageFormat.mm,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: rollFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Business Header
              pw.Center(
                child: pw.Text(
                  business.name.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              if (settings.showBusinessAddress && business.address.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    business.address,
                    style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
              if (settings.showPhone && business.phone.isNotEmpty) ...[
                pw.SizedBox(height: 1),
                pw.Center(
                  child: pw.Text(
                    'Ph: ${business.phone}',
                    style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
              if (settings.showEmail && (business.email ?? '').isNotEmpty) ...[
                pw.SizedBox(height: 1),
                pw.Center(
                  child: pw.Text(
                    'Email: ${business.email}',
                    style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
              if (settings.showGstin && (business.gstin ?? '').isNotEmpty) ...[
                pw.SizedBox(height: 1),
                pw.Center(
                  child: pw.Text(
                    'GSTIN: ${business.gstin}',
                    style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],

              _thermalDashedLine(),

              // Invoice Metadata
              pw.Center(
                child: pw.Text(
                  'TAX INVOICE',
                  style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 3),
              if (settings.showInvoiceNumber)
                _thermalInfoRow('Invoice No:', '#${invoice.invoiceNumber}'),
              if (settings.showInvoiceDate)
                _thermalInfoRow(
                  'Date:',
                  '${dateFormatter.format(invoice.issueDate)} ${settings.showInvoiceTime ? timeFormatter.format(invoice.issueDate) : ''}',
                ),
              if (settings.showCustomerInfo) ...[
                _thermalInfoRow('Billed To:', isCashSale ? 'Cash Sale' : customer.name),
                if (!isCashSale && settings.showCustomerPhone && customer.phone.isNotEmpty)
                  _thermalInfoRow('Phone:', customer.phone),
              ],

              _thermalDashedLine(),

              // Item Table Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('ITEM DESCRIPTION', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                  pw.Text('QTY  AMOUNT', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              _thermalDashedLine(),

              // Product Items List
              ...invoice.items.map((item) {
                final itemTotal = item.quantity * item.unitPrice;
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item.productName,
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${item.quantity} x INR ${item.unitPrice.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800),
                          ),
                          pw.Text(
                            'INR ${itemTotal.toStringAsFixed(2)}',
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              _thermalDashedLine(),

              // Subtotal & Calculations
              _thermalSummaryRow('Subtotal', 'INR ${subtotal.toStringAsFixed(2)}'),
              if (discountTotal > 0) ...[
                _thermalSummaryRow('Discount', '- INR ${discountTotal.toStringAsFixed(2)}'),
                _thermalSummaryRow('Taxable Amt', 'INR ${taxableAmount.toStringAsFixed(2)}'),
              ],
              if (isGstActive) _thermalSummaryRow('GST / Tax', 'INR ${taxTotal.toStringAsFixed(2)}'),
              if (extraExpense > 0)
                _thermalSummaryRow(
                  invoice.extraExpenseDescription.isNotEmpty
                      ? 'Extra (${invoice.extraExpenseDescription})'
                      : 'Extra Expense',
                  'INR ${extraExpense.toStringAsFixed(2)}',
                ),
              if (!isCashSale && settings.showPreviousBalance && previousBalance > 0)
                _thermalSummaryRow('Prev Balance', 'INR ${previousBalance.toStringAsFixed(2)}'),

              _thermalDashedLine(),

              // Grand Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GRAND TOTAL', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                  pw.Text('INR ${grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
                ],
              ),

              _thermalDashedLine(),

              // Payment Summary
              if (settings.showPaymentMethod) _thermalSummaryRow('Payment Mode', paymentMethod),
              if (settings.showAmountPaid) _thermalSummaryRow('Amount Paid', 'INR ${amountPaid.toStringAsFixed(2)}'),
              if (settings.showBalanceDue && balanceDue > 0)
                _thermalSummaryRow('Balance Due', 'INR ${balanceDue.toStringAsFixed(2)}', isBold: true),

              _thermalDashedLine(),

              // Footer Note
              if (settings.showFooterMessage && settings.footerMessage.isNotEmpty) ...[
                pw.Center(
                  child: pw.Text(
                    settings.footerMessage,
                    style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 3),
              ],
              pw.Center(
                child: pw.Text(
                  '*** Thank You! Visit Again ***',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  'Powered by XenoBiz POS',
                  style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 12),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _thermalDashedLine() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Text(
        '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -',
        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
        maxLines: 1,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  static pw.Widget _thermalInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800)),
          pw.Text(value, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _thermalSummaryRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> print2InchThermalInvoice({
    required InvoiceEntity invoice,
    required BusinessEntity business,
    required InvoiceDisplaySettingsEntity settings,
    required TaxSettingsEntity taxSettings,
    CustomerEntity? customer,
    double previousBalance = 0.0,
    String paymentMethod = 'Cash',
  }) async {
    final pdfBytes = await generate2InchThermalPdf(
      invoice: invoice,
      business: business,
      settings: settings,
      taxSettings: taxSettings,
      customer: customer,
      previousBalance: previousBalance,
      paymentMethod: paymentMethod,
    );

    const rollFormat = PdfPageFormat(
      58 * PdfPageFormat.mm,
      double.infinity,
      marginLeft: 3 * PdfPageFormat.mm,
      marginRight: 3 * PdfPageFormat.mm,
      marginTop: 4 * PdfPageFormat.mm,
      marginBottom: 8 * PdfPageFormat.mm,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Receipt_${invoice.invoiceNumber}',
      format: rollFormat,
      usePrinterSettings: false,
    );
  }
}
