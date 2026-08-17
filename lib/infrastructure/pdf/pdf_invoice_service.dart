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

    final isGstActive = taxSettings.isGstEnabled && settings.showTax;
    final isCashSale = customer == null;

    final subtotal = invoice.subtotal;
    final taxTotal = isGstActive ? invoice.taxTotal : 0.0;
    final grandTotal = isGstActive ? invoice.grandTotal : subtotal;
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
                    width: 240,
                    child: pw.Column(
                      children: [
                        _pdfSummaryRow('Subtotal', 'INR ${subtotal.toStringAsFixed(2)}'),
                        if (isGstActive) _pdfSummaryRow('Tax (GST)', 'INR ${taxTotal.toStringAsFixed(2)}'),
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
}
